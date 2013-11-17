$ ->
  # work with tabs
  hash = window.location.hash
  $("[href=\"" + hash + "\"]").trigger "click"  if hash.length
