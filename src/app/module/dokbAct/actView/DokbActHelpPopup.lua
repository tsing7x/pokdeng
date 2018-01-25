--
-- Author: TsingZhang@boyaa.com
-- Date: 2016-05-30 18:20:54
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- Description: DokbActHelpPopup.lua By TsingZhang.
--

local helpPanelParam = {
	WIDTH = 622,
	HEIGHT = 402
}

local DokbActHelpPopup = class("DokbActHelpPopup", function()
	-- body
	return display.newNode()
end)

function DokbActHelpPopup:ctor()
	-- body
	self:setNodeEventEnabled(true)

	self.background_ = display.newScale9Sprite("#dokb_bgActPanel.png", 0, 0, cc.size(helpPanelParam.WIDTH, helpPanelParam.HEIGHT))
		:addTo(self)

	self.background_:setTouchEnabled(true)
	self.background_:setTouchSwallowEnabled(true)

	self:drawTitleArea()
	self:renderMainViews()
	self:addCloseBtn()
end

function DokbActHelpPopup:addCloseBtn()
	-- body
	local closBtnPosAdj = {
		x = 8,
		y = 8
	}

	local closeBtn = cc.ui.UIPushButton.new({normal = "#dokb_btnClose_nor.png", pressed = "#dokb_btnClose_pre.png", disabled = "#dokb_btnClose_nor.png"},
		{scale9 = false})
		:onButtonClicked(buttontHandler(self, self.onCloseBtnCallBack_))
		:pos(helpPanelParam.WIDTH - closBtnPosAdj.x, helpPanelParam.HEIGHT - closBtnPosAdj.y)
		:addTo(self.background_)
end

function DokbActHelpPopup:drawTitleArea()
	-- body
	local titleLblParam = {
		frontSize = 24,
		color = cc.c3b(241, 230, 112)
	}

	local titleLblMagrinTop = 14
	local titleLbl = display.newTTFLabel({text = bm.LangUtil.getText("DOKB", "HELP_INSTRUCT"), size = titleLblParam.frontSize, color = titleLblParam.color, align = ui.TEXT_ALIGN_CENTER})
	titleLbl:pos(helpPanelParam.WIDTH / 2, helpPanelParam.HEIGHT - titleLblMagrinTop - titleLbl:getContentSize().height / 2)
		:addTo(self.background_)

	local decPlantMagrinTitle = 8
	local decPlantRight = display.newSprite("#dokb_decTitleHelp.png")
	decPlantRight:pos(helpPanelParam.WIDTH / 2 + titleLbl:getContentSize().width / 2 + decPlantRight:getContentSize().width / 2 + decPlantMagrinTitle,
		titleLbl:getPositionY())
		:addTo(self.background_)

	local decPlantLeft = display.newSprite("#dokb_decTitleHelp.png")
	decPlantLeft:pos(helpPanelParam.WIDTH / 2 - titleLbl:getContentSize().width / 2 - decPlantRight:getContentSize().width / 2 - decPlantMagrinTitle,
		titleLbl:getPositionY())
		:addTo(self.background_)
		:flipX(true)
end

function DokbActHelpPopup:renderMainViews()
	-- body
	local mainContBgDentSize = {
		width = 605,
		height = 335
	}
	local bgDentMagrinBot = 12

	local contBgDent = display.newScale9Sprite("#dokb_bgDent.png", helpPanelParam.WIDTH / 2, mainContBgDentSize.height / 2 + bgDentMagrinBot,
		cc.size(mainContBgDentSize.width, mainContBgDentSize.height))
		:addTo(self.background_)

	local tipsAllStr = {
		[1] = {
			title = bm.LangUtil.getText("DOKB", "HELP_CONT_TITLES")[1],
			cont = {
				bm.LangUtil.getText("DOKB", "HELP_CONT_DETAIL1")
			}
		},

		[2] = {
			title = bm.LangUtil.getText("DOKB", "HELP_CONT_TITLES")[2],
			cont = bm.LangUtil.getText("DOKB", "HELP_CONT_DETAIL2")
			-- {
			-- 	"满足夺宝单价即可参与夺宝,不同物品的参与单价不同;",
			-- 	"满足夺宝单价即可参与夺宝,不同物品的参与单价不同;",
			-- 	"满足夺宝单价即可参与夺宝,不同物品的参与单价不同;",
			-- 	"满足夺宝单价即可参与夺宝,不同物品的参与单价不同;",
			-- 	"满足夺宝单价即可参与夺宝,不同物品的参与单价不同;",
			-- 	"满足夺宝单价即可参与夺宝,不同物品的参与单价不同;",
			-- 	"满足夺宝单价即可参与夺宝,不同物品的参与单价不同;",
			-- 	"满足夺宝单价即可参与夺宝,不同物品的参与单价不同"
			-- }
		},

		tipsBot = bm.LangUtil.getText("DOKB", "HELP_TIPSBOT")
	}

	local tipsShownWidth = 568

	local tipsMagrins = {
		leftNor = 15,
		detailLeft = 48,
		firstTop = 10,
		titleContGap = 15,
		betweenSec = 30,
		contEach = 12,
		contentEnd = 18,
		starLeft = 22
	}

	local tipsLblParam = {
		frontSizes = {
			title = 20,
			cont = 18,
			tipsBot = 20
		},
		colors = {
			title = display.COLOR_WHITE,
			cont = cc.c3b(148, 154, 192),
			tipsBot = cc.c3b(224, 220, 97)
		}
	}

	local scrollContent = display.newNode()

	local container = display.newNode():addTo(scrollContent)

	local sumHeightContent = 0

	local tipsTitles = {}
	local tipsConts = {}

	local tipsBot = nil

	for i = 1, #tipsAllStr do
		tipsTitles[i] = display.newTTFLabel({text = tipsAllStr[i].title, size = tipsLblParam.frontSizes.title, color = tipsLblParam.colors.title,
			dimensions = cc.size(tipsShownWidth, 0), align = ui.TEXT_ALIGN_LEFT})
		tipsTitles[i]:setAnchorPoint(display.ANCHOR_POINTS[display.LEFT_TOP])

		tipsConts[i] = {}
		for j = 1, #tipsAllStr[i].cont do
			
			if i == #tipsAllStr then
				tipsShownWidth = tipsShownWidth - (tipsMagrins.detailLeft - tipsMagrins.starLeft) - 6
			end

			tipsConts[i][j] = display.newTTFLabel({text = tipsAllStr[i].cont[j], size = tipsLblParam.frontSizes.cont, color = tipsLblParam.colors.cont,
				dimensions = cc.size(tipsShownWidth, 0), align = ui.TEXT_ALIGN_LEFT})
			tipsConts[i][j]:setAnchorPoint(display.ANCHOR_POINTS[display.LEFT_TOP])

			if i == #tipsAllStr and j == #tipsAllStr[#tipsAllStr].cont then
				--todo
				tipsShownWidth = 586
				tipsBot = display.newTTFLabel({text = tipsAllStr.tipsBot, size = tipsLblParam.frontSizes.cont, color = tipsLblParam.colors.cont,
					dimensions = cc.size(tipsShownWidth, 0), align = ui.TEXT_ALIGN_LEFT})
				tipsBot:setAnchorPoint(display.ANCHOR_POINTS[display.LEFT_TOP])
			end
		end

		local sumHeightAboveTitle = 0
		local sumHeightAboveCont = 0

		for j = 1, i do
			for k = 1, #tipsConts[j] do

				if j == 1 then
					--todo
					if k == 1 then
						--todo
						sumHeightAboveCont = sumHeightAboveCont + tipsTitles[j]:getContentSize().height + tipsMagrins.titleContGap
					else
						sumHeightAboveCont = sumHeightAboveCont + tipsConts[j][k - 1]:getContentSize().height + tipsMagrins.contEach
					end
				else
					if k == 1 then
						--todo
						sumHeightAboveTitle = sumHeightAboveCont + tipsConts[j - 1][#tipsConts[j - 1]]:getContentSize().height 
							+ tipsMagrins.betweenSec

						sumHeightAboveCont = sumHeightAboveTitle + tipsTitles[j]:getContentSize().height + tipsMagrins.titleContGap
					else
						sumHeightAboveCont = sumHeightAboveCont + tipsConts[j][k - 1]:getContentSize().height + tipsMagrins.contEach
					end
				end

				if j >= i then
					--todo
					if j == 1 then
						--todo
						tipsConts[j][k]:pos(tipsMagrins.leftNor, - sumHeightAboveCont - tipsMagrins.firstTop)
								:addTo(container)

						-- if not tipsConts[j][k]:getParent() then
						-- 	--todo
						-- 	tipsConts[j][k]:pos(tipsMagrins.leftNor, - sumHeightAboveCont - tipsMagrins.firstTop)
						-- 		:addTo(container)
						-- end
					else
						local starPoint = display.newSprite("#dokb_starPnt.png")
						starPoint:pos(tipsMagrins.starLeft, - sumHeightAboveCont - tipsMagrins.firstTop - starPoint:getContentSize().height / 2)
							:addTo(container)

						tipsConts[j][k]:pos(tipsMagrins.detailLeft, - sumHeightAboveCont - tipsMagrins.firstTop)
							:addTo(container)
					end
				end

				if j == #tipsAllStr and k == #tipsConts[#tipsAllStr] then
					--todo
					tipsBot:pos(tipsMagrins.leftNor, - sumHeightAboveCont - tipsConts[j][k]:getContentSize().height - tipsMagrins.contentEnd - tipsMagrins.firstTop)
						:addTo(container)

					sumHeightContent = sumHeightAboveCont + tipsConts[j][k]:getContentSize().height + tipsBot:getContentSize().height + 
						tipsMagrins.contentEnd + tipsMagrins.firstTop * 2
				end

				-- if j == 1 and k == 1 then
				-- 	--todo
				-- 	sumHeightAboveCont = sumHeightAboveCont + tipsTitles[j]:getContentSize().height + tipsMagrins.titleContGap
				-- else
				-- 	sumHeightAboveTitle = 

				-- 	sumHeightAboveCont = 
				-- end
			end

			if j >= i then
				--todo
				tipsTitles[j]:pos(tipsMagrins.leftNor, - sumHeightAboveTitle - tipsMagrins.firstTop)
					:addTo(container)
			end
		end
	end

	local helpContListViewParam = {
		width = 600,
		height = 322
	}

	local containerPosFix = {
		x = 0,
		y = 0
	}

	-- scrollContent:setContentSize(helpContListViewParam.width, sumHeightContent)  -- SetContentSize ,UptoRefresh Ui
	container:pos(- helpContListViewParam.width / 2 + containerPosFix.x, sumHeightContent / 2 - containerPosFix.y)

	local scrollViewPosAdj = {
		x = 5,
		y = 20
	}
	self.helpContScrollView_ = bm.ui.ScrollView.new({viewRect = cc.rect(- helpContListViewParam.width / 2, - helpContListViewParam.height / 2,
		helpContListViewParam.width, helpContListViewParam.height), scrollContent = scrollContent, direction = bm.ui.ScrollView.DIRECTION_VERTICAL})
        :pos(- scrollViewPosAdj.x, - scrollViewPosAdj.y)
        :addTo(self)
end

function DokbActHelpPopup:onCloseBtnCallBack_(evt)
	-- body
	nk.PopupManager:removePopup(self)
end

function DokbActHelpPopup:showPanel(popUpCallBack)
	-- body
	self.showedCallBack_ = popUpCallBack
	nk.PopupManager:addPopup(self)
end

function DokbActHelpPopup:onShowed()
	-- body
	if self and self.helpContScrollView_ then
		--todo
		self.helpContScrollView_:update()
	end
	
	if self and self.showedCallBack_ then
		--todo
		self.showedCallBack_()
	end
end

function DokbActHelpPopup:onEnter()
	-- body
end

function DokbActHelpPopup:onExit()
	-- body
end

function DokbActHelpPopup:onCleanup()
	-- body
end

return DokbActHelpPopup