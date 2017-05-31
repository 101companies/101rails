class LandingController < ApplicationController

  def index
    @front_page = PageModule.front_page
    @courses_page = PageModule.courses_page

    @technologies = Page.popular_technologies
    @popular_technology_pages = Page.popular_pages('Technology')
    @recent_technology_pages = Page.technologies.recently_updated

    @contributions = Page.popular_contributions
    @popular_contribution_pages = Page.popular_pages('Contribution')
    @recent_contribution_pages = Page.contributions.recently_updated

    @recent_language_pages = Page.languages.recently_updated
    @popular_language_pages = Page.popular_pages('Language')
    @languages = Page.popular_page_views('Language')

    @recent_feature_pages = Page.features.recently_updated
    @popular_feature_pages = Page.popular_pages('Feature')
    @features = Page.popular_page_views('Feature')

    render layout: 'landing'
  end

end
