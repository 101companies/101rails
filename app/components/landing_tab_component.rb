class LandingTabComponent < ViewComponent::Base
  def initialize(popular_pages:, recent_pages:, tagcloud_data:, tag_class_name:)
    @popular_pages = popular_pages
    @recent_pages = recent_pages
    @tagcloud_data = tagcloud_data
    @tag_class_name = tag_class_name
  end
end
