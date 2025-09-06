/* eslint-env browser */
/* global System */
import * as singleSpa from 'single-spa';
import 'zone.js';
import 'bootstrap/dist/css/bootstrap.css';
import 'bootstrap-vue/dist/bootstrap-vue.css';

// AWS S3 configuration
const AWS_CONFIG = {
  s3Bucket: 'single-spa-demo-774145483743',
  region: 'eu-central-1',
  orgName: 'cesarchamal',
};

// Import map URL
const IMPORT_MAP_URL = `https://${AWS_CONFIG.s3Bucket}.s3.${AWS_CONFIG.region}.amazonaws.com/@${AWS_CONFIG.orgName}/importmap.json`;

console.log(`🚀 Single-SPA AWS Mode - Loading from S3: ${IMPORT_MAP_URL}`);

// Load import map from S3 and configure SystemJS
async function loadImportMap() {
  try {
    const response = await fetch(IMPORT_MAP_URL);
    const importMap = await response.json();
    
    console.log('📦 Import map loaded from S3:', importMap);
    
    // Configure SystemJS with the import map
    System.config({
      map: importMap.imports || {}
    });
    
    return importMap;
  } catch (error) {
    console.error('❌ Failed to load import map from S3:', error);
    // Fallback to empty import map
    return { imports: {} };
  }
}

// Helper functions for routing
function showWhenAnyOf(routes) {
  return (location) => routes.some((route) => location.pathname === route);
}

function showWhenPrefix(routes) {
  return (location) => routes.some((route) => location.pathname.startsWith(route));
}

function showExcept(routes) {
  return (location) => routes.every((route) => location.pathname !== route);
}

// App name mapping to import map module names
const APP_MODULE_MAP = {
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

// Load app from S3 using import map
function loadAppFromS3(appName) {
  const moduleName = APP_MODULE_MAP[appName];
  if (!moduleName) {
    throw new Error(`Unknown app: ${appName}`);
  }
  
  console.log(`📥 Loading ${appName} as ${moduleName} from S3`);
  return System.import(moduleName);
}

// Initialize the application
async function initializeApp() {
  // Load import map first
  await loadImportMap();
  
  // Register all applications
  singleSpa.registerApplication('login', () => loadAppFromS3('single-spa-auth-app'), showWhenAnyOf(['/login']));
  singleSpa.registerApplication('layout', () => loadAppFromS3('single-spa-layout-app'), showExcept(['/login']));
  singleSpa.registerApplication('home', () => loadAppFromS3('single-spa-home-app'), showWhenAnyOf(['/']));
  singleSpa.registerApplication('angular', () => loadAppFromS3('single-spa-angular-app'), showWhenPrefix(['/angular']));
  singleSpa.registerApplication('vue', () => loadAppFromS3('single-spa-vue-app'), showWhenPrefix(['/vue']));
  singleSpa.registerApplication('react', () => loadAppFromS3('single-spa-react-app'), showWhenPrefix(['/react']));
  singleSpa.registerApplication('vanilla', () => loadAppFromS3('single-spa-vanilla-app'), showWhenPrefix(['/vanilla']));
  singleSpa.registerApplication('webcomponents', () => loadAppFromS3('single-spa-webcomponents-app'), showWhenPrefix(['/webcomponents']));
  singleSpa.registerApplication('typescript', () => loadAppFromS3('single-spa-typescript-app'), showWhenPrefix(['/typescript']));
  singleSpa.registerApplication('jquery', () => loadAppFromS3('single-spa-jquery-app'), showWhenPrefix(['/jquery']));
  singleSpa.registerApplication('svelte', () => loadAppFromS3('single-spa-svelte-app'), showWhenPrefix(['/svelte']));
  
  // Start Single-SPA
  singleSpa.start();
  console.log('✅ Single-SPA started in AWS mode');
}

// Initialize the application
initializeApp().catch(error => {
  console.error('❌ Failed to initialize Single-SPA in AWS mode:', error);
});