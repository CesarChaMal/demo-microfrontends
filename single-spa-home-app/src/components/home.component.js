import angular from 'angular';
import template from './home.template.html';

angular
  .module('home-app')
  .component('homeComponent', {
    template,
    controllerAs: 'home',
    controller() {
      const vm = this;

      vm.title = 'Home app';
      vm.logoUrl = 'https://angularjs.org/img/ng-logo.png';
      vm.text = 'You are seeing the home page. This is an angularjs application which is displayed when url is equal to "/".';
    },
  });
