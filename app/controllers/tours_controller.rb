class ToursController < ApplicationController
  respond_to :json, :html

  def index
    @tours = Tour.asc
    respond_with @tours
  end

  def show
    @title = params[:title]
    @tour = Tour.where(title: @title).first
    if @tour.nil? 
      respond_with @tour
    else
      respond_with @tour
    end
  end

end

