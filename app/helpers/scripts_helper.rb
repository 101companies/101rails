module ScriptsHelper
  def fix_pdf_links(text)
    html = Nokogiri::HTML::DocumentFragment.parse(text)
    html.search('a').each do |link|
      unless link['href'].match(/^https?:\/\/.*$/)
        link['href'] = 'https://101wiki.softlang.org' + link['href']
      end
    end

    raw html.to_html
  end
end
