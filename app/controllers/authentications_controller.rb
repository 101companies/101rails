# AuthenticationController will handle OmniAuth-providers for an existing
# user. Since authentications are handled by the omni-gem all we need is
# index, create, and delete. There is no need to edit/update or show a single
# authentication.
class AuthenticationsController < ApplicationController

  # Create an authentication when this is called from
  # the authentication provider callback.
  def create
    omniauth = request.env["omniauth.auth"]
    authentication = Authentication.where(:provider => omniauth['provider'], :uid => omniauth['uid']).first
    if authentication
      # Just sign in an existing user with omniauth
      flash[:notice] = t :signed_in
      # if used github -> integrate with app
      integrate_github_info authentication.user, omniauth
      session[:user_id] = authentication.user.id
      go_to_previous_page
    elsif current_user
      # Add authentication to signed in user
      current_user.authentications.create!(:provider => omniauth['provider'], :uid => omniauth['uid'])
      # if used github -> integrate with app
      integrate_github_info current_user, omniauth
      flash[:notice] = t :authentication_successful
      go_to_previous_page
    elsif user = create_new_omniauth_user(omniauth)
      # Create a new User through omniauth
      flash[:notice] = t :signed_in
      integrate_github_info user, omniauth
      session[:user_id] = authentication.user.id
      go_to_previous_page
    end
  end

  def integrate_github_info(user, omniauth)
    if omniauth['provider'] == 'github'
      # get github nickname, token and avatar image
      user.github_name = omniauth['info']['nickname']
      user.github_avatar = omniauth['info']['image']
      user.github_token = omniauth['credentials']['token']
      user.save
    end
  end

  # destroy user's authentication and return to the authentication page.
  def destroy
    session[:user_id] = nil
    flash[:notice] = t(:signed_out)
    go_to_previous_page
  end

  def failure
    flash[:notice] = "Sorry, but login wasn't successful. Please try a bit later again"
    go_to_previous_page
  end

  private

  # Create a new user and assign an authentication to it.
  def create_new_omniauth_user(omniauth)
    user = User.new
    user.apply_omniauth(omniauth)
    if user.save
      user
    else
      nil
    end
  end
end
