// Shared State Showcase Component
// This component can be used across all microfrontends to display shared state

export function createSharedStateShowcase(framework = 'Generic') {
  const container = document.createElement('div');
  container.style.cssText = `
    margin: 15px 0;
    padding: 15px;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    border-radius: 8px;
    color: white;
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
  `;

  const title = document.createElement('h4');
  title.textContent = `🔄 Shared State Management (${framework})`;
  title.style.cssText = `
    margin: 0 0 15px 0;
    color: white;
    font-size: 16px;
  `;

  const userInfo = document.createElement('div');
  userInfo.style.cssText = `
    background: rgba(255,255,255,0.1);
    padding: 10px;
    border-radius: 6px;
    margin-bottom: 10px;
  `;

  const employeeSection = document.createElement('div');
  employeeSection.style.cssText = `
    background: rgba(255,255,255,0.1);
    padding: 10px;
    border-radius: 6px;
    margin-bottom: 10px;
  `;

  const buttonsContainer = document.createElement('div');
  buttonsContainer.style.cssText = `
    display: flex;
    gap: 10px;
    flex-wrap: wrap;
  `;

  // Load Employees Button
  const loadEmployeesBtn = document.createElement('button');
  loadEmployeesBtn.textContent = '👥 Load Employees';
  loadEmployeesBtn.style.cssText = `
    background: #28a745;
    color: white;
    border: none;
    padding: 8px 12px;
    border-radius: 4px;
    cursor: pointer;
    font-size: 12px;
  `;

  // Broadcast Event Button
  const broadcastBtn = document.createElement('button');
  broadcastBtn.textContent = `📡 Broadcast from ${framework}`;
  broadcastBtn.style.cssText = `
    background: #007bff;
    color: white;
    border: none;
    padding: 8px 12px;
    border-radius: 4px;
    cursor: pointer;
    font-size: 12px;
  `;

  // Clear Data Button
  const clearBtn = document.createElement('button');
  clearBtn.textContent = '🗑️ Clear Data';
  clearBtn.style.cssText = `
    background: #dc3545;
    color: white;
    border: none;
    padding: 8px 12px;
    border-radius: 4px;
    cursor: pointer;
    font-size: 12px;
  `;

  container.appendChild(title);
  container.appendChild(userInfo);
  container.appendChild(employeeSection);
  buttonsContainer.appendChild(loadEmployeesBtn);
  buttonsContainer.appendChild(broadcastBtn);
  buttonsContainer.appendChild(clearBtn);
  container.appendChild(buttonsContainer);

  // Update functions
  function updateUserInfo(userState) {
    userInfo.innerHTML = `
      <strong>👤 User State:</strong><br>
      ${userState ? 
        `✅ Logged in as: <strong>${userState.user?.username || 'Unknown'}</strong><br>
         🔑 Token: ${userState.token ? '***' + userState.token.slice(-4) : 'None'}` :
        '❌ Not logged in'
      }
    `;
  }

  function updateEmployeeInfo(employees) {
    const count = employees ? employees.length : 0;
    const preview = employees && employees.length > 0 ? 
      employees.slice(0, 3).map(emp => emp.name).join(', ') + 
      (employees.length > 3 ? ` (+${employees.length - 3} more)` : '') : 
      'No employees loaded';
    
    employeeSection.innerHTML = `
      <strong>👥 Employee Data:</strong><br>
      📊 Count: <strong>${count}</strong><br>
      👀 Preview: ${preview}
    `;
  }

  // Event handlers
  loadEmployeesBtn.onclick = () => {
    if (window.stateManager) {
      window.stateManager.loadEmployees();
      console.log(`🔄 ${framework} app requested employee data load`);
    }
  };

  broadcastBtn.onclick = () => {
    if (window.stateManager) {
      const event = {
        type: 'user-interaction',
        source: framework,
        timestamp: new Date().toISOString(),
        data: { message: `Hello from ${framework}!` }
      };
      window.stateManager.emit('cross-app-message', event);
      console.log(`📡 ${framework} broadcasted event:`, event);
    }
  };

  clearBtn.onclick = () => {
    if (window.stateManager) {
      // Clear employees by setting empty array
      window.stateManager.employees$.next([]);
      console.log(`🗑️ ${framework} cleared employee data`);
    }
  };

  // Subscribe to state changes
  let subscriptions = [];
  
  function initializeSubscriptions() {
    if (window.stateManager) {
      // Subscribe to user state
      const userSub = window.stateManager.userState$.subscribe(updateUserInfo);
      
      // Subscribe to employee data
      const empSub = window.stateManager.employees$.subscribe(updateEmployeeInfo);
      
      // Subscribe to events
      const eventSub = window.stateManager.events$.subscribe(event => {
        console.log(`🎯 ${framework} received event:`, event);
        
        // Visual feedback for received events
        if (event.type === 'cross-app-message' && event.source !== framework) {
          const notification = document.createElement('div');
          notification.style.cssText = `
            position: fixed;
            top: 20px;
            right: 20px;
            background: #17a2b8;
            color: white;
            padding: 10px 15px;
            border-radius: 6px;
            z-index: 10000;
            font-size: 12px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.2);
          `;
          notification.textContent = `📨 Message from ${event.source}: ${event.data?.message}`;
          document.body.appendChild(notification);
          
          setTimeout(() => {
            if (notification.parentNode) {
              notification.parentNode.removeChild(notification);
            }
          }, 3000);
        }
      });
      
      subscriptions = [userSub, empSub, eventSub];
      
      // Initial load
      updateUserInfo(window.stateManager.getUserState());
      updateEmployeeInfo(window.stateManager.getEmployees());
    }
  }

  // Initialize when state manager is available
  if (window.stateManager) {
    initializeSubscriptions();
  } else {
    // Wait for state manager to be available
    const checkInterval = setInterval(() => {
      if (window.stateManager) {
        clearInterval(checkInterval);
        initializeSubscriptions();
      }
    }, 100);
  }

  // Cleanup function
  container.cleanup = () => {
    subscriptions.forEach(sub => sub && sub.unsubscribe && sub.unsubscribe());
  };

  return container;
}

// React Hook version
export function useSharedStateShowcase() {
  if (typeof window !== 'undefined' && window.React) {
    const React = window.React;
    
    const [userState, setUserState] = React.useState(null);
    const [employees, setEmployees] = React.useState([]);
    const [events, setEvents] = React.useState([]);

    React.useEffect(() => {
    if (window.stateManager) {
      const userSub = window.stateManager.userState$.subscribe(setUserState);
      const empSub = window.stateManager.employees$.subscribe(setEmployees);
      const eventSub = window.stateManager.events$.subscribe(event => {
        setEvents(prev => [...prev.slice(-4), event]); // Keep last 5 events
        console.log('⚛️ React hook received event:', event);
      });
      
      return () => {
        userSub.unsubscribe();
        empSub.unsubscribe();
        eventSub.unsubscribe();
      };
    }
  }, []);

    return { userState, employees, events };
  }
  
  return null;
}