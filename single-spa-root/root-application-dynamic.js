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
  AWS: 'aws',
};

// Get mode from URL parameter or localStorage, default to LOCAL
const urlParams = new URLSearchParams(window.location.search);
const mode = urlParams.get('mode') || localStorage.getItem('spa-mode') || MODES.LOCAL;

// Save mode to localStorage for persistence
localStorage.setItem('spa-mode', mode);

// Display current mode
console.log(`🚀 Single-SPA Mode: ${mode.toUpperCase()}`);

// GitHub repository creation and deployment function
function createGitHubRepos() {
  const apps = [
    'single-spa-auth-app',
    'single-spa-layout-app',
    'single-spa-home-app',
    'single-spa-angular-app',
    'single-spa-vue-app',
    'single-spa-react-app',
    'single-spa-vanilla-app',
    'single-spa-webcomponents-app',
    'single-spa-typescript-app',
    'single-spa-jquery-app',
    'single-spa-svelte-app',
    'single-spa-root',
  ];

  console.log('📦 Creating and deploying GitHub repositories for all microfrontends...');

  // Create all repositories and deploy them
  fetch('http://localhost:3001/api/create-all-repos', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ apps }),
  })
    .then((response) => response.json())
    .then((data) => {
      if (data.success) {
        console.log('✅ All repositories created and deployed successfully');
        console.log('🔄 Repositories will be available at GitHub Pages shortly...');
      } else {
        console.log(`⚠️ Repository creation/deployment failed: ${data.error}`);
      }
    })
    .catch((error) => {
      console.log('⚠️ Could not create/deploy repos - API unavailable:', error);
    });
}

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

// Authentication helper function
function isAuthenticated() {
  return sessionStorage.getItem('token') !== null;
}

// Protected route helper - requires authentication
function showWhenAuthenticatedAndPrefix(routes) {
  return function (location) {
    return isAuthenticated() && routes.some((route) => location.pathname.startsWith(route));
  };
}

function showWhenAuthenticatedAndAnyOf(routes) {
  return function (location) {
    return isAuthenticated() && routes.some((route) => location.pathname === route);
  };
}

function showWhenAuthenticatedExcept(routes) {
  return function (location) {
    return isAuthenticated() && routes.every((route) => location.pathname !== route);
  };
}

// AWS S3 import map configuration from webpack template (environment variables)
const { AWS_CONFIG } = window;
const { IMPORTMAP_URL } = window;

// Only warn about AWS config if we're actually using AWS mode
if (mode === MODES.AWS && (!AWS_CONFIG || !IMPORTMAP_URL)) {
  console.warn('⚠️ AWS configuration not found. Make sure environment variables are set: S3_BUCKET, AWS_REGION, ORG_NAME');
}

// Configure loading strategy based on mode
let loadApp;
let importMapPromise;

switch (mode) {
  case MODES.NPM:
    // NPM package imports
    loadApp = (name) => {
      console.log(`Loading ${name} from NPM`);
      return import(name).catch((error) => {
        console.error(`Failed to load ${name} from NPM:`, error);
        throw error;
      });
    };
    break;

  case MODES.NEXUS:
    // Nexus private registry imports (scoped packages)
    loadApp = (name) => {
      // Convert package name to scoped Nexus package
      const scopedName = `@cesarchamal/${name}`;
      console.log(`Loading ${name} from Nexus: ${scopedName}`);
      return import(scopedName).catch((error) => {
        console.error(`Failed to load ${name} from Nexus:`, error);
        throw error;
      });
    };
    break;

  case MODES.GITHUB: {
    // GitHub Pages - different behavior for dev vs prod
    const githubUrlParams = new URLSearchParams(window.location.search);
    const githubEnv = githubUrlParams.get('env') || 'dev';
    const { GITHUB_USERNAME } = window;
    const githubUser = GITHUB_USERNAME || 'cesarchamal';

    if (githubEnv === 'prod') {
      // Production: Create repos and deploy everything
      console.log('🔧 GitHub prod mode: Creating and deploying repositories...');
      createGitHubRepos();
    } else {
      // Development: Just read from existing GitHub Pages
      console.log('📖 GitHub dev mode: Reading from existing GitHub Pages...');
    }

    loadApp = (name) => {
      const appUrls = {
        'single-spa-auth-app': `https://${githubUser}.github.io/single-spa-auth-app/single-spa-auth-app.js`,
        'single-spa-layout-app': `https://${githubUser}.github.io/single-spa-layout-app/single-spa-layout-app.js`,
        'single-spa-home-app': `https://${githubUser}.github.io/single-spa-home-app/single-spa-home-app.js`,
        'single-spa-angular-app': `https://${githubUser}.github.io/single-spa-angular-app/single-spa-angular-app.js`,
        'single-spa-vue-app': `https://${githubUser}.github.io/single-spa-vue-app/single-spa-vue-app.js`,
        'single-spa-react-app': `https://${githubUser}.github.io/single-spa-react-app/single-spa-react-app.js`,
        'single-spa-vanilla-app': `https://${githubUser}.github.io/single-spa-vanilla-app/single-spa-vanilla-app.js`,
        'single-spa-webcomponents-app': `https://${githubUser}.github.io/single-spa-webcomponents-app/single-spa-webcomponents-app.js`,
        'single-spa-typescript-app': `https://${githubUser}.github.io/single-spa-typescript-app/single-spa-typescript-app.js`,
        'single-spa-jquery-app': `https://${githubUser}.github.io/single-spa-jquery-app/single-spa-jquery-app.js`,
        'single-spa-svelte-app': `https://${githubUser}.github.io/single-spa-svelte-app/single-spa-svelte-app.js`,
      };
      const url = appUrls[name];
      console.log(`Loading ${name} from GitHub: ${url}`);
      return import(url).catch((error) => {
        console.error(`Failed to load ${name} from GitHub:`, error);
        throw error;
      });
    };
    break;
  }

  case MODES.AWS:
    // AWS S3 - load from import map
    if (!IMPORTMAP_URL || !AWS_CONFIG) {
      throw new Error('❌ AWS mode requires environment variables: S3_BUCKET, AWS_REGION, ORG_NAME');
    }

    console.log(`📦 Loading import map from: ${IMPORTMAP_URL}`);
    console.log('🔧 AWS Config:', AWS_CONFIG);
    importMapPromise = fetch(IMPORTMAP_URL)
      .then((response) => response.json())
      .catch((error) => {
        console.error('Failed to load import map from S3:', error);
        return { imports: {} };
      });

    loadApp = async (name) => {
      const importMap = await importMapPromise;
      const appNameMap = {
        'single-spa-auth-app': `@${AWS_CONFIG.orgName}/auth-app`,
        'single-spa-layout-app': `@${AWS_CONFIG.orgName}/layout-app`,
        'single-spa-home-app': `@${AWS_CONFIG.orgName}/home-app`,
        'single-spa-angular-app': `@${AWS_CONFIG.orgName}/angular-app`,
        'single-spa-vue-app': `@${AWS_CONFIG.orgName}/vue-app`,
        'single-spa-react-app': `@${AWS_CONFIG.orgName}/react-app`,
        'single-spa-vanilla-app': `@${AWS_CONFIG.orgName}/vanilla-app`,
        'single-spa-webcomponents-app': `@${AWS_CONFIG.orgName}/webcomponents-app`,
        'single-spa-typescript-app': `@${AWS_CONFIG.orgName}/typescript-app`,
        'single-spa-jquery-app': `@${AWS_CONFIG.orgName}/jquery-app`,
        'single-spa-svelte-app': `@${AWS_CONFIG.orgName}/svelte-app`,
      };

      const moduleName = appNameMap[name];
      const url = importMap.imports[moduleName];

      if (!url) {
        throw new Error(`Module ${moduleName} not found in import map`);
      }

      console.log(`Loading ${name} from S3: ${url}`);
      return window.System.import(url).catch((error) => {
        console.error(`Failed to load ${name} from S3:`, error);
        throw error;
      });
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
      console.log(`🚀 Loading ${name} from ${url}`);

      return window.System.import(url).then((module) => {
        console.log(`✅ Successfully loaded ${name}:`, module);
        /*
          return window.System.import(url).then((module) => {
            console.log(`✅ Successfully loaded ${name}:`, module);
            if (name === 'single-spa-layout-app') {
              console.log('🎨 Layout module exports:', Object.keys(module));
              console.log('🎨 Layout bootstrap:', typeof module.bootstrap);
              console.log('🎨 Layout mount:', typeof module.mount);
              console.log('🎨 Layout unmount:', typeof module.unmount);
              console.log('🎨 Layout default:', module.default);
            }
            return module;
    */

        // Handle different module formats
        let lifecycles;

        // Check if it's a proper single-spa app with lifecycle functions
        if (module.bootstrap && module.mount && module.unmount) {
          lifecycles = module;
        } else if (module.default && module.default.bootstrap) {
          lifecycles = module.default;
        // } else if (window['single-spa-layout-app']) {
        //   // Check if it's exposed on window (UMD)
        //   lifecycles = window['single-spa-layout-app'];
        } else if (window[name.replace(/-/g, '')]) {
          // Check if it's exposed on window (UMD)
          const globalName = name.replace(/-/g, '');
          console.log('globalName: ', globalName);
          lifecycles = window[globalName];
        } else {
          console.error(`❌ Invalid module format for ${name}. Expected single-spa lifecycles.`);
          console.log('Module structure:', module);
          throw new Error(`Module ${name} does not export valid single-spa lifecycles`);
        }

        console.log(`✅ ${name} lifecycles resolved:`, {
          bootstrap: typeof lifecycles.bootstrap,
          mount: typeof lifecycles.mount,
          unmount: typeof lifecycles.unmount,
        });

        return lifecycles;
      }).catch((error) => {
        console.error(`❌ Failed to load ${name} locally:`, error);
        throw error;
      });
    };
    break;
}

// Register applications using the selected loading strategy
singleSpa.registerApplication(
  'login',
  () => loadApp('single-spa-auth-app'),
  (location) => {
    // Show login if not authenticated OR explicitly at /login
    return !isAuthenticated() || location.pathname === '/login';
  },
);

singleSpa.registerApplication(
  'layout',
  () => loadApp('single-spa-layout-app'),
  showWhenAuthenticatedExcept(['/login']),
);

singleSpa.registerApplication(
  'home',
  () => loadApp('single-spa-home-app'),
  showWhenAuthenticatedAndAnyOf(['/']),
);

singleSpa.registerApplication(
  'angular',
  () => loadApp('single-spa-angular-app'),
  showWhenAuthenticatedAndPrefix(['/angular']),
);

singleSpa.registerApplication(
  'vue',
  () => loadApp('single-spa-vue-app'),
  showWhenAuthenticatedAndPrefix(['/vue']),
);

singleSpa.registerApplication(
  'react',
  () => loadApp('single-spa-react-app'),
  showWhenAuthenticatedAndPrefix(['/react']),
);

singleSpa.registerApplication(
  'vanilla',
  () => loadApp('single-spa-vanilla-app'),
  showWhenAuthenticatedAndPrefix(['/vanilla']),
);

singleSpa.registerApplication(
  'webcomponents',
  () => loadApp('single-spa-webcomponents-app'),
  showWhenAuthenticatedAndPrefix(['/webcomponents']),
);

singleSpa.registerApplication(
  'typescript',
  () => loadApp('single-spa-typescript-app'),
  showWhenAuthenticatedAndPrefix(['/typescript']),
);

singleSpa.registerApplication(
  'jquery',
  () => loadApp('single-spa-jquery-app'),
  showWhenAuthenticatedAndPrefix(['/jquery']),
);

singleSpa.registerApplication(
  'svelte',
  () => loadApp('single-spa-svelte-app'),
  showWhenAuthenticatedAndPrefix(['/svelte']),
);

// Add event listeners to debug Single-SPA lifecycle
window.addEventListener('single-spa:before-routing-event', (evt) => {
  console.log('📍 Single-SPA before routing event:', evt.detail);
});

window.addEventListener('single-spa:routing-event', (evt) => {
  console.log('📍 Single-SPA routing event:', evt.detail);
});

window.addEventListener('single-spa:app-change', (evt) => {
  console.log('📍 Single-SPA app change:', evt.detail);
});

console.log('🚀 Starting Single-SPA...');
singleSpa.start();
console.log('✅ Single-SPA started');

// Log current location
console.log('📍 Current location:', window.location.pathname);
