sql = require 'sql-bricks'
FastBricks = require 'fast-bricks'

fastB = new FastBricks()
fastB.loadConfig 'database-config.cson'
query = fastB.query

class PublicService

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

		query sql.select().from('user').where(username), (err,result)->
			if result.length > 0
				callback "This user name is not available"
				return

			query sql.select().from('user').where(email), (err,result)->
				if result.length > 0
					callback "This email is not available"
					return

				query sql.insert('user',user), (err,result)->
					user.id = result.insertId
					callback undefined, user
					# TODO: send activation email


	login:(username,password,callback)->
		expr = sql.select().from('user').where(
			username: username
			password: password
		)
		query expr, (err,result)->
			if result.length is 0
				callback "This username/password is not valid"
			else
				callback undefined, result[0]



module.exports = new PublicService()
