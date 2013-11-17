class ApplicationController < ActionController::Base
  protect_from_forgery

  # return to previous page after sign in
  def after_sign_in_path_for(resource)
    request.env['omniauth.origin'] || stored_location_for(resource) || root_path
  end

  def go_to_homepage
    redirect_to '/wiki/@project'
  end

  def get_slide
    # get url for slideshare slide
    slideshare_url = params[:slideshare]
    # remove part of urls with http:/, http://, https://, https:/
    # and replace it with https://
    # this is needed for nginx + passenger, who merge slashes in url, when url is sent as param
    slideshare_url.gsub! /.+[ps]:\/*(.+)/, 'https://\1'
    # parse markup to html
    html = WikiCloth::Parser.new(:data => "<media url='#{CGI.unescape(slideshare_url)}'>", :noedit => true).to_html
    # get download link from html and redirect to it
    redirect_to (html.match /download-link='(.+?)'/)[1]
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
      text = text + '<url><loc>http://101companies.org/wiki/' + page.url + '</loc></url>'
    end
    text = text + '</urlset>'
    render :xml => text
  end

  def go_to_previous_page
    if request.referer
      redirect_to :back
    else
      go_to_homepage
    end
  end

  # handle non authorized 500 status from cancan
  rescue_from CanCan::AccessDenied do |exception|
    flash[:notice] = "Sorry, you aren't permitted to execute your last action =/"
    go_to_previous_page
  end

  helper_method :current_user
  private
  def current_user
    if session[:user_id]
      @current_user = User.where(:id => session[:user_id]).first
    else
      nil
    end
  end

end
