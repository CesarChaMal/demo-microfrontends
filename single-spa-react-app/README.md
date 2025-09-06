# single-spa-react-app

> **Part of [Demo Microfrontends](https://github.com/cesarchamal/demo-microfrontends)** - A comprehensive Single-SPA microfrontend architecture demonstration

A React 16 microfrontend for Single-SPA demonstrating modern React features, hooks, context API, and component-based architecture.

## 🏗️ Microfrontend Architecture

This application is one of **12 microfrontends** in the demo-microfrontends project:

| Microfrontend | Framework | Port | Route | Repository |
|---------------|-----------|------|-------|------------|
| 🔐 Auth App | Vue.js | 4201 | /login | [single-spa-auth-app](https://github.com/cesarchamal/single-spa-auth-app) |
| 🎨 Layout App | Vue.js | 4202 | All routes | [single-spa-layout-app](https://github.com/cesarchamal/single-spa-layout-app) |
| 🏠 Home App | AngularJS | 4203 | / | [single-spa-home-app](https://github.com/cesarchamal/single-spa-home-app) |
| 🅰️ Angular App | Angular 8 | 4204 | /angular/* | [single-spa-angular-app](https://github.com/cesarchamal/single-spa-angular-app) |
| 💚 Vue App | Vue.js 2 | 4205 | /vue/* | [single-spa-vue-app](https://github.com/cesarchamal/single-spa-vue-app) |
| **⚛️ React App** | **React 16** | **4206** | **/react/*** | **This repo** |
| 🍦 Vanilla App | ES2020+ | 4207 | /vanilla/* | [single-spa-vanilla-app](https://github.com/cesarchamal/single-spa-vanilla-app) |
| 🧩 Web Components | Lit | 4208 | /webcomponents/* | [single-spa-webcomponents-app](https://github.com/cesarchamal/single-spa-webcomponents-app) |
| 📘 TypeScript App | TypeScript | 4209 | /typescript/* | [single-spa-typescript-app](https://github.com/cesarchamal/single-spa-typescript-app) |
| 💎 jQuery App | jQuery 3.6 | 4210 | /jquery/* | [single-spa-jquery-app](https://github.com/cesarchamal/single-spa-jquery-app) |
| 🔥 Svelte App | Svelte 3 | 4211 | /svelte/* | [single-spa-svelte-app](https://github.com/cesarchamal/single-spa-svelte-app) |
| 🎯 Root App | Single-SPA | 8080 | Orchestrator | [single-spa-root](https://github.com/cesarchamal/single-spa-root) |

**Main Repository**: [demo-microfrontends](https://github.com/cesarchamal/demo-microfrontends)

## Features

- **React 16**: Modern React with hooks and concurrent features
- **React Router**: Declarative routing for React applications
- **React Hooks**: State and lifecycle management with hooks
- **Context API**: Built-in state management solution
- **JSX**: JavaScript XML syntax for component templates
- **Component Composition**: Reusable and composable components

## Technology Stack

- **Framework**: React 16.13.1
- **Router**: React Router DOM 5.2.0
- **Build Tool**: Webpack 4 with custom configuration
- **Language**: JavaScript (ES2015+) with JSX
- **Integration**: Single-SPA React adapter

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
# Runs on http://localhost:4206
```

### Build

```bash
npm run build
# Outputs to dist/single-spa-react-app.js
```

## React Features

### Functional Components with Hooks
```jsx
import React, { useState, useEffect, useContext } from 'react';

const FeatureComponent = ({ title, onFeatureSelect }) => {
  const [data, setData] = useState([]);
  const [loading, setLoading] = useState(false);
  const theme = useContext(ThemeContext);

  useEffect(() => {
    const fetchData = async () => {
      setLoading(true);
      try {
        const response = await fetch('/api/features');
        const result = await response.json();
        setData(result);
      } catch (error) {
        console.error('Error fetching data:', error);
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, []);

  return (
    <div className={`feature-component ${theme.mode}`}>
      <h2>{title}</h2>
      {loading ? (
        <div>Loading...</div>
      ) : (
        <ul>
          {data.map(item => (
            <li key={item.id} onClick={() => onFeatureSelect(item)}>
              {item.name}
            </li>
          ))}
        </ul>
      )}
    </div>
  );
};

export default FeatureComponent;
```

### Class Components (Legacy Support)
```jsx
import React, { Component } from 'react';

class LegacyComponent extends Component {
  constructor(props) {
    super(props);
    this.state = {
      count: 0
    };
  }

  componentDidMount() {
    console.log('Component mounted');
  }

  handleIncrement = () => {
    this.setState(prevState => ({
      count: prevState.count + 1
    }));
  };

  render() {
    return (
      <div>
        <p>Count: {this.state.count}</p>
        <button onClick={this.handleIncrement}>
          Increment
        </button>
      </div>
    );
  }
}
```

### Context API for State Management
```jsx
// ThemeContext.js
import React, { createContext, useContext, useReducer } from 'react';

const ThemeContext = createContext();

const themeReducer = (state, action) => {
  switch (action.type) {
    case 'TOGGLE_THEME':
      return {
        ...state,
        mode: state.mode === 'light' ? 'dark' : 'light'
      };
    default:
      return state;
  }
};

export const ThemeProvider = ({ children }) => {
  const [state, dispatch] = useReducer(themeReducer, {
    mode: 'light'
  });

  return (
    <ThemeContext.Provider value={{ ...state, dispatch }}>
      {children}
    </ThemeContext.Provider>
  );
};

export const useTheme = () => {
  const context = useContext(ThemeContext);
  if (!context) {
    throw new Error('useTheme must be used within ThemeProvider');
  }
  return context;
};
```

## Single-SPA Integration

This microfrontend exports the required Single-SPA lifecycle functions:

```javascript
export const bootstrap = reactLifecycles.bootstrap;
export const mount = reactLifecycles.mount;
export const unmount = reactLifecycles.unmount;
```

### Mount Point

The application mounts to the DOM element with ID `react-app`:

```html
<div id="react-app"></div>
```

### Route Configuration

Configured to activate on routes starting with `/react`:

```javascript
singleSpa.registerApplication(
  'react',
  () => loadApp('single-spa-react-app'),
  showWhenPrefix(['/react'])
);
```

### React Router Integration
```jsx
import { BrowserRouter as Router, Route, Switch } from 'react-router-dom';

const App = () => {
  return (
    <Router basename="/react">
      <div className="react-app">
        <Navigation />
        <Switch>
          <Route exact path="/" component={Home} />
          <Route path="/about" component={About} />
          <Route path="/features" component={Features} />
          <Route path="/contact" component={Contact} />
        </Switch>
      </div>
    </Router>
  );
};
```

## Component Architecture

### Page Components
```jsx
// Home.jsx
import React from 'react';
import HeroSection from '../components/HeroSection';
import FeatureList from '../components/FeatureList';
import CallToAction from '../components/CallToAction';

const Home = () => {
  const [features, setFeatures] = useState([]);

  useEffect(() => {
    fetchFeatures().then(setFeatures);
  }, []);

  const handleFeatureSelect = (feature) => {
    console.log('Selected feature:', feature);
  };

  return (
    <div className="home-page">
      <HeroSection />
      <FeatureList 
        features={features} 
        onFeatureSelect={handleFeatureSelect} 
      />
      <CallToAction />
    </div>
  );
};

export default Home;
```

### Reusable Components
```jsx
// FeatureCard.jsx
import React from 'react';
import PropTypes from 'prop-types';

const FeatureCard = ({ 
  feature, 
  isActive, 
  onSelect, 
  children 
}) => {
  return (
    <div 
      className={`feature-card ${isActive ? 'active' : ''}`}
      onClick={() => onSelect(feature)}
    >
      <div className="feature-icon">
        {children}
      </div>
      <h3>{feature.title}</h3>
      <p>{feature.description}</p>
      <button className="select-button">
        Select Feature
      </button>
    </div>
  );
};

FeatureCard.propTypes = {
  feature: PropTypes.shape({
    id: PropTypes.number.isRequired,
    title: PropTypes.string.isRequired,
    description: PropTypes.string.isRequired
  }).isRequired,
  isActive: PropTypes.bool,
  onSelect: PropTypes.func.isRequired,
  children: PropTypes.node
};

FeatureCard.defaultProps = {
  isActive: false,
  children: null
};

export default FeatureCard;
```

## Custom Hooks

### Data Fetching Hook
```jsx
// hooks/useApi.js
import { useState, useEffect } from 'react';

const useApi = (url, options = {}) => {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchData = async () => {
      setLoading(true);
      setError(null);

      try {
        const response = await fetch(url, options);
        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`);
        }
        const result = await response.json();
        setData(result);
      } catch (err) {
        setError(err.message);
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, [url]);

  return { data, loading, error };
};

export default useApi;
```

### Local Storage Hook
```jsx
// hooks/useLocalStorage.js
import { useState, useEffect } from 'react';

const useLocalStorage = (key, initialValue) => {
  const [storedValue, setStoredValue] = useState(() => {
    try {
      const item = window.localStorage.getItem(key);
      return item ? JSON.parse(item) : initialValue;
    } catch (error) {
      console.error(`Error reading localStorage key "${key}":`, error);
      return initialValue;
    }
  });

  const setValue = (value) => {
    try {
      setStoredValue(value);
      window.localStorage.setItem(key, JSON.stringify(value));
    } catch (error) {
      console.error(`Error setting localStorage key "${key}":`, error);
    }
  };

  return [storedValue, setValue];
};

export default useLocalStorage;
```

## File Structure

```
single-spa-react-app/
├── src/
│   ├── components/          # Reusable components
│   ├── pages/              # Page components
│   ├── hooks/              # Custom hooks
│   ├── context/            # React context providers
│   ├── utils/              # Utility functions
│   ├── styles/             # CSS/SCSS files
│   ├── App.js              # Root component
│   └── singleSpaEntry.js   # Single-SPA integration
├── dist/                   # Build output directory
├── package.json            # Dependencies and scripts
├── webpack.config.js       # Webpack configuration
├── .gitignore             # Git ignore rules
└── README.md              # This file
```

## Webpack Configuration

### Library Build Setup
```javascript
// webpack.config.js
module.exports = {
  entry: './src/singleSpaEntry.js',
  output: {
    library: 'single-spa-react-app',
    libraryTarget: 'umd',
    filename: 'single-spa-react-app.js'
  },
  module: {
    rules: [
      {
        test: /\.(js|jsx)$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader',
          options: {
            presets: ['@babel/preset-react', '@babel/preset-env']
          }
        }
      },
      {
        test: /\.scss$/,
        use: ['style-loader', 'css-loader', 'sass-loader']
      }
    ]
  },
  externals: {
    'react': 'React',
    'react-dom': 'ReactDOM'
  }
};
```

### Development Configuration
- Hot module replacement
- Source maps
- ESLint integration
- SCSS preprocessing

## State Management Patterns

### Component State
```jsx
const [state, setState] = useState({
  loading: false,
  data: null,
  error: null
});

// Update specific properties
setState(prevState => ({
  ...prevState,
  loading: true
}));
```

### Reducer Pattern
```jsx
const initialState = {
  items: [],
  filter: 'all',
  loading: false
};

const reducer = (state, action) => {
  switch (action.type) {
    case 'SET_LOADING':
      return { ...state, loading: action.payload };
    case 'SET_ITEMS':
      return { ...state, items: action.payload, loading: false };
    case 'SET_FILTER':
      return { ...state, filter: action.payload };
    default:
      return state;
  }
};

const [state, dispatch] = useReducer(reducer, initialState);
```

## Performance Optimization

- **Bundle Size**: ~170KB (UMD build)
- **Code Splitting**: Route-based lazy loading
- **Memoization**: React.memo and useMemo
- **Virtual DOM**: Efficient re-rendering

### React.memo for Component Optimization
```jsx
const ExpensiveComponent = React.memo(({ data, onUpdate }) => {
  return (
    <div>
      {/* Expensive rendering logic */}
    </div>
  );
}, (prevProps, nextProps) => {
  // Custom comparison function
  return prevProps.data.id === nextProps.data.id;
});
```

### useMemo and useCallback
```jsx
const Component = ({ items, filter }) => {
  const filteredItems = useMemo(() => {
    return items.filter(item => item.category === filter);
  }, [items, filter]);

  const handleItemClick = useCallback((item) => {
    console.log('Item clicked:', item);
  }, []);

  return (
    <div>
      {filteredItems.map(item => (
        <Item 
          key={item.id} 
          item={item} 
          onClick={handleItemClick} 
        />
      ))}
    </div>
  );
};
```

## Testing

### Unit Tests with Jest
```bash
npm run test
```

### Component Testing with React Testing Library
```jsx
import { render, screen, fireEvent } from '@testing-library/react';
import FeatureCard from './FeatureCard';

test('renders feature card with title', () => {
  const feature = {
    id: 1,
    title: 'Test Feature',
    description: 'Test description'
  };

  render(<FeatureCard feature={feature} onSelect={() => {}} />);
  
  expect(screen.getByText('Test Feature')).toBeInTheDocument();
});
```

### E2E Tests
```bash
npm run test:e2e
```

## Browser Support

- Modern browsers (ES2015+)
- IE11+ with polyfills
- Mobile browsers
- Progressive enhancement

## Contributing

1. Fork the repository
2. Create a feature branch
3. Follow React best practices
4. Add tests for new components
5. Ensure accessibility compliance
6. Submit a pull request

## License

MIT License - see LICENSE file for details.

## Related Projects

- [React](https://reactjs.org/) - JavaScript library for building user interfaces
- [React Router](https://reactrouter.com/) - Declarative routing for React
- [React Testing Library](https://testing-library.com/docs/react-testing-library/intro/) - Testing utilities
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
# Visit http://localhost:4206
```

## Author

Cesar Francisco Chavez Maldonado - React 16 Microfrontend Example