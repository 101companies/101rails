class Contribution
  include Mongoid::Document
  include Mongoid::Timestamps
  field :url, type: String
  field :created_at, type: DateTime
  field :updated_at, type: DateTime
end
