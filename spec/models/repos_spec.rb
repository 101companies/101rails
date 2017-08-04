require 'rails_helper'

RSpec.describe Repo, type: :model do

  before(:each) do
    @data_path = create :system_setting_data_path
    @result_path = create :system_setting_result_path
  end

  after(:each) do
    FileUtils.remove_dir(@data_path.value)
    FileUtils.remove_dir(@result_path.value)
  end

  describe 'callback behavior' do
    it 'destroys all parts, when it gets destroyed' do
      raw_repo = RawRepo.create(name:'abc',size: 100,state:-1)
      repo = raw_repo.repo.create(name:'cde',size:100,link:'aLink',rev:'rev',state:0)
      repo.part.create(name:'fgh',state:0)
      expect(Part.count).to eql (1)
      repo.destroy
      expect(Part.count).to eql(0)
    end

  end

  end
