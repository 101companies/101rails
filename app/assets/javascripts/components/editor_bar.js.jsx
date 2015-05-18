var EditorBar = React.createClass({

  render: function() {
    return <div id="edit-options" className="editormenu btn-group">
        <button data-editoraction="bold" className="btn btn-small">
          <b>Bold</b>
        </button>
        <button data-editoraction="italic" className="btn btn-small">
          <i>Italic</i>
        </button>
        <button data-editoraction="underline" className="btn btn-small">
          <u>Underline</u>
        </button>
        <button data-editoraction="strike" className="btn btn-small">
          <s>Strike</s>
        </button>
        <button data-editoraction="headline" className="btn btn-small">
          <b style={{color: 'rgb(69, 150, 81)'}}>Headline</b>
        </button>
        <button data-editoraction="link" className="btn btn-small">
          <u style={{color: 'rgb(62, 133, 201)'}}>Link</u>
        </button>
        <button data-editoraction="code" className="btn btn-small">
          <span className="code-button">Code</span>
        </button>
        <button data-editoraction="picture" className="btn btn-small">
          <i className="icon-picture" /> Image
        </button>
        <button data-editoraction="list-ol" className="btn btn-small">
          <i className="icon-list-ol" /> List
        </button>
        <button data-editoraction="list-ul" className="btn btn-small">
          <i className="icon-list-ul" /> Counted list
        </button>
        <button data-editoraction="slideshare" className="btn btn-small">
          <i className="icon-desktop" /> Slideshare
        </button>
        <br />
        <button data-editoraction="youtube" className="btn btn-small">
          <i className="icon-youtube" /> Youtube
        </button>
        <button data-editoraction="fragment" className="btn btn-small">
          <i className="icon-code" /> Fragment
        </button>
      </div>;
  }
});
