// taken from: https://github.com/securingsincity/react-ace

var ID_REGEX = /[a-zA-Z_0-9\$\-\u00A2-\uFFFF\:]/;

var retrievePrecedingIdentifier = function(text, pos, regex) {
    regex = regex || ID_REGEX;
    var buf = [];
    for (var i = pos-1; i >= 0; i--) {
        if (regex.test(text[i]))
            buf.push(text[i]);
        else
            break;
    }
    return buf.reverse().join("");
};

var Editor = React.createClass({
  propTypes: {
    mode  : React.PropTypes.string,
    theme : React.PropTypes.string,
    name : React.PropTypes.string,
    height : React.PropTypes.string,
    width : React.PropTypes.string,
    fontSize : React.PropTypes.number,
    showGutter : React.PropTypes.bool,
    onChange: React.PropTypes.func,
    value: React.PropTypes.string,
    onLoad: React.PropTypes.func,
    highlightActiveLine : React.PropTypes.bool,
    showPrintMargin : React.PropTypes.bool
  },
  getDefaultProps: function() {
    return {
      name   : 'brace-editor',
      mode   : '',
      theme  : '',
      height : '500px',
      width  : '500px',
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
  },
  onChange: function() {
    var value = this.editor.getValue();
    if (this.props.onChange) {
      this.props.onChange(value);
    }
  },
  componentDidMount: function() {
    var self = this;
    this.editor = ace.edit(this.props.name);
    this.editor.getSession().setMode('ace/mode/'+this.props.mode);
    this.editor.setTheme('ace/theme/'+this.props.theme);
    this.editor.setFontSize(this.props.fontSize);
    this.editor.on('change', this.onChange);
    this.editor.setValue(this.props.value, -1);
    this.editor.renderer.setShowGutter(this.props.showGutter);
    this.editor.setShowPrintMargin(this.props.setShowPrintMargin);

    var langTools = ace.require("ace/ext/language_tools");
    var wikiCompleter = {
        getCompletions: function(editor, session, pos, prefix, callback) {
            var line = editor.session.getLine(pos.row);
            prefix = retrievePrecedingIdentifier(line, pos.column);
            if(prefix.indexOf('::') > -1 && prefix.length > 2) {
              $.getJSON('/autocomplete?prefix=' + prefix, function(members) {
                callback(null, members.map(function(member) {
                  return {name: member, value: member, score: 1.0, meta: "101"}
                }));
              });
            }
            else {
              callback(null, []);
            }
            // if (prefix.length === 0) { callback(null, []); return }
            // $.getJSON(
            //     "http://rhymebrain.com/talk?function=getRhymes&word=" + prefix,
            //     function(wordList) {
            //         // wordList like [{"word":"flow","freq":24,"score":300,"flags":"bc","syllables":"1"}]
            //         callback(null, wordList.map(function(ea) {
            //             return {name: ea.word, value: ea.word, score: ea.score, meta: "rhyme"}
            //         }));
            //     })
        }
    }
    langTools.addCompleter(wikiCompleter);

    if (this.props.onLoad) {
      this.props.onLoad(this.editor);
    }
  },

  componentWillReceiveProps: function(nextProps) {
    this.editor = ace.edit(nextProps.name);
    this.editor.getSession().setMode('ace/mode/' + nextProps.mode);
    this.editor.setTheme('ace/theme/' + nextProps.theme);
    this.editor.setFontSize(nextProps.fontSize);
    this.editor.setShowPrintMargin(nextProps.setShowPrintMargin);
    if (this.editor.getValue() !== nextProps.value) {
      this.editor.setValue(nextProps.value, 1);
    }
    this.editor.setOptions({
      enableBasicAutocompletion: true
    });
    this.editor.renderer.setShowGutter(nextProps.showGutter);
    if (nextProps.onLoad) {
      nextProps.onLoad(this.editor);
    }
  },

  render: function() {
    var divStyle = {
      width: this.props.width,
      height: this.props.height
    };
    return (<div id={this.props.name} onChange={this.onChange} style={divStyle}></div>);
  }
});
