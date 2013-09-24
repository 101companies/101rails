class ClonesController < ApplicationController

  respond_to :json, :html

  def show_create
  end

  def create
    puts params
    exists = Clone.where(title: params[:title]).exists?
    if !exists
      params[:clone][:status] = 'new'
      Clone.create(params[:clone])
      render :json => {:success => true}
    else
      render :json => {:success => false, :message => "Clone already exists, choose another name."}, :status => 409
    end
  end

  def show
  end

  def index
    Clone.delay.trigger_preparation
    @clones = Clone.all
    for c in @clones
      c.update_status()
    end
    respond_with @clones
  end

  def get
    Clone.delay.trigger_preparation
    @clone = Clone.where(title: params[:title]).first
    @clone.update_status() unless @clone.nil?
    respond_with @clone
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
