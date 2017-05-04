$(document).on('turbolinks:load', function() {
  $('[data-toggle="popover"]').popover();

  // hide metadata
  var metadata = $('[class="mw-headline"][id="Metadata"]');

  // hide list
  metadata.parent().nextAll("ul").hide();
  metadata.parent().nextAll("p").hide();
  metadata.parent().nextAll("pre").hide();
  metadata.parent().hide();

//   $('#renamePageButton').click(function() {
//     var url = $('#rename-path').data('value');
//     $.ajax({
//       url: url,
//       type: 'PUT',
//       data: {
//         newTitle: $('#newTitle').val()
//       }
//     }).done(function(data) {
//       window.location.pathname = '/' + data.newTitle;
//     })
//   });
});
