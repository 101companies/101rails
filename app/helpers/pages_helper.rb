module PagesHelper

  def parse(page)
    wiki = page.wiki
    html = page.html
    wiki.internal_links.each do |link|
      html.gsub!("<a href=\"#{link}\"", "<a href=\"/wiki/#{link}\"")
    end
    return html.html_safe
  end

  def all_links
    Page.all.map { |p| p.full_title}
  end

  # define links pointing to pages without content
  def to_wiki_links(parsed_page)
    # get html
    html = parsed_page.to_html
    all_page_uris = all_links
    parsed_page.internal_links.each do |link|
      # nice link -> link-uri converted to readable words
      nice_link = Page.unescape_wiki_url link
      # if in list of all pages doesn't exists link -> define css class missing-link
      class_attribute = all_page_uris.include?(nice_link) ?  '' : 'class="missing-link"'
      html.gsub!("<a href=\"#{link}\"", "<a " + class_attribute + " href=\"/wiki/#{nice_link}\"")
      html.gsub!("<a href=\"#{link.camelize(:lower)}\"", "<a " + class_attribute + " href=\"/wiki/#{nice_link}\"")
    end
    return html
  end

  def json_escape(s)
    result = s.to_s.gsub('/', '\/')
    s.html_safe? ? result.html_safe : result
  end

  alias j json_escape

end
