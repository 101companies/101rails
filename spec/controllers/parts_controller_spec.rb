require 'rails_helper'

RSpec.describe PartsController, type: :controller do

  # describe 'GET #show' do
  #   it 'redirects when state equal zero' do
  #     create :system_setting_result_path
  #     create :system_setting_data_path
  #     raw_repo = RawRepo.create(name:"ABC",state:0,size:0)
  #     repo = raw_repo.repo.create(name: "ABCabc",state:1,size:0,link:"link",rev:"abc")
  #     part = repo.part.create(name:"module1",state:0)
  #     expect(get :show, params:{name: part.to_param,repo_name:repo.to_param}).to redirect_to repo
  #   end
  #   it 'renders show normally' do
  #     create :system_setting_result_path
  #     create :system_setting_data_path
  #     raw_repo = RawRepo.create(name:"ABC",state:0,size:0)
  #     repo = raw_repo.repo.create(name: "ABCabc",state:1,size:0,link:"link",rev:"abc")
  #     part = repo.part.create(name:"module1",state:1,dependsOn:'{}',result:'{}')
  #     get :show, params:{name: part.to_param,repo_name:repo.to_param}
  #     expect(response.status).to eq(200)
  #   end
  #
  # end

end
