# single-spa-webcomponents-app

A Web Components microfrontend using Lit for Single-SPA, demonstrating browser-native standards and component encapsulation.

## Features

- **Lit Framework**: Modern Web Components library with reactive properties
- **Shadow DOM**: Complete style and markup encapsulation
- **Custom Elements**: Browser-native component registration
- **Framework Agnostic**: Works with any framework or vanilla JavaScript
- **Reusable Components**: Can be used across different applications

## Technology Stack

- **Framework**: Lit 2.8.0
- **Standards**: Web Components (Custom Elements, Shadow DOM)
- **Build Tool**: Webpack 4
- **Language**: Modern JavaScript (ES2020+)
- **Integration**: Single-SPA lifecycle

## Development

### Prerequisites

- Node.js (v18.0.0 or higher)
- npm (v8.0.0 or higher)

### Installation

```bash
npm install
```

### Development Server

```bash
npm start
# Runs on http://localhost:4208
```

### Build

```bash
npm run build
# Outputs to dist/single-spa-webcomponents-app.js
```

## Web Components Features

### Custom Elements
- Registered as `<micro-widget>` custom element
- Can be used in any HTML context
- Lifecycle callbacks (connectedCallback, disconnectedCallback)

### Shadow DOM Encapsulation
- Scoped CSS styles that don't leak
- Isolated DOM tree
- Protected from external style interference

### Reactive Properties
- Lit reactive properties with automatic re-rendering
- Type-safe property definitions
- Efficient change detection

## Single-SPA Integration

This microfrontend exports the required Single-SPA lifecycle functions:

```javascript
export const bootstrap = () => Promise.resolve();
export const mount = (props) => webComponentsApp.mount(props);
export const unmount = () => webComponentsApp.unmount();
```

### Mount Point

The application mounts to the DOM element with ID `webcomponents-app`:

```html
<div id="webcomponents-app"></div>
```

### Route Configuration

Configured to activate on routes starting with `/webcomponents`:

```javascript
singleSpa.registerApplication(
  'webcomponents',
  () => loadApp('single-spa-webcomponents-app'),
  showWhenPrefix(['/webcomponents'])
);
```

## Component Usage

The Web Component can be used independently:

```html
<!-- Direct usage in HTML -->
<micro-widget></micro-widget>

<!-- Programmatic creation -->
<script>
  const widget = document.createElement('micro-widget');
  document.body.appendChild(widget);
</script>
```

## Browser Support

- Chrome 54+, Firefox 63+, Safari 10.1+, Edge 79+
- Requires native Custom Elements and Shadow DOM support
- Polyfills available for older browsers

## Performance

- **Bundle Size**: ~15KB (including Lit)
- **Runtime**: Efficient reactive updates
- **Memory**: Low overhead with native APIs
- **Encapsulation**: No style conflicts

## File Structure

```
single-spa-webcomponents-app/
├── src/
│   └── single-spa-webcomponents-app.js    # Main application entry
├── dist/                                   # Build output directory
├── package.json                           # Dependencies and scripts
├── webpack.config.js                      # Build configuration
├── .gitignore                            # Git ignore rules
└── README.md                             # This file
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test the Web Component integration
5. Submit a pull request

## License

MIT License - see LICENSE file for details.

## Related Projects

- [Lit](https://lit.dev/) - Simple. Fast. Web Components.
- [Web Components](https://developer.mozilla.org/en-US/docs/Web/Web_Components) - MDN Documentation
- [Demo Microfrontends](../README.md) - Complete microfrontend demo

## Author

Cesar Francisco Chavez Maldonado - Web Components Microfrontend Example