module ContributionModule

  def self.contribution_array_to_string(array)
    if !array.nil?
      array.collect {|u| u}.join ', '
    else
      'No information retrieved'
    end
  end

  def analyse_request
    success = true
    # TODO: check fail case
    #begin
      HTTParty.post 'http://worker.101companies.org/services/analyzeSubmission',
                        :body => {
                            :url => self.contribution_url+'.git',
                            :folder => self.contribution_folder,
                            :name => PageModule.nice_wiki_url(self.title),
                            #TODO: replace before commit
                            :backping => "http://141.26.94.157:3000/contribute/analyze/#{self.id}"
                            #:backping => "http://101companies.org/contribute/analyze/#{@page.id}"
                        }.to_json,
                        :headers => {'Content-Type' => 'application/json'}
    #rescue
    #  success = false
    #end
    success
  end

end

