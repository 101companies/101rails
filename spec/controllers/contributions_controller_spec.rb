require 'rails_helper'

RSpec.describe ContributionsController.rbController, type: :controller do
  describe 'GET index' do
    it 'returns normal page' do
      get :index
      expect(response).to render_template(:index)
end
