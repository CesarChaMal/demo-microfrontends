/* eslint-disable import/no-unresolved */
/* eslint-disable import/no-extraneous-dependencies */
/* eslint-disable prefer-destructuring */
/* eslint-disable no-console */
import Vue from 'vue';
import singleSpaVue from 'single-spa-vue';
import BootstrapVue from 'bootstrap-vue';
import App from './App.vue';
import router from './router';

Vue.use(BootstrapVue);

Vue.config.productionTip = false;

const vueLifecycles = singleSpaVue({
  Vue,
  appOptions: {
    render: (h) => h(App),
    router,
  },
  domElementGetter: () => document.getElementById('vue-app'),
});

// Export lifecycle functions as named exports
export const bootstrap = vueLifecycles.bootstrap;
export const mount = (props) => {
  console.log('💚 Vue App mounting with props:', props);
  return vueLifecycles.mount(props);
};
export const unmount = (props) => {
  console.log('💚 Vue App unmounting');
  return vueLifecycles.unmount(props);
};

// For UMD builds, expose on window
if (typeof window !== 'undefined') {
  window['single-spa-vue-app'] = { bootstrap, mount, unmount };
}

// Default export for UMD builds
export default {
  bootstrap,
  mount,
  unmount,
};
