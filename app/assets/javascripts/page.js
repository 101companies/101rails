$(document).ready(function() {
  // hide metadata
  var metadata = $('#Metadata');

  // hide list
  metadata.parent().nextAll("ul").hide();
  metadata.parent().nextAll("p").hide();
  metadata.parent().nextAll("pre").hide();
  // metadata.parent().next().next().hide();
  // metadata.parent().next().next().next().hide();
  metadata.parent().hide();

  $('#pageDeleteButton').click(function() {
    var ok = confirm("Are you sure?");
    if(ok == true) {
      $.ajax({
        url: window.pagePath,
        type: 'DELETE'
      }).done(function(data) {
        if(data.success) {
          window.location.href = '/wiki/@project';
        }
        else {
          alert(data.success);
        }
      });
    }
    else {
        // do nothing
    }
  });

  $('#renamePageButton').click(function() {
    $.ajax({
      url: window.renamePath,
      type: 'PUT',
      data: {
        newTitle: $('#newTitle').val()
      }
    }).done(function(data) {
      window.location.pathname = '/wiki/' + data.newTitle;
    })
  });
});
