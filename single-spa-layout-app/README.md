# single-spa-layout-app

<img src="https://single-spa.js.org/img/logo-white-bgblue.svg" width="50" height="50">

[![npm version](https://img.shields.io/npm/v/@cesarchamal/single-spa-layout-app.svg?style=flat-square)](https://www.npmjs.com/package/@cesarchamal/single-spa-layout-app)

> **Part of [Demo Microfrontends](https://github.com/cesarchamal/demo-microfrontends)** - A comprehensive Single-SPA microfrontend architecture demonstration

A Vue.js layout microfrontend for Single-SPA providing shared navigation, header, and footer components across the entire application.

## 🏗️ Microfrontend Architecture

This application is one of **12 microfrontends** in the demo-microfrontends project:

| Microfrontend | Framework | Port | Route | Repository |
|---------------|-----------|------|-------|------------|
| 🎯 Root App | Single-SPA | 8080 | Orchestrator | [single-spa-root](https://github.com/cesarchamal/single-spa-root) |
| 🔐 Auth App | Vue.js | 4201 | /login | [single-spa-auth-app](https://github.com/cesarchamal/single-spa-auth-app) |
| **🎨 Layout App** | **Vue.js** | **4202** | **All routes** | **This repo** |
| 🏠 Home App | AngularJS | 4203 | / | [single-spa-home-app](https://github.com/cesarchamal/single-spa-home-app) |
| 🅰️ Angular App | Angular 8 | 4204 | /angular/* | [single-spa-angular-app](https://github.com/cesarchamal/single-spa-angular-app) |
| 💚 Vue App | Vue.js 2 | 4205 | /vue/* | [single-spa-vue-app](https://github.com/cesarchamal/single-spa-vue-app) |
| ⚛️ React App | React 16 | 4206 | /react/* | [single-spa-react-app](https://github.com/cesarchamal/single-spa-react-app) |
| 🍦 Vanilla App | ES2020+ | 4207 | /vanilla/* | [single-spa-vanilla-app](https://github.com/cesarchamal/single-spa-vanilla-app) |
| 🧩 Web Components | Lit | 4208 | /webcomponents/* | [single-spa-webcomponents-app](https://github.com/cesarchamal/single-spa-webcomponents-app) |
| 📘 TypeScript App | TypeScript | 4209 | /typescript/* | [single-spa-typescript-app](https://github.com/cesarchamal/single-spa-typescript-app) |
| 💎 jQuery App | jQuery 3.6 | 4210 | /jquery/* | [single-spa-jquery-app](https://github.com/cesarchamal/single-spa-jquery-app) |
| 🔥 Svelte App | Svelte 3 | 4211 | /svelte/* | [single-spa-svelte-app](https://github.com/cesarchamal/single-spa-svelte-app) |

**Main Repository**: [demo-microfrontends](https://github.com/cesarchamal/demo-microfrontends)

## Features

- **Shared Layout**: Common header, navigation, and footer components
- **Vue.js 2**: Progressive JavaScript framework
- **Bootstrap Vue**: Responsive UI components and grid system
- **FontAwesome Icons**: Comprehensive icon library
- **Responsive Design**: Mobile-first responsive layout
- **Navigation Management**: Dynamic menu and routing integration

## Technology Stack

- **Framework**: Vue.js 2.6.11
- **UI Library**: Bootstrap Vue 2.2.2
- **Build Tool**: Vue CLI 4 with library target
- **Styling**: SCSS with Bootstrap integration
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
# Runs on http://localhost:4202
```

### Build

```bash
npm run build
# Outputs to dist/single-spa-layout-app.umd.js
```

## Layout Components

### Header Component
- Application branding and logo
- User authentication status
- Global navigation menu
- Responsive hamburger menu

### Navigation Component
- Primary navigation menu
- Active route highlighting
- Dropdown submenus
- Mobile-responsive design

### Footer Component
- Copyright information
- Links and social media
- Contact information
- Responsive layout

### Sidebar (Optional)
- Secondary navigation
- Collapsible design
- Context-sensitive content
- Mobile drawer functionality

## Single-SPA Integration

This microfrontend exports the required Single-SPA lifecycle functions:

```javascript
export const bootstrap = vueLifecycles.bootstrap;
export const mount = vueLifecycles.mount;
export const unmount = vueLifecycles.unmount;
```

### Mount Point

The application mounts to the DOM element with ID `layout-app`:

```html
<div id="layout-app"></div>
```

### Route Configuration

Configured to be active on all routes except `/login`:

```javascript
singleSpa.registerApplication(
  'layout',
  () => loadApp('single-spa-layout-app'),
  showWhenNotAnyOf(['/login'])
);
```

### Global Layout Strategy
- Always visible except on login page
- Provides consistent user experience
- Shared navigation state
- Responsive breakpoints

## Vue Configuration

### External Dependencies
The application uses webpack externals for shared dependencies:

```javascript
config.externals([
  'vue',
  'bootstrap-vue',
  'single-spa-vue',
  '@fortawesome/fontawesome-svg-core',
  '@fortawesome/free-brands-svg-icons',
  '@fortawesome/free-solid-svg-icons'
]);
```

### Library Build
Built as UMD library for Single-SPA consumption:

```javascript
configureWebpack: {
  output: {
    library: 'single-spa-layout-app',
    libraryTarget: 'umd',
    filename: 'single-spa-layout-app.js'
  }
}
```

## Layout Features

### Responsive Design
- Mobile-first approach
- Bootstrap grid system
- Flexible breakpoints
- Touch-friendly navigation

### Navigation Management
- Dynamic menu generation
- Route-based active states
- Breadcrumb navigation
- Search functionality

### User Interface
- Consistent branding
- Accessibility compliant
- Dark/light theme support
- Loading states

### Performance
- Lazy-loaded components
- Optimized bundle size
- Efficient re-renders
- Memory management

## Styling Architecture

### SCSS Structure
```scss
// Variables and mixins
@import 'variables';
@import 'mixins';

// Bootstrap customization
@import 'bootstrap-overrides';

// Component styles
@import 'components/header';
@import 'components/navigation';
@import 'components/footer';
```

### CSS Classes
- BEM methodology
- Utility classes
- Component-scoped styles
- Responsive utilities

## File Structure

```
single-spa-layout-app/
├── src/
│   ├── components/           # Layout components
│   │   ├── Header.vue       # Header component
│   │   ├── Navigation.vue   # Navigation component
│   │   └── Footer.vue       # Footer component
│   ├── styles/              # SCSS stylesheets
│   │   ├── variables.scss   # SCSS variables
│   │   └── styles.scss      # Main styles
│   ├── App.vue              # Root layout component
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
      library: 'single-spa-layout-app',
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

### Bootstrap Integration
- Custom theme variables
- Component overrides
- Responsive utilities
- Grid system customization

## Accessibility

### WCAG Compliance
- Semantic HTML structure
- ARIA labels and roles
- Keyboard navigation
- Screen reader support

### Navigation Accessibility
- Skip links
- Focus management
- High contrast support
- Reduced motion support

## Performance Optimization

- **Bundle Size**: ~1.5MB (UMD build with styles)
- **Load Time**: Optimized with external dependencies
- **Runtime**: Efficient Vue.js updates
- **Memory**: Proper component cleanup

## Browser Support

- Modern browsers (ES2015+)
- IE11+ with polyfills
- Mobile browsers
- Progressive enhancement

## Customization

### Theming
```scss
// Override Bootstrap variables
$primary: #007bff;
$secondary: #6c757d;
$success: #28a745;

// Custom layout variables
$header-height: 60px;
$sidebar-width: 250px;
```

### Component Props
```javascript
// Navigation component props
props: {
  menuItems: Array,
  activeRoute: String,
  collapsed: Boolean
}
```

## Testing

### Unit Tests
```bash
npm run test:unit
```

### Component Tests
```bash
npm run test:components
```

### Linting
```bash
npm run lint
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Follow Vue.js and Bootstrap best practices
4. Ensure responsive design
5. Test across different screen sizes
6. Submit a pull request

## License

MIT License - see LICENSE file for details.

## Related Projects

- [Vue.js](https://vuejs.org/) - Progressive JavaScript framework
- [Bootstrap Vue](https://bootstrap-vue.org/) - Vue.js Bootstrap components
- [FontAwesome](https://fontawesome.com/) - Icon library
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
# Visit http://localhost:4202
```

## Author

Cesar Francisco Chavez Maldonado - Vue.js Layout Microfrontend