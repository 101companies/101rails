class ResourceController < ApplicationController
  def get
    host = request.host
    #host = '101companies.org'
    port = ':'+request.port.to_s
    #port = ''
    RDF::Graph.load('/home/andi/dev/ba/101web/data/onto/ontology.xml', format: :xml) do |graph|
      subject = RDF::URI.new(scheme: request.scheme.dup,
                             authority: host+port,
                             host: host,
                             port: request.port,
                             path: request.path.dup)

      if(request.format == 'html')
        @headline = request.path.dup.to_s.split('/').last
        @headline_url = request.url

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

        query_abstract.execute(graph).each do |solution|
          @abstract = solution.o
        end

        query_type.execute(graph).each do |solution|
          @type = solution.o.to_s.split('/').last
          @type_url = solution.o
        end

        @result = query_search1.execute(graph).order_by(:o.to_s.split('/').last).order_by(:p)
        @result_inv = query_search2.execute(graph).order_by(:s.to_s.split('/').last).order_by(:p)
      else
        render request.format => repository.query([subject, :s, :o])
      end
    end
  end

  def get_
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
