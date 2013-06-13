class ToursController < ApplicationController
  respond_to :json, :html

  def index
    @tours = Tour.asc
    respond_with @tours
  end

  def show
    @title = params[:id]
    @tour = Tour.where(title: @title).first
    #if @tour.nil?
     # @tourBlank = Tour.new.create(:title)
     # respond_with @tourBlank
    #else
    respond_with @tour
    #end
  end

  def update
    @tour = Tour.find_or_create_by(title: params[:id])
    @tour.update_attributes(params[:tour])
    render :json => {:success => true}
  end

  def delete
    @_title = params[:id]
    @tour = Tour.find_by(title: @_title)
    @tour.delete()
    render :json => {:success => true}
  end

end
