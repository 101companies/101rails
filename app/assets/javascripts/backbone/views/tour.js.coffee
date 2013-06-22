class Tours.Views.Tour extends Backbone.View
  template : JST['backbone/templates/tour']

  el: '#tour'

  events:
    'mouseover .viewDefault' : 'showEditButton'
    'mouseout .viewDefault' : 'hideEditButton'
    'click .tourShowEdit' : 'showEdit'
    'click .tourAddPage' : 'showAddPage'
    'click .tourAddSection' : 'showAddSection'
    'click .tourRemovePage' : 'removePage'
    'click .tourRemoveSection' : 'removeSection'
    'click .tourSave' : 'updateTour'
    #'click .tour' : 'updateTour'

  initialize: ->
    @model = Tours.tour
    @size = @model.get('pages').length
    @render()

  render: ->
    html = @template(title: @model.get('title'), author: @model.get('author'), pages: @model.get('pages'))
    $(@el).html(html)

  getTriggerButton: (triggerEvent) ->
    triggerButton = triggerEvent.target
    while (triggerButton.tagName != 'BUTTON')
      #console.log(triggerElement.tagName)
      triggerButton = triggerButton.parentNode
    triggerButton
    
  getTriggerByClass: (triggerEvent, className) ->
    triggerButton = triggerEvent.target
    while (triggerButton.className != className)
      #console.log(triggerElement.tagName)
      triggerButton = triggerButton.parentNode
    triggerButton

  showEditButton: (triggerEvent) ->
    triggerElement = @.getTriggerByClass(triggerEvent, 'viewDefault')
    #console.log(triggerElement)
    editButtons = $(triggerElement).find('.editButtons')
    #console.log(editButton)
    $(editButtons).css('display', 'inline')

  hideEditButton: (triggerEvent) ->
    triggerElement = @.getTriggerByClass(triggerEvent, 'viewDefault')
    editButtons = $(triggerElement).find('.editButtons')
    $(editButtons).css('display', 'none')

  showEdit: (triggerEvent) ->
    triggerElement = @.getTriggerButton(triggerEvent)

    parent = triggerElement.parentNode.parentNode.parentNode
    #console.log(parent)

    defaultBoxes = parent.getElementsByClassName('viewDefault')
    #console.log(defaultBoxes)
    for defaultBox in defaultBoxes
      try
        #console.log(defaultBox)
        defaultBox.style.display = 'none'
      catch error
        console.log(error)

    editBoxes = parent.getElementsByClassName('viewEdit')
    #console.log(editBoxes)
    for position, editBox of editBoxes
      try
        #console.log(editBox)
        editBox.style.display = 'block'
      catch error
        console.log(error)

  showAddPage: ->
    pageList = $.find('#pages')
    $(pageList).append(
      '<li class="page">\n'+
      ' <div>\n'+
      '  <div class="viewDefault">'+
      '   <a class="titleLink" href="/wiki/newPage">new Page</a>\n'+
      '   <span class="editButtons">\n' +
      '    <button class="btn-mini tourShowEdit" type="button"><i class="icon-pencil"></i></button><button class="btn-mini tourRemovePage" type="button"><i class="icon-remove"></i></button>\n'+
      '   </span>\n'+
      '  </div>\n'+
      '  <div class="viewEdit"><input class="pageTitle" value="new Page"></div>\n'+
      ' </div>\n'+
      ' <ul class="sections">\n'+
      '  <li class="section">\n'+
      '   <div class="viewDefault">\n'+
      '    <a class="sectionLink" href="/wiki/newPage#Section">#Section</a>\n'+
      '    <span class="editButtons">\n' +
      '     <button class="btn-mini tourShowEdit" type="button"><i class="icon-pencil"></i></button><button class="btn-mini tourRemoveSection" type="button"><i class="icon-remove"></i></button>\n'+
      '    </span>\n'+
      '   </div>\n'+
      '   <div class="viewEdit"><input class="sectionTitle" value="Section"></div>\n'+
      '  </li>\n'+
      ' </ul>\n'+
      ' <button class="btn-mini tourAddSection" type="button"><i class="icon-plus"></i> Add Section</button>\n'
      '</li>\n'
    )

  showAddSection: (triggerEvent) ->
    triggerButton = @.getTriggerButton(triggerEvent)
    sectionsList = triggerButton.parentNode.getElementsByClassName('sections').item(0)
    #console.log(sectionsList)
    newSection = document.createElement('li')
    $(newSection).addClass('section')
    newSection.innerHTML = '<div class="viewDefault">\n'+
                           ' <a class="sectionLink" href="/wiki/newPage#Section">#Section</a>\n'+
                           ' <span class="editButtons">\n' +
                           '  <button class="btn-mini tourShowEdit" type="button"><i class="icon-pencil"></i></button><button class="btn-mini tourRemoveSection" type="button"><i class="icon-remove"></i></button>\n'+
                           ' </span>\n'+
                           '</div>\n'+
                           '<div class="viewEdit"><input class="sectionTitle" value="Section"></div>\n'
    sectionsList.appendChild(newSection)

  removePage: (triggerEvent) ->
    triggerElement = @.getTriggerByClass(triggerEvent, 'page')
    $(triggerElement).remove()

  removeSection: (triggerEvent) ->
    triggerElement = @.getTriggerByClass(triggerEvent, 'section')
    $(triggerElement).remove()

  updateTour: (triggerEvent) ->
    authorElement = $.find(".author")[0]
    authorEdit = $(authorElement).find('.viewEdit')[0]
    author = $(authorEdit).find(".authorName")[0].value
    authorDesciption = $(authorElement).find('.viewDefault')[0]
    authorDesciption.text('by <a href="https://github.com/'+author+'">'+author+'</a>')
    #console.log(author)
    
    tourElement = $.find("#tour")[0]
    pageList = $(tourElement).find("#pages")[0]
    pageItems = $(pageList).find(".page")
    pages = []
    i = 0

    for pageItem in $(pageItems)
      pageTitle = $(pageItem).find(".pageTitle")[0].value
      console.log(pageTitle)
      pageTitleLink = $(pageItem).find(".titleLink")[0]
      #console.log($(pageTitleLink))
      $(pageTitleLink).attr('href', '/wiki/'+pageTitle);
      $(pageTitleLink).text(pageTitle);
      sectionList =  $(pageItem).find(".sections")[0]
      sectionItems = $(sectionList).find(".section")
      sections = []
      j = 0

      for sectionItem in $(sectionItems)
        sectionTitle = $(sectionItem).find(".sectionTitle")[0].value
        sectionLink = $(sectionItem).find(".sectionLink")[0]
        $(sectionLink).attr('href', '/wiki/'+pageTitle+'#'+sectionTitle);
        $(sectionLink).text('#'+sectionTitle);
        sections[j++] = sectionTitle

      pages[i++] = new Tours.Models.TourPage(
        title: pageTitle
        sections: sections
      )

    @model.save(
      {
        author: author
        pages: pages
      }
      success: ->
        console.log(@model)
        
        $(authorElement).find('.viewEdit')[0].css('display', 'none')
        $(authorElement).find('.viewDefault')[0].css('display', 'block')
        
        for pageItem in $(pageItems)
          editViews = $(pageItem).find('.viewEdit')
          #console.log(editViews)
          
          for editView in $(editViews)
            console.log($(editView))
            $(editView).css('display', 'none')
            
          defaultViews = $(pageItem).find('.viewDefault')
          for defaultView in $(defaultViews)
            $(defaultView).css('display', 'block')
    )
