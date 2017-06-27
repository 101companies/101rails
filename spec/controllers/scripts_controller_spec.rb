require 'rails_helper'

RSpec.describe ScriptsController, type: :controller do
  let!(:page) { create(:page) }
  let!(:abstraction_page) { create(:abstraction_page) }

  describe 'show' do

    it 'gets show' do
      get(:show, params: { id: page.full_underscore_title })

      expect(response).to render_template(:show)

      expect(assigns(:pages)).to eq([page, abstraction_page])
    end

    it 'it is non existing page' do
      get(:show, params: { id: 'contribution::DOES_NOT_EXIST' })

      expect(response).to redirect_to(root_path)
    end

  end
end
