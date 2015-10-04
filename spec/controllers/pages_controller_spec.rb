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

    it 'gets a contributor page' do
      user = create :user
      page = create(:contributor_page)
      change = create(:page_change, user: user)

      get :show, { id: page.full_title }, { user_id: user.id }

      expect(assigns(:pages_edits)).to eq([change])
    end

    it 'auto creates a new page' do
      user = create :user

      get :show, { id: 'does_not_exist' }, { user_id: user.id }

      expect(response).to redirect_to('/wiki/does_not_exist/create_new_page_confirmation')
    end

  end

  describe 'GET create_new_page_confirmation' do

    it 'show confirmation page' do
      user = create :user

      get :create_new_page_confirmation, { id: 'does_not_exist' }, { user_id: user.id }

      expect(response).to render_template('create_new_page_confirmation')
      expect(response.status).to eq(200)
    end

  end

  describe 'GET edit' do

    it 'shows page edit' do
      user = create :user

      get :edit, { id: @page.url }, { user_id: user.id }

      expect(response).to render_template('edit')
      expect(response.status).to eq(200)
    end

  end

  describe 'GET destroy' do

    it 'cannot destroys the page' do
      expect {
        get :destroy, { id: @page.url }
      }.to_not change(Page, :count)

      expect(flash[:notice].length).to be > 0
    end

    it 'destroys the page' do
      user = create :user

      expect {
        get :destroy, { id: @page.url }, { user_id: user.id }
      }.to change(Page, :count).by(-1)
    end

  end

  describe 'GET create_new_page' do

    it 'creates page' do
      user = create :user

      get :create_new_page, { id: 'new_page' }, { user_id: user.id }

      expect(response.status).to eq(302)
      expect(response).to redirect_to("/wiki/new_page")
    end

    it 'does not create new page' do
      get :create_new_page, { id: 'new_page' }

      expect(flash[:error].length).to be > 0
      expect(response).to redirect_to("/wiki/@project")
    end

  end

  describe 'update' do

    it 'updates the page' do
      user = create(:user)

      put :update, { id: @page.full_title, content: 'Some other content' }, { user_id: user.id }

      expect(@page.reload.raw_content).to include('Some other content')
    end

  end

  describe 'rename' do

    it 'renames the page' do
      user = create(:user)

      get :rename, { id: @page.full_title, newTitle: 'OtherTitle' }, { user_id: user.id }

      expect(@page.reload.title).to eq('OtherTitle')
    end

  end

  describe 'search' do

    it 'returns the correct page' do
      result = get :search, { q: @page.full_title }

      expect(assigns(:search_results).length).to eq(2)
      expect(response).to render_template(:search)
    end

    it 'flashes warning if no q is given' do
      result = get :search

      expect(response).to redirect_to('/wiki/@project')
    end

  end

  describe 'update_repo' do

    it 'updates the repo' do
      user = create :user
      repo_link = {
        folder: '/',
        user_repo: 'kevin-klein/pythonSyb'
      }

      post :update_repo, { id: @page.url, repo_link: repo_link }, { user_id: user.id }

      expect(@page.reload.repo_link.folder).to eq('/')
    end

  end

end
