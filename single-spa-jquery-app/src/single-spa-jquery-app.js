import $ from 'jquery';

// jQuery Microfrontend for Legacy Integration
class JQueryApp {
  constructor() {
    this.$container = null;
    this.userStateSub = null;
    this.eventsSub = null;
    this.todos = [
      { id: 1, text: 'Learn Single-SPA', completed: false },
      { id: 2, text: 'Integrate jQuery', completed: true },
      { id: 3, text: 'Build Microfrontends', completed: false }
    ];
    this.nextId = 4;
  }

  mount(props) {
    return new Promise((resolve) => {
      this.$container = $('#jquery-app');
      if (this.$container.length === 0) {
        console.error('Mount point #jquery-app not found');
        return resolve();
      }

      if (window.stateManager) {
        this.userStateSub = window.stateManager.userState$.subscribe(state => {
          console.log('💎 jQuery: User state changed:', state);
        });
        this.eventsSub = window.stateManager.events$.subscribe(event => {
          console.log('💎 jQuery received event:', event);
        });
      }

      this.render();
      this.attachEventHandlers();
      console.log('💎 jQuery App mounted');
      resolve();
    });
  }

  unmount() {
    return new Promise((resolve) => {
      if (this.userStateSub) {
        this.userStateSub.unsubscribe();
      }
      if (this.eventsSub) {
        this.eventsSub.unsubscribe();
      }
      if (this.$container) {
        this.$container.empty().off();
      }
      console.log('💎 jQuery App unmounted');
      resolve();
    });
  }

  render() {
    const now = new Date().toLocaleString();
    
    this.$container.html(`
      <div style="padding: 20px; border: 2px solid #ffc107; border-radius: 8px; margin: 10px 0; background: #f8f9fa;">
        <h2 style="color: #ffc107; margin: 0 0 15px 0;">
          <img src="https://upload.wikimedia.org/wikipedia/commons/f/fd/JQuery-Logo.svg" width="80" height="40" style="vertical-align: middle; margin-right: 10px;">
          jQuery Legacy Integration
        </h2>
        <p><strong>Library:</strong> jQuery 3.6.0 (Legacy Library)</p>
        <p><strong>Features:</strong> DOM manipulation, animations, AJAX, event handling</p>
        <p><strong>Mounted at:</strong> ${now}</p>
        
        <div style="margin: 15px 0;">
          <h4 style="color: #495057;">Todo List Manager</h4>
          <div style="margin: 10px 0;">
            <input 
              type="text" 
              id="new-todo-input" 
              placeholder="Add new todo..." 
              style="
                padding: 8px 12px; 
                border: 1px solid #ced4da; 
                border-radius: 4px; 
                margin-right: 10px;
                width: 200px;
              "
            >
            <button 
              id="add-todo-btn" 
              style="
                background: #ffc107; 
                color: #212529; 
                border: none; 
                padding: 8px 16px; 
                border-radius: 4px; 
                cursor: pointer;
                font-weight: bold;
              "
            >
              Add Todo
            </button>
          </div>
        </div>
        
        <div id="todos-container" style="
          margin-top: 15px; 
          padding: 10px; 
          background: #e9ecef; 
          border-radius: 4px;
          min-height: 100px;
        ">
          <!-- Todos will be rendered here -->
        </div>
        
        <div style="margin-top: 15px;">
          <button 
            id="animate-btn" 
            style="
              background: #17a2b8; 
              color: white; 
              border: none; 
              padding: 8px 16px; 
              border-radius: 4px; 
              cursor: pointer;
              margin-right: 10px;
            "
          >
            Animate Todos
          </button>
          
          <button 
            id="clear-completed-btn" 
            style="
              background: #dc3545; 
              color: white; 
              border: none; 
              padding: 8px 16px; 
              border-radius: 4px; 
              cursor: pointer;
            "
          >
            Clear Completed
          </button>
        </div>
        
        <div style="margin-top: 15px; font-size: 0.9em; color: #6c757d;">
          <strong>jQuery Features:</strong>
          <ul style="margin: 5px 0; padding-left: 20px;">
            <li>DOM Manipulation (\$)</li>
            <li>Event Handling</li>
            <li>CSS Animations</li>
            <li>AJAX Requests</li>
            <li>Legacy Browser Support</li>
          </ul>
        </div>
      </div>
    `);

    this.renderTodos();
  }

  renderTodos() {
    const $todosContainer = this.$container.find('#todos-container');
    
    if (this.todos.length === 0) {
      $todosContainer.html('<em>No todos yet. Add one above!</em>');
      return;
    }

    const todosHtml = this.todos.map(todo => `
      <div 
        class="todo-item" 
        data-id="${todo.id}"
        style="
          background: white; 
          padding: 10px; 
          margin: 5px 0; 
          border-radius: 4px; 
          display: flex; 
          align-items: center;
          justify-content: space-between;
          ${todo.completed ? 'opacity: 0.6;' : ''}
        "
      >
        <div style="display: flex; align-items: center;">
          <input 
            type="checkbox" 
            class="todo-checkbox" 
            ${todo.completed ? 'checked' : ''}
            style="margin-right: 10px;"
          >
          <span 
            class="todo-text" 
            style="${todo.completed ? 'text-decoration: line-through;' : ''}"
          >
            ${todo.text}
          </span>
        </div>
        <button 
          class="delete-todo-btn" 
          style="
            background: #dc3545; 
            color: white; 
            border: none; 
            padding: 4px 8px; 
            border-radius: 4px; 
            cursor: pointer;
            font-size: 12px;
          "
        >
          Delete
        </button>
      </div>
    `).join('');

    $todosContainer.html(todosHtml);
  }

  attachEventHandlers() {
    // Add new todo
    this.$container.on('click', '#add-todo-btn', () => {
      this.addTodo();
    });

    // Enter key to add todo
    this.$container.on('keypress', '#new-todo-input', (e) => {
      if (e.which === 13) { // Enter key
        this.addTodo();
      }
    });

    // Toggle todo completion
    this.$container.on('change', '.todo-checkbox', (e) => {
      const todoId = parseInt($(e.target).closest('.todo-item').data('id'));
      this.toggleTodo(todoId);
    });

    // Delete todo
    this.$container.on('click', '.delete-todo-btn', (e) => {
      const todoId = parseInt($(e.target).closest('.todo-item').data('id'));
      this.deleteTodo(todoId);
    });

    // Animate todos
    this.$container.on('click', '#animate-btn', () => {
      this.animateTodos();
    });

    // Clear completed todos
    this.$container.on('click', '#clear-completed-btn', () => {
      this.clearCompleted();
    });
  }

  addTodo() {
    const $input = this.$container.find('#new-todo-input');
    const text = $input.val().trim();
    
    if (text) {
      this.todos.push({
        id: this.nextId++,
        text: text,
        completed: false
      });
      
      $input.val('');
      this.renderTodos();
      
      // Broadcast event
      if (window.stateManager) {
        window.stateManager.emit('jquery-todo-added', { text, totalTodos: this.todos.length });
      }
      
      // Animate the new todo
      const $newTodo = this.$container.find('.todo-item').last();
      $newTodo.hide().fadeIn(300);
    }
  }

  toggleTodo(id) {
    const todo = this.todos.find(t => t.id === id);
    if (todo) {
      todo.completed = !todo.completed;
      this.renderTodos();
    }
  }

  deleteTodo(id) {
    const $todoItem = this.$container.find(`[data-id="${id}"]`);
    
    // Animate removal
    $todoItem.slideUp(300, () => {
      this.todos = this.todos.filter(t => t.id !== id);
      this.renderTodos();
    });
  }

  animateTodos() {
    const $todoItems = this.$container.find('.todo-item');
    
    $todoItems.each((index, element) => {
      const $item = $(element);
      setTimeout(() => {
        $item.animate({
          marginLeft: '20px',
          backgroundColor: '#fff3cd'
        }, 200).animate({
          marginLeft: '0px',
          backgroundColor: 'white'
        }, 200);
      }, index * 100);
    });
  }

  clearCompleted() {
    const $completedItems = this.$container.find('.todo-item').filter((index, element) => {
      const todoId = parseInt($(element).data('id'));
      const todo = this.todos.find(t => t.id === todoId);
      return todo && todo.completed;
    });

    if ($completedItems.length === 0) {
      alert('No completed todos to clear!');
      return;
    }

    // Animate removal of completed items
    $completedItems.fadeOut(300, () => {
      this.todos = this.todos.filter(t => !t.completed);
      this.renderTodos();
    });
  }
}

// Single-SPA Lifecycle Functions
const jqueryApp = new JQueryApp();

export const bootstrap = () => Promise.resolve();
export const mount = (props) => jqueryApp.mount(props);
export const unmount = () => jqueryApp.unmount();

export default {
  bootstrap,
  mount,
  unmount
};