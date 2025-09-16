# single-spa-webcomponents-app

<img src="https://single-spa.js.org/img/logo-white-bgblue.svg" width="50" height="50">

[![npm version](https://img.shields.io/npm/v/@cesarchamal/single-spa-webcomponents-app.svg?style=flat-square)](https://www.npmjs.com/package/@cesarchamal/single-spa-webcomponents-app)

> **Part of [Demo Microfrontends](https://github.com/cesarchamal/demo-microfrontends)** - A comprehensive Single-SPA microfrontend architecture demonstration

A Web Components microfrontend using Lit for Single-SPA, demonstrating browser-native standards and component encapsulation.

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
| **🧩 Web Components** | **Lit** | **4208** | **/webcomponents/*** | **This repo** |
| 📘 TypeScript App | TypeScript | 4209 | /typescript/* | [single-spa-typescript-app](https://github.com/cesarchamal/single-spa-typescript-app) |
| 💎 jQuery App | jQuery 3.6 | 4210 | /jquery/* | [single-spa-jquery-app](https://github.com/cesarchamal/single-spa-jquery-app) |
| 🔥 Svelte App | Svelte 3 | 4211 | /svelte/* | [single-spa-svelte-app](https://github.com/cesarchamal/single-spa-svelte-app) |

**Main Repository**: [demo-microfrontends](https://github.com/cesarchamal/demo-microfrontends)

## Features

- **Lit Framework**: Modern Web Components library with reactive properties
- **Shadow DOM**: Complete style and markup encapsulation
- **Custom Elements**: Browser-native component registration
- **Framework Agnostic**: Works with any framework or vanilla JavaScript
- **Reusable Components**: Can be used across different applications

## Technology Stack

- **Framework**: Lit 2.8.0
- **Standards**: Web Components (Custom Elements, Shadow DOM)
- **Build Tool**: Webpack 4
- **Language**: Modern JavaScript (ES2020+)
- **Integration**: Single-SPA lifecycle

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
# Runs on http://localhost:4208
```

### Build

```bash
npm run build
# Outputs to dist/single-spa-webcomponents-app.js
```

## Web Components Features

### Custom Elements
- Registered as `<micro-widget>` custom element
- Can be used in any HTML context
- Lifecycle callbacks (connectedCallback, disconnectedCallback)

### Shadow DOM Encapsulation
- Scoped CSS styles that don't leak
- Isolated DOM tree
- Protected from external style interference

### Reactive Properties
- Lit reactive properties with automatic re-rendering
- Type-safe property definitions
- Efficient change detection

## Single-SPA Integration

This microfrontend exports the required Single-SPA lifecycle functions:

```javascript
export const bootstrap = () => Promise.resolve();
export const mount = (props) => webComponentsApp.mount(props);
export const unmount = () => webComponentsApp.unmount();
```

### Mount Point

The application mounts to the DOM element with ID `webcomponents-app`:

```html
<div id="webcomponents-app"></div>
```

### Route Configuration

Configured to activate on routes starting with `/webcomponents`:

```javascript
singleSpa.registerApplication(
  'webcomponents',
  () => loadApp('single-spa-webcomponents-app'),
  showWhenPrefix(['/webcomponents'])
);
```

## Component Usage

The Web Component can be used independently:

```html
<!-- Direct usage in HTML -->
<micro-widget></micro-widget>

<!-- Programmatic creation -->
<script>
  const widget = document.createElement('micro-widget');
  document.body.appendChild(widget);
</script>
```

## Browser Support

- Chrome 54+, Firefox 63+, Safari 10.1+, Edge 79+
- Requires native Custom Elements and Shadow DOM support
- Polyfills available for older browsers

## Performance

- **Bundle Size**: ~15KB (including Lit)
- **Runtime**: Efficient reactive updates
- **Memory**: Low overhead with native APIs
- **Encapsulation**: No style conflicts

## File Structure

```
single-spa-webcomponents-app/
├── src/
│   └── single-spa-webcomponents-app.js    # Main application entry
├── dist/                                   # Build output directory
├── package.json                           # Dependencies and scripts
├── webpack.config.js                      # Build configuration
├── .gitignore                            # Git ignore rules
└── README.md                             # This file
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test the Web Component integration
5. Submit a pull request

## License

MIT License - see LICENSE file for details.

## Related Projects

- [Lit](https://lit.dev/) - Simple. Fast. Web Components.
- [Web Components](https://developer.mozilla.org/en-US/docs/Web/Web_Components) - MDN Documentation
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
# Visit http://localhost:4208
```

## Author

Cesar Francisco Chavez Maldonado - Web Components Microfrontend Example