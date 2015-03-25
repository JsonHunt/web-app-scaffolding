express = require('express')
path = require('path')
favicon = require('serve-favicon')
logger = require('morgan')
cookieParser = require('cookie-parser')
bodyParser = require('body-parser')
session = require('express-session')
SessionStore = require('express-mysql-session')

app = express()

# view engine setup
app.set 'views', path.join(__dirname, 'views')
app.set 'view engine', 'jade'
# uncomment after placing your favicon in /public
#app.use(favicon(__dirname + '/public/favicon.ico'));
app.use logger('dev')
app.use bodyParser.json()
app.use bodyParser.urlencoded(extended: false)
app.use cookieParser()

sessionStore = new SessionStore
	host: 'localhost'
	port: 3306
	user: 'root'
	password: 'garsonka'
	database: 'webapp'

app.use(session({
		key: 'session_cookie_name',
		secret: 'session_cookie_secret',
		store: sessionStore,
		resave: true,
		saveUninitialized: true
}))

app.use express.static(path.join(__dirname, 'web-public/client'))
app.use '/admin', express.static(path.join(__dirname, 'web-admin/client'))
app.use '/private', express.static(path.join(__dirname, 'web-private/client'))
app.use '/rest', require './web-public/server/router'
app.use '/admin/rest', require './web-admin/server/router'
app.use '/private/rest', require './web-private/server/router'

# catch 404 and forward to error handler
app.use (req, res, next) ->
	err = new Error('Not Found')
	err.status = 404
	next err
	return

# error handlers

# development error handler
# will print stacktrace
if app.get('env') == 'development'
	app.use (err, req, res, next) ->
		res.status err.status or 500
		res.render 'error',
			message: err.message
			error: err
		return

# production error handler
# no stacktraces leaked to user
app.use (err, req, res, next) ->
	res.status err.status or 500
	res.render 'error',
		message: err.message
		error: {}
	return


module.exports = app
