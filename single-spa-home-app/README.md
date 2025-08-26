<p float="left">
  <img src="https://single-spa.js.org/img/logo-white-bgblue.svg" width="50" height="50">
  <img src="https://angularjs.org/img/ng-logo.png" width="50" height="50">
</p>

[![npm version](https://img.shields.io/npm/v/single-spa-home-app.svg?style=flat-square)](https://www.npmjs.org/package/single-spa-home-app)

# single-spa-home-app

This is an AngularJS application example used as NPM package in [single-spa-login-example-with-npm-packages](https://github.com/cesarchamal/single-spa-login-example-with-npm-packages) in order to register an application. See the installation instructions there.

## ✍🏻 Motivation

This is an AngularJS application with a home view for embbed the app inside a root single-spa application.

## How it works ❓

There are several files for the right working of this application and they are:

- src/routes.js
- src/singleSpaEntry.js
- package.json
- webpack.config.js

### src/routes.js

```javascript
import angular from 'angular';
import './components/home.component';

angular.module('home-app')
  .config(['$stateProvider', '$locationProvider', ($stateProvider, $locationProvider) => {
    $locationProvider.html5Mode({
      enabled: true,
      requireBase: false,
    });

    $stateProvider.state('home', {
      url: '/',
      template: '<home-component />',
    });
  }]);
```

As this application will be mounted when browser url is **/**, we need to enable **html5 mode** into **$locationProvider**.

### src/singleSpaEntry.js

```javascript
import singleSpaAngularJS from 'single-spa-angularjs';
import angular from 'angular';

import app from './app.component.html';

import './app.module';
import './routes';

const domElementGetter = () => document.getElementById('home-app');

const ngLifecycles = singleSpaAngularJS({
  angular,
  domElementGetter,
  mainAngularModule: 'home-app',
  uiRouter: true,
  preserveGlobal: false,
  template: app,
});

export const { bootstrap } = ngLifecycles;
export const { mount } = ngLifecycles;
export const { unmount } = ngLifecycles;
```

The **ngLifecycles** object contains all **single-spa-angularjs** methods for the **single-spa** lifecycle of this app. All used config is default one but the custom config of the **domElementGetter** option. It's assumed that an element with **home-app** id is defined in the **index.html** where this application will be mounted.

### package.json

```json
{
  "name": "single-spa-home-app",
  "version": "0.1.4",
  "description": "AngularJS application with home page for be included in a single-spa application as registered app.",
  "main": "dist/single-spa-home-app.js",
  "scripts": {
    "build": "webpack --config webpack.config.js -p",
    "lint": "eslint . --ext .js --fix"
  },
  "repository": {
    "type": "git",
    "url": "git+https://github.com/jualoppaz/single-spa-home-app.git"
  },
  "author": "Juan Manuel López Pazos",
  "license": "MIT",
  "bugs": {
    "url": "https://github.com/jualoppaz/single-spa-home-app/issues"
  },
  "homepage": "https://github.com/jualoppaz/single-spa-home-app#readme",
  "dependencies": {
    "angular": "1.8.0",
    "angular-ui-router": "1.0.25",
    "single-spa-angularjs": "3.1.0"
  },
  "devDependencies": {
    "@babel/core": "7.8.4",
    "babel-eslint": "10.0.3",
    "babel-loader": "8.0.6",
    "clean-webpack-plugin": "3.0.0",
    "copy-webpack-plugin": "5.1.1",
    "eslint": "6.8.0",
    "eslint-config-airbnb-base": "14.0.0",
    "eslint-loader": "3.0.3",
    "eslint-plugin-import": "2.20.1",
    "html-loader": "0.5.5",
    "html-webpack-plugin": "3.2.0",
    "webpack": "4.41.5",
    "webpack-cli": "3.3.10",
    "webpack-dev-server": "3.11.0"
  },
  "keywords": [
    "single-spa",
    "angularjs",
    "npm",
    "webpack"
  ]
}
```

There are only two scripts in this project:

- **build**: for compile the application and build it as a **libray** in **umd** format
- **lint**: for run **eslint** in all project

### webpack.config.js

```javascript
const path = require('path');
const webpack = require('webpack');
const { CleanWebpackPlugin } = require('clean-webpack-plugin');

module.exports = {
  entry: ['src/singleSpaEntry.js'],
  output: {
    library: 'single-spa-home-app',
    libraryTarget: 'umd',
    filename: 'single-spa-home-app.js',
    path: path.resolve(__dirname, 'dist'),
  },
  module: {
    rules: [
      {
        test: /\.js?$/,
        exclude: [path.resolve(__dirname, 'node_modules')],
        loader: ['babel-loader', 'eslint-loader'],
      },
      {
        test: /\.html$/i,
        loader: 'html-loader',
      },
    ],
  },
  node: {
    fs: 'empty',
  },
  resolve: {
    modules: [__dirname, 'node_modules'],
  },
  plugins: [
    new CleanWebpackPlugin({
      cleanAfterEveryBuildPatterns: ['dist'],
    }),
    new webpack.optimize.LimitChunkCountPlugin({
      maxChunks: 1,
    }),
  ],
  devtool: 'source-map',
  externals: [],
  devServer: {
    historyApiFallback: true,
    writeToDisk: true,
  },
};
```

The needed options for the right build of the application as library are defined in the **output** field.\
The **LimitChunkCountPlugin** is used for disable chunks for build process. It's not necessary but I prefer keep whole application in one chunk as it will be embedded in another one.
