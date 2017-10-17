require 'rails_helper'

RSpec.describe PagesController, type: :controller do
  let(:valid_attributes) { attributes_for(:page) }

  before(:each) do
    @abstraction_page = create(:abstraction_page, :reindex)
    @page = create(:page, :reindex)

    Page.search_index.refresh
  end

  describe 'GET show' do
    it 'returns the normal page' do
      expect {
        get(:show, params: { id: @page.url })
      }.not_to change(Page, :count)

      expect(response).to render_template(:show)
      expect(assigns(:page)).to eq(@page)
    end

    it 'cant find page and redirects' do
      expect {
        get(:show, params: { id: 'does_not_exist' })
      }.not_to change(Page, :count)

      expect(response.status).to eq(302)
      expect(assigns(:page)).to be_nil
    end

    it 'gets a contributor page' do
      user = create(:user)
      page = create(:contributor_page, :reindex)
      change = create(:page_change, user: user)

      Page.search_index.refresh

      expect {
        get(:show, params: { id: page.full_title }, session: { user_id: user.id })
      }.not_to change(Page, :count)

      expect(response.status).to eq(200)
    end

    it 'gets a new contributor page' do
      user = create(:user)

      expect {
        get(:show, params: { id: "Contributor:#{user.github_name}" }, session: { user_id: user.id })
      }.to change(Page, :count).by(1)

      expect(response.status).to eq(302)
      expect(response).to redirect_to(page_path("Contributor:#{user.github_name}"))
    end

    it 'auto creates a new page' do
      user = create(:user)

      expect {
        get(:show, params: { id: 'does_not_exist' }, session: { user_id: user.id })
      }.to change(Page, :count).by(0)

      expect(response).to redirect_to('/does_not_exist/create_new_page_confirmation')
    end
  end

  describe 'GET create_new_page_confirmation' do
    it 'show confirmation page' do
      user = create(:user)

      expect {
        get(:create_new_page_confirmation, params: { id: 'does_not_exist' }, session: { user_id: user.id })
      }.to change(Page, :count).by(0)

      expect(response).to render_template('create_new_page_confirmation')
      expect(response.status).to eq(200)
    end
  end

  describe 'GET edit' do
    it 'shows page edit' do
      user = create :user

      expect {
        get(:edit, params: { id: @page.url }, session: { user_id: user.id })
      }.not_to change(Page, :count)

      expect(response).to render_template('edit')
      expect(response.status).to eq(200)
    end
  end

  describe 'GET destroy' do
    it 'cannot destroys the page' do
      expect {
        get(:destroy, params: { id: @page.url })
      }.to_not change(Page, :count)

      expect(flash[:notice].length).to be > 0
    end

    it 'destroys the page' do
      user = create(:user)

      expect do
        get(:destroy, params: { id: @page.url }, session: { user_id: user.id })
      end.to change(Page, :count).by(-1)
    end
  end

  describe 'GET create_new_page' do
    it 'creates page' do
      user = create(:user)

      expect {
        get(:create_new_page, params: { id: 'new_page' }, session: { user_id: user.id })
      }.to change(Page, :count).by(1)

      expect(response.status).to eq(302)
      expect(response).to redirect_to(page_path('new_page'))
    end

    it 'creates page with special characters' do
      user = create(:user)

      expect {
        get(:create_new_page, params: { id: 'AST^+' }, session: { user_id: user.id })
      }.to change(Page, :count).by(1)

      expect(response.status).to eq(302)
      expect(response).to redirect_to(page_path('AST^+'))
      expect(Page.where(title: 'AST^+').count).to eq(1)
    end

    it 'does not create new page' do
      expect {
        get(:create_new_page, params: { id: 'new_page' })
      }.not_to change(Page, :count)

      expect(flash[:error].length).to be > 0
      expect(response).to redirect_to(root_path)
    end
  end

  describe 'update' do
    it 'updates the page' do
      user = create(:user)

      expect {
        put(:update, params: { id: @page.full_title, content: 'Some other content' }, session: { user_id: user.id })
      }.not_to change(Page, :count)

      expect(@page.reload.raw_content).to include('Some other content')
    end
  end

  describe 'rename' do
    it 'renames the page' do
      user = create(:user)

      expect {
        get(:rename, params: { id: @page.full_title, newTitle: 'OtherTitle' }, session: { user_id: user.id })
      }.not_to change(Page, :count)

      expect(@page.reload.title).to eq('OtherTitle')
    end

    it 'renames a semantic property' do
      user = create(:user)
      page = create(:property_having_page)
      property_page = create(:property_page)

      get(:rename, params: { id: property_page.full_title, newTitle: 'Property:hasDomain' }, session: { user_id: user.id })

      page.reload
      expect(page.raw_content).to include('[[hasDomain::SomeDomain]]')
    end
  end

  describe 'search' do
    it 'returns the correct page' do
      expect {
        get(:search, params: { q: @page.title })
      }.not_to change(Page, :count)

      expect(assigns(:search_results).length).to eq(1)
      expect(response).to render_template(:search)
    end

    it 'searchs for section foobar' do
      page = create(:foobar_page, :reindex)
      Page.search_index.refresh

      get(:search, params: { q: 'Section:FooBar' })

      expect(assigns(:search_results).to_a).to eq([page])
    end

    it 'can search without text' do
      expect {
        get(:search)
      }.not_to change(Page, :count)

      expect(response).to render_template(:search)
    end
  end

  describe 'update_repo' do
    it 'updates the repo' do
      user = create(:user)
      repo_link = {
        folder: '/',
        user_repo: 'kevin-klein/pythonSyb'
      }

      expect {
        post(:update_repo, params: { id: @page.url, repo_link: repo_link }, session: { user_id: user.id })
      }.not_to change(Page, :count)

      expect(@page.reload.repo_link.folder).to eq('/')
    end
  end
end
