import React from 'react';
import './App.scss';

import {
  Route,
  NavLink,
  Switch,
} from 'react-router-dom';

import List from './components/List';
import Detail from './components/Detail';

function App() {
  const [count, setCount] = React.useState(0);
  const [mounted] = React.useState(new Date().toLocaleString());
  
  const features = [
    'Hooks and Functional Components',
    'React Router for Navigation',
    'Component State Management',
    'Virtual DOM Rendering',
    'JSX Syntax'
  ];

  return (
    <div style={{
      padding: '20px',
      border: '2px solid #61dafb',
      borderRadius: '8px',
      margin: '10px 0',
      background: '#f8f9fa',
      fontFamily: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif'
    }}>
      <h2 style={{ color: '#61dafb', margin: '0 0 15px 0' }}>
        <img 
          src="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9Ii0xMS41IC0xMC4yMzE3NCAyMyAyMC40NjM0OCI+CiAgPHRpdGxlPlJlYWN0IExvZ288L3RpdGxlPgogIDxjaXJjbGUgY3g9IjAiIGN5PSIwIiByPSIyLjA1IiBmaWxsPSIjNjFkYWZiIi8+CiAgPGcgc3Ryb2tlPSIjNjFkYWZiIiBzdHJva2Utd2lkdGg9IjEiIGZpbGw9Im5vbmUiPgogICAgPGVsbGlwc2Ugcng9IjExIiByeT0iNC4yIi8+CiAgICA8ZWxsaXBzZSByeD0iMTEiIHJ5PSI0LjIiIHRyYW5zZm9ybT0icm90YXRlKDYwKSIvPgogICAgPGVsbGlwc2Ugcng9IjExIiByeT0iNC4yIiB0cmFuc2Zvcm09InJvdGF0ZSgxMjApIi8+CiAgPC9nPgo8L3N2Zz4K" 
          width="40" 
          height="40" 
          style={{ verticalAlign: 'middle', marginRight: '10px' }}
          alt="React logo"
        />
        React Microfrontend
      </h2>
      <p><strong>Framework:</strong> React 16 with Hooks</p>
      <p><strong>Features:</strong> Modern React patterns, routing, state management</p>
      <p><strong>Mounted at:</strong> {mounted}</p>
      
      <div style={{
        margin: '15px 0',
        padding: '15px',
        background: 'white',
        borderRadius: '6px'
      }}>
        <h4 style={{ color: '#495057', margin: '0 0 10px 0' }}>Interactive Counter</h4>
        <button 
          onClick={() => setCount(count + 1)}
          style={{
            background: '#61dafb',
            color: 'white',
            border: 'none',
            padding: '8px 16px',
            borderRadius: '4px',
            cursor: 'pointer',
            marginRight: '10px'
          }}
        >
          Count: {count}
        </button>
        <button 
          onClick={() => setCount(0)}
          style={{
            background: '#6c757d',
            color: 'white',
            border: 'none',
            padding: '8px 16px',
            borderRadius: '4px',
            cursor: 'pointer'
          }}
        >
          Reset
        </button>
      </div>
      
      <div style={{
        margin: '15px 0',
        padding: '15px',
        background: 'white',
        borderRadius: '6px'
      }}>
        <h4 style={{ color: '#495057', margin: '0 0 10px 0' }}>Navigation</h4>
        <nav style={{ marginBottom: '15px' }}>
          <NavLink 
            to="/" 
            activeClassName="active" 
            exact={true}
            style={{
              marginRight: '15px',
              color: '#61dafb',
              textDecoration: 'none'
            }}
          >
            List
          </NavLink>
          <NavLink 
            to="/detail" 
            activeClassName="active" 
            exact={true}
            style={{
              color: '#61dafb',
              textDecoration: 'none'
            }}
          >
            Detail
          </NavLink>
        </nav>
        <Switch>
          <Route exact path="/" component={List} />
          <Route path="/detail" component={Detail} />
        </Switch>
      </div>
      
      <div style={{ marginTop: '15px', fontSize: '0.9em', color: '#6c757d' }}>
        <strong>React Features:</strong>
        <ul style={{ margin: '5px 0', paddingLeft: '20px' }}>
          {features.map((feature, index) => (
            <li key={index}>{feature}</li>
          ))}
        </ul>
      </div>
    </div>
  );
}

export default App;
