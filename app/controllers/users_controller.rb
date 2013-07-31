class UsersController < ApplicationController
  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
  end

  def claim_pages

    if !current_user
      flash[:notice] = 'You need to be logged in, if you want claim pages'
      redirect_to '/users'
      return
    end

    require 'media_wiki'

    gateway = MediaWiki::Gateway.new 'http://mediawiki.101companies.org/api.php'

    current_user.old_wiki_users.each do |old_wiki_user|

      ((gateway.contributions old_wiki_user.name).map { |edit| edit['title'] }).uniq.each do |old_wiki_page|

        found_page = Page.find_by_full_title old_wiki_page

        if found_page
          found_page.users << current_user
          found_page.users.uniq!
        end

      end

    end

    flash[:notice] = "You are granted editing permissions for #{current_user.pages.count} pages"
    redirect_to current_user

  end
end
