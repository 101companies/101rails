require "rails_helper"

RSpec.describe MappingsController, type: :routing do
  describe "routing" do

    it "routes to #edit" do
      expect(:get => "/mappings/1/edit").to route_to("mappings#edit", :id => "1")
    end

    it "routes to #update via PUT" do
      expect(:put => "/mappings/1").to route_to("mappings#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/mappings/1").to route_to("mappings#update", :id => "1")
    end

  end
end
