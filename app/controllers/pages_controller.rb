class PagesController < ApplicationController

  include RdfModule

  # for calling from view
  helper_method :get_rdf_json

  respond_to :json, :html

  # order of next two lines is very important!
  # before_filter need to be before load_and_authorize_resource
  before_filter :get_the_page, :except => [:create_new_page_confirmation, :create_new_page]
  # methods, that need to check permissions
  load_and_authorize_resource :only => [:delete, :rename, :update, :apply_findings, :update_repo]

  def get_the_page
    # if no title -> set default wiki startpage '@project'
    full_title = params[:id].nil? ? '@project' : params[:id]
    @page = PageModule.find_by_full_title full_title
    # if page doesn't exist, but it's user page -> create page and redirect
    if @page.nil? && !current_user.nil? && full_title.downcase=="Contributor:#{current_user.github_name}".downcase
      PageModule.create_page_by_full_title(full_title)
      redirect_to "/wiki/#{full_title}" and return
    end
    # page not found and user can create page -> create new page by full_title
    if @page.nil? && (can? :create, Page.new)
      redirect_to create_new_page_confirmation_page_path(full_title)
      return
    end
    # if no page created/found
    if !@page
      return respond_to do |format|
        format.html do
          flash[:error] = "Page wasn't not found. Redirected to main wiki page"
          go_to_homepage
        end
        format.json { render :json => {success: false}, :status => 404 }
      end
    end

    # get rdf
    @rdf = get_rdf_json(@page.full_title, true)

    @rdf = @rdf.sort do |x,y|
      if x[:predicate] == y[:predicate]
        x[:node] <=> y[:node]
      else
        x[:predicate] <=> y[:predicate]
      end
    end

    @resources = @rdf.select do |triple|
      triple[:node].start_with? 'http://'
    end

    @rdf = @rdf.select do |triple|
      not triple[:node].start_with? 'http://'
    end

    url = "http://worker.101companies.org/services/termResources/#{@page.full_title}.json"
    url = URI.encode url
    url = URI(url)
    response = Net::HTTP.get url

    @books = JSON::parse response
  end

  def create_new_page
    if (cannot? :manage, Page.new)
      flash[:error] = "You don't have enough rights for creating the page."
      go_to_homepage and return
    end
    full_title = params[:id]
    page = PageModule.create_page_by_full_title full_title
    if page
      redirect_to "/wiki/#{full_title}" and return
    else
      flash[:error] = "You cannot create new page #{full_title}"
      redirect_to "/wiki/@project" and return
    end
  end

  def create_new_page_confirmation
    @full_title = params[:id]
  end

  def update_repo
    repo_link = params[:repo_link]
    # if no link to repo -> create it
    if @page.repo_link.nil?
      @page.repo_link = RepoLink.new
    end
    # fill props
    @page.repo_link.folder = repo_link[:folder]
    @page.repo_link.user = repo_link[:user_repo].split('/').first
    @page.repo_link.repo = repo_link[:user_repo].split('/').last
    # assign page
    @page.repo_link.page = @page
    # save page and link
    (@page.save and @page.repo_link.save) ?
      flash[:success]="Updated linked repo" : flash[:error] = "Failed to update linked repo"
    redirect_to  "/wiki/#{@page.url}"
  end

  def edit
    @pages = Page.all.map &:full_title

    url = "http://worker.101companies.org/data/dumps/wiki-predicates.json"
    url = URI.encode url
    url = URI(url)
    @predicates = JSON::parse(Net::HTTP.get url)
  end

  def destroy
    authorize! :destroy, @page

    result = @page.delete
    # generate flash_message if deleting was successful
    if result
      page_change = PageChange.new :title => @page.title,
                     :namespace => @page.namespace,
                     :raw_content => @page.raw_content,
                     :page => @page,
                     :user => current_user
      page_change.save
      flash[:notice] = 'Page ' + @page.full_title + ' was deleted'
    end
    render json: { success: result }
  end

  def show
    @current_user_can_change_page = (!current_user.nil?) and (can? :manage, @page)
    respond_to do |format|
      format.html {
        # if need redirect? -> wiki url conventions -> do a redirect
        if (@page.namespace == 'Contributor')
          user = User.where(:github_name => @page.title).first
          if !user.nil?
            @pages_edits = user.page_changes
            @contributions = Page.where(:used_links => /developedBy::Contributor:#{user.github_name}/i)
          end
        end
        good_link = @page.url
        if good_link != params[:id]
          redirect_to '/wiki/'+ good_link and return
        end
      }
    end
  end

  def parse
    html = @page.parse params[:content]
    render :json => {:success => true, :html => html}
  end

  def search
    @query_string = params[:q]
    if @query_string == ''
      flash[:notice] = 'Please write something, if you want to search something'
      go_to_homepage
    else
      @search_results = PageModule.search @query_string
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

  def rename
    new_name = PageModule.unescape_wiki_url params[:newTitle]
    result = @page.update_or_rename(new_name, @page.raw_content, [], current_user)
    render :json => {
      success: result,
      newTitle: @page.url
    }
  end

  def update
    sections = []
    content = params[:content]
    result = @page.update_or_rename(@page.full_title, content, sections, current_user)
    update_used_predicates(@page)
    render :json => {
      :success => result,
      :newTitle => @page.url
    }
  end

  def section
    respond_with ({:content => @page.section(params[:full_title])}).to_json
  end

end
