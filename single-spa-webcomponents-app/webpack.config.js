const path = require('path');

module.exports = {
  entry: './src/single-spa-webcomponents-app.js',
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: 'single-spa-webcomponents-app.js',
    library: 'single-spa-webcomponents-app',
    libraryTarget: 'umd'
  },
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader',
          options: {
            presets: ['@babel/preset-env']
          }
        }
      }
    ]
  },
  devServer: {
    port: 4208,
    writeToDisk: true,
    headers: {
      'Access-Control-Allow-Origin': '*'
    }
  }
};