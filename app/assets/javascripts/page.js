$(document).ready(function() {
  // hide metadata
  var metadata = $('#Metadata');

  // hide list
  metadata.parent().next().hide();
  metadata.parent().next().next().hide();
  metadata.parent().next().next().next().hide();
  metadata.parent().hide();

  $('#renamePageButton').click(function() {
    $.ajax({
      url: '<%= rename_page_path(@page.full_title) %>',
      type: 'PUT',
      data: {
        newTitle: $('#newTitle').val()
      }
    }).done(function(data) {
      window.location.pathname = '/wiki/' + data.newTitle;
    })
  });
});
