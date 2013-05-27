# -*- encoding : utf-8 -*-

module PagesHelper
  require 'wikicloth'
  require 'pygments.rb'

  def parse(page)
    wiki = page.wiki
    html = page.html
    wiki.internal_links.each do |link|
      html.gsub!("<a href=\"#{link}\"", "<a href=\"/wiki/#{link}\"")
    end
    return html.html_safe
  end

  #      highlighted.gsub!('<pre>', '!START!')
  #    highlighted.gsub!('</pre>', '!END!')

  def substring_positions(substring, string)
    string.enum_for(:scan, substring).map { $~.offset(0)[0] }
  end

  def all_pages
    all_pages = Rails.cache.read('all_pages')
    if all_pages.nil?
      puts "NOT FROM CACHE"
      api_url = 'http://mediawiki.101companies.org/api.php'
      all_pages = MediaWiki::Gateway.new(api_url).list('').map {|x| x.downcase}
      Rails.cache.write('all_pages', all_pages)
    else
      puts "FROM CACHE"
    end
    all_pages
  end

  def to_wiki_links(parsed_page)
    html = parsed_page.to_html
    all_pages = self.all_pages
    parsed_page.internal_links.each do |link|
      normed_link = link.strip.downcase
      colon_split = link.split(':')
      upper_split_link = link.capitalize
      lower_split_link = link.camelize(:lower)
      if colon_split.length > 1
        upper_split_link = colon_split[0] + ':' + colon_split[1].capitalize
        lower_split_link = colon_split[0] + ':' + colon_split[1].camelize(:lower)
      end
      class_attribute = all_pages.include?(normed_link) ?  '' : 'class="missing-link"'
      html.gsub!("<a href=\"#{link}\"", "<a " + class_attribute + " href=\"/wiki/#{link}\"")
      html.gsub!("<a href=\"#{link.camelize(:lower)}\"", "<a " + class_attribute + " href=\"/wiki/#{link}\"")
      html.gsub!("<a href=\"#{upper_split_link}\"", "<a " + class_attribute + " href=\"/wiki/#{upper_split_link}\"")
      html.gsub!("<a href=\"#{lower_split_link}\"", "<a " + class_attribute + " href=\"/wiki/#{upper_split_link}\"")
    end
    return html
  end

  def json_escape(s)
    result = s.to_s.gsub('/', '\/')
    s.html_safe? ? result.html_safe : result
  end

  alias j json_escape
end
