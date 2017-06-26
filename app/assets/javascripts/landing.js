/*
 = require jquery
 = require d3
 = require bootstrap
 = require d3.layout.cloud
 = require landing_tagcloud
*/

$(document).ready(function() {
  console.log('init');
  var hash = window.location.hash;
  hash && $('a[href="' + hash + '"]').tab('show');

  $('.nav a').click(function (e) {
    var scrollmem = $('body').scrollTop();
    window.location.hash = this.hash;
    $('html,body').scrollTop(scrollmem);
  });
});
