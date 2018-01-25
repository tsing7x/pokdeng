--
-- Author: TsingZhang@boyaa.com
-- Date: 2016-03-30 12:03:30
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- Description: GucuReCallPopup By TsingZhang.
--
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
local CommonRewardChipAnimation = import("app.login.CommonRewardChipAnimation")

local GucuReCallPanelSize = {
	WIDTH = 755,
	HEIGHT = 435
}

local GucuReCallPopup = class("GucuReCallPopup", nk.ui.Panel)

function GucuReCallPopup:ctor()
	-- body
	self.super.ctor(self, {GucuReCallPanelSize.WIDTH, GucuReCallPanelSize.HEIGHT})
	display.addSpriteFrames("gucu_recall.plist", "gucu_recall.png")

	self:setNodeEventEnabled(true)
	self:renderTitleArea()
	self:renderMainArea()

	self:loadData_()
	-- self.isPanelCanClose_ = false

	-- self:playRewardAnim()
end

function GucuReCallPopup:renderTitleArea()
	-- body
	local gucuTitleWidthFix = 1
	local titleBorSize = {
		width = GucuReCallPanelSize.WIDTH - gucuTitleWidthFix * 2,
		height = 55
	}

	local titleBorBgPosYShift = 0
	local titleBorBg = display.newScale9Sprite("#gucu_blockTitle.png", 0, GucuReCallPanelSize.HEIGHT / 2 - titleBorSize.height / 2 - titleBorBgPosYShift,
		cc.size(titleBorSize.width, titleBorSize.height))
		:addTo(self)

	local titleLabParam = {
		frontSize = 30,
		color = cc.c3b(119, 148, 191)
	}

	local titleLabel = display.newTTFLabel({text = bm.LangUtil.getText("GUCURECALL", "WELCOME_BACK"), size = titleLabParam.frontSize, color = titleLabParam.color, align = ui.TEXT_ALIGN_CENTER})
		:pos(titleBorSize.width / 2, titleBorSize.height / 2)
		:addTo(titleBorBg)

	self:addCloseBtn()
end

function GucuReCallPopup:renderMainArea()
	-- body
	local titleBorBgSizeHeight = 55

	local tipsMainLabelParam = {
		frontSize = 20,
		color = cc.c3b(170, 170, 170),
		shownWidth = 708
	}

	local tipsMainLabMagrinTop = 4

	local tipsMainLab = display.newTTFLabel({text = bm.LangUtil.getText("GUCURECALL", "WELCOME_GREETS"), size = tipsMainLabelParam.frontSize,
		color = tipsMainLabelParam.color, dimensions = cc.size(tipsMainLabelParam.shownWidth, 0), align = ui.TEXT_ALIGN_LEFT})

	local tipsMainLabelContSize = tipsMainLab:getContentSize()
	tipsMainLab:pos(0, GucuReCallPanelSize.HEIGHT / 2 - titleBorBgSizeHeight - tipsMainLabMagrinTop - tipsMainLabelContSize.height / 2)
		:addTo(self)

	local rewardBgDentSize = {
		width = 718,
		height = 196
	}

	local rewardBgDentMagrinTop = 6
	local rewardBgDent = display.newScale9Sprite("#gucu_bgDent.png", 0, tipsMainLab:getPositionY() - tipsMainLabelContSize.height / 2 - rewardBgDentMagrinTop - rewardBgDentSize.height / 2,
		cc.size(rewardBgDentSize.width, rewardBgDentSize.height))
		:addTo(self)

	-- 奖励主体 --
	local rewardItemMagrinLeftRight = 50
	local rewardItemModel = display.newSprite("#gucu_item_2.png")
	local rewModelContSize = rewardItemModel:getContentSize()

	local rewItemRangeGap = (rewardBgDentSize.width - rewardItemMagrinLeftRight * 2 - rewModelContSize.width * 3) / 2

	self.rewardItemDescLbl_ = {}

	local rewardItemDescLblParam = {
		frontSize = 22,
		color = display.COLOR_WHITE
	}

	local rewItemDescLblPosY = 20
	for i = 1, 3 do
		local rewardItem = display.newSprite("#gucu_item_" .. i .. ".png")
			:pos(rewardItemMagrinLeftRight + rewModelContSize.width / 2 * (2 * i - 1) + rewItemRangeGap * (i - 1), rewardBgDentSize.height / 2)
			:addTo(rewardBgDent)

		self.rewardItemDescLbl_[i] = display.newTTFLabel({text = "desc :" .. i, size = rewardItemDescLblParam.frontSize, color = rewardItemDescLblParam.color,
			align = ui.TEXT_ALIGN_CENTER})
			:pos(rewModelContSize.width / 2, rewItemDescLblPosY)
			:addTo(rewardItem)
	end

	-- End --
	local tipsBotLabParam = {
		frontSize = 22,
		color = cc.c3b(212, 183, 62)
	}

	local tipsBotMagrinBottom = 6

	self.tipsBotLabel_ = display.newTTFLabel({text = "tips Bottom", size = tipsBotLabParam.frontSize, color = tipsBotLabParam.color,
		align = ui.TEXT_ALIGN_CENTER})

	local tipsBotLabContSize = self.tipsBotLabel_:getContentSize()
	self.tipsBotLabel_:pos(0, - GucuReCallPanelSize.HEIGHT / 2 + tipsBotLabContSize.height / 2 + tipsBotMagrinBottom)
		:addTo(self)

	local splitLineSizeWidthFixSide = 1
	local splitLineSize = {
		width = GucuReCallPanelSize.WIDTH - splitLineSizeWidthFixSide * 2,
		height = 4
	}

	local splitLineMagrinBot = 6
	local splitLine = display.newScale9Sprite("#gucu_splitLine.png", 0, self.tipsBotLabel_:getPositionY() + tipsBotLabContSize.height / 2 + splitLineMagrinBot + splitLineSize.height / 2,
		cc.size(splitLineSize.width, splitLineSize.height))
		:addTo(self)

	local getRewBtnSize = {
		width = 168,
		height = 58
	}

	local getRewBtnMagrinBot = 10

	local getRewBtnLabelParam = {
		frontSize = 28,
		color = display.COLOR_WHITE
	}

	local getRewardBtn = cc.ui.UIPushButton.new({normal = "#gucu_btnGreen.png", pressed = "#gucu_btnGreen.png", disabled = "#common_btn_disabled.png"},
		{scale9 = true})
		:setButtonSize(getRewBtnSize.width, getRewBtnSize.height)
		:onButtonClicked(buttontHandler(self, self.onRewardBtnGetCallBack_))
		:setButtonLabel("normal", display.newTTFLabel({text = bm.LangUtil.getText("GUCURECALL", "CLKTO_GET"), size = getRewBtnLabelParam.frontSize, color = getRewBtnLabelParam.color, align = ui.TEXT_ALIGN_CENTER}))
		:pos(0, splitLine:getPositionY() + splitLineSize.height / 2 + getRewBtnSize.height / 2 + getRewBtnMagrinBot)
		:addTo(self)
end

function GucuReCallPopup:onRewardBtnGetCallBack_(evt)
	-- body
	-- dump("Succ Get Recall Reward!")
	self:hidePanel_()
end

function GucuReCallPopup:loadData_()
	-- body
	-- dump(nk.userData.recallAward, "recallAward: ==================")

	local rewardItemDesc = {
		bm.LangUtil.getText("GUCURECALL", "REWARD_HDDJ") .. " *",
		bm.LangUtil.getText("GUCURECALL", "REWARD_CHIP") .. " *",
		bm.LangUtil.getText("GUCURECALL", "REWARD_SILVER_SEED") .. " *"
	}

	for i = 1, #nk.userData.recallAward.award do
		local rewardNum = nk.userData.recallAward.award[i].num or 0

		if self.rewardItemDescLbl_[i] then
			--todo
			self.rewardItemDescLbl_[i]:setString(rewardItemDesc[i] .. rewardNum)
		end
	end

	if nk.userData.recallAward.warning then
		--todo
		self.tipsBotLabel_:setString(nk.userData.recallAward.warning)
	else
		self.tipsBotLabel_:setString("")
	end

	-- Already Get Reward, Modify To Unget State.
	-- nk.userData.hddjNum = (nk.userData.hddjNum or 0) - checkint(nk.userData.recallAward.award[1].num)
	-- nk.userData["aUser.money"] = (nk.userData["aUser.money"] or 0) - checkint(nk.userData.recallAward.award[2].num)
	-- nk.userData["match.point"] = (nk.userData["match.point"] or 0) - checkint(nk.userData.recallAward.award[3].num)
end

function GucuReCallPopup:playRewardAnim()
	-- body
	if nk.userData.recallAward.ret == 1 then
        nk.userData.recallAward.ret = - 1
        
        self.schedulerUpdateNumHandler_ = scheduler.performWithDelayGlobal(function()
        	-- body
        	nk.userData.hddjNum = (nk.userData.hddjNum or 0) + checkint(nk.userData.recallAward.award[1].num or 0)
	        nk.userData["aUser.money"] = (nk.userData["aUser.money"] or 0) + checkint(nk.userData.recallAward.award[2].num or 0)
	        nk.userData["match.point"] = (nk.userData["match.point"] or 0) + checkint(nk.userData.recallAward.award[3].num or 0)
        end, 1)

        self.animation_ = CommonRewardChipAnimation.new()
        	:pos(display.cx, display.cy)
            :addTo(nk.runningScene, 999)
        self.changeChipAnim_ = nk.ui.ChangeChipAnim.new(checkint(nk.userData.recallAward.award[2].num))
        	:pos(display.cx, display.cy)
            :addTo(nk.runningScene, 999)
    end
end

function GucuReCallPopup:showPanel()
	-- body
	self:showPanel_(true, true, true, true)
end

function GucuReCallPopup:onRemovePopup(removeFunc)
	self:playRewardAnim()
    removeFunc()
end

function GucuReCallPopup:onShowed()
	-- body
end

function GucuReCallPopup:onEnter()
	-- body
end

function GucuReCallPopup:onExit()
	-- body
	display.removeSpriteFramesWithFile("gucu_recall.plist", "gucu_recall.png")
	nk.schedulerPool:delayCall(function()
	    cc.Director:getInstance():getTextureCache():removeUnusedTextures()
	end, 0.1)
end

function GucuReCallPopup:onCleanup()
	-- body
	-- if self.schedulerUpdateNumHandler_ then
 --        scheduler.unscheduleGlobal(self.schedulerUpdateNumHandler_)
 --        self.schedulerUpdateNumHandler_ = nil
 --    end
end

return GucuReCallPopup