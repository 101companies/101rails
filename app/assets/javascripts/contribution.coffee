$ ->

  #TODO: title

  # use for contribution name of repo
  project_select = $("#create_contribution select").first()

  # get input field for title
  contribution_title_input = $("#contribution_title")

  set_value_for_title = () ->
    # retrieve name from name of repo
    contribution_name = project_select.find("option:selected").first().text().split("/")[1]
    # place name of the repo in as title
    contribution_title_input.val contribution_name

  # init title field with name retrieved from first existing repo
  set_value_for_title()

  # on selecting another repo -> set another name
  project_select.change ->
    set_value_for_title()

  # data validation before submit
  $("#create_contribution").submit ->

    # growl-like notification for error
    error_message = (msg) ->
      $.gritter.add
        image: "/assets/error.png"
        title: "Error"
        text: msg

    all_is_ok = true

    # not defined title
    unless contribution_title_input.val().length
      all_is_ok = false
      error_message "You need to define title for your contribution"

    # not defined repo
    unless $("#create_contribution select").val().length
      all_is_ok = false
      error_message "You need to define repo for your contribution"

    # false prevents sending the form
    # true sends the form
    all_is_ok
  for elem in ["#page_contribution_url", "#page_contribution_folder"]
    $(elem).select2 width: "70%"
