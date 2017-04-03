class GetBooksForPage
  include SolidUseCase

  steps :get_books

  def get_books(params)
    page = params[:page]

    books = page.mappings

    params[:books] = books
    continue(params)
  end

end
