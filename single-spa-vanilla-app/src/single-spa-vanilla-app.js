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
      if (window.stateManager) {
        this.userStateSub = window.stateManager.userState$.subscribe(userState => {
          console.log('🍦 Vanilla: User state changed:', userState);
        });
        this.eventsSub = window.stateManager.events$.subscribe(event => {
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