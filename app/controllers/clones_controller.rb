class ClonesController < ApplicationController

  respond_to :json, :html

  def show_create
  end

  def create
    if not Clone.where(title: params[:title]).exists?
      attributes = params[:clone]
      @clone = Clone.create(attributes)
      render :json => @clone
    else
      render :json => {:success => false, :message => 'Clone already exists, choose another name.'}, :status => 409
    end
  end

  def show
  end

  def index
    @clones = Clone.all
    respond_with @clones
  end

  def get
    @clone = Clone.where(title: params[:title]).first
    @clone.update_status() unless @clone.nil? or params[:no_update]
    Clone.trigger_preparation
    respond_with @clone
  end

  def update
    @clone = Clone.find_by(title: params[:title])
    if @clone
      @clone.update_attributes!(params[:clone])
      @clone.update_status() unless params[:no_update]
      respond_with @clone
    else
      render :json => {:success => false}, :status => 409
    end
  end

  def delete
    @clone = Clone.where(title: params[:title])
    if @clone
      @clone.delete
      render :json => {:success => true}
    else
      render :json => {:success => false}, :status => 409
    end
  end

end
