import React from 'react';

export default (props) => {
  const onObjectChange = (event) => {
    props.onChange({
      id: props.triple.id,
      predicate: props.triple.predicate,
      object: event.target.value
    });
  };

  const onPredicateChange = (predicate) => {
    props.onChange({
      id: props.triple.id,
      predicate: predicateInput.value,
      object: props.triple.object
    });
  };

  if(!props.triple.predicate) {
    return <div></div>;
  }

  var predicateOptions = props.predicates.map((predicate) => {
    return <option key={predicate} value={predicate}>{predicate}</option>;
  });

  return (
    <div className='row ml-0 my-2'>
      <div className='col-md-3'>
        <select onChange={onPredicateChange}
                className='form-control'
                ref={(predicateInput) => { predicateInput = predicateInput; }}
                value={props.triple.predicate}>
          {predicateOptions}
        </select>
      </div>

      <div className='col-md-9'>
        <input className='form-control' type='text' ref={(objectInput) => { objectInput = objectInput; }} value={props.triple.object} onChange={onObjectChange} />
      </div>
    </div>
  );
};
