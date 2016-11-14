class Admin::AdminController < ApplicationController
  layout :admin_layout
  authorize_resource

  def index
    @page_count             = Page.cached_count
    @unverified_page_count  = Page.unverified.count
    @today_visits           = Visit.where('started_at > ?', Date.today - 1.day).count
    @today_views            = Ahoy::Event.where(name: '$view').where('time > ?', Date.today.beginning_of_day).count
    @popular_page_views     = Ahoy::Event.where(name: '$view').group('properties ->> \'url\'').order('count_all desc').limit(3).count
    @new_pages              = Page.order(created_at: :desc).limit(10)
    @new_users              = User.order(created_at: :desc).limit(10)
  end

  private

  def admin_layout
    'admin'
  end

end
