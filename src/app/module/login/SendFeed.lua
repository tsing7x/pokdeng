--
-- Author: ThinkerWang
-- Date: 2015-08-26 11:11:50
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- Facebook feed controller
--
local SendFeed = class("SendFeed")

function SendFeed:ctor()

end
--连续登录feed
function SendFeed:login_reward_(errorCallback)
	nk.DReport:report({id = "loginFeedClk"})
	local feedData = clone(bm.LangUtil.getText("FEED", "LOGIN_REWARD"))
	feedData.name = bm.LangUtil.formatString(feedData.name, nk.userData.loginReward.addMoney)
	self:share_(feedData,
	function() 
		nk.DReport:report({id = "loginFeedShr"})
	end,
	errorCallback)
end
--兑换奖励feed
function SendFeed:exchange_code_(codeReward,errorCallback)
	codeReward = codeReward or ""
	nk.DReport:report({id = "exFeedClk"})
	local feedData = clone(bm.LangUtil.getText("FEED", "EXCHANGE_CODE"))
    feedData.name = bm.LangUtil.formatString(feedData.name, codeReward)
    self:share_(feedData,
    function()  
    	nk.DReport:report({id = "exFeedShr"})
    end,
    errorCallback)
end
--大转盘
function SendFeed:wheel_act_(resultCallback,errorCallback)
	nk.DReport:report({id = "wheelFeedClk"})
	self:share_(bm.LangUtil.getText("FEED", "WHEEL_ACT"),
		function()
			resultCallback()
			nk.DReport:report({id = "wheelFeedShr"})
		end,
		errorCallback)
end
--升级feed
function SendFeed:up_grade_reward_(level,reward,resultCallback,errorCallback)
	nk.DReport:report({id = "upGradeFeedClk"})
	local feedData = clone(bm.LangUtil.getText("FEED", "UPGRADE_REWARD"))
    feedData.name = bm.LangUtil.formatString(feedData.name, level, reward)
    feedData.picture = bm.LangUtil.formatString(feedData.picture, level)
    self:share_(feedData,
    	function()
    		nk.DReport:report({id = "upGradeFeedShr"})
    		resultCallback()
    	end,

    errorCallback)
end
--注册
function SendFeed:login_register_()
	nk.DReport:report({id = "reFeedClk"})
	self:share_(bm.LangUtil.getText("FEED", "LOGIN_REGISTER")
		,
		function()
			nk.DReport:report({id = "reFeedShr"})
		end

	)
end
--免费金币
function SendFeed:free_coin_()
	nk.DReport:report({id = "freeCoinClk"})
	self:share_(bm.LangUtil.getText("FEED", "FREE_COIN"),
		function()
			nk.DReport:report({id = "freeCoinShr"})
		end

		);
end
--使用加速药水
function SendFeed:use_speed_(resultCallback,errorCallback)
	nk.DReport:report({id = "getSpeedClk"})
	self:share_(bm.LangUtil.getText("FEED", "COR_GETED_SPEED_WATER"),
		function()
			resultCallback()
			nk.DReport:report({id = "getSpeedShr"})
		end,errorCallback
	)
end
--获取金种子
function SendFeed:get_ingot_(resultCallback,errorCallback)
	nk.DReport:report({id = "getIngotClk"})
	self:share_(bm.LangUtil.getText("FEED", "COR_GETED_INGOT"),

		function()
			resultCallback()
			nk.DReport:report({id = "getIngotShr"})
		end
		,errorCallback
	)
end
--获取银种子
function SendFeed:get_silver_(resultCallback,errorCallback)
	nk.DReport:report({id = "getSilverClk"})
	self:share_(bm.LangUtil.getText("FEED", "COR_GETED_SILVER"),

		function()
			nk.DReport:report({id = "getSilverShr"})
			resultCallback()
		end,errorCallback
	)
end
--分享我的聚宝盆
function SendFeed:share_my_cor_(resultCallback)

	-- nk.http.winFiveReward(
 --        		function(data)
 --        			local addMoney = checkint(data.addmoney)
 --        			nk.TopTipManager:showTopTip(bm.LangUtil.getText("CRASH", "GET_REWARD", addMoney))
 --        			nk.userData['aUser.money'] = checkint(data.money)
 --        		end,

 --        		function(data)

 --        		end

 --        	)

	nk.DReport:report({id = "shareCorClk"})
	self:share_(bm.LangUtil.getText("FEED", "COR_SHARE_MY_COR"),
		function()
			resultCallback()
			nk.DReport:report({id = "shareCorShr"})
		end
	)
end
--
--连胜五局
function SendFeed:win_five_()
	nk.DReport:report({id = "winFiveClk"})
	self:share_(bm.LangUtil.getText("FEED", "CON_WIN_FIVE"),
		function()
			
            if device.platform == "android" or device.platform == "ios" then
                cc.analytics:doCommand{command = "event",
                args = {eventId = "win5feed"}}
            end

        	nk.DReport:report({id = "winFiveShr"})

        	nk.http.winFiveReward(
        		function(data)
        			local addMoney = checkint(data.addmoney)
        			nk.TopTipManager:showTopTip(bm.LangUtil.getText("CRASH", "GET_REWARD", addMoney))
        			nk.userData['aUser.money'] = checkint(data.money)
        		end,

        		function(data)

        		end

        	)
        	
		end
	)
end

--五倍牌型
function SendFeed:five_Card_()
	nk.DReport:report({id = "fiveMuClk"})
	self:share_(bm.LangUtil.getText("FEED", "FIVE_MUL_CARD"),
		function()
			
            if device.platform == "android" or device.platform == "ios" then
                cc.analytics:doCommand{command = "event",
                args = {eventId = "card5mu"}}
            end
        	
        	nk.DReport:report({id = "fiveMuShr"})
		end
	)
end

function SendFeed:unionAct_final_reward_(resultCallBack, errCallBack)
	-- body
	nk.DReport:report({id = "unionActFinalRewardShrClk"})
	-- dump(bm.LangUtil.getText("FEED", "UNIONACT_FINAL_REWARD"), "feedData :===================")
	self:share_(bm.LangUtil.getText("FEED", "UNIONACT_FINAL_REWARD"),
		function()
			-- body
			nk.DReport:report({id = "unionActFinalRewardShrSucc"})
			resultCallBack()
		end,

		function()
			-- body
			errCallBack()
		end)
end

function SendFeed:actCenter_share_fb(shareData, resultCallBack, errCallBack)
	-- body
	-- nk.DReport:report({id = "admadawhj"})

	self:share_(shareData, function()
			-- body
			-- nk.DReport:report({id = "unionActFinalRewardShrSucc"})
			resultCallBack()
		end,
		function()
			-- body
			errCallBack()
		end)
end

function SendFeed:win_match(rank)
	local feedData = clone(bm.LangUtil.getText("FEED", "WIN_MATCH"))
    feedData.name = bm.LangUtil.formatString(feedData.name, nk.userData["aUser.name"], rank)
    self:share_(feedData,
    	function()
    		nk.DReport:report({id = "matchwin"})		
    	end,
    nil)

end

--feed_data 分享内容
--succFunc,failFunc只有回调的时候才传
function SendFeed:share_(feed_data,succFunc,failFunc)
    local feedData = clone(feed_data)
        nk.Facebook:shareFeed(feedData, function(success, result)
        if not success then
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("FEED", "SHARE_FAILED"))
            if failFunc then
            	failFunc()
            end
        else
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("FEED", "SHARE_SUCCESS")) 
            if succFunc then
            	succFunc()
            end
        end
    end)
end

return SendFeed