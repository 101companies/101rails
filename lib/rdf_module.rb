module RdfModule

  def page_to_resource(title)
    return title if title.starts_with?('Http')
    page = PageModule.find_by_full_title title
    return nil if page.nil?
    #RDF::URI.new("http://101companies.org/resources/#{page.namespace.downcase.pluralize}/#{page.title.gsub(' ', '_')}")
    return "#{page.namespace}:#{page.title.gsub(' ', '_')}"
  end

  def reverse_statement(st, title)
    [page_to_resource(st[0].to_s), st[1], page_to_resource(title)]
  end

  def get_rdf_json(title, directions)
    json = []
    get_rdf_graph(title, directions).each do |res|
      if directions
        json << { :direction => res[0].to_s, :predicate => res[1].to_s, :node => res[2].to_s }
      else
        # ingoing triples
        res = reverse_statement res, title if res[0].to_s == 'IN'
        json << [ res[0].to_s, res[1].to_s, res[2].to_s ]
      end
    end
    json
  end

  def get_rdf_graph(title, directions)
    @page = PageModule.find_by_full_title(PageModule.unescape_wiki_url(title))
    uri = self.page_to_resource title
    graph = []
    graph = add_outgoing_semantic_triples graph, @page, uri, directions
    #graph = add_subresources graph, @page, context
    unless directions
      graph = add_outgoing_non_semantic_triples graph, uri, directions
    end
    add_ingoing_triples graph, @page#, context
  end

  def semantic_properties(name)
    # See https://github.com/101companies/101rails/issues/46
    "http://101companies.org/property/#{name}"
  end

  def add_outgoing_non_semantic_triples(graph, uri, directions)
    (@page.internal_links-@page.semantic_links).each do |link|
      object = directions ? link : page_to_resource(link)
      if !object.nil?
        graph << [uri, "mentions", object]
      end
    end
    graph
  end

  def add_subresources(graph, page, context)
    if page.subresources.nil?
      graph
    else
      page.subresources.each do |s|
        s.each do |key, value|
          subject =  page_to_resource(key)
          value.each do |l|
            predicate = RDF::URI.new(self.semantic_properties(l.split('::')[0]))
            object = page_to_resource(l.split('::')[1])
            graph <<  RDF::Statement.new(subject, predicate, object, :context => context)
          end
        end
      end
    end
    graph
  end

  def add_outgoing_semantic_triples(graph, page, uri, directions)
    page.semantic_links.each do |link|
      subject = directions ? "OUT" : uri
      link_prefix = link.split('::')[1]
      object = directions ? link_prefix : page_to_resource(link_prefix)
      semantic_property = PageModule.uncapitalize_first_char link.split('::')[0]
      if !object.nil?
        graph << [subject, semantic_property, object]
      end
    end
    graph
  end

  def add_ingoing_triples(graph, page) #, context)

    #TODO: need to get all semantic properties in a generic way
    semantic_hash = %w(dependsOn instanceOf identifies cites linksTo uses implements isA developedBy reviewedBy relatesTo
       implies mentions memberOf)

    semantic_hash.each do |x|
      x = MediaWiki::send :upcase_first_char, x
      Page.where(:used_links => x+'::'+page.full_title).each do |page|
        graph << ["IN", x.camelize(:lower), page.full_title]
      end
    end
    graph
  end
end
