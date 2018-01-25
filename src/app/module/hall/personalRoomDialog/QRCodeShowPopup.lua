local config = import(".Config")

local QRCodeShowPopup = class("QRCodeShowPopup", function()
	-- body
	return display.newNode()
end)

function QRCodeShowPopup:ctor()
	-- body
	self._background = display.newScale9Sprite("#perRoom_bgPanel.png", 0, 0, cc.size(config.QRCodeShowPanelParam.WIDTH, config.QRCodeShowPanelParam.HEIGHT))
		:addTo(self)

	self._background:setTouchEnabled(true)
	self._background:setTouchSwallowEnabled(true)

	self:initViews()
end

function QRCodeShowPopup:initViews()
	-- body
	local titleBlockBorderXFix = 5

	local titleBlockPosYAdjust = 2

	local titleBlockParam = {
		width = config.QRCodeShowPanelParam.WIDTH - titleBlockBorderXFix * 2,
		height = 52
	}

	local titleBlock = display.newScale9Sprite("#perRoom_blockTitle.png", 0, 0,
		cc.size(titleBlockParam.width, titleBlockParam.height))
	titleBlock:pos(config.QRCodeShowPanelParam.WIDTH / 2, config.QRCodeShowPanelParam.HEIGHT - titleBlockParam.height / 2 - titleBlockPosYAdjust)
		:addTo(self._background)

	local btnSize = {
		width = 38,
		height = 38
	}

	local btnClosePosAdjust = {
		x = 12,
		y = 8
	}

	local btnClose = cc.ui.UIPushButton.new({normal = "#panel_close_btn_up.png", pressed = "#panel_close_btn_down.png"})
		:onButtonClicked(buttontHandler(self, self._onCloseCallBack))
		-- :setButtonImage("normal", "#panel_close_btn_up.png", true)
		-- :setButtonImage("pressed", "#panel_close_btn_down.png", true)
		:pos(config.QRCodeShowPanelParam.WIDTH - btnSize.width / 2 - btnClosePosAdjust.x, config.QRCodeShowPanelParam.HEIGHT - btnSize.height / 2 - btnClosePosAdjust.y)
		:addTo(self._background)

	local title = display.newTTFLabel({text = "QR Code", size = config.QRCodeShowPanelParam.frontSizes.title, color = config.QRCodeShowPanelParam.colors.title, align = ui.TEXT_ALIGN_CENTER})
		:pos(config.QRCodeShowPanelParam.WIDTH / 2, config.QRCodeShowPanelParam.HEIGHT - titleBlockParam.height / 2 - titleBlockPosYAdjust)
		:addTo(self._background)

	local descTopMagrinTop = 0
	local descTop = display.newTTFLabel({text = bm.LangUtil.getText("HALL", "PERSONAL_ROOM_QRSCAN_TIP_TOP"), size = config.QRCodeShowPanelParam.frontSizes.descTop, color = config.QRCodeShowPanelParam.colors.descTop, align = ui.TEXT_ALIGN_CENTER})
	descTop:pos(config.QRCodeShowPanelParam.WIDTH / 2,
		config.QRCodeShowPanelParam.HEIGHT - titleBlockParam.height - descTopMagrinTop - descTop:getContentSize().height / 2)
		:addTo(self._background)

	self:drawQRShownBlock()

end

function QRCodeShowPopup:drawQRShownBlock()
	-- body

	local blockPanelMagrinBottom = 20
	local blockPanelParam = {
		width = 620,
		height = 268
	}

	local QRshownBlockIn = display.newScale9Sprite("#perRoom_blockIn.png", config.QRCodeShowPanelParam.WIDTH / 2,
		blockPanelParam.height / 2 + blockPanelMagrinBottom, cc.size(blockPanelParam.width, blockPanelParam.height))
		:addTo(self._background)
	-- 添加 QRCode 图片 --

	local QRCodePosYShift = 15
	local QRCodeShown = display.newSprite("#perRoom_QRCode.png")
		:pos(config.QRCodeShowPanelParam.WIDTH / 2, blockPanelParam.height / 2 + QRCodePosYShift)
		:addTo(QRshownBlockIn)

	local descBottomMagrinBottom = 10
	local descBottom = display.newTTFLabel({text = bm.LangUtil.getText("HALL", "PERSONAL_ROOM_QRSCAN_TIP_BOTTOM"), size = config.QRCodeShowPanelParam.frontSizes.descBottom, color = config.QRCodeShowPanelParam.colors.descBottom, align = ui.TEXT_ALIGN_CENTER})
	descBottom:pos(config.QRCodeShowPanelParam.WIDTH / 2, descBottom:getContentSize().height / 2 + descBottomMagrinBottom)
		:addTo(QRshownBlockIn)
end

function QRCodeShowPopup:_onCloseCallBack()
	-- body
	nk.PopupManager:removePopup(self)
end

function QRCodeShowPopup:show()
	-- body
	nk.PopupManager:addPopup(self, true, true, true, true)
end

return QRCodeShowPopup