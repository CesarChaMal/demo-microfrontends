const path = require('path');

module.exports = {
  entry: './src/single-spa-svelte-app.js',
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: 'single-spa-svelte-app.js',
    library: 'single-spa-svelte-app',
    libraryTarget: 'umd'
  },
  module: {
    rules: [
      {
        test: /\.svelte$/,
        use: {
          loader: 'svelte-loader',
          options: {
            emitCss: true,
            hotReload: true
          }
        }
      },
      {
        test: /\.css$/,
        use: ['style-loader', 'css-loader']
      }
    ]
  },
  resolve: {
    alias: {
      svelte: path.resolve('node_modules', 'svelte')
    },
    extensions: ['.mjs', '.js', '.svelte'],
    mainFields: ['svelte', 'browser', 'module', 'main']
  },
  devServer: {
    port: 4211,
    writeToDisk: true,
    headers: {
      'Access-Control-Allow-Origin': '*'
    }
  }
};