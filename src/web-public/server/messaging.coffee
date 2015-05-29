https = require "https"
express = require 'express'
request = require 'request'
_ = require 'underscore'
dt = require './../dating'
SeekingArrangement = require './../sa'
router = express.Router()

websiteService =
	sa: SeekingArrangement()

dating = dt(websiteService)

router.post '/register', (req,res,next)->
	dating.register req.body.login,req.body.password, (err,user)->
		if err
			res.json {status: 'error', message: err}
			return
		req.session.userID = user._id
		req.session.userProfiles = {}
		for k,v of user.websiteProfiles
			req.session.userProfiles[k] = v._id
		res.json {status: 'ok', user: user }

router.get '/getUser',(req,res,next)-> dating.getUser req.session?.userID, (err,user)-> res.json user

router.post '/signIn', (req,res,next)->
	dating.signIn req.body.login, req.body.password, (err, user)->
		if err
			res.json {status: 'error', message: err}
			return
		req.session.userID = user._id
		req.session.userProfiles = {}
		for k,v of user.websiteProfiles
			req.session.userProfiles[k] = v._id
		res.json {status: 'ok', user: user }

router.post '/saveSettings', (req,res,next)-> dating.saveSettings req.session.userID, req.body.settings

router.post '/saveWebsiteSettings', (req,res,next)->
	dating.saveWebsiteSettings req.body.website, req.body.userID, req.body.settings, (err)->
		res.send err

router.post '/sendMessage/:website/:memberID', (req, res, next) ->
	userProfileID = req.session.userProfiles?[req.params.website]
	dating.sendMessage userProfileID, req.params.memberID, req.body.message, ()->

router.get '/blockProfile/:website/:memberID', (req,res,next)->
	userProfileID = req.session.userProfiles?[req.params.website]
	dating.blockProfile(userProfileID, req.params.memberID)

router.get '/approve/:website/:memberID', (req,res,next)->
	userProfileID = req.session.userProfiles?[req.params.website]
	dating.approveProfile(userProfileID, req.params.memberID)

router.get '/getProfilesToRate', (req,res,next)->
	dating.getProfilesToRate req.session.userID

router.get '/getProfilesToRespond', (req, res, next) ->
	dating.getProfilesToRespond req.session.userID, (err,profiles)->
		if err
			res.json {status: 'error', message: 'Invalid login'}
		else
			res.json {status: 'ok', profiles: profiles}





module.exports = router
