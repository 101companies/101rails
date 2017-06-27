require 'rails_helper'

RSpec.describe ContributionsController, type: :controller do

  # clear emails
  before { ActionMailer::Base.deliveries = [] }
  let(:current_user) { create(:user) }

  describe 'Create Contribution' do
    it 'no user' do
      params = {
        contrb_tile: 'SomeTitle',
        repo_link: { user_repo: 'SomeRepoURL', folder: '' },
        contrb_description: 'SomeDescription'
      }
      post(:create, params: params)

      expect(response.status).to eq(302)
      expect(response).to redirect_to(root_path)
    end

    it 'no Repo URL' do
      params = {
        contrb_title: 'SomeTitle',
        repo_link: { user_repo: '', folder: '' }
      }
      post(:create, params: params, session: { user_id: current_user.id })

      expect(flash[:error]).to eq('You need to choose a repo first')
      expect(response.status).to eq(302)
      expect(response).to redirect_to('/contribute/new')
    end

    it 'no title' do
      params = {
        contrb_title: '',
        repo_link: { user_repo: '101companies/101docs', folder: '/' },
        contrb_description: 'Test describtion'
      }
      post(:create, params: params, session: { user_id: current_user.id })

      expect(flash[:error]).to eq('You need to define title for contribution')
      expect(response.status).to eq(302)
      expect(response).to redirect_to('/contribute/new')
    end

    it 'duplicated' do
      contributionPage = create(:contributionPage)
      params = {
        contrb_title: 'SomeTitle',
        repo_link: { user_repo: '101companies/101docs', folder: '/' },
        contrb_description: 'Test describtion'
      }
      post(:create, params: params, session: { user_id: current_user.id })

      expect(flash[:error]).to eq('Sorry, but page with this name is already taken')
      expect(response.status).to eq(302)
      expect(response).to redirect_to('/contribute/new')
    end

    it 'Success' do
      params = {
        contrb_title: 'SomeTitle',
        repo_link: { user_repo: '101companies/101docs', folder: '/' },
        contrb_description: 'Test describtion'
      }
      expect {
        post(:create, params: params, session: { user_id: current_user.id })
      }.to change(Page, :count).by(1)

      expect(response.status).to eq(302)
      expect(response).to redirect_to(page_path('Contribution:SomeTitle'))
    end

    it 'Success as normal user' do
      current_user = create :editor_user
      params = {
        contrb_title: 'SomeTitle',
        repo_link: { user_repo: '101companies/101docs', folder: '/' },
        contrb_description: 'Test describtion'
      }
      expect {
        post(:create, params: params, session: { user_id: current_user.id })
      }.to change(Page, :count).by(1)

      expect(response.status).to eq(302)
      expect(response).to redirect_to(page_path('Contribution:SomeTitle'))
    end

    it 'sends emails' do
      current_user = create :editor_user
      email = current_user.email

      params = {
        contrb_title: 'SomeTitle',
        repo_link: { user_repo: '101companies/101docs', folder: '/' },
        contrb_description: 'Test describtion'
      }
      expect {
        post(:create, params: params, session: { user_id: current_user.id })
      }.to change { ActionMailer::Base.deliveries.count }.by(2)

      # user email
      expect(ActionMailer::Base.deliveries[0].to[0]).to eq(email)

      # admin email
      expect(ActionMailer::Base.deliveries[1].to[0]).to eq("101companies@gmail.com")
    end

    it 'Success with default description' do
      current_user = create :user
      params = {
        contrb_title: 'SomeTitle',
        repo_link: { user_repo: '101companies/101docs', folder: '/' },
        contrb_description: ''
      }
      expect {
        post(:create, params: params, session: { user_id: current_user.id })
      }.to change(Page, :count).by(1)

      expect(response.status).to eq(302)
      expect(response).to redirect_to(page_path('Contribution:SomeTitle'))
    end
  end

  describe 'new' do
    it 'no user' do
      post :new
      expect(response).to render_template('contributions/login_intro')
    end
  end
end
