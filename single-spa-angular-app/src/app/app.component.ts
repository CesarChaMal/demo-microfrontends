import { Component, OnInit, OnDestroy } from '@angular/core';
import { Subscription } from 'rxjs';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.scss']
})
export class AppComponent implements OnInit, OnDestroy {
  title = 'single-spa-angular-app';
  count = 0;
  mountedAt = new Date().toLocaleString();
  userState: any;
  employees: any[] = [];
  events: any[] = [];
  private userStateSub: Subscription;
  private employeesSub: Subscription;
  private eventsSub: Subscription;
  features = [
    'TypeScript Integration',
    'Dependency Injection',
    'Angular Router',
    'Component Architecture',
    'RxJS Observables'
  ];

  get doubleCount(): number {
    return this.count * 2;
  }

  get employeePreview(): string {
    if (this.employees.length === 0) return '';
    const preview = this.employees.slice(0, 3).map(emp => emp.name).join(', ');
    return this.employees.length > 3 ? `${preview} (+${this.employees.length - 3} more)` : preview;
  }

  get recentEvents(): any[] {
    return this.events.slice(-3);
  }

  increment(): void {
    this.count++;
    if ((window as any).stateManager) {
      (window as any).stateManager.emit('angular-counter', { count: this.count, app: 'Angular' });
    }
  }

  reset(): void {
    this.count = 0;
  }

  ngOnInit(): void {
    if ((window as any).stateManager) {
      this.userStateSub = (window as any).stateManager.userState$.subscribe(
        (state: any) => this.userState = state
      );
      this.employeesSub = (window as any).stateManager.employees$.subscribe(
        (employees: any[]) => this.employees = employees
      );
      this.eventsSub = (window as any).stateManager.events$.subscribe(
        (event: any) => {
          console.log('🅰️ Angular received event:', event);
          this.events = [...this.events.slice(-4), event]; // Keep last 5 events
        }
      );
    }
  }

  loadEmployees(): void {
    if ((window as any).stateManager) {
      (window as any).stateManager.loadEmployees();
    }
  }

  broadcastMessage(): void {
    if ((window as any).stateManager) {
      const event = {
        type: 'user-interaction',
        source: 'Angular',
        timestamp: new Date().toISOString(),
        data: { message: 'Hello from Angular!' }
      };
      (window as any).stateManager.emit('cross-app-message', event);
    }
  }

  clearEmployees(): void {
    if ((window as any).stateManager) {
      (window as any).stateManager.employees$.next([]);
    }
  }

  ngOnDestroy(): void {
    if (this.userStateSub) {
      this.userStateSub.unsubscribe();
    }
    if (this.employeesSub) {
      this.employeesSub.unsubscribe();
    }
    if (this.eventsSub) {
      this.eventsSub.unsubscribe();
    }
  }
}
