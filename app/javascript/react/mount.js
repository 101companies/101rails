// Mounts the React components that `react_component` (app/helpers/react_helper.rb)
// renders as <div data-react-class="..." data-react-json="..."> placeholders.
//
// This replaces react_ujs, which depended on webpack's require.context.
import React from 'react';
import { createRoot } from 'react-dom/client';
import components from '../components';

const roots = new WeakMap();

export default function mountReactComponents(scope = document) {
  scope.querySelectorAll('[data-react-class]').forEach((element) => {
    if (roots.has(element)) return;

    const name = element.dataset.reactClass;
    const Component = components[name];

    if (!Component) {
      console.warn(`No React component registered for "${name}"`);
      return;
    }

    const props = element.dataset.reactJson ? JSON.parse(element.dataset.reactJson) : {};
    const root = createRoot(element);

    roots.set(element, root);
    root.render(<Component {...props} />);
  });
}
