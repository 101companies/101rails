# module PageBuilder
#
#   private
#
#   def build_page_entity(ar_page)
#     PageEntity.new(
#       title: ar_page.title,
#       namespace: ar_page.namespace,
#       raw_content: ar_page.raw_content
#     )
#   end
#
#   def strip_namespaces(data)
#     data.map do |key, value|
#       # strip namespace
#       _, key = key.split(':') if key.include?(':')
#       [key, value]
#     end.to_h
#   end
#
# end
