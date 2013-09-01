class PageChange

  include Mongoid::Document
  include Mongoid::Timestamps::Created

  belongs_to :page
  belongs_to :user

  field :title, type: String
  field :namespace, type: String
  field :raw_content, type: String

end
