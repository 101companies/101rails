/*
 This is a manifest file that'll be compiled into application.js, which will include all the files
 listed below.

 Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
 or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.

 It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
 the compiled file.

 WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
 GO AFTER THE REQUIRES BELOW.

 = require jquery
 = require turbolinks

 = require typo/typo
 = require spellcheck_ace/spellcheck_ace

 = require jquery_ujs
 = require jquery-ui

 = require bootstrap

 = require ace/ace
 = require ace/ext-searchbox
 = require ace/theme-chrome
 = require ace/theme-textmate
 = require ace/theme-wiki
 = require ace/mode-wiki
 = require ace/ext-language_tools

 = require select2
 = require moment
 = require page
 */

//= require react
//= require react_ujs
//= require classes
//= require react-input-autosize
//= require react-select
//= require components
//= require app
//= require Chart.bundle
//= require chartkick
// = require ahoy

String.prototype.endsWith = function (s) {
  return this.length >= s.length && this.substr(this.length - s.length) == s;
}

ahoy.trackAll();
