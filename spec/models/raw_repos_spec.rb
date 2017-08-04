require 'rails_helper'
require 'fileutils'

RSpec.describe RawRepo, type: :model do

  before(:each) do
    @data_path = create :system_setting_data_path
    @result_path = create :system_setting_result_path
  end

  after(:each) do
    FileUtils.remove_dir(@data_path.value)
    FileUtils.remove_dir(@result_path.value)
  end

  describe 'callback behavior' do
    it 'creates folders after creation' do
      raw_repo = RawRepo.create(name:'abc',size: 100,state:-1)
      expect(Dir.exists?(File.join(@data_path.value,raw_repo.name))).to be true
      expect(Dir.exists?(File.join(@result_path.value,raw_repo.name))).to be true
    end

    it 'deletes folders when destroyed' do
      raw_repo = RawRepo.create(name:'abc',size: 100,state:-1)
      name = raw_repo.name
      expect(Dir.exists?(File.join(@data_path.value,raw_repo.name))).to be true
      expect(Dir.exists?(File.join(@result_path.value,raw_repo.name))).to be true
      raw_repo.destroy
      expect(Dir.exists?(File.join(@data_path.value,name))).to be false
      expect(Dir.exists?(File.join(@result_path.value,name))).to be false
    end

    it 'destroys all corresponding repos, when destroyed' do
      raw_repo = RawRepo.create(name:'abc',size: 100,state:-1)
      raw_repo.repo.create(name:'cde',size:100,link:'aLink',rev:'rev',state:0)
      expect(Repo.count).to eql(1)
      raw_repo.destroy
      expect(Repo.count).to eql(0)
    end

    it 'destroys itself, when no repos are left' do
      raw_repo = RawRepo.create(name:'abc',size: 100,state:-1)
      repo = raw_repo.repo.create(name:'cde',size:100,link:'aLink',rev:'rev',state:0)
      expect(RawRepo.count).to eql(1)
      repo.destroy
      raw_repo.state = 0
      raw_repo.save
      expect(RawRepo.count).to eql(0)
    end
  end
end
