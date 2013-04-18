class Wiki.Views.Sections extends Backbone.View
  template : JST['backbone/templates/section']

  events:
    'click .foldbutton' : 'fold'
    'click .cancelbutton': 'cancel'

  initialize: ->
    @model.bind('error', @error, @)
    @model.bind('sync', @foo, @)

  render: (options) ->
    self = @
    # get prerendered headline node
    preRendered = $('#' + @model.get('title').replace(/\s/, '_')).parent()
    $section = $(@template(title: @model.get('title')))
    unless options

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
      preRendered.after($section).remove()
      @setElement($section)
      @insertHTML($set)

    else
      $section = $(@template(title: @model.get('title')))
      index = 3 + 2 * options.at
      $('#sections .section:nth-child('+ index + ')').before($section)
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
      @editb.click( -> self.initedit())

  insertHTML : (html) ->
    $(@el).find('.section-content-parsed').html(html).find("h2").remove()

  initedit: ->
    self = @
    @toggleEdit(true)
    editordiv = $(@el).find('.editor')[0]
    editorid = @model.get('title').replace(' ', '-') + 'editor'
    $(editordiv).attr('id', editorid)
    @editor = ace.edit(editordiv)
    @editor.setTheme("ace/theme/chrome")
    @editor.getSession().setMode("ace/mode/text")
    @editor.getSession().setUseWrapMode(true)
    @editor.setValue(@model.get('content'))
    @editor.navigateFileStart()
    enable_spellcheck(editorid)

  edit: ->
    @toggleEdit(true)

  save: ->
    self = @
    text = @editor.getValue()
    `matches = text.match(/==([^\r\n=])+==/g)`
    if matches
      `newheadline = matches[0].replace(/==/g,'').trim()`
      $(@el).find('.headline').text(newheadline)
      $.ajax({
        type: "POST"
        url: "/api/parse/"
        data: {content: text}
        success: (data) ->
          unless self.model.get('title') == 'Metadata'
            self.insertHTML(data.html)
          self.model.set('content': self.editor.getValue(), 'title': newheadline)
          self.model.set()
          self.toggleEdit(false)
      })
    else
      @showError("Validation Error: Section header missing")

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

  error: (model, err, options) ->
    @showError(err)

  showError: (err) ->
    $('#modal_body').html(
      $('<div>').addClass('alert alert-error')
        .text(err))
    $('#modal').modal()

