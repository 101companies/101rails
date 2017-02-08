class Book < ApplicationRecord
  has_many :chapters

  # validates :name, presence: true, uniqueness: true
  validates_presence_of :url

end
