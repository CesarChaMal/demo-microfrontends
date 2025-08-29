import { Component } from '@angular/core';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.scss']
})
export class AppComponent {
  title = 'single-spa-angular-app';
  count = 0;
  mountedAt = new Date().toLocaleString();
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
  }

  reset(): void {
    this.count = 0;
  }
}
