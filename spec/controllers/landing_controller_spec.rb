require 'rails_helper'

RSpec.describe LandingController, type: :controller do

  describe 'index' do
    it 'gets index for technologies' do
      tech_page = create(:technology_page)
      tech_having_page = create(:technology_having_page)

      get(:index)

      expect(assigns(:technologies)).to eq({tech_page.title => 1})
    end

    it 'works without technologies' do
      get(:index)

      expect(assigns(:technologies)).to eq({})
    end
  end

  describe 'new index' do
    it 'gets new index' do
      tech_page = create(:technology_page)
      tech_having_page = create(:technology_having_page)

      get(:new_index)

      expect(assigns(:technologies)).to eq({tech_page.title => 1})
    end
  end
end
