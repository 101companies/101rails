class ApplicationController < ActionController::Base
  protect_from_forgery

  # return to previous page after sign in
  def after_sign_in_path_for(resource)
    request.env['omniauth.origin'] || stored_location_for(resource) || root_path
  end

  def go_to_homepage
    redirect_to('/wiki/@project')
  end

  # handle non authorized 500 status from cancan
  rescue_from CanCan::AccessDenied do |exception|
    flash[:notice] = "Sorry, you aren't permitted to execute your last action =/"
    if request.referer
      redirect_to(:back)
    else
      go_to_homepage
    end
  end

  # profiling with ruby-prof
  # add ?profile=true or &profile=true to url to profile it
  around_filter :profile if Rails.env == 'development'
  def profile
    if params[:profile] && result = RubyProf.profile { yield }
      out = StringIO.new
      RubyProf::FlatPrinter.new(result).print out, :min_percent => 0
      self.response_body = out.string
    else
      yield
    end
  end

end
