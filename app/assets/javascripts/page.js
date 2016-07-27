$(document).ready(function() {
  // hide metadata
  var metadata = $('[class="mw-headline"][id="Metadata"]');

  // hide list
  metadata.parent().nextAll("ul").hide();
  metadata.parent().nextAll("p").hide();
  metadata.parent().nextAll("pre").hide();
  metadata.parent().hide();

  $('#pageDeleteButton').click(function() {
    var ok = confirm("Are you sure?");
    if(ok == true) {
      $.ajax({
        url: window.pagePath,
        type: 'DELETE'
      }).done(function(data) {
        if(data.success) {
          window.location.href = '/wiki/101project';
        }
        else {
          alert(data.success);
        }
      });
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
