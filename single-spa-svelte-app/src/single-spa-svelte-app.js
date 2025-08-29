import App from './App.svelte';

// Svelte Microfrontend Integration
class SvelteApp {
  constructor() {
    this.container = null;
    this.svelteApp = null;
  }

  mount(props) {
    return new Promise((resolve) => {
      this.container = document.getElementById('svelte-app');
      if (!this.container) {
        console.error('Mount point #svelte-app not found');
        return resolve();
      }

      // Create Svelte app instance
      this.svelteApp = new App({
        target: this.container,
        props: props || {}
      });

      console.log('🔥 Svelte App mounted');
      resolve();
    });
  }

  unmount() {
    return new Promise((resolve) => {
      if (this.svelteApp) {
        this.svelteApp.$destroy();
        this.svelteApp = null;
      }
      console.log('🔥 Svelte App unmounted');
      resolve();
    });
  }
}

// Single-SPA Lifecycle Functions
const svelteApp = new SvelteApp();

export const bootstrap = () => Promise.resolve();
export const mount = (props) => svelteApp.mount(props);
export const unmount = () => svelteApp.unmount();

export default {
  bootstrap,
  mount,
  unmount
};