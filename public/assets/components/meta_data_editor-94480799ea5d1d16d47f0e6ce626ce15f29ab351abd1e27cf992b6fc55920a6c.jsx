var MetaDataEditor = React.createClass({

  render: function() {
    var triplesView = this.props.triples.map(function(triple, index) {
      return <TripleEditor
        key={index}
        triple={triple}
        pages={this.props.pages}
        predicates={this.props.predicates}
        onChange={this.onTripleChange} />
    }.bind(this));

    return <form>
      <h4>Metadata Editor</h4>
      <fieldset>
        { triplesView }
      </fieldset>
      <button className='btn btn-default' onClick={this.onNewTriple}>
        New Triple
      </button>
    </form>;
  },

  onNewTriple: function(event) {
    event.preventDefault();

    var predicate = Object.keys(this.props.predicates)[0];
    var object = this.props.predicates[predicate][0];

    var newTriples = React.addons.update(this.props.triples, { $push: [{ object: object, predicate: predicate }] })
    this.props.onChange(newTriples);
  },

  onTripleChange: function(newTriple) {
    var newTriples = this.props.triples.map(function(triple) {
      if(newTriple.id == triple.id) {
        return newTriple;
      }
      else {
        return triple;
      }
    });
    this.props.onChange(newTriples);
  }

});
