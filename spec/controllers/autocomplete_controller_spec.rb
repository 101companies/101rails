require 'rails_helper'

RSpec.describe AutocompleteController, type: :controller do

  before(:each) do
    @abstraction_page = create :abstraction_page
    @page = create :page
  end

  describe 'GET index' do

    it 'autocompletes all pages from namespace' do
      get :index, prefix: "#{@page.namespace}::"

      data = JSON.parse(@response.body)

      expect(data).to include(@page.title)
    end

    it 'autocompletes all pages from namespace and prefix' do
      get :index, prefix: "#{@page.namespace}::#{@page.title[0]}"

      data = JSON.parse(@response.body)

      expect(data).to include(@page.title)
    end

    it 'works for namespace without pages' do
      get :index, prefix: "Script::"

      data = JSON.parse(@response.body)

      expect(data.length).to be(0)
    end

    it 'works for unkown namespaces' do
      get :index, prefix: "SomeUnkownNamespace::"

      data = JSON.parse(@response.body)

      expect(data.length).to be(0)
    end

    it 'filters regex characters' do
      get :index, prefix: "#{@page.namespace}::Z*"

      data = JSON.parse(@response.body)

      expect(assigns(:title)).not_to include('*')
    end

  end

end
