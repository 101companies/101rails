module BooksAdapters

  class TestAdapter
    attr_accessor :books

    def initialize(books=[])
      @books = books
    end

    def get_books(title)
      @books
    end

  end

end
