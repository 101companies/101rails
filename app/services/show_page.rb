class ShowPage
  include SolidUseCase

  steps(
    :create_ability,
    GetPage,
    :check_not_existing_page,
    :get_contributions_for_user,
    :fix_link,
    GetTriplesForPage,
    GetBooksForPage)

  def create_ability(params)
    current_user = params[:current_user]

    ability = Ability.new(current_user)

    params[:ability] = ability
    continue(params)
  end

  def check_not_existing_page(params)
    page          = params[:page]
    full_title    = params[:full_title]
    ability       = params[:ability]
    current_user  = params[:current_user]

    # if page doesn't exist, but it's user page -> create page and redirect
    if page.nil? && !current_user.nil? && full_title.downcase == "Contributor:#{current_user.github_name}".downcase
      PageModule.create_page_by_full_title(full_title)
      return fail(:contributor_page_created, { full_title: full_title })
    elsif page.nil? && (ability.can? :create, Page.new)
      # page not found and user can create page -> create new page by full_title
      return fail(:page_not_found_but_creating, { full_title: full_title })
    elsif page.nil?
      # if no page created/found
      return fail(:page_not_found, { full_title: full_title })
    end

    continue(params)
  end

  def get_contributions_for_user(params)
    page = params[:page]

    contributions = []
    page_edits = []

    if (page.namespace == 'Contributor')
      user = User.where(github_name: page.title).first
      if !user.nil?
        page_edits = user.page_changes
        contributions = Page.where(used_links: /developedBy::Contributor:#{user.github_name}/i)
      end
    end

    params[:contributions]  = contributions
    params[:page_edits]     = page_edits
    continue(params)
  end

  def fix_link(params)
    page        = params[:page]
    full_title  = params[:full_title]

    good_link = page.url
    if good_link != full_title
      return fail(:bad_link, { url: '/wiki/'+ good_link })
    end

    continue(params)
  end

end
