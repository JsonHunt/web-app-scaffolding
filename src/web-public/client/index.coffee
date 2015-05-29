app = angular.module 'PublicApp', [ 'ngRoute','oc.modal']
app.config ['$routeProvider', ($routeProvider)->

	$routeProvider.when '/',
		controller : 'HomeController'
		templateUrl : 'home/home.html'
	.when '/contact',
		controller : 'contactController'
		templateUrl : '/contact/contact.html'

	.otherwise
		redirectTo : '/'
]

IndexController = ($scope,$location,$ocModal) ->

	$scope.goto = (path)->
		$scope.path = path
		$location.path(path)

	$scope.login = ()->
		$ocModal.open
			id: 'modal1',
			url: 'login/login.html'
			controller: 'LoginController'

	$scope.signup = ()->
		$ocModal.open
			id: 'modal1',
			url: 'signup/signup.html'
			controller: 'SignupController'

IndexController.$inject = [ '$scope','$location','$ocModal' ]

app.controller 'IndexController', IndexController
app.controller 'HomeController', HomeController
app.controller 'contactController', contactController
app.controller 'LoginController', LoginController
app.controller 'SignupController', SignupController
