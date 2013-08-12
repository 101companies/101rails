class PagesController < ApplicationController

  respond_to :json, :html

  # order of next two lines is very important!
  # before_filter need to be before load_and_authorize_resource
  before_filter :get_the_page
  # methods, that need to check permissions
  load_and_authorize_resource :only => [:delete, :rename, :update]

  def get_the_page

    # get page title
    full_title = params[:id]

    # if no title -> set default wiki startpage '@project'
    if full_title == nil
      full_title = '@project'
    end

    # 'wikify' title param
    full_title = Page.unescape_wiki_url full_title

    # remove trailing spaces
    full_title.strip!

    @page = Page.find_by_full_title full_title

    # page not found and user can create page -> create new page by full_title
    if @page.nil? && (can? :create, Page.new)
      @page = Page.new
      namespace_and_title = Page.retrieve_namespace_and_title full_title
      @page.title = namespace_and_title['title']
      @page.namespace = namespace_and_title['namespace']
      @page.save
    end

    # if no page created/found
    if !@page
      respond_to do |format|
        format.html {
          flash[:error] = "Page wasn't not found. Redirected to main wiki page"
          go_to_homepage
        }
        format.json {
          render :json => {success: false}, :status => 404
        }
      end
    end

  end

  def semantic_properties
    semantic_hash = Hash.new
    %w(dependsOn instanceOf identifies cites linksTo uses implements isA developedBy reviewedBy relatesTo
       implies mentions).map {|prop| semantic_hash["#{prop}"] = "http://101companies.org/property/#{prop}"}
    semantic_hash
  end

  # TODO: refactor
  def get_context_for(title)
    if ((title.split(':').length == 2) and (title.starts_with?('http') == false))
      @ctx  = {ns: title.split(':')[0].downcase, title: title.split(':')[1]}
    elsif title.starts_with?('http')
      @ctx = {title: title}
    else
      @ctx = {ns: 'concept', title: title.split(':')[0]}
    end

    return @ctx
  end

  def page_to_resource(title)
    return title if title.starts_with?('http')
    page = Page.find_by_full_title Page.unescape_wiki_url title
    return nil if page.nil?
    RDF::URI.new("http://101companies.org/resources/#{page.namespace.downcase.pluralize}/#{page.title.sub(' ', '_')}")
  end

  def get_rdf_graph(title, directions=false)
     @page = Page.find_by_full_title Page.unescape_wiki_url title

     uri = self.page_to_resource title
     graph = RDF::Graph.new #<< [uri, RDF::RDFS.title, title]

     context   = RDF::URI.new("http://101companies.org")

     server = RDF::Sesame::Server.new RDF::URI("http://triples.101companies.org/openrdf-sesame")
     repository = server.repository("wiki2")

     @page.semantic_links.each { |l|
      if directions
        subject = RDF::Literal.new("OUT")
      else
        subject = uri
      end
      # uncapitalize link
      semantic_flag = l.split('::')[0]
      semantic_flag = semantic_flag[0, 1].downcase + semantic_flag[1..-1]
      predicate = RDF::URI.new(self.semantic_properties[semantic_flag])
      object =  l.split('::')[1]
      unless directions
        object = page_to_resource(object)
      end
      if !object.nil?
        statement =  RDF::Statement.new(subject, predicate, object, :context => context)
        graph << statement
        unless directions
          repository.delete statement
          repository.insert statement
        end
      end

    }

    unless directions
      @page.internal_links.each { |l|
        #we're not interested in semantic links
        if (l.split('::').length == 1)
          predicate =  RDF::URI.new(self.semantic_properties['mentions'])
          subject = uri
          object = l
          unless directions
            object = page_to_resource(object)
          end
          if !object.nil?
            statement =  RDF::Statement.new(subject, predicate, object, :context => context)
            graph << statement
            repository.delete statement
            repository.insert statement
          end
        end
      }
    end
    return graph
  end

  def get_rdf
    title = params[:id]
    begin
      graph = self.get_rdf_graph(title)
      respond_with graph.dump(:ntriples)
    rescue
      error_message="#{$!}"
      Rails.logger.error error_message
      respond_with error_message
    end
  end

  def get_json
    title = params[:id]
    directions = params[:directions]
    json = []
    rdf = self.get_rdf_graph(title, directions)
    rdf.each do |resource|
      p = "#{resource.predicate.scheme}://#{resource.predicate.host}#{resource.predicate.path}"
      o = resource.object.kind_of?(RDF::Literal) ?
          resource.object.object : "#{resource.object.scheme}://#{resource.object.host}#{resource.object.path}"
      if directions
        s = "#{resource.subject}"
        json.push ({
          :direction => s,
          :predicate => p,
          :node => o.sub('http://101companies.org/resources/', '')
        })
      else
        s = "#{resource.subject.scheme}://#{resource.subject.host}#{resource.subject.path}"
        json.append [s,p,o]
      end
    end
    respond_with json
  end

  def delete
    result = @page.delete
    # generate message if deleting was successful
    if result
      flash[:notice] = 'Page ' + @page.full_title + ' was deleted'
    end
    render :json => {:success => result}
  end

  def show
    respond_to do |format|
      format.html {
        # if need redirect? -> wiki url conventions -> do a redirect
        good_link = @page.nice_wiki_url
        if good_link != params[:id]
          redirect_to '/wiki/'+ good_link and return
        end
        # no redirect? -> render the page
        render :html => @page
      }
      format.json { render :json => {
        'id'        => @page.full_title,
        'content'   => @page.raw_content,
        'sections'  => @page.sections,
        # TODO: fix for new history
        'history'   => [], #@page.history.as_json(:include => {:user => { :except => [:role, :github_name]}}),
        # TODO: restore
        'backlinks' => @page.backlinks
      }}

    end
  end

  def parse
    parsed_page = @page.create_wiki_parser params[:content]
    html = parsed_page.to_html
    # define links pointing to pages without content
    # mark empty or non-existing page with class missing-link (red color)
    parsed_page.internal_links.each do |link|
      # format link to nice readable view
      nice_link = Page.nice_wiki_url link
      # get the page by link in html
      used_page = Page.find_by_full_title Page.unescape_wiki_url nice_link
      # if not found page or it has no content
      # set in class_attribute additional class for link (mark with red)
      class_attribute = ''
      if used_page.nil? || used_page.raw_content.nil?
        class_attribute = 'class="missing-link"'
      end
      # replace page link in html
      html.gsub! "<a href=\"#{link}\"",
                 "<a " + class_attribute + " href=\"/wiki/#{nice_link}\""
      html.gsub! "<a href=\"#{link.camelize(:lower)}\"",
                 "<a " + class_attribute + " href=\"/wiki/#{nice_link}\""
    end
    render :json => {:success => true, :html => html.html_safe}
  end

  def search
    @query_string = params[:q]
    if @query_string == ''
      flash[:notice] = 'Please write something, if you want to search something'
      go_to_homepage
    else
      @search_results = Page.search @query_string
      respond_with @search_results
    end
  end

  def summary
    render :json => {:sections => @page.sections, :internal_links => @page.internal_links}
  end

  # get all sections for a page
  def sections
    respond_with @page.sections
  end

  # get all internal links for the page
  def internal_links
    respond_with @page.internal_links
  end

  def update
    sections = params[:sections]
    content = params[:content]
    new_full_title = Page.unescape_wiki_url params[:newTitle]
    render :json => {
      :success => @page.update_or_rename_page(new_full_title, content, sections),
      :newTitle => @page.nice_wiki_url
    }
  end

  def section
    respond_with ({:content => @page.section(params[:full_title])}).to_json
  end

end
