<template>
  <div class="auth-page">
    <div class="container page">
      <div class="row">
        <div class="col-md-6 offset-md-3 col-xs-12">
          <div class="auth-header">
            <img src="https://vuejs.org/images/logo.png" alt="Vue.js" class="vue-logo" />
            <h1 class="text-xs-center">Vue.js Authentication</h1>
            <p class="subtitle">Secure login powered by Vue.js</p>
          </div>
          <div class="login-card">
            <form @submit.prevent="onSubmit(user, password)">
              <fieldset class="form-group">
                <label>Username</label>
                <input
                  class="form-control form-control-lg"
                  type="text"
                  v-model="user"
                  placeholder="Enter username (admin)"
                />
              </fieldset>
              <fieldset class="form-group">
                <label>Password</label>
                <input
                  class="form-control form-control-lg"
                  type="password"
                  v-model="password"
                  placeholder="Enter password (12345)"
                />
              </fieldset>
              <button class="btn btn-lg btn-success btn-block" type="submit">
                <font-awesome-icon :icon="['fas', 'sign-in-alt']" /> Sign In
              </button>
            </form>
            <div class="demo-credentials">
              <small class="text-muted">
                <font-awesome-icon :icon="['fas', 'info-circle']" />
                Demo credentials: admin / 12345
              </small>
            </div>
          </div>
        </div>
      </div>
      <div id="copyright-section" class="row">
        <div class="col-md-6 offset-md-3 col-xs-12">
          Copyright © 2025
          <a href="https://github.com/CesarChaMal" target="_blank">Cesar Francisco Chavez Maldonado</a>
          <a href="https://github.com/CesarChaMal/demo-microfrontends" target="_blank" id="github-link">
            <font-awesome-icon :icon="['fab', 'github']" size="2x" />
          </a>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'loginView',
  data() {
    return {
      user: '',
      password: '',
    };
  },
  methods: {
    onSubmit(user, password) {
      if (user === 'admin' && password === '12345') {
        const token = `vue-auth-token-${Date.now()}`;
        
        // Use global state manager if available
        if (window.stateManager) {
          window.stateManager.setUser({ username: user }, token);
          window.stateManager.emit('login-success', { username: user, timestamp: Date.now() });
        } else {
          sessionStorage.setItem('user', JSON.stringify({ username: user }));
          sessionStorage.setItem('token', token);
        }
        
        // eslint-disable-next-line no-alert
        alert('Login successful! Welcome to the microfrontend demo.');
        setTimeout(() => {
          window.history.pushState(null, null, '/');
        }, 1000);
      } else {
        // eslint-disable-next-line no-alert
        alert('Invalid credentials. Please use admin/12345');
      }
    },
  },
};
</script>

<style lang="scss" scoped>
.auth-page {
    height: 100vh;
    padding: 0;
    margin: 0;
    background: linear-gradient(135deg, #4fc08d 0%, #42b883 100%);
    display: flex;
    align-items: center;
    justify-content: center;
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;

    .container {
      .row {
        .auth-header {
          text-align: center;
          margin-bottom: 30px;

          .vue-logo {
            width: 80px;
            height: 80px;
            margin-bottom: 20px;
            filter: drop-shadow(0 4px 8px rgba(0,0,0,0.1));
          }

          h1 {
            color: white;
            font-weight: 300;
            margin-bottom: 10px;
            text-shadow: 0 2px 4px rgba(0,0,0,0.1);
          }

          .subtitle {
            color: rgba(255,255,255,0.9);
            font-size: 1.1rem;
            margin-bottom: 0;
          }
        }

        .login-card {
          background: white;
          border-radius: 12px;
          padding: 40px;
          box-shadow: 0 10px 30px rgba(0,0,0,0.1);

          form {
            .form-group {
              margin-bottom: 25px;

              label {
                font-weight: 600;
                color: #2c3e50;
                margin-bottom: 8px;
                display: block;
              }

              .form-control {
                border: 2px solid #e9ecef;
                border-radius: 8px;
                padding: 12px 16px;
                transition: all 0.3s ease;

                &:focus {
                  border-color: #4fc08d;
                  box-shadow: 0 0 0 0.2rem rgba(79, 192, 141, 0.25);
                }
              }
            }

            button {
              background: linear-gradient(135deg, #4fc08d 0%, #42b883 100%);
              border: none;
              border-radius: 8px;
              padding: 12px;
              font-weight: 600;
              transition: all 0.3s ease;
              margin-top: 10px;

              &:hover {
                transform: translateY(-2px);
                box-shadow: 0 5px 15px rgba(79, 192, 141, 0.4);
              }
            }
          }

          .demo-credentials {
            text-align: center;
            margin-top: 20px;
            padding-top: 20px;
            border-top: 1px solid #e9ecef;

            small {
              color: #6c757d;
            }
          }
        }

        &#copyright-section {
          margin-top: 30px;
          line-height: 32px;
          text-align: center;

          a {
            color: rgba(255,255,255,0.9);
            text-decoration: none;

            &:hover {
              color: white;
            }

            &#github-link {
              margin-left: 10px;
              vertical-align: middle;
            }
          }
        }
      }
    }
}
</style>
