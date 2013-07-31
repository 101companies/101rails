class TourPage
  include Mongoid::Document
  include Mongoid::Audit::Trackable
  include Mongoid::Paranoia

  field :name, type: String
  field :sections, type: Array

  track_history :on => [:name, :sections]

  def create(name)
    self.title = name
  end

end
