sql = require 'sql-bricks'
FastBricks = require 'fast-bricks'
emailjs   = require "emailjs/email"
uuid = require 'node-uuid'

fb = new FastBricks()
fb.loadConfig 'database-config.cson'

class PublicService

	server: emailjs.server.connect
		user:    "lukasz.korzeniowski@gmail.com",
		password:"G4rsonk4",
		host:    "smtp.gmail.com",
		port: 	 "465"
		ssl:     true

	signup:(user,callback)->
		if !user.username
			callback "User name is required"
			return

		if !user.password
			callback "Password is required"
			return

		if !user.email
			callback "Email is required"
			return

		username = {username:user.username}
		email = {email:user.email}

		fb.query sql.select().from('`user`').where(username), (err,result)=>
			if result.length > 0
				callback "This user name is not available"
				return

			fb.query sql.select().from('`user`').where(email), (err,result)=>
				if result.length > 0
					callback "This email is not available"
					return

				newuser =
					username: user.username
					password: user.password
					email: user.email
					activation_code: uuid.v1()
					verification: 0

				@sendActivationEmail newuser, (err)->
					if err
						console.log err
						callback "There was a problem with the activation email"
					else
						fb.query sql.insert('`user`',newuser), (err,result)=>
							newuser.id = result.insertId
							delete newuser.password
							callback undefined, newuser


	login:(username,password,callback)->
		expr = sql.select().from('`user`').where(
			username: username
			password: password
		)
		fb.query expr, (err,result)->
			if result.length is 0
				callback "This username/password is not valid"
			else
				user = result[0]
				if user.validation is 0
					callback "This account hasn't been verified yet. Check your email"
				else
					callback undefined, user

	sendEmail: (msg,callback)->
		@server.send msg, (err, message)->
			if err
				callback err
			else
				email =
					'`text`': msg.text
					'`from`': msg.from
					'`to`': msg.to
					'`subject`': msg.subject
					'`status`' : "sent"
					'`time_sent`' : new Date()
				fb.query sql.insert('email', email), (err,result)->
					if err
						callback err
					else
						callback()

	sendActivationEmail: (user, callback)->
		msg =
			text:    "http://localhost:3000/rest/activateAccount?code=#{user.activation_code}"
			from:    "Webapp <accounts@webapp.com>"
			to:      user.email
			subject: "Account activation link #{user.activation_code}"
		@sendEmail msg, callback

	activateUser: (activationCode, callback)->
		fb.query sql.select().from('`user`').where({activation_code:activationCode}), (err,results)->
			if results.length is 0
				callback "Error: invalid activation code"
			else
				user = results[0]
				fb.query sql.update('`user`',{verification:1}).where(id:user.id), (err,result)->
					callback()

	requestPasswordReset: (email, callback)->
		if !email or email.length is 0
			callback "Please enter your email"

		fb.query sql.select().from('`user`').where({email:email}), (err,results)=>
			if results.length is 0
				callback "We do not have an account associated with this email"
			else
				user = results[0]
				passcode = uuid.v1()
				msg =
					text:    "http://localhost:3000/rest/resetPassword?code=#{passcode}"
					from:    "Webapp <accounts@webapp.com>"
					to:      user.email
					subject: "Password reset link #{passcode}"
				@sendEmail msg, (err)=>
					if err
						callback err
					else
						fb.query sql.update('`user`',{password_code:passcode}).where(id:user.id), (err,result)=>
							if err
								callback err
							else
								callback()

	resetPassword: (code,callback)->
		fb.query sql.select().from('`user`').where(password_code:code), (err,results)->
			if err
				callback err
			else if results.length is 0
				callback "This code is invalid"
			else
				callback undefined, results[0]

	changePassword: (user,password,callback)->
		if !user
			callback "You must be logged in to change your password"
		if !password
			callback "Password is required"

		fb.query sql.update('`user`',{password:password}).where(id:user.id), (err,result)->
			callback err

module.exports = new PublicService()
