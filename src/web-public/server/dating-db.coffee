mongoose = require 'mongoose'

MessageSchema= mongoose.Schema
	website: String
	from: Array  # {type: Schema.Types.ObjectId,ref: 'Profile'}
	to: Array # {type:Schema.Types.ObjectId,ref: 'Profile'}
	timestamp: String
	text: String
	sequence: Number

UserSchema= mongoose.Schema
	login: String
	password: String
	websiteProfiles: [ { type: mongoose.Schema.Types.ObjectId, ref: 'UserProfile' } ]
	settings:
		location: String
		locationFilter: Boolean

UserProfileSchema= mongoose.Schema
	userID: String
	website: String
	settings:
		login: String
		password: String
	memberID: String
	hasMessages: Array
	favorites: Array #[ { type: Schema.Types.ObjectId, ref: 'Profile' } ]
	blocked: Array #[ { type: Schema.Types.ObjectId, ref: 'Profile' } ]
	conversation: Array #[ { type: Schema.Types.ObjectId, ref: 'Profile' } ]

ProfileSchema= mongoose.Schema
	website: String
	memberID: String
	avatar: String
	photos: Array
	location: String
	name: String
	age: String
	about: String
	tagline: String
	active: String
	joined: String
	lastFetched: Date

exports.connect = (callback)->
	mongoose.connect('mongodb://localhost/dating')
	mongoose.connection
	.on('error', console.error.bind(console, 'connection error:'))
	.once 'open', (cb) ->
		console.log 'Connection open'
		callback?()

exports.disconnect = ()->
	mongoose.connection.close()

exports.UserProfile = mongoose.model 'UserProfile', UserProfileSchema
exports.User = mongoose.model 'User', UserSchema
exports.Profile = mongoose.model 'Profile', ProfileSchema
exports.Message = mongoose.model 'Message', MessageSchema
