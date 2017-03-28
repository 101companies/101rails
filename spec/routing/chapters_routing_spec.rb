require "rails_helper"

RSpec.describe ChaptersController, type: :routing do
  describe "routing" do

    it "routes to #new" do
      expect(:get => "/books/1/chapters/new").to route_to("chapters#new", book_id: '1')
    end

    it "routes to #edit" do
      expect(:get => "/books/1/chapters/1/edit").to route_to("chapters#edit", id: '1', book_id: '1')
    end

    it "routes to #create" do
      expect(:post => "/books/1/chapters").to route_to("chapters#create", book_id: '1')
    end

    it "routes to #update via PUT" do
      expect(put: "/books/1/chapters/1").to route_to("chapters#update", id: '1', book_id: '1')
    end

    it "routes to #update via PATCH" do
      expect(patch: "/books/1/chapters/1").to route_to("chapters#update", book_id: '1', id: '1')
    end

    it "routes to #destroy" do
      expect(delete: "/books/1/chapters/1").to route_to("chapters#destroy", book_id: '1', id: '1')
    end

  end
end
