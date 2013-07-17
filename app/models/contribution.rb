class Contribution

  include Mongoid::Document
  include Mongoid::Timestamps
  #include Mongoid::Audit::Trackable
  include Mongoid::Paranoia

  field :url, type: String
  field :title, type: String
  field :description, type: String
  field :folder, type: String, :default => '/'

  field :analyzed, type: Boolean, :default => false
  field :approved, type: Boolean, :default => false

  field :languages, type: Array
  field :technologies, type: Array
  field :concepts, type: Array
  field :features, type: Array

  belongs_to :user
  has_one :page

  index({url: 1, folder: 1}, {unique: true})
  index({title: 1}, {unique: true})

  validates_presence_of :title, :url, :folder

  attr_accessible :user_id, :title, :description, :url, :folder, :approved, :analyzed, :page_id

  def self.array_to_string(array)
    if !array.nil?
      array.collect {|u| u}.join ', '
    else
      'No information retrieved'
    end
  end

end
