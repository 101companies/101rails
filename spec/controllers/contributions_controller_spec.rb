require 'rails_helper'

RSpec.describe ContributionsController, type: :controller do
  
  describe 'Create Contribution' do
    it 'no user' do
		params = {
			:contrb_tile => 'SomeTitle',
			:repo_link => {:user_repo => 'SomeRepoURL', :folder => ''},
			:contrb_description => 'SomeDescription'
		}
		post :create, params

      expect(response.status).to eq(302)
      expect(response).to redirect_to('/wiki/101project')
		end

		it 'no Repo URL' do
			current_user = create :user
			params = {
				contrb_title: 'SomeTitle',
				:repo_link => {:user_repo => '', :folder => ''},
			}	
			post :create, params, { user_id: current_user.id }
			expect(flash[:error])
			expect(response.status).to eq(302)
			expect(response).to redirect_to('/contribute/new')
		end
		
		it 'no title' do
			current_user = create :user
			params = {
				contrb_title: '',
                                :repo_link => {:user_repo => '101companies/101docs', :folder => '/'},
				contrb_description: 'Test describtion',
			}	
			post :create, params, { user_id: current_user.id }
			expect(flash[:error])
			expect(response.status).to eq(302)
			expect(response).to redirect_to('/contribute/new')
		end
		
		it 'duplicated' do
			@contributionPage = create :contributionPage
			current_user = create :user
			params = {
				contrb_title: 'SomeTitle',
				:repo_link => {:user_repo => '101companies/101docs', :folder => '/'},
				contrb_description: 'Test describtion',
			}	
			post :create, params, { user_id: current_user.id }
			expect(flash[:error])
			expect(response.status).to eq(302)
			expect(response).to redirect_to('/contribute/new')
		end
		
		it 'Success' do
			current_user = create :user
			params = {
				contrb_title: 'SomeTitle',
				:repo_link => {:user_repo => '101companies/101docs', :folder => '/'},
				contrb_description: 'Test describtion',
			}	
			post :create, params, { user_id: current_user.id }
			expect(response.status).to eq(302)
			expect(response).to redirect_to('/wiki/Contribution:SomeTitle')
		end
		
		it 'Success as normal user' do
			current_user = create :editor_user
			params = {
				contrb_title: 'SomeTitle',
				:repo_link => {:user_repo => '101companies/101docs', :folder => '/'},
				contrb_description: 'Test describtion',
			}	
			post :create, params, { user_id: current_user.id }
			expect(response.status).to eq(302)
			expect(response).to redirect_to('/wiki/Contribution:SomeTitle')
		end
		
		it 'Success with default describtion' do
			current_user = create :user
			params = {
				contrb_title: 'SomeTitle',
				:repo_link => {:user_repo => '101companies/101docs', :folder => '/'},
				contrb_description: '',
			}	
			post :create, params, { user_id: current_user.id }
			expect(response.status).to eq(302)
			expect(response).to redirect_to('/wiki/Contribution:SomeTitle')
		end
	end
end
