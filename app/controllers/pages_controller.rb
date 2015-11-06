class PagesController < ApplicationController

  include RdfModule

  # for calling from view
  helper_method :get_rdf_json

  respond_to :json, :html

  # before_filter need to be before load_and_authorize_resource
  # methods, that need to check permissions
  before_filter :get_the_page, only: [:edit, :rename, :update, :update_repo, :destroy, :verify]
  authorize_resource only: [:delete, :rename, :update, :apply_findings, :update_repo, :verify]

  def get_the_page
    full_title = params[:id]

    @page = get_page.execute!(full_title).page
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
        format.json {
          return render json: {success: false}, status: 404
        }
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
      (triple[:node].start_with?('http://') || triple[:node].starts_with?('https://'))
    end

    @rdf = @rdf.select do |triple|
      !(triple[:node].start_with?('http://') || triple[:node].start_with?('https://'))
    end

    begin
      url = "http://worker.101companies.org/services/termResources/#{@page.full_title}.json"
      url = URI.encode url
      url = URI(url)
      response = Net::HTTP.get url

      @books = JSON::parse response
    rescue SocketError
      Rails.logger.warn("book retrieval failed for #{@page.full_title}")
      @books = []
    end
  end

  def create_new_page
    if (cannot? :create, Page.new)
      flash[:error] = "You don't have enough rights for creating the page."
      go_to_homepage and return
    end

    full_title = params[:id]
    page = PageModule.create_page_by_full_title full_title
    if page
      redirect_to "/wiki/#{full_title}" and return
    else
      flash[:error] = "You cannot create new page #{full_title}"
      redirect_to "/wiki/101project" and return
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
  
  def verify
    @page.verified = true
    @page.save
    redirect_to "/wiki/#{@page.url}"
  end
  
  def edit
    @pages = Page.all.map &:full_title

    begin
      url = "http://worker.101companies.org/data/dumps/wiki-predicates.json"
      url = URI.encode url
      url = URI(url)
      @predicates = JSON::parse(Net::HTTP.get url)
    rescue SocketError
      @predicates = {}
      Rails.logger.warn("Predicates retrieval failed")
    end
  end

  def destroy
    authorize! :destroy, @page

    result = @page.delete
    # generate flash_message if deleting was successful
    if result
      page_change = PageChange.new title: @page.title,
                     namespace: @page.namespace,
                     raw_content: @page.raw_content,
                     page: @page,
                     user: current_user
      page_change.save
      flash[:notice] = 'Page ' + @page.full_title + ' was deleted'
    end
    render json: { success: result }
  end

  def show
    begin
      result = show_page.execute!(params[:id], current_user)

      # set instance variables
      @page = result.page
      @books = result.books
      @rdf = result.rdf
      @resources = result.resources
      @contributions = result.contributions
    rescue ShowPage::ContributorPageCreated => e
      redirect_to "/wiki/#{e.message}"
    rescue ShowPage::PageNotFound => e
      flash[:error] = "Page wasn't not found. Redirected to main wiki page"
      go_to_homepage
    rescue ShowPage::BadLink => e
      redirect_to e.message
    rescue ShowPage::PageNotFoundButCreating => e
      redirect_to create_new_page_confirmation_page_path(e.message)
    end
    if (!@page.nil? && @page.verified == false)
      flash[:error] = "This page has not been verified yet!"
    end
  end

  def search
    @query_string = params[:q] || ''
    if @query_string == ''
      flash[:notice] = 'Please write something, if you want to search something'
      go_to_homepage
    else
      @search_results = PageModule.search @query_string
      respond_with @search_results
    end
  end

  def rename
    new_name = PageModule.unescape_wiki_url params[:newTitle]
    result = @page.update_or_rename(new_name, @page.raw_content, [], current_user)
    render json: {
      success: result,
      newTitle: @page.url
    }
  end

  def update
    sections = []
    content = params[:content]
    result = @page.update_or_rename(@page.full_title, content, sections, current_user)
    update_used_predicates(@page)
    render json: {
      success: result,
      newTitle: @page.url
    }
  end

  private

  def get_page
    @get_page ||= GetPage.new
  end

  def show_page
    @show_page ||= ShowPage.new(logger, Rails.configuration.books_adapter)
  end

end
