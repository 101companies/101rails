class Clone
  require 'open-uri'
  require 'json'
  include Mongoid::Document
  include Mongoid::Paranoia

  field :title, type: String
  field :original, type: String
  field :status, type: String, :default => 'new'
  field :features, type: Array
  field :minusfeatures, type: Array


  def update_status
    case self.status
    when 'new' then
      self.status = 'in_preparation'
    when 'in_preparation' then
      url = "https://api.github.com/repos/tschmorleiz/101haskell/contents/contributions"
      contributions = JSON.parse(open(url).read)
      if contributions.any?{|x| x['type'] == "dir" and x['name'] == self.title}
        self.status = 'in_inspection'
      end
    end
    self.save!
  end

end
