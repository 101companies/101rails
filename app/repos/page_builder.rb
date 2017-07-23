module PageBuilder

  private

  def build_page_entity(ar_page)
    triples = ar_page.triples.map { |triple| build_triple(triple) }
    headline = ar_page.headline
    if headline.blank?
      headline = nil
    end
    PageEntity.new(
      id: ar_page.id,
      title: ar_page.title,
      namespace: ar_page.namespace,
      raw_content: ar_page.raw_content,
      used_links: ar_page.used_links,
      triples: triples,
      headline: headline,
      created_at: ar_page.created_at.to_datetime,
      updated_at: ar_page.updated_at.to_datetime,
      html_content: ar_page.html_content
    )
  end

  def build_triple(ar_triple)
    TripleEntity.new(predicate: ar_triple.predicate, object: ar_triple.object)
  end

  def strip_namespaces(data)
    data.map do |key, value|
      # strip namespace
      _, key = key.split(':') if key.include?(':')
      [key, value]
    end.to_h
  end

end
