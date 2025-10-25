const singleSpaAngularWebpack = require('single-spa-angular/lib/webpack').default

module.exports = (angularWebpackConfig, options) => {
  const singleSpaWebpackConfig = singleSpaAngularWebpack(angularWebpackConfig, options)

  // Override output filename and library name
  singleSpaWebpackConfig.output.filename = 'single-spa-angular-app.js'
  singleSpaWebpackConfig.output.library = 'singleSpaAngularApp'
  
  // Remove polyfills-es5 to avoid filename conflicts
  if (singleSpaWebpackConfig.entry && singleSpaWebpackConfig.entry['polyfills-es5']) {
    delete singleSpaWebpackConfig.entry['polyfills-es5']
  }

  return singleSpaWebpackConfig
}