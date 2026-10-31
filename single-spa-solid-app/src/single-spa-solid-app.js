import { render } from 'solid-js/web';
import App from './App';

// SolidJS needs no single-spa adapter: solid-js/web render() returns a
// dispose function that tears the whole component tree down cleanly.
let dispose = null;

export const bootstrap = () => Promise.resolve();

export const mount = () => new Promise((resolve) => {
  const el = document.getElementById('solid-app');
  if (!el) {
    console.error('Mount point #solid-app not found');
    return resolve();
  }
  dispose = render(() => <App />, el);
  console.log('🔶 Solid App mounted');
  resolve();
});

export const unmount = () => new Promise((resolve) => {
  if (dispose) {
    dispose();
    dispose = null;
  }
  console.log('🔶 Solid App unmounted');
  resolve();
});

export default {
  bootstrap,
  mount,
  unmount
};
