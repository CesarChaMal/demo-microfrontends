# single-spa-vanilla-app

<img src="https://single-spa.js.org/img/logo-white-bgblue.svg" width="50" height="50">

[![npm version](https://img.shields.io/npm/v/@cesarchamal/single-spa-vanilla-app.svg?style=flat-square)](https://www.npmjs.com/package/@cesarchamal/single-spa-vanilla-app)

> **Part of [Demo Microfrontends](https://github.com/cesarchamal/demo-microfrontends)** - A comprehensive Single-SPA microfrontend architecture demonstration

A modern Vanilla JavaScript ES Module microfrontend for Single-SPA demonstrating native web standards and modern JavaScript features.

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
| **🍦 Vanilla App** | **ES2020+** | **4207** | **/vanilla/*** | **This repo** |
| 🧩 Web Components | Lit | 4208 | /webcomponents/* | [single-spa-webcomponents-app](https://github.com/cesarchamal/single-spa-webcomponents-app) |
| 📘 TypeScript App | TypeScript | 4209 | /typescript/* | [single-spa-typescript-app](https://github.com/cesarchamal/single-spa-typescript-app) |
| 💎 jQuery App | jQuery 3.6 | 4210 | /jquery/* | [single-spa-jquery-app](https://github.com/cesarchamal/single-spa-jquery-app) |
| 🔥 Svelte App | Svelte 3 | 4211 | /svelte/* | [single-spa-svelte-app](https://github.com/cesarchamal/single-spa-svelte-app) |

**Main Repository**: [demo-microfrontends](https://github.com/cesarchamal/demo-microfrontends)

## Features

- **Pure JavaScript**: No framework dependencies, uses native ES2020+ features
- **Modern APIs**: Fetch API, Async/Await, Template Literals, Arrow Functions
- **Interactive Demo**: Counter functionality and data fetching examples
- **Single-SPA Integration**: Standard lifecycle functions (bootstrap, mount, unmount)
- **ES Modules**: Native module system with clean imports/exports

## Technology Stack

- **Language**: Vanilla JavaScript (ES2020+)
- **Build Tool**: Webpack 4
- **Module System**: ES Modules
- **APIs**: Fetch API, DOM API, Promise API
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
# Runs on http://localhost:4207
```

### Build

```bash
npm run build
# Outputs to dist/single-spa-vanilla-app.js
```

## Single-SPA Integration

This microfrontend exports the required Single-SPA lifecycle functions:

```javascript
export const bootstrap = () => Promise.resolve();
export const mount = (props) => vanillaApp.mount(props);
export const unmount = () => vanillaApp.unmount();
```

### Mount Point

The application mounts to the DOM element with ID `vanilla-app`:

```html
<div id="vanilla-app"></div>
```

### Route Configuration

Configured to activate on routes starting with `/vanilla`:

```javascript
singleSpa.registerApplication(
  'vanilla',
  () => loadApp('single-spa-vanilla-app'),
  showWhenPrefix(['/vanilla'])
);
```

## Features Demonstrated

### Modern JavaScript
- ES2020+ syntax (classes, arrow functions, destructuring)
- Template literals for dynamic HTML
- Async/await for asynchronous operations
- Native Promise handling

### Web APIs
- **Fetch API**: Modern HTTP client for data fetching
- **DOM API**: Direct DOM manipulation without frameworks
- **Event Handling**: Native event listeners and delegation
- **Local Storage**: Browser storage capabilities

### Interactive Elements
- **Counter**: Demonstrates state management in vanilla JS
- **Data Fetching**: Shows async operations with loading states
- **Error Handling**: Proper error boundaries and user feedback

## File Structure

```
single-spa-vanilla-app/
├── src/
│   └── single-spa-vanilla-app.js    # Main application entry point
├── dist/                            # Build output directory
├── package.json                     # Dependencies and scripts
├── webpack.config.js                # Build configuration
├── .gitignore                       # Git ignore rules
└── README.md                        # This file
```

## Build Configuration

Uses Webpack 4 with UMD output for Single-SPA compatibility:

```javascript
module.exports = {
  entry: './src/single-spa-vanilla-app.js',
  output: {
    filename: 'single-spa-vanilla-app.js',
    library: 'single-spa-vanilla-app',
    libraryTarget: 'umd'
  }
};
```

## Browser Support

- Modern browsers supporting ES2020+
- Chrome 80+, Firefox 72+, Safari 13.1+, Edge 80+
- Requires native ES Module support

## Performance

- **Bundle Size**: ~5KB (minified)
- **Dependencies**: Zero runtime dependencies
- **Load Time**: Fast initial load due to minimal overhead
- **Memory**: Low memory footprint

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test the integration with Single-SPA
5. Submit a pull request

## License

MIT License - see LICENSE file for details.

## Related Projects

- [single-spa](https://single-spa.js.org/) - Microfrontend framework
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
# Visit http://localhost:4207
```

## Author

Cesar Francisco Chavez Maldonado - Vanilla JavaScript Microfrontend Example