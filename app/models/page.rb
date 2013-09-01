require 'media_wiki'

class Page

  # include module with static methods
  include PageModule

  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  include Mongoid::Search

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
      self.used_links = wiki_parser.internal_links.map { |link| PageModule.unescape_wiki_url link }
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

  def rewrite_backlink(backlink, old_title)
    # find page by backlink
    related_page = PageModule.find_by_full_title backlink
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
    nt = PageModule.retrieve_namespace_and_title new_title
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
    new_title = PageModule.unescape_wiki_url new_title
    # if title was changed -> rename page
    self.rename(new_title) if (new_title!=self.full_title and PageModule.find_by_full_title(new_title).nil?)
    self.save
  end

  # TODO: black magic
  def rewrite_internal_links(from, to)
    regex = /(\[\[:?)([^:\]\[]+::)?(#{Regexp.escape(from.gsub("_", " "))})(\s*)(\|[^\[\]]*)?(\]\])/i
    self.raw_content.gsub("_", " ").gsub(regex) do
      "#{$1}#{$2}#{$3[0].downcase == $3[0] ? PageModule.uncapitalize_first_char(to) : to}#{$4}#{$5}#{$6}"
    end
  end

  def nice_wiki_url
    PageModule.nice_wiki_url self.full_title
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
