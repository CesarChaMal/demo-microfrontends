# single-spa-vue-app

A Vue.js 2 microfrontend for Single-SPA demonstrating progressive framework features, reactive data binding, and component-based architecture.

## Features

- **Vue.js 2**: Progressive JavaScript framework
- **Vue Router**: Client-side routing with navigation guards
- **Vuex**: Centralized state management (optional)
- **Single File Components**: Template, script, and style in one file
- **Reactive Data Binding**: Automatic UI updates
- **Component Composition**: Reusable and composable components

## Technology Stack

- **Framework**: Vue.js 2.6.11
- **Router**: Vue Router 3.1.4
- **Build Tool**: Vue CLI 4 with library target
- **Language**: JavaScript (ES2015+)
- **Integration**: Single-SPA Vue adapter

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
# Runs on http://localhost:4205
```

### Build

```bash
npm run build
# Outputs to dist/single-spa-vue-app.umd.js
```

## Vue.js Features

### Single File Components
```vue
<template>
  <div class="feature-component">
    <h2>{{ title }}</h2>
    <button @click="handleClick">{{ buttonText }}</button>
  </div>
</template>

<script>
export default {
  name: 'FeatureComponent',
  data() {
    return {
      title: 'Vue Feature',
      buttonText: 'Click Me'
    };
  },
  methods: {
    handleClick() {
      this.$emit('feature-clicked');
    }
  }
};
</script>

<style scoped>
.feature-component {
  padding: 20px;
}
</style>
```

### Reactive Data System
```javascript
export default {
  data() {
    return {
      message: 'Hello Vue!',
      items: []
    };
  },
  computed: {
    filteredItems() {
      return this.items.filter(item => item.active);
    }
  },
  watch: {
    message(newVal, oldVal) {
      console.log(`Message changed from ${oldVal} to ${newVal}`);
    }
  }
};
```

### Component Communication
```javascript
// Parent to Child (Props)
<child-component :data="parentData" />

// Child to Parent (Events)
this.$emit('update-data', newData);

// Sibling Communication (Event Bus)
this.$bus.$emit('global-event', data);
```

## Single-SPA Integration

This microfrontend exports the required Single-SPA lifecycle functions:

```javascript
export const bootstrap = vueLifecycles.bootstrap;
export const mount = vueLifecycles.mount;
export const unmount = vueLifecycles.unmount;
```

### Mount Point

The application mounts to the DOM element with ID `vue-app`:

```html
<div id="vue-app"></div>
```

### Route Configuration

Configured to activate on routes starting with `/vue`:

```javascript
singleSpa.registerApplication(
  'vue',
  () => loadApp('single-spa-vue-app'),
  showWhenPrefix(['/vue'])
);
```

### Vue Router Integration
```javascript
export default new Router({
  mode: 'history',
  base: '/vue',
  routes: [
    { path: '/', component: Home },
    { path: '/about', component: About },
    { path: '/contact', component: Contact }
  ]
});
```

## Vue Configuration

### External Dependencies
The application uses webpack externals for shared dependencies:

```javascript
config.externals([
  'vue',
  'vue-router',
  'single-spa-vue'
]);
```

### Library Build
Built as UMD library for Single-SPA consumption:

```javascript
configureWebpack: {
  output: {
    library: 'single-spa-vue-app',
    libraryTarget: 'umd',
    filename: 'single-spa-vue-app.js'
  }
}
```

## Component Architecture

### Page Components
```vue
<!-- Home.vue -->
<template>
  <div class="home-page">
    <hero-section />
    <feature-list :features="features" />
    <call-to-action @action-clicked="handleAction" />
  </div>
</template>

<script>
import HeroSection from '@/components/HeroSection.vue';
import FeatureList from '@/components/FeatureList.vue';
import CallToAction from '@/components/CallToAction.vue';

export default {
  name: 'Home',
  components: {
    HeroSection,
    FeatureList,
    CallToAction
  },
  data() {
    return {
      features: []
    };
  },
  async created() {
    this.features = await this.fetchFeatures();
  }
};
</script>
```

### Reusable Components
```vue
<!-- FeatureCard.vue -->
<template>
  <div class="feature-card" :class="{ active: isActive }">
    <slot name="icon"></slot>
    <h3>{{ title }}</h3>
    <p>{{ description }}</p>
    <button @click="$emit('select', feature)">
      Select Feature
    </button>
  </div>
</template>

<script>
export default {
  name: 'FeatureCard',
  props: {
    feature: {
      type: Object,
      required: true
    },
    isActive: {
      type: Boolean,
      default: false
    }
  },
  computed: {
    title() {
      return this.feature.title;
    },
    description() {
      return this.feature.description;
    }
  }
};
</script>
```

## State Management

### Component State
```javascript
export default {
  data() {
    return {
      loading: false,
      error: null,
      data: []
    };
  },
  methods: {
    async fetchData() {
      this.loading = true;
      this.error = null;
      
      try {
        const response = await fetch('/api/data');
        this.data = await response.json();
      } catch (error) {
        this.error = error.message;
      } finally {
        this.loading = false;
      }
    }
  }
};
```

### Vuex Integration (Optional)
```javascript
// store/index.js
export default new Vuex.Store({
  state: {
    user: null,
    preferences: {}
  },
  mutations: {
    SET_USER(state, user) {
      state.user = user;
    }
  },
  actions: {
    async fetchUser({ commit }) {
      const user = await api.getUser();
      commit('SET_USER', user);
    }
  }
});
```

## File Structure

```
single-spa-vue-app/
├── src/
│   ├── components/          # Reusable components
│   ├── views/              # Page components
│   ├── router/             # Vue Router configuration
│   │   └── index.js        # Router setup
│   ├── store/              # Vuex store (optional)
│   ├── assets/             # Static assets
│   ├── App.vue             # Root component
│   └── singleSpaEntry.js   # Single-SPA integration
├── dist/                   # Build output directory
├── package.json            # Dependencies and scripts
├── vue.config.js          # Vue CLI configuration
├── .gitignore             # Git ignore rules
└── README.md              # This file
```

## Vue CLI Configuration

### Library Build Setup
```javascript
// vue.config.js
module.exports = {
  configureWebpack: {
    output: {
      library: 'single-spa-vue-app',
      libraryTarget: 'umd'
    },
    plugins: [
      new webpack.optimize.LimitChunkCountPlugin({
        maxChunks: 1
      })
    ]
  },
  chainWebpack: config => {
    config.externals(['vue', 'vue-router', 'single-spa-vue']);
  }
};
```

### Development Configuration
- Hot module replacement
- Source maps
- ESLint integration
- SCSS preprocessing

## Styling Architecture

### Scoped Styles
```vue
<style scoped>
.component {
  /* Styles scoped to this component */
}
</style>
```

### Global Styles
```vue
<style>
/* Global styles */
.utility-class {
  margin: 0;
}
</style>
```

### CSS Modules
```vue
<style module>
.title {
  font-size: 2rem;
}
</style>

<template>
  <h1 :class="$style.title">Title</h1>
</template>
```

## Performance Optimization

- **Bundle Size**: ~235KB (UMD build)
- **Tree Shaking**: Unused code elimination
- **Lazy Loading**: Route-based code splitting
- **Component Caching**: Keep-alive optimization

## Vue Devtools

### Development Features
- Component inspector
- Vuex state management
- Event timeline
- Performance profiling

### Production Debugging
- Component hierarchy
- Props and data inspection
- Event tracking
- Time-travel debugging

## Testing

### Unit Tests
```bash
npm run test:unit
```

### Component Tests
```bash
npm run test:components
```

### E2E Tests
```bash
npm run test:e2e
```

### Linting
```bash
npm run lint
```

## Browser Support

- Modern browsers (ES2015+)
- IE9+ with polyfills
- Mobile browsers
- Progressive enhancement

## Migration Path

### Vue 2 to Vue 3
- Composition API preparation
- Breaking changes assessment
- Gradual migration strategy
- Compatibility considerations

## Contributing

1. Fork the repository
2. Create a feature branch
3. Follow Vue.js style guide
4. Add tests for new components
5. Ensure accessibility compliance
6. Submit a pull request

## License

MIT License - see LICENSE file for details.

## Related Projects

- [Vue.js](https://vuejs.org/) - Progressive JavaScript framework
- [Vue Router](https://router.vuejs.org/) - Official router for Vue.js
- [Vuex](https://vuex.vuejs.org/) - State management pattern + library
- [Single-SPA](https://single-spa.js.org/) - Microfrontend framework
- [Demo Microfrontends](../README.md) - Complete microfrontend demo

## Author

Demo Team - Vue.js 2 Microfrontend Example