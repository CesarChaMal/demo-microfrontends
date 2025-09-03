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
      vm.features = [
        'Legacy Framework Integration',
        'UI-Router for Navigation',
        'Two-way Data Binding',
        'Dependency Injection',
        'Migration Path to Modern Angular'
      ];
    },
  });
