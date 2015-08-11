class ApplicationController < ActionController::Base
  protect_from_forgery

  # return to previous page after sign in
  def after_sign_in_path_for(resource)
    request.env['omniauth.origin'] || stored_location_for(resource) || root_path
  end

  def go_to_homepage
    redirect_to '/wiki/@project'
  end

  def landing_page
    render template: 'layouts/landing', layout: false
  end

  def contributors_without_github_name
    person_links = []

    Page.where(:used_links => /Contributor/).each do |page|
      page.used_links.select{|l| l.include?('Contributor')}.each do |link|
        links_splits = link.split('::')
        if links_splits.count == 2
          person_links << ((link.include? '::') ? links_splits[1] : link)
        end
      end
    end

    @todo_names = []

    person_links.select{|link| link.starts_with? 'Contributor'}.uniq.sort.each do |person|
      name = person.split(':')[1]
      if name.include?(' ')
        @todo_names << name
      end
    end
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
      text = text + '<url><loc>http://101companies.org/wiki/' + page.url + '</loc>'+
          "<lastmod>#{page.updated_at.to_date}</lastmod>" +
          '<changefreq>weekly</changefreq>'+
          '</url>'
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

  def pull_repo
    entries = Hash.new
    RepoLink.not.where(folder: /\/concepts/).each do |link|
      # filter out concepts
      if entries[link.namespace].nil?
        entries[link.namespace] = Hash.new
      end
      entries[link.namespace][link.out_name] = link.full_url
    end
    render :json => entries
  end

  before_filter :set_cache_buster
  def set_cache_buster
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
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
      @current_user = User.where(id: session[:user_id]).first
    else
      nil
    end
  end

end
