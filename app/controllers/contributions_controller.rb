class ContributionsController < ApplicationController

  before_filter :authenticate_user!, :only => [:new, :create]

  def show
    @contribution = Contribution.find(params[:id])
  end

  def index

    # last 10 contributions
    @contributions = Contribution.desc(:created_at).limit(10)

  end

  def create

    @contribution = Contribution.new
    @contribution.url = params[:contrb_repo_url].first
    @contribution.title = params[:contrb_title]
    @contribution.description = params[:contrb_description]
    @contribution.user = current_user
    @contribution.save
    #TODO: send email to gatekeeper and contributor
    redirect_to  action: "index"
    flash[:notice] = "You have created new contribution. Please wait until it will be approved by gatekeepers."
  end

  def new

    # retrieve github login
    begin
      if current_user.github_name == ''
        agent = Mechanize.new
        resp = agent.get "https://api.github.com/legacy/user/email/#{current_user.email}"
        resp = JSON.parse resp.body
        current_user.github_name = resp["user"]["login"]
        current_user.save
      end
    rescue
      flash[:warning] = "We couldn't retrieve you github repos, please log out and log in again"
    end

    # retrieve repos of user
    temp_repos = Github.repos.list user: current_user.github_name

    @user_github_repos = ''

    # create list for select tag
    temp_repos.each do |repo|
      @user_github_repos = @user_github_repos + '<option>' + repo.clone_url + '</option>'
    end

  end

end
