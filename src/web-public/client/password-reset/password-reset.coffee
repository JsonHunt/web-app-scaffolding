module.exports = PasswordResetController = ($scope, $http, $ocModal) ->

	setTimeout ()->
		$('.focusme').focus()
	,100



PasswordResetController.$inject = [ '$scope', '$http','$ocModal' ]
