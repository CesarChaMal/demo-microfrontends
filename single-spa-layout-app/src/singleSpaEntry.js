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

// Wrap lifecycle functions with debug logging
/*
const debugBootstrap = (props) => {
  console.log('🎨 Layout App bootstrapping with props:', props);
  return vueLifecycles.bootstrap(props);
};
const debugMount = (props) => {
  console.log('🎨 Layout App mounting with props:', props);
  return vueLifecycles.mount(props);
};
const debugUnmount = (props) => {
  console.log('🎨 Layout App unmounting');
  return vueLifecycles.unmount(props);
};

// Export lifecycle functions as named exports
export const bootstrap = debugBootstrap;
export const mount = debugMount;
export const unmount = debugUnmount;

// For UMD builds, expose on window
if (typeof window !== 'undefined') {
  window['single-spa-layout-app'] = {
    bootstrap: debugBootstrap,
    mount: debugMount,
    unmount: debugUnmount,
  };
}

// Default export for UMD builds
export default {
  bootstrap: debugBootstrap,
  mount: debugMount,
  unmount: debugUnmount,
};
*/

export const { bootstrap } = vueLifecycles;
export const { mount } = vueLifecycles;
export const { unmount } = vueLifecycles;

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
