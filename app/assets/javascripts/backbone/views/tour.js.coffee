class Tours.Views.Tour extends Backbone.View
  template : JST['backbone/templates/tour']

  el: '#tour'
  
  events:
    'click .tourViewEdit' : 'showEdit'
    'click .tourViewDefault' : 'hideEdit'
    'click .tourAddPage' : 'showAddPage'
    'click .tourAddSection' : 'showAddSection'
    'click .tourSavePage' : 'savePage'
    
  initialize: ->
    @model = Tours.tour
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
    for position, defaultBox of defaultBoxes
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
    pageList = document.getElementById('pages')
    console.log(pageList)
    
    newPage = document.createElement('li')
    newPage.innerHTML = '<div class="viewDefault" style="display:none;"><a href="/wiki/newPage">new Page</a></div>\n'+
                        '<div class="viewEdit"><input name="title" value="new Page"></div>\n'+
                        '<ul class="sections">\n'+
                        ' <li>\n'+
                        '  <div class="viewDefault" style="display:none;"><a href="/wiki/newPage#Section">Section</a></div>\n'+
                        '  <div class="viewEdit"><input name="title" value="Section"></div>\n'+
                        ' </li>\n'+
                        '</ul>\n'+
                        '<button class="btn-mini tourAddSection" type="button"><i class="icon-plus"></i> Add Section</button>\n'+
                        '<button class="btn-mini tourSavePage" type="button"><i class="icon-check"></i> Ok</button>'
    pageList.appendChild(newPage)

  showAddSection: (triggerEvent) ->
    triggerButton = @.getTriggerButton(triggerEvent)
    sectionsList = triggerButton.parentNode.getElementsByClassName('sections').item(0)
    #console.log(sectionsList)
    newSection = document.createElement('li')
    newSection.innerHTML = '  <div class="viewDefault" style="display:none;"><a href="/wiki/newPage#Section">Section</a></div>\n'+
                           '  <div class="viewEdit"><input name="title" value="Section"></div>\n'
    sectionsList.appendChild(newSection)


  savePage: (triggerEvent) ->
    triggerButton = @.getTriggerButton(triggerEvent)
    
    console.log(triggerButton)
    