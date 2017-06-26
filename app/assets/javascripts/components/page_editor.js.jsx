class PageEditor extends React.Component {

  static propTypes = {
    rawContent: React.PropTypes.string.isRequired
  };

  constructor(props) {
    super(props);

    this.state = {
      rawContent: this.props.rawContent,
      containerWidth: 50,
      predicates: this.props.predicates
    }
  }

  componentDidMount() {
    this.setState({
      containerWidth: this.container.clientWidth,
    });

    $(window).resize(() => {
      this.setState({
        containerWidth: this.container.clientWidth,
      });
    });
  }

  componentWillUnmount() {
    $(window).off("resize");
  }

  savePage() {
    var url = window.location.pathname.replace(/edit$/, '');
    $.ajax({
      url: url,
      type: 'PUT',
      data: {
        content: this.state.rawContent,
        newTitle: this.props.full_title
      }
    }).done(function(data) {
      window.location.pathname = '/' + data.newTitle;
    });
  }

  onCancel() {
    history.back();
  }

  render() {
    var metadata = this.state.rawContent.substring(this.state.rawContent.indexOf('== Metadata =='));
    var lines = metadata.split('\n');
    lines = lines.filter(function(line) {
      return line[0] == '*' && line.match(/\[\[[\S ]+\]\]/);
    }).map(function(line) {
      line = line.substring(1).trim();
      return line.substring(line.indexOf('[['));
    });

    var triples = lines.map(function(line, index) {
      line = line.replace('[[', '').replace(']]', '');
      return {
        predicate: line.split('::')[0],
        object: line.split('::')[1],
        id: index
      }
    });

    return (<div className='' ref={(container) => { this.container = container; }}>
      <div id="contentTop">
        <div id="topEditBar" className="editBar">
          <div className="btn-toolbar editing" style={{display: 'block'}}>
            <div className="btn-group">
              <div className="editButton btn btn-sm btn-default" id="pageCancelButton" onClick={this.onCancel.bind(this)}>
                <i className="icon-remove" />
                <strong>Cancel</strong>
              </div>
              <div className="editButton btn btn-sm btn-default" id="pageSaveButton" onClick={this.savePage.bind(this)}>
                <i className="icon-ok" />
                <strong>Save</strong>
              </div>
            </div>
          </div>
        </div>
        <div id="title">
          <h1>{this.props.full_title}</h1>
        </div>
      </div>
      <div id="sections">
        <div id="sections-source" style={{minHeight: '400px', width: '100%' }}>
          <Editor theme='wiki'
            mode='wiki'
            value={this.state.rawContent}
            onChange={this.onChangeContent.bind(this)}
            height='300px'
            width={this.state.containerWidth + 'px'} />
          <div className='row'>
            <div className='col-md-12'>
              <MetaDataEditor
                triples={triples}
                pages={this.props.pages}
                onChange={this.onChangeTriples.bind(this)}
                predicates={this.state.predicates}  />
            </div>
          </div>
        </div>
      </div>
    </div>)
  }

  onChangeTriples(triples) {
    var indexMetadata = this.state.rawContent.indexOf('== Metadata ==');
    var pageWithoutMetadata = this.state.rawContent;
    if (-1 !== indexMetadata) {
        pageWithoutMetadata = this.state.rawContent.substring(0, indexMetadata);
    }

    var metadata = '== Metadata ==\n\n' + triples.map(function(triple) {
      return '* [[' + triple.predicate + '::' + triple.object + ']]';
    }).join('\n') + '\n\n';

    this.setState({ rawContent: pageWithoutMetadata + metadata, predicates: new_predicates });
  }

  onChangeContent(content) {
    var metadata = content.substring(content.indexOf('== Metadata =='));
    var lines = metadata.split('\n');
    lines = lines.filter(function(line) {
      return line[0] == '*' && line.match(/\[\[[\S ]+\]\]/);
    }).map(function(line) {
      line = line.substring(1).trim();
      return line.substring(line.indexOf('[['));
    });

    var triples = lines.map(function(line, index) {
      line = line.replace('[[', '').replace(']]', '');
      return {
        predicate: line.split('::')[0],
        object: line.split('::')[1],
        id: index
      }
    });

    var new_predicates = this.state.predicates;
    triples.forEach((triple) => {
      if(new_predicates.indexOf(triple.predicate) == -1) {
        new_predicates = React.addons.update(this.props.predicates, { $push: [triple.predicate] });
      }
    });
    this.setState({ rawContent: content, predicates: new_predicates });
  }
}
