class HomeController < ApplicationController
  def index
    render :layout => 'landing'
  end
end
