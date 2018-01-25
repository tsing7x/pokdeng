--
-- Author: TsingZhang@boyaa.com
-- Date: 2016-04-06 10:38:41
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- Description: FirChargePayGuidePop By TsingZhang.
--
local UserCrash = import("app.module.room.userCrash.UserCrash")
local StorePopup = import("app.module.newstore.StorePopup")

local FirChrgPgController = import(".FirChrgPgController")

local FirChargeFavPanelParam = {
	WIDTH = 932,
	HEIGHT = 420
}

local FirChargePayGuidePopup = class("FirChargePayGuidePopup", function()
	-- body
	return display.newNode()
end)

-- @Param sceneType : 1.nor, 0.bankRupt. 2.chipLess--
function FirChargePayGuidePopup:ctor(sceneType)
	-- body
	display.addSpriteFrames("chargeFirst_fav_th.plist", "chargeFirst_fav_th.png")
	self:setNodeEventEnabled(true)

	self.background_ = display.newScale9Sprite("#chgFir_bgMain.png", 0, 0, cc.size(FirChargeFavPanelParam.WIDTH, FirChargeFavPanelParam.HEIGHT))
		:addTo(self)

	self.background_:setTouchEnabled(true)
	self.background_:setTouchSwallowEnabled(true)

	self.rewardIconBgHili_ = display.newSprite("#chgFir_bgHigl.png")
	self.rewardIconBgHili_:pos(self.rewardIconBgHili_:getContentSize().width / 2, FirChargeFavPanelParam.HEIGHT / 2)
		:addTo(self.background_)

	self.sType_ = sceneType or 1

	self.controller_ = FirChrgPgController.new(self)
	self:renderTitleBlock()
	self:drawCloseBtn()
	self:renderMainBlock()

	self.loadingBar_ = nk.ui.Juhua.new()
		:addTo(self)

	self:loadPaymentData()
end

function FirChargePayGuidePopup:renderTitleBlock()
	-- body
	local titleLeftHalf = display.newSprite("#chgFir_bgTitle_left.png")
	titleLeftHalf:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER_RIGHT])
	titleLeftHalf:pos(FirChargeFavPanelParam.WIDTH / 2, FirChargeFavPanelParam.HEIGHT)
		:addTo(self.background_)

	local titleRightHalf = display.newSprite("#chgFir_bgTitle_left.png")
	titleRightHalf:flipX(true)
	titleRightHalf:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER_LEFT])
	titleRightHalf:pos(FirChargeFavPanelParam.WIDTH / 2, FirChargeFavPanelParam.HEIGHT)
		:addTo(self.background_)
		-- :rotation(180)
	local getTitleSprPathBySceneType = {
		[0] = "#chgFir_titleDesc_bankRupt.png",
		[1] = "#chgFir_titleDesc_nor.png",
		[2] = "#chgFir_titleDesc_chipLess.png"
	}

	local titlePosYAdjust = 5
	local titleDescSpr = display.newSprite(getTitleSprPathBySceneType[self.sType_])
		:pos(FirChargeFavPanelParam.WIDTH / 2, FirChargeFavPanelParam.HEIGHT + titlePosYAdjust)
		:addTo(self.background_)
end

function FirChargePayGuidePopup:renderMainBlock()
	-- body
	local rewardIconBgHlSize = self.rewardIconBgHili_:getContentSize()
	local rewardBoxIconPosShift = {
		x = 105,
		y = 20
	}

	local rewardBoxIcon = display.newSprite("#chgFir_icRwdBox.png")
		:pos(rewardIconBgHlSize.width / 2 - rewardBoxIconPosShift.x, rewardIconBgHlSize.height / 2 - rewardBoxIconPosShift.y)
		:addTo(self.rewardIconBgHili_)

	local rewrdDescBgPosAdjust = {
		x = 108,
		y = 90
	}
	local rewrdDescBg = display.newSprite("#chgFir_bgPref.png")
		:pos(rewardBoxIcon:getPositionX() - rewrdDescBgPosAdjust.x, rewardBoxIcon:getPositionY() + rewrdDescBgPosAdjust.y)
		:addTo(self.rewardIconBgHili_)

	local rewardDescSprPosXAdjust = 6
	local rewardDescSpr = display.newSprite("#chgFir_prefDesc.png")
		:pos(rewrdDescBg:getContentSize().width / 2 + rewardDescSprPosXAdjust, rewrdDescBg:getContentSize().height / 2)
		:addTo(rewrdDescBg)

	local rewardItemIconPath = {
		"#chip_icon_icon.png",
		"#cash_coin_icon.png"
	}

	local rewardItemIconPosParam = {
		posX = 408,
		midMagrinBgMid = 8,
		magrinEach = 60
	}

	self.rewardItemIcons = {}
	for i = 1, #rewardItemIconPath do
		self.rewardItemIcons[i] = display.newSprite(rewardItemIconPath[i])
			:pos(rewardItemIconPosParam.posX, FirChargeFavPanelParam.HEIGHT / 2 - rewardItemIconPosParam.midMagrinBgMid
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
	local rewardItemDescLblParam = {
		frontSize = 24,
		color = styles.FONT_COLOR.GOLDEN_TEXT
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
		right = 105,
		bottom = 50
	}

	local buyFavBtnSize = {
		width = 302,
		height = 74
	}

	local btnLabelParam = {
		frontSize = 28,
		color = display.COLOR_WHITE
	}

	self.goBuyFavBtn_ = cc.ui.UIPushButton.new({normal = "#common_green_btn_up.png", pressed = "#common_green_btn_down.png", disabled = "#common_btn_disabled.png"},
		{scale9 = true})
		:setButtonSize(buyFavBtnSize.width, buyFavBtnSize.height)
		:setButtonLabel("normal", display.newTTFLabel({text = bm.LangUtil.getText("CPURCHGUIDE", "GETREWARD_BYPRICE", 0), size = btnLabelParam.frontSize, color = btnLabelParam.color, align = ui.TEXT_ALIGN_CENTER}))
		:onButtonClicked(buttontHandler(self, self.onbuyFavCallBack_))
		:pos(FirChargeFavPanelParam.WIDTH - goBuyFavBtnMagrins.right - buyFavBtnSize.width / 2, buyFavBtnSize.height / 2 + goBuyFavBtnMagrins.bottom)
		:addTo(self.background_)

	self.goBuyFavBtn_:setButtonEnabled(false)
end

function FirChargePayGuidePopup:drawCloseBtn()
	-- body
	local closeBtnPosAdjust = {
		x = 4,
		y = 4
	}

	local closeBtn = cc.ui.UIPushButton.new({normal = "#chgFir_btnClose_nor.png", pressed = "#chgFir_btnClose_pre.png", disabled = "#chgFir_btnClose_nor.png"},
		{scale9 = false})
		:onButtonClicked(buttontHandler(self, self.oncloseBtnCallBack_))
		:pos(FirChargeFavPanelParam.WIDTH - closeBtnPosAdjust.x, FirChargeFavPanelParam.HEIGHT - closeBtnPosAdjust.y)
		:addTo(self.background_)
end

function FirChargePayGuidePopup:onbuyFavCallBack_(evt)
	-- body
	self.loadingBar_ = nk.ui.Juhua.new(nil, true):addTo(self)
	self.controller_:purchaseRewardBag()

	self.state_ = nil
end

function FirChargePayGuidePopup:oncloseBtnCallBack_(evt)
	-- body
	self:hidePanel()
end

function FirChargePayGuidePopup:loadPaymentData()
	-- body
	self.controller_:getFirstChargePayment()
end

function FirChargePayGuidePopup:onPaymentDataGet(data)
	-- body
	self.loadingBar_:removeFromParent()
	self.loadingBar_ = nil

	-- local rewardNumStr = {data.pchips, data.pnum, data.pcoins}
	local rewardDescStr = {
		bm.LangUtil.formatString(bm.LangUtil.getText("CPURCHGUIDE", "FIRCHRG_REWARDS")[1], bm.formatNumberWithSplit(data.pchips or 0)),
		bm.LangUtil.formatString(bm.LangUtil.getText("CPURCHGUIDE", "FIRCHRG_REWARDS")[2], bm.formatNumberWithSplit(data.pcoins or 0))
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

function FirChargePayGuidePopup:onPaymentDataWrong(errData)
	-- body
	nk.ui.Dialog.new({
        messageText = bm.LangUtil.getText("COMMON", "REQUEST_DATA_FAIL"), 
        secondBtnText = bm.LangUtil.getText("COMMON", "RETRY"), 
        callback = function (type)
            if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                self.controller_:getFirstChargePayment()
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
function FirChargePayGuidePopup:showPanel(state, quickPlayHandler,inRoom)
	-- body
	self.state_ = state
	self.handler_ = quickPlayHandler
	self.inRoom_ = inRoom
	nk.PopupManager:addPopup(self)

	nk.http.reportFirstPayData(2, function(retData)
        -- body
        -- dump(retData, "reportFirstPayData.data :==================")
        
    end, function(errData)
        -- body
        dump(retData, "reportFirstPayData.errData :==================")
    end)
end

function FirChargePayGuidePopup:hidePanel()
	-- body
	nk.PopupManager:removePopup(self)
end

function FirChargePayGuidePopup:onShowed()
	-- body
end

function FirChargePayGuidePopup:onEnter()
	-- body
end

function FirChargePayGuidePopup:onExit()
	-- body
	display.removeSpriteFramesWithFile("chargeFirst_fav_th.plist", "chargeFirst_fav_th.png")
	nk.schedulerPool:delayCall(function()
	    cc.Director:getInstance():getTextureCache():removeUnusedTextures()
	end, 0.1)
end

function FirChargePayGuidePopup:onCleanup()
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

return FirChargePayGuidePopup