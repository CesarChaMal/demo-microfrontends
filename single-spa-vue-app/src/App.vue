<template>
  <div class="vue-app-container">
    <h2 style="color: #4fc08d; margin: 0 0 15px 0;">
      <img src="https://vuejs.org/images/logo.png" width="40" height="40" style="vertical-align: middle; margin-right: 10px;">
      Vue.js Microfrontend
    </h2>
    <p><strong>Framework:</strong> Vue.js 2 with Vue Router</p>
    <p><strong>Features:</strong> Reactive data binding, component system, routing</p>
    <p><strong>Mounted at:</strong> {{ mountedAt }}</p>

    <div class="counter-section">
      <h4>Reactive Counter</h4>
      <button class="btn-primary" @click="increment">
        Count: {{ count }}
      </button>
      <button class="btn-secondary" @click="reset">
        Reset
      </button>

      <p class="counter-info">Double: {{ doubleCount }}</p>
    </div>

    <div class="navigation-section">
      <h4>Navigation</h4>
      <nav class="nav-links">
        <router-link to="/" class="nav-link" active-class="active-link">
          List
        </router-link>
        <router-link to="/detail" class="nav-link" active-class="active-link">
          Detail
        </router-link>
      </nav>
      <router-view></router-view>
    </div>

    <!-- Shared State Showcase -->
    <div class="shared-state-showcase">
      <h4>🔄 Shared State Management (Vue)</h4>

      <div class="state-info">
        <strong>👤 User State:</strong><br>
        <span v-if="userState">
          ✅ Logged in as: <strong>{{ userState.user?.username || 'Unknown' }}</strong>
        </span>
        <span v-else>❌ Not logged in</span>
      </div>

      <div class="state-info">
        <strong>👥 Employee Data:</strong><br>
        📊 Count: <strong>{{ employees.length }}</strong><br>
        👀 Preview:
        <span v-if="employees.length > 0">
          {{ employees.slice(0, 3).map(emp => emp.name).join(', ') }}
          <span v-if="employees.length > 3">(+{{ employees.length - 3 }} more)</span>
        </span>
        <span v-else>No employees loaded</span>
      </div>

      <div class="showcase-buttons">
        <button class="btn-employees" @click="loadEmployees">
          👥 Load Employees
        </button>
        <button class="btn-broadcast" @click="broadcastMessage">
          📡 Broadcast from Vue
        </button>
        <button class="btn-clear" @click="clearEmployees">
          🗑️ Clear Data
        </button>
      </div>

      <div v-if="events.length > 0" class="events-info">
        <strong>📨 Recent Events:</strong><br>
        <div v-for="(event, i) in events.slice(-3)" :key="i" class="event-item">
          {{ event.event }}: {{ event.data?.message || event.data?.source || 'Event triggered' }}
        </div>
      </div>
      <div v-else class="events-info">
        <strong>📨 Recent Events:</strong><br>
        <span class="no-events">No recent events</span>
      </div>
    </div>

    <div class="features-section">
      <strong>Vue.js Features:</strong>
      <ul>
        <li v-for="feature in features" :key="feature">{{ feature }}</li>
      </ul>
    </div>
  </div>
</template>

<script>
export default {
  name: 'app',
  data() {
    return {
      count: 0,
      mountedAt: new Date().toLocaleString(),
      userState: null,
      employees: [],
      events: [],
      features: [
        'Reactive Data Binding',
        'Component-based Architecture',
        'Vue Router Integration',
        'Template Syntax',
        'Computed Properties',
      ],
    };
  },
  computed: {
    doubleCount() {
      return this.count * 2;
    },
  },
  mounted() {
    if (window.stateManager) {
      this.userStateSub = window.stateManager.userState$.subscribe((state) => {
        this.userState = state;
      });
      this.employeesSub = window.stateManager.employees$.subscribe((employees) => {
        this.employees = employees;
      });
      this.eventsSub = window.stateManager.events$.subscribe((event) => {
        // eslint-disable-next-line no-console
        console.log('💚 Vue received event:', event);
        this.events = [...this.events.slice(-4), event]; // Keep last 5 events
      });

      this.employeesSub = window.stateManager.employees$.subscribe((employees) => {
        // eslint-disable-next-line no-console
        console.log('💚 Vue received employees update:', employees);
        this.employees = employees;
      });
    }
  },
  beforeDestroy() {
    if (this.userStateSub) {
      this.userStateSub.unsubscribe();
    }
    if (this.employeesSub) {
      this.employeesSub.unsubscribe();
    }
    if (this.eventsSub) {
      this.eventsSub.unsubscribe();
    }
  },
  methods: {
    increment() {
      this.count += 1;
      if (window.stateManager) {
        window.stateManager.emit('vue-counter', { count: this.count, app: 'Vue' });
      }
    },
    reset() {
      this.count = 0;
    },
    loadEmployees() {
      if (window.stateManager) {
        // eslint-disable-next-line no-console
        console.log('💚 Vue: Loading employees...');
        window.stateManager.loadEmployees().then(() => {
          // eslint-disable-next-line no-console
          console.log('💚 Vue: Employees loaded, current count:', this.employees.length);
        });
      }
    },
    broadcastMessage() {
      if (window.stateManager) {
        const event = {
          type: 'cross-app-message',
          source: 'Vue',
          timestamp: new Date().toISOString(),
          data: { message: 'Hello from Vue!' },
        };
        window.stateManager.emit('cross-app-message', event);
        // eslint-disable-next-line no-console
        console.log('📡 Vue broadcasted message:', event);
      }
    },
    clearEmployees() {
      if (window.stateManager) {
        window.stateManager.employees$.next([]);
      }
    },
  },
  components: {},
};
</script>

<style lang="scss" scoped>
.vue-app-container {
  padding: 20px;
  border: 2px solid #4fc08d;
  border-radius: 8px;
  margin: 10px 0;
  background: #f8f9fa;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
}

.counter-section, .navigation-section {
  margin: 15px 0;
  padding: 15px;
  background: white;
  border-radius: 6px;

  h4 {
    color: #495057;
    margin: 0 0 10px 0;
  }
}

.btn-primary {
  background: #4fc08d;
  color: white;
  border: none;
  padding: 8px 16px;
  border-radius: 4px;
  cursor: pointer;
  margin-right: 10px;
}

.btn-secondary {
  background: #6c757d;
  color: white;
  border: none;
  padding: 8px 16px;
  border-radius: 4px;
  cursor: pointer;
}

.btn-success {
  background: #28a745;
  color: white;
  border: none;
  padding: 8px 16px;
  border-radius: 4px;
  cursor: pointer;
  margin-left: 10px;
}

.counter-info {
  margin: 10px 0 0 0;
  font-size: 0.9em;
  color: #6c757d;
}

.nav-links {
  margin-bottom: 15px;
}

.nav-link {
  margin-right: 15px;
  color: #4fc08d;
  text-decoration: none;
  padding: 5px 10px;
  border-radius: 4px;
}

.active-link {
  background-color: #4fc08d !important;
  color: white !important;
}

.shared-state-showcase {
  margin: 15px 0;
  padding: 15px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 8px;
  color: white;

  h4 {
    margin: 0 0 15px 0;
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

  .btn-employees {
    background: #28a745;
    color: white;
    border: none;
    padding: 8px 12px;
    border-radius: 4px;
    cursor: pointer;
    font-size: 12px;
  }

  .btn-broadcast {
    background: #007bff;
    color: white;
    border: none;
    padding: 8px 12px;
    border-radius: 4px;
    cursor: pointer;
    font-size: 12px;
  }

  .btn-clear {
    background: #dc3545;
    color: white;
    border: none;
    padding: 8px 12px;
    border-radius: 4px;
    cursor: pointer;
    font-size: 12px;
  }

  .events-info {
    background: rgba(255,255,255,0.1);
    padding: 10px;
    border-radius: 6px;
    font-size: 12px;

    .event-item {
      margin-top: 5px;
    }
  }
}

.features-section {
  margin-top: 15px;
  font-size: 0.9em;
  color: #6c757d;

  ul {
    margin: 5px 0;
    padding-left: 20px;
  }
}
</style>
