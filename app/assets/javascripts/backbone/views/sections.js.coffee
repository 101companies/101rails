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
    if not _.contains(Wiki.currentUser.get('actions'), "Edit")
      $(@el).find('.editbutton').css("display", "none")

  edit: (button) ->
    self = @
    @toggleEdit(true)
    self.editor = ace.edit($(self.el).find('.editor')[0]);
    self.editor.setTheme("ace/theme/chrome");
    self.editor.getSession().setMode("ace/mode/text");
    self.editor.setValue(self.model.get('content'))
    $(button).find('strong').text("Save")
    $(button).unbind('click').bind('click', -> self.save(button))

  save: (button) ->
    self = @
    $.ajax({
      type: "POST"
      url: "/api/parse/"
      data: {content: self.editor.getValue()}
      success: (data) ->
        if data.success
          $(self.el).find('.section-content-parsed').html(data.html).find("h2").remove()
          alert "foo"
          self.model.set('content', self.editor.getValue())
          self.toggleEdit(false)
    })
    $(button).find('strong').text("Edit")
    $(button).unbind('click').bind('click', -> self.edit(button))

  toggleEdit: (open) ->
    if open
      $(@el).find('.section-content').animate({marginLeft: '-100%'}, 400)
      $(@el).find('.section-content-source').css(height: '400px')
      $(@el).find('.editor').css(height: '400px')
    else
      $(@el).find('.section-content').animate({marginLeft: '0%'}, 400)
      $(@el).find('.section-content-source').css(height: '0px')
      $(@el).find('.editor').css(height: '0px')
