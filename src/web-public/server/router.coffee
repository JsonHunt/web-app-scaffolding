express = require 'express'
service = require './service'
router = express.Router()

router.use '/login', (req, res, next) ->
	service.login req.body.username, req.body.password, (err,user)->
		res.json
			error: err
			user: user

router.use '/signup', (req,res,next)->
	user =
		username: req.body.username
		password: req.body.password
		email: req.body.email

	service.signup user, (err,user)->
		res.json
			error: err
			user: user

module.exports = router
