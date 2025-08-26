# Demo Microfrontends with Single-SPA

A comprehensive demonstration of microfrontend architecture using Single-SPA framework, showcasing multiple frontend technologies working together in a unified application.

## Architecture Overview

This project demonstrates a microfrontend architecture with:
- **Root Application**: Orchestrates and manages all microfrontends
- **Multiple Microfrontends**: Independent applications built with different frameworks
- **Authentication**: Centralized login system
- **Shared Layout**: Common header, navigation, and footer components

## Project Structure

```
demo-microfrontends/
├── single-spa-login-example-with-npm-packages/  # Root application
├── single-spa-auth-app/                         # Vue.js authentication app
├── single-spa-layout-app/                       # Vue.js layout components
├── single-spa-home-app/                         # AngularJS home page
├── single-spa-angular-app/                      # Angular 8 application
├── single-spa-react-app/                        # React application
├── single-spa-vue-app/                          # Vue.js application
└── sportRadarExercise/                          # Java backend exercise
```

## Microfrontends

### 1. Root Application (`single-spa-login-example-with-npm-packages`)
- **Framework**: Single-SPA orchestrator
- **Port**: 8080
- **Purpose**: Manages routing and application lifecycle
- **Technologies**: JavaScript, Webpack, SystemJS

### 2. Authentication App (`single-spa-auth-app`)
- **Framework**: Vue.js
- **Port**: 4201
- **Purpose**: Login functionality
- **Route**: `/login`

### 3. Layout App (`single-spa-layout-app`)
- **Framework**: Vue.js
- **Port**: 4202
- **Purpose**: Shared header, navbar, and footer
- **Active**: All routes except `/login`

### 4. Home App (`single-spa-home-app`)
- **Framework**: AngularJS 1.x
- **Port**: 4203
- **Purpose**: Landing page
- **Route**: `/`

### 5. Angular App (`single-spa-angular-app`)
- **Framework**: Angular 8
- **Port**: 4204
- **Purpose**: Feature-rich application with routing
- **Route**: `/angular/*`

### 6. React App (`single-spa-react-app`)
- **Framework**: React 16
- **Port**: 4206
- **Purpose**: React-based features
- **Route**: `/react/*`

### 7. Vue App (`single-spa-vue-app`)
- **Framework**: Vue.js 2
- **Port**: 4205
- **Purpose**: Vue-based features
- **Route**: `/vue/*`

### 8. SportRadar Exercise (`sportRadarExercise`)
- **Framework**: Java with Maven
- **Purpose**: Backend exercise demonstrating design patterns
- **Technologies**: Java 22, JUnit, Mockito

## Prerequisites

- Node.js (v14 or higher)
- npm or yarn
- Java 22 (for SportRadar exercise)
- Maven (for Java project)

## Quick Start

### 1. Bootstrap All Applications
```bash
cd single-spa-login-example-with-npm-packages
npm run bootstrap
```

### 2. Development Mode
```bash
npm run serve
```

This command will:
- Start the root application on port 8080
- Build all microfrontends in development mode
- Serve each microfrontend on its respective port
- Enable hot reloading for development

### 3. Production Build
```bash
npm run build:apps
npm run build
npm start
```

## Individual Application Setup

### Root Application
```bash
cd single-spa-login-example-with-npm-packages
npm install
npm run serve:root
```

### Each Microfrontend
```bash
cd [app-directory]
npm install
npm run build
```

## Available Scripts

### Root Application Scripts
- `npm run bootstrap` - Install dependencies for all applications
- `npm run serve` - Start development environment
- `npm run build:apps` - Build all microfrontends
- `npm run build` - Build root application
- `npm start` - Start production server
- `npm run lint-all:strict` - Lint all applications (strict mode)

### Individual App Scripts
- `npm run build` - Build the application
- `npm run lint` - Lint the application code

## Technology Stack

### Frontend Technologies
- **Single-SPA**: Microfrontend orchestration
- **Angular 8**: Modern Angular framework
- **React 16**: React library with hooks
- **Vue.js 2**: Progressive JavaScript framework
- **AngularJS 1.x**: Legacy Angular for comparison
- **Bootstrap 4**: CSS framework
- **SystemJS**: Module loader

### Build Tools
- **Webpack 4**: Module bundler
- **Babel**: JavaScript transpiler
- **ESLint**: Code linting
- **Various CLI tools**: Angular CLI, Vue CLI, Create React App

### Backend
- **Java 22**: Modern Java with latest features
- **Maven**: Build automation
- **JUnit 4**: Testing framework
- **Mockito**: Mocking framework

## Design Patterns (Java Exercise)

The SportRadar exercise demonstrates various design patterns:
- **Abstract Factory**: Match creation
- **Command Pattern**: Match operations
- **Observer Pattern**: Event notifications
- **State Pattern**: Match state management
- **Strategy Pattern**: Scoring strategies
- **Decorator Pattern**: Match enhancements

## Development Workflow

1. **Start Development**: Run `npm run serve` from root
2. **Access Application**: Open http://localhost:8080
3. **Navigate Routes**:
   - `/` - Home (AngularJS)
   - `/login` - Authentication (Vue)
   - `/angular/*` - Angular features
   - `/react/*` - React features
   - `/vue/*` - Vue features

## Port Configuration

| Application | Port | URL |
|-------------|------|-----|
| Root | 8080 | http://localhost:8080 |
| Auth | 4201 | http://localhost:4201 |
| Layout | 4202 | http://localhost:4202 |
| Home | 4203 | http://localhost:4203 |
| Angular | 4204 | http://localhost:4204 |
| Vue | 4205 | http://localhost:4205 |
| React | 4206 | http://localhost:4206 |

## Features

- **Framework Agnostic**: Multiple frontend frameworks coexisting
- **Independent Deployment**: Each microfrontend can be deployed separately
- **Shared Dependencies**: Common libraries managed efficiently
- **Authentication Flow**: Centralized login system
- **Routing**: Client-side routing across applications
- **Hot Reloading**: Development-friendly setup

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run linting: `npm run lint-all:loose`
5. Test your changes
6. Submit a pull request

## License

MIT License - see individual LICENSE files in each application directory.

## Authors

- Juan Manuel López Pazos (Original author)
- Various contributors

## Troubleshooting

### Common Issues

1. **Port Conflicts**: Ensure all required ports are available
2. **Node Version**: Use Node.js v14 or higher
3. **Memory Issues**: Increase Node.js memory limit if needed
4. **CORS Issues**: Applications are configured with CORS support

### Debug Mode

Enable debug logging by setting environment variables:
```bash
DEBUG=single-spa:* npm run serve
```

## Additional Resources

- [Single-SPA Documentation](https://single-spa.js.org/)
- [Microfrontends.info](https://microfrontends.info/)
- [Angular Documentation](https://angular.io/)
- [React Documentation](https://reactjs.org/)
- [Vue.js Documentation](https://vuejs.org/)