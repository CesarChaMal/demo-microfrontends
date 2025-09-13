<script>
  import { onMount, onDestroy } from 'svelte';
  
  let count = 0;
  let name = '';
  let items = [];
  let loading = false;
  let mounted = false;
  let userState = null;
  let employees = [];
  let events = [];
  let userStateSub = null;
  let employeesSub = null;
  let eventsSub = null;
  
  onMount(() => {
    mounted = true;
    if (window.stateManager) {
      userStateSub = window.stateManager.userState$.subscribe(state => {
        userState = state;
        console.log('🔥 Svelte: User state changed:', state);
      });
      employeesSub = window.stateManager.employees$.subscribe(emps => {
        employees = emps;
      });
      eventsSub = window.stateManager.events$.subscribe(event => {
        console.log('🔥 Svelte received event:', event);
        events = [...events.slice(-4), event];
      });
    }
    return () => {
      mounted = false;
    };
  });
  
  onDestroy(() => {
    if (userStateSub) {
      userStateSub.unsubscribe();
    }
    if (employeesSub) {
      employeesSub.unsubscribe();
    }
    if (eventsSub) {
      eventsSub.unsubscribe();
    }
  });
  
  function increment() {
    count += 1;
    if (window.stateManager) {
      window.stateManager.emit('svelte-counter', { count, app: 'Svelte' });
    }
  }
  
  function decrement() {
    count -= 1;
  }
  
  function reset() {
    count = 0;
  }
  
  async function loadItems() {
    loading = true;
    
    // Simulate API call
    await new Promise(resolve => setTimeout(resolve, 1000));
    
    items = [
      { id: 1, name: 'Svelte Component', type: 'Framework', reactive: true },
      { id: 2, name: 'Compile-time Optimization', type: 'Feature', reactive: true },
      { id: 3, name: 'No Virtual DOM', type: 'Architecture', reactive: true },
      { id: 4, name: 'Small Bundle Size', type: 'Performance', reactive: true },
      { id: 5, name: 'Built-in Animations', type: 'Feature', reactive: true }
    ];
    
    loading = false;
  }
  
  function addItem() {
    if (name.trim()) {
      items = [...items, {
        id: Date.now(),
        name: name.trim(),
        type: 'Custom',
        reactive: true
      }];
      name = '';
    }
  }
  
  function loadEmployees() {
    if (window.stateManager) {
      window.stateManager.loadEmployees();
    }
  }
  
  function broadcastMessage() {
    if (window.stateManager) {
      const eventData = {
        source: 'Svelte',
        message: 'Hello from Svelte!',
        timestamp: new Date().toISOString()
      };
      window.stateManager.emit('cross-app-message', eventData);
    }
  }
  
  function clearEmployees() {
    if (window.stateManager) {
      window.stateManager.employees$.next([]);
    }
  }
  
  function removeItem(id) {
    items = items.filter(item => item.id !== id);
  }
  
  function toggleReactive(id) {
    items = items.map(item => 
      item.id === id 
        ? { ...item, reactive: !item.reactive }
        : item
    );
  }
  
  // Reactive statements
  $: doubleCount = count * 2;
  $: countMessage = count === 0 ? 'Zero' : count === 1 ? 'One' : `${count} items`;
  $: completedItems = items.filter(item => item.reactive).length;
</script>

<div class="svelte-app">
  <h2>
    <img src="https://svelte.dev/svelte-logo-horizontal.svg" width="80" height="40" style="vertical-align: middle; margin-right: 10px;" alt="Svelte">
    Svelte Microfrontend
  </h2>
  
  <p><strong>Framework:</strong> Svelte 3 (Compile-time optimized)</p>
  <p><strong>Features:</strong> Reactive programming, no virtual DOM, small bundles</p>
  <p><strong>Mounted:</strong> {mounted ? 'Yes' : 'No'} • <strong>Time:</strong> {new Date().toLocaleString()}</p>
  
  <div class="counter-section">
    <h4>Reactive Counter</h4>
    <div class="counter-controls">
      <button on:click={decrement}>-</button>
      <span class="count-display">{count}</span>
      <button on:click={increment}>+</button>
      <button on:click={reset} class="reset-btn">Reset</button>
    </div>
    <p class="counter-info">
      Count: {countMessage} • Double: {doubleCount}
    </p>
  </div>
  
  <div class="items-section">
    <h4>Dynamic Items ({completedItems}/{items.length} active)</h4>
    
    <div class="add-item">
      <input 
        bind:value={name} 
        placeholder="Add new item..." 
        on:keypress={(e) => e.key === 'Enter' && addItem()}
      >
      <button on:click={addItem} disabled={!name.trim()}>Add Item</button>
      <button on:click={loadItems} disabled={loading}>
        {loading ? 'Loading...' : 'Load Sample Items'}
      </button>

    </div>
    
    {#if loading}
      <div class="loading">Loading items...</div>
    {:else if items.length === 0}
      <div class="empty">No items yet. Add some above!</div>
    {:else}
      <div class="items-list">
        {#each items as item (item.id)}
          <div class="item" class:inactive={!item.reactive}>
            <div class="item-content">
              <strong>{item.name}</strong>
              <span class="item-type">{item.type}</span>
            </div>
            <div class="item-actions">
              <button 
                on:click={() => toggleReactive(item.id)}
                class="toggle-btn"
                class:active={item.reactive}
              >
                {item.reactive ? '✓' : '○'}
              </button>
              <button on:click={() => removeItem(item.id)} class="remove-btn">×</button>
            </div>
          </div>
        {/each}
      </div>
    {/if}
  </div>
  
  <!-- Shared State Showcase -->
  <div class="shared-state-showcase">
    <h4 style="margin: 0 0 15px 0; color: white;">🔄 Shared State Management (Svelte)</h4>
    
    <div class="state-info">
      <strong>👤 User State:</strong><br>
      {#if userState}
        ✅ Logged in as: <strong>{(userState.user && userState.user.username) || 'Unknown'}</strong>
      {:else}
        ❌ Not logged in
      {/if}
    </div>
    
    <div class="state-info">
      <strong>👥 Employee Data:</strong><br>
      📊 Count: <strong>{employees.length}</strong><br>
      👀 Preview: {#if employees.length > 0}
        {employees.slice(0, 3).map(emp => emp.name).join(', ')}{employees.length > 3 ? ` (+${employees.length - 3} more)` : ''}
      {:else}
        No employees loaded
      {/if}
    </div>
    
    <div class="showcase-buttons">
      <button on:click={loadEmployees} class="showcase-btn load-btn">
        👥 Load Employees
      </button>
      <button on:click={broadcastMessage} class="showcase-btn broadcast-btn">
        📡 Broadcast from Svelte
      </button>
      <button on:click={clearEmployees} class="showcase-btn clear-btn">
        🗑️ Clear Data
      </button>
    </div>
    
    {#if events.length > 0}
      <div class="events-info">
        <strong>📨 Recent Events:</strong><br>
        {#each events.slice(-3) as event}
          <div class="event-item">
            {(event.data && event.data.source) || event.event}: {(event.data && event.data.message) || event.event}
          </div>
        {/each}
      </div>
    {/if}
  </div>
  
  <div class="features">
    <strong>Svelte Features:</strong>
    <ul>
      <li>Compile-time Optimization</li>
      <li>Reactive Statements ($:)</li>
      <li>No Virtual DOM Overhead</li>
      <li>Built-in State Management</li>
      <li>Small Bundle Size (~10KB)</li>
    </ul>
  </div>
</div>

<style>
  .svelte-app {
    padding: 20px;
    border: 2px solid #ff3e00;
    border-radius: 8px;
    margin: 10px 0;
    background: #f8f9fa;
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
  }
  
  h2 {
    color: #ff3e00;
    margin: 0 0 15px 0;
  }
  
  h4 {
    color: #495057;
    margin: 15px 0 10px 0;
  }
  
  .counter-section {
    margin: 15px 0;
    padding: 15px;
    background: white;
    border-radius: 6px;
  }
  
  .counter-controls {
    display: flex;
    align-items: center;
    gap: 10px;
    margin: 10px 0;
  }
  
  .count-display {
    font-size: 24px;
    font-weight: bold;
    color: #ff3e00;
    min-width: 40px;
    text-align: center;
  }
  
  .counter-info {
    font-size: 14px;
    color: #6c757d;
    margin: 5px 0 0 0;
  }
  
  .items-section {
    margin: 15px 0;
    padding: 15px;
    background: white;
    border-radius: 6px;
  }
  
  .add-item {
    display: flex;
    gap: 10px;
    margin-bottom: 15px;
    flex-wrap: wrap;
  }
  
  .add-item input {
    flex: 1;
    min-width: 200px;
    padding: 8px 12px;
    border: 1px solid #ced4da;
    border-radius: 4px;
  }
  
  .loading, .empty {
    text-align: center;
    padding: 20px;
    color: #6c757d;
    font-style: italic;
  }
  
  .items-list {
    display: flex;
    flex-direction: column;
    gap: 8px;
  }
  
  .item {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 12px;
    background: #f8f9fa;
    border-radius: 4px;
    border-left: 4px solid #ff3e00;
    transition: all 0.2s ease;
  }
  
  .item.inactive {
    opacity: 0.5;
    border-left-color: #6c757d;
  }
  
  .item-content {
    display: flex;
    flex-direction: column;
    gap: 4px;
  }
  
  .item-type {
    font-size: 12px;
    color: #6c757d;
    background: #e9ecef;
    padding: 2px 6px;
    border-radius: 3px;
    width: fit-content;
  }
  
  .item-actions {
    display: flex;
    gap: 5px;
  }
  
  .toggle-btn {
    width: 30px;
    height: 30px;
    border-radius: 50%;
    border: 2px solid #ff3e00;
    background: white;
    color: #ff3e00;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    font-weight: bold;
  }
  
  .toggle-btn.active {
    background: #ff3e00;
    color: white;
  }
  
  .remove-btn {
    width: 30px;
    height: 30px;
    border-radius: 50%;
    border: 2px solid #dc3545;
    background: white;
    color: #dc3545;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    font-weight: bold;
    font-size: 18px;
  }
  
  .remove-btn:hover {
    background: #dc3545;
    color: white;
  }
  
  .reset-btn {
    background: #6c757d !important;
  }
  
  button {
    background: #ff3e00;
    color: white;
    border: none;
    padding: 8px 16px;
    border-radius: 4px;
    cursor: pointer;
    transition: background-color 0.2s;
  }
  
  button:hover:not(:disabled) {
    background: #cc3300;
  }
  
  button:disabled {
    background: #6c757d;
    cursor: not-allowed;
  }
  
  .features {
    margin-top: 15px;
    font-size: 0.9em;
    color: #6c757d;
  }
  
  .features ul {
    margin: 5px 0;
    padding-left: 20px;
  }
  
  .shared-state-showcase {
    margin: 15px 0;
    padding: 15px;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    border-radius: 8px;
    color: white;
  }
  
  .state-info {
    background: rgba(255,255,255,0.1);
    padding: 10px;
    border-radius: 6px;
    margin-bottom: 10px;
  }
  
  .showcase-buttons {
    display: flex;
    gap: 10px;
    flex-wrap: wrap;
    margin-bottom: 10px;
  }
  
  .showcase-btn {
    padding: 8px 12px;
    border-radius: 4px;
    cursor: pointer;
    font-size: 12px;
    border: none;
  }
  
  .load-btn {
    background: #28a745;
    color: white;
  }
  
  .broadcast-btn {
    background: #007bff;
    color: white;
  }
  
  .clear-btn {
    background: #dc3545;
    color: white;
  }
  
  .events-info {
    background: rgba(255,255,255,0.1);
    padding: 10px;
    border-radius: 6px;
    font-size: 12px;
  }
  
  .event-item {
    margin-top: 5px;
  }
</style>