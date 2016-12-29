require 'rails_helper'

RSpec.describe PageChangesController, type: :controller do
  let!(:page) { create(:page) }
  let(:user) { create(:user) }

  let!(:page_change) { create(:page_change, page: page) }
  let!(:other_page_change) { create(:other_page_change, page: page) }

  describe 'diff' do

    it 'diffs 2 pages' do
      get(:diff, params: { page_change_id: page_change.id, another_page_change_id: other_page_change.id })

      expect(response).to render_template(:diff)
    end

    it 'is diffing to the current version' do
      get(:diff, params: { page_change_id: page_change.id })

      expect(response).to render_template(:diff)
    end

    it 'is given an invalid change id for one change' do
      get(:diff, params: { page_change_id: 0, another_page_change_id: other_page_change.id })

      expect(response).to render_template(:diff)
    end

    it 'is missing both page' do
      get(:diff, params: { page_change_id: '' })

      expect(response).to redirect_to('/wiki/101project')
    end

  end

  describe 'get_all' do

    it 'gets all' do
      get(:get_all, params: { page_id: page.id })

      data = JSON::parse(response.body)
      expect(data['success']).to be(true)
    end

  end

  describe 'apply' do

    it 'cant apply without privileges' do
      get(:apply, params: { page_change_id: page_change.id })

      expect(response).to redirect_to('/wiki/101project')
      expect(flash[:error]).not_to be(nil)
    end

    it 'has invalid page change id' do
      get(:apply, params: { page_change_id: 0 })

      expect(response).to redirect_to('/wiki/101project')
      expect(flash[:error]).not_to be(nil)
    end

    it 'applies' do
      get(:apply, params: { page_change_id: page_change.id }, session: { user_id: user.id })

      expect(response).to redirect_to(page_path(page_change.title))
      expect(flash[:warning]).not_to be(nil)

      page.reload
      expect(page.raw_content).to eq(page_change.raw_content)
    end

  end

  describe 'show' do

    it 'shows the page' do
      get(:show, params: { page_change_id: page_change.id })

      expect(assigns(:real_page)).to eq(page)
      expect(assigns(:page)).to be_a_new(Page)
      expect(response).to render_template(:show)
    end

    it 'has invalid change id' do
      get(:show, params: { page_change_id: 0 })

      expect(response).to redirect_to('/wiki/101project')
      expect(flash[:error]).not_to be(nil)
    end

  end

end
