const singleSpaAngularWebpack = require('single-spa-angular/lib/webpack').default

module.exports = (angularWebpackConfig, options) => {
  const singleSpaWebpackConfig = singleSpaAngularWebpack(angularWebpackConfig, options)

  // Override output filename
  singleSpaWebpackConfig.output.filename = 'single-spa-angular-app.js'

  return singleSpaWebpackConfig
}