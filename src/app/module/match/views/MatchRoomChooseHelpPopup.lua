--
-- Author: TsingZhang@boyaa.com
-- Date: 2015-10-15 14:55:49
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- Description: MatchRoomHelpPopup.
--

local MatchRoomChooseHelpPopup = class("MatchRoomChooseHelpPopup", function()
	-- body
	return display.newNode()
end)

-- Global Variable --
local HelpPanelParam = {
	WIDTH = 890,
	HEIGHT = 470,

	frontSizes = {
		title = 35,
		tipsTitle = 22,
		tipsCont = 20
	},

	colors = {
		title = cc.c3b(96, 171, 54),
		tipsTitle = cc.c3b(184, 186, 189),
		tipsCont = cc.c3b(137, 162, 198)
	}
}
	
function MatchRoomChooseHelpPopup:ctor()
	-- body
	self:setNodeEventEnabled(true)
	
	self._background = display.newScale9Sprite("#match_bgPanel.png", 0, 0, 
		cc.size(HelpPanelParam.WIDTH, HelpPanelParam.HEIGHT))
		:addTo(self)

	self._background:setTouchEnabled(true)
	self._background:setTouchSwallowEnabled(true)

	self:initViews()
end

function MatchRoomChooseHelpPopup:initViews()
	-- body
	-- title --
	local blockWidthFixEachSide = 4
	local titleBlockPosYAdjust = 0

	local titleBlockParam = {
		width = HelpPanelParam.WIDTH - blockWidthFixEachSide * 2,
		height = 52
	}

	local titleBlock = display.newScale9Sprite("#match_blockTitle.png", 0, 0, 
		cc.size(titleBlockParam.width, titleBlockParam.height))
		:pos(HelpPanelParam.WIDTH / 2, HelpPanelParam.HEIGHT - titleBlockParam.height / 2 - titleBlockPosYAdjust)
		:addTo(self._background)

	local btnSize = {
		width = 38,
		height = 38
	}

	local btnClosePosAdjust = {
		x = 3,
		y = 8
	}

	local btnClose = cc.ui.UIPushButton.new({normal = "#panel_close_btn_up.png", pressed = "#panel_close_btn_down.png"})
		:onButtonClicked(buttontHandler(self, self._onCloseCallBack))
		:pos(HelpPanelParam.WIDTH - btnSize.width / 2 - btnClosePosAdjust.x, HelpPanelParam.HEIGHT - btnSize.height / 2 - btnClosePosAdjust.y)
		:addTo(self._background)

	local title = display.newTTFLabel({text = bm.LangUtil.getText("MATCH", "MATCH_ROOM_HELP_TITLE"), size = HelpPanelParam.frontSizes.title, color = HelpPanelParam.colors.title, align = ui.TEXT_ALIGN_CENTER})
		:pos(HelpPanelParam.WIDTH / 2, HelpPanelParam.HEIGHT - titleBlockParam.height / 2 - titleBlockPosYAdjust)
		:addTo(self._background)

	self:drawTipsBlock()
end

function MatchRoomChooseHelpPopup:drawTipsBlock()
	-- body
	local tipsBlockMagrinBottom = 12
	local panelBlockInParam = {
		width = 872,
		height = 400
	}

	-- local point = self._background:getAnchorPoint()

	local tipsBlock = display.newScale9Sprite("#match_blockIn.png", HelpPanelParam.WIDTH / 2, panelBlockInParam.height / 2 + tipsBlockMagrinBottom,
		cc.size(panelBlockInParam.width, panelBlockInParam.height))
		:addTo(self._background)

	-- local tipsTitleDesc = {
	-- 	"1. 怎么参加比赛?",
	-- 	"2. 怎么获取比赛门票?",
	-- 	"3. 比赛规则是什么?",
	-- 	"4. 积分是什么?",
	-- 	"5. 比赛怎么玩?"
	-- }

	-- local tipsContDesc = {
	-- 	"比赛分为“付费比赛”和“免费比赛”两种方式。付费比赛需要消耗 “筹码” 或者 “参赛门票”。每场比赛官方会收取一定比例的筹码作为服务费;",
	-- 	"比赛门票有2种获取方式:\n    1.参加低级别的比赛取得名次后可获取高级别的比赛门票;\n    2.在商城储值购买“比赛门票”;",
	-- 	"比赛采用搏定牌的比牌规则。原来是闲家和庄家进行比牌判断输赢,但在比赛中是玩家和玩家进行比牌,所有玩家下注的积分算作桌面奖池,最大牌型的玩家赢得桌面奖池全部积分。",
	-- 	"积分是搏定比赛玩法采用的筹码代币,每场比赛所有玩家初始携带的积分相同,积分输完后自动站起并淘汰出局。最后根据站起的顺序决定排名名次。",
	-- 	"每局开始时所有玩家先下注一定积分到桌面奖池作为前注,下注额度和当前底注相同;\n"..
	-- 		"荷官开始顺时针方向发牌,每人2张牌。为了增强趣味性,每人2张牌中的其中一张亮为明牌给其他玩家看到;\n" .. 			
	-- 		"发完牌后玩家开始轮流下注。下注规则是:上家选择下注积分,则下家下注额度不能少于上家下注额度（可以等于）,下家也可以选择弃牌;\n" .. 
	-- 		"所有玩家第一轮下注完成后选择是否继续要牌。（已弃牌玩家本轮判输不再要牌）;\n" .. 
	-- 		"荷官依次给要牌玩家发第三张牌。为了增强趣味性第三张牌依然为明牌;\n" .. 
	-- 		"第三张牌发完后桌面玩家开始第二次轮流下注;\n" .. 
	-- 		"第二轮下注完毕后所有玩家亮牌进行比牌,最大牌型玩家获胜,赢得桌面奖池;\n" .. 
	-- 		"玩家输完积分后自动站起,根据出局的顺序决定排名并颁奖。"
	-- }

	local tipsTitleDesc = bm.LangUtil.getText("MATCH", "MATCH_ROOM_HELP_TIPS_TITLE")
	local tipsContDesc = bm.LangUtil.getText("MATCH", "MATCH_ROOM_HELP_TIPS_CONT")

	local tipsContShownWidth = 810

	local tipsMagrin = {
		firstLineTop = 15,
		titleLeft = 25,
		contLeft = 40,
		each = 12
	}

	local scrollContent = display.newNode()

	local container = display.newNode():addTo(scrollContent)

	local sumHeightContent = 0

	local tipsTitle = {}
	local tipsCont = {}

	for i = 1, 5 do

		tipsTitle[i] = display.newTTFLabel({text = tipsTitleDesc[i], size = HelpPanelParam.frontSizes.tipsTitle, color = HelpPanelParam.colors.tipsTitle, align = ui.TEXT_ALIGN_CENTER})
		tipsTitle[i]:setAnchorPoint(display.ANCHOR_POINTS[display.LEFT_TOP])

		tipsCont[i] = display.newTTFLabel({text = tipsContDesc[i], size = HelpPanelParam.frontSizes.tipsCont, color = HelpPanelParam.colors.tipsCont,
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
			
			if j == 5 then
				--todo
				sumHeightContent = sumHeightAboveCont + tipsCont[j]:getContentSize().height + tipsMagrin.firstLineTop * 2
			end
		end

		-- dump(tipsMagrin, "tipsMagrin: ===============")

		tipsTitle[i]:pos(tipsMagrin.titleLeft, - tipsMagrin.firstLineTop - sumHeightAboveTitle)
			:addTo(container)

		tipsCont[i]:pos(tipsMagrin.contLeft, - tipsMagrin.firstLineTop - sumHeightAboveCont)
			:addTo(container)
	end

	-- -- local point = self._background:getAnchorPoint()

	local ListViewParam = {
		WIDTH = 872,
		HEIGHT = 380
	}

	local containerPosXFix, containerPosYFix = 0, 0
	container:pos(- ListViewParam.WIDTH / 2 + containerPosXFix, sumHeightContent / 2 + containerPosYFix)

	local scrollViewPosXFix, scrollViewPosYFix = 5, 23

	self._tipsContScrollView = bm.ui.ScrollView.new({viewRect = cc.rect(- ListViewParam.WIDTH / 2, - ListViewParam.HEIGHT / 2, ListViewParam.WIDTH, ListViewParam.HEIGHT),
		scrollContent = scrollContent, direction = bm.ui.ScrollView.DIRECTION_VERTICAL})
        :pos(- scrollViewPosXFix, - scrollViewPosYFix)
        :addTo(self)
end

function MatchRoomChooseHelpPopup:_onCloseCallBack()
	-- body
	nk.PopupManager:removePopup(self)
end

function MatchRoomChooseHelpPopup:show()
	-- body
	nk.PopupManager:addPopup(self, true, true, true, true)
end

function MatchRoomChooseHelpPopup:onShowed()
	-- body
	self._tipsContScrollView:update()
end

function MatchRoomChooseHelpPopup:onEnter()
	-- body
end

function MatchRoomChooseHelpPopup:onExit()
	-- body
end

function MatchRoomChooseHelpPopup:onCleanup()
	-- body
end

return MatchRoomChooseHelpPopup
