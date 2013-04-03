class Wiki.Views.Pages extends Backbone.View
  el: "#page"

  events:
    'click .sectionaddbutton' : 'newSectionModal'
    'click #createSection' : 'createSection'

  initialize: ->
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
        else
          $('#modal_body').html(
            $('<div>').addClass('alert alert-success').text('Done')
            $("#modal").modal('hide')
          )
    )
    @render()

  render: ->
    self = @
    # add page title
    $("#title h1").text(@model.get('title'))

    # add backlinks
    $.each @model.get('backlinks'), (i,bl) ->
      $('#backlinks').append(
        $('<a>').attr('href', '/wiki/' + bl.replace(' ', '_')).html(
           $('<p>').html($('<span>').addClass('label').text(bl))
        ).append(' ')
      )

    # add sections
    @addAllSections()

    # add triples
    @model.get('triples').fetch({
      url: self.model.get('triples').urlBase + self.model.get('title').replace(":", "-3A")
      dataType: 'jsonp'
      jsonpCallback: 'callback'
      success: (data,res,o) ->
          self.addAllTriples()
    })

     # add resources
    @model.get('resources').fetch({
      url: self.model.get('resources').urlBase + self.model.get('title').replace(":", "-3A") + '.jsonp'
      dataType: 'jsonp'
      jsonpCallback: 'resourcecallback'
      success: (data,res,o) ->
        self.addResources()
    })

    # add source links
    contribPrefix = "Contribution:"
    if @model.get('title').substring(0, contribPrefix.length) == contribPrefix
      @model.get('sourceLinks').fetch({
        url: self.model.get('sourceLinks').urlBase + self.model.get('title').substring(contribPrefix.length) + '.jsonp'
        dataType: 'jsonp'
        jsonpCallback: 'sourcelinkscallback'
        success: (data, res, o) ->
          self.addSourceLinks()
      })

    # remove TOC
    $('#toc').remove()

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
    tripleview = new Wiki.Views.Triples(model: triple)
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

  saveSectionEdit: ->
    $('#modal_body').html(
          $('<div>').addClass('alert alert-info')
          .text("Saving..."))
    $('#modal').modal()
    @model.save()
