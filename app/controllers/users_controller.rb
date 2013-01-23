class UsersController < ApplicationController
  before_filter :authenticate_user!

  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
  end

  # Visitors -- everyone
  #	Editor -- create/delete/edit pages
  # Owner -- owns a page
  # Admins -- all rights

  def allowed?
  	@action = params[:action]
  	@page = params[:page]

  	#TODO: check if user is allowed

  	return false
  end

end
