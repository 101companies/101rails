require 'rails_helper'

describe ShowPage do

  before(:each) do

  end

  # TODO: change to real books
  let(:books)           { ['book1', 'book2'] }
  let(:books_adapter)   { BooksAdapters::TestAdapter.new(books) }

  describe 'show' do

    it 'gets the namespace' do
      page = create(:abstraction_page)

      result = ShowPage.new(Rails.logger, books_adapter).show(page.full_title, nil)

      expect(result.page).to eq(page)
      expect(result.rdf).to eq([])
      expect(result.resources).to eq([])
      expect(result.books).to eq(books)
    end

    it 'raise bad link' do
      # this raises bad link as the pages name contains a whitespace
      page = create(:page)

      expect {
        ShowPage.new(Rails.logger, Rails.configuration.books_adapter).show(page.full_title, nil)
      }.to raise_error(ShowPage::BadLink)
    end

  end


end
