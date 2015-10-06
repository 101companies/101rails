module BooksAdapters

  class WorkerAdapter

    def get_books(title)
      begin
        url = get_url(title)
        url = URI.encode url
        url = URI(url)
        response = Net::HTTP.get url

        JSON::parse(response)
      rescue SocketError
        raise Adapter::BooksUnreachable
      rescue JSON::ParserError
        raise Adapter::InvalidBooks
      end
    end

    protected
    def get_url(title)
      "http://worker.101companies.org/services/termResources/#{title}.json"
    end

  end

end
