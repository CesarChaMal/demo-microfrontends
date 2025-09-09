import { LitElement, html, css } from 'lit';

// Custom Web Component using Lit
class MicroWidget extends LitElement {
  static styles = css`
    :host {
      display: block;
      padding: 20px;
      border: 2px solid #6f42c1;
      border-radius: 8px;
      margin: 10px 0;
      background: #f8f9fa;
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    }
    
    h2 {
      color: #6f42c1;
      margin: 0 0 15px 0;
    }
    
    .counter-section {
      margin: 15px 0;
    }
    
    button {
      background: #6f42c1;
      color: white;
      border: none;
      padding: 8px 16px;
      border-radius: 4px;
      cursor: pointer;
      margin-right: 10px;
      transition: background-color 0.2s;
    }
    
    button:hover {
      background: #5a32a3;
    }
    
    .data-display {
      margin-top: 15px;
      padding: 10px;
      background: #e9ecef;
      border-radius: 4px;
      min-height: 40px;
    }
    
    .features {
      margin-top: 15px;
      font-size: 0.9em;
      color: #6c757d;
    }
    
    ul {
      margin: 5px 0;
      padding-left: 20px;
    }
    
    .shared-state-showcase {
      margin: 15px 0;
      padding: 15px;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      border-radius: 8px;
      color: white;
    }
    
    .state-info {
      background: rgba(255,255,255,0.1);
      padding: 10px;
      border-radius: 6px;
      margin-bottom: 10px;
    }
    
    .showcase-buttons {
      display: flex;
      gap: 10px;
      flex-wrap: wrap;
      margin-bottom: 10px;
    }
    
    .showcase-btn {
      padding: 8px 12px;
      border-radius: 4px;
      cursor: pointer;
      font-size: 12px;
      border: none;
    }
    
    .load-btn {
      background: #28a745;
      color: white;
    }
    
    .broadcast-btn {
      background: #007bff;
      color: white;
    }
    
    .clear-btn {
      background: #dc3545;
      color: white;
    }
    
    .events-info {
      background: rgba(255,255,255,0.1);
      padding: 10px;
      border-radius: 6px;
      font-size: 12px;
    }
    
    .event-item {
      margin-top: 5px;
    }
  `;

  static properties = {
    count: { type: Number },
    data: { type: Object },
    loading: { type: Boolean },
    sharedUserState: { type: Object },
    employees: { type: Array },
    events: { type: Array }
  };

  constructor() {
    super();
    this.count = 0;
    this.data = null;
    this.loading = false;
    this.sharedUserState = null;
    this.employees = [];
    this.events = [];
  }

  connectedCallback() {
    super.connectedCallback();
    if (window.stateManager) {
      this.userStateSub = window.stateManager.userState$.subscribe(state => {
        this.sharedUserState = state;
        this.requestUpdate();
      });
      this.employeesSub = window.stateManager.employees$.subscribe(employees => {
        this.employees = employees;
        this.requestUpdate();
      });
      this.eventsSub = window.stateManager.events$.subscribe(event => {
        this.events = [...this.events.slice(-4), event];
        this.requestUpdate();
        console.log('🧩 Web Components received event:', event);
      });
    }
  }

  disconnectedCallback() {
    super.disconnectedCallback();
    if (this.userStateSub) {
      this.userStateSub.unsubscribe();
    }
    if (this.employeesSub) {
      this.employeesSub.unsubscribe();
    }
    if (this.eventsSub) {
      this.eventsSub.unsubscribe();
    }
  }

  render() {
    const now = new Date().toLocaleString();
    
    return html`
      <h2>
        <img src="https://lit.dev/images/logo.svg" width="40" height="40" style="vertical-align: middle; margin-right: 10px;">
        Web Components (Lit)
      </h2>
      <p><strong>Technology:</strong> Lit + Shadow DOM + Custom Elements</p>
      <p><strong>Features:</strong> Encapsulated styles, reusable components, framework agnostic</p>
      <p><strong>Mounted at:</strong> ${now}</p>
      
      <div class="counter-section">
        <button @click=${this._incrementCounter}>
          Click Count: ${this.count}
        </button>
        
        <button @click=${this._fetchData} ?disabled=${this.loading}>
          ${this.loading ? 'Loading...' : 'Fetch Data'}
        </button>
      </div>
      
      <div class="data-display">
        ${this.loading 
          ? html`<em>Loading data...</em>`
          : this.data 
            ? html`
                <strong>Fetched Data:</strong>
                <pre>${JSON.stringify(this.data, null, 2)}</pre>
              `
            : html`<em>Click "Fetch Data" to load content...</em>`
        }
      </div>
      
      <!-- Shared State Showcase -->
      <div class="shared-state-showcase">
        <h4 style="margin: 0 0 15px 0; color: white;">🔄 Shared State Management (Web Components)</h4>
        
        <div class="state-info">
          <strong>👤 User State:</strong><br>
          ${this.sharedUserState ? 
            html`✅ Logged in as: <strong>${this.sharedUserState.user?.username || 'Unknown'}</strong>` :
            html`❌ Not logged in`
          }
        </div>
        
        <div class="state-info">
          <strong>👥 Employee Data:</strong><br>
          📊 Count: <strong>${this.employees.length}</strong><br>
          👀 Preview: ${this.employees.length > 0 ? 
            this.employees.slice(0, 3).map(emp => emp.name).join(', ') + 
            (this.employees.length > 3 ? ` (+${this.employees.length - 3} more)` : '') :
            'No employees loaded'
          }
        </div>
        
        <div class="showcase-buttons">
          <button @click=${this._loadEmployees} class="showcase-btn load-btn">
            👥 Load Employees
          </button>
          <button @click=${this._broadcastMessage} class="showcase-btn broadcast-btn">
            📡 Broadcast from Web Components
          </button>
          <button @click=${this._clearEmployees} class="showcase-btn clear-btn">
            🗑️ Clear Data
          </button>
        </div>
        
        ${this.events.length > 0 ? html`
          <div class="events-info">
            <strong>📨 Recent Events:</strong><br>
            ${this.events.slice(-3).map(event => html`
              <div class="event-item">
                ${event.source}: ${event.data?.message || event.type}
              </div>
            `)}
          </div>
        ` : ''}
      </div>
      
      <div class="features">
        <strong>Web Components Features:</strong>
        <ul>
          <li>Shadow DOM Encapsulation</li>
          <li>Custom Elements API</li>
          <li>Lit Reactive Properties</li>
          <li>Scoped CSS Styles</li>
          <li>Framework Agnostic</li>
        </ul>
      </div>
    `;
  }

  _incrementCounter() {
    this.count++;
    if (window.stateManager) {
      window.stateManager.emit('webcomponents-counter', { count: this.count, app: 'WebComponents' });
    }
  }

  async _fetchData() {
    this.loading = true;
    
    try {
      // Simulate API call
      await new Promise(resolve => setTimeout(resolve, 1000));
      
      this.data = {
        timestamp: new Date().toISOString(),
        randomId: Math.random().toString(36).substr(2, 9),
        component: 'Web Component',
        technology: 'Lit + Shadow DOM',
        encapsulated: true
      };
    } catch (error) {
      this.data = { error: error.message };
    } finally {
      this.loading = false;
    }
  }

  _loadEmployees() {
    if (window.stateManager) {
      window.stateManager.loadEmployees();
    }
  }

  _broadcastMessage() {
    if (window.stateManager) {
      const event = {
        type: 'user-interaction',
        source: 'Web Components',
        timestamp: new Date().toISOString(),
        data: { message: 'Hello from Web Components!' }
      };
      window.stateManager.emit('cross-app-message', event);
    }
  }

  _clearEmployees() {
    if (window.stateManager) {
      window.stateManager.employees$.next([]);
    }
  }
}

// Register the custom element
customElements.define('micro-widget', MicroWidget);

// Single-SPA Integration
class WebComponentsApp {
  constructor() {
    this.container = null;
    this.widget = null;
  }

  mount(props) {
    return new Promise((resolve) => {
      this.container = document.getElementById('webcomponents-app');
      if (!this.container) {
        console.error('Mount point #webcomponents-app not found');
        return resolve();
      }

      // Create and append the web component
      this.widget = document.createElement('micro-widget');
      this.container.appendChild(this.widget);
      
      console.log('🧩 Web Components App mounted');
      resolve();
    });
  }

  unmount() {
    return new Promise((resolve) => {
      if (this.container && this.widget) {
        this.container.removeChild(this.widget);
        this.widget = null;
      }
      console.log('🧩 Web Components App unmounted');
      resolve();
    });
  }
}

// Single-SPA Lifecycle Functions
const webComponentsApp = new WebComponentsApp();

export const bootstrap = () => Promise.resolve();
export const mount = (props) => webComponentsApp.mount(props);
export const unmount = () => webComponentsApp.unmount();

export default {
  bootstrap,
  mount,
  unmount
};