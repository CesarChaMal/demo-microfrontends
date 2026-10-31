import { createSignal, createMemo, onCleanup, For, Show } from 'solid-js';

const App = () => {
  // Fine-grained reactive state — every signal updates exactly the DOM nodes
  // that read it. No virtual DOM, no re-running the component.
  const [count, setCount] = createSignal(0);
  const [name, setName] = createSignal('');
  const [items, setItems] = createSignal([]);
  const [userState, setUserState] = createSignal(null);
  const [employees, setEmployees] = createSignal([]);
  const [events, setEvents] = createSignal([]);
  const [mountedAt] = createSignal(new Date().toLocaleString());

  const doubled = createMemo(() => count() * 2);
  const parity = createMemo(() => (count() % 2 === 0 ? 'even' : 'odd'));

  const employeePreview = createMemo(() => {
    const emps = employees();
    if (emps.length === 0) return 'No employees loaded';
    const preview = emps.slice(0, 3).map((emp) => emp.name).join(', ');
    return emps.length > 3 ? `${preview} (+${emps.length - 3} more)` : preview;
  });

  // Shared state subscriptions (run once — the component body executes once).
  // onCleanup runs when dispose() is called from the single-spa unmount.
  if (window.stateManager) {
    const userSub = window.stateManager.userState$.subscribe((state) => {
      setUserState(state);
      console.log('🔶 Solid: User state changed:', state);
    });
    const employeesSub = window.stateManager.employees$.subscribe((emps) => {
      setEmployees(emps);
    });
    const eventsSub = window.stateManager.events$.subscribe((event) => {
      setEvents([...events().slice(-4), event]);
      console.log('🔶 Solid received event:', event);
    });
    onCleanup(() => {
      userSub.unsubscribe();
      employeesSub.unsubscribe();
      eventsSub.unsubscribe();
    });
  }

  const increment = () => {
    setCount(count() + 1);
    if (window.stateManager) {
      window.stateManager.emit('solid-counter', { count: count(), app: 'Solid' });
    }
  };

  const decrement = () => setCount(count() - 1);
  const reset = () => setCount(0);

  const loadItems = () => {
    setItems([
      { id: 1, name: 'Signals', type: 'Reactivity' },
      { id: 2, name: 'createMemo', type: 'Derived State' },
      { id: 3, name: 'No Virtual DOM', type: 'Architecture' },
      { id: 4, name: 'Fine-Grained Updates', type: 'Performance' },
      { id: 5, name: 'onCleanup', type: 'Lifecycle' }
    ]);
  };

  const addItem = () => {
    if (name().trim()) {
      setItems([...items(), { id: Date.now(), name: name().trim(), type: 'Custom' }]);
      setName('');
    }
  };

  const removeItem = (id) => {
    setItems(items().filter((item) => item.id !== id));
  };

  const loadEmployees = () => {
    if (window.stateManager) {
      window.stateManager.loadEmployees();
    }
  };

  const broadcastMessage = () => {
    if (window.stateManager) {
      window.stateManager.emit('cross-app-message', {
        source: 'Solid',
        message: 'Hello from Solid!',
        timestamp: new Date().toISOString()
      });
    }
  };

  const clearEmployees = () => {
    if (window.stateManager) {
      window.stateManager.employees$.next([]);
    }
  };

  return (
    <div style="padding: 20px; border: 2px solid #446b9e; border-radius: 8px; margin: 10px 0; background: #f8f9fa;">
      <h2 style="color: #2c4f7c; margin: 0 0 15px 0;">
        🔶 SolidJS Fine-Grained Reactivity
      </h2>
      <p><strong>Library:</strong> SolidJS 1.x (Fine-Grained Reactive Framework)</p>
      <p><strong>Integration:</strong> Hand-rolled single-spa lifecycle — render() + dispose(), no adapter needed</p>
      <p><strong>Mounted at:</strong> {mountedAt()}</p>

      <div style="margin: 15px 0;">
        <h4 style="color: #495057;">Signal Counter</h4>
        <p style="font-size: 1.4em; margin: 10px 0;">
          Count: <strong style="color: #2c4f7c;">{count()}</strong>
          <span style="margin-left: 15px; color: #6c757d;">doubled: {doubled()} ({parity()})</span>
        </p>
        <div style="display: flex; gap: 10px; flex-wrap: wrap;">
          <button
            onClick={increment}
            style="background: #446b9e; color: white; border: none; padding: 8px 16px; border-radius: 4px; cursor: pointer; font-weight: bold;"
          >
            + Increment
          </button>
          <button
            onClick={decrement}
            style="background: #6c757d; color: white; border: none; padding: 8px 16px; border-radius: 4px; cursor: pointer;"
          >
            − Decrement
          </button>
          <button
            onClick={reset}
            style="background: #17a2b8; color: white; border: none; padding: 8px 16px; border-radius: 4px; cursor: pointer;"
          >
            Reset
          </button>
        </div>
      </div>

      <div style="margin: 15px 0;">
        <h4 style="color: #495057;">Reactive Items</h4>
        <div style="margin: 10px 0;">
          <input
            type="text"
            placeholder="Add new item..."
            value={name()}
            onInput={(e) => setName(e.currentTarget.value)}
            style="padding: 8px 12px; border: 1px solid #ced4da; border-radius: 4px; margin-right: 10px; width: 200px;"
          />
          <button
            onClick={addItem}
            style="background: #446b9e; color: white; border: none; padding: 8px 16px; border-radius: 4px; cursor: pointer; font-weight: bold;"
          >
            Add Item
          </button>
          <button
            onClick={loadItems}
            style="background: #28a745; color: white; border: none; padding: 8px 16px; border-radius: 4px; cursor: pointer; margin-left: 10px;"
          >
            Load Demo Items
          </button>
        </div>
        <div style="margin-top: 15px; padding: 10px; background: #e9ecef; border-radius: 4px; min-height: 60px;">
          <Show
            when={items().length > 0}
            fallback={<em>No items yet. Add one above or load the demo items!</em>}
          >
            <For each={items()}>
              {(item) => (
                <div
                  style="background: white; padding: 10px; margin: 5px 0; border-radius: 4px; display: flex; align-items: center; justify-content: space-between;"
                >
                  <div>
                    <strong>{item.name}</strong> <span style="color: #6c757d;">({item.type})</span>
                  </div>
                  <button
                    onClick={() => removeItem(item.id)}
                    style="background: #dc3545; color: white; border: none; padding: 4px 8px; border-radius: 4px; cursor: pointer; font-size: 12px;"
                  >
                    Remove
                  </button>
                </div>
              )}
            </For>
          </Show>
        </div>
      </div>

      <div
        style="margin: 15px 0; padding: 15px; background: linear-gradient(135deg, #446b9e 0%, #7c6ff0 100%); border-radius: 8px; color: white;"
      >
        <h4 style="margin: 0 0 15px 0; color: white;">🔄 Shared State Management (Solid)</h4>

        <div style="background: rgba(255,255,255,0.1); padding: 10px; border-radius: 6px; margin-bottom: 10px;">
          <strong>👤 User State:</strong><br />
          <Show when={userState()} fallback="❌ Not logged in">
            ✅ Logged in as: <strong>{userState().user?.username || 'Unknown'}</strong>
          </Show>
        </div>

        <div style="background: rgba(255,255,255,0.1); padding: 10px; border-radius: 6px; margin-bottom: 10px;">
          <strong>👥 Employee Data:</strong><br />
          📊 Count: <strong>{employees().length}</strong><br />
          👀 Preview: {employeePreview()}
        </div>

        <div style="display: flex; gap: 10px; flex-wrap: wrap; margin-bottom: 10px;">
          <button
            onClick={loadEmployees}
            style="background: #28a745; color: white; border: none; padding: 8px 12px; border-radius: 4px; cursor: pointer; font-size: 12px;"
          >
            👥 Load Employees
          </button>
          <button
            onClick={broadcastMessage}
            style="background: #007bff; color: white; border: none; padding: 8px 12px; border-radius: 4px; cursor: pointer; font-size: 12px;"
          >
            📡 Broadcast from Solid
          </button>
          <button
            onClick={clearEmployees}
            style="background: #dc3545; color: white; border: none; padding: 8px 12px; border-radius: 4px; cursor: pointer; font-size: 12px;"
          >
            🗑️ Clear Data
          </button>
        </div>

        <Show when={events().length > 0}>
          <div style="background: rgba(255,255,255,0.1); padding: 10px; border-radius: 6px; font-size: 12px;">
            <strong>📨 Recent Events:</strong><br />
            <For each={events()}>
              {(event) => (
                <div style="margin-top: 5px;">
                  {event.data?.source || event.event}: {event.data?.message || event.event}
                </div>
              )}
            </For>
          </div>
        </Show>
      </div>

      <div style="margin-top: 15px; font-size: 0.9em; color: #6c757d;">
        <strong>Solid Features:</strong>
        <ul style="margin: 5px 0; padding-left: 20px;">
          <li>Signals (createSignal) — fine-grained reactive primitives</li>
          <li>createMemo — derived state that only recomputes on change</li>
          <li>onCleanup — automatic teardown when the app unmounts</li>
          <li>JSX compiled to real DOM operations — no virtual DOM</li>
          <li>Component body runs once, not on every update</li>
        </ul>
      </div>
    </div>
  );
};

export default App;
