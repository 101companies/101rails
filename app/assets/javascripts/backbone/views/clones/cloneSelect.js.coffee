class Wiki.Views.CloneSelect extends Backbone.View
  template : JST['backbone/templates/cloneSelect']

  events:
    'click': 'select'

  initialize: (options) ->
    self = @
    @clone = options.clone
    @clone.on('change:original', -> self.toggleSelect())
    @title = options.candiate
    @setElement(@template(title: @title))
    $('#candidates-container').append(@el)

  select: ->
   @clone.set('original', @title)

  toggleSelect: ->
    $(@el).find('span').toggleClass('badge-success', @clone.get('original') == @title)
