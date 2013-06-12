module ApplicationHelper
  def flash_class(level)
    case level
      when :alert then level = "error"
    end
    level
  end

  def json_escape(s)
    result = s.to_s.gsub('/', '\/')
    s.html_safe? ? result.html_safe : result
  end

  alias j json_escape

end
