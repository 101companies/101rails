require 'rails_helper'

describe GetPage do
  before(:each) do
  end

  # TODO: change to real books
  let(:books)           { %w(book1 book2) }
  let(:books_adapter)   { BooksAdapters::TestAdapter.new(books) }

  describe 'network issues' do
    it 'catches network error' do
      adapter = double
      page = create(:abstraction_page)

      expect(adapter).to receive(:get_books)
        .with(page.full_title)
        .and_raise(BooksAdapters::Errors::NetworkError)

      result = GetPage.new(Rails.logger, adapter).show(page.full_title, nil)
      expect(result.books).to eq([])
    end
  end

  describe 'show' do
    it 'gets the namespace' do
      page = create(:abstraction_page)

      result = GetPage.new(Rails.logger, books_adapter).show(page.full_title, nil)

      expect(result.page).to eq(page)
      expect(result.rdf).to eq([])
      expect(result.resources).to eq([])
      expect(result.books).to eq(books)
    end

    it 'raise bad link' do
      # this raises bad link as the pages name contains a whitespace
      page = create(:page)

      expect do
        GetPage.new(Rails.logger, Rails.configuration.books_adapter).show(page.full_title, nil)
      end.to raise_error(GetPage::BadLink)
    end
  end
end
