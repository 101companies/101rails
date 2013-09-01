require 'media_wiki'

class Page

  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  include Mongoid::Search
  include Mongoid::Versioning
  max_versions 42

  search_in :title, :namespace, :page_title_namespace, :raw_content

  field :title, type: String
  # namespace for page, need to be set
  field :namespace, type: String
  field :page_title_namespace, type: String
  field :raw_content, type: String
  field :used_links, type: Array

  # relations here
  has_and_belongs_to_many :users
  has_many :page_changes
  belongs_to :contribution

  validates_uniqueness_of :page_title_namespace
  validates_presence_of :title
  validates_presence_of :namespace

  attr_accessible :user_ids, :namespace, :title, :contribution_id

  # validate uniqueness for paar title + namespace
  before_validation do
    # prepare field namespace + title
    self.page_title_namespace = self.namespace.to_s + ':' + self.title.to_s
    # fill used_links with links in page
    # parse content and get internal links
    wiki_parser = self.create_wiki_parser
    begin
      # this produces internal_links
      wiki_parser.to_html
    rescue
      Rails.logger.info "Failed producing html for page #{self.full_title}"
    end
    # if exist internal_links -> fill used_links
    if wiki_parser.internal_links
      self.used_links = wiki_parser.internal_links.map { |link| Page.unescape_wiki_url link }
    end
  end

  def create_track(user)
    PageChange.create :page => self,
                      :raw_content => self.raw_content,
                      :title => self.title,
                      :namespace => self.namespace,
                      :user => user
  end

  def get_content_from_mediawiki
    MediaWiki::Gateway.new('http://mediawiki.101companies.org/api.php').get self.full_title
  end

  # TODO: remove after closing mediawiki
  def retrieve_old_wiki_content
    if self.raw_content.nil?
      begin
        self.raw_content = Page.gateway.get(self.full_title)
        self.save
        Rails.logger.info "Successfully retrieved content for page #{self.full_title}"
      rescue
        Rails.logger.info "Failed retrieve content for page #{self.full_title}"
      end
    else
      Rails.logger.info "Content for page #{self.full_title} already exists"
    end
  end

  # get fullname with namespace and  title
  def full_title
    # if used default namespaces -> remove from full title
    return self.title if (self.namespace == '101') or (self.namespace == 'Concept')
    # else use normal building of full url
    self.namespace + ':' + self.title
  end

  def self.match_page_score(found_page, query_string)
    # find match ignoring case
    score = found_page.full_title.downcase.index query_string.downcase
    # not found match in title, make score worst
    score = 10000 if score == nil
    # exact match -> best score (lowest)
    score = -1 if found_page.full_title.downcase == query_string.downcase
    score
  end

  def self.search(query_string)
    found_pages = Page.full_text_search query_string
    # nothing found -> go out
    return [] if found_pages.nil?
    results = []
    found_pages.each do |found_page|
      # do not show pages without content
      next if found_page.raw_content.nil?
      score = Page.match_page_score found_page, query_string
      # prepare array wit results
      results << {
          :title => found_page.full_title,
          :link  => found_page.nice_wiki_url,
          # more score -> worst result
          :score => score
      }
    end
    # sort by score and return
    results.sort_by { |a| a[:score] }
  end

  # if no namespace given
  # starts with '@' ? -> use namespace '101'
  # else -> use default namespace 'Concept'
  def self.retrieve_namespace_and_title(full_title)
    full_title_parts = full_title.split(':')
    # retrieve amount of splits
    amount_of_full_title_parts = full_title_parts.count
    # amount_of_full_title_parts == 0 or amount_of_full_title_parts > 2
    # retrieved namespace and title
    if amount_of_full_title_parts == 2
      namespace = full_title_parts[0]
      title = full_title_parts[1]
    # no namespace retrieved, amount_of_full_title_parts == 1
    else
      # then entire param is title
      title = full_title_parts[0]
      # and namespace need to be defined in this way
      # if title starts with '@' -> '101'
      # else namespace will be set to default value 'Concept'
      namespace = title[0] == "@" ?  "101" : "Concept"
    end
    # TODO: fail case
    { 'namespace' => namespace, 'title' => title }
  end

  def rewrite_backlink(backlink, old_title)
    # find page by backlink
    related_page = Page.find_by_full_title backlink
    if !related_page.nil?
      # rewrite link in page, found by backlink
      related_page.raw_content = related_page.rewrite_internal_links old_title, self.full_title
      # and save changes
      if !related_page.save
        Rails.logger.info "Failed to rewrite links for page " + related_page.full_title
      end
    else
      Rails.logger.info "Couldn't find page with link " + backlink
    end
  end

  def rename(new_title)
    # set new title to page
    nt = Page.retrieve_namespace_and_title new_title
    old_title = self.full_title
    # save old backlinsk before renaming
    old_backlinks = self.backlinks
    # rename the page
    self.namespace = nt['namespace']
    self.title = nt['title']
    # rewrite links in pages, that links to the page
    old_backlinks.each { |old_backlink| self.rewrite_backlink old_backlink, old_title }
  end

  def update_or_rename_page(new_title, content, sections)
    # if content is empty -> populate content with sections
    if content == ""
      sections.each { |s| content += s['content'] + "\n" }
    end
    self.raw_content = content
    # unescape new title to nice readable url
    new_title = Page.unescape_wiki_url new_title
    # if title was changed -> rename page
    self.rename(new_title) if (new_title!=self.full_title and Page.find_by_full_title(new_title).nil?)
    self.save
  end

  def self.uncapitalize_first_char(string)
    string[0,1].downcase + string[1..-1]
  end

  # TODO: black magic
  def rewrite_internal_links(from, to)
    regex = /(\[\[:?)([^:\]\[]+::)?(#{Regexp.escape(from.gsub("_", " "))})(\s*)(\|[^\[\]]*)?(\]\])/i
    self.raw_content.gsub("_", " ").gsub(regex) do
      "#{$1}#{$2}#{$3[0].downcase == $3[0] ? Page.uncapitalize_first_char(to) : to}#{$4}#{$5}#{$6}"
    end
  end

  # find page without creating
  def self.find_by_full_title(full_title)
    full_title = (Page.unescape_wiki_url full_title).strip
    nt = Page.retrieve_namespace_and_title full_title
    Page.where(:page_title_namespace => nt['namespace'] + ':' + nt['title']).first do |page|
      # if page was found create wiki parser
      page.create_wiki_parser if !page.nil?
    end
  end

  def self.create_page_by_full_title(full_title)
    page = Page.new
    full_title = Page.unescape_wiki_url full_title
    namespace_and_title = Page.retrieve_namespace_and_title full_title
    page.title = namespace_and_title['title']
    page.namespace = namespace_and_title['namespace']
    page.save ? page : nil
  end

  # link for using in html rendering
  # replace ' ' with '_', remove trailing spaces
  def self.nice_wiki_url title
    Page.unescape_wiki_url(title).strip.gsub(' ', '_')
  end

  def nice_wiki_url
    Page.nice_wiki_url self.full_title
  end

  def create_wiki_parser(content=nil)
    WikiCloth::Parser.context = {:ns => (MediaWiki::send :upcase_first_char, self.namespace), :title => self.title}
    WikiCloth::Parser.new(:data => ((content.nil?) ? self.raw_content : content), :noedit => true)
  end

  def self.escape_wiki_url(full_title)
    MediaWiki::send :upcase_first_char, MediaWiki::wiki_to_uri(full_title)
  end

  def self.unescape_wiki_url(full_title)
    MediaWiki::send :upcase_first_char, MediaWiki::uri_to_wiki(full_title)
  end

  def semantic_links
    self.used_links.select {|link| link.include? "::" }
  end

  def internal_links
    self.used_links
  end

  def sections
    sections = []
    self.create_wiki_parser.sections.first.children.each do |section|
      sections << { 'title' => section.title, 'content' => section.wikitext.sub(/\s+\Z/, "") }
    end
    sections
  end

  def backlinks
    Page.where(:used_links => self.full_title).map { |page| page.full_title}
  end

  def section(section)
    self.create_wiki_parser.sections.first.children.find { |s| s.full_title.downcase == section.downcase }
  end

end
