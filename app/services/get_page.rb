class GetPage

  class GetPageResult < Struct.new(:page)

  end

  def execute!(full_title)
    full_title = (PageModule.unescape_wiki_url full_title).strip
    nt = PageModule.retrieve_namespace_and_title full_title
    page = Page.where(namespace: nt['namespace'], title: nt['title']).first

    GetPageResult.new(page)
  end

end
