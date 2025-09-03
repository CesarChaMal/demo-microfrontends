/* eslint-env browser */
/* global System */
/* eslint-disable no-unused-vars */
/* eslint-disable func-names */
import * as singleSpa from 'single-spa';
import 'zone.js';

import 'bootstrap/dist/css/bootstrap.css';
import 'bootstrap-vue/dist/bootstrap-vue.css';

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
  () => import('@your-org/single-spa-auth-app'),
  showWhenAnyOf(['/login']),
);

singleSpa.registerApplication(
  'layout',
  () => import('@your-org/single-spa-layout-app'),
  showExcept(['/login']),
);

singleSpa.registerApplication(
  'home',
  () => import('@your-org/single-spa-home-app'),
  showWhenAnyOf(['/']),
);

singleSpa.registerApplication(
  'angular',
  () => import('@your-org/single-spa-angular-app'),
  showWhenPrefix(['/angular']),
);

singleSpa.registerApplication(
  'vue',
  () => import('@your-org/single-spa-vue-app'),
  showWhenPrefix(['/vue']),
);

singleSpa.registerApplication(
  'react',
  () => import('@your-org/single-spa-react-app'),
  showWhenPrefix(['/react']),
);

singleSpa.registerApplication(
  'vanilla',
  () => import('@your-org/single-spa-vanilla-app'),
  showWhenPrefix(['/vanilla']),
);

singleSpa.registerApplication(
  'webcomponents',
  () => import('@your-org/single-spa-webcomponents-app'),
  showWhenPrefix(['/webcomponents']),
);

singleSpa.registerApplication(
  'typescript',
  () => import('@your-org/single-spa-typescript-app'),
  showWhenPrefix(['/typescript']),
);

singleSpa.registerApplication(
  'jquery',
  () => import('@your-org/single-spa-jquery-app'),
  showWhenPrefix(['/jquery']),
);

singleSpa.registerApplication(
  'svelte',
  () => import('@your-org/single-spa-svelte-app'),
  showWhenPrefix(['/svelte']),
);

singleSpa.start();