$(document).ready(function() {
  // hide metadata
  var metadata = $('#Metadata');

  // hide list
  metadata.parent().next().hide();
  metadata.parent().hide();

  // make resource toggle work
  var hoverIn = function() {
    var id = $(this).data('toggle');
    $('#' + id).css('height', 'auto');
  };

  var hoverOut = function() {
    var id = $(this).data('toggle');
    $('#' + id).css('height', '0px');
  };

  $('.resource').hover(hoverIn, hoverOut);

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
