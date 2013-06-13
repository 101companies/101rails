class Tours.Views.Tour extends Backbone.View
  template : JST['backbone/templates/tour']

  el: '#tour'
  
  events:
    'click .tourViewEdit' : 'showEdit'
    'click .tourViewDefault' : 'hideEdit'
    
  initialize: ->
    @model = Tours.tour
    @render()

  render: ->
    html = @template(title: @model.get('title'), author: @model.get('author'), pages: @model.get('pages'))
    $(@el).html(html)
    
  showEdit: (a) ->
    parent = a.target.parentNode.parentNode.parentNode
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
    
  hideEdit: (a) ->
    parent = a.target.parentNode.parentNode.parentNode
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
