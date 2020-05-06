import $ from 'jquery';

$.fn.extend({
  acedInit: function(options) {
    if (options == null) {
      options = {};
    }
    return this.each(function() {
      var editor;
      editor = ace.edit(this);
      if (options.theme != null) {
        editor.setTheme("ace/theme/" + options.theme);
      }
      if (options.mode != null) {
        editor.getSession().setMode("ace/mode/" + options.mode);
      }
      return $(this).data('ace-editor', editor);
    });
  },
  acedInitTA: function(options) {
    return this.each(function() {
      var div, editor, height, ta, width;
      ta = $(this);
      height = ta.height();
      width = ta.width();
      div = $("<div style=\"height: " + height + "px; width: " + width + "px;\"></div>");
      ta.hide();
      ta.before(div);
      ta.data('ace-div', div);
      div.acedInit(options);
      editor = div.aced();
      editor.setValue(ta.text());
      editor.clearSelection();
      return editor.getSession().on('change', function(e) {
        return ta.text(editor.getValue());
      });
    });
  },
  aced: function() {
    return $(this).data('ace-editor');
  },
  acedSession: function() {
    return $(this).data('ace-editor').getSession();
  }
});

$(document).ready(function() {
  $('div[ace-editor]').each(function() {
    var div, mode, theme;
    div = $(this);
    theme = div.attr('ace-theme');
    mode = div.attr('ace-mode');
    return div.acedInit({
      theme: theme,
      mode: mode
    });
  });
  return $('textarea[ace-editor]').each(function() {
    var mode, ta, theme;
    ta = $(this);
    theme = ta.attr('ace-theme');
    mode = ta.attr('ace-mode');
    return ta.acedInitTA({
      theme: theme,
      mode: mode
    });
  });
});
