<template>
  <div style="padding: 20px; border: 2px solid #4fc08d; border-radius: 8px; margin: 10px 0; background: #f8f9fa; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;">
    <h2 style="color: #4fc08d; margin: 0 0 15px 0;">
      <img src="https://vuejs.org/images/logo.png" width="40" height="40" style="vertical-align: middle; margin-right: 10px;">
      Vue.js Microfrontend
    </h2>
    <p><strong>Framework:</strong> Vue.js 2 with Vue Router</p>
    <p><strong>Features:</strong> Reactive data binding, component system, routing</p>
    <p><strong>Mounted at:</strong> {{ mountedAt }}</p>
    
    <div style="margin: 15px 0; padding: 15px; background: white; border-radius: 6px;">
      <h4 style="color: #495057; margin: 0 0 10px 0;">Reactive Counter</h4>
      <button 
        @click="increment"
        style="background: #4fc08d; color: white; border: none; padding: 8px 16px; border-radius: 4px; cursor: pointer; margin-right: 10px;"
      >
        Count: {{ count }}
      </button>
      <button 
        @click="reset"
        style="background: #6c757d; color: white; border: none; padding: 8px 16px; border-radius: 4px; cursor: pointer;"
      >
        Reset
      </button>
      <p style="margin: 10px 0 0 0; font-size: 0.9em; color: #6c757d;">Double: {{ doubleCount }}</p>
    </div>
    
    <div style="margin: 15px 0; padding: 15px; background: white; border-radius: 6px;">
      <h4 style="color: #495057; margin: 0 0 10px 0;">Navigation</h4>
      <nav style="margin-bottom: 15px;">
        <router-link 
          to="/" 
          style="margin-right: 15px; color: #4fc08d; text-decoration: none; padding: 5px 10px; border-radius: 4px;"
          active-class="active-link"
        >
          List
        </router-link>
        <router-link 
          to="/detail" 
          style="color: #4fc08d; text-decoration: none; padding: 5px 10px; border-radius: 4px;"
          active-class="active-link"
        >
          Detail
        </router-link>
      </nav>
      <router-view></router-view>
    </div>
    
    <div style="margin-top: 15px; font-size: 0.9em; color: #6c757d;">
      <strong>Vue.js Features:</strong>
      <ul style="margin: 5px 0; padding-left: 20px;">
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
      features: [
        'Reactive Data Binding',
        'Component-based Architecture',
        'Vue Router Integration',
        'Template Syntax',
        'Computed Properties'
      ]
    };
  },
  computed: {
    doubleCount() {
      return this.count * 2;
    }
  },
  methods: {
    increment() {
      this.count++;
    },
    reset() {
      this.count = 0;
    }
  },
  components: {},
};
</script>

<style lang="scss" scoped>
.active-link {
  background-color: #4fc08d !important;
  color: white !important;
}
</style>
