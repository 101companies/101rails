require '../config/environment.rb'
require 'media_wiki'
include ActionView::Helpers::PagesHelper

# inject all namespace triples by triggering "change"
all_pages.each do |title|
  p = Page.new.create(title)
  if p.content
    print title + ': Injecting...'
    p.change(p.content)
    print " done.\n"
  end
end
