local config = import(".Config")

local GameDLTipPopup = class("GameDLTipPopup", function()
	-- body
	return display.newNode()
end)

function GameDLTipPopup:ctor()
	-- body
	self._background = display.newSprite("#prom_bgAppDownGuide.png")
		:addTo(self)

	self._background:setTouchEnabled(true)
	self._background:setTouchSwallowEnabled(true)

	self:initViews()
end

function GameDLTipPopup:initViews()
	-- body
	local titleMagrinTop = 25

	local titleDesc = display.newTTFLabel({text = bm.LangUtil.getText("CUNIONACT", "GAME_GO_DOWNLOAD"), size = config.GameDLPanelParam.tipFrontSize,
		color = config.GameDLPanelParam.tipsColor, align = ui.TEXT_ALIGN_CENTER})
	titleDesc:pos(config.GameDLPanelParam.WIDTH / 2, config.GameDLPanelParam.HEIGHT - titleMagrinTop - titleDesc:getContentSize().height / 2)
		:addTo(self._background)

	local gameDLIcon = display.newSprite("#prom_gameDownGP.png")
		:pos(config.GameDLPanelParam.WIDTH / 2, config.GameDLPanelParam.HEIGHT / 2)
		:addTo(self._background)

	local playBtnMagrinBottom = 35
	local BtnSize = {
		width = 115,
		height = 42
	}

	local goGooglePlayBtn = cc.ui.UIPushButton.new("#prom_btnGlePly.png", {scale9 = false})
		:onButtonClicked(buttontHandler(self, self._goGooglePlayCallBack))
		:pos(config.GameDLPanelParam.WIDTH / 2, playBtnMagrinBottom + BtnSize.height / 2)
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

function GameDLTipPopup:_goGooglePlayCallBack()
	-- body

	nk.DReport:report({id = "unionActGameDownLoadClk"})
	-- local reportGooglePlayClickTime = nk.http.ReportActData(2,
	-- 	function(data)
	-- 		-- body
	-- 	end,
	-- 	function(errData)
	-- 		-- body
	-- 	end)
	device.openURL(config.NinekeGameDownLoadUrl)
	nk.PopupManager:removeAllPopup()
	
end

function GameDLTipPopup:_onCloseCallBack()
	-- body
	nk.PopupManager:removePopup(self)
end

function GameDLTipPopup:show()
	-- body
	nk.PopupManager:addPopup(self, true, true, true, true)
end

return GameDLTipPopup