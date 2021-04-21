// taken from: https://github.com/securingsincity/react-ace

import React from 'react';
import AceEditor from "react-ace";

import "ace-builds/src-noconflict/mode-mediawiki";
import "ace-builds/src-noconflict/theme-xcode";

import EditorBar from './EditorBar';

const Editor = (props) => {
  const reactAceComponent = React.useRef(null);

  const onInsert = (help) => {
    console.log(reactAceComponent.current.editor);
    const editor = reactAceComponent.current.editor;
    console.log(editor.getSession());

    const toWrap = editor.getSession().getTextRange(editor.getSelectionRange());
    editor.getSession().replace(editor.getSelectionRange(), help.start + toWrap + help.end);
    editor.navigateRight(help.end.length);
  }

  const onChange = (value) => {
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
        ref={reactAceComponent}
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
          useWorker: false
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
