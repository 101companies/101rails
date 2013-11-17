class Wiki.Routers.PagesRouter extends Backbone.Router
  routes:
    "*actions" : "default"


  initialize: (ViewClass) ->
    @ViewClass = ViewClass
    # Change hash when a tab changes
    $('a[data-toggle="tab"]').on 'shown', (e) ->
      history.pushState(null, null, event.target.href);

  # show page with wiki view
  default: (x) ->
    if @ViewClass
      new @ViewClass(model: Wiki.page)
    else
      new Wiki.Views.Page(model: new Wiki.Models.Page(id: Wiki.pageTitle, newTitle: Wiki.pageTitle))
