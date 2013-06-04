class ToursController < ApplicationController
  respond_to :json, :html

  def index
    @tours = Tour.asc
    respond_with @tours
  end

  def show
    @title = params[:title]
    @tour = Tour.where(title: @title).first
    #if @tour.nil? 
     # @tourBlank = Tour.new.create(:title)
     # respond_with @tourBlank
    #else
    respond_with @tour
    #end
  end

end