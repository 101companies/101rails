class ResourceController < ApplicationController
  def get
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
