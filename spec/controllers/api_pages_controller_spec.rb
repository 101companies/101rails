require 'rails_helper'

RSpec.describe ApiPagesController, type: :controller do
  let!(:page) { create(:page) }
  render_views

  describe 'GET show' do

    it 'returns the normal page' do
      get :show, id: page.url, format: :json

      json_reponse = JSON.parse(response.body)

      expect(json_reponse['title']).to eq(page.title)
      expect(json_reponse['markup']).to eq(page.raw_content)
      expect(json_reponse['namespace']).to eq(page.namespace)

      expect(response).to render_template(:show, locals: { page: page })
    end

  end

end
