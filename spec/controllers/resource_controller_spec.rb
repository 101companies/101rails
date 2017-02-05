require 'rails_helper'

=begin
def check_graph
  onto_path = Rails.root.join('../101web/data/dumps/ontology.ttl')

  if (!File.exists?(onto_path))
    @result = nil
    render file: 'resource/search.html.erb'
    false
  else
    true
  end
end
=end

RSpec.describe ResourceController, type: :controller do

  describe 'GET resource' do

    it 'checks json result of 101companies' do

      get :get, params: { resource_name: '101companies', host: 'localhost', format: :json }

      json_reponse = JSON.parse(response.body)

      expect(json_reponse).not_to eq({})
    end

    it 'checks json result of not existing item' do

      get :get, params: { resource_name: '555b72c2-9d0d-47ed-8715-ececc2e117d9', host: 'localhost', format: :json }

      json_reponse = JSON.parse(response.body)

      expect(json_reponse).to eq({})
    end

=begin
    it 'returns the html page' do
      get(:get, params: { resource_name: '101companies' })

      expect(response).to render(:partial => 'resource/101companies')
    end
=end

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

end
