express = require 'express'
service = require './service'
router = express.Router()

router.use '/getPrivateUserData', (req,res,next)-> res.json {data:"This is for private eyes only"}

module.exports = router
