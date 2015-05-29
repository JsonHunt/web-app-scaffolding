module.exports = SearchController = ($scope,$http,$interval)->

	$scope.getMembers = (member)->
		$scope.members = [{},{},{},{},{},{},{},{},{},{},{},{}]

		# $http.get "http://localhost:3000/messaging/search"
		# .success (data,status,headers,config)->
		# 	$scope.members = data

	$scope.approve = (member)->
		# $http.get "http://localhost:3000/messaging/approve"
		# .success (data,status,headers,config)->
			member.favorite = true
			member.blocked = false

	$scope.reject = (member)->
		# $http.get "http://localhost:3000/messaging/reject"
		# .success (data,status,headers,config)->
			member.blocked = true
			member.favorite = false

	if window.user is undefined
		$location.path ''
	else
		$scope.getMembers()

SearchController.$inject = [ '$scope','$http','$interval' ]
