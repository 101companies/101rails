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
      <h4>Metadata-Editor</h4>
      <fieldset>
        { triplesView }
      </fieldset>
    </form>;
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
