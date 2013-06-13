class Contribution

  include Mongoid::Document
  include Mongoid::Timestamps

  field :url, type: String
  field :title, type: String
  field :description, type: String

  field :created_at, type: DateTime
  field :updated_at, type: DateTime

  field :approved, type: Boolean, :default => false

  belongs_to :user

  has_one :page

  attr_accessible :user_id, :url, :created_at, :updated_at, :title, :description, :page_id, :approved

end
