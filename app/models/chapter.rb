class Chapter < ApplicationRecord
  belongs_to :book
  has_many :mappings

  validates :url, presence: true, url: true
  validates :title, presence: true
end
