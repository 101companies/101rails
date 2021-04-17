import React from 'react';
import { TagCloud } from 'react-tagcloud';

const options = {
  luminosity: 'light',
  hue: 'blue',
}

export default ({data}) => {
  const tagCloudData = Object.entries(data).map((item) => {
    const [key, value] = item;
    return { value: key, count: value };
  })

  return (
    <TagCloud
      minSize={12}
      colorOptions={options}
      maxSize={35}
      tags={tagCloudData}
      onClick={tag => alert(`'${tag.value}' was selected!`)}
    />
  );
}
