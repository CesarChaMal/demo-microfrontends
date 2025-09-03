# single-spa-home-app

An AngularJS 1.x microfrontend for Single-SPA serving as the main landing page and demonstrating legacy framework integration strategies.

## Features

- **AngularJS 1.8**: Legacy Angular framework (1.x)
- **UI Router**: Client-side routing with state management
- **Component Architecture**: Modular component-based design
- **Legacy Integration**: Shows migration path from AngularJS to modern frameworks
- **Home Dashboard**: Landing page with application overview

## Technology Stack

- **Framework**: AngularJS 1.8.0
- **Router**: Angular UI Router 1.0.25
- **Build Tool**: Webpack 4 with custom configuration
- **Language**: JavaScript (ES5+ compatible)
- **Integration**: Single-SPA AngularJS adapter

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
# Runs on http://localhost:4203
```

### Build

```bash
npm run build
# Outputs to dist/single-spa-home-app.js
```

## AngularJS Features

### Component Architecture
```javascript
// Home component definition
angular.module('home-app')
  .component('homeComponent', {
    template: homeTemplate,
    controller: HomeController,
    controllerAs: 'vm'
  });
```

### UI Router Configuration
```javascript
$stateProvider.state('home', {
  url: '/',
  template: '<home-component />',
});

$locationProvider.html5Mode({
  enabled: true,
  requireBase: false
});
```

### Module System
- Modular application structure
- Dependency injection
- Service layer architecture
- Component lifecycle management

## Single-SPA Integration

This microfrontend exports the required Single-SPA lifecycle functions:

```javascript
export const bootstrap = ngLifecycles.bootstrap;
export const mount = ngLifecycles.mount;
export const unmount = ngLifecycles.unmount;
```

### Mount Point

The application mounts to the DOM element with ID `home-app`:

```html
<div id="home-app"></div>
```

### Route Configuration

Configured to activate on the root route `/`:

```javascript
singleSpa.registerApplication(
  'home',
  () => loadApp('single-spa-home-app'),
  showWhenAnyOf(['/'])
);
```

### AngularJS Adapter Configuration
```javascript
const ngLifecycles = singleSpaAngularJS({
  angular,
  domElementGetter: () => document.getElementById('home-app'),
  mainAngularModule: 'home-app',
  uiRouter: true,
  preserveGlobal: false,
  template: appTemplate
});
```

## Legacy Framework Benefits

### Migration Strategy
- Gradual modernization approach
- Coexistence with modern frameworks
- Preserve existing functionality
- Reduce migration risk

### Team Familiarity
- Existing AngularJS knowledge
- Minimal learning curve
- Proven patterns and practices
- Established ecosystem

### Incremental Updates
- Component-by-component replacement
- Maintain business continuity
- Test-driven migration
- Risk mitigation

## Home Page Features

### Dashboard Components
- Application overview
- Quick navigation links
- Recent activity feed
- System status indicators

### User Interface
- Responsive design
- Bootstrap integration
- Accessible components
- Mobile-friendly layout

### Data Integration
- Service layer architecture
- HTTP client integration
- State management
- Error handling

## Component Structure

### Home Component
```javascript
function HomeController($scope, $http) {
  const vm = this;
  
  vm.$onInit = function() {
    // Component initialization
    vm.loadDashboardData();
  };
  
  vm.loadDashboardData = function() {
    // Load dashboard content
  };
}
```

### Service Layer
```javascript
angular.module('home-app')
  .service('HomeService', function($http) {
    this.getDashboardData = function() {
      return $http.get('/api/dashboard');
    };
  });
```

## File Structure

```
single-spa-home-app/
├── src/
│   ├── components/           # AngularJS components
│   │   └── home.component.js # Main home component
│   ├── services/            # Application services
│   ├── app.module.js        # Main module definition
│   ├── routes.js            # UI Router configuration
│   ├── app.component.html   # Root template
│   └── singleSpaEntry.js    # Single-SPA integration
├── dist/                    # Build output directory
├── package.json             # Dependencies and scripts
├── webpack.config.js        # Webpack configuration
├── .gitignore              # Git ignore rules
└── README.md               # This file
```

## Webpack Configuration

### Library Build
```javascript
module.exports = {
  entry: ['src/singleSpaEntry.js'],
  output: {
    library: 'single-spa-home-app',
    libraryTarget: 'umd',
    filename: 'single-spa-home-app.js'
  },
  plugins: [
    new webpack.optimize.LimitChunkCountPlugin({
      maxChunks: 1
    })
  ]
};
```

### Module Rules
- Babel transpilation for modern JavaScript
- ESLint integration for code quality
- HTML template loading
- Source map generation

## Legacy Integration Patterns

### Dependency Management
- Self-contained dependencies
- No external requirements
- Isolated module system
- Clean separation of concerns

### State Management
- AngularJS services
- Scope-based data binding
- Event system integration
- Cross-component communication

### Performance Optimization
- Lazy loading strategies
- Efficient digest cycles
- Memory leak prevention
- Proper cleanup on unmount

## Migration Considerations

### Modernization Path
1. **Wrap in Single-SPA**: Current state
2. **Component Isolation**: Extract reusable parts
3. **Service Modernization**: Update data layer
4. **Gradual Replacement**: Replace with modern components
5. **Complete Migration**: Remove AngularJS dependency

### Compatibility
- Works alongside modern frameworks
- Shared routing integration
- Common authentication
- Consistent user experience

## Performance

- **Bundle Size**: ~300KB (including AngularJS)
- **Load Time**: Fast with efficient bundling
- **Runtime**: AngularJS digest cycle optimization
- **Memory**: Proper cleanup and garbage collection

## Browser Support

- Modern browsers (ES5+)
- IE9+ compatibility
- Mobile browsers
- Legacy system support

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
3. Follow AngularJS best practices
4. Maintain backward compatibility
5. Test migration scenarios
6. Submit a pull request

## License

MIT License - see LICENSE file for details.

## Related Projects

- [AngularJS](https://angularjs.org/) - Superheroic JavaScript MVW Framework
- [UI Router](https://ui-router.github.io/ng1/) - State-based routing for AngularJS
- [Single-SPA](https://single-spa.js.org/) - Microfrontend framework
- [Demo Microfrontends](../README.md) - Complete microfrontend demo

## Author

Demo Team - AngularJS Legacy Integration Example