--
-- Author: TsingZhang@boyaa.com
-- Date: 2016-01-13 18:01:04
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- Description: AuctionMarketHelpPopup.lua By Tsing.
--

local AuctionMarketHelpPopup = class("AuctionMarketHelpPopup", nk.ui.Panel)

local AuctionMarketHelpPanelSize = {
	WIDTH = 810,
	HEIGHT = 542
}

function AuctionMarketHelpPopup:ctor()
	-- body
	self.super.ctor(self, {AuctionMarketHelpPanelSize.WIDTH, AuctionMarketHelpPanelSize.HEIGHT})

	self:setNodeEventEnabled(true)

	self:drawTitleBlock()
	self:drawMainBlock()
end

function AuctionMarketHelpPopup:drawTitleBlock()
	-- body
	local titleBlockWidthFix = 2

	local titleBlockSize = {
		width = AuctionMarketHelpPanelSize.WIDTH - titleBlockWidthFix * 2,
		height = 55
	}

	local titleBlockDent = display.newScale9Sprite("#aucMar_helpTitleBlock.png", 0,
		AuctionMarketHelpPanelSize.HEIGHT / 2 - titleBlockSize.height / 2, cc.size(titleBlockSize.width, titleBlockSize.height))
		:addTo(self)

	local titleLabelParam = {
		frontSize = 30,
		color = cc.c3b(111, 129, 175)
	}

	local labelTitle = display.newTTFLabel({text = bm.LangUtil.getText("AUCTION_MARKET","AUCTION_HELP_TITLE"), size = titleLabelParam.frontSize, color = titleLabelParam.color, align = ui.TEXT_ALIGN_CENTER})
		:pos(titleBlockSize.width / 2, titleBlockSize.height / 2)
		:addTo(titleBlockDent)

	self:addCloseBtn()
end

function AuctionMarketHelpPopup:drawMainBlock()
	-- body
	local descContBgMagrinBottom = 20

	local helpDescBgSize = {
		width = 784,
		height = 460
	}

	local descContBg = display.newScale9Sprite("#aucMar_bgHelpDescCont.png", 0,
		- AuctionMarketHelpPanelSize.HEIGHT / 2 + helpDescBgSize.height / 2 + descContBgMagrinBottom, cc.size(helpDescBgSize.width, helpDescBgSize.height))
		:addTo(self)

	local scrollContContainer = display.newNode()

	local container = display.newNode():addTo(scrollContContainer)  -- 必须要一个Container作为Node添加????

	local helpItemStr = bm.LangUtil.getText("AUCTION_MARKET","AUCTION_HELP_ITEM_STRING")

	local itemDescDetailStr = {
		title = bm.LangUtil.getText("AUCTION_MARKET","AUCTION_HELP_DES_TITLE"),

		descCont = bm.LangUtil.getText("AUCTION_MARKET","AUCTION_HELP_DES_CONTENT")
	}
	-- local testText = display.newTTFLabel({text = "test!adawdadwaaaaaaaaaaa", size = 25, align = ui.TEXT_ALIGN_CENTER})
	-- 	:addTo(descContBg)
	-- display.newColorLayer(cc.c4b(0, 0, 0, 255)):addTo(descContBg)

	local labelHelpItemParam = {
		frontSize = 20,
		color = {
			nor = cc.c3b(199, 199, 199),
			hli = cc.c3b(139, 159, 209)
		},
		shownWidth = 700
	}

	local sumContHeight = 0

	local labelHelpItem = {}
	local itemDescTitle = {}
	local itemDescCont = {}

	local descContMagrins = {
		firstTop = 0,
		helpItemEachLine = 8,
		itemBetweenDetail = 10,
		descDetailEach = 5
	}

	-- local testText = display.newTTFLabel({text = "test!adawdadwadaaaaaaaaaaaaaaaaaaaaaaaaaaaa", size = 25, align = ui.TEXT_ALIGN_CENTER})
	-- 	:addTo(scrollContContainer)
	for i = 1, #helpItemStr do

		labelHelpItem[i] = display.newTTFLabel({text = helpItemStr[i], size = labelHelpItemParam.frontSize, color = labelHelpItemParam.color.nor,
			dimensions = cc.size(labelHelpItemParam.shownWidth, 0), align = ui.TEXT_ALIGN_LEFT})
		labelHelpItem[i]:setAnchorPoint(display.ANCHOR_POINTS[display.LEFT_TOP])

		local itemHeightAboveSum = 0
		for j = 1, i do
			if j ~= 1 then
				--todo
				itemHeightAboveSum = itemHeightAboveSum + labelHelpItem[j - 1]:getContentSize().height + descContMagrins.helpItemEachLine
			end

			if j == #helpItemStr then
				--todo
				sumContHeight = itemHeightAboveSum + labelHelpItem[j]:getContentSize().height + descContMagrins.itemBetweenDetail
			end
		end

		labelHelpItem[i]:pos(0, - itemHeightAboveSum)
			:addTo(container)
	end

	for i = 1, #itemDescDetailStr.title do
		itemDescTitle[i] = display.newTTFLabel({text = itemDescDetailStr.title[i] .. ":", size = labelHelpItemParam.frontSize, color = labelHelpItemParam.color.hli,
			dimensions = cc.size(labelHelpItemParam.shownWidth, 0), align = ui.TEXT_ALIGN_LEFT})

		itemDescTitle[i]:setAnchorPoint(display.ANCHOR_POINTS[display.LEFT_TOP])

		itemDescCont[i] = display.newTTFLabel({text = itemDescDetailStr.descCont[i], size = labelHelpItemParam.frontSize, color = labelHelpItemParam.color.nor,
			dimensions = cc.size(labelHelpItemParam.shownWidth, 0), align = ui.TEXT_ALIGN_LEFT})

		itemDescCont[i]:setAnchorPoint(display.ANCHOR_POINTS[display.LEFT_TOP])

		local sumHeightAboveTitle = 0
		local sumHeightAboveCont = 0

		for j = 1, i do

			if j == 1 then
				--todo

				-- 初始位置
				sumHeightAboveTitle = sumContHeight

				sumHeightAboveCont = sumContHeight + itemDescTitle[j]:getContentSize().height + descContMagrins.descDetailEach
			else
				sumHeightAboveTitle = sumHeightAboveTitle + itemDescTitle[j - 1]:getContentSize().height +
					itemDescCont[j - 1]:getContentSize().height + descContMagrins.descDetailEach * 2

				sumHeightAboveCont = sumHeightAboveCont + itemDescTitle[j]:getContentSize().height +
					itemDescCont[j - 1]:getContentSize().height + descContMagrins.descDetailEach * 2
			end

			if j == #itemDescDetailStr.title then
				--todo
				sumContHeight = sumHeightAboveCont + itemDescCont[j]:getContentSize().height + descContMagrins.descDetailEach
			end
		end

		itemDescTitle[i]:pos(0, - sumHeightAboveTitle)
			:addTo(container)

		itemDescCont[i]:pos(0, - sumHeightAboveCont)
			:addTo(container)
	end

	local ListViewParam = {
		WIDTH = 708,
		HEIGHT = 436
	}

	local containerPosShift = {
		x = 0,
		y = - 10
	}
	container:pos(- ListViewParam.WIDTH / 2 + containerPosShift.x, sumContHeight / 2 + containerPosShift.y)

	self.helpDescScrollView_ = bm.ui.ScrollView.new({viewRect = cc.rect(- ListViewParam.WIDTH / 2, - ListViewParam.HEIGHT / 2,
		ListViewParam.WIDTH, ListViewParam.HEIGHT), scrollContent = scrollContContainer, direction = bm.ui.ScrollView.DIRECTION_VERTICAL})
		:pos(helpDescBgSize.width / 2, helpDescBgSize.height / 2)
		:addTo(descContBg)
end

function AuctionMarketHelpPopup:show()
	-- body
	self:showPanel_()
end

function AuctionMarketHelpPopup:onShowed()
	-- body
	self.helpDescScrollView_:update()
end

function AuctionMarketHelpPopup:onEnter()
	-- body
end

function AuctionMarketHelpPopup:onExit()
	-- body
end

function AuctionMarketHelpPopup:onCleanup()
	-- body
end

return AuctionMarketHelpPopup