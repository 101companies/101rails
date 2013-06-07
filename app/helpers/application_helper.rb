module ApplicationHelper
  def flash_class(level)
    case level
      when :alert then level = "error"
    end
    level
  end
end
