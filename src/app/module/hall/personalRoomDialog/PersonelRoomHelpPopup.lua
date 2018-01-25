local config = import(".Config")

local PersonelRoomHelpPopup = class("PersonelRoomHelpPopup", function()
	-- body
	return display.newNode()
end)

function PersonelRoomHelpPopup:ctor()
	-- body

	self:setNodeEventEnabled(true)

	self._background = display.newScale9Sprite("#perRoom_bgPanel.png", 0,0,
		cc.size(config.HelpPanelParam.WIDTH, config.HelpPanelParam.HEIGHT))
	-- self._background:setAnchorPoint(display.ANCHOR_POINTS[display.BOTTOM_LEFT])
		-- :pos(display.cx - config.HelpPanelParam.WIDTH / 2, display.cy - config.HelpPanelParam.HEIGHT / 2)
		:addTo(self)

	self._background:setTouchEnabled(true)
	self._background:setTouchSwallowEnabled(true)

	self:initViews()
end

function PersonelRoomHelpPopup:initViews()
	-- body
	local titleBlockBorderXFix = 5

	local titleBlockPosYAdjust = 2

	local titleBlockParam = {
		width = config.HelpPanelParam.WIDTH - titleBlockBorderXFix * 2,
		height = 52
	}

	local titleBlock = display.newScale9Sprite("#perRoom_blockTitle.png", 0, 0,
		cc.size(titleBlockParam.width, titleBlockParam.height))

	titleBlock:pos(config.HelpPanelParam.WIDTH / 2, config.HelpPanelParam.HEIGHT - titleBlockParam.height / 2 - titleBlockPosYAdjust)
		:addTo(self._background)

	local btnSize = {
		width = 38,
		height = 38
	}

	local btnClosePosAdjust = {
		x = 12,
		y = 8
	}
	-- local point = self._background:getAnchorPoint()

	local btnClose = cc.ui.UIPushButton.new({normal = "#panel_close_btn_up.png", pressed = "#panel_close_btn_down.png"})
		:onButtonClicked(buttontHandler(self, self._onCloseCallBack))
		:pos(config.HelpPanelParam.WIDTH - btnSize.width / 2 - btnClosePosAdjust.x, config.HelpPanelParam.HEIGHT - btnSize.height / 2 - btnClosePosAdjust.y)
		:addTo(self._background)

	local title = display.newTTFLabel({text = bm.LangUtil.getText("HALL", "PERSONAL_ROOM_HELP_TITLE"), size = config.HelpPanelParam.frontSizes.title, color = config.HelpPanelParam.colors.title, align = ui.TEXT_ALIGN_CENTER})
		:pos(config.HelpPanelParam.WIDTH / 2, config.HelpPanelParam.HEIGHT - titleBlockParam.height / 2 - titleBlockPosYAdjust)
		:addTo(self._background)

	self:drawTipsBlock()
end

function PersonelRoomHelpPopup:drawTipsBlock()
	-- body
	local tipsBlockMagrinBottom = 20
	local panelBlockInParam = {
		width = 785,
		height = 465
	}

	-- local point = self._background:getAnchorPoint()

	local tipsBlock = display.newScale9Sprite("#perRoom_blockIn.png", config.HelpPanelParam.WIDTH / 2, panelBlockInParam.height / 2 + tipsBlockMagrinBottom,
		cc.size(panelBlockInParam.width, panelBlockInParam.height))
		:addTo(self._background)

	local tipsMagrin = {
		firstLineTop = 12,
		titleLeft = 25,
		contLeft = 55,
		each = 8
	}

	local ListViewParam = {
		WIDTH = 750,
		HEIGHT = 450
	}

	local tipsTitleDesc = bm.LangUtil.getText("HALL", "PERSONAL_ROOM_HELP_TIPS_TITLE")
	local tipsContDesc = bm.LangUtil.getText("HALL", "PERSONAL_ROOM_HELP_TIPS_CONT")

	local tipsContShownWidth = 675

	local scrollContent = display.newNode()

	local container = display.newNode():addTo(scrollContent)

	local sumHeightContent = 0

	local tipsTitle = {}
	local tipsCont = {}
	for i = 1, 4 do

		tipsTitle[i] = display.newTTFLabel({text = tipsTitleDesc[i], size = config.HelpPanelParam.frontSizes.tipsTiltle, color = config.HelpPanelParam.colors.tipsTitle, align = ui.TEXT_ALIGN_LEFT})
		tipsTitle[i]:setAnchorPoint(display.ANCHOR_POINTS[display.LEFT_TOP])

		tipsCont[i] = display.newTTFLabel({text = tipsContDesc[i], size = config.HelpPanelParam.frontSizes.tipsCont, color = config.HelpPanelParam.colors.tipsCont,
			dimensions = cc.size(tipsContShownWidth, 0), align = ui.TEXT_ALIGN_LEFT})
		tipsCont[i]:setAnchorPoint(display.ANCHOR_POINTS[display.LEFT_TOP])

		local sumHeightAboveTitle = 0
		local sumHeightAboveCont = 0

		for j = 1, i do

			if j == 1 then
				--todo

				sumHeightAboveCont = sumHeightAboveCont + tipsTitle[j]:getContentSize().height + tipsMagrin.each
			else
				sumHeightAboveTitle = sumHeightAboveTitle + tipsTitle[j - 1]:getContentSize().height + tipsCont[j - 1]:getContentSize().height
					+ 2 * tipsMagrin.each

				sumHeightAboveCont = sumHeightAboveCont + tipsTitle[j]:getContentSize().height + tipsCont[j - 1]:getContentSize().height
					+ 2 * tipsMagrin.each
			end
			
			if j == 4 then
				--todo
				sumHeightContent = sumHeightAboveCont + tipsCont[j]:getContentSize().height + tipsMagrin.firstLineTop * 2
			end
		end

		tipsTitle[i]:pos(tipsMagrin.titleLeft, - tipsMagrin.firstLineTop - sumHeightAboveTitle)
			:addTo(container)

		tipsCont[i]:pos(tipsMagrin.contLeft, - tipsMagrin.firstLineTop - sumHeightAboveCont)
			:addTo(container)
	end

	-- local point = self._background:getAnchorPoint()

	local containerPosYFix = 0
	container:pos(- ListViewParam.WIDTH / 2 , sumHeightContent / 2 + containerPosYFix)

	local scrollViewPosXFix, scrollViewPosYFix = 20, 20

	self._tipsContScrollView = bm.ui.ScrollView.new({viewRect = cc.rect(- ListViewParam.WIDTH / 2, - ListViewParam.HEIGHT / 2, ListViewParam.WIDTH, ListViewParam.HEIGHT),
		scrollContent = scrollContent, direction = bm.ui.ScrollView.DIRECTION_VERTICAL})
        :pos(- scrollViewPosXFix, - scrollViewPosYFix)
        :addTo(self)
end

function PersonelRoomHelpPopup:_onCloseCallBack()
	-- body
	nk.PopupManager:removePopup(self)
end

function PersonelRoomHelpPopup:show()
	-- body
	nk.PopupManager:addPopup(self, true, true, true, true)
end

function PersonelRoomHelpPopup:onShowed()
	-- body
	self._tipsContScrollView:update()
end

return PersonelRoomHelpPopup