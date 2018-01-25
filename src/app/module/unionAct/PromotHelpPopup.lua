local config = import(".Config")

local PromotHelpPopup = class("PromotHelpPopup", function()
	-- body
	return display.newNode()
end)

function PromotHelpPopup:ctor()
	-- body
	self._background = display.newSprite("#prom_bgAwardDesc.png")
		:addTo(self)
	self._background:setTouchEnabled(true)
	self._background:setTouchSwallowEnabled(true)

	local titleMagrinTop = 15

	local title = display.newTTFLabel({text = bm.LangUtil.getText("CUNIONACT", "UNIONACT_HELP"), size = config.HelpPanelParam.frontSizes.Title,
		color = config.HelpPanelParam.tipMsgColor, align = ui.TEXT_ALIGN_CENTER})
	title:pos(config.HelpPanelParam.WIDTH / 2, config.HelpPanelParam.HEIGHT - titleMagrinTop - title:getContentSize().height / 2)
		:addTo(self._background)

	self:drawLabelTips()
	self:initDescTable()

	local closeBtnPosShift = {
		x = 8,
		y = 8
	}

	local closeBtn = cc.ui.UIPushButton.new("#prom_btnClose.png", {scale9 = false})
		:onButtonClicked(buttontHandler(self, self._closeCallBack))
		:pos(config.HelpPanelParam.WIDTH - closeBtnPosShift.x, config.HelpPanelParam.HEIGHT - closeBtnPosShift.y)
		:addTo(self._background)
end

function PromotHelpPopup:drawLabelTips()
	-- body
	local tipsDesc = bm.LangUtil.getText("CUNIONACT", "REWARD_GET_TIPS")

	local tipsDescMagrin = {
		left = 35,
		each = 5,
		top = 55
	}

	local tipsDescShownWidth = 500
	local tipsDescLineHeight = 15

	local tipsItemList = {}

	for i = 1, 3 do
		tipsItemList[i] = display.newTTFLabel({text = tipsDesc[i], size = config.HelpPanelParam.frontSizes.TipsItem, dimensions = cc.size(tipsDescShownWidth, 0),
			color = config.HelpPanelParam.tipMsgColor, align = ui.TEXT_ALIGN_LEFT})
		tipsItemList[i]:setAnchorPoint(display.ANCHOR_POINTS[display.LEFT_TOP])
		
		if tipsItemList[i - 1] then
			--todo

			if i == 3 then
				--todo
				tipsItemList[i]:pos(tipsDescMagrin.left,
				config.HelpPanelParam.HEIGHT - tipsDescMagrin.top - tipsDescMagrin.each * (i - 1) - tipsItemList[i - 1]:getContentSize().height - tipsItemList[i - 2]:getContentSize().height)
			else
				tipsItemList[i]:pos(tipsDescMagrin.left,
				config.HelpPanelParam.HEIGHT - tipsDescMagrin.top - tipsDescMagrin.each * (i - 1) - tipsItemList[i - 1]:getContentSize().height)
			end
			
		else
			tipsItemList[i]:pos(tipsDescMagrin.left, config.HelpPanelParam.HEIGHT - tipsDescMagrin.top)
		end

		tipsItemList[i]:addTo(self._background)
	end

end

function PromotHelpPopup:initDescTable()
	-- body
	local descTableParam = {
		WIDTH = 492,
		HEIGHT = 115,

		itemNameBlockWidth = 205,
		tableItemHeight = 22,
		paddingBottom = 35
	}

	local descTableBg = display.newSprite("#prom_bgAwardDescTable.png")
		:pos(config.HelpPanelParam.WIDTH / 2, descTableParam.paddingBottom + descTableParam.HEIGHT / 2)
		:addTo(self._background)

	local nameBlockTitle = display.newTTFLabel({text = bm.LangUtil.getText("CUNIONACT", "GOALS"), size = config.HelpPanelParam.frontSizes.rewardName,
		color = config.HelpPanelParam.tipMsgColor, align = ui.TEXT_ALIGN_CENTER})
		:pos(descTableParam.itemNameBlockWidth / 2, descTableParam.HEIGHT - descTableParam.tableItemHeight / 2)
		:addTo(descTableBg)

	local contBlockTitle = display.newTTFLabel({text = bm.LangUtil.getText("CUNIONACT", "REWARD"), size = config.HelpPanelParam.frontSizes.rewardName,
		color = config.HelpPanelParam.tipMsgColor, align = ui.TEXT_ALIGN_CENTER})
		:pos(descTableParam.WIDTH - (descTableParam.WIDTH - descTableParam.itemNameBlockWidth) / 2, descTableParam.HEIGHT - descTableParam.tableItemHeight / 2)
		:addTo(descTableBg)

	local descItemList = {
		name = bm.LangUtil.getText("CUNIONACT", "GOALS_NEED"),
		cont = bm.LangUtil.getText("CUNIONACT", "REWARDS_DETAIL")
	}

	for i = 1, 4 do
		local rewardDescName = display.newTTFLabel({text = descItemList.name[i], size = config.HelpPanelParam.frontSizes.rewardName,
			color = config.HelpPanelParam.tipMsgColor, align = ui.TEXT_ALIGN_CENTER})
			:pos(descTableParam.itemNameBlockWidth / 2, descTableParam.HEIGHT - descTableParam.tableItemHeight / 2 * (2 * i + 1))
			:addTo(descTableBg)

		local rewardDescCont = display.newTTFLabel({text = descItemList.cont[i], size = config.HelpPanelParam.frontSizes.rewardCont,
			color = config.HelpPanelParam.rewardContDescColor, align = ui.TEXT_ALIGN_CENTER})
			:pos(descTableParam.WIDTH - (descTableParam.WIDTH - descTableParam.itemNameBlockWidth) / 2, descTableParam.HEIGHT - descTableParam.tableItemHeight / 2 * (2 * i + 1))
			:addTo(descTableBg)
	end
end

function PromotHelpPopup:_closeCallBack()
	-- body
	nk.PopupManager:removePopup(self)
end

function PromotHelpPopup:show()
	-- body
	nk.PopupManager:addPopup(self, true, true, true, true)
end

return PromotHelpPopup