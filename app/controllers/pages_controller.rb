class PagesController < ApplicationController
  include PagesHelper
  respond_to :json, :html

  def show
    @logged_user = current_user
    #TODO: add actions for the current page based on the roles
    @logged_user.actions = ["View"]

    @title = params[:title]
    if @title == nil
      @title = "101companies:Project"
    end  
    @page = Page.new(@title)
    respond_with @page
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

  def update
    title = params[:title]
    sections = params[:sections]
    content = ""
    sections.each { |s| content += s['content'] }
    page = Page.new(title)
    page.update(content)
    render :json => {:success => true}
  end

  def section
    title = params[:id]
    p = Page.new(title)
    section = {'content' => p.section(params[:title])}
    respond_with section.to_json
  end
end
