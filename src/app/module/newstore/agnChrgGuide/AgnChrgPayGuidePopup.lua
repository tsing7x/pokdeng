--
-- Author: TsingZhang@boyaa.com
-- Date: 2016-05-18 14:24:05
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- Description: AgnChrgPayGuidePopup.lua By TsingZhang.
--

local UserCrash = import("app.module.room.userCrash.UserCrash")
local StorePopup = import("app.module.newstore.StorePopup")

local AgnChrgPgController = import(".AgnChrgPgController")

local AgnChargeFavPanelParam = {
	WIDTH = 930,
	HEIGHT = 418
}

local AgnChrgPayGuidePopup = class("AgnChrgPayGuidePopup", function()
	-- body
	return display.newNode()
end)

-- @param: packType, 礼包类型,可能的值: 0.周一礼包, 1.周五礼包
function AgnChrgPayGuidePopup:ctor()
	-- body
	self.giftPackType_ = nk.userData.bagPayList and nk.userData.bagPayList.type or 0

	local getResByPackTypeKey = {
		[0] = {
			filePlist = "chargeAgain_favMon_th.plist",
			filePng = "chargeAgain_favMon_th.png"
		},

		[1] = {
			filePlist = "chargeAgain_favFir_th.plist",
			filePng = "chargeAgain_favFir_th.png"
		}
	}

	display.addSpriteFrames(getResByPackTypeKey[self.giftPackType_].filePlist, getResByPackTypeKey[self.giftPackType_].filePng,
		handler(self, self.renderView))
	
	-- self.sType_ = sceneType or 1
end

function AgnChrgPayGuidePopup:renderView(args)
	-- body
	self:setNodeEventEnabled(true)

	self.background_ = display.newScale9Sprite("#chgAgn_bgMain.png", 0, 0, cc.size(AgnChargeFavPanelParam.WIDTH, AgnChargeFavPanelParam.HEIGHT))
		:addTo(self)
	self.background_:setTouchEnabled(true)
	self.background_:setTouchSwallowEnabled(true)

	local rewardPackBgHili = display.newSprite("#chgAgn_bgHigl.png")
	rewardPackBgHili:pos(rewardPackBgHili:getContentSize().width / 2, AgnChargeFavPanelParam.HEIGHT / 2)
		:addTo(self.background_)

	self.controller_ = AgnChrgPgController.new(self)
	self:renderMainBlock()
	self:renderTitleBlock()
	self:drawCloseBtn()

	self.loadingBar_ = nk.ui.Juhua.new()
		:addTo(self)
	self:loadPaymentData()
end

function AgnChrgPayGuidePopup:renderTitleBlock()
	-- body
	local titleBgPosYFix = 5

	local titleLeftHalf = display.newSprite("#chgAgn_bgTitle_left.png")
	titleLeftHalf:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER_RIGHT])
	titleLeftHalf:pos(AgnChargeFavPanelParam.WIDTH / 2, AgnChargeFavPanelParam.HEIGHT - titleBgPosYFix)
		:addTo(self.background_)

	local titleRightHalf = display.newSprite("#chgAgn_bgTitle_left.png")
	titleRightHalf:flipX(true)
	titleRightHalf:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER_LEFT])
	titleRightHalf:pos(AgnChargeFavPanelParam.WIDTH / 2, AgnChargeFavPanelParam.HEIGHT - titleBgPosYFix)
		:addTo(self.background_)

	local titleDescSprPosAdj = 4
	local titleDescSpr = display.newSprite("#chgAgn_titleDesc.png")
		:pos(AgnChargeFavPanelParam.WIDTH / 2, AgnChargeFavPanelParam.HEIGHT - titleDescSprPosAdj)
		:addTo(self.background_)
end

function AgnChrgPayGuidePopup:renderMainBlock()
	-- body
	local rewardBoxIconPosShift = {
		x = 5,
		y = 0
	}

	local rewardBoxIcon = display.newSprite("#chgAgn_decCon_pack.png")
	local rewardBoxIconSize = rewardBoxIcon:getContentSize()

	rewardBoxIcon:pos(rewardBoxIconSize.width / 2 + rewardBoxIconPosShift.x, rewardBoxIconSize.height / 2 + rewardBoxIconPosShift.y)
		:addTo(self.background_)

	local rewardGiftDscPosShift = {
		x = 3,
		y = - 15
	}

	local rewardGiftDescSpr = display.newSprite("#chgAgn_rewardDesc_gift.png")
	rewardGiftDescSpr:pos(rewardBoxIconSize.width + rewardGiftDescSpr:getContentSize().width / 2 - rewardGiftDscPosShift.x, AgnChargeFavPanelParam.HEIGHT * 3 / 4 + 
		rewardGiftDscPosShift.y)
		:addTo(self.background_)

	local rewardItemIconPath = {
		"#chgAgn_ic_chip.png",
		"#chgAgn_ic_cash.png"
	}

	local rewardItemIconPosParam = {
		posX = 408,
		midMagrinBgMid = 8,
		magrinEach = 50
	}

	local ItemIconsMagrinBgMidFix = 40

	self.rewardItemIcons = {}
	for i = 1, #rewardItemIconPath do
		self.rewardItemIcons[i] = display.newSprite(rewardItemIconPath[i])
			:pos(rewardItemIconPosParam.posX, AgnChargeFavPanelParam.HEIGHT / 2 - ItemIconsMagrinBgMidFix - rewardItemIconPosParam.midMagrinBgMid
				- (i - 2) * rewardItemIconPosParam.magrinEach)
			:addTo(self.background_)

		self.rewardItemIcons[i]:scale(0.9)
		-- if i == 2 then
		-- 	--todo
		-- 	self.rewardItemIcons[i]:scale(0.4)
		-- else
		-- 	self.rewardItemIcons[i]:scale(0.85)
		-- end
	end

	local rewardDescStr = {
		"chips :0",
		"cions : 0"
	}

	local rewardItemDescMagrinLeft = 8

	self.rewardItemDescLbls = {}

	local getItemDescLblFontColorByPackType = {
		[0] = cc.c3b(89, 232, 237),
		[1] = cc.c3b(241, 218, 60)
	}

	local rewardItemDescLblParam = {
		frontSize = 24,
		color = getItemDescLblFontColorByPackType[self.giftPackType_]
	}

	for i = 1, #rewardDescStr do
		self.rewardItemDescLbls[i] = display.newTTFLabel({text = rewardDescStr[i], size = rewardItemDescLblParam.frontSize,
			color = rewardItemDescLblParam.color, align = ui.TEXT_ALIGN_CENTER})
		self.rewardItemDescLbls[i]:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER_LEFT])
		self.rewardItemDescLbls[i]:pos(rewardItemIconPosParam.posX + self.rewardItemIcons[i]:getContentSize().width / 2 
			* self.rewardItemIcons[i]:getScale() + rewardItemDescMagrinLeft, self.rewardItemIcons[i]:getPositionY())
			:addTo(self.background_)
	end

	local goBuyFavBtnMagrins = {
		right = 112,
		bottom = 30
	}

	local buyFavBtnSize = {
		width = 362,
		height = 72
	}

	local btnLabelParam = {
		frontSize = 30,
		color = cc.c3b(49, 86, 0)
	}

	self.goBuyFavBtn_ = cc.ui.UIPushButton.new({normal = "#common_green_btn_up.png", pressed = "#common_green_btn_down.png", disabled = "#common_btn_disabled.png"},
		{scale9 = true})
		:setButtonSize(buyFavBtnSize.width, buyFavBtnSize.height)
		:setButtonLabel("normal", display.newTTFLabel({text = bm.LangUtil.getText("CPURCHGUIDE", "GETREWARD_BYPRICE", 0), size = btnLabelParam.frontSize, color = btnLabelParam.color, align = ui.TEXT_ALIGN_CENTER}))
		:onButtonClicked(buttontHandler(self, self.onbuyFavCallBack_))
		:pos(AgnChargeFavPanelParam.WIDTH - goBuyFavBtnMagrins.right - buyFavBtnSize.width / 2, buyFavBtnSize.height / 2 + goBuyFavBtnMagrins.bottom)
		:addTo(self.background_)

	self.goBuyFavBtn_:setButtonEnabled(false)
end

function AgnChrgPayGuidePopup:drawCloseBtn()
	-- body
	local closeBtnPosAdjust = {
		x = 26,
		y = 28
	}

	local closeBtn = cc.ui.UIPushButton.new({normal = "#chgAgn_btnClose_nor.png", pressed = "#chgAgn_btnClose_pre.png", disabled = "#chgAgn_btnClose_nor.png"},
		{scale9 = false})
		:onButtonClicked(buttontHandler(self, self.oncloseBtnCallBack_))
		:pos(AgnChargeFavPanelParam.WIDTH - closeBtnPosAdjust.x, AgnChargeFavPanelParam.HEIGHT - closeBtnPosAdjust.y)
		:addTo(self.background_)
end

function AgnChrgPayGuidePopup:onbuyFavCallBack_(evt)
	-- body
	local isGiftPackAvailable = nk.userData.bagPayList.access and nk.userData.bagPayList.access == 1
	if not isGiftPackAvailable  then
		--todo
		nk.TopTipManager:showTopTip(bm.LangUtil.getText("CPURCHGUIDE", "RECHGALM_CANTACCESS"))

		return
	end

	self.loadingBar_ = nk.ui.Juhua.new(nil, true):addTo(self)
	self.controller_:purchaseRewardBag()

	self.state_ = nil
end

function AgnChrgPayGuidePopup:oncloseBtnCallBack_(evt)
	-- body
	self:hidePanel()
end

function AgnChrgPayGuidePopup:loadPaymentData()
	-- body
	self.controller_:getRechargeAlmFavPayment(self.giftPackType_)
end

function AgnChrgPayGuidePopup:onPaymentDataGet(data)
	-- body
	if self and self.loadingBar_ then
		--todo
		self.loadingBar_:removeFromParent()
		self.loadingBar_ = nil
	end
	
	-- local rewardNumStr = {data.pchips, data.pnum, data.pcoins}
	local rewardDescStr = {
		bm.LangUtil.formatString(bm.LangUtil.getText("CPURCHGUIDE", "FIRCHRG_REWARDS")[1], bm.formatNumberWithSplit(data.pchips or 0)),
		bm.LangUtil.formatString(bm.LangUtil.getText("CPURCHGUIDE", "FIRCHRG_REWARDS")[2], bm.formatNumberWithSplit(data.pcoins or 0)),
	}
	-- {
	-- 	"轻松获得 " .. data.pchips,
	-- 	tostring(data.pcoins) .. " 现金币，玩转现金币场"
	-- }

	for i = 1, #rewardDescStr do
		self.rewardItemDescLbls[i]:setString(rewardDescStr[i])
	end

	self.goBuyFavBtn_:setButtonLabelString("normal", bm.LangUtil.getText("CPURCHGUIDE", "GETREWARD_BYPRICE", data.price or 0))
	self.goBuyFavBtn_:setButtonEnabled(true)
end

function AgnChrgPayGuidePopup:onPaymentDataWrong(errData)
	-- body
	nk.ui.Dialog.new({
        messageText = bm.LangUtil.getText("COMMON", "REQUEST_DATA_FAIL"), 
        secondBtnText = bm.LangUtil.getText("COMMON", "RETRY"), 
        callback = function (type)
            if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                self.controller_:getRechargeAlmFavPayment()
            else
            	if self.loadingBar_ then
            		--todo
            		self.loadingBar_:removeFromParent()
					self.loadingBar_ = nil
            	end
            end
        end
    }):show()
end

-- @Param :state 0.Needed BankRuptPop, nil.None Oper onCleanup, others.ChipNotEnough; 
-- quickPlayHandler.quickPlayFunc; inRoom.isInRoomFlag
function AgnChrgPayGuidePopup:showPanel(state, quickPlayHandler, inRoom)
	-- body
	self.state_ = state
	self.handler_ = quickPlayHandler
	self.inRoom_ = inRoom

	nk.PopupManager:addPopup(self)

	-- 成功展示上报 -- 
	nk.DReport:report({id = "AlmReChargeFavDisplay"})
end

function AgnChrgPayGuidePopup:hidePanel()
	-- body
	nk.PopupManager:removePopup(self)
end

function AgnChrgPayGuidePopup:onShowed()
	-- body
end

function AgnChrgPayGuidePopup:onEnter()
	-- body
end

function AgnChrgPayGuidePopup:onExit()
	-- body
	local getResByPackTypeKey = {
		[0] = {
			filePlist = "chargeAgain_favMon_th.plist",
			filePng = "chargeAgain_favMon_th.png"
		},

		[1] = {
			filePlist = "chargeAgain_favFir_th.plist",
			filePng = "chargeAgain_favFir_th.png"
		}
	}

	display.removeSpriteFramesWithFile(getResByPackTypeKey[self.giftPackType_].filePlist, getResByPackTypeKey[self.giftPackType_].filePng)

	nk.schedulerPool:delayCall(function()
	    cc.Director:getInstance():getTextureCache():removeUnusedTextures()
	end, 0.1)
end

function AgnChrgPayGuidePopup:onCleanup()
	-- body
	self.controller_:dispose()

	if not self.state_ then
		--todo
		return
	end

	if self.state_ == 0 then
		--todo
		if nk.userData["aUser.bankMoney"] >= nk.userData.bankruptcyGrant.maxsafebox then
            --保险箱的钱大于设定值，引导保险箱取钱
            local userCrash = UserCrash.new(0, 0, 0, 0, true, self.inRoom_)
            userCrash:show()

        else
        	local rewardTime = nk.userData.bankruptcyGrant.bankruptcyTimes + 1
	        local bankruptcyTimes = nk.userData.bankruptcyGrant.bankruptcyTimes
	        local rewardMoney = nk.userData.bankruptcyGrant.money[rewardTime] or 0
	        local limitDay = nk.userData.bankruptcyGrant.day or 1
	        local limitTimes = nk.userData.bankruptcyGrant.num or 0
	        local userCrash = UserCrash.new(bankruptcyTimes, rewardMoney, limitDay, limitTimes)
	        userCrash:show()
        end
	else
		local runningScene = nk.runningScene
		if (not runningScene) or (runningScene.name == nil) or runningScene.name == "RoomScene" then
	         -- _state = 1,搓桌引导
			nk.ui.Dialog.new({
	            hasCloseButton = false,
	            messageText = bm.LangUtil.getText("ROOM", "SIT_DOWN_NOT_ENOUGH_MONEY"), 
	            firstBtnText = bm.LangUtil.getText("ROOM", "AUTO_CHANGE_ROOM"),
	            secondBtnText = bm.LangUtil.getText("ROOM", "CHARGE_CHIPS"), 
	            callback = function (type)
	            if type == nk.ui.Dialog.FIRST_BTN_CLICK then
	            	if self.handler_ then
	            		--todo
	            		if self.handler_ == - 1 then
	            			--todo
	            			nk.TopTipManager:showTopTip(bm.LangUtil.getText("HALL", "PERSONAL_ROOM_CANT_CHANGEROOM"))
	            		else
	            			self.handler_()
	            		end
	            	else
	            		nk.server:quickPlay()
	            	end
	            elseif type == nk.ui.Dialog.SECOND_BTN_CLICK then
	                	StorePopup.new():showPanel()
	                end
	            end
	    	}):show() 
	    else
	    	nk.ui.Dialog.new({
	            hasCloseButton = true,
	            hasFirstButton = false,
	            messageText = bm.LangUtil.getText("ROOM", "SIT_DOWN_NOT_ENOUGH_MONEY"), 
	            secondBtnText = bm.LangUtil.getText("ROOM", "CHARGE_CHIPS"), 
	            callback = function (type)
	            if type == nk.ui.Dialog.FIRST_BTN_CLICK then
	            	if self.handler_ then
	            		--todo
	            		self.handler_()
	            	else
	            		nk.server:quickPlay()
	            	end
	            elseif type == nk.ui.Dialog.SECOND_BTN_CLICK then
	                	StorePopup.new():showPanel()
	                end
	            end
	    	}):show() 
	    end
	end
end

return AgnChrgPayGuidePopup