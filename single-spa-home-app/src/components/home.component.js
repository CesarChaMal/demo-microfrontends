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
        vm.eventsSub = window.stateManager.events$.subscribe(event => {
          console.log('🏠 Home received event:', event);
        });
      }

      vm.$onDestroy = function() {
        if (vm.userStateSub) {
          vm.userStateSub.unsubscribe();
        }
        if (vm.eventsSub) {
          vm.eventsSub.unsubscribe();
        }
      };
    },
  });
