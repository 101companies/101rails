var EditorBar = React.createClass({

  onInsert: function(content) {
    this.props.onInsert(content);
  },

  render: function() {
    return (
      <div id="edit-options" className="editormenu btn-group">
        <button className="btn btn-small" onClick={this.onInsert.bind(this, {start: "'''", end: "'''"})}>
          <b>Bold</b>
        </button>
        <button className="btn btn-small" onClick={this.onInsert.bind(this, {start: "''", end: "''"})}>
          <i>Italic</i>
        </button>
        <button className="btn btn-small" onClick={this.onInsert.bind(this, {start: "<ins>", end: "</ins>"})}>
          <u>Underline</u>
        </button>
        <button className="btn btn-small" onClick={this.onInsert.bind(this, {start: "<del>", end: "</del>"})}>
          <s>Strike</s>
        </button>
        <button className="btn btn-small" onClick={this.onInsert.bind(this, {start: "==", end: "=="})}>
          <b style={{color: 'rgb(69, 150, 81)'}}>Headline</b>
        </button>
        <button className="btn btn-small" onClick={this.onInsert.bind(this, {start: "[[", end: "]]"})}>
          <u style={{color: 'rgb(62, 133, 201)'}}>Link</u>
        </button>
        <button className="btn btn-small" onClick={this.onInsert.bind(this, {start: "<syntaxhighlight lang=\"???\">\n", end: "\n</syntaxhighlight>"})}>
          <span className="code-button">Code</span>
        </button>
        <button className="btn btn-small" onClick={this.onInsert.bind(this, {start: "[[media:FULL_LINK_TO_PICTURE]]", end: ""})}>
          <i className="icon-picture" /> Image
        </button>
        <button className="btn btn-small" onClick={this.onInsert.bind(this, {start: "\n#", end: "\n#\n#\n"})}>
          <i className="icon-list-ol" /> List
        </button>
        <button className="btn btn-small" onClick={this.onInsert.bind(this, {start: "\n*", end: "\n*\n*\n"})}>
          <i className="icon-list-ul" /> Counted list
        </button>
        <button className="btn btn-small" onClick={this.onInsert.bind(this, {start: "<media url='URL_TO_SLIDEHSARE_PRESENTATION' />", end: ""})}>
          <i className="icon-desktop" /> Slideshare
        </button>
        <br />
        <button className="btn btn-small" onClick={this.onInsert.bind(this, {start: "<media url='URL_TO_YOUTUBE_VIDEO' />", end: ""})}>
          <i className="icon-youtube" /> Youtube
        </button>
        <button className="btn btn-small" onClick={this.onInsert.bind(this, {start: "<fragment url='URL_TO_FRGAMENT' explore='true'/>", end: ""})}>
          <i className="icon-code" /> Fragment
        </button>
      </div>
    );
  }
});
