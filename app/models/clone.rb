class Clone
  require 'open-uri'
  require 'json'
  require 'eventmachine'
  require 'em-http'
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
    when 'in_preparation', 'new' then
      url = 'https://api.github.com/repos/tschmorleiz/101haskell/contents/contributions'
      contributions = JSON.parse(open(url).read)
      if contributions.any?{|x| x['type'] == 'dir' and x['name'] == self.title}
        self.status = 'in_inspection'
      end
    when 'confirmed', 'new'
    end
    self.save!
  end


  def create_contribution_page

  end

  def self.trigger_preparation
    EM.run do
      triggerurl = 'http://worker.101companies.org/services/triggerCloneCreation'
      http = EM::HttpRequest.new(triggerurl).get
      http.errback do
        puts "Connection error: #{http.error}"
        EM.stop
      end
      http.callback do
        if http.response_header.status == 200
          puts "Success!"
          puts http.response
        else
          puts "Unexpected status code: #{http.response_header.status}"
        end
        EM.stop
      end
    end
  end

end
