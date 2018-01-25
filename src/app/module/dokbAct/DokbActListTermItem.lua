--
-- Author: TsingZhang@boyaa.com
-- Date: 2016-05-27 17:29:54
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- Description: DokbActListTermItem.lua By TsingZhang.
--

local AttendActPopup = import(".actView.DokbAttendActPopup")

local dokbActTermItemParam = {
	WIDTH = 252,
	HEIGHT = 324,

	FLAG = {
		WIDTH = 232,
		HEIGHT = 25
	}
}

local DokbActListTermItem = class("DokbActListTermItem", function()
	-- body
	return display.newNode()
end)

function DokbActListTermItem:ctor()
	-- body
	self:setNodeEventEnabled(true)

	self.background_ = display.newScale9Sprite("#dokb_bgActListTermItem.png", 0, 0, cc.size(dokbActTermItemParam.WIDTH, dokbActTermItemParam.HEIGHT))
		:addTo(self)

	self.background_:setTouchEnabled(true)
	self.background_:setTouchSwallowEnabled(true)

	local decPrunu = display.newSprite("#dokb_bgDec_actListItem.png")
	decPrunu:pos(dokbActTermItemParam.WIDTH / 2, dokbActTermItemParam.HEIGHT - decPrunu:getContentSize().height / 2)
		:addTo(self.background_)

	local stateFlagMagrinTop = 8

	self.stateFlag_ = display.newScale9Sprite("#dokb_actTermFlag_red.png", dokbActTermItemParam.FLAG.WIDTH / 2, dokbActTermItemParam.HEIGHT 
		- dokbActTermItemParam.FLAG.HEIGHT / 2 - stateFlagMagrinTop, cc.size(dokbActTermItemParam.FLAG.WIDTH, dokbActTermItemParam.FLAG.HEIGHT))
		:addTo(self.background_)

	local infoLblParam = {
		frontSizes = {
			stateTip = 16,
			gemName = 22,
			ltryNdTerm = 15,
			ltryNdNumInfo = 15,
			involInfo = 15,
			btnAttend = 30,
			tipBot = 14
		},

		colors = {
			stateTip = display.COLOR_WHITE,
			gemName = cc.c3b(98, 58, 0),
			ltryNdTerm = cc.c3b(98, 58, 0),
			ltryNdNumInfo = cc.c3b(103, 55, 229),
			involInfo = cc.c3b(119, 74, 3),
			btnAttend = display.COLOR_WHITE,
			tipBot = display.COLOR_WHITE
		}
	}

	-- local stateTipLblParam = {
	-- 	frontSize = 18,
	-- 	color = display.COLOR_WHITE
	-- }

	local stateTipsMagrinLeft = 5
	self.stateTip_ = display.newTTFLabel({text = bm.LangUtil.getText("DOKB", "GEMSTATE_FINISH"), size = infoLblParam.frontSizes.stateTip, color = infoLblParam.colors.stateTip,
		align = ui.TEXT_ALIGN_CENTER})
	self.stateTip_:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER_LEFT])
	self.stateTip_:pos(stateTipsMagrinLeft, self.stateFlag_:getPositionY())
		:addTo(self.background_)

	local gemIconPaddingTop = 80

	self.gemFrame_ = cc.ui.UIImage.new(--[["#chip_icon_icon.png"]])
	self.gemFrame_:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER])
	self.gemFrame_:pos(dokbActTermItemParam.WIDTH / 2, dokbActTermItemParam.HEIGHT - gemIconPaddingTop)
		:addTo(self.background_)

	self.gemFrameLoaderId_ = nk.ImageLoader:nextLoaderId()

	local NeedInfoMagrinLeftRight = 15
	local gemNameLblPaddingTop = 125

	self.gemName_ = display.newTTFLabel({text = "gem Name", size = infoLblParam.frontSizes.gemName, color = infoLblParam.colors.gemName,
		align = ui.TEXT_ALIGN_CENTER})
	self.gemName_:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER_LEFT])
	self.gemName_:pos(NeedInfoMagrinLeftRight, dokbActTermItemParam.HEIGHT - gemNameLblPaddingTop - self.gemName_:getContentSize().height / 2)
		:addTo(self.background_)

	local ltryNdInfoMagrinTop = 5

	local ltryNdInfoHead = display.newTTFLabel({text = bm.LangUtil.getText("DOKB", "LOTRY_MEET"), size = infoLblParam.frontSizes.ltryNdTerm, color = infoLblParam.colors.ltryNdTerm,
		align = ui.TEXT_ALIGN_CENTER})
	ltryNdInfoHead:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER_LEFT])
	ltryNdInfoHead:pos(NeedInfoMagrinLeftRight, self.gemName_:getPositionY() - self.gemName_:getContentSize().height / 2 - ltryNdInfoMagrinTop
		- ltryNdInfoHead:getContentSize().height / 2)
		:addTo(self.background_)

	local ltryNdPeopLblMagrinHoriz = 3
	self.lrtyNdPeop_ = display.newTTFLabel({text = "0", size = infoLblParam.frontSizes.ltryNdNumInfo, color = infoLblParam.colors.ltryNdTerm,
		align = ui.TEXT_ALIGN_CENTER})
	self.lrtyNdPeop_:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER_LEFT])
	self.lrtyNdPeop_:pos(ltryNdInfoHead:getPositionX() + ltryNdInfoHead:getContentSize().width + ltryNdPeopLblMagrinHoriz, ltryNdInfoHead:getPositionY())
		:addTo(self.background_)

	self.ltryPeopLbl_ = display.newTTFLabel({text = bm.LangUtil.getText("DOKB", "PEOP"), size = infoLblParam.frontSizes.ltryNdTerm, color = infoLblParam.colors.ltryNdTerm,
		align = ui.TEXT_ALIGN_CENTER})
	self.ltryPeopLbl_:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER_LEFT])
	self.ltryPeopLbl_:pos(self.lrtyNdPeop_:getPositionX() + self.lrtyNdPeop_:getContentSize().width + ltryNdPeopLblMagrinHoriz, ltryNdInfoHead:getPositionY())
		:addTo(self.background_)

	self.ltryPeopInfoRest_ = display.newTTFLabel({text = bm.LangUtil.getText("DOKB", "LOTRY_TERM_STATE", 0, 0), size = infoLblParam.frontSizes.ltryNdNumInfo, color = infoLblParam.colors.ltryNdTerm,
		align = ui.TEXT_ALIGN_CENTER})
	self.ltryPeopInfoRest_:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER_LEFT])
	self.ltryPeopInfoRest_:pos(self.ltryPeopLbl_:getPositionX() + self.ltryPeopLbl_:getContentSize().width, ltryNdInfoHead:getPositionY())
		:addTo(self.background_)

	local involInfoPrgParam = {
		width = 225,
		height = 16,
		fillWidthInit = 10,
		magrinInHeight = 2
	}

	local involInfoProgBarPaddingBot = 130

	self.involInfoProgress_ = nk.ui.ProgressBar.new("#common_progBgDent_gery.png", "#common_progBar_green.png", 
        {bgWidth = involInfoPrgParam.width, bgHeight = involInfoPrgParam.height, fillWidth = involInfoPrgParam.fillWidthInit,
        	fillHeight = involInfoPrgParam.height - involInfoPrgParam.magrinInHeight})
		:pos(dokbActTermItemParam.WIDTH / 2 - involInfoPrgParam.width / 2, involInfoProgBarPaddingBot + involInfoPrgParam.height / 2)
		:addTo(self.background_)
		:setValue(0)

	local peopInfoPaddingBot = 85
	local peopChgceInfoMagrinBot = 5

	local peopJoninedInfoLbl = display.newTTFLabel({text = bm.LangUtil.getText("DOKB", "PEOP_JONINED"), size = infoLblParam.frontSizes.involInfo, color = infoLblParam.colors.involInfo,
		align = ui.TEXT_ALIGN_CENTER})
	peopJoninedInfoLbl:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER_LEFT])
	peopJoninedInfoLbl:pos(NeedInfoMagrinLeftRight, peopJoninedInfoLbl:getContentSize().height / 2 + peopInfoPaddingBot)
		:addTo(self.background_)

	self.peopJonined_ = display.newTTFLabel({text = "0", size = infoLblParam.frontSizes.involInfo, color = infoLblParam.colors.involInfo,
		align = ui.TEXT_ALIGN_CENTER})
	self.peopJonined_:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER_LEFT])
	self.peopJonined_:pos(NeedInfoMagrinLeftRight, self.peopJonined_:getContentSize().height / 2 + peopInfoPaddingBot
		+ peopJoninedInfoLbl:getContentSize().height + peopChgceInfoMagrinBot)
		:addTo(self.background_)

	local peopChanceRestLbl = display.newTTFLabel({text = bm.LangUtil.getText("DOKB", "PEOP_REST"), size = infoLblParam.frontSizes.involInfo, color = infoLblParam.colors.involInfo,
		align = ui.TEXT_ALIGN_CENTER})
	peopChanceRestLbl:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER_RIGHT])
	peopChanceRestLbl:pos(dokbActTermItemParam.WIDTH - NeedInfoMagrinLeftRight, peopChanceRestLbl:getContentSize().height / 2 + peopInfoPaddingBot)
		:addTo(self.background_)

	self.peopChgceRest_ = display.newTTFLabel({text = "0", size = infoLblParam.frontSizes.involInfo, color = display.COLOR_RED,
		align = ui.TEXT_ALIGN_CENTER})
	self.peopChgceRest_:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER_RIGHT])
	self.peopChgceRest_:pos(peopChanceRestLbl:getPositionX(), peopInfoPaddingBot + peopChanceRestLbl:getContentSize().height + peopChgceInfoMagrinBot
		+ self.peopChgceRest_:getContentSize().height / 2)
		:addTo(self.background_)

	local attenfBtnSize = {
		width = 230,
		height = 48
	}

	local attendBtnPaddingBot = 32

	self.attendActBtn_ = cc.ui.UIPushButton.new({normal = "#dokb_btnItemPurple_nor.png", pressed = "#dokb_btnItemPurple_pre.png", disabled = "#dokb_btnItemPurple_dis.png"},
		{scale9 = true})
		:setButtonSize(attenfBtnSize.width, attenfBtnSize.height)
		:setButtonLabel(display.newTTFLabel({text = bm.LangUtil.getText("DOKB", "ATTENED_NOW"), size = infoLblParam.frontSizes.btnAttend, color = infoLblParam.colors.btnAttend, align = ui.TEXT_ALIGN_CENTER}))
		:onButtonClicked(handler(self, self.onAttendActBtnCallBack_))
		:pos(dokbActTermItemParam.WIDTH / 2, attenfBtnSize.height / 2 + attendBtnPaddingBot)
		:addTo(self.background_)

	self.attendActBtn_:setButtonEnabled(false)
	self.isAttendBtnEnable = true

	local currencyConverTipsMagrinBot = 10
	self.dokbPriceTips_ = display.newTTFLabel({text = "Tip Dokb Currency Bottom.", size = infoLblParam.frontSizes.tipBot, color = infoLblParam.colors.tipBot,
		align = ui.TEXT_ALIGN_CENTER})
	self.dokbPriceTips_:pos(dokbActTermItemParam.WIDTH / 2, self.dokbPriceTips_:getContentSize().height / 2 + currencyConverTipsMagrinBot)
		:addTo(self.background_)
end

function DokbActListTermItem:onAttendActBtnCallBack_(evt)
	-- body
	if self.isAttendBtnEnable then
		--todo
		self.isAttendBtnEnable = false
		AttendActPopup.new(self.itemData_):showPanel(function()
			-- body
			self.isAttendBtnEnable = true
		end, function()
			-- body
			self.peopJoinedTimes_ = self.peopJoinedTimes_ + 1

			if self.peopJoinedTimes_ >= self.lotryNdPeopTotalTimes_ then
				--todo
				-- self.itemStatus_ = 1
				-- self.stateFlag_:setSpriteFrame(display.newSpriteFrame(stateFlagPath[self.itemStatus_]))
				-- self.stateFlag_:setContentSize(dokbActTermItemParam.FLAG.WIDTH, dokbActTermItemParam.FLAG.HEIGHT)
				bm.EventCenter:dispatchEvent(nk.eventNames.DOKB_LOTRY_LOAD_NEXTROUND_RERESHDATA)
			else

				self.itemData_.nowcount = self.peopJoinedTimes_
				self.peopJonined_:setString(tostring(self.peopJoinedTimes_))
				self.peopChgceRest_:setString(tostring(self.lotryNdPeopTotalTimes_ - self.peopJoinedTimes_))

				self.involInfoProgress_:setValue(self.peopJoinedTimes_ / (self.itemData_.total or 1))
			end
		end)
	end
end

function DokbActListTermItem:refreshTermItemUiData(data)
	-- body
	self.itemData_ = data

	self.termItemId_ = data.id
	self.termId_ = data.termId_

	self.itemStatus_ = data.code or - 2

	-- just for Test --
	-- self.itemStatus_ = - 1
	-- data.stime = 10
	-- end --

	local stateFlagPath = {
		[- 2] = "dokb_actTermFlag_red.png",  -- 已结束
		[- 1] = "dokb_actTermFlag_purple.png",  -- 已颁奖，等待下一轮
		[1] = "dokb_actTermFlag_green.png"  -- 正在颁奖中
	}

	local stateTips = {
		[- 2] = bm.LangUtil.getText("DOKB", "GEMSTATE_FINISH"),
		[- 1] = bm.LangUtil.getText("DOKB", "GEMSTATE_WAIT", "00:00"),
		[1] = bm.LangUtil.getText("DOKB", "GEMSTATE_UNDERWAY")
	}

	nk.ImageLoader:loadAndCacheImage(self.gemFrameLoaderId_, data.propsurl or "", handler(self, self.onGemFrameImgLoadComplete_))

	self.stateFlag_:setSpriteFrame(display.newSpriteFrame(stateFlagPath[self.itemStatus_]))
	self.stateFlag_:setContentSize(dokbActTermItemParam.FLAG.WIDTH, dokbActTermItemParam.FLAG.HEIGHT)

	self.stateTip_:setString(stateTips[self.itemStatus_])

	if self.tickDownShortAction_ then
		--todo
		self:stopAction(self.tickDownShortAction_)
		self.tickDownShortAction_ = nil
	end

	if self.tickDownLongAction_ then
		--todo
		self:stopAction(self.tickDownLongAction_)
		self.tickDownLongAction_ = nil
	end

	if self.itemStatus_ == - 1 then
		--todo
		-- 已颁奖，等待下一轮 开始倒计时
		self.timeCountDown = data.stime or 0

		self:startTimeTickDown()
	end

	self.gemName_:setString(data.props or "Gem Name.")

	-- 记录当前已参加人次和需要开奖总人次 --
	self.peopJoinedTimes_ = tonumber(data.nowcount or 0)
	self.lotryNdPeopTotalTimes_ = tonumber(data.total or 0)

	local ltryNdPeopLblMagrinHoriz = 3
	if self.itemStatus_ == - 2 then
		--todo
		self.lrtyNdPeop_:setString("0")

		-- Label Pos Adj --
		self.ltryPeopLbl_:setPositionX(self.lrtyNdPeop_:getPositionX() + self.lrtyNdPeop_:getContentSize().width + ltryNdPeopLblMagrinHoriz)
		self.ltryPeopInfoRest_:setString(bm.LangUtil.getText("DOKB", "LOTRY_TERM_STATE", data.count or 0, data.daycount or 0))
		self.ltryPeopInfoRest_:setPositionX(self.ltryPeopLbl_:getPositionX() + self.ltryPeopLbl_:getContentSize().width)

		self.peopJonined_:setString("0")
		self.peopChgceRest_:setString("0")

		self.involInfoProgress_:setValue(0)
	else
		self.lrtyNdPeop_:setString(tostring(self.lotryNdPeopTotalTimes_))

		-- Label Pos Adj --
		self.ltryPeopLbl_:setPositionX(self.lrtyNdPeop_:getPositionX() + self.lrtyNdPeop_:getContentSize().width + ltryNdPeopLblMagrinHoriz)
		self.ltryPeopInfoRest_:setString(bm.LangUtil.getText("DOKB", "LOTRY_TERM_STATE", data.count or 0, data.daycount or 0))
		self.ltryPeopInfoRest_:setPositionX(self.ltryPeopLbl_:getPositionX() + self.ltryPeopLbl_:getContentSize().width)

		self.peopJonined_:setString(tostring(self.peopJoinedTimes_))
		self.peopChgceRest_:setString(tostring(self.lotryNdPeopTotalTimes_ - self.peopJoinedTimes_))

		self.involInfoProgress_:setValue(self.peopJoinedTimes_ / tonumber(data.total or 1))
	end

	if self.itemStatus_ == 1 then
		--todo
		self.attendActBtn_:setButtonEnabled(true)
	else
		self.attendActBtn_:setButtonEnabled(false)
	end

	if data.price then
		--todo
		-- local attendPrice = json.decode(data.price)
		self.dokbPriceTips_:setString(bm.LangUtil.getText("DOKB", "ATTENED_CURRENCY", bm.formatBigNumber(data.price.point or 0), bm.formatBigNumber(data.price.money or 0)))
	else
		self.dokbPriceTips_:setString(bm.LangUtil.getText("DOKB", "ATTENED_CURRENCY", 0, 0))
	end
	
end

function DokbActListTermItem:onGemFrameImgLoadComplete_(success, sprite)
	-- body
	if success then
		--todo
		local tex = sprite:getTexture()
		local texSize = tex:getContentSize()

		local gemFrameShownSize = {
			width = 128,
			height = 80
		}
		if self and self.gemFrame_ then
			--todo
			self.gemFrame_:setTexture(tex)
			self.gemFrame_:setTextureRect(cc.rect(0, 0, texSize.width, texSize.height))

			self.gemFrame_:setScaleX(gemFrameShownSize.width / texSize.width)
			self.gemFrame_:setScaleY(gemFrameShownSize.height / texSize.height)
		end
	end
end

function DokbActListTermItem:startTimeTickDown()
	-- body
	if self.timeCountDown < 3600 then
		--todo
		local time_str = bm.formatTimeStamp(1, self.timeCountDown)
		local minShown = nil
		local secShown = nil

		if time_str.min < 10 then
			--todo
			minShown = "0" .. time_str.min
		else
			minShown = tostring(time_str.min)
		end

		if time_str.sec < 10 then
			--todo
			secShown = "0" .. time_str.sec
		else
			secShown = tostring(time_str.sec)
		end
		-- "已颁奖, 00:00后开始下一轮"
		self.stateTip_:setString(bm.LangUtil.getText("DOKB", "GEMSTATE_WAIT", minShown .. ":" .. secShown))

		-- if self.timeCountDown <= 0 then
		-- 	--todo
		-- 	return
		-- end
		self.tickDownShortAction_ = self:schedule(function()
			-- body
			self.timeCountDown = self.timeCountDown - 1

			local time_str = bm.formatTimeStamp(1, self.timeCountDown)
			local minShown = nil
			local secShown = nil

			if time_str.min < 10 then
				--todo
				minShown = "0" .. time_str.min
			else
				minShown = tostring(time_str.min)
			end

			if time_str.sec < 10 then
				--todo
				secShown = "0" .. time_str.sec
			else
				secShown = tostring(time_str.sec)
			end

			self.stateTip_:setString(bm.LangUtil.getText("DOKB", "GEMSTATE_WAIT", minShown .. ":" .. secShown))

			if self.timeCountDown <= 0 then
				--todo
				self:stopAction(self.tickDownShortAction_)
				self.tickDownShortAction_ = nil

				-- self.stateFlag_:setSpriteFrame(display.newSpriteFrame("dokb_actTermFlag_green.png"))
				-- self.stateFlag_:setContentSize(dokbActTermItemParam.FLAG.WIDTH, dokbActTermItemParam.FLAG.HEIGHT)
				-- self.stateTip_:setString("夺宝进行中.....")

				-- self.itemStatus_ = 1
				-- self.attendActBtn_:setButtonEnabled(true)

				bm.EventCenter:dispatchEvent(nk.eventNames.DOKB_LOTRY_LOAD_NEXTROUND_RERESHDATA)
			end
		end, 1)
	else
		local timeTabel = bm.formatTimeStamp(2, self.timeCountDown)

		local remainTimeShownStr = nil
		local hourShown = nil
		local minShown = nil
		local secShown = nil

		if timeTabel.hour < 10 then
			--todo
			hourShown = "0" .. timeTabel.hour
		else
			hourShown = tostring(timeTabel.hour)
		end

		if timeTabel.min < 10 then
			--todo
			minShown = "0" .. timeTabel.min
		else
			minShown = tostring(timeTabel.min)
		end

		if timeTabel.sec < 10 then
			--todo
			secShown = "0" .. timeTabel.sec
		else
			secShown = tostring(timeTabel.sec)
		end

		self.stateTip_:setString(bm.LangUtil.getText("DOKB", "GEMSTATE_WAIT", hourShown .. ":" .. minShown .. ":" .. secShown))

		self.tickDownLongAction_ = self:schedule(function()
			-- body
			self.timeCountDown = self.timeCountDown - 1

			if self.timeCountDown < 3600 then
				--todo
				self:stopAction(self.tickDownLongAction_)
				self.tickDownLongAction_ = nil

				local time_str = bm.formatTimeStamp(1, self.timeCountDown)
				local minShown = nil
				local secShown = nil

				if time_str.min < 10 then
					--todo
					minShown = "0" .. time_str.min
				else
					minShown = tostring(time_str.min)
				end

				if time_str.sec < 10 then
					--todo
					secShown = "0" .. time_str.sec
				else
					secShown = tostring(time_str.sec)
				end

				self.stateTip_:setString(bm.LangUtil.getText("DOKB", "GEMSTATE_WAIT", minShown .. ":" .. secShown))

				self.tickDownShortAction_ = self:schedule(function()
					-- body
					self.timeCountDown = self.timeCountDown - 1

					local time_str = bm.formatTimeStamp(1, self.timeCountDown)
					local minShown = nil
					local secShown = nil

					if time_str.min < 10 then
						--todo
						minShown = "0" .. time_str.min
					else
						minShown = tostring(time_str.min)
					end

					if time_str.sec < 10 then
						--todo
						secShown = "0" .. time_str.sec
					else
						secShown = tostring(time_str.sec)
					end

					self.stateTip_:setString(bm.LangUtil.getText("DOKB", "GEMSTATE_WAIT", minShown .. ":" .. secShown))

					if self.timeCountDown <= 0 then
						--todo
						self:stopAction(self.tickDownShortAction_)
						self.tickDownShortAction_ = nil

						-- self.stateFlag_:setSpriteFrame(display.newSpriteFrame("dokb_actTermFlag_green.png"))
						-- self.stateFlag_:setContentSize(dokbActTermItemParam.FLAG.WIDTH, dokbActTermItemParam.FLAG.HEIGHT)
						-- self.stateTip_:setString("夺宝进行中.....")
						
						-- self.itemStatus_ = 1
						-- self.attendActBtn_:setButtonEnabled(true)
						bm.EventCenter:dispatchEvent(nk.eventNames.DOKB_LOTRY_LOAD_NEXTROUND_RERESHDATA)
					end
				end, 1)
			else

				local timeTabel = bm.formatTimeStamp(2, self.timeCountDown)

				local remainTimeShownStr = nil
				local hourShown = nil
				local minShown = nil
				local secShown = nil

				if timeTabel.hour < 10 then
					--todo
					hourShown = "0" .. timeTabel.hour
				else
					hourShown = tostring(timeTabel.hour)
				end

				if timeTabel.min < 10 then
					--todo
					minShown = "0" .. timeTabel.min
				else
					minShown = tostring(timeTabel.min)
				end

				if timeTabel.sec < 10 then
					--todo
					secShown = "0" .. timeTabel.sec
				else
					secShown = tostring(timeTabel.sec)
				end

				self.stateTip_:setString(bm.LangUtil.getText("DOKB", "GEMSTATE_WAIT", hourShown .. ":" .. minShown .. ":" .. secShown))
			end
		end, 1)
	end
end

function DokbActListTermItem:onEnter()
	-- body
end

function DokbActListTermItem:onExit()
	-- body
	nk.ImageLoader:cancelJobByLoaderId(self.gemFrameLoaderId_)
	
	if self.tickDownShortAction_ then
		--todo
		self:stopAction(self.tickDownShortAction_)
		self.tickDownShortAction_ = nil
	end

	if self.tickDownLongAction_ then
		--todo
		self:stopAction(self.tickDownLongAction_)
		self.tickDownShortAction_ = nil
	end
end

function DokbActListTermItem:onCleanup()
	-- body
end

return DokbActListTermItem