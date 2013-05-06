class Wiki.Views.Pages extends Backbone.View
  el: "#page"

  expandableTemplate : JST['backbone/templates/expandable']

  events:
    'click #sectionAddButton' : 'newSectionModal'
    'click #createSection' : 'createSection'
    'click #pageCancelButton': 'cancel'
    'click #pageDeleteButton': 'delete'

  internalTripleCount: 0
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
    cleanTitle = @model.get('title').replace(/_/g, ' ')
    colonSplit = cleanTitle.split(":")
    if colonSplit.length > 1
      $('#title h1')
        .append($('<span class="title-prefix">').text(colonSplit[0] + ":"))
        .append(colonSplit[1])
    else
      $("#title h1").text(cleanTitle)

    # add backlinks
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

    # add sections
    @addAllSections()

    # add triples
    @model.get('triples').fetch({
      url: self.model.get('triples').urlBase + self.escapeURI(self.model.get('title'))
      dataType: 'jsonp'
      jsonpCallback: 'callback'
      success: (data,res,o) ->
          self.addAllTriples()
    })

     # add resources
    @model.get('resources').fetch({
      url: self.model.get('resources').urlBase + self.escapeURI(self.model.get('title')) + '.jsonp'
      dataType: 'jsonp'
      jsonpCallback: 'resourcecallback'
      success: (data,res,o) ->
        self.addResources()
    })

    # add source links
    contribPrefix = "contribution:"
    if @model.get('title').toLowerCase().substring(0, contribPrefix.length) == contribPrefix
      @model.get('sourceLinks').fetch({
        url: self.model.get('sourceLinks').urlBase + self.model.get('title').substring(contribPrefix.length) + '.jsonp'
        dataType: 'jsonp'
        jsonpCallback: 'sourcelinkscallback'
        success: (data, res, o) ->
          self.addSourceLinks()
      })

    # remove TOC
    $('#toc').remove()

    # add handlers
    @editb = $('#pageEditButton')
    @editb.click( -> self.initedit())
    @canelb = $('#pageCancelButton')
    @deleteb = $('#pageDeleteButton')
    @newsectionb = $('#sectionAddButton')
    if not _.contains(Wiki.currentUser.get('actions'), "Edit")
      @editb.css("display", "none")
      @newsectionb.css("display", "none")
      @deleteb.css("display", "none")
    else
      @editb.click( -> self.initedit())

    # temporary fixes
    $('a[href^=imported]').remove()

  escapeURI: (uri) ->
    result = decodeURIComponent(uri
      .replace(/\-/g, '-2D')
      .replace(/\:/g, "-3A")
      .replace(/\s/g, '_')
    )
    result

  addSection: (section, sections, options) ->
    sectionview = new Wiki.Views.Sections(model: section)
    sectionview.render(options)

  addAllSections: ->
    self = @
    $('#sposition').html('')
    $('#sposition').append($('<option>').text('(before first section)'))
    $.each @model.get('sections').models , (i, section) ->
      if section.get('title') != "Metadata"
        $('#sposition').append($('<option>').text(section.get('title')))
      self.addSection(section)

  newSectionModal: ->
    $('#creationmodal').modal()

  createSection: ->
    $("#creationmodal").modal('hide')
    newtitle = $('#sname').val()
    newsection = new Wiki.Models.Section({title: newtitle, content: "==" + newtitle + "=="})
    @model.get('sections').add([newsection], {at: document.getElementById('sposition').selectedIndex})

  addInternalTriple: (triple) ->
    if @internalTripleCount < 13
      el = '#metasection .section-content-parsed'
    else
      if @internalTripleCount == 13
        $('#metasection').append(@expandableTemplate(name: "metasection-continued"))
      el = "#metasection-continued"
    tripleview = new Wiki.Views.Triples(model: triple, el: el)
    tripleview.render()


  addExternalTriple: (triple) ->
    tripleview = new Wiki.Views.ExTriples(model: triple)
    tripleview.render()

  is101Triple: (triple) ->
    internalPrefix = 'http://101companies.org/'
    triple.get('node').substring(0, internalPrefix.length) == internalPrefix

  tripleOrdering: (a,b) ->
    if a.get('predicate') < b.get('predicate')
      -1
    else if a.get('predicate') > b.get('predicate')
      1
    else if a.get('node') < b.get('node')
      -1
    else if a.get('node') > b.get('node')
      1
    else
      0

  addAllTriples: ->
    self = @
    $.each @model.get('triples').models.sort(self.tripleOrdering), (i, triple) ->
      if self.is101Triple(triple)
        self.internalTripleCount++;
        self.addInternalTriple(triple)
      else
        self.addExternalTriple(triple)

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
    githubview = new Wiki.Views.SourceLink(model: link)
    githubview.render()

  addSourceLinks: ->
    $('#sourcelinks').find('.dropdown-menu').html('')
    self = @
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
      $(@el).find("#topeditbar .loading-indicator").css('visibility', 'visible')
    @model.save({'content' : newcontent}, {success: -> location.reload()})

  cancel: (button) ->
    @toggleEdit(false)
    @fillEditor()

  delete: ->
    @model.destroy(success: -> document.location.href = '/')

  toggleEdit: (open) ->
    self = @
    if open
      $(@el).find('#sections').animate({marginLeft: '-100%'}, 300)
      $(@el).find('#sections-source').css(height: '400px')
      $(@el).find('#pageeditor').css(height: '400px')
      @editb.find("i").attr("class", "icon-ok")
      @editb.find('strong').text("Save")
      @editb.unbind('click').bind('click', -> self.save())
      @canelb.show()
      @newsectionb.hide()
    else
      $(@el).find('#sections').animate({marginLeft: '0%'}, 300)
      $(@el).find('#sections-source').css(height: '0px')
      $(@el).find('#pageeditor').css(height: '0px')
      @editb.find('strong').text("Edit")
      @editb.unbind('click').bind('click', -> self.edit())
      @canelb.hide()
      @newsectionb.show()

  saveSectionEdit: (section) ->
    index = @model.get('sections').indexOf(section)
    indicator = $(@el).find('#sections .loading-indicator')[index]
    $(indicator).css('visibility', 'visible')
    @model.save({},
      success: -> $(indicator).css('visibility', 'hidden')
      error: -> $(indicator).css('visibility', 'hidden')
    )
