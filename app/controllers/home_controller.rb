class HomeController < ApplicationController
  def index
    render :layout => 'landing'
  end

  def not_authorized
  end

end
