class PagesController < ApplicationController

  respond_to :json, :html

  # methods, that need to check permissions
  #load_and_authorize_resource :only => [:delete, :rename, :update]

  before_filter :get_the_page

  def get_the_page

    # get page title
    full_title = params[:id]

    # if no title -> set default wiki startpage '@project'
    if full_title == nil
      full_title = '@project'
    end

    # 'wikify' title param
    full_title = Page.unescape_wiki_url full_title

    # if user can create page -> create new
    if can? :create, Page.new
      @page = Page.find_or_create_page full_title
    # else this page doesn't exist
    else
      @page = Page.find_by_full_title full_title
    end

    # check page existence
    if @page == nil
      flash[:error] = "Page wasn't not found. Redirected to main wiki page"
      # TODO: different formats
      redirect_to '/wiki'
    end

  end

  def clean_cache
    @page.clear_wiki_cache
    flash[:notice] = "Cache for page "+@page.full_title+" successfully cleared"
    redirect_to :action => 'show', :id => @page.full_title
  end

  def semantic_properties
    {
      'dependsOn'  => 'http://101companies.org/property/dependsOn',
      'instanceOf'  => 'http://101companies.org/property/instanceOf',
      'identifies'  => 'http://101companies.org/property/identifies',
      'linksTo'     => 'http://101companies.org/property/linksTo',
      'cites'       => 'http://101companies.org/property/cites',
      'uses'        => 'http://101companies.org/property/uses',
      'implements'  => 'http://101companies.org/property/implements',
      'instanceOf'  => 'http://101companies.org/property/instanceOf',
      'isA'         => 'http://101companies.org/property/isA',
      'developedBy' => 'http://101companies.org/property/developedBy',
      'reviewedBy'  => 'http://101companies.org/property/reviewedBy',
      'relatesTo'   => 'http://101companies.org/property/relatesTo',
      'implies'   => 'http://101companies.org/property/implies',
      'mentions'    => 'http://101companies.org/property/mentions'
    }
  end

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
    page = Page.find_by_full_title(Page.unescape_wiki_url(title))
    if page.title.starts_with?('http')
      page.title
    else
      RDF::URI.new("http://101companies.org/resources/#{page.namespace.pluralize}/#{page.title}")
    end
  end

  # get all titles as json
  def all
    render :json => Page.get_all_pages_uris
  end

  def get_rdf_graph(title, directions=false)
     @page = Page.find_by_full_title(title)

     uri = self.page_to_resource title
     #TODO: unused variable
     v101 = RDF::Vocabulary.new("http://101companies.org/property/")
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
      predicate = RDF::URI.new(self.semantic_properties[l.split('::')[0]])
      object =  l.split('::')[1]
      unless directions
        object = page_to_resource(object)
      end
      statement =  RDF::Statement.new(subject, predicate, object, :context => context)
      graph << statement
      unless directions
        repository.delete statement
        repository.insert statement
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
          statement =  RDF::Statement.new(subject, predicate, object, :context => context)
          graph << statement
          repository.delete statement
          repository.insert statement
        end
      }
    end

    server = RDF::Sesame::Server.new RDF::URI("http://triples.101companies.org/openrdf-sesame")
    repository = server.repository("wiki101")
    title = title.sub(':', '-3A')
    res = repository.query(:object => RDF::URI.new("http://101companies.org/resource/#{title}"))
    res.each do |solution|
      if directions
          solution.object = solution.subject

          solution.subject = RDF::Literal("IN")
      end
      graph << patch_resource(solution, directions)
    end

    return graph
  end

  def patch_resource(resource, directions)
    unless directions
      resource.subject.path.sub!('resource', 'resources')
    end
    resource.object.path.sub!('resource', 'resources')

    unless directions
      resource.subject.path = patch_path(resource.subject.path)
    end
    resource.object.path = patch_path(resource.object.path, directions)
    resource
  end

  def patch_path(path, directions=false)
    item = path.split("/").last
    fixed_item = item

    if (fixed_item.split('-3A').length == 2)
      ns = fixed_item.split('-3A')[0]
      title = fixed_item.split('-3A')[1]
      if directions
        fixed_item = "#{ns}:#{title}"
      else
        fixed_item = "#{ns.downcase.pluralize}/#{title}"
      end
    else
      unless directions
        fixed_item = "concepts/#{fixed_item}"
      end
    end

    path.sub!(item, fixed_item)
    path
  end

  def get_rdf
    title = params[:id]
    graph = self.get_rdf_graph(title)
    respond_with graph.dump(:ntriples)
  end

  def get_json
    title = params[:id]
    directions = params[:directions]
    json = []
    rdf = self.get_rdf_graph(title, directions)
    rdf.each do |resource|
      p = "#{resource.predicate.scheme}://#{resource.predicate.host}#{resource.predicate.path}"
      o = resource.object.kind_of?(RDF::Literal) ? resource.object.object : "#{resource.object.scheme}://#{resource.object.host}#{resource.object.path}"
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
    # remove page from mediawiki
    @page.delete_from_mediawiki
    # remove the object itself
    @page.delete
    render :json => {:success => true}
  end

  def show

    # TODO: rework history
    @page.instance_eval { class << self; self end }.send(:attr_accessor, "history")

    if not History.where(:page => @page.full_title).exists?
      @page.history = History.create!(
        user: current_user,
        page:@page.full_title,
        version: 1
        )
    else
      @page.history = History.where(:page => @page.full_title).first
    end

    respond_to do |format|
      format.html { render :html => @page }
      format.json { render :json => {
        'id'        => @page.full_title,
        'content'   => @page.content,
        'sections'  => @page.sections,
        # TODO: to much entries about versions
        'history'   => @page.history.as_json(:include => {:user => { :except => [:role, :github_name]}}),
        'backlinks' => @page.backlinks
      }}

    end
  end

  def parse
    content = params[:content]
    parsed_page = WikiCloth::Parser.new(:data => content, :noedit => true)
    parsed_page.sections.first.auto_toc = false
    WikiCloth::Parser.context = @page.namespace

    # define links pointing to pages without content
    html = parsed_page.to_html
    all_page_uris = Page.get_all_pages_uris
    parsed_page.internal_links.each do |link|
      # nice link -> link-uri converted to readable words
      nice_link = Page.escape_wiki_url link
      # if in list of all pages doesn't exists link -> define css class missing-link
      class_attribute = all_page_uris.include?(nice_link) ?  '' : 'class="missing-link"'
      html.gsub!("<a href=\"#{link}\"", "<a " + class_attribute + " href=\"/wiki/#{nice_link}\"")
      html.gsub!("<a href=\"#{link.camelize(:lower)}\"", "<a " + class_attribute + " href=\"/wiki/#{nice_link}\"")
    end

    render :json => {:success => true, :html => html.html_safe}
  end

  def search
    @query_string = params[:q]
    if @query_string == ''
      redirect_to "/wiki/"
      flash[:notice] = 'Please write something, if you want to search something'
    else
      respond_with Page.gateway_and_login.search(@query_string)
    end
  end

  def summary
    begin
      render :json => {:sections => @page.sections, :internal_links => @page.internal_links}
    rescue
      @error_message="#{$!}"
      render :json => {:success => false, :error => @error_message}
    ensure
    end
  end

  # get all sections for a page
  def sections
    begin
      respond_with @page.sections
    rescue
      @error_message="#{$!}"
      render :json => {:success => false, :error => @error_message}
    end
  end

  # get all internal links for the page
  def internal_links
    begin
      respond_with @page.internal_links
    rescue
      @error_message="#{$!}"
      render :json => {:success => false, :error => @error_message}
    end
  end

  # TODO: does it actually work?
  def update_history(pagename)
    if History.where(:page => pagename).exists?
      history = History.where(:page => pagename).first
      history.update_attributes(
        version: history.version + 1,
        user: current_user
        )
    else
      History.create!(
        page: pagename,
        version: 1,
        user: current_user
        )
    end
  end

  def update
    sections = params[:sections]
    content = params[:content]
    new_full_title = Page.unescape_wiki_url params[:newTitle]
    @page.update_or_rename_page new_full_title, content, sections
    # TODO: has it worked at all?
    #update_history(title)
    render :json => {:success => true}
  end

  def rename
    begin
      new_full_title = Page.unescape_wiki_url params[:newTitle]
      sections = params[:sections]
      content = params[:content]
      @page.update_or_rename_page new_full_title, content, sections
      # TODO: has it worked at all?
      #update_history(new_full_title)
      render :json => {:success => true, :newtitle => new_full_title}
    rescue
      render :json => {:success => false, :error => 'Renamed failed'}, :status => 409
    end
  end

  def section
    respond_with ({:content => @page.section(params[:full_title])}).to_json
  end
end

