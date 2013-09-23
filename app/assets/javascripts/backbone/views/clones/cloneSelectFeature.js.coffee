class Wiki.Views.CloneSelectFeature extends Backbone.View
  template : JST['backbone/templates/cloneSelectFeature']

  events:
    'click': 'trigger'

  initialize: (options) ->
    @clone = options.clone
    @title = options.feature
    @detectable = options.detections.length > 0
    @impliedBy = options.impliedBy
    @selected = true
    @setElement(@template(title: @title))
    $('#features').append(@el)
    @showStatus()

  showStatus: ->
    $(@el).find('.badge').toggleClass('badge-success', @selected)

  trigger: ->
    self = @
    $('.text-error').text("")
    confliciting = _.filter(@impliedBy, (other) -> _.contains(self.clone.get('features'), other.replace(/\s/g, '_')))
    if confliciting.length > 0
      text = "Sorry, this feature can only be deselected if you deselect <b>" + confliciting.join("</b>, <b> ") + "</b>."
      $(@el).find('.text-error').html(text)
    else if not @detectable
      $(@el).find('.text-error').text("Sorry, this feature can currently not be deselected.")
    else
      features = @clone.get('features')
      minusfeatures = @clone.get('minusfeatures')
      if @selected
        features = _.difference(features, [@title])
        minusfeatures = _.union(minusfeatures, [@title])
      else
        minusfeatures = _.difference(minusfeatures, [@title])
        features = _.union(features, [@title])
      @clone.set('features', features)
      @clone.set('minusfeatures', minusfeatures)
      @selected = not @selected
      @showStatus()
