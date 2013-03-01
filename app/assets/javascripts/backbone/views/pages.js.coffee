class Wiki.Views.Pages extends Backbone.View

  el: "#page"

  initialize: ->
    @model.get('sections').bind('add', @addSection, @)
    @model.bind('change', @render, @)
    @model.get('sections').bind('change', @saveSectionEdit, @)
    @listen = false
    @render()
    @addAllSections()
    self = @
    @model.get('triples').fetch({
      url: self.model.get('triples').urlBase + self.model.get('title').replace(":", "-3A")
      dataType: 'jsonp'
      jsonpCallback: 'callback'
      success: (data,res,o) ->
          self.addAllTriples()
    })

  render: ->
    self = @
    # add page title
    $("#title h1").text(@model.get('title'))

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
          )
          setTimeout (
            -> $("#modal").modal('hide')
            200
          )
    )

    # add backlinks
    $.each @model.get('backlinks'), (i,bl) ->
      $('#backlinks').append(
        $('<a>').attr('href', '/wiki/' + bl.replace(' ', '_')).html(
           $('<p>').html($('<span>').addClass('label').text(bl))
        ).append(' ')
      )

    # remove TOC
    $('#toc').remove()

  addSection: (section) ->
    sectionview = new Wiki.Views.Sections(model: section)
    sectionview.render()

  addAllSections: ->
    self = @
    $.each @model.get('sections').models , (i, section) ->
      self.addSection(section)

  addTriple: (triple) ->
    tripleview = new Wiki.Views.Triples(model: triple)
    tripleview.render()

  addAllTriples: ->
    self = @
    $.each @model.get('triples').models , (i, triple) ->
      self.addTriple(triple)

  saveSectionEdit: ->
    $('#modal_body').html(
          $('<div>').addClass('alert alert-info')
          .text("Saving..."))
    $('#modal').modal()
    @model.save()
