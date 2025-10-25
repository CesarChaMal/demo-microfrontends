const path = require('path');
const webpack = require('webpack');
const { CleanWebpackPlugin } = require('clean-webpack-plugin');

module.exports = {
  entry: ['./src/singleSpaEntry.js'],
  output: {
    library: 'singleSpaReactApp',
    libraryTarget: 'umd',
    filename: 'single-spa-react-app.js',
    path: path.resolve(__dirname, 'dist'),
    publicPath: 'http://localhost:4206/',
  },
  module: {
    rules: [
      // JS (drop eslint-loader to avoid the flowtype plugin warnings)
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: ['babel-loader'],
      },

      // HTML
      {
        test: /\.html$/i,
        use: ['html-loader'],
      },

      // Plain CSS -> NO sass-loader here
      {
        test: /\.css$/i,
        use: ['style-loader', 'css-loader'],
      },

      // SCSS/SASS -> use sass-loader with Dart Sass
      {
        test: /\.s[ac]ss$/i,
        use: [
          'style-loader',
          'css-loader',
          {
            loader: 'sass-loader',
            options: {
              implementation: require('sass'),
            },
          },
        ],
      },
    ],
  },
  node: {
    fs: 'empty',
  },
  resolve: {
    modules: [__dirname, 'node_modules'],
    extensions: ['.js', '.json'],
  },
  plugins: [
    new CleanWebpackPlugin({ cleanAfterEveryBuildPatterns: ['dist'] }),
    new webpack.optimize.LimitChunkCountPlugin({ maxChunks: 1 }),
  ],
  devtool: 'source-map',
  externals: [],
  devServer: {
    port: 4206,
    historyApiFallback: true,
    writeToDisk: true,
    headers: { 'Access-Control-Allow-Origin': '*' },
  },
};
