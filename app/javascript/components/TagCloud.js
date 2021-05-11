import React from 'react';
import { TagCloud } from 'react-tagcloud';

const options = {
  // luminosity: 'light',
  // hue: 'blue',
}

let seed = 1337
function random() {
  const x = Math.sin(seed++) * 10000
  return x - Math.floor(x)
}

export default ({namespace, data}) => {
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
      randomNumberGenerator={random}
      onClick={(tag) => {
          window.location.href = `/${namespace}:${tag.value}`;
        }
      }
    />
  );
}
