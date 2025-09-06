# single-spa-typescript-app

> **Part of [Demo Microfrontends](https://github.com/cesarchamal/demo-microfrontends)** - A comprehensive Single-SPA microfrontend architecture demonstration

A TypeScript microfrontend for Single-SPA demonstrating type safety, interfaces, and compile-time error detection in microfrontend architecture.

## 🏗️ Microfrontend Architecture

This application is one of **12 microfrontends** in the demo-microfrontends project:

| Microfrontend | Framework | Port | Route | Repository |
|---------------|-----------|------|-------|------------|
| 🔐 Auth App | Vue.js | 4201 | /login | [single-spa-auth-app](https://github.com/cesarchamal/single-spa-auth-app) |
| 🎨 Layout App | Vue.js | 4202 | All routes | [single-spa-layout-app](https://github.com/cesarchamal/single-spa-layout-app) |
| 🏠 Home App | AngularJS | 4203 | / | [single-spa-home-app](https://github.com/cesarchamal/single-spa-home-app) |
| 🅰️ Angular App | Angular 8 | 4204 | /angular/* | [single-spa-angular-app](https://github.com/cesarchamal/single-spa-angular-app) |
| 💚 Vue App | Vue.js 2 | 4205 | /vue/* | [single-spa-vue-app](https://github.com/cesarchamal/single-spa-vue-app) |
| ⚛️ React App | React 16 | 4206 | /react/* | [single-spa-react-app](https://github.com/cesarchamal/single-spa-react-app) |
| 🍦 Vanilla App | ES2020+ | 4207 | /vanilla/* | [single-spa-vanilla-app](https://github.com/cesarchamal/single-spa-vanilla-app) |
| 🧩 Web Components | Lit | 4208 | /webcomponents/* | [single-spa-webcomponents-app](https://github.com/cesarchamal/single-spa-webcomponents-app) |
| **📘 TypeScript App** | **TypeScript** | **4209** | **/typescript/*** | **This repo** |
| 💎 jQuery App | jQuery 3.6 | 4210 | /jquery/* | [single-spa-jquery-app](https://github.com/cesarchamal/single-spa-jquery-app) |
| 🔥 Svelte App | Svelte 3 | 4211 | /svelte/* | [single-spa-svelte-app](https://github.com/cesarchamal/single-spa-svelte-app) |
| 🎯 Root App | Single-SPA | 8080 | Orchestrator | [single-spa-root](https://github.com/cesarchamal/single-spa-root) |

**Main Repository**: [demo-microfrontends](https://github.com/cesarchamal/demo-microfrontends)

## Features

- **Strong Typing**: Full TypeScript with strict mode enabled
- **Interface Definitions**: Type-safe data structures and APIs
- **Generic Types**: Reusable type-safe components
- **Compile-time Validation**: Catch errors before runtime
- **Enhanced IDE Support**: IntelliSense, refactoring, navigation

## Technology Stack

- **Language**: TypeScript 3.5.3
- **Build Tool**: Webpack 4 with ts-loader
- **Type Checking**: Strict TypeScript configuration
- **Integration**: Single-SPA lifecycle with typed interfaces

## Development

### Prerequisites

- Node.js (v18.0.0 or higher)
- npm (v8.0.0 or higher)
- TypeScript knowledge recommended

### Installation

```bash
npm install
```

### Development Server

```bash
npm start
# Runs on http://localhost:4209
```

### Build

```bash
npm run build
# Outputs to dist/single-spa-typescript-app.js
```

## TypeScript Features Demonstrated

### Interfaces and Types
```typescript
interface User {
  id: number;
  name: string;
  email: string;
  role: 'admin' | 'user' | 'guest';
  createdAt: Date;
}

interface ApiResponse<T> {
  data: T;
  status: 'success' | 'error';
  message: string;
  timestamp: string;
}
```

### Generic Functions
```typescript
private async fetchUsersFromAPI(): Promise<ApiResponse<User[]>> {
  // Type-safe API response handling
}
```

### Strict Type Checking
- Null safety with strict null checks
- No implicit any types
- Unused variable detection
- Consistent casing enforcement

## Single-SPA Integration

This microfrontend exports typed Single-SPA lifecycle functions:

```typescript
export const bootstrap = (): Promise<void> => Promise.resolve();
export const mount = (props?: any): Promise<void> => typeScriptApp.mount(props);
export const unmount = (): Promise<void> => typeScriptApp.unmount();
```

### Mount Point

The application mounts to the DOM element with ID `typescript-app`:

```html
<div id="typescript-app"></div>
```

### Route Configuration

Configured to activate on routes starting with `/typescript`:

```javascript
singleSpa.registerApplication(
  'typescript',
  () => loadApp('single-spa-typescript-app'),
  showWhenPrefix(['/typescript'])
);
```

## Development Benefits

### Compile-time Safety
- Interface validation
- Type checking across modules
- Refactoring safety
- API contract enforcement

### IDE Integration
- Auto-completion
- Inline documentation
- Error highlighting
- Intelligent refactoring

### Code Quality
- Self-documenting interfaces
- Reduced runtime errors
- Better maintainability
- Team collaboration

## Configuration

### TypeScript Config (tsconfig.json)
```json
{
  "compilerOptions": {
    "target": "ES2018",
    "module": "ESNext",
    "strict": true,
    "esModuleInterop": true
  }
}
```

### Webpack Integration
- ts-loader for TypeScript compilation
- Source map generation
- Type checking during build

## Performance

- **Bundle Size**: ~8KB (compiled JavaScript)
- **Compilation**: Fast incremental builds
- **Runtime**: No TypeScript overhead
- **Development**: Enhanced productivity

## File Structure

```
single-spa-typescript-app/
├── src/
│   └── single-spa-typescript-app.ts      # Main TypeScript entry
├── dist/                                 # Build output directory
├── tsconfig.json                         # TypeScript configuration
├── package.json                          # Dependencies and scripts
├── webpack.config.js                     # Build configuration
├── .gitignore                           # Git ignore rules
└── README.md                            # This file
```

## Best Practices

### Type Definitions
- Use interfaces for object shapes
- Leverage union types for enums
- Generic types for reusability
- Strict null checking

### Error Handling
- Type-safe error boundaries
- Proper exception typing
- Validation at boundaries

### API Integration
- Typed response interfaces
- Generic API functions
- Runtime type validation

## Contributing

1. Fork the repository
2. Create a feature branch
3. Follow TypeScript best practices
4. Add type definitions for new features
5. Test compilation and runtime behavior
6. Submit a pull request

## License

MIT License - see LICENSE file for details.

## Related Projects

- [TypeScript](https://www.typescriptlang.org/) - Typed JavaScript at scale
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
# Visit http://localhost:4209
```

## Author

Cesar Francisco Chavez Maldonado - TypeScript Microfrontend Example