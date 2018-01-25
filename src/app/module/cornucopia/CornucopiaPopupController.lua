-- Author: thinkeras3@163.com
-- Date: 2015-08-11 15:31:50
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.

local CornucopiaPopupController = class("CornucopiaPopupController")
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
local CornucopiaInfoDialog = import(".CornucopiaInfoDialog")
local GetedRewardDialog = import(".GetedRewardDialog")

function CornucopiaPopupController:ctor(view)
    self.view_ = view
end
function CornucopiaPopupController:getSelfCornucopia()
	self.view_:setLoading(true)
	self.getSelfCorRequestId_ = nk.http.getSelfCornucopia(nk.userData["aUser.mid"],
		function(data)
			--CornucopiaInfoDialog.new():show(data)
			self.view_:setLoading(false)
			self.view_:setMyCorData(data)
		end,

		function(errdata)
			self.view_:setLoading(false)
			 nk.ui.Dialog.new({
                    messageText = bm.LangUtil.getText("COMMON", "REQUEST_DATA_FAIL"), 
                    secondBtnText = bm.LangUtil.getText("COMMON", "RETRY"), 
                    callback = function (type)
                        if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                            self:getSelfCornucopia()
                        end
                    end
                })
                    :show()
		end
	)
end

function CornucopiaPopupController:dispose()
     nk.http.cancel(self.getSelfCorRequestId_)
     nk.http.cancel(self.openLockRequestId_)
     nk.http.cancel(self.plantRequestId_)
     nk.http.cancel(self.addSpeedRequestId_)
     nk.http.cancel(self.getLevelRankIdRequestId_)
     nk.http.cancel(self.getMyRecRequestId_)
     nk.http.cancel(self.shareToGetSeedRequest_)
     nk.http.cancel(self.reapMySeedRequestId_)
     nk.http.cancel(self.stealFriendSeedRequestId_)
end

function CornucopiaPopupController:openLock(id)
	self.view_:setLoading(true)
	self.openLockRequestId_ = nk.http.openLock(nk.userData["aUser.mid"],id,

	function(data)
		---CornucopiaInfoDialog.new():show(data)
		self.view_:setLoading(false)
		self:getSelfCornucopia()
		nk.userData["aUser.money"] = checkint(data.money);
		nk.TopTipManager:showTopTip(bm.LangUtil.getText("DORNUCOPIA", "OPEN_LOCK_SUCC"))
		--cost 
	end,
	function(errdata)
		self.view_:setLoading(false)
		if errdata and errdata.errorCode then
			if checkint(errdata.errorCode)==-6 then--前面的没有解锁
				nk.TopTipManager:showTopTip(bm.LangUtil.getText("DORNUCOPIA", "OPEN_LOCK_FIAL"))
			elseif checkint(errdata.errorCode)==-4 then
				nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "SEND_CHIP_NOT_ENOUGH_CHIPS"))
			else
				nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "REQUEST_DATA_FAIL"))
			end
		else
			nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "REQUEST_DATA_FAIL"))
		end
	end
	)
end
function CornucopiaPopupController:plantSeed(plantid,seedid)
	self.view_:setLoading(true)
	self.plantRequestId_ = nk.http.plantSeed(nk.userData["aUser.mid"],seedid,plantid,

	function(data)
		self.view_:setLoading(false)--种植成功
		nk.TopTipManager:showTopTip(bm.LangUtil.getText("DORNUCOPIA", "GORW_TERR_SUCC"))
		self:getSelfCornucopia()
	end,

	function(errdata)
		self.view_:setLoading(false)
		nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "REQUEST_DATA_FAIL"))
	end
	)
end

function CornucopiaPopupController:addSpeed(plantid)
	self.view_:setLoading(true)
	self.addSpeedRequestId_ = nk.http.addSpeedForTree(nk.userData["aUser.mid"],plantid,
	function(data)
		self.view_:setLoading(false)
		self:getSelfCornucopia()--加速成功
		nk.TopTipManager:showTopTip(bm.LangUtil.getText("DORNUCOPIA", "ADD_SPEED_SUCC"))
	end,

	function(errdata)
		self.view_:setLoading(false)
		if errdata and errdata.errorCode then
			if checkint(errdata.errorCode)==-2 then--加速水不足
				nk.TopTipManager:showTopTip(bm.LangUtil.getText("DORNUCOPIA", "NOT_SPEED_WATER"))
			else
				nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "REQUEST_DATA_FAIL"))
			end
		else
			nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "REQUEST_DATA_FAIL"))
		end
	end
	)
end

function CornucopiaPopupController:reapMySeed(plantid)
	self.view_:setLoading(true)
	local uid = nk.userData["aUser.mid"]
	self.reapMySeedRequestId_ = nk.http.reapMySeed(uid,plantid,
	
	

	function(data)
		self.view_:setLoading(false)
		self:getSelfCornucopia()
		nk.userData["aUser.money"] = checkint(data.money);
		nk.TopTipManager:showTopTip(bm.LangUtil.getText("DORNUCOPIA", "GETED_COR_MONEY",data.getMoney))
		if checkint(data.getJs) == 1 then
			GetedRewardDialog.new(self.view_):show(3)
		end
	end,

	function(errdata)
		self.view_:setLoading(false)
		nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "REQUEST_DATA_FAIL"))
	end
	)
end

function CornucopiaPopupController:getLevelRanlIds()

	local uid = nk.userData["aUser.mid"]
	self.getLevelRankIdRequestId_ = nk.http.getLevelRanlIds(uid,
	function(data)
		self.view_:setFriendList(data)
	end,

	function(errdata)

		self.view_:setFriendList({})
	end
	)

end

function CornucopiaPopupController:getFriendCornucopia(mid)
	self.view_:setLoading(true)
	self.getSelfCorRequestId_ = nk.http.getFriendCornucopia(mid,
		function(data)
			self.view_:setLoading(false)
			self.view_:setFriendCorData(data)
		end,
		function(errdata)
			self.view_:setLoading(false)
			nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "REQUEST_DATA_FAIL"))
		end
	)
end
function CornucopiaPopupController:stealFriendSeed(fid,bowlId)
	self.view_:setLoading(true)
	self.stealFriendSeedRequestId_ = nk.http.getFriendstealSeed(
		nk.userData["aUser.mid"],
		fid,bowlId,

		function(data)
			self.view_:setLoading(false)
			nk.userData["aUser.money"] = checkint(data.money);
			--nk.TopTipManager:showTopTip('偷到'..data.getMoney);
			nk.TopTipManager:showTopTip(bm.LangUtil.getText("DORNUCOPIA", "GETED_FRIEND_MONEY",data.getMoney))
			if data.sendseed then
				if checkint(data.sendseed) == 401 then
					GetedRewardDialog.new(self.view_):show(2)
				elseif checkint(data.sendseed) == 402 then
					GetedRewardDialog.new(self.view_):show(1)
				end
				self:getSelfCornucopia()
			end
		end,
		function(errdata)
			self.view_:setLoading(false)
			if errdata and errdata.errorCode then 
				if checkint(errdata.errorCode)== -4 then
					nk.TopTipManager:showTopTip(bm.LangUtil.getText("DORNUCOPIA", "GETED_FIRNED_FIAL"))
				elseif checkint(errdata.errorCode)== -3 then
					nk.TopTipManager:showTopTip(bm.LangUtil.getText("DORNUCOPIA", "GETED_FIRNED_FIAL2"))
				else
					nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "REQUEST_DATA_FAIL"))
				end
			else
				nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "REQUEST_DATA_FAIL"))
			end
		end
	)
end
function CornucopiaPopupController:getMyRec()
	-- body
	self.view_:setLoading(true)
	local uid = nk.userData["aUser.mid"]
	self.getMyRecRequestId_ = nk.http.getMyRec(uid,
	
		function(data)
			self.view_:setLoading(false)
			self.view_:setMyRecListData(data)
		end,

		function(errdata)
			self.view_:setLoading(false)
			 nk.ui.Dialog.new({
                    messageText = bm.LangUtil.getText("COMMON", "REQUEST_DATA_FAIL"), 
                    secondBtnText = bm.LangUtil.getText("COMMON", "RETRY"), 
                    callback = function (type)
                        if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                            self:getMyRec()
                        end
                    end
                })
                    :show()
		end
	)
end
function CornucopiaPopupController:shareToGetSeed(mode)
	local uid = nk.userData["aUser.mid"]
	self.shareToGetSeedRequest_ = nk.http.shareToGetSeed(
		uid,
		mode,
		function(data)
			if data and data.getseed then
				if checkint(data.getseed)==1 then
					nk.TopTipManager:showTopTip(bm.LangUtil.getText("DORNUCOPIA", "GETED_SILVER"))
					self:getSelfCornucopia()
				end
			end
		end,
		function(errorCode)

		end

	)
end
return CornucopiaPopupController
