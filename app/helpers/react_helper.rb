# Renders a React component placeholder. The bundle built by esbuild
# (app/javascript/react/mount.js) finds these placeholders and mounts the
# component with the given props.
#
#   react_component('PageEditor', rawContent: @page.raw_content)
#
# Replaces the helper previously provided by the react-rails gem.
module ReactHelper
  def react_component(name, props = {}, html_options = {})
    data = { react_class: name, react_json: props.to_json }
    data.merge!(html_options.delete(:data) || {})

    tag.div('', class: html_options.delete(:class), id: html_options.delete(:id), **html_options, data: data)
  end
end
