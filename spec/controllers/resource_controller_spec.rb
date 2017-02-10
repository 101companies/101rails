require 'rails_helper'

RSpec.describe ResourceController, type: :controller do

  describe 'Ontology Graph' do
    it 'should exist and not empty' do
      expect($graph).not_to be_nil

      expect($graph.count).to be > 0

      allow($graph).to receive(:magic_call_method_or_so) {
        {key: 'some-data'}
      }
    end

    describe 'GET resource' do

      xit 'returns resource' do

        # get should return a simple json response of an existing resource. It should do it but it does not.
        get(:get, params: { resource_name: '101companies' })

        # it expects a knows attribute of a simple json response of an existing resource
        expect(true).to eq(response.body)

      end

    end
  end
end

=begin
  describe 'GET get' do

    it 'checks non html results ' do
      expect(check_graph).to eq(true)
      expect($graph.count).not_to eq(0)

      if(check_graph)
        $graph.to_set.each do |s,p,o|

          str_s = s.relativize(s.parent).to_str
          str_p = p.relativize(p.parent).to_str

          if(o.literal?)
            str_o = o.value
          else
            str_o = o.relativize(o.parent).to_str
          end

          get :get, params: { resource_name: str_s, format: :xml }

          #expect(str_s).to eq('chicken')
          expect(response.body).to eq('chicken')


          #get :get, params: { resource_name: s.pname, format: :xml }
          #get :get, params: { resource_name: s.pname, format: :n3 }
          #get :get, params: { resource_name: s.pname, format: :ttl }

          json_reponse = JSON.parse(response.body)

          expect(json_reponse).to eq('chicken')#o.value)

          expect(json_reponse[str_p]).to eq(str_o)

          expect(json_reponse).to eq('chicken')#o.value)

        end
      end
      #expect(response).to render_template(:show, locals: { page: page })
    end

  end
=end
