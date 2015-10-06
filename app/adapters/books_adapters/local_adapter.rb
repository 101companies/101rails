module BooksAdapters

  class LocalAdapter < WorkerAdapter

    protected
    def get_url(title)
      "http://localhost:8000/services/termResources/#{title}.json"
    end

  end

end
