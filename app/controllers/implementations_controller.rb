class ImplementationsController < ApplicationController
  # GET /implementations/1
  # GET /implementations/1.json
  def show
  	@title = params[:title].sub(':', '')
  end
end
