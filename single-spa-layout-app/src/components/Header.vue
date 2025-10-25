<template>
  <div id="header" class="clearfix">
    <b-navbar type="light" variant="light" fixed="top" class="enhanced-navbar fixed-top">
      <b-navbar-brand class="brand-section">
        <a href="https://single-spa.js.org" target="_blank" class="brand-link">
          <img id="logo" src="../assets/logo.svg" />
          <span class="brand-text">Single-SPA Demo</span>
        </a>
        <span class="demo-badge">Microfrontends</span>
      </b-navbar-brand>

      <b-navbar-nav class="ml-auto">
        <b-nav-item class="user-info">
          <font-awesome-icon :icon="['fas', 'user-circle']" class="user-icon" />
          <span v-if="recentEvents.length > 0" class="event-badge">{{ recentEvents.length }}</span>
        </b-nav-item>
        <b-nav-item-dropdown right class="user-dropdown">
          <template v-slot:button-content>
            <span class="username">{{ username }}</span>
          </template>
          <b-dropdown-item v-on:click="logout" class="logout-item">
            <font-awesome-icon :icon="['fas', 'sign-out-alt']" /> Sign Out
          </b-dropdown-item>
        </b-nav-item-dropdown>
      </b-navbar-nav>
    </b-navbar>
  </div>
</template>

<script>
export default {
  name: 'Header',
  data() {
    return {
      userState: null,
      recentEvents: [],
    };
  },
  mounted() {
    if (window.stateManager) {
      this.userStateSub = window.stateManager.userState$.subscribe((state) => {
        this.userState = state;
      });
      this.eventsSub = window.stateManager.events$.subscribe((event) => {
        // eslint-disable-next-line no-console
        console.log('🎨 Layout received event:', event);
        // Store recent events for display
        this.recentEvents = [...(this.recentEvents || []).slice(-4), event];
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
  props: {},
  methods: {
    logout() {
      if (window.stateManager) {
        window.stateManager.logout();
        window.stateManager.emit('logout', { timestamp: Date.now() });
      } else {
        sessionStorage.removeItem('user');
        sessionStorage.removeItem('token');
      }
      window.history.pushState(null, null, '/login');
    },
  },
  computed: {
    username() {
      return this.userState?.user?.username || '';
    },
  },
};
</script>

<style lang="scss" scoped>
#header {
  .enhanced-navbar {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%) !important;
    border-bottom: 3px solid #4fc08d;
    box-shadow: 0 2px 10px rgba(0,0,0,0.1);
    padding: 0.75rem 1rem;

    .brand-section {
      display: flex;
      align-items: center;

      .brand-link {
        display: flex;
        align-items: center;
        text-decoration: none;
        color: white !important;
        margin-right: 15px;

        &:hover {
          color: #4fc08d !important;
          text-decoration: none;
        }

        img#logo {
          width: 45px;
          height: 45px;
          margin-right: 10px;
          filter: brightness(1.1);
        }

        .brand-text {
          font-weight: 600;
          font-size: 1.3rem;
        }
      }

      .demo-badge {
        background: #4fc08d;
        color: white;
        padding: 4px 12px;
        border-radius: 20px;
        font-size: 0.8rem;
        font-weight: 500;
        text-transform: uppercase;
        letter-spacing: 0.5px;
      }
    }

    .navbar-nav {
      .user-info {
        .user-icon {
          color: white;
          font-size: 1.5rem;
          margin-right: 10px;
        }
      }

      .user-dropdown {
        .dropdown-toggle {
          background: rgba(255,255,255,0.1) !important;
          border: 1px solid rgba(255,255,255,0.2) !important;
          border-radius: 25px !important;
          padding: 8px 16px !important;

          .username {
            color: white;
            font-weight: 500;
          }

          &:hover {
            background: rgba(255,255,255,0.2) !important;
            transform: translateY(-1px);
          }
        }

        .logout-item {
          color: #dc3545;
          font-weight: 500;

          &:hover {
            background-color: #dc3545;
            color: white;
          }
        }
      }
    }
  }
}
</style>
