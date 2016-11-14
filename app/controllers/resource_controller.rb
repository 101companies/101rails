class ResourceController < ApplicationController

  helper_method :render_resource

  $linked_data_graph = nil
  $linked_data_graph_mtime = nil

  def get
    onto_path = Rails.root.join('../101web/data/onto/ontology.ttl')
    host = request.host
    #host = '101companies.org'
    port = ':'+request.port.to_s
    #port = ''

    # + load graph --------------------------
    # check, if graph is already loaded
    if($linked_data_graph.nil? || $linked_data_graph_mtime != File.mtime(onto_path))

      logger.info "    load new ontology from " + onto_path.to_s

      # load new graph into global variable
      $linked_data_graph_mtime = File.mtime(onto_path)
      $linked_data_graph = RDF::Graph.load(onto_path, format: :ttl)

    end
    graph = $linked_data_graph
    # - load graph ---------------------------

    path = params[:resource_name]

    # + prepare subject ----------------------
    @subject = RDF::URI.new(scheme: request.scheme.dup,
                           authority: host + port,
                           host: host,
                           port: request.port,
                           path: 'resource/' + path)
    # - prepare subject ----------------------

    # + execute rdf querys -----------------
    sub_set = graph.query([@subject, :p, :o]).to_set
    obj_set = graph.query([:s, :p, @subject]).to_set
    respond_to do |format|
      format.json { render :json => sub_set.merge(obj_set).to_rdf_json }
      format.xml  { render :xml  => sub_set.merge(obj_set).to_rdfxml }
      #format.rdf  { render :xml  => graph.query([@subject, :p, :o]).to_rdfxml }
      format.html {

        # + queries on graph -------------------
        graph.query([@subject, RDF::URI('http://purl.org/dc/terms/abstract'), :o]) do |s,p,o|
          @abstract = o.value
        end

        graph.query([@subject, RDF::type, :o]) do |s,p,o|
          @type = o.value.split('/').last
          @type_url = o.value
        end

        @result = sub_set.sort_by { |s,p,o| p.pname + o.value }
        @result_inv = obj_set.sort_by { |s,p,o| p.pname + s.value }
        # - queries on graph -------------------

        # + additional informationes -----------
        @headline = request.path.dup.to_s.split('/').last
        @headline_url = request.url
        # - additional informationes -----------

        # html format without results tries a search
        if(@result.length == 0 && @result_inv.length == 0)
          search_str = params[:resource_name].downcase
          if search_str.length > 2
            @result = graph.query([:s, RDF::URI('http://localhost:3000/resource/ontoid', :o)]).to_set.select{ |s,p,o| s.to_s.downcase.include?(search_str) }.sort_by { |s,p,o| s.pname }
          else
            @result = nil
          end
          render file: 'resource/search.html.erb'
        end
      }
      end
  end

  # helper function for render resources
  def render_resource (res)
    if res.uri? # is an uri
      if res.value.split(request.host).count < 2 # is an external link
        view_context.link_to res.value.split('/').last, res.value, :target => "_blank"
      else
        view_context.link_to res.value.split('/').last, res.value
      end
    else
      require 'uri'
      if (res.value =~ /\A#{URI::regexp}\z/)
        view_context.link_to res.value, res.value, :target => "_blank"
      else
        res.value
      end
    end
  end

end
