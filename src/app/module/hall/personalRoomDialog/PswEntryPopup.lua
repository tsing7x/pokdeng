local config = import(".Config")

local PswEntryPopup = class("PswEntryPopup", function()
	-- body

	return display.newNode()
end)

function PswEntryPopup:ctor(param, handler)
	-- body
	self._roomId = param.roomID
	self.tableID_ = param.tableID
	self._roomName = param.roomName
	self.roomData = param

	dump(param,"param")

	self._entryCallBack = handler

	self._background = display.newScale9Sprite("#perRoom_bgPanel.png", 0, 0,
		cc.size(config.PSWEntryPanelParam.WIDTH, config.PSWEntryPanelParam.HEIGHT))
		:addTo(self)

	self._background:setTouchEnabled(true)
	self._background:setTouchSwallowEnabled(true)

	self:setupViews()
end

function PswEntryPopup:setupViews()
	-- body
	local titleBlockBorderXFix = 5

	local titleBlockPosYAdjust = 2

	local titleBlockParam = {
		width = config.PSWEntryPanelParam.WIDTH - titleBlockBorderXFix * 2,
		height = 52
	}

	local titleBlock = display.newScale9Sprite("#perRoom_blockTitle.png", 0, 0,
		cc.size(titleBlockParam.width, titleBlockParam.height))
	titleBlock:pos(config.PSWEntryPanelParam.WIDTH / 2, config.PSWEntryPanelParam.HEIGHT - titleBlockParam.height / 2 - titleBlockPosYAdjust)
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
		:pos(config.PSWEntryPanelParam.WIDTH - btnSize.width / 2 - btnClosePosAdjust.x, config.PSWEntryPanelParam.HEIGHT - btnSize.height / 2 - btnClosePosAdjust.y)
		:addTo(self._background)

	local title = display.newTTFLabel({text = bm.LangUtil.getText("HALL", "PERSONAL_ROOM_ENTRY_TITLE"), size = config.PSWEntryPanelParam.frontSizes.title, color = config.PSWEntryPanelParam.colors.title, align = ui.TEXT_ALIGN_CENTER})
		:pos(config.PSWEntryPanelParam.WIDTH / 2, config.PSWEntryPanelParam.HEIGHT - titleBlockParam.height / 2 - titleBlockPosYAdjust)
		:addTo(self._background)

	self:drawPswInputBlock()
end

function PswEntryPopup:drawPswInputBlock()
	-- body
	local descShownParam = {
		paddings = {
			top = 75,
			left = 25
		},

		magrins = {
			line = 15,
			colum = 18
		}
	}

	local roomNameColum = display.newTTFLabel({text = bm.LangUtil.getText("HALL", "PERSONAL_ROOM_CREATE")[1], size = config.PSWEntryPanelParam.frontSizes.columDesc, color = config.PSWEntryPanelParam.colors.columDesc, align = ui.TEXT_ALIGN_CENTER})
	roomNameColum:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER_LEFT])

	roomNameColum:pos(descShownParam.paddings.left, config.PSWEntryPanelParam.HEIGHT - descShownParam.paddings.top - roomNameColum:getContentSize().height / 2)
		:addTo(self._background)

	local roomIDColum = display.newTTFLabel({text = bm.LangUtil.getText("HALL", "PERSONAL_ROOM_ENTRY_ROOM_ID"), size = config.PSWEntryPanelParam.frontSizes.columDesc, color = config.PSWEntryPanelParam.colors.columDesc, align = ui.TEXT_ALIGN_CENTER})
	roomIDColum:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER_LEFT])

	roomIDColum:pos(descShownParam.paddings.left,
		config.PSWEntryPanelParam.HEIGHT - descShownParam.paddings.top - roomNameColum:getContentSize().height - descShownParam.magrins.colum - roomIDColum:getContentSize().height / 2)
		:addTo(self._background)

	local roomNameCont = display.newTTFLabel({text = tostring(self._roomName), size = config.PSWEntryPanelParam.frontSizes.contDesc, color = config.PSWEntryPanelParam.colors.contDesc, align = ui.TEXT_ALIGN_CENTER})
	roomNameCont:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER_LEFT])

	roomNameCont:pos(descShownParam.paddings.left + roomNameColum:getContentSize().width + descShownParam.magrins.colum,
		config.PSWEntryPanelParam.HEIGHT - descShownParam.paddings.top - roomNameColum:getContentSize().height / 2)
		:addTo(self._background)

	local roomIDCont = display.newTTFLabel({text = tostring(self.tableID_), size = config.PSWEntryPanelParam.frontSizes.contDesc, color = config.PSWEntryPanelParam.colors.contDesc, align = ui.TEXT_ALIGN_CENTER})
	roomIDCont:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER_LEFT])

	roomIDCont:pos(descShownParam.paddings.left + roomIDColum:getContentSize().width + descShownParam.magrins.colum,
		config.PSWEntryPanelParam.HEIGHT - descShownParam.paddings.top - roomNameColum:getContentSize().height - descShownParam.magrins.colum - roomIDColum:getContentSize().height / 2)
		:addTo(self._background)

    local pswInputEditBlockPosYAdjust = 8
    local pswInputEditBlockSize = {
    	width = 428,
    	height = 54
	}

	self._pswInputEditBlock = cc.ui.UIInput.new({size = cc.size(pswInputEditBlockSize.width, pswInputEditBlockSize.height), align = ui.TEXT_ALIGN_CENTER,
		image = "#perRoom_blockEdit.png", imagePressed = "#perRoom_blockEdit.png", x = config.PSWEntryPanelParam.WIDTH / 2, y = config.PSWEntryPanelParam.HEIGHT / 2 - pswInputEditBlockPosYAdjust,
		listener = handler(self, self._onInputPswEdit)})

	self._pswInputEditBlock:setFontName(ui.DEFAULT_TTF_FONT)
	self._pswInputEditBlock:setFontSize(config.PSWEntryPanelParam.frontSizes.editHint)
	self._pswInputEditBlock:setFontColor(config.PSWEntryPanelParam.colors.editHint)
	self._pswInputEditBlock:setPlaceholderFontName(ui.DEFAULT_TTF_FONT)
    self._pswInputEditBlock:setPlaceholderFontSize(config.PSWEntryPanelParam.frontSizes.editHint)
    self._pswInputEditBlock:setPlaceholderFontColor(config.PSWEntryPanelParam.colors.editHint)
    self._pswInputEditBlock:setPlaceHolder(bm.LangUtil.getText("HALL", "PERSONAL_ROOM_CREATE")[7])
    self._pswInputEditBlock:setReturnType(cc.KEYBOARD_RETURNTYPE_GO)
    self._pswInputEditBlock:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
    self._pswInputEditBlock:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
    self._pswInputEditBlock:addTo(self._background)

    local labelTipsMagrinTop = 10

    self._wrongPswTips = display.newTTFLabel({text = bm.LangUtil.getText("HALL", "PERSONAL_ROOM_ENTRY_WRONG_PSW_TIP"), size = config.PSWEntryPanelParam.frontSizes.tips, color = config.PSWEntryPanelParam.colors.tips, align = ui.TEXT_ALIGN_CENTER})
	self._wrongPswTips:setAnchorPoint(display.ANCHOR_POINTS[display.LEFT_TOP])

    self._wrongPswTips:pos(config.PSWEntryPanelParam.WIDTH / 2 - pswInputEditBlockSize.width / 2,
    	config.PSWEntryPanelParam.HEIGHT / 2 - pswInputEditBlockPosYAdjust - pswInputEditBlockSize.height / 2 - labelTipsMagrinTop)
    	:addTo(self._background)

    self._wrongPswTips:setVisible(false)
    local btnEntermagrinBottom = 45

    local btnSize = {
    	width = 188,
    	height = 58
	}

    local enterRoomBtn = cc.ui.UIPushButton.new("#perRoom_btnGreen.png", {scale9 = true})
    	:setButtonSize(btnSize.width, btnSize.height)
    	:setButtonLabel("normal", display.newTTFLabel({text = bm.LangUtil.getText("HALL", "PERSONAL_ROOM_ENTRY_ENTER_ROOM"), size = config.PSWEntryPanelParam.frontSizes.btnLabel, color = config.PSWEntryPanelParam.colors.btnLabel, align = ui.TEXT_ALIGN_CENTER}))
    	:onButtonClicked(buttontHandler(self, self._onPswEntryCallBack))
    	:pos(config.PSWEntryPanelParam.WIDTH / 2, btnEntermagrinBottom + btnSize.height / 2)
    	:addTo(self._background)
end

function PswEntryPopup:_onInputPswEdit(evt)
	-- body
	if evt == "began" then
        -- 开始输入
    elseif evt == "changed" then
        -- 输入框内容发生变化是
        self._pswEditText = self._pswInputEditBlock:getText()
    elseif evt == "ended" then
        
    elseif evt == "return" then
        -- 从输入框返回
    end
end

function PswEntryPopup:_onPswEntryCallBack()
	-- body
	if self._pswEditText == nil or string.len(string.trim(self._pswEditText)) ~= 6 then
		--todo
		self._wrongPswTips:setVisible(true)
		return
	end
	self._wrongPswTips:setVisible(false)
	-- local pswInput = self._pswEditText
	if self._entryCallBack then
		self._entryCallBack(self._pswEditText,self.roomData)
		self:hide()
	end
	
end

function PswEntryPopup:_onCloseCallBack()
	-- body
	nk.PopupManager:removePopup(self)
end

function PswEntryPopup:show()
	-- body
	nk.PopupManager:addPopup(self, true, true, true, true)
end


function PswEntryPopup:hide()
	nk.PopupManager:removePopup(self)
end

return PswEntryPopup