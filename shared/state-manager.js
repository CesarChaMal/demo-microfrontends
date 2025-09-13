import { BehaviorSubject, Subject } from 'rxjs';

class StateManager {
  constructor() {
    this.userState$ = new BehaviorSubject({ user: null, isAuthenticated: false, token: null });
    this.events$ = new Subject();
    this.employees$ = new BehaviorSubject([]);
    this.employeesLoaded = false;
    
    console.log('🏠 StateManager initialized');
    console.log('🔍 Initial employees$ value:', this.employees$.value);
    
    // Debug: Log when employees$ changes
    this.employees$.subscribe(employees => {
      console.log('📊 employees$ updated with:', employees);
    });
    
    // Auto-load employees when state manager is first accessed
    this.autoLoadEmployees();
  }

  autoLoadEmployees() {
    // Load employees automatically after a short delay to ensure DOM is ready
    setTimeout(() => {
      if (!this.employeesLoaded) {
        console.log('🔄 Auto-loading employees on state manager initialization');
        this.loadEmployees().then(() => {
          console.log('✅ Auto-load completed, current employees:', this.getEmployees());
        });
      }
    }, 1000);
  }

  setUser(user, token) {
    this.userState$.next({ user, isAuthenticated: true, token });
    sessionStorage.setItem('user', JSON.stringify(user));
    sessionStorage.setItem('token', token);
  }

  logout() {
    this.userState$.next({ user: null, isAuthenticated: false, token: null });
    sessionStorage.removeItem('user');
    sessionStorage.removeItem('token');
  }

  emit(event, data) {
    const eventData = { event, data, timestamp: Date.now() };
    console.log('📡 Emitting event:', eventData);
    this.events$.next(eventData);
  }

  async loadEmployees() {
    try {
      // Try multiple possible locations for employees.json
      const possibleUrls = [
        '/employees.json',
        './employees.json',
        `${window.location.origin}/employees.json`
      ];
      
      let response;
      let data;
      
      for (const url of possibleUrls) {
        try {
          console.log(`🔄 Trying to load employees from: ${url}`);
          response = await fetch(url);
          console.log('🔍 Fetch response status:', response.status, response.statusText);
          
          if (response.ok) {
            data = await response.json();
            console.log('📊 Raw employee data from JSON:', data);
            break;
          }
        } catch (fetchError) {
          console.log(`❌ Failed to fetch from ${url}:`, fetchError.message);
          continue;
        }
      }
      
      // If all URLs failed, use fallback data
      if (!data) {
        console.log('⚠️ All employee data URLs failed, using fallback data');
        data = {
          employees: [
            { id: 1, name: 'John Doe', position: 'Software Engineer', department: 'Engineering' },
            { id: 2, name: 'Jane Smith', position: 'Product Manager', department: 'Product' },
            { id: 3, name: 'Mike Johnson', position: 'Designer', department: 'Design' },
            { id: 4, name: 'Sarah Wilson', position: 'DevOps Engineer', department: 'Engineering' },
            { id: 5, name: 'Tom Brown', position: 'QA Engineer', department: 'Quality Assurance' }
          ]
        };
      }
      // Transform employee data to include full name
      const employees = data.data.map(emp => ({
        ...emp,
        name: `${emp.first_name} ${emp.last_name}`
      }));
      console.log('🔄 Setting employees in BehaviorSubject:', employees);
      this.employees$.next(employees);
      this.employeesLoaded = true;
      // Emit the actual employee data, not just the count
      this.emit('employees-loaded', { count: employees.length, employees });
      console.log(`✅ Successfully loaded ${employees.length} employees:`, employees);
      console.log('🔍 Current employees$ value after setting:', this.employees$.value);
      return employees;
    } catch (error) {
      console.error('❌ Failed to load employees:', error);
      this.emit('employees-error', { error: error.message });
      return [];
    }
  }

  getEmployees() {
    const employees = this.employees$.value;
    console.log('🔍 getEmployees() called, returning:', employees);
    return employees;
  }

  getUserState() {
    const userState = this.userState$.value;
    console.log('🔍 getUserState() called, returning:', userState);
    return userState;
  }
}

export default new StateManager();