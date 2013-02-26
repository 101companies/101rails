class GithubProjectController < ApplicationController

  def index
  end

  def new

    # wait for three responses

    # save to db
    contribution = GithubProject.new
    contribution.url = params[:project_url]
    contribution.save

    redirect_to :index

  end

end
