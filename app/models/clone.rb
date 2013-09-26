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
  field :feature_diff

  def update_status
    case self.status
    when 'new' then
      self.record_original_commit_sha
      self.status = 'in_preparation'
    when 'in_preparation', 'new' then
      url = 'https://api.github.com/repos/tschmorleiz/101haskellclones/contents/contributions'
      contributions = JSON.parse(open(url).read)
      if contributions.any?{|x| x['type'] == 'dir' and x['name'] == self.title}
        self.status = 'in_inspection'
      end
    when 'confirmed'
      self.record_clone_commit_sha
      self.create_contribution_page
      self.status = 'created'
    when 'created'
      if not self.feature_diff
        self.getDiff
      end
    end
    self.save!
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

  def getDiff
    url = 'http://worker.101companies.org/services/diffClone?clonename=' + self.title
    diff = JSON.parse(open(url).read)
    unless diff.has_key?('error')
      self.feature_diff = diff
    end
  end

  def create_contribution_page
    @page = PageModule.create_page_by_full_title("Contribution:" + self.title)
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
