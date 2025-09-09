import { BehaviorSubject, Subject } from 'rxjs';

class StateManager {
  constructor() {
    this.userState$ = new BehaviorSubject({ user: null, isAuthenticated: false, token: null });
    this.events$ = new Subject();
    this.employees$ = new BehaviorSubject([]);
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
    this.events$.next({ event, data, timestamp: Date.now() });
  }

  async loadEmployees() {
    try {
      const response = await fetch('/employees.json');
      const data = await response.json();
      // Transform employee data to include full name
      const employees = data.data.map(emp => ({
        ...emp,
        name: `${emp.first_name} ${emp.last_name}`
      }));
      this.employees$.next(employees);
      this.emit('employees-loaded', { count: employees.length });
      return employees;
    } catch (error) {
      console.error('Failed to load employees:', error);
      this.emit('employees-error', { error: error.message });
      return [];
    }
  }

  getEmployees() {
    return this.employees$.value;
  }
}

export default new StateManager();