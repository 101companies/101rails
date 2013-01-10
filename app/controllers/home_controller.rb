class HomeController < ApplicationController
  def index
    @users = User.all
  end

  def data
  	
  end
end
