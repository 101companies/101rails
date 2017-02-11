module ApplicationHelper

  def bootstrap_class_for(flash_type)
    case flash_type.to_sym
      when :success
        "alert-success"
      when :error
        "alert-error"
      when :alert
        "alert-block"
      when :notice
        "alert-info"
      else
        flash_type.to_s
    end
  end

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

  def get_user_repos
    begin
      current_user.get_repos
    rescue
      []
    end
  end

  alias j json_escape

end
