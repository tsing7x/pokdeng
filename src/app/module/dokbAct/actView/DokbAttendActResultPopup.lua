--
-- Author: TsingZhang@boyaa.com
-- Date: 2016-05-31 15:05:36
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- Description: DokbAttendActResultPopup.lua By TsingZhang.
--

local attendResultPanelParam = {
	WIDTH = 622,
	HEIGHT = 366
}

local DokbAttendActResultPopup = class("DokbAttendActResultPopup", function()
	-- body
	return display.newNode()
end)

-- @param resultData, resultData.code :LotryCode, Not Needed.; resultData.type :Result Type, Needed.
function DokbAttendActResultPopup:ctor(resultData)
	-- body
	self:setNodeEventEnabled(true)

	self.background_ = display.newScale9Sprite("#dokb_bgActPanel.png", 0, 0, cc.size(attendResultPanelParam.WIDTH, attendResultPanelParam.HEIGHT))
		:addTo(self)

	self.background_:setTouchEnabled(true)
	self.background_:setTouchSwallowEnabled(true)

	self:renderMainView(resultData)
	self:drawCloseBtn()
end

function DokbAttendActResultPopup:renderMainView(data)
	-- body
	local bgDentPanelSize = {
		width = 555,
		height = 236
	}
	local bgDentMagrinTop = 16

	local bgDentPanel = display.newScale9Sprite("#dokb_bgDent.png", attendResultPanelParam.WIDTH / 2, attendResultPanelParam.HEIGHT - bgDentPanelSize.height / 2
		- bgDentMagrinTop, cc.size(bgDentPanelSize.width, bgDentPanelSize.height))
		:addTo(self.background_)

	local infoLblParam = {
		frontSizes = {
			resultTips = 26,
			checkLotry = 20,
			getBtn = 22
		},
		colors = {
			resultTips = cc.c3b(241, 230, 112),
			checkLotry = display.COLOR_WHITE,
			getBtn = display.COLOR_WHITE
		}
	}

	local resultInfoShownBorderMagrin = 5
	-- local resultTipsShownWidth = 408
	local resultTipsMagrinTop = 35
	local resultTipsMagrinEach = 20

	local resultTipsStr = {
		[1] = {
			tips = bm.LangUtil.getText("DOKB", "ATTRESULT_SUCC")
			-- "恭喜您夺宝成功,您的夺宝编号为:",
		},
		[2] = {
			tips = bm.LangUtil.getText("DOKB", "ATTRESULT_FAILD_CURRENCY_SHORT")
			-- "夺宝失败,您的现金币或筹码不足。"
		},
		[3] = {
			tips1 = bm.LangUtil.getText("DOKB", "ATTRESULT_FAILD_TIMEFULL"),
			-- "夺宝失败,您已经夺宝该物品三次啦",
			tips2 = bm.LangUtil.getText("DOKB", "ATTRESULT_CHANGE_ANOTHER")
			-- "换一个试试吧！"
		}
	}

	local resultTips1 = nil
	local resultTips2 = nil

	local drawResultTipsLblByType = {
		[1] = function()
			-- body
			resultTips1 = display.newTTFLabel({text = resultTipsStr[1].tips, size = infoLblParam.frontSizes.resultTips, color = infoLblParam.colors.resultTips,
				dimensions = cc.size(bgDentPanelSize.width - resultInfoShownBorderMagrin * 2, 0), align = ui.TEXT_ALIGN_CENTER})
			resultTips1:pos(bgDentPanelSize.width / 2, bgDentPanelSize.height - resultTips1:getContentSize().height / 2 - resultTipsMagrinTop)
				:addTo(bgDentPanel)

			resultTips2 = display.newTTFLabel({text = data.code or "0", size = infoLblParam.frontSizes.resultTips, color = display.COLOR_RED,
				dimensions = cc.size(bgDentPanelSize.width - resultInfoShownBorderMagrin * 2, 0), align = ui.TEXT_ALIGN_CENTER})
			-- resultTips2:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER_LEFT])
			resultTips2:pos(bgDentPanelSize.width / 2, resultTips1:getPositionY() - resultTips1:getContentSize().height / 2 - resultTipsMagrinEach 
				- resultTips2:getContentSize().height / 2)
				:addTo(bgDentPanel)
		end,

		[2] = function()
			-- body
			resultTips1 = display.newTTFLabel({text = resultTipsStr[2].tips, size = infoLblParam.frontSizes.resultTips, color = infoLblParam.colors.resultTips,
				dimensions = cc.size(bgDentPanelSize.width - resultInfoShownBorderMagrin * 2, 0), align = ui.TEXT_ALIGN_CENTER})
			resultTips1:pos(bgDentPanelSize.width / 2, bgDentPanelSize.height - resultTips1:getContentSize().height / 2 - resultTipsMagrinTop)
				:addTo(bgDentPanel)
		end,

		[3] = function()
			-- body
			resultTips1 = display.newTTFLabel({text = resultTipsStr[3].tips1, size = infoLblParam.frontSizes.resultTips,	color = infoLblParam.colors.resultTips,
				dimensions = cc.size(bgDentPanelSize.width - resultInfoShownBorderMagrin * 2, 0), align = ui.TEXT_ALIGN_CENTER})
			resultTips1:pos(bgDentPanelSize.width / 2, bgDentPanelSize.height - resultTips1:getContentSize().height / 2 - resultTipsMagrinTop)
				:addTo(bgDentPanel)

			resultTips2 = display.newTTFLabel({text = resultTipsStr[3].tips2, size = infoLblParam.frontSizes.resultTips, color = infoLblParam.colors.resultTips,
				dimensions = cc.size(bgDentPanelSize.width - resultInfoShownBorderMagrin * 2, 0), align = ui.TEXT_ALIGN_CENTER})
			resultTips2:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER_LEFT])
			resultTips2:pos(bgDentPanelSize.width / 2 - resultTips1:getContentSize().width / 2, resultTips1:getPositionY() - resultTips1:getContentSize().height / 2
				- resultTipsMagrinEach - resultTips2:getContentSize().height / 2)
				:addTo(bgDentPanel)
		end
	}

	drawResultTipsLblByType[data.type or 3]()

	-- local resultTips = display.newTTFLabel({text = "夺宝失败,您已经夺宝该物品三次啦\n换一个试试吧", size = infoLblParam.frontSizes.resultTips,
	-- 	color = infoLblParam.colors.resultTips, dimensions = cc.size(resultTipsShownWidth, 0), align = ui.TEXT_ALIGN_LEFT})
	-- -- resultTips:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER_LEFT])
	-- resultTips:pos(bgDentPanelSize.width / 2, bgDentPanelSize.height - resultTips:getContentSize().height / 2 - resultTipsMagrinTop)
	-- 	-- :align(display.LEFT)
	-- 	:addTo(bgDentPanel)

	local divLinePaddingBot = 75

	local divLineWidthFixHoriz = 40
	local dividLineContSize = {
		width = bgDentPanelSize.width - divLineWidthFixHoriz * 2,
		height = 2
	}

	local infoDivLine = display.newScale9Sprite("#dokb_divLine_info.png", bgDentPanelSize.width / 2, divLinePaddingBot,
		cc.size(dividLineContSize.width, dividLineContSize.height))
		:addTo(bgDentPanel)

	local tipsCheckLotryMagrinTop = 24

	local tipCheckLotry = display.newTTFLabel({text = bm.LangUtil.getText("DOKB", "ATTRESULT_CHECKNO_TIP"), size = infoLblParam.frontSizes.checkLotry,
		color = infoLblParam.colors.checkLotry, align = ui.TEXT_ALIGN_CENTER})
	tipCheckLotry:pos(bgDentPanelSize.width / 2, infoDivLine:getPositionY() - tipsCheckLotryMagrinTop - tipCheckLotry:getContentSize().height / 2)
		:addTo(bgDentPanel)

	local gotKnwBtnSize = {
		width = 130,
		height = 54
	}
	local gotKnwBtnMagrinBot = 42

	self.gotKnwBtn_ = cc.ui.UIPushButton.new({normal = "#common_btnGreenCor_nor.png", pressed = "#common_btnGreenCor_pre.png", disabled = "#common_btn_disabled.png"},
		{scale9 = true})
		:setButtonSize(gotKnwBtnSize.width, gotKnwBtnSize.height)
		:setButtonLabel(display.newTTFLabel({text = bm.LangUtil.getText("DOKB", "ATTRESULT_GETKNOWN"), size = infoLblParam.frontSizes.getBtn, color = infoLblParam.colors.getBtn,
			align = ui.TEXT_ALIGN_CENTER}))
		:onButtonClicked(buttontHandler(self, self.onGetKnwBtnCallBack_))
		:pos(attendResultPanelParam.WIDTH / 2, gotKnwBtnSize.height / 2 + gotKnwBtnMagrinBot)
		:addTo(self.background_)
end

function DokbAttendActResultPopup:drawCloseBtn()
	-- body
	local closBtnPosAdj = {
		x = 8,
		y = 8
	}

	local closeBtn = cc.ui.UIPushButton.new({normal = "#dokb_btnClose_nor.png", pressed = "#dokb_btnClose_pre.png", disabled = "#dokb_btnClose_nor.png"},
		{scale9 = false})
		:onButtonClicked(buttontHandler(self, self.onCloseBtnCallBack_))
		:pos(attendResultPanelParam.WIDTH - closBtnPosAdj.x, attendResultPanelParam.HEIGHT - closBtnPosAdj.y)
		:addTo(self.background_)
end

function DokbAttendActResultPopup:onGetKnwBtnCallBack_(evt)
	-- body
	nk.PopupManager:removePopup(self)
end

function DokbAttendActResultPopup:onCloseBtnCallBack_(evt)
	-- body
	nk.PopupManager:removePopup(self)
end

function DokbAttendActResultPopup:showPanel()
	-- body
	nk.PopupManager:addPopup(self)
end

function DokbAttendActResultPopup:onEnter()
	-- body
end

function DokbAttendActResultPopup:onExit()
	-- body
end

function DokbAttendActResultPopup:onCleanup()
	-- body
end

return DokbAttendActResultPopup