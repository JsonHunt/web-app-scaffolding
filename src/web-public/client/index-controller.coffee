mod = require 'web-app-modules/gen/client'

ctr = module.exports = ($scope,$location,$ocModal,$http,$modal,$rootScope, $sce) ->
	###
	## sourceURL=hello.js
	###
	$scope.back = ()->
		window.history.back()

	$scope.log = (x)->
		if _.isObject x
			console.log JSON.stringify(x,null,2)
		else
			console.log x.valueOf()

	$scope.getLogin = ()->
		$http.get "/module/auth/getLogin"
		.success (data,status,headers,config)->
			$scope.user = data.user
			$scope.checked = true

	# $scope.getLogin()

	$scope.goto = (path)->
		$scope.path = path
		console.log "Going to #{path}"
		$location.path(path)

	$scope.gotoPage = (p)->
		$scope.page = p

	$scope.isPage = (p)-> $scope.page is p

	$scope.login = ()->

		modalInstance = $modal.open
			templateUrl : 'module/auth/login.html'
			controller : mod.auth.login

		modalInstance.result.then (result)->
			$rootScope.user = result
		, ()->
			$location.path('/')

	$scope.signup = ()->
		modal = $modal.open
			templateUrl: 'module/auth/signup.html'
			controller: mod.auth.signup

	$scope.pay = (description,amount)->
		$modal.open
			templateUrl: 'module/payment/load-balance.html'
			controller: mod.payment.loadBalance

	$scope.logout = ()->
		$http.post "/module/auth/logout"
		.success (data,status,headers,config)->
			delete $rootScope.user
			$location.path('/')

ctr.$inject = [ '$scope','$location','$ocModal','$http','$modal','$rootScope','$sce']
