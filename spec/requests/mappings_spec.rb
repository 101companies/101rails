require 'rails_helper'

RSpec.describe "Mappings", type: :request do
  describe "GET /mappings" do
    it "works! (now write some real specs)" do
      get mappings_path
      expect(response).to have_http_status(200)
    end
  end
end
