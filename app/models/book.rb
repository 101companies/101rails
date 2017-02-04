class Book < ApplicationRecord
  has_many :mappings
  has_many :chapters

  validates_presence_of :name
  validates_presence_of :url
end
