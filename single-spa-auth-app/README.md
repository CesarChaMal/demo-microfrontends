# single-spa-auth-app

> **Part of [Demo Microfrontends](https://github.com/cesarchamal/demo-microfrontends)** - A comprehensive Single-SPA microfrontend architecture demonstration

A Vue.js authentication microfrontend for Single-SPA providing centralized login functionality and user authentication management.

## 🏗️ Microfrontend Architecture

This application is one of **12 microfrontends** in the demo-microfrontends project:

| Microfrontend | Framework | Port | Route | Repository |
|---------------|-----------|------|-------|------------|
| **🔐 Auth App** | **Vue.js** | **4201** | **/login** | **This repo** |
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
| 🎯 Root App | Single-SPA | 8080 | Orchestrator | [single-spa-root](https://github.com/cesarchamal/single-spa-root) |

**Main Repository**: [demo-microfrontends](https://github.com/cesarchamal/demo-microfrontends)

## Features

- **Vue.js 2**: Progressive JavaScript framework
- **Authentication Flow**: Complete login/logout functionality
- **Bootstrap Vue**: UI components and styling
- **FontAwesome Icons**: Icon library integration
- **Vue Router**: Client-side routing with history mode
- **Toast Notifications**: User feedback system

## Technology Stack

- **Framework**: Vue.js 2.6.11
- **UI Library**: Bootstrap Vue 2.2.2
- **Build Tool**: Vue CLI 4 with library target
- **Icons**: FontAwesome with Vue integration
- **Integration**: Single-SPA Vue adapter

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
# Runs on http://localhost:4201
```

### Build

```bash
npm run build
# Outputs to dist/single-spa-auth-app.umd.js
```

## Authentication Features

### Login Form
- Username/email input validation
- Password field with visibility toggle
- Remember me functionality
- Form validation and error handling

### User Management
- Login state management
- Session persistence
- Logout functionality
- User profile integration

### Security Features
- Input sanitization
- CSRF protection ready
- Secure session handling
- Authentication token management

## Single-SPA Integration

This microfrontend exports the required Single-SPA lifecycle functions:

```javascript
export const bootstrap = vueLifecycles.bootstrap;
export const mount = vueLifecycles.mount;
export const unmount = vueLifecycles.unmount;
```

### Mount Point

The application mounts to the DOM element with ID `auth-app`:

```html
<div id="auth-app"></div>
```

### Route Configuration

Configured to activate on the `/login` route:

```javascript
singleSpa.registerApplication(
  'login',
  () => loadApp('single-spa-auth-app'),
  showWhenAnyOf(['/login'])
);
```

### Router Configuration

```javascript
export default new Router({
  mode: 'history',
  base: '/login',
  routes: [
    {
      path: '/',
      component: () => import('@/views/Login'),
    }
  ]
});
```

## Vue Configuration

### External Dependencies
The application uses webpack externals for shared dependencies:

```javascript
config.externals([
  'vue',
  'vue-router',
  'bootstrap-vue',
  'single-spa-vue',
  '@fortawesome/fontawesome-svg-core'
]);
```

### Library Build
Built as UMD library for Single-SPA consumption:

```javascript
configureWebpack: {
  output: {
    library: 'single-spa-auth-app',
    libraryTarget: 'umd',
    filename: 'single-spa-auth-app.js'
  }
}
```

## Authentication Flow

### Login Process
1. User enters credentials
2. Form validation
3. Authentication request
4. Token storage
5. Redirect to main application

### Session Management
- JWT token handling
- Automatic token refresh
- Session expiration detection
- Secure logout process

## UI Components

### Login Form
- Responsive design
- Bootstrap Vue components
- Form validation
- Loading states
- Error messaging

### Styling
- Bootstrap 4 integration
- Custom SCSS styles
- Responsive layout
- Accessibility compliant

## File Structure

```
single-spa-auth-app/
├── src/
│   ├── components/           # Vue components
│   ├── views/               # Page components
│   │   └── Login.vue        # Main login view
│   ├── router/              # Vue Router configuration
│   │   └── index.js         # Router setup
│   ├── App.vue              # Root component
│   └── singleSpaEntry.js    # Single-SPA integration
├── dist/                    # Build output directory
├── package.json             # Dependencies and scripts
├── vue.config.js           # Vue CLI configuration
├── .gitignore              # Git ignore rules
└── README.md               # This file
```

## Configuration

### Vue CLI Configuration (vue.config.js)
```javascript
module.exports = {
  configureWebpack: {
    output: {
      library: 'single-spa-auth-app',
      libraryTarget: 'umd'
    },
    plugins: [
      new webpack.optimize.LimitChunkCountPlugin({
        maxChunks: 1
      })
    ]
  }
};
```

### ESLint Configuration
- Airbnb base configuration
- Vue.js specific rules
- Import/export validation
- Code quality enforcement

## Performance

- **Bundle Size**: ~800KB (UMD build)
- **Load Time**: Fast with external dependencies
- **Runtime**: Vue.js reactive updates
- **Memory**: Efficient component lifecycle

## Browser Support

- Modern browsers (ES2015+)
- IE11+ with polyfills
- Mobile browsers
- Progressive enhancement

## Testing

### Unit Tests
```bash
npm run test:unit
```

### E2E Tests
```bash
npm run test:e2e
```

### Linting
```bash
npm run lint
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Follow Vue.js best practices
4. Add tests for new features
5. Ensure authentication security
6. Submit a pull request

## License

MIT License - see LICENSE file for details.

## Related Projects

- [Vue.js](https://vuejs.org/) - Progressive JavaScript framework
- [Bootstrap Vue](https://bootstrap-vue.org/) - Vue.js Bootstrap components
- [Single-SPA](https://single-spa.js.org/) - Microfrontend framework
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
# Visit http://localhost:4201
```

## Author

Cesar Francisco Chavez Maldonado - Vue.js Authentication Microfrontend