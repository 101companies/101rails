module ContributionModule

  def self.contribution_array_to_string(array)
    if !array.nil?
      array.collect {|u| u}.join ', '
    else
      'No information retrieved'
    end
  end

  def analyze_request
    success = true
    begin
      url = 'http://worker.101companies.org/services/analyzeSubmission'
      HTTParty.post url,
        :body => {
            :url => self.contribution_url+'.git',
            :folder => self.contribution_folder,
            :name => PageModule.nice_wiki_url(self.title),
            :backping => "http://101companies.org/contribute/analyze/#{self.id}"
        }.to_json,
        :headers => {'Content-Type' => 'application/json'}
    rescue
      success = false
    end
    success
  end

end

