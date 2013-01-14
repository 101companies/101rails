class HomeController < ApplicationController
  def index
    @users = User.all
    render :layout => 'landing'
  end

  def data
  	
  end
end
