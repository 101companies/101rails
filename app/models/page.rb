# -*- encoding : utf-8 -*-
require 'json'
require 'pp'
require 'media_wiki'
require 'wikicloth'

class WikiParser < WikiCloth::Parser
    #external_link do |url,text|
    #  "<a href=\"#{url}\" target=\"_blank\" class=\"exlink\">#{text.blank? ? url : text}</a>"
    #end
end

class Page

  include Mongoid::Document
  include Mongoid::Timestamps

  field :title, type: String
  index({ title: 1 }, { unique: true, background: true })

  belongs_to :user

  attr_accessible :user_id, :title, :created_at, :updated_at

  def create(title)

    @base_uri = 'http://mediawiki.101companies.org/api.php'

    # create a context from NS:TITLE
    @ctx = title.split(':').length == 2 ?
        {ns: title.split(':')[0].downcase, title: title.split(':')[1]} : {ns: 'concept', title: title.split(':')[0]}
    #Rails.logger.debug(@ctx)

    # set title to page, if defined in db
    page_from_db = Page.where(:title => title).first
    if !page_from_db.nil?
      self.user = page_from_db.user
    end

    self.title = title
    self.save
    @title = title

    @wiki = WikiParser.new(:data => content, :noedit => true)
    WikiParser.context = @ctx

    @html = Rails.cache.read(title + "_html")
    if (@html == nil)
      @html = @wiki.to_html
      @wiki.internal_links.each do |link|
        @html.gsub!("<a href=\"#{link}\"", "<a href=\"/wiki/#{link}\"")
        #html.gsub!(":Category:","/wiki/Category:")
     end
      #convert <p>http://foo.com</p> into <p><a href="http://foo.com">http://foo.com</a>
      #@html.gsub!(/\b([\w]+?:\/\/[\w]+[^ \"\r\n\t<]*)/i, '<a href="\1">\1</a>')
      Rails.cache.write(title + "_html", @html)
    end

    self

  end

  def content
    c = Rails.cache.read(self.title)

    if (c == nil)
      c = gateway.get(self.title)
      Rails.cache.write(title, c)
    end

    return c
  end

  def html
    @html
  end

  def wiki
    @wiki
  end

  def change(content)
    Rails.cache.write(self.title, content)
    Rails.cache.delete(self.title + "_html")
    gw = MediaWiki::Gateway.new(@base_uri)
    gw.login(ENV['WIKIUSER'], ENV['WIKIPASSWORD'])
    gw.edit(self.title, content)
  end

  def internal_links
    puts "internal_links "
    puts @wiki
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
    gateway.backlinks(self.title).map { |e| e.gsub(" ", "_")  }
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
