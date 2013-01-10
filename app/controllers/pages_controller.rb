class PagesController < ApplicationController
  include PagesHelper
  respond_to :json, :html

  def show
    @title = params[:title]
    @page = Page.new(@title)
    respond_with @page
  end

  # get all sections for a page
  def sections
    title = params[:id]
    page = Page.new(title)
    sections = page.sections
    respond_with sections
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
