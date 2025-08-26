/* eslint-env browser */
/* global System */
import * as singleSpa from 'single-spa';
import 'zone.js';
import 'bootstrap/dist/css/bootstrap.css';
import 'bootstrap-vue/dist/bootstrap-vue.css';

// Register external modules from GitHub Pages
System.import = System.import || window.importShim || (() => Promise.reject('System.import not available'));

System.config({
  paths: {
    'single-spa-auth-app': 'https://cesarchamal.github.io/single-spa-auth-app/single-spa-auth-app.js',
    'single-spa-layout-app': 'https://cesarchamal.github.io/single-spa-layout-app/single-spa-layout-app.js',
    'single-spa-home-app': 'https://cesarchamal.github.io/single-spa-home-app/single-spa-home-app.js',
    'single-spa-angular-app': 'https://cesarchamal.github.io/single-spa-angular-app/single-spa-angular-app.js',
    'single-spa-vue-app': 'https://cesarchamal.github.io/single-spa-vue-app/single-spa-vue-app.js',
    'single-spa-react-app': 'https://cesarchamal.github.io/single-spa-react-app/single-spa-react-app.js',
  }
});

function showWhenAnyOf(routes) {
  return (location) => routes.some((route) => location.pathname === route);
}

function showWhenPrefix(routes) {
  return (location) => routes.some((route) => location.pathname.startsWith(route));
}

function showExcept(routes) {
  return (location) => routes.every((route) => location.pathname !== route);
}

singleSpa.registerApplication('login', () => System.import('single-spa-auth-app'), showWhenAnyOf(['/login']));
singleSpa.registerApplication('layout', () => System.import('single-spa-layout-app'), showExcept(['/login']));
singleSpa.registerApplication('home', () => System.import('single-spa-home-app'), showWhenAnyOf(['/']));
singleSpa.registerApplication('angular', () => System.import('single-spa-angular-app'), showWhenPrefix(['/angular']));
singleSpa.registerApplication('vue', () => System.import('single-spa-vue-app'), showWhenPrefix(['/vue']));
singleSpa.registerApplication('react', () => System.import('single-spa-react-app'), showWhenPrefix(['/react']));

singleSpa.start();
