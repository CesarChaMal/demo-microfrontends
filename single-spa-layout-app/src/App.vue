<template>
  <div id="layout-app">
    <Header />
    <Navbar />
    <Footer />
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
  beforeCreate() {
    if (!sessionStorage.getItem('token')) {
      window.history.pushState(null, null, '/login');
    }

    document.querySelector('body').classList.add('mb');
  },
  destroyed() {
    document.querySelector('body').classList.remove('mb');
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
