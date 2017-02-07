require 'rails_helper'

RSpec.describe ResourceController, type: :controller do

  describe 'GET get' do
    it 'should exist and not empty' do
      expect($graph).not_to be_nil

      expect($graph.count).to be > 0
    end

    describe 'GET resource' do

      it 'returns existing resource' do

        request.host = 'localhost:3000'

        # controller returns a json response of an existing resource
        get(:get, params: { resource_name: '101worker', format: 'json'})

        # expects a not empty json
        expect(JSON.parse(response.body)).not_to eq({})
      end

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
