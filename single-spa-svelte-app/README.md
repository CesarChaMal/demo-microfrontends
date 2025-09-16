# single-spa-svelte-app

<img src="https://single-spa.js.org/img/logo-white-bgblue.svg" width="50" height="50">

[![npm version](https://img.shields.io/npm/v/@cesarchamal/single-spa-svelte-app.svg?style=flat-square)](https://www.npmjs.com/package/@cesarchamal/single-spa-svelte-app)

> **Part of [Demo Microfrontends](https://github.com/cesarchamal/demo-microfrontends)** - A comprehensive Single-SPA microfrontend architecture demonstration

A Svelte microfrontend for Single-SPA demonstrating compile-time optimization, reactive programming, and minimal runtime overhead.

## 🏗️ Microfrontend Architecture

This application is one of **12 microfrontends** in the demo-microfrontends project:

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
| **🔥 Svelte App** | **Svelte 3** | **4211** | **/svelte/*** | **This repo** |

**Main Repository**: [demo-microfrontends](https://github.com/cesarchamal/demo-microfrontends)

## Features

- **Svelte 3**: Compile-time optimized framework
- **Reactive Programming**: Automatic UI updates with reactive statements
- **No Virtual DOM**: Direct DOM manipulation for better performance
- **Small Bundle Size**: Minimal runtime overhead (~10KB)
- **Built-in State Management**: No external state libraries needed

## Technology Stack

- **Framework**: Svelte 3.59.2
- **Build Tool**: Webpack 4 with svelte-loader
- **Language**: JavaScript with Svelte syntax
- **Integration**: Single-SPA lifecycle with Svelte components

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
# Runs on http://localhost:4211
```

### Build

```bash
npm run build
# Outputs to dist/single-spa-svelte-app.js
```

## Svelte Features Demonstrated

### Reactive Statements
```javascript
// Automatic recalculation when dependencies change
$: doubleCount = count * 2;
$: countMessage = count === 0 ? 'Zero' : count === 1 ? 'One' : `${count} items`;
```

### Component State
```javascript
let count = 0;
let items = [];
let loading = false;

// Reactive updates automatically trigger re-renders
```

### Event Handling
```svelte
<button on:click={increment}>+</button>
<input bind:value={name} on:keypress={(e) => e.key === 'Enter' && addItem()}>
```

### Conditional Rendering
```svelte
{#if loading}
  <div class="loading">Loading...</div>
{:else if items.length === 0}
  <div class="empty">No items yet!</div>
{:else}
  {#each items as item (item.id)}
    <div class="item">{item.name}</div>
  {/each}
{/if}
```

## Single-SPA Integration

This microfrontend exports the required Single-SPA lifecycle functions:

```javascript
export const bootstrap = () => Promise.resolve();
export const mount = (props) => svelteApp.mount(props);
export const unmount = () => svelteApp.unmount();
```

### Mount Point

The application mounts to the DOM element with ID `svelte-app`:

```html
<div id="svelte-app"></div>
```

### Route Configuration

Configured to activate on routes starting with `/svelte`:

```javascript
singleSpa.registerApplication(
  'svelte',
  () => loadApp('single-spa-svelte-app'),
  showWhenPrefix(['/svelte'])
);
```

## Svelte Advantages

### Compile-time Optimization
- No runtime framework overhead
- Optimal JavaScript output
- Tree-shaking friendly
- Small bundle sizes

### Reactive Programming
- Automatic dependency tracking
- Efficient updates
- No manual state management
- Declarative syntax

### Developer Experience
- Simple syntax
- Less boilerplate
- Built-in animations
- Great tooling

## Interactive Features

### Reactive Counter
- Increment/decrement buttons
- Automatic double calculation
- Dynamic message updates
- Reset functionality

### Dynamic Items List
- Add custom items
- Load sample data
- Toggle item states
- Remove items
- Real-time counters

### Reactive Statements
- Automatic recalculation
- Dependency tracking
- Efficient updates
- No manual subscriptions

## Performance Benefits

- **Bundle Size**: ~10KB (including Svelte runtime)
- **Runtime**: No virtual DOM overhead
- **Updates**: Surgical DOM updates
- **Memory**: Minimal memory footprint
- **Startup**: Fast initial render

## Component Architecture

### App.svelte
```svelte
<script>
  // Component logic
  let state = 'reactive';
  
  // Reactive statements
  $: derivedValue = computeFromState(state);
  
  // Event handlers
  function handleClick() {
    state = 'updated';
  }
</script>

<!-- Template -->
<div class="component">
  <button on:click={handleClick}>
    {state}
  </button>
</div>

<style>
  /* Scoped styles */
  .component {
    /* Component-specific styles */
  }
</style>
```

## File Structure

```
single-spa-svelte-app/
├── src/
│   ├── App.svelte                        # Main Svelte component
│   └── single-spa-svelte-app.js          # Single-SPA integration
├── dist/                                 # Build output directory
├── package.json                          # Dependencies and scripts
├── webpack.config.js                     # Build configuration
├── .gitignore                           # Git ignore rules
└── README.md                            # This file
```

## Svelte Concepts

### Reactivity
- Assignments trigger updates
- Reactive statements ($:)
- Reactive blocks
- Store subscriptions

### Component Communication
- Props for parent-to-child
- Events for child-to-parent
- Context for deep passing
- Stores for global state

### Lifecycle
- onMount for initialization
- onDestroy for cleanup
- beforeUpdate/afterUpdate
- tick for DOM updates

## Browser Support

- Modern browsers (ES2015+)
- Chrome 51+, Firefox 54+, Safari 10+, Edge 15+
- Polyfills available for older browsers
- Mobile browser support

## Migration from Other Frameworks

### From React
- Similar component concepts
- Less boilerplate code
- No JSX, uses templates
- Built-in state management

### From Vue
- Similar template syntax
- Reactive programming model
- Scoped styles
- Simpler setup

## Contributing

1. Fork the repository
2. Create a feature branch
3. Follow Svelte best practices
4. Test component reactivity
5. Ensure proper cleanup
6. Submit a pull request

## License

MIT License - see LICENSE file for details.

## Related Projects

- [Svelte](https://svelte.dev/) - Cybernetically enhanced web apps
- [SvelteKit](https://kit.svelte.dev/) - Full-stack Svelte framework
- [Demo Microfrontends](https://github.com/cesarchamal/demo-microfrontends) - Complete microfrontend demo

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
# Visit http://localhost:4211
```

## Author

Cesar Francisco Chavez Maldonado - Svelte Microfrontend Example