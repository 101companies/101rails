class ShowPage

  ContributorPageCreated = Class.new(StandardError)
  PageNotFoundButCreating = Class.new(StandardError)
  PageNotFound = Class.new(StandardError)
  BadLink = Class.new(StandardError)

  class ShowPageResult < Struct.new(:page, :rdf, :books, :resources, :page_edits, :contributions)
    def initialize(*attributes)
      super
      yield self
      freeze
    end
  end

  def initialize(logger, books_adapter)
    @books_adapter = books_adapter
    @logger = logger
  end

  def execute!(full_title, current_user)
    ability = Ability.new(current_user)

    page = get_page.execute!(full_title).page

    # if page doesn't exist, but it's user page -> create page and redirect
    if page.nil? && !current_user.nil? && full_title.downcase == "Contributor:#{current_user.github_name}".downcase
      PageModule.create_page_by_full_title(full_title)
      raise ContributorPageCreated.new(full_title)
    elsif page.nil? && (ability.can? :create, Page.new)
      # page not found and user can create page -> create new page by full_title
      raise PageNotFoundButCreating.new(full_title)
    elsif page.nil?
      # if no page created/found
      raise PageNotFound.new(full_title)
    end

    current_user_can_change_page = ability.can?(:manage, @page)
    if (page.namespace == 'Contributor')
      user = User.where(github_name: page.title).first
      if !user.nil?
        pages_edits = user.page_changes
        contributions = Page.where(used_links: /developedBy::Contributor:#{user.github_name}/i)
      end
    else
      contributions = []
      pages_edits = []
    end

    good_link = page.url
    if good_link != full_title
      raise BadLink.new('/wiki/'+ good_link)
    end

    triples_result  = get_triples_for_page.execute!(page)
    books_result    = get_books_for_page.execute!(page)

    ShowPageResult.new do |result|
      result.page = page
      result.books = books_result.books
      result.page_edits = pages_edits
      result.contributions = contributions
      result.rdf = triples_result.triples
      result.resources = triples_result.resources
    end
  end

  private

  attr_reader :logger
  attr_reader :books_adapter

  def get_triples_for_page
    @get_triples_for_page ||= GetTriplesForPage.new
  end

  def get_books_for_page
    @get_books_for_page ||= GetBooksForPage.new(logger, books_adapter)
  end

  def get_page
    @get_page ||= GetPage.new
  end

end
