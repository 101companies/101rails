var TripleEditor = React.createClass({

  render: function() {
    var predicateOptions = $.map(this.props.predicates, function(index, key) {
      return <option value={key} key={key}>{key}</option>;
    });

    return <div>
      <select onChange={this.onChange} ref='predicateInput' value={this.props.triple.predicate}>
        {predicateOptions}
      </select>
      <input onChange={this.onChange} type='text' ref='objectInput' value={this.props.triple.object} />
    </div>;
  },

  componentDidMount: function() {
    $(React.findDOMNode(this.refs.objectInput)).autocomplete({
      source: this.props.pages,
      change: this.onChange
    });
  },

  onChange: function() {
    this.props.onChange({
      id: this.props.triple.id,
      predicate: React.findDOMNode(this.refs.predicateInput).value,
      object: React.findDOMNode(this.refs.objectInput).value
    });
  }

});
