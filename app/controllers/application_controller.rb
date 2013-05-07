class ApplicationController < ActionController::Base
  protect_from_forgery

  # return to previous page after sign in
  def after_sign_in_path_for(resource)
    request.env['omniauth.origin'] || stored_location_for(resource) || root_path
  end

  # handle non authorized 500 status from cancan
  rescue_from CanCan::AccessDenied do |exception|
    flash[:notice] = "Sorry, you aren't permitted to execute your last action =/"
    if request.referer
      redirect_to(:back)
    else
      redirect_to('/wiki')
    end
  end

  def current_git_state
    last_commit = %x( git rev-parse HEAD).to_s
    render :text => "<a href='https://github.com/101companies/101rails/commit/#{last_commit}'>#{last_commit}</a>"
  end

end
