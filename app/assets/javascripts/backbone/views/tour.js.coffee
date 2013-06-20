class Tours.Views.Tour extends Backbone.View
  template : JST['backbone/templates/tour']

  el: '#tour'
  
  events:
    'click .tourViewEdit' : 'showEdit'
    'click .tourViewDefault' : 'hideEdit'
    'click .tourAddPage' : 'showAddPage'
    'click .tourAddSection' : 'showAddSection'
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
    
    
  showEdit: (triggerEvent) ->
    triggerElement = @.getTriggerButton(triggerEvent)
      
    parent = triggerElement.parentNode.parentNode
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
    
  hideEdit: (triggerEvent) ->
    triggerElement = @.getTriggerButton(triggerEvent)
    parent = triggerElement.parentNode.parentNode
    #console.log(parent)
    
    defaultBoxes = parent.getElementsByClassName('viewDefault')
    #console.log(defaultBoxes)
    for position, defaultBox of defaultBoxes
      try
        #console.log(defaultBox)
        defaultBox.style.display = 'block'
      catch error
        console.log(error)
      
    editBoxes = parent.getElementsByClassName('viewEdit')
    #console.log(editBoxes)
    for position, editBox of editBoxes
      try
        #console.log(editBox)
        editBox.style.display = 'none'
      catch error
        console.log(error)
        
  showAddPage: ->
    pageList = $.find('#pages')
    #console.log(pageList)
    
    newPage = document.createElement('li')
    $(newPage).addClass('page')
    newPage.innerHTML = '<div class="viewDefault" style="display:none;"><a href="/wiki/newPage">new Page</a></div>\n'+
                        '<div class="viewEdit"><input class="pageTitle" value="new Page"></div>\n'+
                        '<ul class="sections">\n'+
                        ' <li class="section">\n'+
                        '  <div class="viewDefault" style="display:none;"><a href="/wiki/newPage#Section">Section</a></div>\n'+
                        '  <div class="viewEdit"><input class="sectionTitle" value="Section"></div>\n'+
                        ' </li>\n'+
                        '</ul>\n'+
                        '<button class="btn-mini tourAddSection" type="button"><i class="icon-plus"></i> Add Section</button>\n'
    $(pageList).append(newPage)

  showAddSection: (triggerEvent) ->
    triggerButton = @.getTriggerButton(triggerEvent)
    sectionsList = triggerButton.parentNode.getElementsByClassName('sections').item(0)
    #console.log(sectionsList)
    newSection = document.createElement('li')
    $(newSection).addClass('section')
    newSection.innerHTML = '  <div class="viewDefault" style="display:none;"><a href="/wiki/newPage#Section">Section</a></div>\n'+
                           '  <div class="viewEdit"><input class="sectionTitle" value="Section"></div>\n'
    sectionsList.appendChild(newSection)


  updateTour: (triggerEvent) ->
    tourElement = $.find("#tour")[0]
    author = $(tourElement).find(".author")[0].value
    pageList = $(tourElement).find("#pages")[0]
    pageItems = $(pageList).find(".page")
    pages = []
    i = 0
    
    for pageItem in $(pageItems)
      pageTitle = $(pageItem).find(".pageTitle")[0].value
      console.log(pageTitle)
      sectionList =  $(pageItem).find(".sections")[0]
      sectionItems = $(sectionList).find(".section")
      sections = []
      j = 0
      
      for sectionItem in $(sectionItems)
        sectionTitle = $(sectionItem).find(".sectionTitle")[0].value
        sections[j++] = sectionTitle
      
      pages[i++] = new Tours.Models.TourPage(
        title: pageTitle
        sections: sections
      )
      
    console.log(pages)

    @model.save(
      {
        author: author
        pages: pages
      }
    )