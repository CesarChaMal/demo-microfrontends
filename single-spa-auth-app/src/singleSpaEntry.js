/* eslint-disable import/no-unresolved */
/* eslint-disable import/no-extraneous-dependencies */
import Vue from 'vue';
import singleSpaVue from 'single-spa-vue';
import { library } from '@fortawesome/fontawesome-svg-core';
import { faGithub } from '@fortawesome/free-brands-svg-icons';
import { faSignInAlt, faInfoCircle } from '@fortawesome/free-solid-svg-icons';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';
import App from './App.vue';
import router from './router';

library.add(faGithub, faSignInAlt, faInfoCircle);

Vue.component('font-awesome-icon', FontAwesomeIcon);

// Temporarily disable problematic plugins
// Vue.use(BootstrapVue);
// Vue.use(VueToastr);
// Vue.use(require('vue-script2'));
// Vue.use(Ads.AutoAdsense);

Vue.config.productionTip = false;

const vueLifecycles = singleSpaVue({
  Vue,
  appOptions: {
    el: '#auth-app',
    render: (h) => h(App),
    router,
  },
});

export const { bootstrap } = vueLifecycles;
export const mount = (props) => {
  console.log('🔐 Auth App mounted');
  return vueLifecycles.mount(props);
};
export const unmount = (props) => {
  console.log('🔐 Auth App unmounted');
  return vueLifecycles.unmount(props);
};
