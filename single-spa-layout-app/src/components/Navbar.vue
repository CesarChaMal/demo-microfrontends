<template>
  <div id="navbar">
    <b-nav class="enhanced-nav">
      <b-nav-item href="/" v-on:click.prevent="navigateTo('/')" class="nav-item-enhanced home-item">
        <font-awesome-icon :icon="['fas', 'home']" class="nav-icon"/>
        <span class="nav-text">Home</span>
      </b-nav-item>
      <b-nav-item
        href="/angular"
        v-on:click.prevent="navigateTo('/angular')"
        class="nav-item-enhanced"
      >
        <img
          src="https://angular.io/assets/images/logos/angular/angular.svg"
          class="tech-icon"
          alt="Angular"
        />
        <span class="nav-text">Angular</span>
      </b-nav-item>
      <b-nav-item
        href="/vue"
        v-on:click.prevent="navigateTo('/vue')"
        class="nav-item-enhanced"
      >
        <img src="https://vuejs.org/images/logo.png" class="tech-icon" alt="Vue" />
        <span class="nav-text">Vue</span>
      </b-nav-item>
      <b-nav-item
        href="/react"
        v-on:click.prevent="navigateTo('/react')"
        class="nav-item-enhanced"
      >
        <img
          src="https://upload.wikimedia.org/wikipedia/commons/a/a7/React-icon.svg"
          class="tech-icon"
          alt="React"
        />
        <span class="nav-text">React</span>
      </b-nav-item>
      <b-nav-item
        href="/vanilla"
        v-on:click.prevent="navigateTo('/vanilla')"
        class="nav-item-enhanced"
      >
        <img
          src="https://upload.wikimedia.org/wikipedia/commons/6/6a/JavaScript-logo.png"
          class="tech-icon"
          alt="Vanilla JS"
        />
        <span class="nav-text">Vanilla</span>
      </b-nav-item>
      <b-nav-item
        href="/webcomponents"
        v-on:click.prevent="navigateTo('/webcomponents')"
        class="nav-item-enhanced"
      >
        <img
          src="https://www.webcomponents.org/assets/logo-192x192.png"
          class="tech-icon"
          alt="Web Components"
        />
        <span class="nav-text">Web Components</span>
      </b-nav-item>
      <b-nav-item
        href="/typescript"
        v-on:click.prevent="navigateTo('/typescript')"
        class="nav-item-enhanced"
      >
        <img
          src="https://upload.wikimedia.org/wikipedia/commons/4/4c/Typescript_logo_2020.svg"
          class="tech-icon"
          alt="TypeScript"
        />
        <span class="nav-text">TypeScript</span>
      </b-nav-item>
      <b-nav-item
        href="/jquery"
        v-on:click.prevent="navigateTo('/jquery')"
        class="nav-item-enhanced"
      >
        <img
          src="https://upload.wikimedia.org/wikipedia/commons/f/fd/JQuery-Logo.svg"
          class="tech-icon"
          alt="jQuery"
        />
        <span class="nav-text">jQuery</span>
      </b-nav-item>
      <b-nav-item
        href="/svelte"
        v-on:click.prevent="navigateTo('/svelte')"
        class="nav-item-enhanced"
      >
        <img
          src="https://upload.wikimedia.org/wikipedia/commons/1/1b/Svelte_Logo.svg"
          class="tech-icon"
          alt="Svelte"
        />
        <span class="nav-text">Svelte</span>
      </b-nav-item>
    </b-nav>
  </div>
</template>

<script>
export default {
  name: 'Navbar',
  props: {},
  methods: {
    navigateTo(url) {
      window.history.pushState(null, null, url);
    },
  },
};
</script>

<style lang="scss" scoped>
#navbar {
  .enhanced-nav {
    background: linear-gradient(90deg, #f8f9fa 0%, #e9ecef 100%) !important;
    border-bottom: 2px solid #4fc08d;
    padding: 8px 0;
    margin-top: 80px;
    box-shadow: 0 2px 5px rgba(0,0,0,0.05);
    display: flex;
    justify-content: center;
    flex-wrap: wrap;
    gap: 10px;

    .nav-item-enhanced {
      background: white;
      border: 2px solid #e9ecef;
      border-radius: 12px;
      margin: 5px;
      padding: 0;
      transition: all 0.3s ease;
      box-shadow: 0 2px 4px rgba(0,0,0,0.05);

      &:hover {
        transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(79, 192, 141, 0.2);
        border-color: #4fc08d;
      }

      &.home-item {
        background: linear-gradient(135deg, #4fc08d 0%, #42b883 100%);
        border-color: #42b883;

        .nav-link {
          color: white !important;
        }

        .nav-icon {
          color: white;
        }
      }

      .nav-link {
        display: flex;
        align-items: center;
        padding: 12px 16px !important;
        color: #495057 !important;
        text-decoration: none;
        font-weight: 500;

        &:hover {
          color: #4fc08d !important;
        }

        .tech-icon {
          width: 20px;
          height: 20px;
          margin-right: 8px;
          object-fit: contain;
        }

        .nav-icon {
          font-size: 18px;
          margin-right: 8px;
          color: #4fc08d;
        }

        .nav-text {
          font-size: 0.9rem;
          white-space: nowrap;
        }
      }
    }
  }
}

@media (max-width: 768px) {
  #navbar .enhanced-nav {
    .nav-item-enhanced .nav-link {
      padding: 10px 12px !important;

      .nav-text {
        font-size: 0.8rem;
      }

      .tech-icon {
        width: 16px;
        height: 16px;
      }
    }
  }
}
</style>
