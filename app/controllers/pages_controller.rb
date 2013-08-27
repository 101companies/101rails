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
    full_title = '@project' if full_title == nil

    @page = Page.find_by_full_title full_title

    # page not found and user can create page -> create new page by full_title
    @page = Page.create_page_by_full_title full_title if @page.nil? && (can? :create, Page.new)

    # if no page created/found
    if !@page
      respond_to do |format|
        format.html do
          flash[:error] = "Page wasn't not found. Redirected to main wiki page"
          go_to_homepage
        end
        format.json { render :json => {success: false}, :status => 404 }
      end
    end

  end

  def semantic_properties
    semantic_hash = Hash.new
    %w(dependsOn instanceOf identifies cites linksTo uses implements isA developedBy reviewedBy relatesTo
       implies mentions).map {|prop| semantic_hash["#{prop}"] = "http://101companies.org/property/#{prop}"}
    semantic_hash
  end

  def get_rdf_graph(title, directions=false)
    @page = Page.find_by_full_title Page.unescape_wiki_url title
    uri = self.page_to_resource title
    context   = RDF::URI.new("http://101companies.org")
    graph = RDF::Graph.new

    @page.semantic_links.each do |link|
      subject = directions ? RDF::Literal.new("OUT") : uri
      link_prefix = link.split('::')[1]
      object = directions ? link_prefix : page_to_resource(link_prefix)
      semantic_property = Page.uncapitalize_first_char link.split('::')[0]
      if !object.nil?
        graph <<  RDF::Statement.new(subject, RDF::URI.new(self.semantic_properties[semantic_property]),
                                     object, :context => context)
      end
    end

    unless directions
      (@page.internal_links-@page.semantic_links).each do |link|
        object = directions ? link : page_to_resource(link)
        if !object.nil?
          graph << RDF::Statement.new(uri, RDF::URI.new(self.semantic_properties['mentions']), object,
                                      :context => context)
        end
      end
    end

    semantic_properties.each do |prop_key, value|
      prop_key = MediaWiki::send :upcase_first_char, prop_key
      Page.where(:used_links => prop_key+'::'+@page.full_title).each do |page|
        graph << RDF::Statement.new(RDF::Literal.new("IN"), value, page.full_title, :context => context)
      end
    end

    graph
  end

  def page_to_resource(title)
    return title if title.starts_with?('Http')
    page = Page.find_by_full_title title
    return nil if page.nil?
    RDF::URI.new("http://101companies.org/resources/#{page.namespace.downcase.pluralize}/#{page.title.gsub(' ', '_')}")
  end

  def reverse_statement(st, title)
    RDF::Statement.new( page_to_resource(st.object.to_s), st.predicate, page_to_resource(title), :context => st.context)
  end

  def get_rdf
    title = params[:id]
    begin
      graph_to_return = RDF::Graph.new
      self.get_rdf_graph(title).each do |st|
        graph_to_return << (st.subject.to_s === "IN" ? (reverse_statement st, title) : st)
      end
      respond_with graph_to_return.dump(:ntriples)
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
    self.get_rdf_graph(title, directions).each do |res|
      if directions
        json << { :direction => res.subject.to_s, :predicate => res.predicate.to_s, :node => res.object.to_s }
      else
        # ingoing triples
        res = reverse_statement res, title if res.subject.to_s == 'IN'
        json << [ res.subject.to_s, res.predicate.to_s, res.object.to_s ]
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
        'backlinks' => @page.backlinks
      }}

    end
  end

  def parse
    parsed_page = @page.create_wiki_parser params[:content]
    html = parsed_page.to_html
    # mark empty or non-existing page with class missing-link (red color)
    parsed_page.internal_links.each do |link|
      nice_link = Page.nice_wiki_url link
      used_page = Page.find_by_full_title nice_link
      # if not found page or it has no content
      # set in class_attribute additional class for link (mark with red)
      class_attribute = (used_page.nil? || used_page.raw_content.nil?) ? 'class="missing-link"' : ''
      # replace page links in html
      html.gsub! "<a href=\"#{link}\"", "<a #{class_attribute} href=\"/wiki/#{nice_link}\""
      html.gsub! "<a href=\"#{link.camelize(:lower)}\"", "<a #{class_attribute} href=\"/wiki/#{nice_link}\""
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
    # TODO: renaming -> check used page
    render :json => {
      :success => @page.update_or_rename_page(new_full_title, content, sections),
      :newTitle => @page.nice_wiki_url
    }
  end

  def section
    respond_with ({:content => @page.section(params[:full_title])}).to_json
  end

end
