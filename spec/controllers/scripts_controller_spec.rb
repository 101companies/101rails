require 'rails_helper'

RSpec.describe ScriptsController, type: :controller do
  let!(:page) { create(:page) }
  let!(:abstraction_page) { create(:abstraction_page) }

  describe 'index' do

    it 'gets index' do
      get(:show, params: { id: page.full_underscore_title })

      expect(response).to render_template(:show)

      expect(assigns(:pages)).to eq([page, abstraction_page])
    end

  end

end
