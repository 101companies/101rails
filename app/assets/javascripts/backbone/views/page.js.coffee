class Wiki.Views.Page extends Backbone.View
  el: "#page"

  pageTemplate: JST['backbone/templates/page']
  expandableTemplate: JST['backbone/templates/expandable']
  editormenuTemplate: JST['backbone/templates/editormenu']

  events:
    'click #sectionAddButton' : 'newSectionModal'
    'click #createSection' : 'createSection'
    'click #pageCancelButton' : 'cancel'
    'click #pageSourceButton' : 'showSource'
    'click #pageDeleteButton' : 'initdelete'
    'click #pageDeleteSubmit' : 'delete'
    'click #pageSaveButton' : 'save'
    'click #pageRenameButton' : 'initRename'
    'click #pageRenameSubmit' : 'rename'

    #editor
    'click #pageeditor button' : "helpEditor"

  linksCount: 0

  initialize: ->
    self = @
    @inedit = false
    self.bindHanders()
    self.render()

  bindHanders: ->
    @model.get('sections').bind('add', @addSection, @)
    @model.get('sections').bind('change', @saveSectionEdit, @)
    # modal for completed ajax
    $(document).ajaxComplete((event, res, settings) ->
      if settings.url.lastIndexOf("/api/pages/", 0) == 0
        unless res.status == 200
          errorMessage = JSON.parse(res.responseText).error
          $('#modal_body').html(
            $('<div>').addClass('alert alert-error')
              .text("Something went wrong: " + errorMessage))
          $('#modal').modal()
    )

  render: ->
    self = @

    niceTitle = Wiki.Utils.atTo101(@model.get('id').replace(/_/g, ' '))

    colonSplit = niceTitle.split(":")
    if colonSplit.length > 1
      niceTitle = $('<span class="title-prefix">')
        .text(colonSplit[0])
        .prop('outerHTML') + ":" + colonSplit[1]

    $(@el).html($(@pageTemplate(title: niceTitle)))
    $('#sections-parsed').html('')

    $('#page').append($('<div id="infofooter"></div>').append('<div id="history"></div>'));
    new Wiki.Views.History(model: @model.get('history'))
    @addBacklinks()
    @addSections()
    new Wiki.Views.Resources(model: @model.get('resources'))

    # add discovery tab
    upperTitle = @model.get('id').charAt(0).toUpperCase() + @model.get('id').slice(1);
    $('#discovery-tab-link').attr('href', 'http://101companies.org/resources?format=html&wikititle=' + upperTitle)

    # add handlers
    @editb = $('#pageEditButton')
    @notEditingButtons = $('#contentTop .notEditing')
    @editingButtons = $('#contentTop .editing')
    @sourceButton = $('#pageSourceButton')
    @saveButton = $('#pageSaveButton')

    # set up buttons depending on whether user is logged-in
    if _.contains(Wiki.currentUser.get('actions'), "Edit")
      @editb.click( -> self.initEditor(false))
      @notEditingButtons.show()
      @sourceButton.remove()
    else
      @notEditingButtons.remove()
      @saveButton.remove()

    $('a[href^=imported]').remove()
    $('#disqus-loader').show()

  initRename: ->
    $('#renamemodal').modal()

  rename: ->
    newTitle = $('#newTitle').val()
    unless newTitle == ''
      $(@el).find("#renamemodal .loading-indicator").show()
      @model.save({'newTitle' : newTitle.replace(/\s/g, '_')},
        success: (model, res) ->
          console.log(res)
          $("#renamemodal").modal('hide')
          window.location = '/wiki/' + res.newTitle
      )

  addSection: (section, sections, options) ->
    args = {model: section}
    if not options
      options = {}
    if section.get('title') == 'Metadata'
        args.subview = new Wiki.Views.Triples(model: @model.get('triples'))
        args.subId = 'metasection'
        options.renderTour = true
    sectionview = new Wiki.Views.Section(args)
    sectionview.render(options)

  addSections: ->
    self = @
    $('#sposition').html('')
    $('#sposition').append($('<option>').text('(before first section)'))
    $.each @model.get('sections').models , (i, section) ->
      if section.get('title') != "Metadata"
        $('#sposition').append($('<option>').text(section.get('title')))
      self.addSection(section)

  addBacklinks: ->
    self = @
    if @model.get('backlinks').length > 0
      $('#backlinks').show()
    $.each @model.get('backlinks'), (i,bl) ->
      if i < 21
        target = '#backlinks-body'
      # cut visible backlinks after 21
      else
        if i == 21
          $('#backlinks')
            .append($("<br>"))
            .append(self.expandableTemplate(name: 'backlinks-continued'))
        target = '#backlinks-continued'
      $(target).append(
        $('<a>').attr('href', '/wiki/' + bl.replace(/\s/g, '_')).html(
          $('<div>').html($('<span>').addClass('label').text(Wiki.Utils.atTo101(bl.replace(/_/g, ' '))))
        ).append(' ')
      )

  newSectionModal: ->
    $('#creationmodal').modal()

  createSection: ->
    $("#creationmodal").modal('hide')
    newtitle = $('#sname').val()
    newsection = new Wiki.Models.Section({title: newtitle, content: "==" + newtitle + "=="})
    @model.get('sections').add([newsection], {at: document.getElementById('sposition').selectedIndex})

  fillEditor: ->
    if @model.get('sections').models.length == 0
      allcontents = @model.get('content')
    else
      allcontents = @model.get('sections').models.reduce(((agg, cur) -> agg + cur.get('content') + "\n\n"), '')
    @editor.setValue(allcontents)
    @editor.navigateFileStart()

  helpEditor: (options) ->
    self = @
    helps =
      'bold': {start: "'''", end: "'''"}
      'italic': {start: "''", end: "''"}
      'headline': {start: "==", end: "=="}
      'link': {start: "[[", end: "]]"}
      'code': {start: "<syntaxhighlight lang=\"???\">\n", end: "\n</syntaxhighlight>"}
    toInsert = $(options.currentTarget).attr('data-editoraction')
    help = helps[toInsert]
    toWrap = @editor.getSession().getTextRange(@editor.getSelectionRange())
    @editor.getSession().replace(@editor.getSelectionRange(), help.start + toWrap + help.end)
    @editor.navigateRight(help.end.length)

  showSource: ->
    @initEditor(true)

  initEditor: (readOnly) ->
    self = @
    @toggleEdit(true)
    editorid = 'pageeditor-content'
    @editor = ace.edit(editorid)
    @editor.setTheme("ace/theme/wiki")
    @editor.getSession().setMode("ace/mode/wiki")
    @editor.getSession().setUseWrapMode(true)
    @editor.setReadOnly(readOnly)
    @editor.on('change', -> self.editor.replaceAll('[[@', needle: '[[101'))
    if not readOnly
      @editb.unbind('click').bind('click', -> self.edit())
      $(@el).find('#pageeditor').prepend(@editormenuTemplate())
      enable_spellcheck(editorid)
    @fillEditor()

  edit: ->
    @fillEditor()
    @toggleEdit(true)

  save: ->
    newcontent = @editor.getValue()
    if newcontent != @model.get('content')
      $(@el).find("#contentTop .loading-indicator").show()
    @model.save({'content' : newcontent},
      success: (model, res) ->
        location.reload()
    )

  cancel: (button) ->
    @toggleEdit(false)
    @fillEditor()

  initdelete: ->
    $('#deletionmodal').modal()

  delete: ->
    @model.destroy(success: ->
      if history.length > 2
        history.back()
      else
        document.location.href = '/wiki'
    )

  toggleEdit: (open) ->
    self = @
    if open
      $(@el).find('#sections').animate({marginLeft: '-100%'}, 300)
      $(@el).find('#sections-source').css(height: '400px')
      $(@el).find('#pageeditor').show()
      $(@notEditingButtons).hide()
      $(@sourceButton).hide()
      $(@editingButtons).show()
    else
      $(@el).find('#sections').animate({marginLeft: '0%'}, 300)
      $(@el).find('#sections-source').css(height: '0px')
      $(@el).find('#pageeditor').hide()
      $(@editingButtons).hide()
      $(@notEditingButtons).show()
      $(@sourceButton).show()

  saveSectionEdit: (section) ->
    self = @
    @model.set('content', '')
    index = @model.get('sections').indexOf(section)
    indicator = $(@el).find('#sections .loading-indicator')[index]
    isMetasection = section.get('title') == 'Metadata'
    if isMetasection
      $('#metasection .section-content-parsed').fadeTo(0, 0.2)
    @model.save({},
      success: ->
        unless isMetasection
          $(indicator).hide()
        section.trigger('sync')
      error: -> $(indicator).hide()
    )
