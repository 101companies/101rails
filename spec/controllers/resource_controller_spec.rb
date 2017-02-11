require 'rails_helper'



RSpec.describe ResourceController, type: :controller do

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
        @testformats.each do |f,e|

          # controller returns a json response of an existing resource
          get(:get, params: { resource_name: 'resource_controller_spec.rb', format: f})
          expect(response.body).not_to eq(e)

        end

      end

      it 'returns non-existing resource' do
        @testformats.each do |f,e|

          # controller returns a json response of an non-existing resource
          get(:get, params: { resource_name: 'resource_that_does_not_exist', format: f })
          expect(response.body).to eq(e)

        end
      end
    end
  end

  context "with render_views" do
    render_views

    it 'returns html of existing resource' do

      get(:get, params: { resource_name: 'resource_controller_spec.rb', format: 'html' })
      expect(response.body).to include('>resource_controller_spec.rb<', '<h1>About:')

    end


    it 'search with search_str.length > 2 (no results)' do

      get(:get, params: { resource_name: 'resource_that_does_not_exist', format: 'html' })
      expect(response.body).to include('<h1>Nothing found...</h1>', 'some cats')

    end

    it 'search with search_str.length > 2 (with results)' do

      get(:get, params: { resource_name: 'resource', format: 'html' })
      expect(response.body).to include('<h1>Nothing found...</h1>', 'maybe you mean')

    end

    it 'search with search_str.length <= 2' do

      get(:get, params: { resource_name: 'xy', format: 'html' })
      expect(response.body).to include('<h1>Nothing found...</h1>', 'some cats')

    end

    it 'returns html of landing' do

      get( :landing )
      expect(response.body).to include('<h1>Welcome to 101linkeddata</h1>')

    end

    it 'get without graph' do

      allow($graph).to receive(:has_graph?) { nil }
      get(:get, params: { resource_name: 'resource_controller_spec.rb', format: 'html' })
      expect(response).not_to have_http_status(:success)

    end

    it 'landing without graph' do

      allow($graph).to receive(:has_graph?) { nil }
      get( :landing )
      expect(response).not_to have_http_status(:success)

    end

  end
end
