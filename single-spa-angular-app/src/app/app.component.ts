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
  private userStateSub: Subscription;
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
      this.eventsSub = (window as any).stateManager.events$.subscribe(
        (event: any) => console.log('🅰️ Angular received event:', event)
      );
    }
  }

  ngOnDestroy(): void {
    if (this.userStateSub) {
      this.userStateSub.unsubscribe();
    }
    if (this.eventsSub) {
      this.eventsSub.unsubscribe();
    }
  }
}
