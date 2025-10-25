import React, { useState, useEffect } from 'react';
import './App.scss';

// Custom hook for global state
function useGlobalState() {
  const [userState, setUserState] = useState(null);
  
  useEffect(() => {
    if (window.stateManager) {
      const userSub = window.stateManager.userState$.subscribe(setUserState);
      const eventsSub = window.stateManager.events$.subscribe(event => {
        console.log('⚛️ React received event:', event);
      });
      return () => {
        userSub.unsubscribe();
        eventsSub.unsubscribe();
      };
    }
  }, []);
  
  return userState;
}

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
  const userState = useGlobalState();
  const [sharedUserState, setSharedUserState] = useState(null);
  const [employees, setEmployees] = useState([]);
  const [events, setEvents] = useState([]);
  
  useEffect(() => {
    if (window.stateManager) {
      const userSub = window.stateManager.userState$.subscribe(setSharedUserState);
      const employeesSub = window.stateManager.employees$.subscribe(setEmployees);
      const eventsSub = window.stateManager.events$.subscribe(event => {
        console.log('⚛️ React received event:', event);
        setEvents(prev => [...prev.slice(-4), event]);
      });
      return () => {
        userSub.unsubscribe();
        employeesSub.unsubscribe();
        eventsSub.unsubscribe();
      };
    }
  }, []);
  
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
          onClick={() => {
            setCount(count + 1);
            if (window.stateManager) {
              window.stateManager.emit('react-counter', { count: count + 1, app: 'React' });
            }
          }}
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
      
      {/* Shared State Showcase */}
      <div style={{
        margin: '15px 0',
        padding: '15px',
        background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
        borderRadius: '8px',
        color: 'white'
      }}>
        <h4 style={{ margin: '0 0 15px 0', color: 'white' }}>🔄 Shared State Management (React)</h4>
        
        <div style={{
          background: 'rgba(255,255,255,0.1)',
          padding: '10px',
          borderRadius: '6px',
          marginBottom: '10px'
        }}>
          <strong>👤 User State:</strong><br/>
          {sharedUserState ? 
            `✅ Logged in as: ${(sharedUserState.user && sharedUserState.user.username) || 'Unknown'}` :
            '❌ Not logged in'
          }
        </div>
        
        <div style={{
          background: 'rgba(255,255,255,0.1)',
          padding: '10px',
          borderRadius: '6px',
          marginBottom: '10px'
        }}>
          <strong>👥 Employee Data:</strong><br/>
          📊 Count: <strong>{(employees && employees.length) || 0}</strong><br/>
          👀 Preview: {employees && employees.length > 0 ? 
            employees.slice(0, 3).map(emp => emp.name).join(', ') + 
            (employees.length > 3 ? ` (+${employees.length - 3} more)` : '') : 
            'No employees loaded'
          }
        </div>
        
        <div style={{ display: 'flex', gap: '10px', flexWrap: 'wrap' }}>
          <button 
            onClick={() => window.stateManager && window.stateManager.loadEmployees()}
            style={{
              background: '#28a745',
              color: 'white',
              border: 'none',
              padding: '8px 12px',
              borderRadius: '4px',
              cursor: 'pointer',
              fontSize: '12px'
            }}
          >
            👥 Load Employees
          </button>
          <button 
            onClick={() => {
              if (window.stateManager) {
                const eventData = {
                  source: 'React',
                  message: 'Hello from React!',
                  timestamp: new Date().toISOString()
                };
                window.stateManager.emit('cross-app-message', eventData);
              }
            }}
            style={{
              background: '#007bff',
              color: 'white',
              border: 'none',
              padding: '8px 12px',
              borderRadius: '4px',
              cursor: 'pointer',
              fontSize: '12px'
            }}
          >
            📡 Broadcast from React
          </button>
          <button 
            onClick={() => window.stateManager && window.stateManager.employees$.next([])}
            style={{
              background: '#dc3545',
              color: 'white',
              border: 'none',
              padding: '8px 12px',
              borderRadius: '4px',
              cursor: 'pointer',
              fontSize: '12px'
            }}
          >
            🗑️ Clear Data
          </button>
        </div>
        
        {events && events.length > 0 && (
          <div style={{
            background: 'rgba(255,255,255,0.1)',
            padding: '10px',
            borderRadius: '6px',
            marginTop: '10px',
            fontSize: '12px'
          }}>
            <strong>📨 Recent Events:</strong><br/>
            {events.slice(-3).map((event, i) => (
              <div key={i} style={{ marginTop: '5px' }}>
                {(event.data && event.data.source) || event.event}: {(event.data && event.data.message) || event.event}
              </div>
            ))}
          </div>
        )}
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
