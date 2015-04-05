request = require 'request'
_ = require 'underscore'
async = require 'async'
bunyan = require 'bunyan'

module.exports = ()->
		
	log: bunyan.createLogger {name: 'SA'}

	isLoginPage:(body)->
		reg = ///Don't\shave\san\saccount?///gm
		#reg = ///Sign in///m
		return reg.test(body)

	signIn:(userProfile, callback)->
		@log.debug "Signing in to SA as #{userProfile.settings.login}"
		request = request.defaults {jar: true, gzip: true}
		request.post 
			url: "https://www.seekingarrangement.com/login.php?previous_url=/member/conversations.php?section=inbox"
			# headers:
			# 	'User-Agent': 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/40.0.2214.93 Safari/537.36'
			# 	'Host': 'www.seekingarrangement.com'
			# 	'Origin':'https://www.seekingarrangement.com'
			# 	'Content-Type': 'application/x-www-form-urlencoded'
			# 	'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8'
			form: 
				email: userProfile.settings.login
				pass: userProfile.settings.password
		, (err,resp,body) =>
			failed = @isLoginPage(body)
			if failed
				callback 'Invalid username/password'
			else callback()
	
	sendMessage:(userProfile, memberID, message, callback)->
		@log.debug "Sending message to SA member #{memberID}: '#{message}'"
		callback()
		# request = request.defaults {jar: true, gzip: true}
		# request.post 
		# 	url: "https://www.seekingarrangement.com/member/conversation.php?member_id=#{memberID}&mailbox=inbox"
		# 	form: 
		# 		send_message: 1
		# 		member_id: memberID
		# 		message: message
		# ,(err,httpResponse,body)=>
		# 	if @isLoginPage(body)
		# 		@signIn ()=> @sendMessage userProfile, memberID,message,callback
		# 	else
		# 		callback err,httpResponse,body

	parseConversation:(body)->
		messages = []
		listReg = ///<ul\sclass="message-list[\s\S]*?</ul>///gm
		messageReg = ///<li>[\s\S]*?</li>///gm
		textReg = ///<p\sclass="msg__content\spush--right">([\s\S]*?)</p>///m
		timestampReg = ///<span\sclass="timestamp[\s\S]*?>(.*?)</span>///m
		list = listReg.exec(body)
		senderAvatarReg = ///<span\sclass="avatar"><img\ssrc="(.*?)"///m
		senderNameReg = ///<span\sclass="link-complex__target">(.*?)</span>///m
		while message = messageReg.exec(list[0])
			messages.push
				text: textReg.exec(message[0])?[1]
				timestamp: timestampReg.exec(message[0])?[1]
				senderName: senderNameReg.exec(message[0])?[1]?.trim()
				senderAvatar: senderAvatarReg.exec(message[0])?[1]

		@log.debug "Found #{messages.length} messages"
		return messages

	scrapeConversation:(userProfile, memberID, callback)->
		@log.debug "Scraping SA conversation with #{memberID}"
		request = request.defaults {jar: true, gzip: true}
		request "https://www.seekingarrangement.com/member/conversation.php?member_id=#{memberID}&mailbox=inbox",(err,resp,body)=>
			conversation = 
				messages: @parseConversation(body)
				userID: userProfile.memberID
				memberID: memberID
			callback(undefined, conversation)

	parseProfile:(body)->
		nameReg = ///<div\sclass="page-title">([\s\S]*?)<///m
		ageReg = ///primary-profile-description">([\s\S]*?)<///m
		locationReg = ///primary-profile-description">[\s\S]*?<span\sclass="bullet"></span>([\s\S]*?)</div>///m
		activeReg = ///<div>[\s]*?<b>Active</b>[\s]*?</div>[\s]*?<span\sclass="timestamp">([\s\S]*?)</span>///m
		joinedReg = ///<div>[\s]*?<b>Joined</b>[\s]*?</div>[\s]*?<span\sclass="timestamp">([\s\S]*?)</span>///m
		taglineReg = ///<p\sdata-section="heading"><span\sdata-translated="no">([\s\S]*?)</span>///m
		info1Reg = ///<h4>About\sMe</h4>[\s]*<p\sclass="user-content"\sdata-section="description"><span\sdata-translated="no">([\s\S]*?)</span>///m
		info2Reg = ///<h4>What\sI'm\slooking\sfor</h4>[\s\S]*<p\sclass="user-content"\s\sdata-section="arrangement"><span\sdata-translated="no">([\s\S]*?)</span>///m
		photosReg = ///<li\sclass="grid__item\sphoto-grid__item">[\s]*<a\shref="(.*?)"///gm
		avatarReg = ///<img\sid="js-main-img"\sclass="ProfileAvatar-img"\ssrc="(.*?)"///m
		data =
			avatar: avatarReg.exec(body)?[1]
			name: nameReg.exec(body)?[1]?.trim()
			age: ageReg.exec(body)?[1]?.trim()
			location: locationReg.exec(body)?[1]?.trim()
			active: activeReg.exec(body)?[1]?.trim()
			joined: joinedReg.exec(body)?[1].trim()
			about: info1Reg.exec(body)?[1].replace(/[\n\r]+/g, '').replace(/\s{2,10}/g, ' ').trim() + " " + info2Reg.exec(body)?[1].replace(/[\n\r]+/g, '').replace(/\s{2,10}/g, ' ').trim()
			tagline: taglineReg.exec(body)?[1].trim()
			photos: []
		while photo = photosReg.exec(body)
			data.photos.push photo?[1]

		return data

	scrapeProfile:(userProfile, memberID, callback)->
		@log.debug "Scraping SA profile of member #{memberID}"
		# set request session to match user profile
		request = request.defaults {jar: true, gzip: true}
		request "https://www.seekingarrangement.com/member/#{memberID}/view?conversation-inbox", (err, resp, body)=>
			callback undefined, @parseProfile(body)				
	
	parseInbox:(body)->
		con = []
		messageReg = ///<li\sclass="convo-list-item[\s\S]*?</li>///gm
		memberIdReg = ///member_id=(.*?)&///m
		
		while message = messageReg.exec(body)
			con.push
				memberID: message?[0]?.match(memberIdReg)?[1]				
		
		@log.debug "Found conversations with #{con.length} members"
		return con
	
	scrapeInbox:(userProfile, callback)->
		@log.debug 'Scraping SA inbox'
		query = 
			section:'inbox'
			pg_page:1
			pg_perpage:25
			pg_width:1

		request = request.defaults {jar: true, gzip: true}
		request.get 
			url: "https://www.seekingarrangement.com/member/conversations.php"
			qs: query
		, (err,resp,body) =>
			previews = @parseInbox body
			hasNextPage = body.match(///<span\sclass="pager__next pager__action"></span>///m) isnt null
			async.whilst ()=> 
				hasNextPage
			,(cb)=>
				query.pg_page++
				request.get 
					url: "https://www.seekingarrangement.com/member/conversations.php"
					qs: query
				, (err,resp,body) =>
					previews.concat @parseInbox(body)
					hasNextPage = body.match(///<span\sclass="pager__next pager__action"></span>///gm) isnt null
					cb()
			,(err)=>
				conversations = []
				async.each previews, (notification, cb)=>					
					@scrapeConversation userProfile, notification.memberID, (err, conv)->
						conversations.push conv
						cb()
				,(err)-> callback(err, conversations)				

	parseSearch:(body)->
		profiles = []
		itemReg = ///result-list-item([\s\S]*?)result__body///gm
		urlReg = ///
			member/(.*?)/
			///m
		avatarReg = ///src="(.*?)"///m

		while profile = itemReg.exec(body)	
			detail = profile?[0]	
			profiles.push
				memberID: detail?.match(urlReg)?[1]	
				avatar: detail?.match(avatarReg)?[1]				
		@log.debug "Parsed #{profiles.length} profiles"
		return profiles		

	scrapeSearch:(userProfile, callback)->
		@log.debug 'Scraping SA member search'
		query = 
			country_id:38
			state_id:502
			city_id:5946940
			distance:25
			body_type: ['slim','athletic','average']
			age_high:30
			latitude:43.219299316406
			longitude:-79.683898925781
			sort:'created_dt_desc'
			photo:'on'
			last_login_dt:1391311643
			pg_page:1
			pg_perpage:25
			pg_width:7
			pg_total:510

		request = request.defaults {jar: true, gzip:true}
		request.get 
			url: "https://www.seekingarrangement.com/member/search.php"
			qs: query				
		, (err,resp,body) =>
			lastPageReg = ///<li\sclass="last-page[\s\S]*?pg_page=(\d*)&///m
			lastPage = parseInt(lastPageReg.exec(body)[1])
			profiles = @parseSearch(body)
			query.pg_page = 2
			async.whilst ()=> 
				query.pg_page <= 3 #lastPage
			,(callbackX)=>
				request.get 
					url: "https://www.seekingarrangement.com/member/search.php"
					qs: query		
				,(err,resp,body) =>
					profiles.concat @parseSearch(body)
					query.pg_page++
					callbackX()
			    
			,(err)-> callback(undefined, profiles)
			
	blockProfile:(userProfile, memberID, callback)->	
		@log.debug "Blocking SA member #{memberID}"
		request = request.defaults {jar: true, gzip:true}
		request.get "https://www.seekingarrangement.com/member/addblock.php?member_id=#{memberID}", callback
		
	unblockProfile:(userProfile, memberID, callback)->
		@log.debug "TODO: Blocking SA member #{memberID}"
		callback()

			

					
						

				