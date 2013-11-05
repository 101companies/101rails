class ContributionsController < ApplicationController

  def analyze
    begin
      @contribution_page = Page.find(params[:id])
      # write worker findings
      findings = []
      %w(languages concepts technologies features).map do |index|
        findings << { index => params[index] } if params[index]
      end
      @contribution_page.worker_findings = findings.to_json.to_s
      @contribution_page.save!
      Mailer.analyzed_contribution(@contribution_page).deliver
    end
    render nothing: true
  end

  def index
    # get all contribution, where already defined folder and url from github
    @contributions = Page.where(:contribution_folder.ne => "", :contribution_folder.exists => true,
                                :contribution_url.ne => "", :contribution_url.exists => true)
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
    # TODO: check contrb url+folder via validation
    @contribution_page.contribution_url = 'https://github.com/' + params[:contrb_repo_url].first
    # set folder to '/' if no folder given
    @contribution_page.contribution_folder = params[:contrb_folder].empty?  ? '/' : params[:contrb_folder]
    unless params[:contrb_description].empty?
      @contribution_page.raw_content = "== Headline ==\n\n" + params[:contrb_description]
    else
      @contribution_page.raw_content = "== Headline ==\n\n" + PageModule.default_contribution_text
    end
    @contribution_page.contributor = current_user
    # send request to matching service
    unless @contribution_page.analyze_request
      flash[:error] = "You have created new contribution. Request on analyze service wasn't successful. Please retry it later"
    else
      flash[:notice] = "You have created new contribution. You will retrieve an email, when it will be analyzed."
    end
    @contribution_page.inject_namespace_triple
    @contribution_page.save
    Mailer.created_contribution(@contribution_page).deliver
    redirect_to  "/wiki/#{@contribution_page.nice_wiki_url}"
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

end
