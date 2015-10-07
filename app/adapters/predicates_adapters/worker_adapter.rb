module PredicatesAdapters

  class WorkerAdapter

    def get_predicates
      begin
        url = get_url
        url = URI.encode url
        url = URI(url)
        @predicates = JSON::parse(Net::HTTP.get url)
      rescue SocketError
        raise Errors::NetworkError
      rescue JSON::ParserError
        raise Errors::InvalidPredicates
      end
    end

    protected

    def get_url
      "http://worker.101companies.org/data/dumps/wiki-predicates.json"
    end

  end

end
