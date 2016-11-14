$(document).ready(function() {
  MessageBus.alwaysLongPoll = true;
  MessageBus.callbackInterval = 5000;

  MessageBus.start();

  var last_id = $('meta[name=last_message_id]')[0].content;

  MessageBus.subscribe("/messages", function(data){
    alert(data);
  }, last_id);
});

$(document).on('turbolinks:load', function() {
  var btn = $('#render-page-button');

  btn.click(function() {
    var btn = $(this);

    $.getJSON('/wiki/' + btn.data('page-id') + '/render_script', function(result) {
      console.log(result);
      $('#myModal').modal('hide');
    });
  });


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
    var url = $('#rename-path').data('value');
    $.ajax({
      url: url,
      type: 'PUT',
      data: {
        newTitle: $('#newTitle').val()
      }
    }).done(function(data) {
      window.location.pathname = '/wiki/' + data.newTitle;
    })
  });
});
