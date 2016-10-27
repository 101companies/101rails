class ResourceController < ApplicationController

  helper_method :render_resource
  @@linked_data_graph = nil

  def get
    host = request.host
    #host = '101companies.org'
    port = ':'+request.port.to_s
    #port = ''

    # + load graph --------------------------
    # check, if graph is already loaded
    if(@@linked_data_graph == nil)
      require 'rdf/turtle'
      require 'rdf/json'
      require 'rdf/rdfxml'

      # save graph global (available to this class)
      @@linked_data_graph = RDF::Graph.load(Rails.root.join('../101web/data/onto/ontology.ttl'), format: :ttl)
    end
    graph = @@linked_data_graph
    # - load graph ---------------------------

    path = File.basename(request.path.dup, File.extname(request.path.dup))

    # + prepare subject ----------------------
    @subject = RDF::URI.new(scheme: request.scheme.dup,
                           authority: host+port,
                           host: host,
                           port: request.port,
                           path: 'resource/'+path)
    # - prepare subject ----------------------

    # + execute rdf querys -----------------
    respond_to do |format|
      format.json { render :json => graph.query([@subject, :p, :o]).to_rdf_json }
      format.xml  { render :xml  => graph.query([@subject, :p, :o]).to_rdfxml }
      #format.rdf  { render :xml  => graph.query([@subject, :p, :o]).to_rdfxml }
      format.html {

        # + prepare rdf querys -----------------
        query_abstract = RDF::Query.new( [@subject, RDF::Vocab::DC.abstract, :object])
        query_type = RDF::Query.new( [@subject, RDF::type, :object])
        query_search1 = RDF::Query.new( [@subject, :p, :object])
        query_search2 = RDF::Query.new( [:s, :p, @subject])
        # - prepare rdf querys -----------------

        graph.query([@subject, RDF::Vocab::DC.abstract, :o]) do |s,p,o|
          @abstract = o.value
        end

        graph.query([@subject, RDF::type, :o]) do |s,p,o|
          @type = o.value.split('/').last
          @type_url = o.value
        end

        @result = graph.query([@subject, :p, :o]).sort_by { |s,p,o| o.value }
        @result_inv = graph.query([:s, :p, @subject]).sort_by { |s,p,o| p.value }

        # + additional informationes -----------
        @headline = request.path.dup.to_s.split('/').last
        @headline_url = request.url
        # - additional informationes -----------
      }
      end
  end

  def render_resource (res)
    if res.uri? # is an uri
      if res.value.split(request.host).count < 2 # is an external link
        view_context.link_to res.value.split('/').last, res.value, :target => "_blank"
      else
        view_context.link_to res.value.split('/').last, res.value
      end
    else
      if res.value =~ URI::regexp
        view_context.link_to res.value, res.value, :target => "_blank"
      else
        res.value
      end
    end
  end

end
