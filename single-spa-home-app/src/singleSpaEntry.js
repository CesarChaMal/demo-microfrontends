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

export const { bootstrap } = ngLifecycles;
export const { mount } = ngLifecycles;
export const { unmount } = ngLifecycles;
