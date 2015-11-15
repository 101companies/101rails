module BooksAdapters

  class LocalWorkerAdapter < WorkerAdapter

    def get_books(page)
      super
    rescue Errors::NetworkError
      Rails.logger.info('local book retrieval failed')
      []
    end

    protected
    def get_url(title)
      "http://localhost:8000/services/termResources/#{title}.json"
    end

  end

end
