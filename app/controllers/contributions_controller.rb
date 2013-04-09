class ContributionsController < ApplicationController

  def index
  end

  def new

    # wait for three responses

    # save to db
    contribution = Contribution.new
    contribution.url = params[:project_url]
    contribution.user = current_user
    contribution.save

    redirect_to :index

  end

end
