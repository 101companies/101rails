class CategoryPagesController < ApplicationController
  respond_to :json, :html

  def show
    @title = params[:title]
    @page = CategoryPage.new(@title)    	  
    respond_with @page
  end
end
