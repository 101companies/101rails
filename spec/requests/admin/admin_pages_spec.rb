require 'rails_helper'

RSpec.describe "Admin::Pages", type: :request do
  describe "GET /admin_pages" do
    it "works! (now write some real specs)" do
      get admin_pages_path
      expect(response).to have_http_status(200)
    end
  end
end
