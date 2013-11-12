$ ->

  # clicking on tab
  $(".tab-link").on "click", (evt) ->
    #evt.preventDefault();
    $(this).tab "show"
    # prevent scrolling to the bottom of page
    $(document).scrollTop 0


  # if page opened with hash param -> try to open appropriate tab
  hash = window.location.hash
  $("[href=\"" + hash + "\"]").trigger "click"  if hash.length
