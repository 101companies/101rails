class Repo < ApplicationRecord
  require 'fileutils'
  has_many :part
  belongs_to :raw_repo

  validates :link, :rev, :state, presence: true
  validates_associated :raw_repo, :part
  validates :name, presence:true, uniqueness: true

  def to_param
    name
  end

  before_destroy do |repo|
    resultPath = SystemSetting.find_by(name: "Result_Path").value
    repo.part.all.each do |modul|
      modul.destroy
    end
    raw_repo_name = repo.raw_repo.name
    if Dir.exists? File.join(resultPath,raw_repo_name,repo.name)
    FileUtils.remove_dir File.join(resultPath,raw_repo_name,repo.name)
    end
    if File.exists?File.join(resultPath,raw_repo_name,repo.name+'.zip')
    FileUtils.rm File.join(resultPath,raw_repo_name,repo.name+'.zip')
    end
  end

end
