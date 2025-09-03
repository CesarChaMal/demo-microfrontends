# single-spa-typescript-app

A TypeScript microfrontend for Single-SPA demonstrating type safety, interfaces, and compile-time error detection in microfrontend architecture.

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
- [Demo Microfrontends](../README.md) - Complete microfrontend demo

## Author

Cesar Francisco Chavez Maldonado - TypeScript Microfrontend Example