class ApplicationController < ActionController::Base
  protect_from_forgery

  # return to previous page after sign in
  def after_sign_in_path_for(resource)
    request.env['omniauth.origin'] || stored_location_for(resource) || root_path
  end

  # handle non authorized 500 status from cancan
  rescue_from CanCan::AccessDenied do |exception|
    flash[:notice] = "Sorry, you aren't permitted to do it =/"
    redirect_to root_url
  end

end
