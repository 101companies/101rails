class Page < ActiveRecord::Base

  # relations here
  has_one :repo_link, dependent: :destroy
  has_many :page_changes, dependent: :destroy
  has_many :page_verifications, dependent: :destroy
  has_and_belongs_to_many :users
  has_many :mappings, dependent: :destroy
  has_many :triples, autosave: true, dependent: :destroy

  validates_presence_of :title
  validates_presence_of :namespace
  validates :title, uniqueness: { scope: [:namespace] }

  before_save :preparing_the_page
  include RdfModule

  def self.unverified
    where(verified: false)
  end

  def self.by_title
    order(:title)
  end

  def self.scripts
    where(namespace: 'Script')
  end

  def self.technologies
    where(namespace: 'Technology')
  end

  def preparing_the_page
    self.html_content = self.parse

    self.subresources = []
    self.used_links   = []

    # we hack this for now
    links = raw_content.scan /\[\[[^\]]*\]\]/
    links = links.map do |link|
      link.sub('[[', '').sub(']]', '').sub(/\|.*/, '')
    end
    links = links.map do |link|
      if link.include?('://')
        link
      else
        PageModule.unescape_wiki_url(link)
      end
    end
    self.used_links = links.flatten.uniq

    self.triples.clear
    used_links.each do |link|
      if link.include?('::')
        predicate, object = link.split('::')
        self.triples << self.triples.new(predicate: predicate, object: object)
      end
    end

    self.headline = get_headline_html_content
  end

  def self.search(text)
    like = sanitize_sql_like(text.downcase)
    like = "%#{like}%"
    where('LOWER(title) like ? or LOWER(raw_content) like ? or (namespace || \':\' || title) = ?', like, like, text).distinct
  end

  def self.search_title(text)
    like = sanitize_sql_like(text.downcase)
    like = "%#{like}%"
    where('LOWER(title) like ? or (namespace || \':\' || title) = ?', like, text).distinct
  end

  def render
    Rails.cache.fetch("#{cache_key}/content") do
      preparing_the_page
      self.parse
    end
  end

  def get_metadata_section
    self.sections.select { |section| section["title"] == 'Metadata' }.first
  end

  def get_headline_html_content
    begin
      Nokogiri::HTML(self.html_content).css('#Headline').first.parent.next_element.text.strip
    rescue
      ''
    end
  end

  def inject_triple(triple)
    # find metadata section
    metadata_section = get_metadata_section
    # not found -> create it
    if metadata_section.nil?
      self.raw_content = (self.raw_content.nil? || self.raw_content.empty?) ?
          "== Metadata ==\n* [[#{triple}]]" : self.raw_content + "\n== Metadata == \n* [[#{triple}]]"
    else
      if !metadata_section['content'].include?(triple)
        self.raw_content = self.raw_content.strip + "\n* [[#{triple}]]"
      end
    end
  end

  def decorate_headline(headline_text)
    # if string is too long -> cut to 250 chars and add '...' at the end
    popup_msg_length = 250
    (headline_text.length < popup_msg_length)  ? headline_text : "#{headline_text[0..popup_msg_length-1]} ..."
  end

  def get_last_change
    last_change = self.page_changes.order(created_at: :asc).last
    if last_change && last_change.user
      history_entry = {
          user_name: last_change.user.name,
          user_pic: last_change.user.github_avatar,
          user_email: last_change.user.email,
          created_at: last_change.created_at
      }
    else
      history_entry = {}
    end
    history_entry
  end

  def get_headline
    # assume that first <p> in html content will be shown as popup
    headline_elem = Nokogiri::HTML(self.html_content).css('p').first
    headline_elem.nil? ?
        "No headline found for page #{self.full_title}" : (decorate_headline(headline_elem.text)).strip
  end

  def parse(content = self.raw_content)
    parsed_page = self.get_parser
    parsed_page.sections.first.auto_toc = false
    html = parsed_page.to_html

    parsed_page.internal_links.each do |link|
      link = link
      nice_link = PageModule.url link

      html.gsub! "<a href=\"#{link}\"", "<a "+
          "href=\"/#{nice_link}\""
    end

    return html.html_safe
  end

  # get fullname with namespace and  title
  def full_title
    # if used default namespaces -> remove from full title
    if (self.namespace == '101') or (self.namespace == 'Concept')
      self.title
    else
      # else use normal building of full url
      self.namespace + ':' + self.title
    end
  end

  def full_underscore_title
    full_title.gsub(' ', '_')
  end

  def rewrite_backlink(related_page, old_title)
    if !related_page.nil?
      # rewrite link in page, found by backlink
      related_page.raw_content = related_page.rewrite_internal_links(old_title, self.full_title)
      # and save changes
      if !related_page.save
        Rails.logger.info "Failed to rewrite links for page " + related_page.full_title
      end
    else
      Rails.logger.info "Couldn't find page with link " + backlink
    end
  end

  def rename(new_title, page_change)
    # set new title to page
    nt = PageModule.retrieve_namespace_and_title new_title
    old_title = self.full_title
    # save old backlinsk before renaming
    old_backlinking_pages = self.backlinking_pages
    # rename the page
    self.namespace = nt['namespace']
    self.title = nt['title']
    # rewrite links in pages, that links to the page
    old_backlinking_pages.each do |old_backlinking_page|
      self.rewrite_backlink old_backlinking_page, old_title
    end
    self.rewrite_backlink self, old_title
  end

  def build_content_from_sections(sections)
    content = ""
    if !sections.nil?
      sections.each { |s| content += s['content'] + "\n" }
    end
    content
  end

  def rename_property(name, new_name)
    Page.find_each do |page|
      if page.raw_content.include?("[[#{name}")
        page.raw_content = page.raw_content.gsub("[[#{name}", "[[#{new_name}")
        page.save!
      end
    end
  end

  def update_or_rename(new_title, content, sections, user)
    page_change = PageChange.new title: self.title,
                                 namespace: self.namespace,
                                 raw_content: self.raw_content,
                                 page: self,
                                 user: user

    new_title_only = PageModule.retrieve_namespace_and_title(new_title)['title']
    if namespace == 'Property'
      rename_property(title, new_title_only)
    end

    self.raw_content = content
    # sections
    # unescape new title to nice readable url
    new_title = PageModule.unescape_wiki_url(new_title)
    # if title was changed -> rename page
    if (new_title != self.full_title and GetPage.run(full_title: new_title).value[:page].nil?)
      self.rename(new_title, page_change)
    end
    page_change.save!
    self.save!
  end

  def rewrite_internal_links(from, to)
    regex = /(\[\[:?)(~)?([^:\]\[]+::)?(#{Regexp.escape(from.gsub("_", " "))})(\s*)(\|[^\[\]]*)?(\]\])/i
    self.raw_content.gsub("_", " ").gsub(regex) do
      "#{$1}#{$2}#{$3}#{$4[0].downcase == $4[0] ? PageModule.uncapitalize_first_char(to) : to}#{$5}#{$6}#{$7}"
    end
  end

  def url
    PageModule.url(full_title)
  end

  def get_parser
    WikiCloth::Parser.context = {
      ns: StringUtils.upcase_first_char(self.namespace),
      title: self.title
    }
    parser = WikiCloth::Parser.new(data: self.raw_content, noedit: true)

    parser.to_html

    parser
  end

  def semantic_links
    self.internal_links.select {|link| link.include? "::" }
  end

  def internal_links
    used_links != nil ? self.used_links : []
  end

  def sections
    sections = []
    self.get_parser.sections.first.children.each do |section|
      content_with_subsections = section.wikitext.sub(/\s+\Z/, "")

      parsed_html = parse content_with_subsections

      sections << {
          'is_resource' => section.is_resource_section,
          'title' => section.title,
          'content' => content_with_subsections,
          'html_content' => parsed_html
      }
    end

    self.save
    sections
  end

  def backlinking_pages
    Page.where('used_links && ARRAY[?]::varchar[]', full_title)
  end

  def self.by_author(user)
    where('used_links && ARRAY[?]::varchar[]', "developedBy::Contributor:#{user.github_name}/")
  end

  def backlinks
    r = backlinking_pages.map { |page| page.full_title}
    r.uniq
  end

  def section(section)
    self.get_parser.sections.first.children.find { |s| s.full_title.downcase == section.downcase }
  end

  def self.popular_technology_pages
    Page.find_by_sql('
    SELECT * FROM pages
    inner join
      (SELECT  properties ->> \'title\' as properties_title,
        COUNT(*) AS count_all
        FROM "ahoy_events"
        WHERE "ahoy_events"."name" = \'$view\' AND
        (position(\'Technology:\' in properties ->> \'title\') <> 0)
        GROUP BY properties ->> \'title\' ORDER BY count_all desc LIMIT 5) as popular_pages
    on (pages.namespace || \':\' || pages.title) = properties_title
    order by count_all desc')
  end

  def self.recently_updated
    order(updated_at: :desc).limit(5)
  end

  def preview
    if sections.length > 0
      content = sections[0]['content']
      content = content.sub(/==.*==/, '')
      content = content[0..100]
    else
      content = ''
    end

    parser = WikiCloth::Parser.new(data: content, noedit: true)
    parser.to_html.gsub('<pre></pre>', '')
  end

  def self.popular_technologies
    Rails.cache.fetch("popular_technologies", expires_in: 12.hours) do
      technologies = Page.connection.execute('
        SELECT substring(link from 12) AS link, count(*)
        FROM pages, unnest(used_links) AS link
        WHERE substring(link from 0 for 11) = \'Technology\'
        GROUP BY 1
        order by 2 desc
      ')

      result = {}
      technologies.each do |row|
        result[row['link']] = row['count']
      end

      result
    end
  end

  def self.used_predicates
    Page.connection.execute('
      SELECT DISTINCT substr(link, 0, pos)
      FROM pages, unnest(used_links) AS link, strpos(link, \'::\') AS pos
      WHERE pos > 0
    ').values.map { |row| row[0] }.sort
  end

  def self.cached_count
    Rails.cache.fetch("page_count", expires_in: 12.hours) do
      count
    end
  end

end
