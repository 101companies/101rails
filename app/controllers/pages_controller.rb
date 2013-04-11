class PagesController < ApplicationController
  include PagesHelper
  respond_to :json, :html

  def show
    @logged_user = current_user
    #TODO: add actions for the current page based on the roles
    if not @logged_user.nil?
      @logged_user[:actions] = ["View", "Edit"]
    end

    @title = params[:title]
    if @title == nil
      @title = "101companies:Project"
    end
    @page = Page.new(@title)

    @page.instance_eval { class << self; self end }.send(:attr_accessor, "history")
    if not History.where(:page => @title).exists?
      @page.history = History.create!(
        user: current_user,
        page: @title,
        version: 1
      )
    else
     @page.history = History.where(:page => @title).first
    end

    respond_with @page
  end

  def parse
    content = params[:content]
    wiki = WikiCloth::Parser.new(:data => content, :noedit => true)
    html = wiki.to_html
    wiki.internal_links.each do |link|
      html.gsub!("<a href=\"#{link}\"", "<a href=\"/wiki/#{link}\"")
    end
    render :json => {:success => true, :html => html.html_safe}
  end

  def summary
    begin
      GC.disable
      title = params[:id]
      page = Page.new(title)
      render :json => {:sections => page.sections, :internal_links => page.internal_links}
    rescue
      @error_message="#{$!}"
      render :json => {:success => false, :error => @error_message}
    ensure
      GC.enable
      GC.start  
    end
  end

  # get all sections for a page
  def sections
    begin
      title = params[:id]
      page = Page.new(title)
      sections = page.sections
      respond_with sections
    rescue
      @error_message="#{$!}"
      render :json => {:success => false, :error => @error_message}
    end
  end

  # get all internal links for the page
  def internal_links
    begin
      title = params[:id]
      page = Page.new(title)
      respond_with page.internal_links
    rescue
      @error_message="#{$!}"
      render :json => {:success => false, :error => @error_message}
    end
  end

  def update
    title = params[:title]
    sections = params[:sections]
    page = Page.new(title)
    if params.has_key?('content') and params[:content] != ""
      page.update(params[:content])
    else
      content = ""
      sections.each { |s| content += s['content'] }
      page.update(content)
    end

    if History.where(:page => title).exists?
      history = History.where(:page => title).first
      history.update_attributes(
        version: history.version + 1,
        user: current_user
      )
    else
      History.create!(
        page: title,
        version: 1,
        user: current_user
      )
    end

    render :json => {:success => true}
  end

  def section
    title = params[:id]
    p = Page.new(title)
    section = {'content' => p.section(params[:title])}
    respond_with section.to_json
  end
end
