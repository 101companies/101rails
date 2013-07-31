require 'media_wiki'

class Page

  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  include Mongoid::Audit::Trackable
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
  belongs_to :contribution

  # validate uniqueness for paar title + namespace
  before_validation :page_title_namespace_proc
  def page_title_namespace_proc
    # prepare paar namespace + tile
    self.page_title_namespace = self.namespace.to_s + ':' + self.title.to_s
    # fill with links
    self.used_links = []
    self.internal_links.each do |link|
      self.used_links << (Page.unescape_wiki_url link)
    end
  end

  validates_uniqueness_of :page_title_namespace
  validates_presence_of :title
  validates_presence_of :namespace

  validates_uniqueness_of :page_title_namespace_proc

  track_history :on => [:title, :namespace, :raw_content, :user_ids, :contribution_id]

  attr_accessible :user_ids, :namespace, :title, :contribution_id

  # uri for using mediawiki gateway
  @@base_uri = 'http://mediawiki.101companies.org/api.php'

  # get fullname with namespace and  title
  def full_title
    # if used default namespaces -> remove from full title
    if (self.namespace == '101') or (self.namespace == 'Concept')
      return self.title
    end
    # else use normal building of full url
    self.namespace + ':' + self.title
  end

  def self.search(query_string)
    found_pages = Page.full_text_search query_string
    # save results here
    results = []
    # find occurrence of searched string in title
    if !found_pages.nil?
      found_pages.each do |found_page|
        # do not show pages without content
        if found_page.raw_content.nil?
          next
        end
        # find match ignoring case
        score = found_page.full_title.downcase.index query_string.downcase
        # not found match in title
        if score == nil
          # big value for search
          score = 10000
        end
        # exact match -> best score (lowest)
        if found_page.full_title.downcase == query_string.downcase
          score = -1
        end
        # prepare array wit results
        results << {
            :title => found_page.full_title,
            :link  => found_page.nice_wiki_url,
            # more score -> worst result
            :score => score
        }
      end
    end
    # sort by score and return
    return results.sort_by { |a| a[:score] }
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
      if title[0] == "@"
        namespace = "101"
        # else namespace will be set to default value 'Concept'
      else
        namespace = "Concept"
      end
    end
    # return hash with namespace and title
    return {
      'namespace' => namespace,
      'title' => title
    }
  end

  def update_or_rename_page(new_title, content, sections)
    # if content is empty -> populate content with sections
    if content == ""
      sections.each { |s| content += s['content'] + "\n" }
    end
    # save new content
    self.raw_content = content
    # unescape new title to nice readable url
    new_title = Page.unescape_wiki_url new_title
    # if title was changes -> rename page
    if new_title!=self.full_title
      # set new title to page
      nt = Page.retrieve_namespace_and_title new_title
      self.namespace = nt['namespace']
      self.title = nt['title']
      # rewrite backlinks
      # TODO: rewrite clearer
      Page.gateway.backlinks(Page.escape_wiki_url old_title).each do |backlink|
        related_page = Page.find_by_full_title Page.unescape_wiki_url backlink
        if !related_page.nil?
          related_page.rewrite_internal_links old_title, self.full_title
        else
          Rails.logger.info "Couldn't find page with link " + backlink
        end
      end
    end
    # save the changes to page
    self.save
  end

  # find page without creating
  def self.find_by_full_title(full_title)
    nt = Page.retrieve_namespace_and_title full_title
    page = Page.where(:page_title_namespace => nt['namespace'] + ':' + nt['title']).first
    # if page was found create wiki parser
    if !page.nil?
      page.create_wiki_parser
    end
    return page
  end

  # link for using in html rendering
  # replace ' ' with '_'
  # remove trailing spaces
  def self.nice_wiki_url title
    return (Page.unescape_wiki_url title).strip.gsub(' ', '_')
  end

  def nice_wiki_url
    return Page.nice_wiki_url self.full_title
  end

  def create_wiki_parser
    # TODO: change, very dirty!, dup
    self.instance_eval { class << self; self end }.send(:attr_accessor, "wiki")
    self.prepare_wiki_context
    self.wiki = WikiCloth::Parser.new(:data => self.raw_content, :noedit => true)
    return self.wiki
  end

  def prepare_wiki_context
    WikiCloth::Parser.context = {:ns => (MediaWiki::send :upcase_first_char, self.namespace), :title => self.title}
  end

  def rewrite_link_name(from, to)
    from[0].downcase == from[0] ? to[0,1].downcase + to[1..-1] : to
  end

  def rewrite_internal_links(from, to)
    regex = /(\[\[:?)([^:\]\[]+::)?(#{Regexp.escape(from.gsub("_", " "))})(\s*)(\|[^\[\]]*)?(\]\])/i
    new_content = self.raw_content.gsub("_", " ").gsub(regex) do |link|
      "#{$1}#{$2}#{rewrite_link_name($3, to)}#{$4}#{$5}#{$6}"
    end
    update_wiki_content new_content
  end

  def self.escape_wiki_url(full_title)
    MediaWiki::send :upcase_first_char, (MediaWiki::wiki_to_uri full_title)
  end

  def self.unescape_wiki_url(full_title)
    MediaWiki::send :upcase_first_char, (MediaWiki::uri_to_wiki full_title)
  end

  def semantic_links
    self.used_links.map {|link| link.include? "::" }
  end

  def internal_links
    self.used_links
  end

  def sections
    sec = []
    self.create_wiki_parser.sections.first.children.each do |s|
      sec.push({'title' => s.title, 'content' => s.wikitext.sub(/\s+\Z/, "")})
    end
    sec
  end

  def backlinks
    Page.where(:used_links => self.full_title).map { |page| page.full_title}
  end

  def section(section)
    self.wiki.sections.first.children.find { |s| s.full_title.downcase == section.downcase }
  end

end
