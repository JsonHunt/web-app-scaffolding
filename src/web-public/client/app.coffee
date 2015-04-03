app = angular.module 'PublicApp', [
	'ngRoute'
	'oc.modal'
	'ui.bootstrap'
]

mod = require 'web-app-modules/gen/client'

app.controller 'IndexController', require './index-controller'
app.factory 'LoginInterceptor', mod.auth.loginInterceptor

app.config ['$httpProvider','$routeProvider', ($httpProvider,$routeProvider) ->
	$httpProvider.interceptors.push 'LoginInterceptor'

	userPromise =
		xxx: ($q, $http, $rootScope)->
			return if $rootScope.user
			i = $q.defer()
			$http.get 'module/auth/getLogin'
			.success (data)->
				$rootScope.user = data.user
				i.resolve()
			.error ()->
				delete $rootScope.user
				i.reject()
			i.promise

	$routeProvider.when '/',
		controller : require './home/home'
		templateUrl : 'home/home.html'
		resolve: userPromise
	.when '/contact',
		controller : require './contact/contact'
		templateUrl : '/contact/contact.html'
		resolve: userPromise
	.when '/features',
		controller : require './features/features'
		templateUrl : '/features/features.html'
		resolve: userPromise
	# .when '/change-password',
	# 		controller : mod.auth.change-password
	# 		templateUrl : '/mod/auth/change-password.html'
	.otherwise
		redirectTo : '/'
]

module.exports = app
