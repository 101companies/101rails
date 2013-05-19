Wiki.Utils.atTo101 = (s) ->
  match = /@(.*)/.exec(s)
  if match
    '101' + match[1]
  else
    s
