# -*- encoding : utf-8 -*-

module PagesHelper
  require 'wikicloth'
  require 'pygments.rb'
  
	def parse(page)
    wiki = page.wiki
    html = page.html
    #html.gsub!('!START!', '<pre>')
    #html.gsub!('!END!','</pre>')
    wiki.internal_links.each do |link|
      html.gsub!("<a href=\"#{link}\"", "<a href=\"/#{link}\"")
    end  
    return html.html_safe
  end 
  
  def highlight(input)
    puts substring_positions('<syntaxhighlight', input)
    fragments = []
    substring_positions('<syntaxhighlight', input).each do |idx|
      e = input.index('</syntaxhighlight>', idx + 1)
      fragment = input[idx, e + 18 - idx]
      fragments.push(fragment)
    end  

    fragments.each do |fragment|
      matches = fragment.match /<syntaxhighlight lang="(\w+)">([\S\s]+)<\/syntaxhighlight>/
      lang = matches[1]
      code = matches[2]
      highlighted = Pygments.highlight(code, :lexer => lang)
      highlighted.gsub!('<pre>', '!START!')
      highlighted.gsub!('</pre>', '!END!')
      input.gsub!(fragment, highlighted)
    end  

    input
  end  

  def substring_positions(substring, string)
    string.enum_for(:scan, substring).map { $~.offset(0)[0] }
  end

  def json_escape(s)
    result = s.to_s.gsub('/', '\/')
    s.html_safe? ? result.html_safe : result
  end

  alias j json_escape
end
