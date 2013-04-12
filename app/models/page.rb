# -*- encoding : utf-8 -*-
require 'json'
require 'pp'
require 'media_wiki'
require 'wikicloth'

class Page
  include HTTParty

  def initialize(title)
    @title = title
    @base_uri = 'http://mediawiki.101companies.org/api.php'
    content = Rails.cache.read(title)
    
    if (content == nil)
      content = gateway.get(title)
      Rails.cache.write(title, content)
    end  

    # create a context from NS:TITLE
    @ctx = title.split(':').length == 2 ? {ns: title.split(':')[0].downcase, title: title.split(':')[1]} : {ns: 'concept', title: title.split(':')[0]}
    #Rails.logger.debug(@ctx)

    @wiki = WikiCloth::Parser.new(:data => content, :noedit => true)
    WikiCloth::Parser.context = @ctx

    @html = Rails.cache.read(title + "_html")
    if (@html == nil)
      @html = @wiki.to_html
      Rails.cache.write(title + "_html", @html)
    end 
  end
      
  def html
    @html
  end

  def wiki
    @wiki
  end

  def title
    @title
  end

  def update(content)
    Rails.cache.write(@title, content)
    Rails.cache.delete(@title, + "_html", content)

    gw = MediaWiki::Gateway.new(@base_uri)
    gw.login(ENV['WIKIUSER'], ENV['WIKIPASSWORD'])
    gw.edit(@title, content)
  end

  def internal_links
    @wiki.internal_links
  end  

  def sections
    sec = []
    @wiki.sections.first.children.each { |s| sec.push({'title' => s.title, 'content' => s.wikitext})  }
    return sec
  end

  def categories
    @wiki.categories
  end

  def backlinks
    gateway.backlinks(@title)
  end

  def section(section)
    @wiki.sections.first.children.find { |s| s.title.downcase == section.downcase }
  end

  private
    def gateway
      if @_gateway == nil
        @_gateway = MediaWiki::Gateway.new(@base_uri)
      else
        return @_gateway
      end    
    end
end
