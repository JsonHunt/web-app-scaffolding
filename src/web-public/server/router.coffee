express = require 'express'
service = require './service'
router = express.Router()

router.use '/getLogin', (req,res,next)->
	res.json
		user: req.session?.appuser

router.use '/login', (req, res, next) ->
	try
		service.login req.body.username, req.body.password, (err,user)->
			if !err and user
				req.session.appuser = user
			res.json
				error: err
				user: user
	catch e
		res.json
			error: e

router.use '/logout', (req,res,next)->
	delete req.session.appuser
	res.send 'ok'

router.use '/signup', (req,res,next)->
	service.signup req.body.user, (err,user)->
		res.json
			error: err
			user: user

router.use '/activateAccount', (req,res,next)->
	code = req.query.code
	service.activateUser code, (err)->
		res.json
			error: err

router.use '/requestPasswordReset', (req,res,next)->
	service.requestPasswordReset req.body.email, (err)->
		res.json
			error: err

router.use '/resetPassword', (req,res,next)->
	service.resetPassword req.query.code, (err,user)->
		if err
			res.redirect "reset-password-error.html"
		else
			req.session.appuser = user
			res.redirect "/#/change-password"

router.use '/changePassword', (req,res,next)->
	user = req.session.appuser
	if !user
		res.send "NOT AUTHENTICATED"
	else
		password = req.body.password
		service.changePassword user, password, (err)->
			res.json
				error: err


module.exports = router
