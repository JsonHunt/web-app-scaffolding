app = angular.module 'PublicApp', [ 'ngRoute']
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

IndexController = ($scope,$location) ->

	$scope.goto = (path)->
		$scope.path = path
		$location.path(path)


IndexController.$inject = [ '$scope','$location' ]

app.controller 'IndexController', IndexController
app.controller 'HomeController', HomeController
app.controller 'contactController', contactController
