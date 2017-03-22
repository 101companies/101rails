class Wordnet

  def initialize()
    # @cache = Concurrent::Hash.new
  end

  def is_common?(term)
    # Rails.logger.debug("getting term frequency for #{term}")
    # if @cache[term]
    #   Rails.logger.debug('got from cache')
    #   @cache[term]
    # else
    #   url = "http://www.wordcount.org/dbquery.php?toFind=#{term}&method=SEARCH_BY_NAME"
    #   begin
    #     result = Net::HTTP.get(URI.parse(url))
    #     result = result.split('&')
    #     if result[1] == 'wordFound=yes'
    #       rank = result[3].gsub("rankOfRequested=", '').to_i
    #     else
    #       rank = 9999
    #     end
    #   rescue => e
    #     ap e
    #     rank = 9999
    #   end
    #
    #   @cache[term] = rank
    #   rank
    # end
    $common_terms.include?(term)
  end

end
