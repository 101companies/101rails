require 'mongoid'

class History
  include Mongoid::Document
  include Mongoid::Timestamps

  field :page, type: String
  field :version, type: Integer

  belongs_to :user
  attr_accessible :user, :page, :version
end
