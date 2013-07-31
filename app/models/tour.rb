class Tour
  include Mongoid::Document
  include Mongoid::Audit::Trackable
  include Mongoid::Paranoia

  track_history :on => [:title, :author, :pages]

  field :title, type: String
  field :author, type: String
  field :pages, type: Array

  def create(title)
    self.title = title
  end

end
