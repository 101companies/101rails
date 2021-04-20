module Admin
  class ValidationsController < ApplicationController
    layout :admin_layout
    authorize_resource

    def index; end

    private

    def admin_layout
      'admin'
    end
  end
end
