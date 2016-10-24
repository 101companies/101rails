class ResourceController < ApplicationController

  @@linked_data_graph = nil

  def get
    host = request.host
    #host = '101companies.org'
    port = ':'+request.port.to_s
    #port = ''

    # + load graph --------------------------
    # check, if graph is already loaded
    if(@@linked_data_graph == nil)
      # save graph global (available to this class)
      @@linked_data_graph = RDF::Graph.load(Rails.root.join('../101web/data/onto/ontology.xml'), format: :xml)
    end
    graph = @@linked_data_graph
    # - load graph ---------------------------

    # + prepare subject ----------------------
    subject = RDF::URI.new(scheme: request.scheme.dup,
                           authority: host+port,
                           host: host,
                           port: request.port,
                           path: request.path.dup)
    # - prepare subject ----------------------

    if(request.format == 'html')

      # + prepare rdf querys -----------------
      query_abstract = RDF::Query.new do
        pattern [subject, RDF::Vocab::DC.abstract, :o]
      end
      query_type = RDF::Query.new do
        pattern [subject, RDF::type, :o]
      end
      query_search1 = RDF::Query.new do
        pattern [subject, :p, :o]
      end
      query_search2 = RDF::Query.new do
        pattern [:s, :p, subject]
      end
      # - prepare rdf querys -----------------

      # + execute rdf querys -----------------
      query_abstract.execute(graph).each do |solution|
        @abstract = solution.o
      end
      query_type.execute(graph).each do |solution|
        @type = solution.o.to_s.split('/').last
        @type_url = solution.o
      end
      @result = query_search1.execute(graph).order_by(:o.to_s.split('/').last).order_by(:p)
      @result_inv = query_search2.execute(graph).order_by(:s.to_s.split('/').last).order_by(:p)
      # - execute rdf querys -----------------


      # + additional informationes -----------
      @headline = request.path.dup.to_s.split('/').last
      @headline_url = request.url
      # - additional informationes -----------

      render layout: false
    else
      # - non-html requests (e.g. json, xml) -
      render request.format => repository.query([subject, :s, :o])
      # - non-html requests (e.g. json, xml) -
    end
  end

  def get_old
    RDF::Repository.load('/home/andi/dev/ba/101web/data/onto/ontology.xml', format: :xml) do |repository|
      subject = RDF::URI.new(scheme: request.scheme.dup,
                             authority: request.host+':'+request.port.to_s,
                             host: request.host.dup,
                             port: request.port,
                             path: request.path.dup)

      if(request.format == 'html')
        @headline = request.path.dup
        @headline_url = request.url
        repository.query([subject, RDF::type, :o]).each do |s,p,o|
          @type = o
          @type_url = o
        end

        @result = repository.query([subject, :p, :o])
        @result_inv = repository.query([:s, :p, subject])
      else
        render request.format => repository.query([subject, :s, :o])
      end
    end
  end
end
