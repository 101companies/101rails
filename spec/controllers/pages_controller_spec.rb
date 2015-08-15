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

      get :show, { id: 'contributor:test' }, { user_id: user.id }

      expect(response).to redirect_to('/wiki/contributor:test')
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

end
