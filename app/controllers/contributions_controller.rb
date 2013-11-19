class ContributionsController < ApplicationController

  def analyze
    begin
      # exception for id check
      begin
        @request = MatchingServiceRequest.find(params[:id])
      rescue
        Rails.logger "Strange request from matching service with id #{params[:id]}"
        @request = nil
      end
      (render nothing: true and return) if @request.nil?

      findings = []
      %w(languages concepts technologies features).map do |index|
        findings << { index => params[index] } if params[index]
      end

      @request.page.worker_findings = findings.to_json.to_s
      @request.page.save!

      @request.worker_findings = findings.to_json.to_s
      @request.page.worker_findings = findings.to_json.to_s
      @request.analysed = true
      @request.save!

      Mailer.analyzed_contribution(@request).deliver
    end
    render nothing: true
  end

  def get_repo_dirs
    render :json => current_user.get_repo_dirs_recursive(params[:repo])
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

    @page = Page.new
    full_title = PageModule.unescape_wiki_url "Contribution:#{params[:contrb_title]}"
    namespace_and_title = PageModule.retrieve_namespace_and_title full_title
    @page.title = namespace_and_title["title"]
    @page.namespace = namespace_and_title["namespace"]

    # page already exists
    unless PageModule.find_by_full_title(@page.full_title).nil?
      flash[:error] = 'Sorry, but page with this name is already taken'
      redirect_to action: 'new' and return
    end

    # define github url to repo
    @page.contribution_url = params[:contrb_repo_url].first

    # set folder to '/' if no folder given
    @page.contribution_folder = params[:contrb_folder].empty?  ? '/' : params[:contrb_folder]

    unless params[:contrb_description].empty?
      @page.raw_content = "== Headline ==\n\n" + params[:contrb_description]
    else
      @page.raw_content = "== Headline ==\n\n" + PageModule.default_contribution_text(@page.contribution_url)
    end

    request = MatchingServiceRequest.new
    request.user = current_user
    request.page = @page
    request.save

    request.send_request

    # send request to matching service
    unless request.sent
      flash[:error] = "You have created new contribution. Request on analyze service wasn't successful. Please retry it later"
    else
      flash[:notice] = "You have created new contribution. You will retrieve an email, when it will be analyzed."
    end

    @page.inject_namespace_triple
    @page.inject_triple "developedBy::#{current_user.name}"
    @page.save
    Mailer.created_contribution(request).deliver
    redirect_to  "/wiki/#{@page.url}"
  end

  def new
    # if not logged in -> show intro and go out
    if !current_user
      render 'contributions/login_intro' and return
    end

    @user_github_repos = nil

    begin
      @user_github_repos = current_user.get_repos
    rescue
      flash[:warning] = "We couldn't retrieve you github information, please try in 5 minutes. " +
          "If you haven't added github public email - please do it!"
      redirect_to '/contribute'
    end

  end

end
