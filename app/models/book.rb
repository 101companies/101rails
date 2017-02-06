class Book < ApplicationRecord
  has_many :chapters

  validates :name, presence: true, unique: true
  validates_presence_of :url

end
