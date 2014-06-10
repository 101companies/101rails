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
    # create new user if not found
    if user.nil?
      user = User.new
    end
    # fill user info from omniauth
    failed_to_populate_data = false
    begin
      user.populate_data omniauth
    rescue
      failed_to_populate_data = true
    end
    if !failed_to_populate_data and user.save
      session[:user_id] = user.id
      create_user_page_and_set_permissions(user)
      flash[:notice] = t :signed_in
    else
      flash[:error] = "Failed to login. Have you added name and public email into GitHub account?"
    end
    go_to_previous_page
  end

  def create_user_page_and_set_permissions(user)
    user_page = Page.where(:title => user.github_name, :namespace => 'Contributor').first
    if user_page.nil?
      user_page = Page.new :title => user.github_name,
                           :namespace => 'Contributor'
      user_page.save
    end
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
