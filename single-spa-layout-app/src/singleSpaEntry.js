/* eslint-disable import/no-unresolved */
/* eslint-disable import/no-extraneous-dependencies */
/* eslint-disable prefer-destructuring */
/* eslint-disable no-console */
import Vue from 'vue';
import singleSpaVue from 'single-spa-vue';
import BootstrapVue from 'bootstrap-vue';
import { library } from '@fortawesome/fontawesome-svg-core';
import { faGithub } from '@fortawesome/free-brands-svg-icons';
import {
  faHome,
  faUserCircle,
  faSignOutAlt,
  faCube,
} from '@fortawesome/free-solid-svg-icons';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';
import App from './App.vue';
import './styles/styles.scss';

library.add(faGithub, faHome, faUserCircle, faSignOutAlt, faCube);

Vue.component('font-awesome-icon', FontAwesomeIcon);
Vue.use(BootstrapVue);
Vue.config.productionTip = false;

const vueLifecycles = singleSpaVue({
  Vue,
  appOptions: {
    el: '#layout-app',
    render: (h) => h(App),
  },
});

/*
// Add debug logging to original functions
const originalBootstrap = vueLifecycles.bootstrap;
const originalMount = vueLifecycles.mount;
const originalUnmount = vueLifecycles.unmount;

vueLifecycles.bootstrap = function (props) {
  console.log('🎨 Layout App bootstrapping with props:', props);
  return originalBootstrap.call(this, props);
};

vueLifecycles.mount = function (props) {
  console.log('🎨 Layout App mounting with props:', props);
  return originalMount.call(this, props);
};

vueLifecycles.unmount = function (props) {
  console.log('🎨 Layout App unmounting');
  return originalUnmount.call(this, props);
};
*/

export const bootstrap = vueLifecycles.bootstrap;
export const mount = vueLifecycles.mount;
export const unmount = vueLifecycles.unmount;

// For UMD builds, expose on window
if (typeof window !== 'undefined') {
  window['single-spa-layout-app'] = { bootstrap, mount, unmount };
}

// Default export for UMD builds
export default {
  bootstrap,
  mount,
  unmount,
};
