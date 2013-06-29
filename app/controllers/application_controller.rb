class ApplicationController < ActionController::Base
  protect_from_forgery

  # return to previous page after sign in
  def after_sign_in_path_for(resource)
    request.env['omniauth.origin'] || stored_location_for(resource) || root_path
  end

  def go_to_homepage
    redirect_to '/wiki/@project'
  end

  def sitemap
    # generate sitemap for better google indexing
    text = '<?xml version="1.0" encoding="UTF-8"?>
      <urlset
        xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9
        http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd">'
    Page.all.each do |page|
      text = text + '<url><loc>http://101companies.org/wiki/' + (Page.nice_wiki_url page.full_title) + '</loc></url>'
    end
    text = text + '</urlset>'
    render :xml => text
  end

  # handle non authorized 500 status from cancan
  rescue_from CanCan::AccessDenied do |exception|
    flash[:notice] = "Sorry, you aren't permitted to execute your last action =/"
    if request.referer
      redirect_to :back
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
