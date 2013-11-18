class MatchingServiceRequest

  include Mongoid::Document
  include Mongoid::Paranoia
  include Mongoid::Timestamps

  belongs_to :user
  belongs_to :page

  field :worker_findings, type: String, :default => ''
  field :analysed, type: Boolean, :default => false
  field :sent, type: Boolean, :default => false

  attr_accessible  :page_id, :user_id

  def send_request
    success = true
    begin
      url = 'http://worker.101companies.org/services/analyzeSubmission'
      HTTParty.post url,
                    :body => {
                        :url => "https://github.com/#{self.page.contribution_url}.git",
                        :folder => self.page.contribution_folder,
                        :name => self.page.url,
                        :backping => "http://141.26.88.4:3000/contribute/analyze/#{self.id}"
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
