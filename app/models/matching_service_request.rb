class MatchingServiceRequest

  include Mongoid::Document
  include Mongoid::Paranoia
  include Mongoid::Timestamps

  belongs_to :user
  belongs_to :page

  attr_accessible  :page_id, :user_id

end
