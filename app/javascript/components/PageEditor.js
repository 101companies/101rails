import React from 'react';
import $ from 'jquery';

import Editor from './Editor';
import MetaDataEditor from './MetaDataEditor';

export default class PageEditor extends React.Component {
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

    var token = $("meta[name='csrf-token']").attr('content');
    $.ajax({
      url: url,
      headers: {
        'X-CSRF-Token': token
      },
      type: 'PUT',
      xhrFields: {
        withCredentials: true
      },
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

    var toolbar = null;
    var tripleEditor = null;
    if(this.props.can_edit) {
      toolbar = (
        <div className="btn-toolbar editing" style={{display: 'block'}}>
          <div className="btn-group">
            <div className="editButton btn btn-sm btn-secondary" id="pageCancelButton" onClick={this.onCancel.bind(this)}>
              <i className="icon-remove" />
              <strong>Cancel</strong>
            </div>
            <div className="editButton btn btn-sm btn-secondary" id="pageSaveButton" onClick={this.savePage.bind(this)}>
              <i className="icon-ok" />
              <strong>Save</strong>
            </div>
          </div>
        </div>
      );

      tripleEditor = (
        <MetaDataEditor
          triples={triples}
          pages={this.props.pages}
          onChange={this.onChangeTriples.bind(this)}
          predicates={this.state.predicates}  />
      );
    }

    return (<div className='' ref={(container) => { this.container = container; }}>
      <div id="contentTop">
        <div id="topEditBar" className="editBar">
          {toolbar}
        </div>
        <div id="title">
          <h1>{this.props.full_title}</h1>
        </div>
      </div>
      <div id="sections">
        <div id="sections-source" style={{minHeight: '400px', width: '100%' }}>
          <Editor theme='wiki'
            mode='mediawiki'
            value={this.state.rawContent}
            onChange={this.onChangeContent.bind(this)}
            height='300px'
            width={this.state.containerWidth + 'px'} />
          <div className='row'>
            <div className='col-md-12'>
              {tripleEditor}
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

    this.setState({ rawContent: pageWithoutMetadata + metadata });
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
