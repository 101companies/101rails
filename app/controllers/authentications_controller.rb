class AuthenticationsController < ApplicationController

  # Create an authentication when this is called from
  # the authentication provider callback.
  def create

    omniauth = request.env["omniauth.auth"]

    # try to catch user by uid
    user = User.where(:github_uid => omniauth['uid']).first

    # try to catch user by email
    if user.nil?
      user = User.where(:email => omniauth['info']['email']).first
    end

    # create new user
    if user.nil?
      user = User.new
    end

    user.email = omniauth['info']['email']
    user.name = omniauth['info']['name']
    user.github_name = omniauth['info']['nickname']
    user.github_avatar = omniauth['info']['image']
    user.github_token = omniauth['credentials']['token']
    user.github_uid = omniauth['uid']

    #begin
      user.save!
    #rescue
    #  flash[:warning] = "Sorry, but we couldn't read you data from github. Have you added public github email?"
    ##  go_to_previous_page and return
    #end

    session[:user_id] = user.id
    flash[:notice] = t :signed_in
    go_to_previous_page
  end

  # destroy user's authentication and return to the authentication page.
  def destroy
    session[:user_id] = nil
    flash[:notice] = t(:signed_out)
    go_to_previous_page
  end

end
