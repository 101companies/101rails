class Contribution

  include Mongoid::Document
  include Mongoid::Timestamps
  #include Mongoid::Paranoia
  #include Mongoid::Versioning

  field :url, type: String
  field :title, type: String
  field :description, type: String

  field :created_at, type: DateTime
  field :updated_at, type: DateTime

  field :approved, type: Boolean, :default => false

  field :folder, type: String, :default => '/'

  index({url: 1, folder: 1}, {unique: true})

  validates_presence_of :title, :url, :folder

  field :languages, type: Array
  field :technologies, type: Array
  field :concepts, type: Array
  field :features, type: Array

  field :analyzed, type: Boolean, :default => false

  belongs_to :user

  has_one :page

  attr_accessible :user_id, :created_at, :updated_at, :title, :description, :folder, :approved, :analyzed, :page_id

  def self.array_to_string(array)
    array.collect {|u| u}.join ', '
  end

end
