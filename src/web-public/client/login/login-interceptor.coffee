module.exports = LoginInterceptor = ($q, $modal, $injector) ->
	'self': this
	'request': (config) -> config
	'requestError': (rejection) -> $q.reject rejection
	'response': (response) ->
		if response.data == 'NOT AUTHENTICATED'
			def = $q.defer()
			modalInstance = $modal.open
				templateUrl : 'login/login.html'
				controller : require './login'

			modalInstance.result.then (result)->
				$http = $injector.invoke ($http)->
					$http
				$http(response.config).then (secondResponse)->
					def.resolve(secondResponse)
			, ()->
				def.reject("NOT AUTHORIZED")

			# $ocModal.open
			# 	id: 'modal1',
			# 	url: 'login/login.html'
			# 	controller: 'LoginController'
			# 	onClose: (user)->
			# 		$http = $injector.invoke($http) -> $http
			# 		$http(response.config).then (secondResponse) ->
			# 			def.resolve secondResponse
			# 		, ()->
			# 			def.reject 'NOT AUTHORIZED'
			def.promise
		else
			response
	'responseError': (rejection) -> $q.reject rejection
