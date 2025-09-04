/* eslint-disable */
import Vue from 'vue';
import singleSpaVue from 'single-spa-vue';
import { library } from '@fortawesome/fontawesome-svg-core';
import { faGithub } from '@fortawesome/free-brands-svg-icons';
import { faHome } from '@fortawesome/free-solid-svg-icons';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';
import App from './App.vue';
import './styles/styles.scss';

library.add(faGithub);
library.add(faHome);

Vue.component('font-awesome-icon', FontAwesomeIcon);

// Temporarily disable BootstrapVue
// Vue.use(BootstrapVue);

Vue.config.productionTip = false;

const vueLifecycles = singleSpaVue({
  Vue,
  appOptions: {
    el: '#layout-app',
    render: (h) => h(App),
  },
});

export const { bootstrap } = vueLifecycles;
export const { mount } = vueLifecycles;
export const { unmount } = vueLifecycles;
