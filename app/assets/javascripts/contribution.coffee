#= require masonry.pkgd.min
$ ->

  # use for contribution name of repo
  project_select = $("#create_contribution select").first()
  project_select.change ->
    contribution_name = $(this).find("option:selected").first().text()
    contribution_name = contribution_name.split("/")[1]

    # place name of the repo in as title
    $("#contribution_title").val contribution_name


  # data validation before submit
  $("#create_contribution").submit ->

    error_message = (msg) ->
      $.gritter.add
        image: "/assets/error.png"
        title: "Error"
        text: msg

    all_is_ok = true

    # not defined title
    unless $("#contribution_title").val().length
      all_is_ok = false
      error_message "You need to define title for your contribution"

    # not defined repo
    unless $("#create_contribution select").val().length
      all_is_ok = false
      error_message "You need to define repo for your contribution"

    all_is_ok
