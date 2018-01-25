--
-- Author: TsingZhang@boyaa.com
-- Date: 2016-03-28 17:12:22
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- Description: ScoreMarketHelpPopup By TsingZhang.
--

local ScoreMarketHelpPopup = class("ScoreMarketHelpPopup", nk.ui.Panel)

local HelpPopupParam = {
	WIDTH = 720,
	HEIGHT = 480
}

function ScoreMarketHelpPopup:ctor()
	-- body
	self:setNodeEventEnabled(true)

	self.super.ctor(self, {HelpPopupParam.WIDTH, HelpPopupParam.HEIGHT})

	self:renderMainViews()
end

function ScoreMarketHelpPopup:renderMainViews()
	-- body
	local titleBorWidthFix = 1

	local titleBorSize = {
		width = HelpPopupParam.WIDTH - titleBorWidthFix * 2,
		height = 55
	}

	local titleBorderPosYAdjust = 0
	local titleBorder = display.newScale9Sprite("#socre_titleBor.png", 0, HelpPopupParam.HEIGHT / 2 - titleBorSize.height / 2 - titleBorderPosYAdjust,
		cc.size(titleBorSize.width, titleBorSize.height))
		:addTo(self)

	self:addCloseBtn()

	local titleLabelParam = {
		frontSize = 32,
		color = display.COLOR_WHITE
	}
	local titleLabel = display.newTTFLabel({text = bm.LangUtil.getText("SCOREMARKET", "EXCHANGE_NOTICE"), size = titleLabelParam.frontSize, color = titleLabelParam.color, algin = ui.TEXT_ALIGN_CENTER})
		:pos(titleBorSize.width / 2, titleBorSize.height / 2)
		:addTo(titleBorder)

	local explContBgSize = {
		width = 700,
		height = 410
	}

	local explContBgMagrinBot = 10
	local explContBg = display.newScale9Sprite("#score_bgExplCont.png", 0,
		- HelpPopupParam.HEIGHT / 2 + explContBgSize.height / 2 + explContBgMagrinBot, cc.size(explContBgSize.width, explContBgSize.height))
		:addTo(self)

	local explainListSize = {
		width = 690,
		height = 385
	}

	local tipsCont = {
		title = bm.LangUtil.getText("SCOREMARKET", "EXCHANGE_HELP_QUESTIONS"),
		-- {
		-- 	"1.什么是现金币？",
		-- 	"2.如何兑换奖品？",
		-- 	"3.若有任何问题,请联系客服。"
		-- },

		details = bm.LangUtil.getText("SCOREMARKET", "EXCHANGE_HELP_ANSWER")
		-- {
		-- 	"现金币是搏定的一直兑换货币,通过赢比赛和现金币场可以获得。现金币累计到一定数量后进行兑奖。",
		-- 	"通过比赛或者现金币场赢得奖券,打开兑换中心,选择喜欢的奖品,点击“立即兑换”,即可兑换成功。兑换成功后打开“兑换记录”,就可以领取奖励。",
		-- 	"客服联系方式：打开FB,搜索搏定,找到搏定粉丝页,直接在上面发问;或者打开右下角“系统”,点击“问号”,进行发问。"
		-- }
	}

	local tipsLabelParam = {
		frontSizes = {
			title = 24,
			detail = 20
		},

		colors = {
			title = cc.c3b(139, 159, 209),
			detail = cc.c3b(199, 199, 199)
		}
	}

	local sumContHeight = 0

	local labelExplainTitle = {}
	local labelExplainDetail = {}

	local explainContMagrins = {
		fristTop = 0,
		explTitleTopBot = 8,
		-- explDetailTopBot = 8,
		explContMagrinLeft = 20,
		widthEachSide = 6
	}

	local explContNode = display.newNode()

	local container = display.newNode():addTo(explContNode)
	-- local explContNodePosYShift = 30
	for i = 1, #tipsCont.title do
		labelExplainTitle[i] = display.newTTFLabel({text = tipsCont.title[i], size = tipsLabelParam.frontSizes.title, color = tipsLabelParam.colors.title, 
			dimensions = cc.size(explainListSize.width - explainContMagrins.widthEachSide * 2, 0), align = ui.TEXT_ALIGN_LEFT})

		labelExplainTitle[i]:setAnchorPoint(display.ANCHOR_POINTS[display.LEFT_TOP])

		labelExplainDetail[i] = display.newTTFLabel({text = tipsCont.details[i], size = tipsLabelParam.frontSizes.detail, color = tipsLabelParam.colors.detail, 
			dimensions = cc.size(explainListSize.width - explainContMagrins.widthEachSide * 2, 0), align = ui.TEXT_ALIGN_LEFT})

		labelExplainDetail[i]:setAnchorPoint(display.ANCHOR_POINTS[display.LEFT_TOP])

		local sumHeightAboveTitle = 0
		local sumHeightAboveCont = 0

		for j = 1, i do
			if j == 1 then
				--todo

				-- 初始位置
				sumHeightAboveTitle = sumContHeight

				sumHeightAboveCont = sumContHeight + labelExplainTitle[j]:getContentSize().height + explainContMagrins.explTitleTopBot
			else
				sumHeightAboveTitle = sumHeightAboveTitle + labelExplainTitle[j - 1]:getContentSize().height +
					labelExplainDetail[j - 1]:getContentSize().height + explainContMagrins.explTitleTopBot * 2

				sumHeightAboveCont = sumHeightAboveCont + labelExplainTitle[j]:getContentSize().height +
					labelExplainDetail[j - 1]:getContentSize().height + explainContMagrins.explTitleTopBot * 2
			end

			if j == #tipsCont.title then
				--todo
				sumContHeight = sumHeightAboveCont + labelExplainDetail[j]:getContentSize().height + explainContMagrins.explTitleTopBot
			end
		end

		labelExplainTitle[i]:pos(0, - sumHeightAboveTitle)
			:addTo(container)

		labelExplainDetail[i]:pos(explainContMagrins.explContMagrinLeft, - sumHeightAboveCont)
			:addTo(container)
	end

	local containerPosShift = {
		x = 0,
		y = - 10
	}
	container:pos(- explainListSize.width / 2 + containerPosShift.x, sumContHeight / 2 + containerPosShift.y)

	self.explContList_ = bm.ui.ScrollView.new({viewRect = cc.rect(- explainListSize.width / 2, - explainListSize.height / 2,
		explainListSize.width, explainListSize.height), scrollContent = explContNode, direction = bm.ui.ScrollView.DIRECTION_VERTICAL})
		:pos(explContBgSize.width / 2, explContBgSize.height / 2)
		:addTo(explContBg)
end

function ScoreMarketHelpPopup:showPanel()
	-- body
	self:showPanel_()
end

function ScoreMarketHelpPopup:onShowed()
	-- body
	-- if self.explContList_ then
	-- 	--todo
	-- 	self.explContList_:update()
	-- 	self.explContList_:update()
	-- end
	self.explContList_:update()
end

function ScoreMarketHelpPopup:hidePanel()
	-- body
	self:hidePanel_()
end

function ScoreMarketHelpPopup:onEnter()
	-- body
end

function ScoreMarketHelpPopup:onExit()
	-- body
end

function ScoreMarketHelpPopup:onCleanup()
	-- body
end

return ScoreMarketHelpPopup