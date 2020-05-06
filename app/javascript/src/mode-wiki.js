/**
 * All credit goes to Dan Michael Heggø,
 * based on https://github.com/danmichaelo/acewiki
**/

define('ace/mode/wiki_highlight_rules', ['require', 'exports', 'module' , 'ace/lib/oop', 'ace/mode/text_highlight_rules'], function(require, exports, module) {

  var oop = require("../lib/oop");
  var TextHighlightRules = require("./text_highlight_rules").TextHighlightRules;

  var WikiHighlightRules = function() {

    // regexp must not have capturing parentheses
    // regexps are ordered -> the first match is used
    this.$rules = {
        start : [
            {
                token : "comment",
                merge : true,
                regex : "<\\!--",
                next : "comment"
            }, {
                token : "comment",
                regex : "<nowiki>",
                merge : true,
                next : "nowiki"
            }, {
                token : "specialchar",
                regex : "[– ]"
            }, {
                // External links [ ... ]
                token : "externallink",
                regex : "\\[[^\\[\\]]*\\]"
            }, { // headings
                token: "markup.heading.1",
                regex: "^==.*==\\s*$"
            }, {
                token : "meta.tag",
                regex : "<ref[^<>]*?/>"
            }, {
                token : "meta.tag",
                regex : "<ref[^<>]*?>",
                merge : true,
                next : "ref"
            }, {
                token : "table",
                merge : true,
                regex : "{\\|",
                next : "table"
            }, {
                token : "template",
                merge : true,
                regex : "{{",
                next : "template"
            }, {
                // Wikilinks {{ ... }}
                token : "wikilinkbraces",
                regex : "\\[\\[",
                next : "wikilink"
            }],
        ref : [
         {
                token : "meta.tag",
                regex : ".*?</ref>",
                next : "start"
            }, {
                token : "meta.tag",
                merge : true,
                regex : ".+"
            }],
        wikilink : [
         {
                token : "wikilinkbraces",
                regex : "\\]\\]",
                next : "start"
            }, {
                token : "wikilink",
                merge : true,
                regex : "[^\\]]+"
            }],
        comment : [
            {
                token : "comment",
                regex : ".*?-->",
                next : "start"
            }, {
                token : "comment",
                merge : true,
                regex : ".+"
            }],
        nowiki : [
            {
                token : "comment",
                regex : ".*?</nowiki>",
                next : "start"
            }, {
                token : "comment",
                merge : true,
                regex : ".+"
            }],
        table : [
            {
                token : "table",
                regex : ".*?\\|}",
                next : "start"
            }, {
                token : "table",
                merge : true,
                regex : ".+"
            }],
        template : [
            {
                token : "template.sub",
                merge : true,
                regex : "{{",
                next : "subtemplate"
            }, {
                token : "template",
                regex : "}}",
                next : "start"
            }, {
                token : "specialchar",
                regex : "[– ]"
            }, {
                token : "template",
                merge : true,
                regex : "[^{}– ]+"
            }],
        subtemplate : [
            {
                token : "template.sub",
                regex : "[^– ]*?}}",
                next : "template"
            }, {
                token : "specialchar",
                regex : "[– ]"
            }, {
                token : "template.sub",
                merge : true,
                regex : "[^– ]+"
            }]
    };

  }

  oop.inherits(WikiHighlightRules, TextHighlightRules);
  exports.WikiHighlightRules = WikiHighlightRules;
});


define('ace/mode/wiki', function(require, exports, module) {

  var oop = require("../lib/oop");
  var TextMode = require("./text").Mode;
  var WikiHighlightRules = require("./wiki_highlight_rules").WikiHighlightRules;

  var Mode = function() {
    this.HighlightRules = WikiHighlightRules;
  };
  oop.inherits(Mode, TextMode);

  (function() {
      this.$id = "ace/mode/wiki";
  }).call(Mode.prototype);

  exports.Mode = Mode;
});
