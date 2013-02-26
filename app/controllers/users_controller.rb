class UsersController < ApplicationController
  before_filter :authenticate_user!

  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
  end

  # ROLES:
  # Visitors -- everyone
  #	Editor -- create/delete/edit pages
  # Owner -- owns a page
  # Admins -- all rights

  # ACTIONS:
  # Edit
  # View
  def allowed?
  	@action = params[:action]
  	@page = params[:page]

    if current_user.email == "dotnetby@gmail.com"
      return true
    else 
      return false
    end  
  end
end
