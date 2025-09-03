<template>
  <footer class="footer enhanced-footer">
    <div class="container">
      <div class="footer-content">
        <div class="footer-section">
          <h6 class="footer-title">
            <font-awesome-icon :icon="['fas', 'cube']" class="footer-icon" />
            Microfrontends Demo
          </h6>
          <p class="footer-description">
            Showcasing Single-SPA architecture with multiple frameworks
          </p>
        </div>
        <div class="footer-section">
          <h6 class="footer-title">Technologies</h6>
          <div class="tech-badges">
            <span class="tech-badge">Vue.js</span>
            <span class="tech-badge">React</span>
            <span class="tech-badge">Angular</span>
            <span class="tech-badge">TypeScript</span>
            <span class="tech-badge">Vanilla JS</span>
            <span class="tech-badge">Web Components</span>
            <span class="tech-badge">jQuery</span>
            <span class="tech-badge">Svelte</span>
          </div>
        </div>
        <div class="footer-section">
          <div class="copyright-section">
            <p class="copyright-text">
              Copyright © 2025
              <a href="https://github.com/CesarChaMal" target="_blank" id="personal-page-link">
                Cesar Francisco Chavez Maldonado
              </a>
            </p>
            <div class="social-links">
              <a href="https://github.com/CesarChaMal/demo-microfrontends" target="_blank" id="github-link" class="social-link">
                <font-awesome-icon :icon="['fab', 'github']" size="lg" />
                <span>View Source</span>
              </a>
            </div>
          </div>
        </div>
      </div>
    </div>
  </footer>
</template>

<script>
export default {
  name: 'Footer',
  props: {},
};
</script>

<style lang="scss" scoped>
.enhanced-footer {
  background: linear-gradient(135deg, #2c3e50 0%, #34495e 100%);
  position: absolute;
  bottom: 0;
  width: 100%;
  padding: 30px 0;
  min-height: 180px;
  border-top: 3px solid #4fc08d;

  @media screen and (min-width: 768px) {
    min-height: 140px;
  }

  .container {
    height: 100%;
  }

  .footer-content {
    display: flex;
    flex-direction: column;
    gap: 20px;
    color: #ecf0f1;

    @media screen and (min-width: 768px) {
      flex-direction: row;
      justify-content: space-between;
      align-items: flex-start;
      gap: 30px;
    }

    .footer-section {
      flex: 1;

      .footer-title {
        color: #4fc08d;
        font-size: 1rem;
        font-weight: 600;
        margin-bottom: 10px;
        display: flex;
        align-items: center;

        .footer-icon {
          margin-right: 8px;
        }
      }

      .footer-description {
        font-size: 0.9rem;
        color: #bdc3c7;
        margin-bottom: 0;
        line-height: 1.4;
      }

      .tech-badges {
        display: flex;
        flex-wrap: wrap;
        gap: 8px;

        .tech-badge {
          background: rgba(79, 192, 141, 0.2);
          color: #4fc08d;
          padding: 4px 10px;
          border-radius: 12px;
          font-size: 0.8rem;
          font-weight: 500;
          border: 1px solid rgba(79, 192, 141, 0.3);
        }
      }

      .copyright-section {
        text-align: center;

        @media screen and (min-width: 768px) {
          text-align: right;
        }

        .copyright-text {
          font-size: 0.9rem;
          margin-bottom: 10px;
          line-height: 1.5;

          a#personal-page-link {
            color: #4fc08d;
            text-decoration: none;
            font-weight: 500;

            &:hover {
              color: #42b883;
              text-decoration: underline;
            }
          }
        }

        .social-links {
          .social-link {
            display: inline-flex;
            align-items: center;
            color: #ecf0f1;
            text-decoration: none;
            background: rgba(255, 255, 255, 0.1);
            padding: 8px 12px;
            border-radius: 20px;
            transition: all 0.3s ease;

            &:hover {
              background: #4fc08d;
              color: white;
              transform: translateY(-2px);
            }

            span {
              margin-left: 8px;
              font-size: 0.9rem;
              font-weight: 500;
            }
          }
        }
      }
    }
  }
}
</style>
