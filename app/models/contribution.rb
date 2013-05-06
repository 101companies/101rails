class Contribution

  include Mongoid::Document
  include Mongoid::Timestamps

  field :url, type: String
  index({ url: 1 }, { unique: true, background: true })

  field :title, type: String
  index({ title: 1 }, { unique: true, background: true })

  field :description, type: String
  index({ description: 1 }, { unique: true, background: true })

  field :created_at, type: DateTime
  field :updated_at, type: DateTime

  field :approved, type: Boolean, :default => false

  belongs_to :user

  has_one :page

  attr_accessible :user, :url, :created_at, :updated_at, :title, :description, :page

end
