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
  field :original_commit_sha, type: String
  field :clone_commit_sha, type: String
  field :last_checked_original_sha, type: String
  field :last_checked_clone_sha, type: String
  field :feature_diff
  field :propagation

  def update_status
    case self.status

    when 'new' then
      self.record_original_commit_sha
      self.status = 'in_preparation'

    when 'in_preparation', 'new' then
     self.check_creation

    when 'confirmed'
      self.record_clone_commit_sha
      self.create_contribution_page
      self.status = 'created'

    when 'created'
      if self.feature_diff.nil?
        self.get_diff
      end
      if self.propagation == ''
        self.propagation = nil
      end
      if not self.propagation.nil? and not self.propagation['response'].nil?
        self.process_response
        self.get_propagations
      end
      if self.propagation.nil?
        self.get_propagations
      end
      if not self.propagation.nil? and self.last_checked_clone_sha.nil?
        self.get_last_checked_clone_sha
      end
    end

    self.save
  end

  def check_creation
   url = 'https://api.github.com/repos/tschmorleiz/101haskellclones/contents/contributions'
   contributions = JSON.parse(open(url).read)
   if contributions.any?{|x| x['type'] == 'dir' and x['name'] == self.title}
    self.status = 'in_inspection'
   end
  end

  def record_commit_sha(url)
    url = 'https://api.github.com/repos/' + url
    return JSON.parse(open(url).read)[0]['sha']
  end

  def record_original_commit_sha
    url = '101companies/101haskell/commits'
    self.original_commit_sha = self.record_commit_sha(url)
  end

  def record_clone_commit_sha
    url = 'tschmorleiz/101haskellclones/commits?path=contributions/' + self.title
    self.clone_commit_sha = self.record_commit_sha(url)
  end

  def features_to_wikitext_triples
    wikitext_triples = self.features.map {|f| "* [[implements::Feature:" + f + "]]"}
    return wikitext_triples.join("\n")
  end

  def get_diff
    url = 'http://worker.101companies.org/services/diffClone?clonename=' + self.title
    diff = JSON.parse(open(url).read)
    unless diff.has_key?('error')
      self.feature_diff = diff
    end
  end

  def get_propagations
    url = 'http://worker.101companies.org/data/dumps/clonehistory.json'
    propagations = JSON.parse(open(url).read)
    if propagations.has_key?(self.title)
      candidate = propagations[self.title]['inspection']
      if candidate
        if not self.propagation or candidate['branch'] != self.propagation['branch']
          self.propagation = candidate
        end
      end
    end
  end

  def process_response
    self.last_checked_original_sha = self.propagation['commits'][0]
    self.last_checked_clone_sha = nil
  end

  def get_last_checked_clone_sha
    url = 'http://worker.101companies.org/data/dumps/clonehistory.json'
    propagations = JSON.parse(open(url).read)
    if propagations[self.title].has_key?('inspection')
      inspection = propagations[self.title]['inspection']
      if inspection.has_key?('merge_commit')
        self.last_checked_clone_sha = inspection['merge_commit']
      end
    end
  end

  def create_contribution_page
    full_title = "Contribution:" + self.title
    @page = PageModule.create_page_by_full_title(full_title)
    if @page.nil?
      @page = PageModule.find_by_full_title(full_title)
    end
    content = "== Headline ==\nA variant of [[Contribution:" + self.original + "]].\n\n"
    content += "== Metadata ==\n" + self.features_to_wikitext_triples
    content += "\n* [[cloneOf::Contribution:" + self.original + "]]"
    content += "\n* [[instanceOf::Namespace:Contribution]]"
    @page.raw_content = content
    @page.save
  end

  def self.trigger_preparation
    EM.run do
      triggerurl = 'http://worker.101companies.org/services/triggerCloneCreation'
      http = EM::HttpRequest.new(triggerurl).get
      http.errback do
        EM.stop
      end
      http.callback do
        EM.stop
      end
    end
  end

end
