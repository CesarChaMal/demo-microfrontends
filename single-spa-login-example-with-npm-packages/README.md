# single-spa-login-example-with-npm-packages

<img src="https://single-spa.js.org/img/logo-white-bgblue.svg" width="50" height="50">
[![npm version](https://img.shields.io/npm/v/single-spa-login-example-with-npm-packages.svg?style=flat-square)](https://www.npmjs.org/package/single-spa-login-example-with-npm-packages)

Single-spa application example which imports registered applications from NPM packages and manages authentication features such as login.

---

## ✍🏻 Motivation

This application is a [demo](https://single-spa-with-npm-packages.herokuapp.com/) showing how to use single-spa with [Option 2: NPM packages](https://single-spa.js.org/docs/separating-applications#option-2-npm-packages) for splitting code.

---

## ▶️ Demo

**Live Demo:** [https://single-spa-with-npm-packages.herokuapp.com](https://single-spa-with-npm-packages.herokuapp.com/)
**Login credentials:**

| User  | Password |
| ----- | -------- |
| admin | 12345    |

---

## ⚙️ Node.js Compatibility & Setup

This project uses **legacy tooling** (Angular v8, Webpack 4, etc.) and **requires Node.js v12.x**. **Do not** use Node 16+ or 18+.

**Recommended:**

* **Node.js:** v12.18.3
* **npm:** 6.x
* **nvm:** for Node version management

```bash
nvm install 12.18.3
nvm use 12.18.3
```

---

## 💻 Local Development & Production Flow

### Development Mode

Use this when you want to run everything locally with hot reload:

```bash
npm run bootstrap   # Install root + all sub-app dependencies
npm run serve       # Start root app + all MFEs concurrently
```

Open: [http://localhost:8080](http://localhost:8080)

### Production Build & Run

Use this to prepare the production build and run it locally:

```bash
npm run build   # Build root app into dist/
npm start       # Run Express server serving dist/
```

---

## 📜 NPM Scripts Overview

```json
"scripts": {
  "bootstrap": "npm install && npm run bootstrap:apps",
  "bootstrap:apps": "concurrently \"npm install --prefix ../single-spa-auth-app\" \"npm install --prefix ../single-spa-layout-app\" \"npm install --prefix ../single-spa-home-app\" \"npm install --prefix ../single-spa-angular-app\" \"npm install --prefix ../single-spa-vue-app\" \"npm install --prefix ../single-spa-react-app\"",
  "lint-all": "concurrently \"npm run lint --prefix ../single-spa-auth-app\" \"npm run lint --prefix ../single-spa-layout-app\" \"npm run lint --prefix ../single-spa-home-app\" \"npm run lint --prefix ../single-spa-angular-app\" \"npm run lint --prefix ../single-spa-vue-app\" \"npm run lint --prefix ../single-spa-react-app\"",
  "serve:apps": "concurrently -k -n \"AUTH,LAYOUT,HOME,ANG,VUE,REACT\" \"npm start --prefix ../single-spa-auth-app\" \"npm start --prefix ../single-spa-layout-app\" \"npm start --prefix ../single-spa-home-app\" \"npm run ng --prefix ../single-spa-angular-app -- serve --port 4204\" \"npm start --prefix ../single-spa-vue-app\" \"npm start --prefix ../single-spa-react-app\"",
  "serve:root": "webpack-dev-server --hot --port 8080",
  "serve": "concurrently -k -n \"ROOT,MFES\" \"npm run serve:root\" \"npm run serve:apps\"",
  "build": "webpack --config webpack.config.js -p",
  "start": "npm run build && node server.js",
  "heroku-postbuild": "npm run build",
  "lint": "eslint . --ext .js --fix",
  "test": "echo \"Error: no test specified\" && exit 1"
}
```

---

## 📦 Included Microfrontends

* [single-spa-auth-app](https://github.com/cesarchamal/single-spa-auth-app)
* [single-spa-layout-app](https://github.com/cesarchamal/single-spa-layout-app)
* [single-spa-home-app](https://github.com/cesarchamal/single-spa-home-app)
* [single-spa-angular-app](https://github.com/cesarchamal/single-spa-angular-app)
* [single-spa-vue-app](https://github.com/cesarchamal/single-spa-vue-app)
* [single-spa-react-app](https://github.com/cesarchamal/single-spa-react-app)

---

## 🛠 How it works

* **root-application.js:** Registers each MFE with single-spa lifecycle rules.
* **server.js:** Express server for production mode (Heroku-ready).
* **webpack.config.js:** Bundles root app, configures loaders & plugins.

---

## 📌 Notes

* Bootstrap & FontAwesome CSS are imported in **root-application.js** to avoid duplication.
* Login logic is hardcoded for demo purposes.
* `serve` script runs both the root and all microfrontends in parallel.
* Use `lint-all` to lint all MFEs at once.
* `bootstrap` script ensures dependencies for all MFEs are installed.
