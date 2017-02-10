require 'rails_helper'

RSpec.describe ResourceController, type: :controller do

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
        # controller returns a json response of an existing resource
        get(:get, params: { resource_name: 'resource_controller_spec.rb', format: 'json'})

        # expects a not empty json
        expect(JSON.parse(response.body)).not_to eq({})
      end

      ## test the graph doent exists
        ## allow($graph).to receive(:has_graph?) { nil }

      it 'returns non-existing resource' do

        request.host = 'localhost:3000'

        # controller returns a json response of an non-existing resource
        get(:get, params: { resource_name: 'resource_that_does_not_exist_123456789987654321', format: 'json'})

        # expects a not empty json
        expect(JSON.parse(response.body)).to eq({})
      end

    end
  end
end
