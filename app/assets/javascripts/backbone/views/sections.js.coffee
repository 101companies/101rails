class Wiki.Views.Sections extends Backbone.View
  template : JST['backbone/templates/section']

  render: ->
    self = @
    # get prerendered headline node
    preRendered = $('#' + @model.get('title')).parent()

    # collect prerendered content nodes
    $set = $()
    if preRendered[0]
      nxt = preRendered[0].nextSibling
      while nxt
        unless $(nxt).is('h2') or not nxt.nextSibling
          $set.push nxt
          nxt = nxt.nextSibling
        else
          break


    # replace prerendered section by template
    $section = $(@template(title: @model.get('title')))
    $section.find('.section-content-parsed').append($set)
    preRendered.after($section).remove()
    @setElement($section)

    # fix links
    $.each $(@el).find('a') , (a) ->
        if $(@).attr('href')
          $(@).attr('href', $(@).attr('href').replace(/\/wiki\/(\b[a-z])/g, (s,match) ->
            '/wiki/' + match.toUpperCase())
          )

    # hide metadata section
    if @model.get('title') == "Metadata"
      $(@el).find('.section-content-parsed').html("")
      $(@el).attr('id','metasection')

    # buttons and handlers
    @editb = $(@el).find('.editbutton')
    @canelb = $(@el).find('.cancelbutton')
    @foldb = $(@el).find('.foldbutton')
    if not _.contains(Wiki.currentUser.get('actions'), "Edit")
      @editb.css("display", "none")
    else
      @editb.click( -> self.edit())
      @canelb.click( -> self.cancel())
     @foldb.click( -> self.fold())

  edit: ->
    self = @
    @toggleEdit(true)
    @editor = ace.edit($(@el).find('.editor')[0])
    @editor.setTheme("ace/theme/chrome")
    @editor.getSession().setMode("ace/mode/text")
    @editor.setValue(@model.get('content'))
    @editor.navigateFileStart()

  save: ->
    self = @
    $.ajax({
      type: "POST"
      url: "/api/parse/"
      data: {content: self.editor.getValue()}
      success: (data) ->
        $(self.el).find('.section-content-parsed').html(data.html).find("h2").remove()
        self.model.set('content', self.editor.getValue())
        self.toggleEdit(false)
    })

  cancel: (button) ->
    @toggleEdit(false)
    @editor.setValue(@model.get('content'))

  toggleEdit: (open) ->
    self = @
    if open
      $(@el).find('.section-content').animate({marginLeft: '-100%'}, 300)
      $(@el).find('.section-content-source').css(height: '400px')
      $(@el).find('.editor').css(height: '400px')
      @editb.find("i").attr("class", "icon-ok")
      @editb.find('strong').text("Save")
      @editb.unbind('click').bind('click', -> self.save())
      @canelb.show()
    else
      $(@el).find('.section-content').animate({marginLeft: '0%'}, 300)
      $(@el).find('.section-content-source').css(height: '0px')
      $(@el).find('.editor').css(height: '0px')
      @editb.find("i").attr("class", "icon-pencil")
      @editb.find('strong').text("Edit")
      @editb.unbind('click').bind('click', -> self.edit())
      @canelb.hide()

  fold: ->
      $(@el).find('.section-content-container').toggle(100)
      $(@foldb).find('i').toggleClass('icon-resize-small icon-resize-full')

