local config = import(".Config")

local pa = import(".Init")
local ChipItem = import(".PromotItemChip")
local HelpPopup = import(".PromotHelpPopup")
local SharePopup = import(".PromotSharePopup")
local PromotActModule = import(".PromotActModule")

local chipsMagrin = {
		left = 55,
		each = 7,
		bottom = 30
}

local PromotActPopup = class("PromotActPopup", function()
	-- body
	return display.newNode()
end)

function PromotActPopup:ctor()
	-- body
	self:setNodeEventEnabled(true)

	pa.loadTexture()

	bm.EventCenter:addEventListener(nk.eventNames.PROMOT_GET_TASK_STATUS_DATA_SUCC, handler(self, self._onGetTaskStatuSucc))
	bm.EventCenter:addEventListener(nk.eventNames.PROMOT_GET_TASK_STATUS_DATA_FAIL, handler(self, self.showBadNetDialog))

	-- Initialization --
	self._background = display.newSprite("#prom_bg.png")
		-- :pos(0, 0)
		:addTo(self)

	self._background:setTouchEnabled(true)
	self._background:setTouchSwallowEnabled(true)

	self:setupViews()

end

function PromotActPopup:setupViews()
	-- body

	-- title --

	local titlePosFix = {
		x = 10,
		y = 10
	}

	local titleSpr = display.newSprite("#prom_title.png")
		:pos(config.PromotActPanelParam.WIDTH / 2 + titlePosFix.x,
			config.PromotActPanelParam.HEIGHT - titlePosFix.y)
		:addTo(self._background)

	-- PromotItemChips --

	-- loadData from svr first --

	self:drawRewardChips()

	-- bottomBar -- 
	self:drawBottomBar()

	-- Curtain --
	self:drawCurtains()

	-- button --
	self:setupButtons()

	PromotActModule.getDataListSvr()

	self:showLoadingForRefreshUi(true)
end

function PromotActPopup:drawRewardChips()
	-- body

	-- drawComonChips --
	local itemParamInitData = {
		{finishNum = 0, state = 2},
		{finishNum = 0, state = 1},
		{finishNum = 0, state = 1}
	}

	self._chipsItemList = {}

	for i = 1, 3 do
		self._chipsItemList[i] = ChipItem.new(false, i, itemParamInitData[i])

		self._chipsItemList[i]:pos(chipsMagrin.left + config.ChipItemParam.WIDTH / 2 * (2 * i - 1) + chipsMagrin.each * (i - 1),
			chipsMagrin.bottom + config.ChipItemParam.HEIGHT / 2)
			:addTo(self._background)
	end
end


function PromotActPopup:drawCurtains()
	-- body

	local curtainPosAdjust = {
		x = 15,
		y = 10
	}

	local curtainLeft = display.newSprite("#prom_curtLeft.png")
	curtainLeft:pos(curtainPosAdjust.x,
		config.PromotActPanelParam.HEIGHT - curtainLeft:getContentSize().height / 2 - curtainPosAdjust.y)
		:addTo(self._background)

	local curtainRight = display.newSprite("#prom_curtLeft.png")
		:pos(config.PromotActPanelParam.WIDTH - curtainPosAdjust.x,
			config.PromotActPanelParam.HEIGHT - curtainLeft:getContentSize().height / 2 - curtainPosAdjust.y)
		:addTo(self._background)
		:flipX(true)
end

function PromotActPopup:setupButtons()
	-- body

	local closeBtnPosShift = {
		x = 8,
		y = 8
	}

	local closeBtn = cc.ui.UIPushButton.new("#prom_btnClose.png", {scale9 = false})
		:pos(config.PromotActPanelParam.WIDTH - closeBtnPosShift.x,
			config.PromotActPanelParam.HEIGHT - closeBtnPosShift.y)
		:onButtonClicked(buttontHandler(self, self._onCloseCallBack))
		:addTo(self._background)

	local helpBtnPadding = {
		left = 35,
		top = 40
	}

	local helpBtn = cc.ui.UIPushButton.new("#prom_help.png", {scale9 = false})
		:pos(helpBtnPadding.left, config.PromotActPanelParam.HEIGHT - helpBtnPadding.top)
		:onButtonClicked(buttontHandler(self, self._onHelpCallBack))
		:addTo(self._background)
end

function PromotActPopup:drawBottomBar()
	-- body

	local bottomBarMagrinBottom = 30
	local bottomBarPosXAdjust = 0

	local bottomBar = display.newSprite("#prom_barBottom.png")
	bottomBar:pos(config.PromotActPanelParam.WIDTH / 2 + bottomBarPosXAdjust, bottomBarMagrinBottom + bottomBar:getContentSize().height / 2)
		:addTo(self._background)

	local rewardIconPosXAdjust = {
		chips = - 45,
		gift = 115
	}

	local sumRewardChipIcon = display.newSprite("#prom_rewardChips.png")
		:pos(bottomBar:getContentSize().width / 2 + rewardIconPosXAdjust.chips, bottomBar:getContentSize().height / 2)
		:addTo(bottomBar)

	local sumRewardGiftIcon = display.newSprite("#prom_rewardSGift.png")
		:pos(bottomBar:getContentSize().width / 2 + rewardIconPosXAdjust.gift, bottomBar:getContentSize().height / 2)
		:addTo(bottomBar)

	-- local tipsMagrin = {
	-- 	left = 20,
	-- 	bottomTop = 10,
	-- 	each = 5
	-- }

	-- local tipsP1 = display.newTTFLabel({text = "aaa", size = config.PromotActPanelParam.bottomBarParam.frontSizes.tips, align = ui.TEXT_ALIGN_CENTER})
	-- tipsP1:setAnchorPoint(display.ANCHOR_POINTS[display.TOP_LEFT])
	-- tipsP1:pos(tipsMagrin.left, bottomBar:getContentSize().height - tipsMagrin.bottomTop)
	-- 	:addTo(bottomBar)

	-- self._needCompleteChipsNum = display.newTTFLabel({text = tostring(3), size = config.PromotActPanelParam.bottomBarParam.frontSizes.tips,
	-- 	color = config.PromotActPanelParam.bottomBarParam.colors.tipsNumFrontColor, align = ui.TEXT_ALIGN_CENTER})
	-- self._needCompleteChipsNum:setAnchorPoint(display.ANCHOR_POINTS[display.LEFT_TOP])
	-- self._needCompleteChipsNum:pos(tipsMagrin.left + tipsP1:getContentSize().width + tipsMagrin.each, bottomBar:getContentSize().height - tipsMagrin.bottomTop)
	-- 	:addTo(bottomBar)

	-- local tipsP2 = display.newTTFLabel({text = "bbbbbbbbbbb", size = config.PromotActPanelParam.bottomBarParam.frontSizes.tips, align = ui.TEXT_ALIGN_CENTER})
	-- tipsP2:setAnchorPoint(display.ANCHOR_POINTS[display.LEFT_TOP])
	-- tipsP2:pos(tipsMagrin.left + tipsP1:getContentSize().width + tipsMagrin.each * 2 + self._needCompleteChipsNum:getContentSize().width,
	-- bottomBar:getContentSize().height - tipsMagrin.bottomTop)
	-- 	:addTo(bottomBar)

	-- local tipsP3 = display.newTTFLabel({text = "ccccccccccccccc", size = config.PromotActPanelParam.bottomBarParam.frontSizes.tips, align = ui.TEXT_ALIGN_CENTER})
	-- tipsP3:setAnchorPoint(display.ANCHOR_POINTS[display.LEFT_BOTTOM])
	-- tipsP3:pos(tipsMagrin.left, tipsMagrin.bottomTop)
	-- 	:addTo(bottomBar)

	-- self._rewardContDesc = display.newTTFLabel({text = "dddddddddddddddd", size = config.PromotActPanelParam.bottomBarParam.frontSizes.tips,
	-- 	color = config.PromotActPanelParam.bottomBarParam.colors.tipsNumFrontColor, align = ui.TEXT_ALIGN_CENTER})
	-- self._rewardContDesc:setAnchorPoint(display.ANCHOR_POINTS[display.LEFT_BOTTOM])
	-- self._rewardContDesc:pos(tipsMagrin.left + tipsP3:getContentSize().width + tipsMagrin.each, tipsMagrin.bottomTop)
	-- 	:addTo(bottomBar)

	local getRewardBtnMagrinright = 10
	local BtnSize = {
		width = 136,
		height = 44
	}

	self._getRewardBtn = cc.ui.UIPushButton.new("#prom_unGetAllReward.png", {scale9 = false})
		-- :setButtonLabel("normal", display.newTTFLabel({text = "kkkkkk", size = config.PromotActPanelParam.bottomBarParam.frontSizes.btn,
		-- 	color = config.PromotActPanelParam.bottomBarParam.colors.tipsNumFrontColor, align = ui.TEXT_ALIGN_CENTER}))
		:onButtonClicked(buttontHandler(self, self._onGetRewardCallBack))
		:pos(bottomBar:getContentSize().width - getRewardBtnMagrinright - BtnSize.width / 2,
			bottomBar:getContentSize().height / 2)
		:addTo(bottomBar)

end

function PromotActPopup:refreshActUI()
	-- body

	self:showLoadingForRefreshUi(false)

	local finalRewardGetStatu = self._taskStatusDataList.finalRewardStatu

	if finalRewardGetStatu == 3 then
		--todo
		self._getRewardBtn:setButtonImage("normal", "#prom_imGetAllReward.png")
			:setButtonImage("pressed", "#prom_imGetAllReward.png")
		self._isCanGetReward = true
	else
		if finalRewardGetStatu == 4 then
			--todo
			self._getRewardBtn:setButtonImage("normal", "#prom_unGetAllReward.png")
				:setButtonImage("pressed", "#prom_unGetAllReward.png")
			self._isCanGetReward = false
		end
	end

	for i = 1, #self._chipsItemList do
		self._chipsItemList[i]:removeFromParent()
		self._chipsItemList[i] = nil
	end

	for i = 1, 3 do

		local isClaimed = self._taskStatusDataList[i].state == 4 or false

		self._chipsItemList[i] = ChipItem.new(isClaimed, i, self._taskStatusDataList[i])

		self._chipsItemList[i]:pos(chipsMagrin.left + config.ChipItemParam.WIDTH / 2 * (2 * i - 1) + chipsMagrin.each * (i - 1),
			chipsMagrin.bottom + config.ChipItemParam.HEIGHT / 2)
			:addTo(self._background)
	end

end

function PromotActPopup:_onCloseCallBack()
	-- body
	nk.PopupManager:removePopup(self)
end

function PromotActPopup:_onHelpCallBack()
	-- body
	HelpPopup.new():show()
end

function PromotActPopup:_onGetRewardCallBack()
	-- body

	-- just for test SharePopup --
	-- SharePopup.new():show()
	-- end --

	if self._isCanGetReward then
		
		local claimFinalRewardId = nk.http.claimUnionActRewardSum(
			function(data)
				-- body

				dump(data, "claimFinalReward.data :========================")

				nk.userData["aUser.money"] = data.money
				nk.userData["aUser.gift"] = data.propsid
				nk.TopTipManager:showTopTip(bm.LangUtil.getText("LOGIN", "REWARD_SUCCEED"))

				PromotActModule.getDataListSvr()
				self:showLoadingForRefreshUi(true)

				SharePopup.new():show()
			end,

			function(errData)
				-- body
				dump(errData, "claimFinalReward.errData :======================")
				nk.TopTipManager:showTopTip(bm.LangUtil.getText("CUNIONACT", "GET_REWARD_FAILED"))
			end)
		return
	end
end

function PromotActPopup:show()
	-- body
	nk.PopupManager:addPopup(self, true, true, true, true)

end

function PromotActPopup:showLoadingForRefreshUi(loading)
	-- body
	if loading then
        if not self.juhua_ then
            self.juhua_ = nk.ui.Juhua.new()
                :pos(0, 0)
                :addTo(self)
        end
    else
        if self.juhua_ then
            self.juhua_:removeFromParent()
            self.juhua_ = nil
        end
    end
end

-- event handle functions --
function PromotActPopup:_onGetTaskStatuSucc()
	-- body
	self._taskStatusDataList = PromotActModule.getClaimStatuListData()

	-- dump(self._taskStatusDataList, "_taskStatusDataList :====================")

	self:refreshActUI()
end

function PromotActPopup:showBadNetDialog()
	-- body
	if self.juhua_ then
		--todo
		self.juhua_:removeFromParent()
        self.juhua_ = nil
	end

	nk.ui.Dialog.new({
        messageText = bm.LangUtil.getText("COMMON", "REQUEST_DATA_FAIL"), 
                secondBtnText = bm.LangUtil.getText("COMMON", "RETRY"), 
                callback = function (type)
                    if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                        PromotActModule.getDataListSvr()
                        self:showLoadingForRefreshUi(true)
                    end
                end
    }):show()
end

-- Not excute --
function PromotActPopup:onEnter()
	-- body
end

function PromotActPopup:onExit()
	-- body
	pa.removeTexture()

	bm.EventCenter:removeEventListenersByEvent(nk.eventNames.PROMOT_GET_TASK_STATUS_DATA_SUCC)
	bm.EventCenter:removeEventListenersByEvent(nk.eventNames.PROMOT_GET_TASK_STATUS_DATA_FAIL)
end

return PromotActPopup