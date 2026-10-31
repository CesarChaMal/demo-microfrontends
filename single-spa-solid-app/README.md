# single-spa-solid-app

<img src="https://single-spa.js.org/img/logo-white-bgblue.svg" width="50" height="50">

[![npm version](https://img.shields.io/npm/v/@cesarchamal/single-spa-solid-app.svg?style=flat-square)](https://www.npmjs.com/package/@cesarchamal/single-spa-solid-app)

> **Part of [Demo Microfrontends](https://github.com/cesarchamal/demo-microfrontends)** - A comprehensive Single-SPA microfrontend architecture demonstration

A SolidJS microfrontend for Single-SPA demonstrating fine-grained reactivity with signals, no virtual DOM, and a hand-rolled single-spa lifecycle (no adapter library needed).

## 🏗️ Microfrontend Architecture

This application is one of **13 microfrontends** in the demo-microfrontends project:

| Microfrontend | Framework | Port | Route | Repository |
|---------------|-----------|------|-------|------------|
| 🎯 Root App | Single-SPA | 8080 | Orchestrator | [single-spa-root](https://github.com/cesarchamal/single-spa-root) |
| 🔐 Auth App | Vue.js | 4201 | /login | [single-spa-auth-app](https://github.com/cesarchamal/single-spa-auth-app) |
| 🎨 Layout App | Vue.js | 4202 | All routes | [single-spa-layout-app](https://github.com/cesarchamal/single-spa-layout-app) |
| 🏠 Home App | AngularJS | 4203 | / | [single-spa-home-app](https://github.com/cesarchamal/single-spa-home-app) |
| 🅰️ Angular App | Angular 8 | 4204 | /angular/* | [single-spa-angular-app](https://github.com/cesarchamal/single-spa-angular-app) |
| 💚 Vue App | Vue.js 2 | 4205 | /vue/* | [single-spa-vue-app](https://github.com/cesarchamal/single-spa-vue-app) |
| ⚛️ React App | React 16 | 4206 | /react/* | [single-spa-react-app](https://github.com/cesarchamal/single-spa-react-app) |
| 🍦 Vanilla App | ES2020+ | 4207 | /vanilla/* | [single-spa-vanilla-app](https://github.com/cesarchamal/single-spa-vanilla-app) |
| 🧩 Web Components | Lit | 4208 | /webcomponents/* | [single-spa-webcomponents-app](https://github.com/cesarchamal/single-spa-webcomponents-app) |
| 📘 TypeScript App | TypeScript | 4209 | /typescript/* | [single-spa-typescript-app](https://github.com/cesarchamal/single-spa-typescript-app) |
| 💎 jQuery App | jQuery 3.6 | 4210 | /jquery/* | [single-spa-jquery-app](https://github.com/cesarchamal/single-spa-jquery-app) |
| 🔥 Svelte App | Svelte 3 | 4211 | /svelte/* | [single-spa-svelte-app](https://github.com/cesarchamal/single-spa-svelte-app) |
| **🔶 Solid App** | **SolidJS 1.x** | **4212** | **/solid/*** | **This repo** |

**Main Repository**: [demo-microfrontends](https://github.com/cesarchamal/demo-microfrontends)

## Features

- **SolidJS 1.x**: Fine-grained reactive framework
- **Signals**: `createSignal` / `createMemo` for automatic dependency tracking
- **No Virtual DOM**: Compiled direct DOM updates
- **JSX Without React**: `babel-preset-solid` compiles JSX to real DOM operations
- **Shared State**: Subscribes to the root `window.stateManager` observables

## Technology Stack

- **Framework**: solid-js 1.9.x
- **Build Tool**: Webpack 4 + babel-loader (`babel-preset-solid` + `@babel/preset-env`)
- **Language**: JavaScript with Solid JSX (`.jsx`)
- **Integration**: Hand-rolled Single-SPA lifecycle (`render()` / `dispose()`)

## Development

### Prerequisites

- Node.js (v18.0.0 or higher)
- npm (v8.0.0 or higher)

### Installation

```bash
npm install
```

### Development Server

```bash
npm start
# Runs on http://localhost:4212
```

### Build

```bash
npm run build
# Outputs to dist/single-spa-solid-app.js
```

## SolidJS Features Demonstrated

### Signals
```jsx
const [count, setCount] = createSignal(0);
const double = createMemo(() => count() * 2);  // auto-recalculated
```

### Fine-grained Rendering
```jsx
<button onClick={() => setCount(c => c + 1)}>Count: {count()}</button>
```

### List Rendering with Keys
```jsx
<For each={employees()}>{(emp) => <li>{emp.name}</li>}</For>
```

### Conditional Rendering
```jsx
<Show when={user()} fallback={<span>Not logged in</span>}>
  {(u) => <span>Hello {u().name}</span>}
</Show>
```

## Single-SPA Integration

This microfrontend exports the required Single-SPA lifecycle functions with a
direct `render()` / `dispose()` pair — no adapter library:

```javascript
import { render } from 'solid-js/web';
import App from './App';

let dispose = null;

export const bootstrap = () => Promise.resolve();
export const mount = () => new Promise((resolve) => {
  const el = document.getElementById('solid-app');
  dispose = render(() => <App />, el);
  resolve();
});
export const unmount = () => new Promise((resolve) => {
  if (dispose) { dispose(); dispose = null; }
  resolve();
});
```

### Mount Point

The application mounts to the DOM element with ID `solid-app`:

```html
<div id="solid-app"></div>
```

### Route Configuration

Configured to activate (when authenticated) on routes starting with `/solid`:

```javascript
singleSpa.registerApplication(
  'solid',
  () => loadApp('single-spa-solid-app'),
  showWhenAuthenticatedAndPrefix(['/solid'])
);
```

## Webpack 4 Compatibility Notes

solid-js ships an `exports` map and optional-chaining syntax that webpack 4
cannot handle. Two config tweaks are required (already applied here):

1. **`resolve.alias`** pins `solid-js` and `solid-js/web` to their browser
   dists — webpack 4 ignores `exports` and otherwise resolves the SERVER build.
2. **`module.rules[].exclude`** uses a negative lookahead
   (`node_modules\/(?!(solid-js)\/)`) so babel-loader also transpiles the
   solid-js dists, whose optional chaining webpack 4's parser cannot read.

See `ADDING_A_MICROFRONTEND.md` in the main repository for the full write-up.

## File Structure

```
single-spa-solid-app/
├── src/
│   ├── App.jsx                           # Main Solid component
│   └── single-spa-solid-app.js           # Single-SPA lifecycle
├── dist/                                 # Build output directory
├── package.json                          # Dependencies and scripts
├── webpack.config.js                     # Build configuration
└── README.md                             # This file
```

## 🚀 Quick Start

**Run the complete microfrontend system:**
```bash
# Clone main repository
git clone https://github.com/cesarchamal/demo-microfrontends.git
cd demo-microfrontends

# Start all microfrontends
./run.sh local dev
```

**Run this microfrontend individually:**
```bash
npm install
npm start
# Visit http://localhost:4212
```

## Author

Cesar Francisco Chavez Maldonado - SolidJS Microfrontend Example
