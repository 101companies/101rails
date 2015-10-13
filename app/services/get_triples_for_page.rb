class GetTriplesForPage

  class TriplesForPageResult < Struct.new(:triples, :resources)
    def initialize(*attributes)
      super
      yield self
      freeze
    end
  end

  def execute!(page)
    rdf = rdf_for_page(page)

    resources = resources_for_rdf(rdf)

    rdf = rdf.select do |triple|
      node = triple[:node]
      !(node.start_with?('http://') || node.start_with?('https://'))
    end

    TriplesForPageResult.new do |result|
      result.resources = resources
      result.triples = rdf
    end
  end

  private

  include RdfModule

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
