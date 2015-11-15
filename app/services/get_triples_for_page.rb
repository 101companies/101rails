class GetTriplesForPage
  include SolidUseCase
  include RdfModule

  steps :get_rdf_for_page, :sort_rdf, :get_resources, :get_triples

  def get_rdf_for_page(params)
    page = params[:page]

    rdf = get_rdf_json(page.full_title, true)

    params[:rdf] = rdf
    continue(params)
  end

  def sort_rdf(params)
    rdf = params[:rdf]

    rdf.sort do |x,y|
      if x[:predicate] == y[:predicate]
        x[:node] <=> y[:node]
      else
        x[:predicate] <=> y[:predicate]
      end
    end

    params[:rdf] = rdf
    continue(params)
  end

  def get_resources(params)
    rdf = params[:rdf]

    resources = rdf.select do |triple|
      triple[:node].include?('://')
    end

    params[:resources] = resources
    continue(params)
  end

  def get_triples(params)
    rdf = params[:rdf]

    triples = rdf.select do |triple|
      node = triple[:node]
      !triple[:node].include?('://')
    end

    params[:triples] = triples
    continue(params)
  end

end
