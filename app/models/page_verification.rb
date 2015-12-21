class PageVerification
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :user
  belongs_to :page

  field :from_state,  type: Boolean, default: false
  field :to_state,    type: Boolean, default: true

end
