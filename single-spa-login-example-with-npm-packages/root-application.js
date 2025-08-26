/* eslint-env browser */
/* global System */
/* eslint-disable no-unused-vars */
/* eslint-disable func-names */
import * as singleSpa from 'single-spa';
import 'zone.js';

import 'bootstrap/dist/css/bootstrap.css';
import 'bootstrap-vue/dist/bootstrap-vue.css';

System.import = System.import || window.importShim;

System.config({
  map: {
    'single-spa-auth-app': 'http://localhost:4201/single-spa-auth-app.js',
    'single-spa-layout-app': 'http://localhost:4202/single-spa-layout-app.js',
    'single-spa-home-app': 'http://localhost:4203/single-spa-home-app.js',
    'single-spa-angular-app': 'http://localhost:4204/single-spa-angular-app.js',
    'single-spa-vue-app': 'http://localhost:4205/single-spa-vue-app.js',
    'single-spa-react-app': 'http://localhost:4206/single-spa-react-app.js',
  },
});

function showWhenAnyOf(routes) {
  return function (location) {
    return routes.some((route) => location.pathname === route);
  };
}

function showWhenPrefix(routes) {
  return function (location) {
    return routes.some((route) => location.pathname.startsWith(route));
  };
}

function showExcept(routes) {
  return function (location) {
    return routes.every((route) => location.pathname !== route);
  };
}

singleSpa.registerApplication(
  'login',
  () => import('single-spa-auth-app'),
  showWhenAnyOf(['/login']),
);

singleSpa.registerApplication(
  'layout',
  () => import('single-spa-layout-app'),
  showExcept(['/login']),
);

singleSpa.registerApplication(
  'home',
  () => import('single-spa-home-app'),
  showWhenAnyOf(['/']),
);

singleSpa.registerApplication(
  'angular',
  () => import('single-spa-angular-app'),
  showWhenPrefix(['/angular']),
);

singleSpa.registerApplication(
  'vue',
  () => import('single-spa-vue-app'),
  showWhenPrefix(['/vue']),
);

singleSpa.registerApplication(
  'react',
  () => import('single-spa-react-app'),
  showWhenPrefix(['/react']),
);

singleSpa.start();
