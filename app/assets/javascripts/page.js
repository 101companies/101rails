$(document).ready(function() {
  if($('meta[name=last_message_id]').length == 0) {
    return;
  }
  MessageBus.alwaysLongPoll = true;
  MessageBus.callbackInterval = 5000;

  MessageBus.start();

  var last_id = $('meta[name=last_message_id]')[0].content;

  MessageBus.subscribe("/messages", function(data, _, message_id){
    alert(data);
    $.post('/last_received', { last_message_id: message_id })
      .done(function(result) {
        console.log(result);
      });

  }, last_id);
});

$(document).on('turbolinks:load', function() {
  $('[data-toggle="popover"]').popover();

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
          window.location.href = '/101project';
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
      window.location.pathname = '/' + data.newTitle;
    })
  });
});
