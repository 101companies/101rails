class Wiki.Views.Resources extends Backbone.View
  template : JST['backbone/templates/resource']

  render: ->
    self = @
    console.log(@model.get('name'))
    @setElement($(@template(@model.toJSON())))
    primary = @model.get('primary')
    if not _.isEmpty(primary)
      primaryel = $('<div class="subresources">')
      $(primaryel).append($('<h5>').text('Primary'))
      $.each primary, (i, target) ->
        if target.substring(0, 7) == 'http://'
          $(primaryel).append($('<li>').html($('<a>').attr('href', target).text(target)))
        else
          $(primaryel).append($('<li>').text(target))

      $(@el).append(primaryel)
    secondary = @model.get('secondary')
    if not _.isEmpty(secondary)
      secondaryel= $('<div class="subresources">')
      $(secondaryel).append($('<h5>').text('Secondary'))
      $.each secondary, (i, target) ->
       $(secondaryel).append($('<li>').text(target))
      $(@el).append(secondaryel)
    $('#resources').append(@el)


