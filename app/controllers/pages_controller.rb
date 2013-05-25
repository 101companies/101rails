class PagesController < ApplicationController
  include PagesHelper
  require 'media_wiki'
  require 'rdf'
  require 'rdf/ntriples'
  require 'rdf/sesame'
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

  def get_rdf
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
     title = params[:id]
     @page = Page.new.create(title)

     v101 = RDF::Vocabulary.new("http://101companies.org/property/")
     uri = RDF::URI.new("http://101companies.org/resources/contribution/haskellStarter")
     graph = RDF::Graph.new << [uri, RDF::RDFS.title, "haskellStarter"]

     context   = RDF::URI.new("http://101companies.org")

     server = RDF::Sesame::Server.new RDF::URI("http://triples.101companies.org/openrdf-sesame")
     repository = server.repository("test")

     @page.semantic_links.each { |l| 
      subject = uri
      predicate = RDF::URI.new(self.semantic_properties[l.split('::')[0]])
      object =  l.split('::')[1]
      statement =  RDF::Statement.new(subject, predicate, object, :context => context) 
      graph << statement
      repository.delete statement
      repository.insert statement
    }

     respond_with graph.dump(:ntriples)
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

    #respond_with @page

    respond_to do |format|
      format.html { render :html => @page }
      format.json { render :json => {
        'id'        => @page._id,
        'idtitle'     => @page.title,
        'content' => @page.content,
        'title'     => @page.title,
        'sections'  => @page.sections,
        'history'   => @page.history,
        'backlinks' => @page.backlinks
        } }
    end
  end

  def parse
    content = params[:content]
    #we use the title to get the context of the page
    title = params[:pagetitle]
    wiki = WikiCloth::Parser.new(:data => content, :noedit => true)
    page = Page.new.create title
    WikiCloth::Parser.context = page.context
    html = wiki.to_html
    gw = MediaWiki::Gateway.new('http://mediawiki.101companies.org/api.php')
    all_pages = gw.list('')
    wiki.internal_links.each do |link|
      link = link.capitalize
      colon_split = link.split(':')
      lower_link = link.camelize(:lower)
      upper_split_link = link.capitalize
      lower_split_link = link.camelize(:lower)
      if colon_split.length > 1
        lower_split_link = colon_split[0] + ':' + colon_split[1].camelize(:lower)
        upper_split_link = colon_split[0] + ':' + colon_split[1].capitalize
      end
      class_attribute = ''
      unless all_pages.include?(upper_split_link)
        class_attribute = 'class="missing-link"'
      end
      html.gsub!("<a href=\"#{link}\"", "<a " + class_attribute + " href=\"/wiki/#{link}\"")
      html.gsub!("<a href=\"#{lower_link}\"", "<a " + class_attribute + " href=\"/wiki/#{link}\"")
      html.gsub!("<a href=\"#{upper_split_link}\"", "<a " + class_attribute + " href=\"/wiki/#{upper_split_link}\"")
      html.gsub!("<a href=\"#{lower_split_link}\"", "<a " + class_attribute + " href=\"/wiki/#{upper_split_link}\"")
    end
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

  def update
    # check if operation is not permitted
    if cannot? :update, Page.where(:title => params[:idtitle]).first
      render :json => {:success => false} and return
    end
    title = params[:idtitle]
    sections = params[:sections]
    page = Page.new.create(title)
    if params.has_key?('content') and params[:content] != ""
      page.change(params[:content])
    else
      content = ""
      sections.each { |s| content += s['content'] + "\n" }
      page.change(content)
    end

    if History.where(:page => title).exists?
      history = History.where(:page => title).first
      history.update_attributes(
        version: history.version + 1,
        user: current_user
      )
    else
      History.create!(
        page: title,
        version: 1,
        user: current_user
      )
    end
    if title != params[:title]
      rename
    else
      render :json => {:success => true}
    end
  end

  def rename
    if cannot? :update, Page.where(:title => params[:title]).first
      render :json => {:success => false} and return
    end
    begin
      from = params[:idtitle]
      to = params[:title]
      old_page = Page.new.create(from)
      new_page = Page.new.create(to)
      new_page.change(old_page.content)
      old_page.rewrite_backlinks(to)
      old_page.delete
      if History.where(:page => to).exists?
        history = History.where(:page => to).first
        history.update_attributes(
          version: history.version + 1,
          user: current_user
        )
      else
        History.create!(
          page: to,
          version: 1,
          user: current_user
        )
      end
      render :json => {:success => true, :newtitle => to}
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

