import singleSpaAngularJS from 'single-spa-angularjs';
import angular from 'angular';

import app from './app.component.html';

import './app.module';
import './routes';

const domElementGetter = () => document.getElementById('home-app');

const ngLifecycles = singleSpaAngularJS({
  angular,
  domElementGetter,
  mainAngularModule: 'home-app',
  uiRouter: true,
  preserveGlobal: false,
  template: app,
});

export const bootstrap = ngLifecycles.bootstrap;
export const mount = (props) => {
  console.log('🏠 Home App (AngularJS) mounted');
  return ngLifecycles.mount(props);
};
export const unmount = (props) => {
  console.log('🏠 Home App (AngularJS) unmounted');
  return ngLifecycles.unmount(props);
};

// For UMD builds, expose on window
if (typeof window !== 'undefined') {
  window['single-spa-home-app'] = { bootstrap, mount, unmount };
}

// Default export for UMD builds
export default {
  bootstrap,
  mount,
  unmount,
};
