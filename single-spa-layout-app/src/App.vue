<template>
  <div id="layout-app">
    <div v-if="isAuthenticated">
      <Header />
      <Navbar />
      <Footer />
    </div>
  </div>
</template>

<script>
import Header from './components/Header.vue';
import Navbar from './components/Navbar.vue';
import Footer from './components/Footer.vue';

export default {
  name: 'app',
  components: {
    Header,
    Navbar,
    Footer,
  },
  data() {
    return {
      isAuthenticated: false,
    };
  },
  mounted() {
    this.checkAuth();
    // Listen for authentication changes
    window.addEventListener('storage', this.checkAuth);
    window.addEventListener('popstate', this.checkAuth);
    // Listen for login events
    window.addEventListener('single-spa:routing-event', this.checkAuth);
  },
  beforeDestroy() {
    window.removeEventListener('storage', this.checkAuth);
    window.removeEventListener('popstate', this.checkAuth);
    window.removeEventListener('single-spa:routing-event', this.checkAuth);
    document.querySelector('body').classList.remove('mb');
  },
  methods: {
    checkAuth() {
      const token = sessionStorage.getItem('token');
      const isLoginPage = window.location.pathname === '/login';
      this.isAuthenticated = !!token && !isLoginPage;

      if (this.isAuthenticated) {
        document.querySelector('body').classList.add('mb');
      } else {
        document.querySelector('body').classList.remove('mb');
      }
    },
  },
};
</script>

<style lang="scss">
html {
  min-height: 100%;
  position: relative;
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
}

body {
  height: 100%;
  margin: 0;
  padding: 0;
  background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);

  &.mb {
    margin-bottom: 180px;

    @media screen and (min-width: 768px) {
      margin-bottom: 140px;
    }
  }
}

* {
  box-sizing: border-box;
}
</style>
