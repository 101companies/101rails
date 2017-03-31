class ResourceController < ApplicationController
  helper_method :render_resource

  def query
    query = params[:query]
    sse = SPARQL.parse(query)

    result = sse.execute($graph.snapshot)
    result = Kaminari.paginate_array(result).page(params[:page]).per(100)
    result = RDF::Query::Solutions.new(result)
    
    render json: result.to_json
  end

  def landing
    if(params[:q].present?)
      params[:resource_name] = params[:q]
      get
    else
      if($graph.has_graph?)

        # + prepare subject ----------------------
        @subject = RDF::URI.new(scheme: request.scheme.dup,
                                host: '101companies.org',
                                path: 'resource/namespace')
        # - prepare subject ----------------------

        # + queries on graph -------------------
        @result = $graph.query([:s, :p, @subject]).to_a.uniq { |s,p,o| s.pname }.sort_by { |s,p,o| s.pname }

        # + execute rdf querys -----------------
        respond_to do |format|
          format.html {
            render file: 'resource/landing.html.erb'
          }
        end
      else
        flash[:error] = "Ontology file seems to be missing."
        render file: 'resource/search.html.erb', success: false, status: 500
      end
    end
  end

  def get
    if($graph.has_graph?)
      # + prepare subject ----------------------
      @subject = RDF::URI.new(scheme: request.scheme.dup,
                             host: '101companies.org',
                             path: 'resource/' + params[:resource_name])
      # - prepare subject ----------------------

      sub_set = nil
      obj_set = nil
      $graph.with_lock do
        sub_set = $graph.query([@subject, :p, :o]).to_set
        obj_set = $graph.query([:s, :p, @subject]).to_set
      end

      # + execute rdf querys -----------------
      respond_to do |format|
        format.json {
          render :json => sub_set.merge(obj_set).to_rdf_json
        }
        format.xml  {
          render :xml  => sub_set.merge(obj_set).to_rdfxml
        }
        format.ttl {
          render :plain  => sub_set.merge(obj_set).to_ttl
        }
        format.n3 {
          render :plain  => sub_set.merge(obj_set).to_ntriples
        }
        format.html {

          # + queries on graph -------------------
          @q_abstract = sub_set.select{ |s,p,o| p == RDF::URI('http://purl.org/dc/terms/abstract') }
          if(@q_abstract.length > 0)
            @abstract = @q_abstract[0][2].value
          end
          @q_type = sub_set.select{ |s,p,o| p == RDF::type }
          if(@q_type.length > 0)
            @type = @q_type[0][2].value.split('/').last
            @type_url = @q_type[0][2].value
          end

          @result = sub_set.sort_by { |s,p,o| p.pname + o.value }

          @result_inv = obj_set.sort_by { |s,p,o| p.pname + s.value }
          # - queries on graph -------------------

          # + additional informationes -----------
          @headline = params[:resource_name] #request.path.dup.to_s.split('/').last
          @headline_url = request.url

          # - additional informationes -----------
          if(sub_set.length + obj_set.length == 0)
            # html format without results tries a search
            search_str = params[:resource_name].downcase

            if search_str.length > 2
              @result = $graph.to_a.uniq{|s,p,o| s.pname }.select{ |s,p,o| s.pname.split('/').last.downcase.include?(search_str) }.sort_by { |s,p,o| s.pname }
            else
              @result = nil
            end
            @graphsize = $graph.count
            render file: 'resource/search.html.erb', success: true
          end
        }
        end
    else
      flash[:error] = "Ontology file seems to be missing."
      render file: 'resource/search.html.erb', success: false, status: 500
    end
  end

  private

  # helper function for render resources
  def render_resource_url(res_uri)
    return request.protocol + request.host_with_port + '/resource/' + res_uri.split('/').last
  end

  def render_resource_path(res_uri)
    return '/resource/' + res_uri.split('/').last
  end

  def render_resource(res)
    if res.literal?
      # literal
      require 'uri'
      if res.value =~ URI::regexp
        # url literal
        view_context.link_to res.value, res.value
      else
        # text literal
        view_context.raw res.value
      end
    else
      # node
      if res.value.split(request.host).count < 2
        # external uri
        view_context.link_to res.value.split('/').last, res.value
      else
        # internal uri
        view_context.link_to  res.value.split('/').last, render_resource_path(res.value)
      end
    end
  end

end
