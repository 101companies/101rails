class GetMultiplePages
  include SolidUseCase

  steps :normalize_titles, :retrieve_pages

  def normalize_titles(params)
    params[:nts] = params[:links].map do |link|
      link = link[0]
      full_title = (PageModule.unescape_wiki_url(link)).strip
      PageModule.retrieve_namespace_and_title(full_title)
    end

    continue(params)
  end

  def retrieve_pages(params)
    if params[:nts].length > 0
      scope = Page.where(namespace: params[:nts].first['namespace'], title: params[:nts].first['title'])
      params[:nts].drop(1).each do |nt|
        scope = scope.or(Page.where(namespace: nt['namespace'], title: nt['title']))
      end

      params[:pages] = scope.to_a.select do |page|
        !page.nil?
      end
    else
      params[:pages] = []
    end

    continue(params)
  end

end
