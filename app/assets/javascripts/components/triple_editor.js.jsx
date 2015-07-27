var TripleEditor = React.createClass({

  componentDidMount: function() {
    $(React.findDOMNode(this.refs.objectInput)).autocomplete({
      source: this.props.pages,
      change: this.onChange
    });
  },

  onObjectChange: function(object) {
    this.props.onChange({
      id: this.props.triple.id,
      predicate: this.props.triple.predicate,
      object: object
    });
  },

  onPredicateChange: function(predicate) {
    this.props.onChange({
      id: this.props.triple.id,
      predicate: predicate,
      object: this.props.predicates[predicate][0]
    });
  },

  render: function() {
    if(!this.props.triple.predicate || !this.props.predicates[this.props.triple.predicate]) {
      return <div></div>;
    }

    var predicateOptions = $.map(this.props.predicates, function(index, key) {
      return {
        value: key,
        label: key
      };
    });

    var objectOptions = $.map(this.props.predicates[this.props.triple.predicate], function(object) {
      return {
        value: object,
        label: object
      };
    });

    return <div className='row' style={{ marginLeft: 0 }}>
      <div className='span6'>
        <Select onChange={this.onPredicateChange}
                options={predicateOptions}
                ref='predicateInput'
                value={this.props.triple.predicate} />
      </div>

      <div className='span6'>
        <Select onChange={this.onObjectChange}
                ref='objectInput'
                options={objectOptions}
                value={this.props.triple.object} />
      </div>
    </div>;
  }

});
