# Ruby 3.2 deprecated File.exists? and Ruby 4 removed it. The pinned
# wikicloth fork still calls File.exists? while parsing file and fragment
# extensions, which makes those pages fail with a 500.
File.singleton_class.alias_method(:exists?, :exist?) unless File.respond_to?(:exists?)
