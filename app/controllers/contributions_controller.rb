class ContributionsController < ApplicationController

  def index
    # get all contribution, where already defined folder and url from github
    @contributions = Page.where(:contribution_folder.ne => "", :contribution_folder.exists => true,
                                :contribution_url.ne => "", :contribution_url.exists => true)
  end

  def get_repo_dirs
    render :json => current_user.get_repo_dirs_recursive(params[:repo])
  end

  def create
    #  not logged in -> go out!
    if !current_user
      flash[:notices] = 'You need to be logged in, if you want to make contribution'
      go_to_previous_page
      return
    end
    # check, if title given
    if params[:contrb_title].nil? || params[:contrb_title].empty?
      flash[:error] = 'You need to define title for contribution'
      redirect_to action: 'new' and return
    end
    @contribution_page = Page.new
    full_title = PageModule.unescape_wiki_url "Contribution:#{params[:contrb_title]}"
    namespace_and_title = PageModule.retrieve_namespace_and_title full_title
    @contribution_page.title = namespace_and_title["title"]
    @contribution_page.namespace = namespace_and_title["namespace"]
    # page already exists
    unless PageModule.find_by_full_title(@contribution_page.full_title).nil?
      flash[:error] = 'Sorry, but page with this name is already taken'
      redirect_to action: 'new' and return
    end
    # define github url to repo
    @repo_link = RepoLink.new
    if params[:contrb_repo_url].nil? || params[:contrb_repo_url].empty?
      flash[:error] = 'You need to select a repo to contribute'
      redirect_to action: 'new' and return
    end
    @repo_link.repo = params[:contrb_repo_url]
    # set folder to '/' if no folder given
    @repo_link.folder = params[:contrb_folder].empty?  ? '/' : params[:contrb_folder]
    unless params[:contrb_description].empty?
      @contribution_page.raw_content = "== Headline ==\n\n" + params[:contrb_description]
    else
      @contribution_page.raw_content = "== Headline ==\n\n" + default_contribution_text
    end
    if current_user.role == 'admin'
      @contribution_page.verified = true
    else
      @contribution_page.verified = false
    end
    @contribution_page.user_ids << current_user.id
    @contribution_page.save
    @repo_link.user = current_user.github_name
    @repo_link.namespace
    @repo_link.page = @contribution_page
    @repo_link.save
    # @contribution_page.repo_link = @repo_link
    
    Mailer.user_created_contribution(@contribution_page, current_user.email).deliver_now
    Mailer.admin_created_contribution(@contribution_page).deliver_now
    redirect_to  "/wiki/#{@contribution_page.url}"
  end

  def new
    # if not logged in -> show intro and go out
    if !current_user
      render 'contributions/login_intro' and return
    end

    @user_github_repos = nil

    begin
      # retrieve all repos of user
      @user_github_repos = (Octokit.repos current_user.github_name, {:type => 'all'}).map do |repo|
        # retrieve 'username/reponame' from url
        repo.full_name
      end
    rescue
      flash[:warning] = "We couldn't retrieve you github information, please try in 5 minutes. " +
          "If you haven't added github public email - please do it!"
      redirect_to '/contribute'
    end

  end

  def default_contribution_text
    "You have created new contribution using [https://github.com Github]. " +
    "Source code for this contribution you can find here. " +
    "Please replace this text with something more meaningful."
  end
end
