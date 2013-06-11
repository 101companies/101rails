require '../config/environment.rb'
require 'media_wiki'
include ActionView::Helpers::PagesHelper

all_pages.each do |title|
  p = Page.new.create(title)
  if p.content
    print title + ': Injecting...'
    p.change(p.content)
  end
  print " done.\n"
end
