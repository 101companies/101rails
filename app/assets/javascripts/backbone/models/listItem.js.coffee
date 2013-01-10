class Wiki.Models.ListItem extends Backbone.Model

  defaults:
    title: ""
    removable: false

class Wiki.Models.ItemList extends Backbone.Collection
  model: Wiki.Models.ListItem
