import React from 'react';

import TripleEditor from './TripleEditor';

export default (props) => {
  const onTripleChange = (newTriple) => {
    var newTriples = props.triples.map((triple) => {
      if(newTriple.id == triple.id) {
        return newTriple;
      }
      else {
        return triple;
      }
    });
    props.onChange(newTriples);
  }

  const onNewTriple = (event) => {
    event.preventDefault();

    var predicate = this.props.predicates[0];
    var object = '';

    var newTriples = props.triples.concat([{ object: object, predicate: predicate }]);
    props.onChange(newTriples);
  }

  const triplesView = props.triples.map((triple, index) =>
    <TripleEditor
      key={index}
      triple={triple}
      pages={props.pages}
      predicates={props.predicates}
      onChange={onTripleChange} />
  );

  return (
    <form className='mt-4'>
      <h4>Metadata Editor</h4>
      <fieldset>
        { triplesView }
      </fieldset>
      <button className='btn btn-secondary' onClick={onNewTriple}>
        New Triple
      </button>
    </form>
  );
}
