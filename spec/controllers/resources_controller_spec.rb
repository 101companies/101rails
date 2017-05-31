require 'rails_helper'

RSpec.describe ResourcesController, type: :controller do

  before(:each) do
    @testformats = [
        ['json', '{}'],
        ['n3', ''],
        ['ttl', ''],
        ['xml', "<?xml version='1.0' encoding='utf-8' ?>\n<rdf:RDF xmlns:rdf='http://www.w3.org/1999/02/22-rdf-syntax-ns#'>\n</rdf:RDF>\n"]
    ]
  end

  describe 'GET get' do
    it 'should exist and not empty' do
      expect($graph).not_to be_nil

      expect($graph.count).to be > 0

      #allow($graph).to receive(:magic_call_method_or_so) {
      #  {key: 'some-data'}
      #}
    end

    describe 'GET resource' do

      it 'returns existing resource' do
        @testformats.each do |f, e|

          # controller returns a json response of an existing resource
          get(:show, params: { id: 'resource_controller_spec.rb', format: f})

          expect(response.body).not_to eq(e)
        end

      end

      it 'returns non-existing resource' do
        @testformats.each do |f,e|

          # controller returns a json response of an non-existing resource
          get(:show, params: { id: 'resource_that_does_not_exist', format: f })
          expect(response.body).to eq(e)

        end
      end
    end
  end

  context "with render_views" do
    render_views

    it 'returns html of existing resource' do
      get(:show, params: { id: 'resource_controller_spec.rb', format: 'html' })

      expect(response.body).to include('resource_controller_spec.rb', '<h1>About:')
    end

    it 'resource without type and abstract' do

      get(:show, params: { id: 'test_ontology', format: 'html' })
      expect(response).to have_http_status(:success)

    end

    it 'search with search_strf.length > 2 (with results)' do

      get(:show, params: { id: 'resource', format: 'html' })
      expect(response.body).to include('<h1>Nothing found...</h1>', 'maybe you mean')

    end


    it 'search with search_str.length > 2 (without results)' do

      get(:show, params: { id: 'resource_that_does_not_exist', format: 'html' })
      expect(response.body).to include('<h1>Nothing found...</h1>', 'some cats')

    end

    it 'search with search_str.length <= 2' do

      get(:show, params: { id: 'xy', format: 'html' })
      expect(response.body).to include('<h1>Nothing found...</h1>', 'some cats')

    end

    it 'returns html of landing' do
      get(:index)

      expect(response.body).to include('<title>101linkeddata</title>')
    end

    it 'get without graph' do

      allow($graph).to receive(:has_graph?) { nil }
      get(:show, params: { id: 'resource_controller_spec.rb', format: 'html' })
      expect(response).not_to have_http_status(:success)

    end

    it 'landing without graph' do
      allow($graph).to receive(:has_graph?) { nil }

      get(:index)

      expect(response).not_to have_http_status(:success)
    end

  end

  describe 'query' do
    it 'gets most frequently used predicates' do
      query = 'SELECT ?predicate (COUNT(*)AS ?frequency)
WHERE {?subject ?predicate ?obDEject}
GROUP BY ?predicate
ORDER BY DESC(?frequency)
LIMIT 2'

      get(:query, params: { query: query })

      expect(response).to have_http_status(:ok)
      expect(json_response['head']['vars']).to eq(['predicate', 'frequency'])
      expect(json_response['results']['bindings'].length).to eq(2)
    end

    it 'can handle invalid syntax' do
      query = 'this is not sparql'

      get(:query, params: { query: query })

      expect(response).to redirect_to(resources_path)
      expect(flash[:error]).not_to be(nil)
    end
  end
end
