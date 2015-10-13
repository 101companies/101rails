class GetBooksForPage

  class BooksForPageResult < Struct.new(:books)

  end

  def initialize(logger, books_adapter)
    @books_adapter = books_adapter
    @logger = logger
  end

  def execute!(page)
    begin
      books = books_adapter.get_books(page.full_title)
    rescue BooksAdapters::Errors::NetworkError
      logger.warn("book retrieval failed for #{page.full_title}")
      books = []
    end

    BooksForPageResult.new(books)
  end

  private

  attr_reader :books_adapter
  attr_reader :logger

end
