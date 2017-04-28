class Book < ApplicationRecord
  has_many :chapters

  validates :name, presence: true
  validates :url, presence: true, url: true

end
