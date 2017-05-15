class LandingController < ApplicationController

  def index
    @technologies = Page.popular_technologies
  end

  def new_index
    @technologies = Page.popular_technologies
    @popular_technology_pages = Page.popular_technology_pages
    @recent_technology_pages = Page.technologies.recently_updated
    @contributions = Page.popular_contributions
    @popular_contribution_pages = Page.popular_contribution_pages
    @recent_contribution_pages = Page.contributions.recently_updated

    render layout: 'landing_new'
  end

end
