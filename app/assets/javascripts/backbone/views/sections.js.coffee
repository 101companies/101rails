class Wiki.Views.Sections extends Backbone.View
  template : JST['backbone/templates/section']

  render: ->
    self = @
    # get prerendered headline node
    preRendered = $('#' + @model.get('title')).parent()

    # collect prerendered content nodes
    $set = $()
    nxt = preRendered[0].nextSibling
    while nxt
        unless $(nxt).is('h2')
          $set.push nxt
          nxt = nxt.nextSibling
        else
          break

    # replace prerendered section by template
    $section = $(@template(title: @model.get('title')))
    $section.find('.section-content-parsed').append($set)
    preRendered.after($section).remove()
    @setElement($section)
    # hide metadata section
    if @model.get('title') == "Metadata"
      $(@el).find('.section-content-parsed').html("")
      $(@el).attr('id','metasection')

    # set handler
    $(@el).find('.editbutton').click( -> self.edit(@))
    if _.contains(Wiki.currentUser.actions, "Edit")
        alert("YES!")

  edit: (button) ->
    if  _.contains(Wiki.currentUser.actions, "Edit")
      $('#modal_body').html(
          $('<div>').addClass('alert alert-info')
          .text("Please login to edit"))
      $('#modal').modal()
    else
      self = @
      console.log(button)
      @toggleEdit(true)
      self.editor = ace.edit($(self.el).find('.editor')[0]);
      self.editor.setTheme("ace/theme/chrome");
      self.editor.getSession().setMode("ace/mode/text");
      self.editor.insert(self.model.get('content'))
      $(button).find('strong').text("Save")
      $(button).unbind('click').bind('click', -> self.save(button))

  save: (button) ->
    @model.set('content', @editor.getValue())

  toggleEdit: (open) ->
    $(@el).find('.section-content').animate({marginLeft: '-100%'}, 400)
    $(@el).find('.section-content-source').css(height: '400px')
    $(@el).find('.editor').css(height: '400px')
