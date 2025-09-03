# single-spa-jquery-app

A jQuery microfrontend for Single-SPA demonstrating legacy library integration and migration strategies for existing jQuery-based applications.

## Features

- **jQuery 3.6.0**: Latest stable version of the popular library
- **Legacy Integration**: Shows how to integrate existing jQuery apps
- **DOM Manipulation**: Classic jQuery patterns and animations
- **Event Handling**: jQuery event delegation and management
- **Todo List Manager**: Interactive demo with CRUD operations

## Technology Stack

- **Library**: jQuery 3.6.0
- **Build Tool**: Webpack 4
- **Language**: JavaScript (ES5+ compatible)
- **Integration**: Single-SPA lifecycle with jQuery patterns

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
# Runs on http://localhost:4210
```

### Build

```bash
npm run build
# Outputs to dist/single-spa-jquery-app.js
```

## jQuery Features Demonstrated

### DOM Manipulation
```javascript
// Classic jQuery selectors and manipulation
this.$container.html(template);
$('#todo-item').addClass('completed');
```

### Event Handling
```javascript
// Event delegation
this.$container.on('click', '.delete-btn', (e) => {
  // Handle click events
});
```

### Animations
```javascript
// jQuery animations
$todoItem.slideUp(300);
$element.fadeIn(200).fadeOut(200);
```

### AJAX (Ready for integration)
```javascript
// jQuery AJAX patterns
$.ajax({
  url: '/api/todos',
  method: 'GET',
  success: (data) => { /* handle response */ }
});
```

## Single-SPA Integration

This microfrontend exports the required Single-SPA lifecycle functions:

```javascript
export const bootstrap = () => Promise.resolve();
export const mount = (props) => jqueryApp.mount(props);
export const unmount = () => jqueryApp.unmount();
```

### Mount Point

The application mounts to the DOM element with ID `jquery-app`:

```html
<div id="jquery-app"></div>
```

### Route Configuration

Configured to activate on routes starting with `/jquery`:

```javascript
singleSpa.registerApplication(
  'jquery',
  () => loadApp('single-spa-jquery-app'),
  showWhenPrefix(['/jquery'])
);
```

## Migration Benefits

### Legacy Code Integration
- Minimal changes to existing jQuery code
- Gradual migration strategy
- Preserve existing functionality
- Team familiarity

### Modernization Path
- Wrap jQuery apps in Single-SPA lifecycle
- Incremental replacement of components
- Coexistence with modern frameworks
- Reduced migration risk

## Interactive Features

### Todo List Manager
- Add new todos with Enter key or button
- Toggle completion status
- Delete individual todos
- Clear all completed todos
- Smooth animations for all interactions

### jQuery Animations
- Slide animations for todo removal
- Fade effects for new items
- Bounce effects for interactions
- Smooth transitions

## Performance Considerations

- **Bundle Size**: ~35KB (including jQuery)
- **DOM Performance**: Efficient with proper event delegation
- **Memory**: Clean event unbinding on unmount
- **Legacy Support**: Works in older browsers

## Migration Strategy

### Phase 1: Wrap Existing Code
```javascript
// Minimal wrapper for existing jQuery app
class LegacyJQueryApp {
  mount() {
    // Initialize existing jQuery code
    this.initializeExistingApp();
  }
  
  unmount() {
    // Clean up jQuery events and DOM
    this.$container.off().empty();
  }
}
```

### Phase 2: Incremental Modernization
- Replace components one by one
- Maintain jQuery for complex legacy parts
- Add modern tooling gradually

### Phase 3: Complete Migration
- Remove jQuery dependency
- Use modern alternatives
- Maintain same functionality

## File Structure

```
single-spa-jquery-app/
├── src/
│   └── single-spa-jquery-app.js          # Main jQuery application
├── dist/                                 # Build output directory
├── package.json                          # Dependencies and scripts
├── webpack.config.js                     # Build configuration
├── .gitignore                           # Git ignore rules
└── README.md                            # This file
```

## Best Practices

### Event Management
- Use event delegation for dynamic content
- Properly unbind events on unmount
- Namespace events to avoid conflicts

### DOM Manipulation
- Cache jQuery selectors
- Minimize DOM queries
- Use efficient selectors

### Memory Management
- Clean up on unmount
- Remove event listeners
- Clear references

## Browser Support

- Modern browsers with jQuery 3.6.0 support
- IE9+ compatibility
- Mobile browser support
- Legacy system integration

## Contributing

1. Fork the repository
2. Create a feature branch
3. Follow jQuery best practices
4. Test in multiple browsers
5. Ensure proper cleanup
6. Submit a pull request

## License

MIT License - see LICENSE file for details.

## Related Projects

- [jQuery](https://jquery.com/) - Write less, do more
- [Single-SPA](https://single-spa.js.org/) - Microfrontend framework
- [Demo Microfrontends](../README.md) - Complete microfrontend demo

## Author

Demo Team - jQuery Legacy Integration Example