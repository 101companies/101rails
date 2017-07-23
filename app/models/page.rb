class Page < ApplicationRecord
  has_one :repo_link, dependent: :destroy
  has_many :page_changes, dependent: :destroy
  has_many :page_verifications, dependent: :destroy
  has_and_belongs_to_many :users
  has_many :mappings, dependent: :destroy
  has_many :triples, autosave: true, dependent: :destroy

  validates_presence_of :title
  validates_presence_of :namespace
  validates :title, uniqueness: { scope: [:namespace] }

  before_save :before_save

  def self.unverified
    where(verified: false)
  end

  def self.by_title
    order(:title)
  end

  def self.scripts
    where(namespace: 'Script')
  end

  def self.features
    where(namespace: 'Feature')
  end

  def self.technologies
    where(namespace: 'Technology')
  end

  def self.contributions
    where(namespace: 'Contribution')
  end

  def self.languages
    where(namespace: 'Language')
  end

  def self.recently_updated
    order(updated_at: :desc)
  end

end
