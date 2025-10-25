/* eslint-env browser */
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

singleSpa.registerApplication(
  'vanilla',
  () => import('single-spa-vanilla-app'),
  showWhenPrefix(['/vanilla']),
);

singleSpa.registerApplication(
  'webcomponents',
  () => import('single-spa-webcomponents-app'),
  showWhenPrefix(['/webcomponents']),
);

singleSpa.registerApplication(
  'typescript',
  () => import('single-spa-typescript-app/src/single-spa-typescript-app'),
  showWhenPrefix(['/typescript']),
);

singleSpa.registerApplication(
  'jquery',
  () => import('single-spa-jquery-app'),
  showWhenPrefix(['/jquery']),
);

singleSpa.registerApplication(
  'svelte',
  () => import('single-spa-svelte-app'),
  showWhenPrefix(['/svelte']),
);

singleSpa.start();
