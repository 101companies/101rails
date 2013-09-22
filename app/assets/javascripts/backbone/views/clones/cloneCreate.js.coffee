class Wiki.Views.CloneCreate extends Backbone.View
  el: '#creation'
  template : JST['backbone/templates/cloneCreate']

  events:
    'keyup #name-container input': 'changeName'
    'click #submit': 'submit'

  initialize: ->
    self = @
    @clone = new Wiki.Models.Clone()
    @clone.on('change:original', -> self.pullAllFeatures())
    @clone.on('change', -> self.renderClone())
    @haskellTriples = new Wiki.Models.Triples()
    $.ajax(
      dataType: 'jsonp',
      jsonpCallback: 'detection_callback',
      url: 'http://data.101companies.org/dumps/detection_HEAD.jsonp',
      success: (data) ->
        self.detections = data
        $.ajax(
          dataType: 'jsonp',
          jsonpCallback: 'implications_callback',
          url: 'http://data.101companies.org/dumps/featureImplications.jsonp',
          success: (data) ->
            self.implications = data
            self.haskellTriples.fetch(
              url: "/endpoint/Language:Haskell/json/directions"
              success: -> self.render()
            )
        )
    )

  render: ->
    self = @
    $('#name-container input').val(@clone.get('title'))
    contribTriples = _.filter(@haskellTriples.models, (t) -> t.get('direction') == "IN" and t.get('predicate') == 'http://101companies.org/property/uses')
    contribNames = _.map(contribTriples, (t) -> t.get('node').replace("Contribution:", ""))
    contribNames = _.filter(contribNames, (n) -> n of self.detections)
    _.each(contribNames, (n) -> new Wiki.Views.CloneSelect(clone : self.clone, candiate: n))

  renderClone: ->
    $('#preview-container h3').html(@template(@clone.toJSON()))

  pullAllFeatures: ->
    $('.text-error').text("")
    self = @
    detections = @detections[@clone.get('original')]['features']
    self.clone.set('features', [])
    contribTriples = new Wiki.Models.Triples()
    contribTriples.fetch(
      url: "/endpoint/Contribution:" + self.clone.get('original') + "/json/directions"
      success: ->
        $('#features').html('')
        featTriples = _.filter(contribTriples.models, (t) -> t.get('direction') == "OUT" and t.get('predicate') == 'http://101companies.org/property/implements')
        featNames = _.map(featTriples, (t) -> t.get('node').replace("Feature:", ""))
        _.each(featNames, (n) ->
          self.clone.get('features').push(n)
          cleanname = n.replace(/\s/g, '_')
          impliedBy = _.filter(Object.keys(self.implications), (k) ->
            _.contains(self.implications[k], cleanname)
          )
          new Wiki.Views.CloneSelectFeature(clone : self.clone, feature: n, detections: detections[cleanname], impliedBy: impliedBy)
        )
        self.renderClone()
    )
  changeName: ->
    $('.text-error').text("")
    $name = $('#name-container input')
    @clone.set('title', $('#name-container input').val())

  submit: ->
    self =@
    @clone.save({}
      success: -> window.location = '/clones/check/' + self.clone.get('title')
      error: (model,response) ->
        $('#submit-error').text(JSON.parse(response.responseText)['message'])
    )


