const path = require('path');
const webpack = require('webpack');

module.exports = {
  devServer: {
    port: 4202,
    writeToDisk: true,
    headers: {
      'Access-Control-Allow-Origin': '*',
    },
  },
  configureWebpack: {
    output: {
      library: 'singleSpaLayoutApp',
      libraryTarget: 'umd',
      filename: 'single-spa-layout-app.js',
      path: path.resolve(__dirname, 'dist'),
    },
    plugins: [
      new webpack.optimize.LimitChunkCountPlugin({
        maxChunks: 1,
      }),
    ],
    externals: {
      vue: 'Vue',
      'vue-router': 'VueRouter',
      'single-spa-vue': 'singleSpaVue',
      'bootstrap-vue': 'BootstrapVue',
    },
  },
};
