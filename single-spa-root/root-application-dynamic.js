/* eslint-env browser */
/* eslint-disable no-unused-vars */
/* eslint-disable func-names */
/* eslint-disable no-console */
import * as singleSpa from 'single-spa';
import 'zone.js';

import 'bootstrap/dist/css/bootstrap.css';
import 'bootstrap-vue/dist/bootstrap-vue.css';

// Configuration modes
const MODES = {
  LOCAL: 'local',
  NPM: 'npm',
  NEXUS: 'nexus',
  GITHUB: 'github',
};

// Get mode from URL parameter or localStorage, default to LOCAL
const urlParams = new URLSearchParams(window.location.search);
const mode = urlParams.get('mode') || localStorage.getItem('spa-mode') || MODES.LOCAL;

// Save mode to localStorage for persistence
localStorage.setItem('spa-mode', mode);

// Display current mode
console.log(`🚀 Single-SPA Mode: ${mode.toUpperCase()}`);

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

// Configure loading strategy based on mode
let loadApp;

switch (mode) {
  case MODES.NPM:
    // NPM package imports
    loadApp = (name) => import(name);
    break;

  case MODES.NEXUS:
    // Nexus private registry imports (scoped packages)
    loadApp = (name) => {
      // Convert package name to scoped Nexus package
      const scopedName = `@your-org/${name}`;
      return import(scopedName);
    };
    break;

  case MODES.GITHUB:
    // GitHub Pages - use direct imports
    loadApp = (name) => {
      const appUrls = {
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
      };
      return import(appUrls[name]);
    };
    break;

  case MODES.LOCAL:
  default:
    // Local development - use SystemJS for external URLs
    loadApp = (name) => {
      const appUrls = {
        'single-spa-auth-app': 'http://localhost:4201/single-spa-auth-app.umd.js',
        'single-spa-layout-app': 'http://localhost:4202/single-spa-layout-app.umd.js',
        'single-spa-home-app': 'http://localhost:4203/single-spa-home-app.js',
        'single-spa-angular-app': 'http://localhost:4204/single-spa-angular-app.js',
        'single-spa-vue-app': 'http://localhost:4205/single-spa-vue-app.umd.js',
        'single-spa-react-app': 'http://localhost:4206/single-spa-react-app.js',
        'single-spa-vanilla-app': 'http://localhost:4207/single-spa-vanilla-app.js',
        'single-spa-webcomponents-app': 'http://localhost:4208/single-spa-webcomponents-app.js',
        'single-spa-typescript-app': 'http://localhost:4209/single-spa-typescript-app.js',
        'single-spa-jquery-app': 'http://localhost:4210/single-spa-jquery-app.js',
        'single-spa-svelte-app': 'http://localhost:4211/single-spa-svelte-app.js',
      };
      const url = appUrls[name];
      console.log(`Loading ${name} from ${url}`);
      return window.System.import(url);
    };
    break;
}

// Register applications using the selected loading strategy
singleSpa.registerApplication(
  'login',
  () => loadApp('single-spa-auth-app'),
  showWhenAnyOf(['/login']),
);

singleSpa.registerApplication(
  'layout',
  () => loadApp('single-spa-layout-app'),
  showExcept(['/login']),
);

singleSpa.registerApplication(
  'home',
  () => loadApp('single-spa-home-app'),
  showWhenAnyOf(['/']),
);

singleSpa.registerApplication(
  'angular',
  () => loadApp('single-spa-angular-app'),
  showWhenPrefix(['/angular']),
);

singleSpa.registerApplication(
  'vue',
  () => loadApp('single-spa-vue-app'),
  showWhenPrefix(['/vue']),
);

singleSpa.registerApplication(
  'react',
  () => loadApp('single-spa-react-app'),
  showWhenPrefix(['/react']),
);

singleSpa.registerApplication(
  'vanilla',
  () => loadApp('single-spa-vanilla-app'),
  showWhenPrefix(['/vanilla']),
);

singleSpa.registerApplication(
  'webcomponents',
  () => loadApp('single-spa-webcomponents-app'),
  showWhenPrefix(['/webcomponents']),
);

singleSpa.registerApplication(
  'typescript',
  () => loadApp('single-spa-typescript-app'),
  showWhenPrefix(['/typescript']),
);

singleSpa.registerApplication(
  'jquery',
  () => loadApp('single-spa-jquery-app'),
  showWhenPrefix(['/jquery']),
);

singleSpa.registerApplication(
  'svelte',
  () => loadApp('single-spa-svelte-app'),
  showWhenPrefix(['/svelte']),
);

singleSpa.start();
