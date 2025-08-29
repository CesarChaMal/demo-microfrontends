const path = require('path');

module.exports = {
  entry: './src/single-spa-vanilla-app.js',
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: 'single-spa-vanilla-app.js',
    library: 'single-spa-vanilla-app',
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
            presets: ['@babel/preset-env'],
            plugins: ['@babel/plugin-proposal-optional-chaining']
          }
        }
      }
    ]
  },
  devServer: {
    port: 4207,
    writeToDisk: true,
    headers: {
      'Access-Control-Allow-Origin': '*'
    }
  }
};