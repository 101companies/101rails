# -*- encoding : utf-8 -*-

module PagesHelper
  require 'wikicloth'
  require 'pygments.rb'
  
	def parse(page)
    wiki = page.wiki
    html = page.html
    wiki.internal_links.each do |link|
      html.gsub!("<a href=\"#{link}\"", "<a href=\"/wiki/#{link}\"")
      #html.gsub!(":Category:","/wiki/Category:")
    end  
    return html.html_safe
  end 
  
  #      highlighted.gsub!('<pre>', '!START!')
  #    highlighted.gsub!('</pre>', '!END!')

  def substring_positions(substring, string)
    string.enum_for(:scan, substring).map { $~.offset(0)[0] }
  end

  def json_escape(s)
    result = s.to_s.gsub('/', '\/')
    s.html_safe? ? result.html_safe : result
  end

  alias j json_escape
end
