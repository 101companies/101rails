class Wiki.Views.Search extends Backbone.View
  el: '#page'
  template : JST['backbone/templates/searchResult']

  initialize: ->
    @render()

  render: ->
   self = @
   $('#query-string').text('Search results for "' + Wiki.queryString + '"')
   _.each Wiki.searchResults, (result) ->
      $('#search-results ul').append(self.template(link: result.link, name: result.title))
