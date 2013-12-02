module SnapshotModule
  require 'nokogiri'
  require 'watir-webdriver'
  require 'timeout'
  require 'ejs'

  def self.get_snapshot(page)
    @b = Watir::Browser.new :phantomjs
    @b.driver.manage.timeouts.implicit_wait = 30 #30 seconds
    @site = "http://101companies.org/"
    begin
      @b.goto "#{@site}wiki/#{page.url}"
      #@b.div(:class, 'triple').wait_until_present
      @b.div(:id, 'backlinks').wait_until_present
      @b.div(:class, 'content-loading').wait_while_present
      @doc = Nokogiri.HTML(@b.html) # Parse the document
      @doc.css('script').remove     # Remove <script>…</script>
    rescue
      @b.goto "#{@site}wiki/#{page.url}"
      @doc = Nokogiri.HTML(@b.html)
      @doc.css('script').remove
    ensure
      @b.close
    end

    return @doc.to_html
  end

end
