# this module includes all static methods for pages

class PageModule

  def self.contribution_array_to_string(array)
    if !array.nil?
      array.collect {|u| u}.join ', '
    else
      'No information retrieved'
    end
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
    { 'namespace' => namespace, 'title' => title }
  end

  def self.default_contribution_text(url)
    "You have created new contribution using [https://github.com Github]. " +
        "Source code for this contribution you can find [#{url} here]."
  end

  def self.search(query, namespace=nil)
    search = query[:search]
    pages = Page.none

    search.each do |item|
      if item[:text]
        text = item[:text].to_s
        if text.starts_with?('Property:')
          pages = pages.or(search_property(text))
        else
          pages = pages.or(Page.search(item[:text].to_s))
        end
      end
    end

    search.each do |item|
      if item[:query]
        if item[:query][:identifier] == 'inNamespace'
          if pages.none?
            pages = Page.all
          end
          namespace = item[:query][:value].to_s

          pages = pages.where('lower(namespace) = ?', namespace.downcase)
        end
      end
    end

    pages.order(:title)
  end

  def self.search_property(name)
    if name.blank?
      Page.where(namespace: 'Property')
    else
      if name.include?('::')
        property_name, object_name = name.split('::')

        Page.left_outer_joins(:triples).where('lower(triples.predicate) = ? and lower(triples.object) = ?', property_name.downcase, object_name.downcase).distinct
      else
        if name.include?(':')
          _, name = name.split(':')
          Page.left_outer_joins(:triples).where('lower(triples.predicate) = ?', name.downcase).distinct
        else
          like_name = Page.send(:sanitize_sql_like, name.downcase)
          like_name = "%#{like_name}%"
          Page.left_outer_joins(:triples).where('(lower(triples.predicate) = ?) or (lower(pages.title) like ? and pages.namespace = ?)', name.downcase, like_name, 'Property').distinct
        end
      end
    end
  end

  def self.search_title(query_string, namespace=nil)
    if namespace.blank?
      pages = Page.all
    else
      pages = Page.where(namespace: namespace)
    end

    found_pages = pages.search_title(query_string).order(:title)
    # nothing found -> go out
    if found_pages.nil?
      return []
    end
    found_pages
  end

  # link for using in html rendering
  # replace ' ' with '_', remove trailing spaces
  def self.url(title)
    unescape_wiki_url(title).strip.gsub(' ', '_')
  end

  def self.escape_wiki_url(full_title)
    StringUtils::upcase_first_char(wiki_to_uri(full_title))
  end

  def self.unescape_wiki_url(full_title)
    uri_to_wiki(full_title)
  end

  def self.create_page_by_full_title(full_title)
    full_title = self.unescape_wiki_url(full_title)
    namespace_and_title = self.retrieve_namespace_and_title full_title

    page = Page.new(
      title: namespace_and_title['title'],
      namespace: namespace_and_title['namespace']
    )
    page.save ? page : nil
  end

  # find page without creating
  def self.find_by_full_title(full_title)
    full_title = (self.unescape_wiki_url(full_title)).strip
    nt = self.retrieve_namespace_and_title(full_title)
    Page.where(namespace: nt['namespace'], title: nt['title']).first
  end

  def self.front_page
    page = find_by_full_title('Internal:FrontPage')
    if page.nil?
      page = Page.create!(
        namespace: 'Internal',
        title: 'FrontPage',
        raw_content: "== Headline ==\n\nFront Page"
      )
    end
    page
  end

  def self.courses_page
    page = find_by_full_title('Internal:Courses')
    if page.nil?
      page = Page.create!(
        namespace: 'Internal',
        title: 'Courses',
        raw_content: "== Headline ==\n\nCourses Page"
      )
    end
    page
  end

  def self.resources_page
    page = find_by_full_title('Internal:Resources')
    if page.nil?
      page = Page.create!(
        namespace: 'Internal',
        title: 'Resources',
        raw_content: "== Headline ==\n\nResources Page"
      )
    end
    page
  end

  def self.uncapitalize_first_char(string)
    string[0,1].downcase + string[1..-1]
  end

  private

  # [wiki] Page name string in URL
  def self.uri_to_wiki(uri)
    StringUtils::upcase_first_char(uri.tr('_', ' ').tr('#<>[]|{}', '')) if uri
  end

  # Convert a Wiki page name ("Getting there & away") to URI-safe format ("Getting_there_%26_away"),
  # taking care not to mangle slashes or colons
  # [wiki] Page name string in Wiki format
  def self.wiki_to_uri(wiki)
    wiki.to_s.split('/').map {|chunk| CGI.escape(CGI.unescape(chunk).tr(' ', '_')) }.join('/').gsub('%3A', ':') if wiki
  end

end
