express = require 'express'
service = require './service'
router = express.Router()

router.use '/load', (req, res, next) ->
	res.send 'ok'

module.exports = router
