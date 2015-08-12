require 'rails_helper'

RSpec.describe PagesController, type: :controller do

  let(:valid_attributes) { attributes_for(:page) }

  before(:each) do
    @abstraction_page = create :abstraction_page
    @page = create :page
  end

  describe 'GET show' do

    it 'returns the normal page' do
      get :show, id: @page.url

      expect(response).to render_template(:show)
      expect(assigns(:page)).to eq(@page)
    end

    it 'cant find page and redirects' do
      get :show, id: 'does_not_exist'

      expect(response.status).to eq(302)
      expect(assigns(:page)).to be_nil
    end

  end

end
