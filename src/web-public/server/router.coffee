express = require 'express'
service = require './service'
multer  = require('multer')
router = express.Router()

router.use multer(
	dest: './graphicFiles/'
	onFileUploadComplete: (file,req,res)->
		console.log "File upload complete"
)

router.use '/uploadGraphic', (req,res,next)->
	console.log req.files
	res.json {result: 'success', file: req.files.file.name}

router.use '/getPrivateUserData', (req,res,next)-> res.json {data:"This is for private eyes only"}

module.exports = router
