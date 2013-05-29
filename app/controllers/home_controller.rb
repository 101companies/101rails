class HomeController < ApplicationController
  def index
    render :layout => 'landing'
  end

  def login_intro
    #TODO: check -> already logged in
  end

end
