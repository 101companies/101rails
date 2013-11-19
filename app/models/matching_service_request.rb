class MatchingServiceRequest

  include Mongoid::Document
  include Mongoid::Paranoia
  include Mongoid::Timestamps

  belongs_to :user
  belongs_to :page

  field :worker_findings, :type => String, :default => ''
  field :analysed, :type => Boolean, :default => false
  field :sent, :type => Boolean, :default => false

  validates_presence_of :page
  validates_presence_of :user

  attr_accessible  :page_id, :user_id

  # dependent of environment send result of matching service on different ip
  def backping_ip
    # for production
    return '101companies.org' if Rails.env=='production'
    # for development it's external visible ip + port 3000
    address = Socket.ip_address_list.detect  do |i|
      i.ipv4? and !i.ipv4_loopback? and !i.ipv4_multicast? and !i.ipv4_private?
    end
    address.ip_address+':3000'
  end

  # sends request on matching service
  def send_request
    success = true
    begin
      url = 'http://worker.101companies.org/services/analyzeSubmission'
      HTTParty.post url,
                    :body => {
                        :url => "https://github.com/#{self.page.contribution_url}.git",
                        :folder => self.page.contribution_folder,
                        :name => self.page.url,
                        :backping => "http://#{backping_ip}/contribute/analyze/#{self.id}"
                    }.to_json,
                    :headers => {'Content-Type' => 'application/json'}
    rescue
      success = false
    end
    self.sent = success
    self.save
    success
  end

end
