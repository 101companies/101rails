class GetPage

  include SolidUseCase

  steps :get_location, :get_page

  def get_location(params)
    full_title = params[:full_title]

    full_title = (PageModule.unescape_wiki_url(full_title)).strip
    nt = PageModule.retrieve_namespace_and_title(full_title)

    params[:nt] = nt
    continue(params)
  end

  def get_page(params)
    nt = params[:nt]

    page = Page.where(namespace: nt['namespace'], title: nt['title']).first

    params[:page] = page
    continue(params)
  end

end
