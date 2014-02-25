class AuthenticationsController < ApplicationController

  # Create an authentication when this is called from
  # the authentication provider callback.
  def create
    omniauth = request.env["omniauth.auth"]
    # try to catch user by uid
    user = User.where(:github_uid => omniauth['uid']).first
    # try to catch user by email
    user = User.where(:email => omniauth['info']['email']).first if user.nil?
    # create new user
    user = User.new if user.nil?
    # fill user info from omniauth
    user.populate_data omniauth
    if user.save
      session[:user_id] = user.id
      flash[:notice] = t :signed_in
    else
      flash[:warning] = "Sorry, but we couldn't read you data from GitHub. Have you added public GitHub email?"
    end
    go_to_previous_page
  end

  def failure
    flash[:warning] = "Sorry, but login wasn't successful"
    go_to_previous_page
  end

  # destroy user's authentication and return to the authentication page.
  def destroy
    session[:user_id] = nil
    flash[:notice] = t(:signed_out)
    go_to_previous_page
  end

end
