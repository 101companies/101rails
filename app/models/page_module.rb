# this module includes all static methods for pages
# it was removed to make page model less fat

class PageModule
  require 'media_wiki'

  def self.match_page_score(found_page, query_string)
    # find match ignoring case
    score = found_page.full_title.downcase.index query_string.downcase
    # not found match in title, make score worst
    score = 10000 if score == nil
    # exact match -> best score (lowest)
    score = -1 if found_page.full_title.downcase == query_string.downcase
    score
  end

  def self.contribution_array_to_string(array)
    if !array.nil?
      array.collect {|u| u}.join ', '
    else
      'No information retrieved'
    end
  end

  def self.backup
    Rails.logger.info 'Started exporting pages to backup'
    Page.all.each do |p|
      File.open("#{Rails.root}/wiki_content/#{CGI::escape(p.full_title)}", 'w+') { |file| file.write(p.raw_content) }
    end
    Rails.logger.info 'Ended exporting pages to backup'
  end

  def self.apply_backup
    Rails.logger.info 'Started exporting pages from backup'
    folder = "#{Rails.root}/wiki_content/"
    Dir.foreach(folder) do |fname|
      next if fname[0] == '.'
      full_title = CGI::unescape fname
      page = PageModule.find_by_full_title full_title
      page = PageModule.create_page_by_full_title full_title if page.nil?
      if page.nil?
        Rails.logger.error "Couldn't create page #{full_title}"
        next
      end
      page.raw_content = File.read(folder+fname)
      page.save!
    end
    Rails.logger.info 'Ended exporting pages from backup'
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
      # TODO: case crazy
    else
      # then entire param is title
      title = full_title_parts[0]
      # and namespace need to be defined in this way
      # if title starts with '@' -> '101'
      # else namespace will be set to default value 'Concept'
      namespace = title[0] == "@" ?  "101" : "Concept"
    end
    { 'namespace' => namespace, 'title' => title }
  end

  def self.default_contribution_text(url)
    "You have created new contribution using [https://github.com Github]. " +
        "Source code for this contribution you can find [#{url} here]. " +
        "Please replace this text with something more meaningful."
  end

  def self.search(query_string)
    begin
      found_pages = Page.full_text_search query_string
    rescue
      found_pages = nil
    end
    # nothing found -> go out
    return [] if found_pages.nil?
    results = []
    found_pages.each do |found_page|
      # do not show pages without content
      next if found_page.raw_content.nil?
      score = PageModule.match_page_score found_page, query_string
      # prepare array wit results
      results << {
          :title => found_page.full_title,
          :link  => found_page.url,
          # more score -> worst result
          :score => score
      }
    end
    # sort by score and return
    results.sort_by { |a| a[:score] }
  end

  # link for using in html rendering
  # replace ' ' with '_', remove trailing spaces
  def self.url title
    self.unescape_wiki_url(title).strip.gsub(' ', '_')
  end

  def self.escape_wiki_url(full_title)
    # TODO: exception?
    MediaWiki::send :upcase_first_char, MediaWiki::wiki_to_uri(full_title)
  end

  def self.unescape_wiki_url(full_title)
    MediaWiki::send :upcase_first_char, MediaWiki::uri_to_wiki(full_title)
  end

  def self.create_page_by_full_title(full_title)
    page = Page.new
    full_title = self.unescape_wiki_url full_title
    namespace_and_title = self.retrieve_namespace_and_title full_title
    page.title = namespace_and_title['title']
    page.namespace = namespace_and_title['namespace']
    page.save ? page : nil
  end

  # find page without creating
  def self.find_by_full_title(full_title)
    full_title = (self.unescape_wiki_url full_title).strip
    nt = self.retrieve_namespace_and_title full_title
    Page.where(:page_title_namespace => nt['namespace'] + ':' + nt['title']).first do |page|
      # if page was found create wiki parser
      page.create_wiki_parser if !page.nil?
    end
  end

  def self.uncapitalize_first_char(string)
    string[0,1].downcase + string[1..-1]
  end

end
