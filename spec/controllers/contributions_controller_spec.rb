require 'rails_helper'

RSpec.describe ContributionsController.rbController, type: :controller do
  describe 'GET index' do
    it 'should get the index' do
      get :index
      expect(response).to render_template(:index)
    end
  end
end
