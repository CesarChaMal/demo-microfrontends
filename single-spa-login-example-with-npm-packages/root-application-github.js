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
    'single-spa-vanilla-app': 'https://cesarchamal.github.io/single-spa-vanilla-app/single-spa-vanilla-app.js',
    'single-spa-webcomponents-app': 'https://cesarchamal.github.io/single-spa-webcomponents-app/single-spa-webcomponents-app.js',
    'single-spa-typescript-app': 'https://cesarchamal.github.io/single-spa-typescript-app/single-spa-typescript-app.js',
    'single-spa-jquery-app': 'https://cesarchamal.github.io/single-spa-jquery-app/single-spa-jquery-app.js',
    'single-spa-svelte-app': 'https://cesarchamal.github.io/single-spa-svelte-app/single-spa-svelte-app.js',
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
singleSpa.registerApplication('vanilla', () => System.import('single-spa-vanilla-app'), showWhenPrefix(['/vanilla']));
singleSpa.registerApplication('webcomponents', () => System.import('single-spa-webcomponents-app'), showWhenPrefix(['/webcomponents']));
singleSpa.registerApplication('typescript', () => System.import('single-spa-typescript-app'), showWhenPrefix(['/typescript']));
singleSpa.registerApplication('jquery', () => System.import('single-spa-jquery-app'), showWhenPrefix(['/jquery']));
singleSpa.registerApplication('svelte', () => System.import('single-spa-svelte-app'), showWhenPrefix(['/svelte']));

singleSpa.start();
