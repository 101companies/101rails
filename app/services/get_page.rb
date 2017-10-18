class GetPage

  include SolidUseCase

  steps :get_location, :get_page

  def get_location(params)
    full_title = params[:full_title]

    full_title = PageModule.unescape_wiki_url(full_title).strip
    nt = PageModule.retrieve_namespace_and_title(full_title)

    params[:nt] = nt
    continue(params)
  end

  def get_page(params)
    nt = params[:nt]
    namespace = nt['namespace']
    title = nt['title'].downcase
    underscore_title = title.gsub(' ', '_').downcase

    if params[:time]
      page = WikiAtTimes.page_at_time(namespace, title, DateTime.parse(params[:time]))
    else
      page = Page.where(namespace: namespace).where('lower(title) in (?)', [title, underscore_title]).first
    end

    params[:page] = page
    continue(params)
  end

end
