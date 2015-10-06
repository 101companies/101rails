class ShowPage

  ContributorPageCreated = Class.new(StandardError)
  PageNotFoundButCreating = Class.new(StandardError)
  PageNotFound = Class.new(StandardError)
  BadLink = Class.new(StandardError)

  include RdfModule

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

  def show(title, current_user)
    ability = Ability.new(current_user)
    # if no title -> set default wiki startpage '@project'
    full_title = title.nil? ? '@project' : title
    page = PageModule.find_by_full_title full_title
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

    rdf = rdf_for_page(page)

    resources = resources_for_rdf(rdf)

    rdf = rdf.select do |triple|
      node = triple[:node]
      !(node.start_with?('http://') || node.start_with?('https://'))
    end

    begin
      books = @books_adapter.get_books(page.full_title)
    rescue BooksAdapters::Adapter::BooksUnreachable
      logger.critical("book retrieval failed for #{page.full_title}")
      books = []
    end

    current_user_can_change_page = ability.can?(:manage, @page)
    if (page.namespace == 'Contributor')
      user = User.where(:github_name => page.title).first
      if !user.nil?
        pages_edits = user.page_changes
        contributions = Page.where(:used_links => /developedBy::Contributor:#{user.github_name}/i)
      end
    else
      contributions = nil
      pages_edits = nil
    end
    good_link = page.url
    if good_link != title
      raise BadLink.new('/wiki/'+ good_link)
    end

    ShowPageResult.new do |result|
      result.page = page
      result.books = books
      result.resources = resources
      result.page_edits = pages_edits
      result.contributions = contributions
      result.rdf = rdf
    end
  end

  private

  def resources_for_rdf(rdf)
    rdf.select do |triple|
      (triple[:node].start_with?('http://') || triple[:node].starts_with?('https://'))
    end
  end

  def rdf_for_page(page)
    rdf = get_rdf_json(page.full_title, true)

    rdf.sort do |x,y|
      if x[:predicate] == y[:predicate]
        x[:node] <=> y[:node]
      else
        x[:predicate] <=> y[:predicate]
      end
    end
  end

end
