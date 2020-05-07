require 'rails_helper'
require 'fileutils'

RSpec.describe ReposController, type: :controller do


  # before (:each) do
  #   create :system_setting_result_path
  #   create :system_setting_data_path
  #   create :system_setting_web_path
  #   SystemSetting.create(name: "Module_Dependencies", value:"{\"simpleLOC\":[],\"locPerContribution\":[\"simpleLOC\"],\"matchLanguage\":[]}")
  # end
  #
  # after do
  #   resultPath = SystemSetting.find_by(name: 'Result_Path').value
  #   dataPath = SystemSetting.find_by(name: 'Data_Path').value
  #
  #   if Dir.exist?(File.join(resultPath,'repo_github_com_101companies_101worker'))
  #     FileUtils.remove_dir File.join(resultPath,'repo_github_com_101companies_101worker')
  #   end
  #   if Dir.exist?(File.join(dataPath,'repo_github_com_101companies_101worker'))
  #     FileUtils.remove_dir File.join(dataPath,'repo_github_com_101companies_101worker')
  #   end
  # end
  #
  # describe 'GET #index' do
  #   it 'responds successfull to html when active' do
  #     stop = SystemSetting.create(name: 'Stop', value: 1)
  #     get :index
  #     expect(response).to be_success
  #   end
  #   it 'redirects when service is offline' do
  #     stop = SystemSetting.create(name: 'Stop', value: -1)
  #     get :index
  #     expect(response).not_to be_success
  #   end
  # end
  #
  # describe 'POST #create' do
  #
  #   describe 'display error logs' do
  #     it 'shows link not found error' do
  #       params = {'repoData'=>{'link'=>'noLink',
  #                              'branch'=>'',
  #                              'revision'=>'ToShortRev',
  #                              'matchLanguage'=>'1',
  #                              'simpleLOC'=>'0'},
  #                 'commit'=>'Save Repodata'}
  #       post :create, params: params
  #       expect(flash['error']).to eq('The Repository could not be found with the provided link')
  #
  #     end
  #     it 'shows branch not found error' do
  #       params = {'repoData'=>{'link'=>'http://www.github.com/101companies/101worker.git',
  #                              'branch'=>'NotABranch',
  #                              'revision'=>'',
  #                              'matchLanguage'=>'1',
  #                              'simpleLOC'=>'0'},
  #                 'commit'=>'Save Repodata'}
  #       post :create, params: params
  #       expect(flash['error']).to eq('Your defined branch could not be found')
  #
  #     end
  #     it 'shows revision not found error' do
  #       params = {'repoData'=>{'link'=>'http://www.github.com/101companies/101worker.git',
  #                              'branch'=>'',
  #                              'revision'=>'ToShortRev',
  #                              'matchLanguage'=>'1',
  #                              'simpleLOC'=>'0'},
  #                 'commit'=>'Save Repodata'}
  #       post :create, params: params
  #       expect(flash['error']).to eq('Your defined revision could not be found, please check your input')
  #
  #     end
  #     it 'shows no module selected error' do
  #       params = {'repoData'=>{'link'=>'http://www.github.com/101companies/101worker.git',
  #                              'branch'=>'',
  #                              'revision'=>'',
  #                              'matchLanguage'=>'0',
  #                              'simpleLOC'=>'0'},
  #                 'commit'=>'Save Repodata'}
  #       post :create, params: params
  #       expect(flash['error']).to eq('Please select a Module, before submitting a analysis')
  #
  #     end
  #     it 'show repo size to high error' do
  #       create :system_setting_maximum_size_zero
  #       params = {'repoData'=>{'link'=>'http://www.github.com/101companies/101worker.git',
  #                              'branch'=>'',
  #                              'revision'=>'',
  #                              'matchLanguage'=>'1',
  #                              'simpleLOC'=>'0'},
  #                 'commit'=>'Save Repodata'}
  #       post :create, params: params
  #       expect(flash['error']).to eq('The size of the Repo is to high')
  #     end
  #   end
  #
  #
  #   it 'creates raw repo if not exists' do
  #     create :system_setting_maximum_size_high
  #
  #     params = {'repoData'=>{'link'=>'http://www.github.com/101companies/101worker.git',
  #                            'branch'=>'',
  #                            'revision'=>'703cc3316602a25feba145e545bc8b3f75c9b183',
  #                            'simpleLOC'=>'1'},
  #               'commit'=>'Save Repodata'}
  #     post :create, params: params
  #     expect(RawRepo.count()).to eq(1)
  #
  #   end
  #
  #   it 'creates and redirects to repo' do
  #     create :system_setting_maximum_size_high
  #
  #     params = {'repoData'=>{'link'=>'http://www.github.com/101companies/101worker.git',
  #                            'branch'=>'',
  #                            'revision'=>'703cc3316602a25feba145e545bc8b3f75c9b183',
  #                            'simpleLOC'=>'1'},
  #               'commit'=>'Save Repodata'}
  #     post :create, params: params
  #     expect(Repo.count()).to eq(1)
  #     repo = Repo.first
  #     expect(post :create, params: params).to redirect_to(repo)
  #   end
  #
  #   #it 'enqueues job' do
  #     #ActiveJob::Base.queue_adapter = :test
  #     #create :system_setting_maximum_size_high
  #     #
  #     #params = {'repoData'=>{'link'=>'http://www.github.com/101companies/101worker.git',
  #     #                       'branch'=>'',
  #     #                       'revision'=>'703cc3316602a25feba145e545bc8b3f75c9b183',
  #     #                       'simpleLOC'=>'1'},
  #     #          'commit'=>'Save Repodata'}
  #     #post :create, params: params
  #     #expect(AnalyseJob).to have_been_enqueued
  #   #end
  # end
  #
  #
  # describe 'POST #getInfoAsync' do
  #   it 'gives right response' do
  #     raw_repo = RawRepo.create(name:"ABC",state:0,size:0)
  #     repo = raw_repo.repo.create(name: "ABCabc",state:1,size:0,link:"link",rev:"abc")
  #     repo.part.create(name:"module1",state:0)
  #     repo.part.create(name:"module2",state:1)
  #     post :getInfoAsync, params: {name: 'ABCabc'}
  #     expect((response.body)).to eq("{\"repo\":1,\"module\":[{\"name\":\"module1\",\"state\":0},{\"name\":\"module2\",\"state\":1}]}")
  #
  #   end
  # end
  #
  # describe 'GET #show' do
  #   it 'shows a repo' do
  #     raw_repo = RawRepo.create(name:"ABC",state:0,size:0)
  #     repo = raw_repo.repo.create(name: "abc",state:1,size:0,link:"link",rev:"abc")
  #
  #     get :show, params:{name:repo.to_param}
  #     expect(response).to be_success
  #   end
  # end
  #
  #
  # describe 'POST #sendDownload' do
  #   it 'error - repo not available' do
  #     raw_repo = RawRepo.create(name:"ABC",state:0,size:0)
  #     repo = raw_repo.repo.create(name: "abc",state:1,size:0,link:"link",rev:"abc")
  #     post :sendDownload, params: {name: "abc"}
  #     expect(flash[:error]).to eq("There are actually some analysis running on this repositorie, please wait until they are finished")
  #   end
  # end


end
