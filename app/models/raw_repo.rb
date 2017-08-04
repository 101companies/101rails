class RawRepo < ApplicationRecord
require 'fileutils'

has_many :repo

  after_update do |raw_repo|
    if raw_repo.repo.all.empty? && raw_repo.state == 0
      raw_repo.destroy
    end
  end
  

  after_initialize do |raw_repo|
    resultPath = SystemSetting.find_by(name: "Result_Path").value
    dataPath = SystemSetting.find_by(name: "Data_Path").value
  if !Dir.exists?(File.join(dataPath,raw_repo.name))
    FileUtils.mkdir_p(File.join(dataPath,raw_repo.name))
  end
  if !Dir.exists?(File.join(resultPath,raw_repo.name))
    FileUtils.mkdir_p(File.join(resultPath,raw_repo.name))
  end
  end



  before_destroy do |raw_repo|
    raw_repo.repo.all.each do |repo|
      repo.destroy
    end
    resultPath = SystemSetting.find_by(name: "Result_Path").value
    dataPath = SystemSetting.find_by(name: "Data_Path").value
    if Dir.exist?(dataPath+'/'+raw_repo.name)
    FileUtils.remove_dir dataPath+'/'+raw_repo.name
    end
    if Dir.exist?(resultPath+'/'+raw_repo.name)
    FileUtils.remove_dir resultPath+'/'+raw_repo.name
      end
  end

end
