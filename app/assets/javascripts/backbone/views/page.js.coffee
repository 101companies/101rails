class Wiki.Views.Page extends Backbone.View
  el: "#page"

  expandableTemplate : JST['backbone/templates/expandable']

  events:
    'click #sectionAddButton' : 'newSectionModal'
    'click #createSection' : 'createSection'
    'click #pageCancelButton' : 'cancel'
    'click #pageDeleteButton' : 'delete'
    'click #pageSaveButton' : 'save'
    'mouseover a[href^="/wiki/"]': 'tooltipHeadline'
    'mouseleave a[href^="/wiki/"]' :'tooltipLeft'

  linksCount: 0

  initialize: ->
    @inedit = false
    @model.get('sections').bind('add', @addSection, @)
    #@model.bind('change', @render, @)
    @model.get('sections').bind('change', @saveSectionEdit, @)
    # modal for completed ajax
    $(document).ajaxComplete((event, res, settings) ->
      if settings.url.lastIndexOf("/api/pages/", 0) == 0
        unless res.status == 200
          $('#modal_body').html(
            $('<div>').addClass('alert alert-error')
              .text("Something went wrong: " + res.statusText))
          $('#modal').modal()
    )
    @render()

  render: ->
    self = @

    # add page title
    niceTitle = @model.get('title').replace(/_/g, ' ')
    colonSplit = niceTitle.split(":")
    if colonSplit.length > 1
      $('#title h1')
        .append($('<span class="title-prefix">').text(colonSplit[0] + ":"))
        .append(colonSplit[1])
    else
    $("#title h1").text(niceTitle)


    # add sub-views (FIXME: Add collection views for other model collections)
    @addSections()
    @addBacklinks()
    @fetchResources()
    @fetchSourceLinks()

    # add discovery tab
    upperTitle = @model.get('title').charAt(0).toUpperCase() + @model.get('title').slice(1);
    $('#discovery-tab-link').attr('href', 'http://101companies.org/resources?format=html&wikititle=' + upperTitle)

    # remove TOC
    $('#toc').remove()

    # add handlers
    @editb = $('#pageEditButton')
    @editb.click( -> self.initedit())
    @notEditingButtons = $('#top .notEditing')
    @editingButtons = $('#top .editing')
    if not _.contains(Wiki.currentUser.get('actions'), "Edit")
      @notEditingButtons.hide()

    # temporary fixes
    $('a[href^=imported]').remove()

    # enable tool-tips
    $('a[href^="/wiki/"]', @el).tooltip(delay: {show: 250})

  fetchResources: ->
    self = @
    @model.get('resources').fetch({
      url: self.model.get('resources').urlBase + self.escapeURI(self.model.get('title')) + '.jsonp'
      dataType: 'jsonp'
      jsonpCallback: 'resourcecallback'
      success: (data,res,o) ->
        self.addResources()
    })

  fetchSourceLinks: ->
    self = @
    contribPrefix = "contribution:"
    if @model.get('title').toLowerCase().substring(0, contribPrefix.length) == contribPrefix
      @model.get('sourceLinks').fetch({
        url: self.model.get('sourceLinks').urlBase + self.model.get('title').substring(contribPrefix.length) + '.jsonp'
        dataType: 'jsonp'
        jsonpCallback: 'sourcelinkscallback'
        success: (data, res, o) ->
          self.addSourceLinks()
      })

  escapeURI: (uri) ->
    decodeURIComponent(uri
      .replace(/\-/g, '-2D')
      .replace(/\:/g, "-3A")
      .replace(/\s/g, '_')
    )

  addSection: (section, sections, options) ->
    args = {model: section}
    if section.get('title') == 'Metadata'
        args.subview = new Wiki.Views.Triples(model: @model.get('triples'))
        args.subId = 'metasection'
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
    $.each @model.get('backlinks'), (i,bl) ->
      if i < 21
        target = '#backlinks-body'
      else
        if i == 21
          $('#backlinks')
            .append($("<br>"))
            .append(self.expandableTemplate(name: 'backlinks-continued'))
        target = '#backlinks-continued'
      $(target).append(
        $('<a>').attr('href', '/wiki/' + bl.replace(/\s/g, '_')).html(
          $('<div>').html($('<span>').addClass('label').text(bl.replace(/_/g, ' ')))
        ).append(' ')
      )

  newSectionModal: ->
    $('#creationmodal').modal()

  createSection: ->
    $("#creationmodal").modal('hide')
    newtitle = $('#sname').val()
    newsection = new Wiki.Models.Section({title: newtitle, content: "==" + newtitle + "=="})
    @model.get('sections').add([newsection], {at: document.getElementById('sposition').selectedIndex})

  addResource: (resource) ->
    resourceview = new Wiki.Views.Resources(model: resource)
    resourceview.render()

  addResources: ->
    self = @
    resources = _.filter(@model.get('resources').models, (r) -> not r.get('error'))
    if resources
      $.each resources, (i,r) ->
        self.addResource(r)

  addSourceLink: (link) ->
    sourceview = new Wiki.Views.SourceLink(model: link)
    sourceview.render()

  addSourceLinks: ->
    self = @
    $('#sourcelinks').find('.dropdown-menu').html('')
    $.each @model.get('sourceLinks').models, (i, link) ->
      self.addSourceLink(link)

  fillEditor: ->
    if @model.get('sections').models.length == 0
      allcontents = @model.get('content')
    else
      allcontents = @model.get('sections').models.reduce(((agg, cur) -> agg + cur.get('content') + "\n\n"), '')
    @editor.setValue(allcontents)

  initedit: ->
    @toggleEdit(true)
    editorid = 'pageeditor'
    @editor = ace.edit(editorid)
    @editor.setTheme("ace/theme/chrome")
    @editor.getSession().setMode("ace/mode/text")
    @editor.getSession().setUseWrapMode(true)
    @fillEditor()
    @editor.navigateFileStart()
    enable_spellcheck(editorid)

  edit: ->
    @toggleEdit(true)

  save: ->
    newcontent = @editor.getValue()
    if newcontent != @model.get('content')
      $(@el).find("#top .loading-indicator").show()
    @model.save({'content' : newcontent}, {success: -> location.reload()})

  cancel: (button) ->
    @toggleEdit(false)
    @fillEditor()

  delete: ->
    @model.destroy(success: ->
      if history.length > 1
        history.back()
      else
        document.location.href = '/wiki'
    )

  toggleEdit: (open) ->
    self = @
    if open
      $(@el).find('#sections').animate({marginLeft: '-100%'}, 300)
      $(@el).find('#sections-source').css(height: '400px')
      $(@el).find('#pageeditor').css(height: '400px')
      $(@notEditingButtons).hide()
      $(@editingButtons).show()
    else
      $(@el).find('#sections').animate({marginLeft: '0%'}, 300)
      $(@el).find('#sections-source').css(height: '0px')
      $(@el).find('#pageeditor').css(height: '0px')
      $(@editingButtons).hide()
      $(@notEditingButtons).show()

  saveSectionEdit: (section) ->
    self = @
    @model.set('content', '')
    index = @model.get('sections').indexOf(section)
    indicator = $(@el).find('#sections .loading-indicator')[index]
    console.log($(@el).find('#sections .loading-indicator')[index])
    $(indicator).show()
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

  tooltipHeadline: (event) ->
    $target = $(event.target)
    $target.addClass('hovered')
    if ($target.attr('data-original-title') == '')
      $target.attr('data-original-title', 'Loading headline...')
      linkTitle = $target.attr('href').replace('/wiki/', '').replace(/^\s+|\s+$/g, '')
      linkDiscovery = new Wiki.Models.PageDiscovery(title: linkTitle)
      linkDiscovery.fetch({
        dataType: 'jsonp'
        success: (model) ->
          headline = model.get('headline').charAt(0).toUpperCase() + model.get('headline').slice(1);
          if headline == ''
            headline = "Page does not have a headline."
          $target.attr('title', headline).tooltip('fixTitle')
          if $target.hasClass('hovered')
            $target.tooltip('show')
        error: ->
          $target.attr('title', "Page not found.").tooltip('fixTitle')
          if $target.hasClass('hovered')
            $target.tooltip('show')
      })

  tooltipLeft: (event) ->
    $(event.target).removeClass("hovered")
