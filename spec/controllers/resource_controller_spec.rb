require 'rails_helper'

RSpec.describe ResourceController, type: :controller do

  describe "GET #get" do
    it "returns http success" do
      get :get
      expect(response).to have_http_status(:success)
    end
  end

end
