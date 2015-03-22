sql = require 'sql-bricks'
FastBricks = require 'fast-bricks'

fastB = new FastBricks()
fastB.loadConfig 'database-config.cson'
query = fastB.query

class PublicService


module.exports = new PublicService()
