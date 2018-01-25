local config = import(".Config")
local pg = import(".Init")

local panel = nk.ui.Panel
local RoomEnterTip = class("RoomEnterTip", panel)

function RoomEnterTip:ctor(data)
	-- body
	pg.loadTexture()
	self:setNodeEventEnabled(true)

	RoomEnterTip.super.ctor(self, {config.TipsPanelParam.WIDTH, config.TipsPanelParam.HEIGHT})

	RoomEnterTip.super.addCloseBtn(self)

	self:drawViews(data)
end

function RoomEnterTip:drawViews(roomInfo)
	-- body

	local divdLineParam = {
		width = 615,
		height = 2
	}

	local divdLinePuddingTop = 52

	local labelPart1PosYAdjust = 20
	local labelSingleLineHeight = 30

	local LabelShownWidth = 600
	-- TitleLabel --
	local titleLabel = display.newTTFLabel({text = bm.LangUtil.getText("COMMON", "NOTICE"), size = config.TipsPanelParam.LabelTitleFrontSize, align = ui.TEXT_ALIGN_CENTER})
	titleLabel:pos(0, config.TipsPanelParam.HEIGHT / 2 - config.TipsPanelParam.LabelTitleMagrinTop - titleLabel:getContentSize().height / 2)
		:addTo(self)

	-- divdLine --
	local divdLine = display.newScale9Sprite("#payGuide_dividLine.png", 0, config.TipsPanelParam.HEIGHT / 2 - divdLinePuddingTop, cc.size(divdLineParam.width, divdLineParam.height))
		:addTo(self)

	-- LabelShown --
	--local tipsLabelPart1 = display.newTTFLabel({text = bm.LangUtil.getText("CPURCHGUIDE", "ROOM_CHIPS_NEED_RANGE", roomInfo.blind or 0, roomInfo.minBuyIn or 0, roomInfo.maxBuyIn or 0),
		local tipsLabelPart1 = display.newTTFLabel({text = bm.LangUtil.getText("CPURCHGUIDE", "ROOM_CHIPS_NEED_RANGE2", roomInfo.blind or 0, roomInfo.minBuyIn or 0),
		dimensions = cc.size(LabelShownWidth, 0), size = config.TipsPanelParam.TipsLabelFrontSize, align = ui.TEXT_ALIGN_LEFT})

	if math.ceil(tipsLabelPart1:getContentSize().height / labelSingleLineHeight) >= 2 then
		--todo
		tipsLabelPart1:pos(0, config.TipsPanelParam.LabelShonMagrinLines + tipsLabelPart1:getContentSize().height - labelPart1PosYAdjust)
			:addTo(self)
	else
		tipsLabelPart1:pos(0, config.TipsPanelParam.LabelShonMagrinLines + tipsLabelPart1:getContentSize().height)
		:addTo(self)
	end

	local tipsLabelPart2 = display.newTTFLabel({text = bm.LangUtil.getText("CPURCHGUIDE", "PRAISE_AND_GUIDE"), size = config.TipsPanelParam.TipsLabelFrontSize, align = ui.TEXT_ALIGN_CENTER})
	tipsLabelPart2:pos(- (tipsLabelPart1:getContentSize().width / 2 - tipsLabelPart2:getContentSize().width / 2), 0)
		:addTo(self)

	local tipsLabelPart3 = display.newTTFLabel({text = bm.LangUtil.getText("CPURCHGUIDE", "BLESSES"), size = config.TipsPanelParam.TipsLabelFrontSize, align = ui.TEXT_ALIGN_CENTER})
	tipsLabelPart3:pos(- (tipsLabelPart1:getContentSize().width / 2 - tipsLabelPart3:getContentSize().width / 2), - (config.TipsPanelParam.LabelShonMagrinLines + tipsLabelPart3:getContentSize().height))
		:addTo(self)

	-- Button --
	local BtnSize = {
		width = 180,
		height = 55
	}

	local btnMagrinBottom = 22

	self._goNowBtn = cc.ui.UIPushButton.new("#payGuide_btnGreen.png", {scale9 = true})
		:setButtonSize(BtnSize.width, BtnSize.height)
		:setButtonLabel("normal", display.newTTFLabel({text = bm.LangUtil.getText("CPURCHGUIDE", "GO_NOW"), size = config.TipsPanelParam.BtnFrontSize, align = ui.TEXT_ALIGN_CENTER}))
		:onButtonClicked(buttontHandler(self, self._goNowBtnCallBack))
		:pos(0, - (config.TipsPanelParam.HEIGHT / 2 - btnMagrinBottom - BtnSize.height / 2))
		:addTo(self)
end

function RoomEnterTip:_goNowBtnCallBack()
	-- body
	-- 快速搓桌。
	nk.server:quickPlay()
	self:hidePanel_()
end

function RoomEnterTip:show()
	-- body
	self:showPanel_()
end

function RoomEnterTip:onExit()
	-- body
	pg.removeTexture()
end

return RoomEnterTip