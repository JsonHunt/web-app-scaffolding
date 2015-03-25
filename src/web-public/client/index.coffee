@app = app = angular.module 'PublicApp', [ 'ngRoute','oc.modal','ui.bootstrap']
app.config ['$routeProvider', ($routeProvider)->

	$routeProvider.when '/',
		controller : 'HomeController'
		templateUrl : 'home/home.html'
	.when '/contact',
		controller : 'contactController'
		templateUrl : '/contact/contact.html'
	.when '/change-password',
			controller : 'ChangePasswordController'
			templateUrl : '/change-password/change-password.html'
	.otherwise
		redirectTo : '/'
]

IndexController = ($scope,$location,$ocModal,$http) ->

	$scope.getLogin = ()->
		$http.get "/rest/getLogin"
		.success (data,status,headers,config)->
			$scope.user = data.user
			$scope.checked = true

	$scope.getLogin()

	$scope.goto = (path)->
		$scope.path = path
		$location.path(path)

	$scope.login = ()->
		$ocModal.open
			id: 'modal1',
			url: 'login/login.html'
			controller: 'LoginController'
			onClose: (user)->
				$scope.user = user

	$scope.signup = ()->
		$ocModal.open
			id: 'modal1',
			url: 'signup/signup.html'
			controller: 'SignupController'

	$scope.logout = ()->
		$http.post "/rest/logout"
		.success (data,status,headers,config)-> delete $scope.user

IndexController.$inject = [ '$scope','$location','$ocModal','$http']

app.controller 'IndexController', IndexController
app.controller 'HomeController', HomeController
app.controller 'contactController', contactController
app.controller 'LoginController', LoginController
app.controller 'SignupController', SignupController
app.controller 'PasswordResetController', PasswordResetController
app.controller 'ChangePasswordController', ChangePasswordController
