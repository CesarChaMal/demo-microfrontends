# single-spa-angular-app

> **Part of [Demo Microfrontends](https://github.com/cesarchamal/demo-microfrontends)** - A comprehensive Single-SPA microfrontend architecture demonstration

An Angular 8 microfrontend for Single-SPA demonstrating modern Angular features, TypeScript integration, and enterprise-grade development patterns.

## 🏗️ Microfrontend Architecture

This application is one of **12 microfrontends** in the demo-microfrontends project:

| Microfrontend | Framework | Port | Route | Repository |
|---------------|-----------|------|-------|------------|
| 🔐 Auth App | Vue.js | 4201 | /login | [single-spa-auth-app](https://github.com/cesarchamal/single-spa-auth-app) |
| 🎨 Layout App | Vue.js | 4202 | All routes | [single-spa-layout-app](https://github.com/cesarchamal/single-spa-layout-app) |
| 🏠 Home App | AngularJS | 4203 | / | [single-spa-home-app](https://github.com/cesarchamal/single-spa-home-app) |
| **🅰️ Angular App** | **Angular 8** | **4204** | **/angular/*** | **This repo** |
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

- **Angular 8**: Modern Angular framework with Ivy renderer
- **TypeScript**: Strong typing and compile-time error detection
- **Angular CLI**: Standard tooling and build optimization
- **RxJS**: Reactive programming with observables
- **Angular Router**: Advanced routing with lazy loading
- **Dependency Injection**: Hierarchical injector system

## Technology Stack

- **Framework**: Angular 8.2.14
- **Language**: TypeScript 3.5.3
- **Build Tool**: Angular CLI 8.3.23 with custom webpack
- **State Management**: Angular services with RxJS
- **Integration**: Single-SPA Angular adapter

## Development

### Prerequisites

- Node.js (v18.0.0 or higher)
- npm (v8.0.0 or higher)
- Angular CLI 8.x

### Installation

```bash
npm install
```

### Development Server

```bash
npm start
# Runs on http://localhost:4204
```

### Build

```bash
npm run build:single-spa
# Outputs to dist/single-spa-angular-app.js
```

## Angular Features

### Component Architecture
```typescript
@Component({
  selector: 'app-feature',
  templateUrl: './feature.component.html',
  styleUrls: ['./feature.component.scss']
})
export class FeatureComponent implements OnInit {
  constructor(private service: FeatureService) {}
  
  ngOnInit(): void {
    this.loadData();
  }
}
```

### Service Layer
```typescript
@Injectable({
  providedIn: 'root'
})
export class FeatureService {
  constructor(private http: HttpClient) {}
  
  getData(): Observable<any> {
    return this.http.get('/api/data');
  }
}
```

### Routing Configuration
```typescript
const routes: Routes = [
  { path: '', component: HomeComponent },
  { path: 'feature', loadChildren: () => import('./feature/feature.module').then(m => m.FeatureModule) }
];
```

## Single-SPA Integration

This microfrontend exports the required Single-SPA lifecycle functions:

```typescript
export const bootstrap = singleSpaAngular.bootstrap;
export const mount = singleSpaAngular.mount;
export const unmount = singleSpaAngular.unmount;
```

### Mount Point

The application mounts to the DOM element with ID `angular-app`:

```html
<div id="angular-app"></div>
```

### Route Configuration

Configured to activate on routes starting with `/angular`:

```javascript
singleSpa.registerApplication(
  'angular',
  () => loadApp('single-spa-angular-app'),
  showWhenPrefix(['/angular'])
);
```

### Angular Configuration
```typescript
// main.single-spa.ts
import { enableProdMode, NgZone } from '@angular/core';
import { platformBrowserDynamic } from '@angular/platform-browser-dynamic';
import { Router } from '@angular/router';
import singleSpaAngular from 'single-spa-angular';

import { AppModule } from './app/app.module';

const lifecycles = singleSpaAngular({
  bootstrapFunction: singleSpaProps => {
    return platformBrowserDynamic().bootstrapModule(AppModule);
  },
  template: '<app-root />',
  Router,
  NgZone
});

export const bootstrap = lifecycles.bootstrap;
export const mount = lifecycles.mount;
export const unmount = lifecycles.unmount;
```

## Angular 8 Features

### Ivy Renderer
- Improved bundle sizes
- Better tree-shaking
- Enhanced debugging
- Faster builds

### Differential Loading
- Modern JS for modern browsers
- Legacy JS for older browsers
- Automatic polyfill management
- Optimized bundle delivery

### Dynamic Imports
- Lazy loading modules
- Code splitting
- Reduced initial bundle size
- On-demand loading

### Web Workers
- Background processing
- Non-blocking operations
- Performance optimization
- CPU-intensive tasks

## TypeScript Integration

### Strict Type Checking
```typescript
interface User {
  id: number;
  name: string;
  email: string;
  roles: UserRole[];
}

class UserService {
  getUsers(): Observable<User[]> {
    return this.http.get<User[]>('/api/users');
  }
}
```

### Decorators and Metadata
- Component decorators
- Service injection
- Route guards
- Pipe transformations

## File Structure

```
single-spa-angular-app/
├── src/
│   ├── app/
│   │   ├── components/       # Angular components
│   │   ├── services/         # Injectable services
│   │   ├── guards/          # Route guards
│   │   ├── pipes/           # Custom pipes
│   │   ├── app.module.ts    # Root module
│   │   └── app.component.ts # Root component
│   ├── environments/        # Environment configurations
│   ├── main.single-spa.ts   # Single-SPA entry point
│   └── polyfills.ts        # Browser polyfills
├── dist/                   # Build output directory
├── angular.json            # Angular CLI configuration
├── tsconfig.json          # TypeScript configuration
├── extra-webpack.config.js # Custom webpack config
├── package.json           # Dependencies and scripts
└── README.md              # This file
```

## Custom Webpack Configuration

### Single-SPA Integration
```javascript
const singleSpaAngularWebpack = require('single-spa-angular/lib/webpack').default;

module.exports = (angularWebpackConfig, options) => {
  const singleSpaWebpackConfig = singleSpaAngularWebpack(angularWebpackConfig, options);
  
  // Override output filename
  singleSpaWebpackConfig.output.filename = 'single-spa-angular-app.js';
  
  return singleSpaWebpackConfig;
};
```

### Build Optimization
- Tree shaking
- Code splitting
- Bundle analysis
- Source map generation

## RxJS Integration

### Reactive Patterns
```typescript
@Component({...})
export class DataComponent implements OnInit, OnDestroy {
  data$ = this.service.getData().pipe(
    catchError(this.handleError),
    takeUntil(this.destroy$)
  );
  
  private destroy$ = new Subject<void>();
  
  ngOnDestroy(): void {
    this.destroy$.next();
    this.destroy$.complete();
  }
}
```

### State Management
- Observable services
- Subject-based communication
- Reactive forms
- HTTP interceptors

## Performance Optimization

- **Bundle Size**: ~360KB (compiled)
- **Tree Shaking**: Unused code elimination
- **Lazy Loading**: Route-based code splitting
- **Change Detection**: OnPush strategy optimization

## Testing

### Unit Tests
```bash
npm run test
```

### E2E Tests
```bash
npm run e2e
```

### Linting
```bash
npm run lint
```

## Browser Support

- Modern browsers (ES2015+)
- Differential loading for legacy browsers
- Progressive enhancement
- Polyfill management

## Development Tools

### Angular DevTools
- Component inspector
- Performance profiler
- Dependency injection tree
- Router visualization

### TypeScript Support
- IntelliSense
- Refactoring tools
- Error detection
- Auto-completion

## Contributing

1. Fork the repository
2. Create a feature branch
3. Follow Angular style guide
4. Add unit tests for new features
5. Ensure TypeScript compliance
6. Submit a pull request

## License

MIT License - see LICENSE file for details.

## Related Projects

- [Angular](https://angular.io/) - Platform for building mobile and desktop web applications
- [TypeScript](https://www.typescriptlang.org/) - Typed JavaScript at scale
- [RxJS](https://rxjs.dev/) - Reactive Extensions for JavaScript
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
# Visit http://localhost:4204
```

## Author

Cesar Francisco Chavez Maldonado - Angular 8 Microfrontend Example