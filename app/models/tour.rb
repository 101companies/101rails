class Tour
  include Mongoid::Document
  include Mongoid::Paranoia

  field :title, type: String
  field :author, type: String
  field :pages, type: Array

  def create(title)
    self.title = title
  end

end
