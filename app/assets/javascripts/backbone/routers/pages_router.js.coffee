class Wiki.Routers.PagesRouter extends Backbone.Router
	routes:
		"*actions" : "wikiTab"


	initialize: (ViewClass) ->
		# Change hash when a tab changes
		$('a[data-toggle="tab"]').on 'shown', (e) ->
		  location.href = event.target.href

	# show page with wiki view
	wikiTab: (x) ->
		new Wiki.Views.Page(model: new Wiki.Models.Page(title: Wiki.pageTitle, idtitle: Wiki.pageTitle))
