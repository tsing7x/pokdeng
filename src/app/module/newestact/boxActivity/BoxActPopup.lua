-- Author: thinkeras3@163.com
-- Date: 2015-09-08 10:0:39
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.

local BoxItem = import(".BoxItem")
local NotEnoughMoneyTip = import(".BoxActNotEnoughMoneyTip")
local BoxActTenOpenBoxDialog = import(".BoxActTenOpenBoxDialog")
local BoxActMyRecordDialog = import(".BoxActMyRecordDialog")
local BoxActGetedRewardDialog = import(".BoxActGetedRewardDialog")
local StorePopup = import("app.module.newstore.StorePopup")


local WIDTH = 860
local HEIGHT = 366
local BG_TOP_GAP = 13
local RIGHT_TOP_GAP = 35

local ITEM_WITH = 248
local ITEM_HEIGHT = 157


local BoxActivity = class("BoxActivity", function() return display.newNode() end)

function BoxActivity:ctor(popup)
	self.popup_ = popup
	self:setNodeEventEnabled(true)
	self:createNode_()
end

function BoxActivity:createNode_()
	display.newSprite("#actBox_bg.jpg", 0, 0)
	:addTo(self)
	:pos(0,15)

	display.newScale9Sprite("#actBox_egg_bg.png")
	:addTo(self)
	:pos(-WIDTH/4+20,0)
	--:setScaleX(-1)

	display.newSprite("#actBox_right.png")
    :addTo(self)
    :pos(WIDTH/4+10,RIGHT_TOP_GAP)

    cc.ui.UIPushButton.new({normal = "#actBox_tenOpenBox.png", pressed = "#actBox_tenOpenBox.png"})
    :addTo(self)
    :pos(WIDTH/4+10,-128)
    :onButtonClicked(buttontHandler(self, self.tenOpenBox))

    display.newSprite("#actBox_icon.png")
    :addTo(self)
    :pos(WIDTH/4+180,-90)

    self.boxManager_ = {}
    for i=1,4 do
    	local boxItem = BoxItem.new(self)
    	boxItem:setBoxId(i)
    	boxItem:setScale(0.85)
    	table.insert(self.boxManager_,boxItem)
    end
    self.boxManager_[1]:pos(-WIDTH/4-80 ,75-40):addTo(self)
    self.boxManager_[2]:pos(-WIDTH/4 + ITEM_WITH - 75-70,75-40):addTo(self)
    self.boxManager_[3]:pos(-WIDTH/4 + ITEM_WITH - 75-50,75-ITEM_HEIGHT-5):addTo(self)
    self.boxManager_[4]:pos(-WIDTH/4-100,75-ITEM_HEIGHT-5):addTo(self)

    display.newSprite("#actBox_coinBg.png")
    :addTo(self)
    :pos(-WIDTH/4,173)

    display.newTTFLabel({text = bm.LangUtil.getText("BOXACT","MY_COIN"), color = cc.c3b(0x6c, 0x28, 0x03), size = 24, align = ui.TEXT_ALIGN_CENTER})
	:addTo(self)
	:pos(-WIDTH/4-150,172)

	self.my_coin_ = display.newTTFLabel({text = "1", color = cc.c3b(0xfe, 0xd8, 0x83), size = 24, align = ui.TEXT_ALIGN_CENTER})
	:addTo(self)
	:pos(-WIDTH/4,172)
	self:upDate()

    display.newSprite("#actBox_timeBg.png")
    :addTo(self)
    :pos(WIDTH/4-50,173)

    display.newTTFLabel({text = bm.LangUtil.getText("BOXACT","ACT_TIME"), color = cc.c3b(0x6c, 0x28, 0x03), size = 24, align = ui.TEXT_ALIGN_CENTER})
	:addTo(self)
	:pos(WIDTH/4-250,172)

	self.actTime_ = display.newTTFLabel({text = "11 ก.ย.-12 ต.ค. 58", color = cc.c3b(0xfe, 0xd8, 0x83), size = 22, align = ui.TEXT_ALIGN_CENTER})
	:addTo(self)
	:pos(WIDTH/4-40,172)


	cc.ui.UIPushButton.new({normal = "#actBox_record_bt.png", pressed = "#actBox_record_bt.png"})
    :addTo(self)
    :pos(WIDTH/4+140,172)
   -- :setButtonLabel("normal", display.newTTFLabel({text = bm.LangUtil.getText("BOXACT","RECORD"), color = cc.c3b(0x83, 0x11, 0x08), size = 20, align = ui.TEXT_ALIGN_CENTER}))
    :onButtonClicked(handler(self, self.recordClick_))

    self.eggTimeRequestId_ =  nk.http.getEggActTime(
    function(data)
    	self.eggTimeRequestId_ = nil
    	if self.actTime_ then
    		self.actTime_:setString(data.time or "13 - 27 ต.ค. 58")
    	end
    	
    end,
    function(errordata)
    	-- dump(errordata,"ddddd")
    	self.eggTimeRequestId_ = nil
    	if self.actTime_ then
    		self.actTime_:setString("13 - 27 ต.ค. 58")
    	end
    end

    )
end


function BoxActivity:tenOpenBox()
	--
	if self.boxRunning_ == true then
		return
	end
	if nk.userData["aUser.money"] < 80000 then
		NotEnoughMoneyTip.new(self):show()
		return
	end
	self.boxRunning_ = true
	self.openTenBoxRequest_ = nk.http.tenOpenLuckBox(
		function(data)
			-- nk.http.cancel(self.openTenBoxRequest_)
			self.openTenBoxRequest_ = nil
			self.tenRockGift = data.win.rid;
			self.myMoney = data.win.money;

			self.giftid = checkint(data.giftid)


			for i=1,4 do
				self.boxManager_[i]:onlyRock()
			end
			
			self.action_ = self:schedule(function ()
				self:stopAction(self.action_)
				self:runBigAni()
			end,2)
		end,

		function(errordata)
			-- nk.http.cancel(self.openTenBoxRequest_)
			self.openTenBoxRequest_ = nil
			self.boxRunning_ = false
			if errordata and errordata.errorCode then
				if checkint(errordata.errorCode==-1) then
					NotEnoughMoneyTip.new(self):show()
				else
					nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "BAD_NETWORK")..errordata.errorCode)
				end
			else
				nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
			end
		end
		)
end

function BoxActivity:runBigAni()
	self.animation_ = display.newSprite("#actBox_bigAnim.png")
    :addTo(self)
    self.animation_:scale(0.2)
    transition.scaleTo(self.animation_, {time = 0.5, easing = "BACKOUT", scale = 1, onComplete=
    function()
    	self.action_ = self:schedule(function ()
    		BoxActTenOpenBoxDialog.new(self.tenRockGift):show()
    		self:stopAction(self.action_)
    		self.boxRunning_ = false
    		self.animation_:removeFromParent()
    		self.animation_ = nil
    		self:upDateResult()
    	end,1)

     end})
end

function BoxActivity:recordClick_()
	BoxActMyRecordDialog.new():show()
end

function BoxActivity:goShop_()
	self.popup_:hide()
	StorePopup.new():showPanel()
end
function BoxActivity:goPlay_()
	self.popup_.callback_("playnow")
	self.popup_:hide()
end

function BoxActivity:upDate()
	self.my_coin_:setString(bm.formatNumberWithSplit(nk.userData["aUser.money"]));
end
function BoxActivity:upDateResult()
	nk.userData["aUser.money"] = self.myMoney
	if self.giftid > 0 then
		nk.userData["aUser.gift"] = self.giftid
	end
	self:upDate()
end
function BoxActivity:onCleanup()
	if self.eggTimeRequestId_ then
		nk.http.cancel(self.eggTimeRequestId_)
	end

	if self.openBoxRequest_ then
		nk.http.cancel(self.openBoxRequest_)
	end

	if self.openTenBoxRequest_ then
		nk.http.cancel(self.openTenBoxRequest_)
	end
end
--
function BoxActivity:toOpenBox(boxid)
	if self.boxRunning_ == true then
		return
	end
	if nk.userData["aUser.money"] < 8000 then
		NotEnoughMoneyTip.new(self):show()
		return
	end
	self.boxRunning_ = true
	self.openBoxId = boxid;
	self.openBoxRequest_ = nk.http.openLuckBox(
		function(data)
			-- nk.http.cancel(self.openBoxRequest_)
			self.openBoxRequest_ = nil
			self.rewardGid_ = checkint(data.win.rid);
			self.otherBoxGift = data.lose;
			self.boxManager_[self.openBoxId]:rockBox(self.rewardGid_)
			self.myMoney = checkint(data.win.money)
			self.giftid = checkint(data.giftid)
		end,

		function(errordata)
			-- nk.http.cancel(self.openBoxRequest_)
			self.openBoxRequest_ = nil
			self.boxRunning_ = false
			if errordata and errordata.errorCode then
				if checkint(errordata.errorCode==-1) then
					NotEnoughMoneyTip.new(self):show()
				else
					nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "BAD_NETWORK")..errordata.errorCode)
				end
			else
				nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
			end
		end
	)
end
function BoxActivity:openOtherBox()
	local rewardIndex = 0;
	for i=1,4 do
		if i ~= self.openBoxId then
			rewardIndex = rewardIndex+1
			self.boxManager_[i]:openBox(checkint(self.otherBoxGift[rewardIndex]))
		end
	end

	self.action_ = self:schedule(function ()
		self:stopAction(self.action_)
		self.boxRunning_ = false
		BoxActGetedRewardDialog.new():show(self.rewardGid_)
		for i=1,4 do
			self.boxManager_[i]:setDefStutes_()
		end
	end,2)
end

return BoxActivity