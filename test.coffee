# sql = require 'sql-bricks'
# FastBricks = require 'fast-bricks'
test = require 'fast-bricks/gen/dupa.js'

console.log test

# fastB = new FastBricks()
# fastB.loadConfig 'database-config.cson'
# q = fastB.prototype.query
#
# expr = sql.select().from("`user`")
# expr.log = true
# q expr, (err,users)->
# 	for user in users
# 		console.log "#{user.id} : #{user.username}"
# 	return
