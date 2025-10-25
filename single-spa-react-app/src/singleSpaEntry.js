import React from 'react';
import ReactDOM from 'react-dom';
import singleSpaReact from 'single-spa-react';

import rootComponent from './index';

const reactLifecycles = singleSpaReact({
  React,
  ReactDOM,
  rootComponent,
  domElementGetter: () => document.getElementById('react-app'),
});
export const bootstrap = reactLifecycles.bootstrap;
export const mount = (props) => {
  console.log('⚛️ React App mounted');
  return reactLifecycles.mount(props);
};
export const unmount = (props) => {
  console.log('⚛️ React App unmounted');
  return reactLifecycles.unmount(props);
};

export default {
  bootstrap,
  mount,
  unmount,
};
