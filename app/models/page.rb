require 'media_wiki'

class Page

  include Mongoid::Document
  include Mongoid::Timestamps

  field :title, type: String
  # namespace for page, need to be set
  field :namespace, type: String, :default => ""

  # relations here
  has_and_belongs_to_many :users
  belongs_to :contribution

  attr_accessible :user_ids, :namespace, :title, :created_at, :updated_at, :contribution_id

  # uri for using mediawiki gateway
  @base_uri = 'http://mediawiki.101companies.org/api.php'

  # get fullname with namespace and  title
  def full_title
    # if used default namespaces -> remove from full title
    if (self.namespace == '101') or (self.namespace == 'Concept')
      return self.title
    end
    # else use normal building of full url
    self.namespace + ':' + self.title
  end

  # get authorship of old wiki users for page
  def retrieve_old_wiki_users
    begin
      # else retrieve users from old wiki
      a = Mechanize.new
      # get all authors of page in json format, 500 last revisions
      authors= a.get @base_uri +
                         "?action=query&prop=revisions&titles=#{self.full_title}&rvprop=user&rvlimit=500&format=json"
      # parse json
      authors = JSON.parse authors.body
      # retrieve body of data from response => all revisions
      authors = authors['query']['pages'].first[1]['revisions'].to_a.uniq
      # go through authors and assign to page
      authors.each do |author|
        old_wiki_user = OldWikiUser.where(:name => author['user']).first
        # if matched user from old wiki
        if !old_wiki_user.nil?
          # and we have matching user from new wiki
          if !old_wiki_user.user.nil?
            # add him to authors of this page
            self.users << old_wiki_user.user
          end
        end
      end
    rescue
    end
  end

  # if no namespace given
  # starts with '@' ? -> use namespace '101'
  # else -> use default namespace 'Concept'
  def self.retrieve_namespace_and_title(full_title)
    full_title_parts = full_title.split(':')
    # retrieve amount of splits
    amount_of_full_title_parts = full_title_parts.count
    # TODO: crazy case:
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

  # static method for getting page if already exist in db
  # or creating using mediawiki api
  def self.find_or_create_page(full_title)
    # retrieve namespace and title from page full_title
    namespace_and_title = retrieve_namespace_and_title full_title

    # find page from db
    page = Page.where(:title => namespace_and_title['title'], :namespace => namespace_and_title['namespace']).first

    if page.nil?
      page = Page.new
      page.namespace = namespace_and_title['namespace']
      page.title = namespace_and_title['title']
      # retrieve content for page from wiki
      page.retrieve_content_from_wiki
      # retrieve user info
      page.retrieve_old_wiki_users
      # save page at end of changes
      page.save
    end
    # TODO: change, very dirty!, dup
    page.instance_eval { class << self; self end }.send(:attr_accessor, "wiki")
    page.wiki = WikiCloth::Parser.new(:data => page.content, :noedit => true)
    # set namespace for work with wiki
    WikiCloth::Parser.context = page.namespace
    # return page at the end
    page
  end

  def content
    # retrieve content from cache
    content = Rails.cache.read(self.full_title)
    # if no content stored in cache
    if (content == nil)
      # get content
      content = Page.gateway.get(self.full_title)
      # and store content in cache
      Rails.cache.write(self.full_title, content)
    end
    return content
  end

  def retrieve_content_from_wiki
    # TODO: change, very dirty!, dup
    self.instance_eval { class << self; self end }.send(:attr_accessor, "wiki")
    self.wiki = WikiCloth::Parser.new(:data => self.content, :noedit => true)
    @html = Rails.cache.read(self.full_title + "_html")
    # if not found in cache
    if (@html == nil)
      # get html markup for page
      @html = @wiki.to_html
      # rewrite all wiki links adding prefix "wiki" to links
      @wiki.internal_links.each do |link|
        @html.gsub!("<a href=\"#{link}\"", "<a href=\"/wiki/#{link}\"")
      end
      Rails.cache.write(self.title + "_html", @html)
    end
  end

  def rewrite_link_name(from, to)
    from[0].downcase == from[0] ? to[0,1].downcase + to[1..-1] : to
  end

  def rewrite_internal_links(from, to)
    regex = /(\[\[:?)([^:\]\[]+::)?(#{Regexp.escape(from.gsub("_", " "))})(\s*)(\|[^\[\]]+)?(\]\])/i
    new_content = content.gsub("_", " ").gsub(regex) do |link|
      "#{$1}#{$2}#{rewrite_link_name($3, to)}#{$4}#{$5}#{$6}"
    end
    change(new_content)
  end

  def rewrite_backlinks(to)
    backlinks.each do |backlink|
      bl_page = Page.new.create(backlink)
      bl_page.rewrite_internal_links(self.full_title, to)
    end
  end

  def rename(to)
    new_page = Page.find_or_create_page(to)
    new_page.change(content)
    rewrite_backlinks(to)
    new_page.retrieve_namespace_and_title to
    new_page.save
  end

  def add_triple_link(content, triple)
    content.sub(/\s+\Z/, '') + "\n* " + '[[' + triple + ']]'
  end

  def remove_namespace_triples(content)
    content.sub(/\*\s*\[\[instanceOf::Namespace:([^\[\]]+)\]\]/, '')
  end

  def add_namespace_triple(content)
    parsed_page = WikiCloth::Parser.new(:data => self.content, :noedit => true)
    parsed_page.to_html
    namespace_triple = 'instanceOf::Namespace:' + namespace
    unless parsed_page.internal_links.include?(namespace_triple)
      metaheader = '== Metadata =='
      unless content.gsub(/\s+/, '').include?(metaheader.gsub(/\s+/, ''))
        content.concat("\n" + metaheader)
      end
      content = add_triple_link(content, namespace_triple)
    end
    content
  end

  def change(content)
    content = remove_namespace_triples(content)
    content = add_namespace_triple(content)
    Rails.cache.write(self.title, content)
    Rails.cache.delete(self.title + "_html")
    gateway_and_login.edit(self.title, content)
  end

  def delete
    # delete wiki page
    gateway_and_login.delete(self.full_title)
    # delete cache
    Rails.cache.delete(self.full_title + "_html")
    Rails.cache.delete(self.full_title)
    # TODO: remove from db page entity
  end

  def semantic_links
    # TODO: to_html -> some fix for producing non-empty internal_links, remove later
    self.wiki.to_html
    self.wiki.internal_links.find_all{|item| item.include? "::" }
  end

  def internal_links
    # TODO: to_html -> some fix for producing non-empty internal_links, remove later
    self.wiki.to_html
    self.wiki.internal_links
  end

  def sections
    sec = []
    self.wiki.sections.first.children.each do |s|
      sec.push({'title' => s.title, 'content' => s.wikitext.sub(/\s+\Z/, "")})
    end
    sec
  end

  def backlinks
    Page.gateway.backlinks(self.full_title).map { |e| e.gsub(" ", "_")  }
  end

  def section(section)
    self.wiki.sections.first.children.find { |s| s.full_title.downcase == section.downcase }
  end

  def self.gateway_and_login
    gw = gateway
    gw.login(ENV['WIKIUSER'], ENV['WIKIPASSWORD'])
    return gw
  end

  def self.gateway
    if @gateway == nil
      @gateway = MediaWiki::Gateway.new(@base_uri)
    end
    @gateway
  end

end
