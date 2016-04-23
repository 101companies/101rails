class GetBooksForPage
  include SolidUseCase

  steps :get_books

  def get_books(params)
    page = params[:page]

    begin
      ap 'get bookgs'
      books = BooksAdapters::WorkerAdapter.new.get_books(page.full_title)
    rescue BooksAdapters::Errors::NetworkError
      Rails.logger.warn("book retrieval failed for #{page.full_title}")
      books = []
    end

    ap 'got books'

    params[:books] = books
    continue(params)
  end

end
