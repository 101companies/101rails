var TripleEditor = React.createClass({

  render: function() {
    if(!this.props.triple.predicate || !this.props.predicates[this.props.triple.predicate]) {
      return <div></div>;
    }

    var predicateOptions = $.map(this.props.predicates, function(index, key) {
      return <option value={key} key={key}>{key}</option>;
    });

    var objectOptions = $.map(this.props.predicates[this.props.triple.predicate], function(object) {
      return <option value={object} key={object}>{object}</option>
    });

    return <div>
      <select onChange={this.onPredicateChange} ref='predicateInput' value={this.props.triple.predicate}>
        {predicateOptions}
      </select>
      <select onChange={this.onObjectChange} ref='objectInput' value={this.props.triple.object}>
        {objectOptions}
      </select>
    </div>;
  },

  componentDidMount: function() {
    $(React.findDOMNode(this.refs.objectInput)).autocomplete({
      source: this.props.pages,
      change: this.onChange
    });
  },

  onObjectChange: function() {
    this.props.onChange({
      id: this.props.triple.id,
      predicate: this.props.triple.predicate,
      object: React.findDOMNode(this.refs.objectInput).value
    });
  },

  onPredicateChange: function() {
    var predicate = React.findDOMNode(this.refs.predicateInput).value;
    this.props.onChange({
      id: this.props.triple.id,
      predicate: predicate,
      object: this.props.predicates[predicate][0]
    });
  }

});
