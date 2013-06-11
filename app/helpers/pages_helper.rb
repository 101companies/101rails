module PagesHelper

  def all_links
    Page.all.map { |p| p.full_title}
  end

  def json_escape(s)
    result = s.to_s.gsub('/', '\/')
    s.html_safe? ? result.html_safe : result
  end

  alias j json_escape

end
