module BooksAdapters

  class WorkerAdapter

    def get_books(title)
      # begin
      #   url = get_url(title)
      #   url = URI.encode url
      #   url = URI(url)
      #
      #   request = Net::HTTP::Get.new url
      #   response = Net::HTTP.start(url.host, url.port, read_timeout: 0.5, connect_timeout: 1) {|http| http.request(request)}
      #
      #   JSON::parse(response.message)
      # rescue JSON::ParserError, Timeout::Error, Errno::EHOSTUNREACH, Errno::EINVAL, Errno::ECONNREFUSED, Errno::ECONNRESET, EOFError, Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => e
      #   raise Errors::NetworkError
      # rescue JSON::ParserError
      #   []
      # end
      []
    end

    protected
    def get_url(title)
      "http://worker.101companies.org/services/termResources/#{title}.json"
    end

  end

end
