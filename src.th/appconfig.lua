-- 
-- 应用相关配置
-- 访问: appconfig.*
-- Author: tony
-- Date: 2014-11-10 11:52:02
--

local channelInfo = require("channelConfig")

local appconfig = {}
appconfig.LANG 					= "th_TH"
appconfig.LANG_FILE_NAME 		= "lang"
appconfig.UPD_LANG_FILE_NAME 	= "update.updateLang"

appconfig.VERSION_CHECK_URL 	= channelInfo.onlineServerUrl

--邀请好友每个多少钱
appconfig.INVITE_FRIEND_MONEY 	= 500

appconfig.ROOT_CGI_SID          = channelInfo.sid
appconfig.UMENG_APPKEY          = channelInfo.umengAppkey
appconfig.FEED_BACK_INFO         = channelInfo.feedback

return appconfig