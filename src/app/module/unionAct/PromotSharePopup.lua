local config = import(".Config")

local PromotSharePopup = class("PromotSharePopup", function()
	-- body
	return display.newNode()
end)

function PromotSharePopup:ctor()
	-- body
	self._background = display.newSprite("#prom_bgAppDownGuide.png")
		:addTo(self)

	self._background:setTouchEnabled(true)
	self._background:setTouchSwallowEnabled(true)

	self:initViews()
end

function PromotSharePopup:initViews()
	-- body
	local descLabelMagrinTop = 55
	local descLabelShownWidth = 265

	local descLabel = display.newTTFLabel({text = bm.LangUtil.getText("CUNIONACT", "SHARE_DESC"), size = config.GameDLPanelParam.tipsShareFrontSize, dimensions = cc.size(descLabelShownWidth, 0),
			color = config.GameDLPanelParam.tipsColor, align = ui.TEXT_ALIGN_CENTER})
	descLabel:pos(config.GameDLPanelParam.WIDTH / 2, config.GameDLPanelParam.HEIGHT - descLabelMagrinTop - descLabel:getContentSize().height / 2)
		:addTo(self._background)

	local BtnMagrinBottom = 50
	local BtnSize = {
		width = 122,
		height = 54
	}

	local shareBtn = cc.ui.UIPushButton.new("#prom_btnShare.png", {scale9 = false})
		:onButtonClicked(buttontHandler(self, self._onShareCallBack))
		:pos(config.GameDLPanelParam.WIDTH / 2, BtnMagrinBottom + BtnSize.height / 2)
		:addTo(self._background)

	local closeBtnPosShift = {
		x = 8,
		y = 8
	}

	local closeBtn = cc.ui.UIPushButton.new("#prom_btnClose.png", {scale9 = false})
		:pos(config.GameDLPanelParam.WIDTH - closeBtnPosShift.x,
			config.GameDLPanelParam.HEIGHT - closeBtnPosShift.y)
		:onButtonClicked(buttontHandler(self, self._onCloseCallBack))
		:addTo(self._background)
end

function PromotSharePopup:_onShareCallBack()
	-- body

    nk.sendFeed:unionAct_final_reward_(function()
		-- nk.TopTipManager:showTopTip(bm.LangUtil.getText("FEED", "SHARE_SUCCESS")) 
		end,

		function()
			-- body
			-- nk.TopTipManager:showTopTip(bm.LangUtil.getText("FEED", "SHARE_FAILED"))
		end)

	nk.PopupManager:removeAllPopup()
end

function PromotSharePopup:_onCloseCallBack()
	-- body
	nk.PopupManager:removePopup(self)
end

function PromotSharePopup:show()
	-- body
	nk.PopupManager:addPopup(self, true, true, true, true)
end

return PromotSharePopup