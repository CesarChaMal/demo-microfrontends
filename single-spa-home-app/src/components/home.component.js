import angular from 'angular';
import template from './home.template.html';

angular
  .module('home-app')
  .component('homeComponent', {
    template,
    controllerAs: 'home',
    controller: ['$scope', function($scope) {
      const vm = this;
      vm.$scope = $scope;

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
          // Use $evalAsync to avoid digest conflicts
          if (!vm.$scope.$$phase) {
            vm.$scope.$apply();
          }
        });
        vm.employeesSub = window.stateManager.employees$.subscribe(employees => {
          console.log('🏠 Home received employees update:', employees);
          vm.employees = employees;
          // Use $evalAsync to avoid digest conflicts
          if (!vm.$scope.$$phase) {
            vm.$scope.$apply();
          }
        });
        vm.eventsSub = window.stateManager.events$.subscribe(event => {
          console.log('🏠 Home received event:', event);
          vm.events = [...vm.events.slice(-4), event];
          // Use $evalAsync to avoid digest conflicts
          if (!vm.$scope.$$phase) {
            vm.$scope.$apply();
          }
        });
      }

      vm.loadEmployees = function() {
        if (window.stateManager) {
          console.log('🏠 AngularJS: Loading employees...');
          window.stateManager.loadEmployees().then(() => {
            console.log('🏠 AngularJS: Employees loaded, current count:', vm.employees.length);
          });
        }
      };

      vm.broadcastMessage = function() {
        if (window.stateManager) {
          const eventData = {
            source: 'AngularJS',
            message: 'Hello from AngularJS!',
            timestamp: new Date().toISOString()
          };
          window.stateManager.emit('cross-app-message', eventData);
          console.log('📡 AngularJS broadcasted message:', eventData);
        }
      };

      vm.clearEmployees = function() {
        if (window.stateManager) {
          window.stateManager.employees$.next([]);
        }
      };

      vm.getEmployeePreview = function() {
        if (vm.employees.length === 0) return 'No employees loaded';
        const preview = vm.employees.slice(0, 3).map(emp => emp.name).join(', ');
        return vm.employees.length > 3 ? `${preview} (+${vm.employees.length - 3} more)` : preview;
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
    }],
  });
