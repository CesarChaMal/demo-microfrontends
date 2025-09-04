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

// Get mode from environment variables (via webpack), URL parameter, or localStorage
const urlParams = new URLSearchParams(window.location.search);
const envMode = process.env.SPA_MODE || MODES.LOCAL;
const envEnvironment = process.env.SPA_ENV || 'dev';
// Prioritize environment variables over localStorage
const mode = envMode !== MODES.LOCAL ? envMode : (urlParams.get('mode') || localStorage.getItem('spa-mode') || envMode);

// Save mode to localStorage for persistence
localStorage.setItem('spa-mode', mode);

// Display current mode
console.log(`🚀 Single-SPA Mode: ${mode.toUpperCase()}`);
console.log(`🔧 Environment Variables - SPA_MODE: ${process.env.SPA_MODE}, SPA_ENV: ${process.env.SPA_ENV}`);

// AWS S3 deployment function
function deployToAWS() {
  console.log('🚀 AWS deployment uses existing deployment scripts');
  
  const { S3_WEBSITE_URL } = window;
  
  if (S3_WEBSITE_URL) {
    const message = `🎉 AWS S3 Deployment Available!\n\n` +
                   `🌍 Public URL: ${S3_WEBSITE_URL}\n\n` +
                   `Your application is deployed and live on the internet!`;
    
    alert(message);
    console.log('🌍 S3 Website URL:', S3_WEBSITE_URL);
  } else {
    const message = `🚀 AWS S3 Deployment\n\n` +
                   `Run the deployment script to deploy to S3:\n` +
                   `./scripts/deploy-s3.sh prod (Linux/Mac)\n` +
                   `scripts\\deploy-s3.bat prod (Windows)`;
    
    alert(message);
  }
}

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

console.log('🔍 Mode comparison debug:');
console.log(`  - mode: '${mode}' (type: ${typeof mode})`);
console.log(`  - MODES.AWS: '${MODES.AWS}' (type: ${typeof MODES.AWS})`);
console.log(`  - mode === MODES.AWS: ${mode === MODES.AWS}`);
console.log(`  - mode === 'aws': ${mode === 'aws'}`);

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
    const githubEnv = envEnvironment;
    const { GITHUB_USERNAME } = window;
    const githubUser = GITHUB_USERNAME || process.env.GITHUB_USERNAME || 'cesarchamal';

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

    // AWS - different behavior for dev vs prod
    const { S3_WEBSITE_URL } = window;
    const publicUrl = S3_WEBSITE_URL || `http://${AWS_CONFIG.bucket}.s3-website-${AWS_CONFIG.region}.amazonaws.com`;
    
    if (envEnvironment === 'prod') {
      // Production: Deploy everything to S3 + show public URL
      console.log('🔧 AWS prod mode: Deploying all microfrontends to S3...');
      console.log('🌍 Public S3 Website will be available at:');
      console.log(`   ${publicUrl}`);
      deployToAWS();
    } else {
      // Development: Just read from existing S3
      console.log('📖 AWS dev mode: Reading from existing S3 deployment...');
      console.log('🌍 Public S3 Website:');
      console.log(`   ${publicUrl}`);
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
    // Local mode - detect if production build (files served from root)
    // or development (individual ports)
    loadApp = (name) => {
      // Check if we're in production mode using environment variable
      const isProduction = envEnvironment === 'prod';

      // Debug information
      console.log('🔍 LOCAL Mode Debug Info:');
      console.log('  - URL:', window.location.href);
      console.log('  - Port:', window.location.port);
      console.log('  - SPA_MODE:', process.env.SPA_MODE);
      console.log('  - SPA_ENV:', process.env.SPA_ENV);
      console.log('  - envEnvironment:', envEnvironment);
      console.log('  - isProduction:', isProduction);
      console.log('  - Mode will be:', isProduction ? 'PRODUCTION (root server)' : 'DEVELOPMENT (individual ports)');

      const appUrls = isProduction ? {
        // Production: Load from root server static files
        'single-spa-auth-app': '/single-spa-auth-app.umd.js',
        'single-spa-layout-app': '/single-spa-layout-app.umd.js',
        'single-spa-home-app': '/single-spa-home-app.js',
        'single-spa-angular-app': '/single-spa-angular-app.js',
        'single-spa-vue-app': '/single-spa-vue-app.umd.js',
        'single-spa-react-app': '/single-spa-react-app.js',
        'single-spa-vanilla-app': '/single-spa-vanilla-app.js',
        'single-spa-webcomponents-app': '/single-spa-webcomponents-app.js',
        'single-spa-typescript-app': '/single-spa-typescript-app.js',
        'single-spa-jquery-app': '/single-spa-jquery-app.js',
        'single-spa-svelte-app': '/single-spa-svelte-app.js',
      } : {
        // Development: Load from individual ports
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
      console.log(`🔍 Debug: Using ${isProduction ? 'PRODUCTION' : 'DEVELOPMENT'} URLs for ${name}`);

      return window.System.import(url).then((module) => {
        console.log(`✅ Successfully loaded ${name}:`, module);


        // Handle different module formats
        let lifecycles;

        // Check if it's a proper single-spa app with lifecycle functions
        if (module.bootstrap && module.mount && module.unmount) {
          lifecycles = module;
        } else if (module.default && module.default.bootstrap) {
          lifecycles = module.default;
        } else if (window['single-spa-layout-app']) {
          // Check if it's exposed on window (UMD)
          lifecycles = window['single-spa-layout-app'];
        } else if (window[name.replace(/-/g, '')]) {
          // Check if it's exposed on window (UMD)
          const globalName = name.replace(/-/g, '');
          console.log('globalName: ', globalName);
          lifecycles = window[globalName];
        } else {
          // Try specific UMD global names
          const umdGlobals = {
            'single-spa-auth-app': 'singleSpaAuthApp',
            'single-spa-layout-app': 'singleSpaLayoutApp',
            'single-spa-home-app': 'singleSpaHomeApp',
            'single-spa-angular-app': 'singleSpaAngularApp',
            'single-spa-vue-app': 'singleSpaVueApp',
            'single-spa-react-app': 'singleSpaReactApp',
            'single-spa-vanilla-app': 'singleSpaVanillaApp',
            'single-spa-webcomponents-app': 'singleSpaWebcomponentsApp',
            'single-spa-typescript-app': 'singleSpaTypescriptApp',
            'single-spa-jquery-app': 'singleSpaJqueryApp',
            'single-spa-svelte-app': 'singleSpaSvelteApp',
          };
          const umdGlobalName = umdGlobals[name];
          console.log(`🔍 Debug: Trying UMD global '${umdGlobalName}' for ${name}`);
          console.log('🔍 Debug: Available globals:', Object.keys(window).filter((k) => k.includes('single') || k.includes('Spa')));

          if (umdGlobalName && window[umdGlobalName]) {
            console.log(`✅ Found UMD global '${umdGlobalName}' for ${name}`);
            lifecycles = window[umdGlobalName];
          } else {
            console.error(`❌ Invalid module format for ${name}. Expected single-spa lifecycles.`);
            console.log('🔍 Debug: Module structure:', module);
            console.log('🔍 Debug: Expected UMD global:', umdGlobalName);
            console.log('🔍 Debug: Available on window:', !!window[umdGlobalName]);
            throw new Error(`Module ${name} does not export valid single-spa lifecycles`);
          }
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
  (location) => !isAuthenticated() || location.pathname === '/login',
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
