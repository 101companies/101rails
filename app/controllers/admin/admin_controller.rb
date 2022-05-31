module Admin
  class AdminController < ApplicationController
    layout :admin_layout
    authorize_resource

    def index
      @page_count             = Page.cached_count
      @unverified_page_count  = Page.unverified.count
      @new_pages              = Page.order(created_at: :desc).limit(10)
      @new_users              = User.order(created_at: :desc).limit(10)
    end

    private

    def admin_layout
      'admin'
    end
  end
end
