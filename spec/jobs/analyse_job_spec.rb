require 'rails_helper'
require 'sucker_punch/testing/inline'
require 'fileutils'

RSpec.describe AnalyseJob, type: :job do

  describe 'workflow' do

    before do
      create :system_setting_worker_path
      @result_path = (create :system_setting_result_path).value
      @data_path = (create :system_setting_data_path).value
      create :system_setting_web_path

      if Dir.exists?(@result_path)
        FileUtils.remove_dir(@result_path)
      end
      if Dir.exists?(@data_path)
        FileUtils.remove_dir(@data_path)
      end
      Dir.mkdir(@result_path)
      Dir.mkdir(@data_path)
    end

    after do
      FileUtils.remove_dir(@result_path)
      FileUtils.remove_dir(@data_path)
    end

    describe 'first flow, empty folders' do
      before do
        create :system_setting_maximum_size_high
        create :system_setting_actual_size
        create :system_setting_actual_size_repo
        create :system_setting_maximum_size_repo
      end

      it 'runs correctly' do
        raw_repo = RawRepo.new(name:"repo_github_com_101companies_101haskell",state: 0,size: 400)
        raw_repo.save
        repo = raw_repo.repo.new(name: "repo_github_com_101companies_101haskellce140df9793441693e50b94939a9281df98dff92",
                                 link: "http://www.github.com/101companies/101haskell.git",
                                 rev: "ce140df9793441693e50b94939a9281df98dff92",state: 0,size: 400)
        repo.save
        modules = ["simpleLOC","locPerContribution"]
        modules.each do |m|
          q = repo.part.create(name: m, state: 0)
          q.save
          repo.save

          #start test
        end
        expect(Dir.exist?(File.join(@data_path,repo.raw_repo.name,"result"))).to be false
        expect(File.exist?(File.join(@result_path,repo.raw_repo.name,repo.name+'.zip'))).to be false

        repo.part.all.each do |m|
          expect(m.state).to eq(0)
        end
        AnalyseJob.perform_async("http://www.github.com/101companies/101haskell.git", "ce140df9793441693e50b94939a9281df98dff92",
                                 "repo_github_com_101companies_101haskellce140df9793441693e50b94939a9281df98dff92",
                                 400, modules)
        repo = Repo.find_by(name: "repo_github_com_101companies_101haskellce140df9793441693e50b94939a9281df98dff92")

        expect(Dir.exist?(File.join(@data_path,repo.raw_repo.name,"result"))).to be true
        expect(File.exist?(File.join(@result_path,repo.raw_repo.name,repo.name+'.zip'))).to be true
        expect(repo.state).to eq(2)
        expect(repo.raw_repo.state).to eq(1)

        repo.part.all.each do |m|
          expect(m.state).to eq(1)
        end
      end

    end

    describe 'second flow, other folder exists, raw repo size to high' do

      before do
        create :system_setting_actual_size_repo
        create :system_setting_maximum_size_repo
        max_size = create :system_setting_maximum_size_high
        SystemSetting.create(name:"Actual_Size_Raw_Repo",value: (max_size.value.to_i-10).to_s)
        mock_raw_repo = RawRepo.create(name:"Mock",state:1,size: (max_size.value.to_i-10).to_s)
        @mock_repo = mock_raw_repo.repo.create(name:"MockRepo",state:2,link:"does not matter",rev:"anyone",size:100)
        Dir.mkdir((File.join(@data_path,@mock_repo.raw_repo.name,"result")))
        File.new(File.join(@result_path,@mock_repo.raw_repo.name,@mock_repo.name+'.zip'),'w')
      end

      it 'deletes completed folder, when not enough place on disk' do
        raw_repo = RawRepo.new(name:"repo_github_com_101companies_101haskell",state: 0,size: 400)
        raw_repo.save
        repo = raw_repo.repo.new(name: "repo_github_com_101companies_101haskellce140df9793441693e50b94939a9281df98dff92",
                                 link: "http://www.github.com/101companies/101haskell.git",
                                 rev: "ce140df9793441693e50b94939a9281df98dff92",state: 0,size: 400)
        repo.save
        modules = ["simpleLOC","locPerContribution"]
        modules.each do |m|
          q = repo.part.create(name: m, state: 0)
          q.save
          repo.save

          #start test
        end
        expect(Dir.exist?(File.join(@data_path,repo.raw_repo.name,"result"))).to be false
        expect(File.exist?(File.join(@result_path,repo.raw_repo.name,repo.name+'.zip'))).to be false
        expect(Dir.exist?(File.join(@data_path,@mock_repo.raw_repo.name,"result"))).to be true
        expect(File.exist?(File.join(@result_path,@mock_repo.raw_repo.name,@mock_repo.name+'.zip'))).to be true
        AnalyseJob.perform_async("http://www.github.com/101companies/101haskell.git", "ce140df9793441693e50b94939a9281df98dff92",
                                 "repo_github_com_101companies_101haskellce140df9793441693e50b94939a9281df98dff92",
                                 400, modules)
        repo = Repo.find_by(name: "repo_github_com_101companies_101haskellce140df9793441693e50b94939a9281df98dff92")

        expect(Dir.exist?(File.join(@data_path,repo.raw_repo.name,"result"))).to be true
        expect(File.exist?(File.join(@result_path,repo.raw_repo.name,repo.name+'.zip'))).to be true
        expect(SystemSetting.find_by(name:'Actual_Size_Raw_Repo').value.to_i < SystemSetting.find_by(name:'Maximum_Size_Raw_Repo').value.to_i).to be true
        expect(Dir.exist?(File.join(@data_path,@mock_repo.raw_repo.name,"result"))).to be false
        expect(File.exist?(File.join(@result_path,@mock_repo.raw_repo.name,@mock_repo.name+'.zip'))).to be true
        expect(repo.state).to eq(2)
        expect(repo.raw_repo.state).to eq(1)
        repo.part.all.each do |m|
          expect(m.state).to eq(1)
        end
        mock_repo = Repo.find_by(name: "MockRepo")
        expect(mock_repo.state).to eq(2)
        expect(mock_repo.raw_repo.state).to eq(0)
      end
    end

    describe 'third flow, other folder exists, repo size to high' do

      before do
        max_size = create :system_setting_maximum_size_repo
        create :system_setting_maximum_size_high
        create :system_setting_actual_size
        SystemSetting.create(name:'Actual_Size_Repo',value: (max_size.value.to_i-1).to_s)
        mock_raw_repo = RawRepo.create(name:"Mock",state:1,size:50)
        @mock_repo = mock_raw_repo.repo.create(name:"MockRepo",state:2,link:"does not matter",rev:"anyone",size:max_size.value.to_i-1)
        Dir.mkdir((File.join(@data_path,@mock_repo.raw_repo.name,"result")))
        File.new(File.join(@result_path,@mock_repo.raw_repo.name,@mock_repo.name+'.zip'),'w')
      end

      it 'deletes completed folder, when not enough place on disk' do
        raw_repo = RawRepo.new(name:"repo_github_com_101companies_101haskell",state: 0,size: 400)
        raw_repo.save
        repo = raw_repo.repo.new(name: "repo_github_com_101companies_101haskellce140df9793441693e50b94939a9281df98dff92",
                                 link: "http://www.github.com/101companies/101haskell.git",
                                 rev: "ce140df9793441693e50b94939a9281df98dff92",state: 0,size: 400)
        repo.save
        modules = ["simpleLOC","locPerContribution"]
        modules.each do |m|
          q = repo.part.create(name: m, state: 0)
          q.save
          repo.save

          #start test
        end
        expect(Dir.exist?(File.join(@data_path,repo.raw_repo.name,"result"))).to be false
        expect(File.exist?(File.join(@result_path,repo.raw_repo.name,repo.name+'.zip'))).to be false
        expect(Dir.exist?(File.join(@data_path,@mock_repo.raw_repo.name,"result"))).to be true
        expect(File.exist?(File.join(@result_path,@mock_repo.raw_repo.name,@mock_repo.name+'.zip'))).to be true
        expect(Repo.count).to eq(2)
        AnalyseJob.perform_async("http://www.github.com/101companies/101haskell.git", "ce140df9793441693e50b94939a9281df98dff92",
                                 "repo_github_com_101companies_101haskellce140df9793441693e50b94939a9281df98dff92",
                                 400, modules)
        repo = Repo.find_by(name: "repo_github_com_101companies_101haskellce140df9793441693e50b94939a9281df98dff92")

        expect(Repo.count).to eq(1)
        expect(Dir.exist?(File.join(@data_path,repo.raw_repo.name,"result"))).to be true
        expect(File.exist?(File.join(@result_path,repo.raw_repo.name,repo.name+'.zip'))).to be true
        expect(SystemSetting.find_by(name:'Actual_Size_Repo').value.to_i < SystemSetting.find_by(name:'Maximum_Size_Repo').value.to_i).to be true
        expect(Dir.exist?(File.join(@data_path,@mock_repo.raw_repo.name,"result"))).to be true
        expect(File.exist?(File.join(@result_path,@mock_repo.raw_repo.name,@mock_repo.name+'.zip'))).to be false
        expect(repo.state).to eq(2)
        expect(repo.raw_repo.state).to eq(1)
        repo.part.all.each do |m|
          expect(m.state).to eq(1)
        end
        expect(Repo.count).to eq(1)
      end

    end
  end
end



