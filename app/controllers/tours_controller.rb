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
       render :html => {:success => false}, :status => 404
    else
      respond_with @tour
    end
  end

end

