const path = require('path');

module.exports = {
  entry: './src/single-spa-vanilla-app.js',
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: 'single-spa-vanilla-app.js',
    library: 'single-spa-vanilla-app',
    libraryTarget: 'umd'
  },
  devServer: {
    port: 4207,
    writeToDisk: true,
    headers: {
      'Access-Control-Allow-Origin': '*'
    }
  }
};