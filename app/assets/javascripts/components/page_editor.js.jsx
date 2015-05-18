window.PageEditor = React.createClass({

  propTypes: {
    rawContent: React.PropTypes.string.isRequired
  },

  getInitialState: function() {
    return {
      rawContent: this.props.rawContent
    }
  },

  render: function() {
    var metadata = this.state.rawContent.substring(this.state.rawContent.indexOf('== Metadata =='));
    var lines = metadata.split('\n');
    lines = lines.filter(function(line) {
      return line[0] == '*';
    }).map(function(line) {
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
    console.log(JSON.stringify(triples));


    return <div id="sections-source" style={{height: '800px', width: '100%' }}>
      <EditorBar />
      <Editor theme='wiki'
        mode='wiki'
        value={this.state.rawContent}
        onChange={this.onChangeContent}
        height='300px'
        width='820px' />
      <MetaDataEditor
        triples={triples}
        pages={this.props.pages}
        onChange={this.onChangeTriples}
        predicates={this.props.predicates}  />
    </div>;
  },

  onChangeTriples: function(triples) {
    var pageWithoutMetadata = this.state.rawContent.substring(0, this.state.rawContent.indexOf('== Metadata =='));

    var metadata = '== Metadata ==\n' + triples.map(function(triple) {
      return '* [[' + triple.predicate + '::' + triple.object + ']]';
    }).join('\n');

    this.setState({ rawContent: pageWithoutMetadata + metadata });
  },

  onChangeContent: function(content) {
    this.setState({ rawContent: content });
  }

});
