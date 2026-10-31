const path = require('path');

module.exports = {
  entry: './src/single-spa-solid-app.js',
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: 'single-spa-solid-app.js',
    library: 'singleSpaSolidApp',
    libraryTarget: 'umd'
  },
  resolve: {
    extensions: ['.js', '.jsx'],
    // webpack 4 cannot read solid-js's `exports` map, so bare `solid-js` resolves
    // to the SERVER build and fails on `seroval-plugins`. Pin the browser dists.
    alias: {
      'solid-js/web': path.resolve(__dirname, 'node_modules/solid-js/web/dist/web.js'),
      'solid-js$': path.resolve(__dirname, 'node_modules/solid-js/dist/solid.js')
    }
  },
  module: {
    rules: [
      {
        test: /\.jsx?$/,
        // solid-js dists ship optional chaining, which webpack 4's parser cannot
        // read — route them through babel like our own sources (no JSX in them,
        // so babel-preset-solid is a no-op there).
        exclude: /node_modules\/(?!(solid-js)\/)/,
        use: {
          loader: 'babel-loader',
          options: {
            presets: ['babel-preset-solid', '@babel/preset-env']
          }
        }
      }
    ]
  },
  devServer: {
    port: 4212,
    writeToDisk: true,
    headers: {
      'Access-Control-Allow-Origin': '*'
    }
  }
};
