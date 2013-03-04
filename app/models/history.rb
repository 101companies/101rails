require 'mongoid'

class History
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  include Mongoid::Timestamps::Updated

  field :page, type: String
  field :version, type: Integer

  belongs_to :user
  attr_accessible :user, :page, :version
end