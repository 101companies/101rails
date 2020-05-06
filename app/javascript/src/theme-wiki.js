/**
 * All credit goes to Dan Michael Heggø,
 * based on https://github.com/danmichaelo/acewiki
**/
define('ace/theme/wiki', ['require', 'exports', 'module' , 'ace/lib/dom'], function(require, exports, module) {

exports.isDark = false;
exports.cssClass = "ace-wiki";
exports.cssText = "\
.ace-wiki .ace_editor {\
  border: 2px solid rgb(159, 159, 159);\
}\
\
.ace-wiki .ace_editor.ace_focus {\
  border: 2px solid #327fbd;\
}\
\
.ace-wiki .ace_gutter {\
  background: #e8e8e8;\
  color: #333;\
}\
\
.ace-wiki .ace_print_margin {\
  width: 1px;\
  background: #e8e8e8;\
}\
\
.ace-wiki .ace_scroller {\
  background-color: #FFFFFF;\
}\
\
.ace-wiki .ace_text-layer {\
  cursor: text;\
  color: #000000;\
}\
\
.ace-wiki .ace_cursor {\
  border-left: 2px solid #000000;\
}\
\
.ace-wiki .ace_cursor.ace_overwrite {\
  border-left: 0px;\
  border-bottom: 1px solid #000000;\
}\
 \
.ace-wiki .ace_marker-layer .ace_selection {\
  background: #BDD5FC;\
}\
\
.ace-wiki .ace_marker-layer .ace_step {\
  background: rgb(198, 219, 174);\
}\
\
.ace-wiki .ace_marker-layer .ace_bracket {\
  margin: -1px 0 0 -1px;\
  border: 1px solid #BFBFBF;\
}\
\
.ace-wiki .ace_marker-layer .ace_active_line {\
 \
}\
\
.ace-wiki .ace_marker-layer .ace_selected_word {\
  border: 1px solid #BDD5FC;\
}\
\
.ace-wiki .ace_invisible {\
  color: #BFBFBF;\
}\
\
.ace-wiki .ace_keyword {\
  color:#AF956F;\
}\
\
.ace-wiki .ace_lparen {\
  color: #ff0000;\
}\
\
.ace-wiki .ace_keyword.ace_operator {\
  color:#484848;\
}\
\
.ace-wiki .ace_constant.ace_language {\
  color:#39946A;\
}\
\
.ace-wiki .ace_constant.ace_numeric {\
  color:#46A609;\
}\
\
.ace-wiki .ace_invalid {\
  background-color:#FF002A;\
}\
\
.ace-wiki .ace_fold {\
    background-color: #AF956F;\
    border-color: #000000;\
}\
\
.ace-wiki .ace_support.ace_function {\
  color:#C52727;\
}\
\
.ace-wiki .ace_storage {\
  color:#C52727;\
}\
\
.ace-wiki .ace_template {\
  color:#718C00;\
}\
\
.ace-wiki .ace_template.ace_sub {\
  color:#596E00;\
}\
\
.ace-wiki .ace_wikilink {\
  color:rgb(62, 133, 201);\
}\
\
.ace-wiki .ace_wikilinkbraces {\
  color: #999999;\
}\
\
.ace-wiki .ace_externallink {\
  color: rgb(62, 133, 201);\
}\
\
.ace-wiki .ace_heading {\
  color: rgb(69, 150, 81);\
}\
\
.ace-wiki .ace_specialchar {\
  color: #00AA00;\
  background-color:#dddddd;\
}\
\
.ace-wiki .ace_comment {\
  color:#8E908C;\
}\
\
.ace-wiki .ace_table {\
  color:#80461B;\
}\
\
.ace-wiki .ace_entity.ace_other.ace_attribute-name {\
  color:#606060;\
}\
\
.ace-wiki .ace_meta.ace_tag {\
  color:#C82829;\
}\
\
.ace-wiki .ace_markup.ace_underline {\
    text-decoration:underline;\
}";

    var dom = require("../lib/dom");
    dom.importCssString(exports.cssText, exports.cssClass);
});
