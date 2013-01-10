# -*- encoding : utf-8 -*-
require 'json'
require 'pp'
require 'media_wiki'
require 'wikicloth'

class CategoryPage < Page

  def members
    gw = MediaWiki::Gateway.new(@base_uri)
    gw.category_members(@title)
  end
end
