class PagesController < ApplicationController
  include PagesHelper
  require 'media_wiki'
  before_filter :check_uri
  respond_to :json, :html

  def check_uri
    title = params[:title]
    if title == nil
      return
    end

    # save params title
    title_wiki = title

    # convert to wiki-uri format, upcase for first char
    title = MediaWiki::send :upcase_first_char, (MediaWiki::wiki_to_uri title)

    # redirect, if title was changed
    # Important: during the redirect will be automatically unescaped url
    # so we avoid endless loop for 'escaping/unenscaping' url during redirect_to by previous unescaping for title
    if title_wiki != CGI.unescape(title)
      redirect_to "/wiki/#{title}"
    end
    begin
      gw = MediaWiki::Gateway.new('http://mediawiki.101companies.org/api.php')
      if gw.redirect?(title)
        @redirect_page = Page.new.create title
        redirect_to "/wiki/" + @redirect_page.redirect_target
      end
    rescue MediaWiki::APIError
    end
  end

  def semantic_properties
   {'dependsOn'  => 'http://101companies.org/property/dependsOn',
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
     'relatesTo'   => 'http://101companies.org/property/relatesTo' }
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
    @ctx = get_context_for(title)

    if @ctx[:title].starts_with?('http')
      @ctx[:title]
    else
      RDF::URI.new("http://101companies.org/resources/#{@ctx[:ns].pluralize}/#{@ctx[:title]}")
    end
  end

  def all
    respond_with all_pages
  end

  def get_rdf_graph(title, directions=false)
     #   public static DEPENDS_ON = 'http://101companies.org/property/dependsOn'
     #   public static IDENTIFIES = 'http://101companies.org/property/identifies'
     #   public static LINKS_TO = 'http://101companies.org/property/linksTo'
     #   public static CITES = 'http://101companies.org/property/cites'
     #   public static USES = 'http://101companies.org/property/uses'
     #   public static IMPLEMENTS = 'http://101companies.org/property/implements'
     #   public static INSTANCE_OF = 'http://101companies.org/property/instanceOf'
     #   public static IS_A = 'http://101companies.org/property/isA'
     #   public static DEVELOPED_BY = 'http://101companies.org/property/developedBy'
     #   public static REVIEWED_BY = 'http://101companies.org/property/reviewedBy'
     #   public static RELATES_TO = 'http://101companies.org/property/relatesTo'
     #   public static LABEL = 'http://www.w3.org/2000/01/rdf-schema#label'
     #   public static PAGE = 'http://semantic-mediawiki.org/swivt/1.0#page'
     #   public static TYPE = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type'
     title.gsub!(' ', '_')
     puts title
     @page = Page.new.create(title)

     uri = self.page_to_resource title
     v101 = RDF::Vocabulary.new("http://101companies.org/property/")
     graph = RDF::Graph.new #<< [uri, RDF::RDFS.title, title]

     context   = RDF::URI.new("http://101companies.org")

     server = RDF::Sesame::Server.new RDF::URI("http://triples.101companies.org/openrdf-sesame")
     repository = server.repository("test")

     @page.semantic_links.each { |l|
      if directions
        subject = RDF::Literal.new("OUT")
      else
        subject = uri
      end
      predicate = RDF::URI.new(self.semantic_properties[l.split('::')[0]])
      object =  l.split('::')[1]
      statement =  RDF::Statement.new(subject, predicate, page_to_resource(object), :context => context)
      graph << statement
      repository.delete statement
      repository.insert statement
    }

    server = RDF::Sesame::Server.new RDF::URI("http://triples.101companies.org/openrdf-sesame")
    repository = server.repository("wiki101")
    title = title.sub(':', '-3A')
    res = repository.query(:object => RDF::URI.new("http://101companies.org/resource/#{title}"))
    res.each do |solution|
      if directions
          solution.object = solution.subject
          solution.subject = RDF::Literal("IN")
      end
      graph << patch_resource(solution, !directions)
    end

    return graph
  end

  def patch_resource(resource, both=true)
    if both
      resource.subject.path.sub!('resource', 'resources')
    end
    resource.object.path.sub!('resource', 'resources')

    if both
      resource.subject.path = patch_path(resource.subject.path)
    end
    resource.object.path = patch_path(resource.object.path)
    resource
  end

  def patch_path(path)
    item = path.split("/").last
    fixed_item = item

    if (fixed_item.split('-3A').length == 2)
      ns = fixed_item.split('-3A')[0]
      title = fixed_item.split('-3A')[1]
      fixed_item = "#{ns.downcase.pluralize}/#{title}"
    else
      fixed_item = "concepts/#{fixed_item}"
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
          :node => o
        })
      else
        s = "#{resource.subject.scheme}://#{resource.subject.host}#{resource.subject.path}"
        json.append [s,p,o]
      end
    end
    respond_with json
  end

  def delete
    logger.debug(current_user.role)
    if current_user and (current_user.role=="admin")
      title = params[:id]
      page = Page.new.create(title)
      page.delete
    end
    render :json => {:success => true}
  end

  def show
    @title = params[:title]
    if @title == nil
      if params[:id].nil?
        @title = "@project"
      else
        @title = params[:id]
      end
    end
    @page = Page.new.create @title
    @page.instance_eval { class << self; self end }.send(:attr_accessor, "history")
    if not History.where(:page => @title).exists?
      @page.history = History.create!(
        user: current_user,
        page: @title,
        version: 1
        )
    else
     @page.history = History.where(:page => @title).first
    end

    respond_to do |format|
      format.html { render :html => @page }
      format.json { render :json => {
        'id'        => @page._id,
        'idtitle'     => @page.title,
        'content' => @page.content,
        'title'     => @page.title,
        'sections'  => @page.sections,
        'history'   => @page.history.as_json(:include => {:user => { :except => [:role, :github_name]}}),
        'backlinks' => @page.backlinks
        }
      }
      end
  end

  def parse
    content = params[:content]
    #we use the title to get the context of the page
    title = params[:pagetitle]
    parsed_page = WikiCloth::Parser.new(:data => content, :noedit => true)
    parsed_page.sections.first.auto_toc = false
    page = Page.new.create title
    WikiCloth::Parser.context = page.context
    html = to_wiki_links(parsed_page)
    render :json => {:success => true, :html => html.html_safe}
  end

  def search
    @query_string = params[:q]
    if @query_string == ''
      redirect_to "/wiki/"
    else
      gw = MediaWiki::Gateway.new('http://mediawiki.101companies.org/api.php')
      gw.login(ENV['WIKIUSER'], ENV['WIKIPASSWORD'])
      @search_results = gw.search(@query_string)
      respond_with @search_results
    end
  end

  def summary
    begin
      GC.disable
      title = params[:id]
      page = Page.new.create title
      render :json => {:sections => page.sections, :internal_links => page.internal_links}
    rescue
      @error_message="#{$!}"
      render :json => {:success => false, :error => @error_message}
    ensure
      GC.enable
      GC.start
    end
  end

  # get all sections for a page
  def sections
    begin
      title = params[:id]
      page = Page.new.create(title)
      sections = page.sections
      respond_with sections
    rescue
      @error_message="#{$!}"
      render :json => {:success => false, :error => @error_message}
    end
  end

  # get all internal links for the page
  def internal_links
    begin
      title = params[:id]
      page = Page.new.create(title)
      respond_with page.internal_links
    rescue
      @error_message="#{$!}"
      render :json => {:success => false, :error => @error_message}
    end
  end

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
    # check if operation is not permitted
    if cannot? :update, Page.where(:title => params[:idtitle]).first
      render :json => {:success => false} and return
    end
    title = params[:idtitle]
    sections = params[:sections]
    content = params[:content]
    if content == ""
      sections.each { |s| content += s['content'] + "\n" }
    end
    page = Page.new.create(title)
    page.change(content)
    update_history(title)
    if title != params[:title]
      rename
    else
      render :json => {:success => true}
    end
  end

  def rename
    begin
      new_title = params[:title]
      page = Page.new.create(params[:idtitle])
      page.rename(new_title)
      update_history(new_title)
      render :json => {:success => true, :newtitle => new_title}
    rescue MediaWiki::APIError
      @error_message="#{$!.info}"
      render :json => {:success => false, :error => @error_message}, :status => 409
    end
  end

  def section
    title = params[:id]
    p = Page.new.create(title)
    section = {'content' => p.section(params[:title])}
    respond_with section.to_json
  end
end

