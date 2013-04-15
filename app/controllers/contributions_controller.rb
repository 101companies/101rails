class ContributionsController < ApplicationController

  load_and_authorize_resource :only => [:create, :new]

  def show
    @contribution = Contribution.find(params[:id])
  end

  def index

    # last 10 contributions
    @contributions = Contribution.desc(:created_at).limit(10)

  end

  def create

    @contribution = Contribution.new
    @contribution.url = params[:repo_url]
    @contribution.user = current_user
    @contribution.save
    redirect_to  action: "index" #, :notice => 'New contribution added'

  end

  def new

  end

end
