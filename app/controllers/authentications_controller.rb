# AuthenticationController will handle OmniAuth-providers for an existing
# user. Since authentications are handled by the omni-gem all we need is
# index, create, and delete. There is no need to edit/update or show a single
# authentication.
class AuthenticationsController < ApplicationController

  # Load user's authentications (Twitter, Facebook, ....)
  def index
    @authentications = current_user.authentications if current_user
  end

  # Create an authentication when this is called from
  # the authentication provider callback.
  def create
    omniauth = request.env["omniauth.auth"]
    logger.info omniauth.inspect
    authentication = Authentication.where(:provider => omniauth['provider'], :uid => omniauth['uid']).first
    if authentication
      # Just sign in an existing user with omniauth
      flash[:notice] = I18n.t 'devise.sessions.signed_in'
      # if used github -> integrate with app
      integrate_github_info authentication.user, omniauth
      sign_in_and_redirect(:user, authentication.user)
    elsif current_user
      # Add authentication to signed in user
      current_user.authentications.create!(:provider => omniauth['provider'], :uid => omniauth['uid'])
      # if used github -> integrate with app
      integrate_github_info current_user, omniauth
      flash[:notice] = t(:authentication_successful)
      redirect_to authentications_url
    elsif user = create_new_omniauth_user(omniauth)
      # Create a new User through omniauth
      flash[:notice] = I18n.t 'devise.sessions.signed_in'
      integrate_github_info user, omniauth
      sign_in_and_redirect(:user, user)
    else
      # New user data not valid, try again
      session[:omniauth] = omniauth.except('extra')
      flash[:notice] = 'Please specify a public email address on your github profile before sign up'
      redirect_to new_user_registration_url
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
    @authentication = current_user.authentications.find(params[:id])
    @authentication.destroy
    flash[:notice] = t(:successfully_destroyed_authentication)
    go_to_homepage
  end

  # try again when authentication failed.
  def auth_failure
    redirect_to '/users/sign_in', :alert => params[:message]
  end

  private

  def create_authentication(omniauth)
    Authentication.where(:provider => omniauth['provider'], :uid => omniauth['uid']).first
  end

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
