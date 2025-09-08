// Modern Vanilla JavaScript ES Module Microfrontend
class VanillaApp {
  constructor() {
    this.container = null;
    this.mounted = false;
  }

  mount(props) {
    return new Promise((resolve) => {
      this.container = document.getElementById('vanilla-app');
      if (!this.container) {
        console.error('Mount point #vanilla-app not found');
        return resolve();
      }

      // Subscribe to global state
      this.userState = null;
      this.employees = [];
      this.events = [];
      
      if (window.stateManager) {
        this.userStateSub = window.stateManager.userState$.subscribe(userState => {
          this.userState = userState;
          this.updateSharedStateDisplay();
          console.log('🍦 Vanilla: User state changed:', userState);
        });
        this.employeesSub = window.stateManager.employees$.subscribe(employees => {
          this.employees = employees;
          this.updateSharedStateDisplay();
        });
        this.eventsSub = window.stateManager.events$.subscribe(event => {
          this.events = [...this.events.slice(-4), event];
          this.updateSharedStateDisplay();
          console.log('🍦 Vanilla received event:', event);
        });
      }

      this.render();
      this.mounted = true;
      console.log('🍦 Vanilla JS App mounted');
      resolve();
    });
  }

  unmount() {
    return new Promise((resolve) => {
      // Cleanup state subscription
      if (this.userStateSub) {
        this.userStateSub.unsubscribe();
      }
      if (this.employeesSub) {
        this.employeesSub.unsubscribe();
      }
      if (this.eventsSub) {
        this.eventsSub.unsubscribe();
      }
      
      if (this.container) {
        this.container.innerHTML = '';
      }
      this.mounted = false;
      console.log('🍦 Vanilla JS App unmounted');
      resolve();
    });
  }

  render() {
    const now = new Date().toLocaleString();
    
    this.container.innerHTML = `
      <div style="padding: 20px; border: 2px solid #28a745; border-radius: 8px; margin: 10px 0; background: #f8f9fa;">
        <h2 style="color: #28a745; margin: 0 0 15px 0;">
          <img src="https://raw.githubusercontent.com/voodootikigod/logo.js/master/js.png" width="40" height="40" style="vertical-align: middle; margin-right: 10px;">
          Vanilla JavaScript ES Module
        </h2>
        <p><strong>Framework:</strong> Pure JavaScript (ES2020+)</p>
        <p><strong>Features:</strong> Native ES Modules, Web Components, Modern APIs</p>
        <p><strong>Mounted at:</strong> ${now}</p>
        
        <div style="margin: 15px 0;">
          <button id="vanilla-counter-btn" style="
            background: #28a745; 
            color: white; 
            border: none; 
            padding: 8px 16px; 
            border-radius: 4px; 
            cursor: pointer;
            margin-right: 10px;
          ">
            Click Count: <span id="vanilla-counter">0</span>
          </button>
          
          <button id="vanilla-fetch-btn" style="
            background: #007bff; 
            color: white; 
            border: none; 
            padding: 8px 16px; 
            border-radius: 4px; 
            cursor: pointer;
            margin-right: 10px;
          ">
            Fetch Data
          </button>
          
          <button id="vanilla-employees-btn" style="
            background: #28a745; 
            color: white; 
            border: none; 
            padding: 8px 16px; 
            border-radius: 4px; 
            cursor: pointer;
          ">
            Load Employees
          </button>
        </div>
        
        <div id="vanilla-data" style="
          margin-top: 15px; 
          padding: 10px; 
          background: #e9ecef; 
          border-radius: 4px;
          min-height: 40px;
        ">
          <em>Click "Fetch Data" to load content...</em>
        </div>
        
        <!-- Shared State Showcase -->
        <div id="shared-state-showcase" style="
          margin: 15px 0; 
          padding: 15px; 
          background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); 
          border-radius: 8px; 
          color: white;
        ">
          <h4 style="margin: 0 0 15px 0; color: white;">🔄 Shared State Management (Vanilla JS)</h4>
          
          <div id="user-state-info" style="
            background: rgba(255,255,255,0.1); 
            padding: 10px; 
            border-radius: 6px; 
            margin-bottom: 10px;
          ">
            <strong>👤 User State:</strong><br>
            <span id="user-status">❌ Not logged in</span>
          </div>
          
          <div id="employee-state-info" style="
            background: rgba(255,255,255,0.1); 
            padding: 10px; 
            border-radius: 6px; 
            margin-bottom: 10px;
          ">
            <strong>👥 Employee Data:</strong><br>
            📊 Count: <strong><span id="employee-count">0</span></strong><br>
            👀 Preview: <span id="employee-preview">No employees loaded</span>
          </div>
          
          <div style="display: flex; gap: 10px; flex-wrap: wrap; margin-bottom: 10px;">
            <button id="load-employees-btn" style="
              background: #28a745; 
              color: white; 
              border: none; 
              padding: 8px 12px; 
              border-radius: 4px; 
              cursor: pointer; 
              font-size: 12px;
            ">
              👥 Load Employees
            </button>
            <button id="broadcast-btn" style="
              background: #007bff; 
              color: white; 
              border: none; 
              padding: 8px 12px; 
              border-radius: 4px; 
              cursor: pointer; 
              font-size: 12px;
            ">
              📡 Broadcast from Vanilla
            </button>
            <button id="clear-employees-btn" style="
              background: #dc3545; 
              color: white; 
              border: none; 
              padding: 8px 12px; 
              border-radius: 4px; 
              cursor: pointer; 
              font-size: 12px;
            ">
              🗑️ Clear Data
            </button>
          </div>
          
          <div id="events-info" style="
            background: rgba(255,255,255,0.1); 
            padding: 10px; 
            border-radius: 6px; 
            font-size: 12px;
            display: none;
          ">
            <strong>📨 Recent Events:</strong><br>
            <div id="events-list"></div>
          </div>
        </div>
        
        <div style="margin-top: 15px; font-size: 0.9em; color: #6c757d;">
          <strong>Modern Features:</strong>
          <ul style="margin: 5px 0; padding-left: 20px;">
            <li>ES2020+ Modules</li>
            <li>Async/Await</li>
            <li>Fetch API</li>
            <li>Template Literals</li>
            <li>Arrow Functions</li>
          </ul>
        </div>
      </div>
    `;

    this.attachEventListeners();
  }

  attachEventListeners() {
    let counter = 0;
    
    // Counter functionality
    const counterBtn = this.container.querySelector('#vanilla-counter-btn');
    const counterSpan = this.container.querySelector('#vanilla-counter');
    
    counterBtn?.addEventListener('click', () => {
      counter++;
      counterSpan.textContent = counter;
      if (window.stateManager) {
        window.stateManager.emit('vanilla-counter', { count: counter, app: 'Vanilla' });
      }
    });

    // Fetch functionality
    const fetchBtn = this.container.querySelector('#vanilla-fetch-btn');
    const employeesBtn = this.container.querySelector('#vanilla-employees-btn');
    const dataDiv = this.container.querySelector('#vanilla-data');
    
    fetchBtn?.addEventListener('click', async () => {
      dataDiv.innerHTML = '<em>Loading...</em>';
      
      try {
        // Simulate API call
        await new Promise(resolve => setTimeout(resolve, 1000));
        
        const mockData = {
          timestamp: new Date().toISOString(),
          randomId: Math.random().toString(36).substr(2, 9),
          status: 'success',
          message: 'Data fetched using modern Fetch API!'
        };
        
        dataDiv.innerHTML = `
          <strong>Fetched Data:</strong>
          <pre style="background: white; padding: 10px; border-radius: 4px; margin-top: 5px; overflow-x: auto;">
${JSON.stringify(mockData, null, 2)}
          </pre>
        `;
      } catch (error) {
        dataDiv.innerHTML = `<span style="color: #dc3545;">Error: ${error.message}</span>`;
      }
    });

    // Load employees functionality
    employeesBtn?.addEventListener('click', () => {
      if (window.stateManager) {
        window.stateManager.loadEmployees();
      }
    });

    // Shared state showcase buttons
    const loadEmployeesBtnShowcase = this.container.querySelector('#load-employees-btn');
    const broadcastBtn = this.container.querySelector('#broadcast-btn');
    const clearEmployeesBtn = this.container.querySelector('#clear-employees-btn');

    loadEmployeesBtnShowcase?.addEventListener('click', () => {
      if (window.stateManager) {
        window.stateManager.loadEmployees();
      }
    });

    broadcastBtn?.addEventListener('click', () => {
      if (window.stateManager) {
        const event = {
          type: 'user-interaction',
          source: 'Vanilla',
          timestamp: new Date().toISOString(),
          data: { message: 'Hello from Vanilla JS!' }
        };
        window.stateManager.emit('cross-app-message', event);
      }
    });

    clearEmployeesBtn?.addEventListener('click', () => {
      if (window.stateManager) {
        window.stateManager.employees$.next([]);
      }
    });
  }

  updateSharedStateDisplay() {
    if (!this.container) return;

    // Update user state
    const userStatus = this.container.querySelector('#user-status');
    if (userStatus) {
      userStatus.innerHTML = this.userState ? 
        `✅ Logged in as: <strong>${this.userState.user?.username || 'Unknown'}</strong>` :
        '❌ Not logged in';
    }

    // Update employee data
    const employeeCount = this.container.querySelector('#employee-count');
    const employeePreview = this.container.querySelector('#employee-preview');
    
    if (employeeCount) {
      employeeCount.textContent = this.employees.length;
    }
    
    if (employeePreview) {
      if (this.employees.length > 0) {
        const preview = this.employees.slice(0, 3).map(emp => emp.name).join(', ');
        const extra = this.employees.length > 3 ? ` (+${this.employees.length - 3} more)` : '';
        employeePreview.textContent = preview + extra;
      } else {
        employeePreview.textContent = 'No employees loaded';
      }
    }

    // Update events
    const eventsInfo = this.container.querySelector('#events-info');
    const eventsList = this.container.querySelector('#events-list');
    
    if (eventsInfo && eventsList) {
      if (this.events.length > 0) {
        eventsInfo.style.display = 'block';
        eventsList.innerHTML = this.events.slice(-3).map(event => 
          `<div style="margin-top: 5px;">${event.source}: ${event.data?.message || event.type}</div>`
        ).join('');
      } else {
        eventsInfo.style.display = 'none';
      }
    }
  }
}

// Single-SPA Lifecycle Functions
const vanillaApp = new VanillaApp();

export const bootstrap = () => Promise.resolve();
export const mount = (props) => vanillaApp.mount(props);
export const unmount = () => vanillaApp.unmount();

// Also export as default for UMD compatibility
export default {
  bootstrap,
  mount,
  unmount
};