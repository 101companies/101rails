$ ->

  # if page opened with hash param -> try to open appropriate tab
  hash = window.location.hash
  $("[href=\"" + hash + "\"]").trigger "click" if hash.length
