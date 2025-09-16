/* eslint-disable import/no-unresolved */
/* eslint-disable import/no-extraneous-dependencies */
/* eslint-disable prefer-destructuring */
/* eslint-disable no-console */
import Vue from 'vue';
import singleSpaVue from 'single-spa-vue';
import BootstrapVue from 'bootstrap-vue';
import { library } from '@fortawesome/fontawesome-svg-core';
import { faGithub } from '@fortawesome/free-brands-svg-icons';
import { faSignInAlt, faInfoCircle } from '@fortawesome/free-solid-svg-icons';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';
import App from './App.vue';
import router from './router';

library.add(faGithub, faSignInAlt, faInfoCircle);

Vue.component('font-awesome-icon', FontAwesomeIcon);
Vue.use(BootstrapVue);

Vue.config.productionTip = false;

const vueLifecycles = singleSpaVue({
  Vue,
  appOptions: {
    render: (h) => h(App),
    router,
  },
  handleInstance: (app) => {
    app.$mount('#auth-app');
  },
});

// Export lifecycle functions as named exports
export const bootstrap = vueLifecycles.bootstrap;
export const mount = (props) => {
  console.log('🔐 Auth App mounting with props:', props);
  return vueLifecycles.mount(props);
};
export const unmount = (props) => {
  console.log('🔐 Auth App unmounting');
  return vueLifecycles.unmount(props).then(() => {
    // Clean up the mount point to prevent layout issues
    const mountPoint = document.getElementById('auth-app');
    if (mountPoint) {
      mountPoint.innerHTML = '';
      mountPoint.style.display = 'none';
      mountPoint.style.height = '0';
      mountPoint.style.margin = '0';
      mountPoint.style.padding = '0';
    }
  });
};

// For UMD builds, expose on window
if (typeof window !== 'undefined') {
  window['single-spa-auth-app'] = { bootstrap, mount, unmount };
}

// Default export for UMD builds
export default {
  bootstrap,
  mount,
  unmount,
};
