Wiki.Utils.atTo101 = (s) ->
  match = /@(.*)/.exec(s)
  if match
    '101' + match[1]
  else
    s

Wiki.Utils.escapeURI = (uri) ->
  decodeURIComponent(uri
    .replace(/\-/g, '-2D')
    .replace(/\:/g, "-3A")
    .replace(/\s/g, '_')
  )
