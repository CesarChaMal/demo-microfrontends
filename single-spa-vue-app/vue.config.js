const path = require('path');
const webpack = require('webpack');

module.exports = {
  devServer: {
	port: 4205,
    writeToDisk: true,
    headers: {
      'Access-Control-Allow-Origin': '*',
    },
	
  },
  configureWebpack: {
    output: {
      library: 'single-spa-vue-app',
      libraryTarget: 'umd',
      filename: 'single-spa-vue-app.js',
      path: path.resolve(__dirname, 'dist'),
    },
    plugins: [
      new webpack.optimize.LimitChunkCountPlugin({
        maxChunks: 1,
      }),
    ],
    externals: {
      'vue': 'Vue',
      'single-spa-vue': 'singleSpaVue',
      'bootstrap-vue': 'BootstrapVue',
      'vue-router': 'VueRouter'
    },
  },
};
