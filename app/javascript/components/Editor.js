// taken from: https://github.com/securingsincity/react-ace

import React from 'react';
import AceEditor from "react-ace";

import "ace-builds/src-noconflict/mode-mediawiki";
import "ace-builds/src-noconflict/theme-xcode";

import EditorBar from './EditorBar';

const Editor = (props) => {
  const onInsert = (help) => {
    const toWrap = editor.current.getSession().getTextRange(editor.current.getSelectionRange());
    editor.current.getSession().replace(editor.current.getSelectionRange(), help.start + toWrap + help.end);
    editor.current.navigateRight(help.end.length);
  }
  //
  // React.useEffect(() => {
  //   editor.current = ace.edit(props.name);
  //   editor.current.getSession().setMode('ace/mode/' + props.mode);
  //   editor.current.getSession().setUseWrapMode(true);
  //   editor.current.setTheme('ace/theme/' + props.theme);
  //   editor.current.setFontSize(props.fontSize);
  //   editor.current.on('change', onChange);
  //   editor.current.setValue(props.value, -1);
  //   editor.current.renderer.setShowGutter(props.showGutter);
  //   editor.current.currentsetShowPrintMargin(props.setShowPrintMargin);
  //
  //   editor.current.setOptions({
  //     enableBasicAutocompletion: true
  //   });
  //
  //   var langTools = ace.require("ace/ext/language_tools");
  //   var wikiCompleter = {
  //       getCompletions: function(editor, session, pos, prefix, callback) {
  //           var line = editor.session.getLine(pos.row);
  //           prefix = retrievePrecedingIdentifier(line, pos.column);
  //           if(prefix.indexOf(':') > -1 && prefix.length > 2) {
  //             $.getJSON('/autocomplete?prefix=' + prefix, function(members) {
  //               callback(null, members.map(function(member) {
  //                 return {name: member, value: member, score: 1.0, meta: "101"}
  //               }));
  //             });
  //           }
  //           else {
  //             callback(null, []);
  //           }
  //       }
  //   }
  //   langTools.addCompleter(wikiCompleter);
  //
  //   if (props.onLoad) {
  //     props.onLoad(editor.current);
  //   }
  // }, [props]);
  //
  const onChange = () => {
    var value = editor.current.getValue();
    if (props.onChange) {
      props.onChange(value);
    }
  }

  const divStyle = {
    width: props.width,
    height: props.height
  };
  return (
    <div>
      <EditorBar onInsert={onInsert} />
      <AceEditor
        mode={props.mode}
        theme="xcode"
        onChange={onChange}
        height={props.height}
        width={props.width}
        showGutter={props.showGutter}
        highlightActiveLine={true}
        showPrintMargin={props.showPrintMargin}
        fontSize={props.fontSize}
        value={props.value}
        name="wiki-editor"
        wrapEnabled={true}
        setOptions={{
          useWrapMode: true,
        }}
      />
    </div>
  );
}

Editor.defaultProps = {
  name   : 'brace-editor',
  mode   : '',
  theme  : '',
  height : '500px',
  width  : '50px',
  value  : '',
  fontSize   : 12,
  showGutter : true,
  onChange   : null,
  onLoad     : null,
  maxLines   : null,
  readOnly   : false,
  highlightActiveLine : true,
  showPrintMargin     : true
};

export default Editor;
