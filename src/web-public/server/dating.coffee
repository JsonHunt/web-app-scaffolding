_ = require 'underscore'
bunyan = require 'bunyan'
async = require 'async'
db = require './dating-db'
XDate = require 'xdate'
db.connect()

User = db.User
UserProfile = db.UserProfile
Profile = db.Profile

module.exports = (scrapers)->
	websiteService: scrapers
	log: bunyan.createLogger {name: 'Dating'}

	deleteAll:(callback)->
		async.parallel [
			(cb)-> User.remove {}, cb()
			(cb)-> UserProfile.remove {}, cb()
		],()=>
			@log.info 'Database emptied'
			callback()

	getUser:(userID,callback)->
		User.findById userID, (err, user)->
			if user is null
				callback 'User not found'
				return
			UserProfile.find { userID: user._id }, (err,profiles)->
				u = user.toObject()
				u.websiteProfiles = {}
				for prof in profiles
					u.websiteProfiles[prof.website] = prof.toObject()
				callback undefined, u

	register:(login,password, callback)->
		if password is undefined
			callback 'Password is required'
			return
		if login is undefined
			callback 'Login is required'
			return
		User.findOne { login: login }, (err, existing)->
			if existing isnt null
				callback 'This login is already in use'
				return
			new User
				login: login
				password: password
				settings:
					location: ''
					locationFilter: false
			.save callback

	signIn:(login,password, callback)->
		User.findOne { login: login, password: password }, (err,user)->
			if user is null
				callback 'User not found'
				return
			UserProfile.find { userID: user._id }, (err,profiles)->
				u = user.toObject()
				u.websiteProfiles = {}
				for prof in profiles
					u.websiteProfiles[prof.website] = prof.toObject()
				callback undefined, u

	saveSettings:(userID, settings, callback)-> User.findByIdAndUpdate userID, {settings: settings}, callback
	saveWebsiteSettings:(website, userID, settings, callback)->
		UserProfile.findOneAndUpdate
			website: website
			userID: userID
		,
			settings:settings
		, { upsert: true }
		,(err,up)=>
			@websiteService[website].signIn up, callback

	# SINGLE SITE OPERATIONS ( could go on UserProfile model... )

	fetchProfile:(userProfileID, profileID, callback)->
		UserProfile.findById userProfileID, (err,userProfile)=>
			now = new XDate()
			website = userProfile.website
			isExpired = (profile)->
				return true if profile is null or profile is undefined
				return true if profile.lastFetched is null
				last = new XDate(profile.lastFetched)
				return last.diffHours(now) > 24
			Profile.findOne { website: website, memberID: profileID }, (err,profile)=>
				if profile is null or isExpired(profile)
					@websiteService[website].scrapeProfile userProfile, profileID, (err,profileData)->
						profileData.lastFetched = new Date()
						Profile.findOneAndUpdate {website: website, memberID: profileID},profileData,{upsert: true},callback
				else callback undefined, profile

	blockProfile:(userProfileID, profileID, callback)->
		UserProfile.findById userProfileID, (err,userProfile)=>
			if not _.contains userProfile.blocked, profileID
				@websiteService[userProfile.website].blockProfile userProfile, profileID, (err)->
					userProfile.blocked.push profileID
					userProfile.save callback

	sendMessage:(userProfileID, profileID, message, callback)->
		UserProfile.findById userProfileID, (err,userProfile)=>
			@websiteService[userProfile.website].sendMessage userProfile, profileID, message, callback

	approve:(userProfileID, profileID, callback, message)->
		UserProfile.findById userProfileID, (err,userProfile)=>
			if not _.contains userProfile.favorites, profileID
				userProfile.favorites.push profileID
				userProfile.save (err)=>
					@sendMessage(userProfile, profileID, message, callback) if message

	# MULTI SITE OPERATIONS

	getProfilesToRate:(userID, callback)->
		profilesToRate = []
		UserProfile.find { userID: userID }, (err, userProfiles)=>
			async.each userProfiles, (up,cb)=>
				@websiteService[up.website].scrapeSearch up, (err,results)=>
					unrated = _.filter results, (p)->
						return false if _.contains(up.blocked,p.memberID)
						return false if _.contains(up.favorites,p.memberID)
						return false if _.contains(up.conversation, p.memberID)
					async.each unrated, (r,cbX)=>
						@fetchProfile up, r.memberID, (err,prof)->
							profilesToRate.push prof
							cbX()
					,cb()
			, (err)-> callback undefined, profilesToRate

	getProfilesToRespond:(userID, callback)->
		toRespond = []
		UserProfile.find {userID: userID}, (err,userProfiles)=>
			async.each userProfiles, (up,cb)=>
				@websiteService[up.website].signIn up, (err)=>
					if err
						callback err
						return
					else
						@websiteService[up.website].scrapeInbox up, (err,conversations)=>
							members = _.pluck conversations, 'memberID'
							up.conversation = _.union up.conversation, members
							up.save (err)=>
								# to save, or not to save? (messages)
								# applicable = _.filter conversations, (conv)->
								# 	return false if conv.userID is not up.memberID
								# 	return false if _.contains up.blocked, conv.memberID

								async.each conversations, (conv,cbX)=>
									@fetchProfile up, conv.memberID, (err,prof)->
										obj = prof.toObject()
										obj.messages = conv.messages
										toRespond.push obj
										cbX()
								, cb()
			, (err)-> callback undefined, toRespond
