class LandingController < ApplicationController

  def index
    stats_repo = StatsRepo.new
    page_repo = PageRepo.new

    @front_page = PageModule.front_page
    @courses_page = PageModule.courses_page

    @technologies = stats_repo.popular_technologies
    @popular_technology_pages = stats_repo.popular_pages('Technology')
    @recent_technology_pages = page_repo.recent_technologies

    @contributions = stats_repo.popular_contributions
    @popular_contribution_pages = stats_repo.popular_pages('Contribution')
    @recent_contribution_pages = page_repo.recent_contributions

    @recent_language_pages = page_repo.recent_languages
    @popular_language_pages = stats_repo.popular_pages('Language')
    @languages = stats_repo.popular_page_views('Language')

    @recent_feature_pages = page_repo.recent_features
    @popular_feature_pages = stats_repo.popular_pages('Feature')
    @features = stats_repo.popular_page_views('Feature')

    render layout: 'landing'
  end

end
