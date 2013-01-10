# -*- encoding : utf-8 -*-

require 'spec_helper'
require 'pygments.rb'

class WikiParser < WikiCloth::Parser

    url_for do |page|
      "javascript:alert('You clicked on: #{page}');"
    end

    link_attributes_for do |page|
      { :href => url_for(page) }
    end

    template do |template|
      puts template
      "Hello {{{1}}}" if template == "hello"
    end

    external_link do |url,text|
      "<a href=\"#{url}\" target=\"_blank\" class=\"exlink\">#{text.blank? ? url : text}</a>"
    end

end

describe Page do
  it "should support update" do
    page = Page.new("Technology:Ruby_on_Rails")
    page.update("foo bar")
  end
end 
  