const path = require('path');

module.exports = {
  entry: './src/single-spa-jquery-app.js',
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: 'single-spa-jquery-app.js',
    library: 'single-spa-jquery-app',
    libraryTarget: 'umd'
  },
  devServer: {
    port: 4210,
    writeToDisk: true,
    headers: {
      'Access-Control-Allow-Origin': '*'
    }
  }
};