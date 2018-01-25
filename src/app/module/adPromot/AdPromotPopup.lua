--
-- Author: TsingZhang@boyaa.com
-- Date: 2015-12-21 10:46:35
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- Description: AdPromotPopup By tsing.
--
-- local AdPromotModule = import(".AdPromotModule")
local AdPromotPopup = class("AdPromotPopup", function()
	-- body
	return display.newNode()
end)

function AdPromotPopup:ctor(callback)
	-- body
	self.callback_ = callback

	self:setNodeEventEnabled(true)
	self:setTouchEnabled(true)
	-- self:setTouchSwallowEnabled(true)
	self:loadTexture()

	self:setupViews()
end

function AdPromotPopup:setupViews()
	-- body
	local bgMain = display.newSprite("#adProm_bgMain.png")
		:addTo(self)
	bgMain:setTouchSwallowEnabled(true)

	local adPicPosYShift = 15
	self.adPic_ = cc.ui.UIImage.new()
	self.adPic_:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER])
	self.adPic_:pos(bgMain:getContentSize().width / 2, bgMain:getContentSize().height / 2 + adPicPosYShift)
		:addTo(bgMain)

	self.adPic_:setTouchEnabled(true)
	self.adPic_:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.onActionCallBack_))

	self.adImgLoaderId_ = nk.ImageLoader:nextLoaderId()
	-- self.adPic_:setSpriteFrame(display.newSpriteFrame("adPromot_btnBottom.png"))
	local curtainPosShift = {
		x = 6,
		y = 15
	}

	local curtainLeft = display.newSprite("#adPromot_decLeft.png")
	curtainLeft:pos(- curtainPosShift.x, bgMain:getContentSize().height - curtainLeft:getContentSize().height / 2 + curtainPosShift.y)
		:addTo(bgMain)

	local curtainRight = display.newSprite("#adPromot_decLeft.png")
	curtainRight:pos(bgMain:getContentSize().width + curtainPosShift.x, curtainLeft:getPositionY())
		:addTo(bgMain)
		:flipX(true)

	local closeBtnPosShift = {
		x = 12,
		y = 12
	}
	local closeBtn = cc.ui.UIPushButton.new("#adPromot_btnClose.png", {scale9 = false})
		:onButtonClicked(buttontHandler(self, self.onCloseBtnCallBack_))
		:pos(bgMain:getContentSize().width - closeBtnPosShift.x, bgMain:getContentSize().height - closeBtnPosShift.y)
		:addTo(bgMain)

	local btnBottomMagrinBottom = 10
	local btnBottomHeight = 46

	local btnBottomLabelParam = {
		size = 22,
		color = cc.c3b(242, 178, 73)
	}
	local btnBottom = cc.ui.UIPushButton.new("#adPromot_btnBottom.png", {scale9 = false})
		:setButtonLabel("normal", display.newTTFLabel({text = bm.LangUtil.getText("COMMON", "CONFIRM"), size = btnBottomLabelParam.size, color = btnBottomLabelParam.color, align = ui.TEXT_ALIGN_CENTER}))
		:onButtonClicked(buttontHandler(self, self.onActionCallBack_))
		:pos(bgMain:getContentSize().width / 2, btnBottomHeight / 2 + btnBottomMagrinBottom)
		:addTo(bgMain)

	-- AdPromotModule.getPromotDataFromSvr()
	self.loadingBar_ = nk.ui.Juhua.new()
		:pos(bgMain:getContentSize().width / 2, bgMain:getContentSize().height / 2)
		:addTo(bgMain)
end

function AdPromotPopup:show()
	-- body
	nk.PopupManager:addPopup(self)
end

function AdPromotPopup:onShowed()
	-- body
	self:getPromotData()
end

function AdPromotPopup:loadTexture()
	-- body
	display.addSpriteFrames("ad_promot.plist", "ad_promot.png")
end

function AdPromotPopup:removeTexture()
	-- body
	display.removeSpriteFramesWithFile("ad_promot.plist", "ad_promot.png")

	nk.schedulerPool:delayCall(function()
	    cc.Director:getInstance():getTextureCache():removeUnusedTextures()
	end, 0.1)
end

function AdPromotPopup:onCloseBtnCallBack_()
	-- body
	nk.PopupManager:removePopup(self)
end

function AdPromotPopup:onActionCallBack_()
	-- body
	if self.callback_ and self.actionType then
		--todo
		-- 根据图片类型跳转(条件判断)
		self.callback_(self.actionType)

		nk.http.reportAdPromot(self.actionType, function(data)
			-- body
			dump(data, "AdPromotReportSuccData:")
		end, function(errData)
			-- body
			dump(errData, "AdPromotErrData:")
		end)
		
		self:onCloseBtnCallBack_()
	end
end

function AdPromotPopup:getPromotData()
	-- body
	local adImgUrl = nk.userData.popad.picurl
	nk.ImageLoader:loadAndCacheImage(self.adImgLoaderId_, adImgUrl, handler(self, self.onAdImgLoadComplete_))

	-- self.actionType = "invitFri"
end

function AdPromotPopup:onAdImgLoadComplete_(success, sprite)
	-- body
	self.loadingBar_:removeFromParent()
	self.loadingBar_ = nil

	if success then
		--todo
		local tex = sprite:getTexture()
        local texSize = tex:getContentSize()
        self.adPic_:setTexture(tex)
        self.adPic_:setTextureRect(cc.rect(0, 0, texSize.width, texSize.height))
        -- self.adPic_:setScaleX(self.iconWidth / texSize.width)
        -- self.adPic_:setScaleY(self.iconHeight / texSize.height)

        self.actionType = nk.userData.popad.clicklink

        -- Test --
        -- self.actionType = "activitycenter"
        -- End --
	end
end

function AdPromotPopup:onEnter()
	-- body
end

function AdPromotPopup:onExit()
	-- body
	self:removeTexture()
	nk.ImageLoader:cancelJobByLoaderId(self.adImgLoaderId_)
end

function AdPromotPopup:onCleanup()
	-- body

end

return AdPromotPopup