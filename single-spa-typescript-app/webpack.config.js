const path = require('path');

module.exports = {
  entry: './src/single-spa-typescript-app.ts',
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: 'single-spa-typescript-app.js',
    library: 'singleSpaTypescriptApp',
    libraryTarget: 'umd'
  },
  module: {
    rules: [
      {
        test: /\.ts$/,
        use: 'ts-loader',
        exclude: /node_modules/
      }
    ]
  },
  resolve: {
    extensions: ['.ts', '.js']
  },
  devServer: {
    port: 4209,
    writeToDisk: true,
    headers: {
      'Access-Control-Allow-Origin': '*'
    }
  }
};