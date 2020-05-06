var TripleEditor = React.createClass({

  onObjectChange: function(event) {
    this.props.onChange({
      id: this.props.triple.id,
      predicate: this.props.triple.predicate,
      object: event.target.value
    });
  },

  onPredicateChange: function(predicate) {
    this.props.onChange({
      id: this.props.triple.id,
      predicate: this.predicateInput.value,
      object: this.props.triple.object
    });
  },

  render: function() {
    if(!this.props.triple.predicate) {
      return <div></div>;
    }

    var predicateOptions = $.map(this.props.predicates, function(predicate) {
      return <option key={predicate} value={predicate}>{predicate}</option>;
    });

    return (<div className='row' style={{ marginLeft: 0 }}>
      <div className='col-md-3'>
        <select onChange={this.onPredicateChange}
                className='form-control'
                ref={(predicateInput) => { this.predicateInput = predicateInput; }}
                value={this.props.triple.predicate}>
          {predicateOptions}
        </select>
      </div>

      <div className='col-md-9'>
        <input className='form-control' type='text' ref={(objectInput) => { this.objectInput = objectInput; }} value={this.props.triple.object} onChange={this.onObjectChange} />
      </div>
    </div>);
  }

});
