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
      <button class="btn-success" @click="loadEmployees">
        Load Employees
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
      this.eventsSub = window.stateManager.events$.subscribe((event) => {
        // eslint-disable-next-line no-console
        console.log('💚 Vue received event:', event);
      });
    }
  },
  beforeDestroy() {
    if (this.userStateSub) {
      this.userStateSub.unsubscribe();
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
        window.stateManager.loadEmployees();
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
