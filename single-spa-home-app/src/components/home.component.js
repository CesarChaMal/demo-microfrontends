import angular from 'angular';
import template from './home.template.html';

angular
  .module('home-app')
  .component('homeComponent', {
    template,
    controllerAs: 'home',
    controller() {
      const vm = this;

      vm.title = 'AngularJS Home Microfrontend';
      vm.logoUrl = 'https://angularjs.org/img/ng-logo.png';
      vm.text = 'Welcome to the microfrontend architecture demo! This is the home page built with AngularJS 1.x, demonstrating legacy framework integration in a modern Single-SPA setup.';
      vm.mountedAt = new Date().toLocaleString();
      vm.userState = null;
      vm.employees = [];
      vm.events = [];
      vm.features = [
        'Legacy Framework Integration',
        'UI-Router for Navigation',
        'Two-way Data Binding',
        'Dependency Injection',
        'Migration Path to Modern Angular'
      ];

      if (window.stateManager) {
        vm.userStateSub = window.stateManager.userState$.subscribe(state => {
          vm.userState = state;
        });
        vm.employeesSub = window.stateManager.employees$.subscribe(employees => {
          vm.employees = employees;
        });
        vm.eventsSub = window.stateManager.events$.subscribe(event => {
          console.log('🏠 Home received event:', event);
          vm.events = [...vm.events.slice(-4), event];
        });
      }

      vm.loadEmployees = function() {
        if (window.stateManager) {
          window.stateManager.loadEmployees();
        }
      };

      vm.broadcastMessage = function() {
        if (window.stateManager) {
          const event = {
            type: 'user-interaction',
            source: 'AngularJS',
            timestamp: new Date().toISOString(),
            data: { message: 'Hello from AngularJS!' }
          };
          window.stateManager.emit('cross-app-message', event);
        }
      };

      vm.clearEmployees = function() {
        if (window.stateManager) {
          window.stateManager.employees$.next([]);
        }
      };

      vm.$onDestroy = function() {
        if (vm.userStateSub) {
          vm.userStateSub.unsubscribe();
        }
        if (vm.employeesSub) {
          vm.employeesSub.unsubscribe();
        }
        if (vm.eventsSub) {
          vm.eventsSub.unsubscribe();
        }
      };
    },
  });
