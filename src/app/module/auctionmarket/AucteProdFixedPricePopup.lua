--
-- Author: TsingZhang@boyaa.com
-- Date: 2016-01-18 09:49:57
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- Description: AucteProdFixedPricePopup.lua By tsing.
--

local AucteProdFixedPricePopup = class("AucteProdFixedPricePopup", function()
	-- body
	return display.newNode()
end)

-- @param args #table args.contName :物品详情描述, args.timeRemain :剩余竞拍时间(秒为单位的时间戳), args.price :一口价竞拍价格
function AucteProdFixedPricePopup:ctor(args, controller)
	-- body
	self.background_ = display.newSprite("#aucMar_bgAcutProdMain.png")
		:addTo(self)

	self.background_:setTouchEnabled(true)
	self:setNodeEventEnabled(true)

	self.controller_ = controller
	self:drawTitleBlock()
	self:drawMainBlock(args)
end

function AucteProdFixedPricePopup:drawTitleBlock()
	-- body

	local bgPanelSize = self.background_:getContentSize()

	local titleLabelParam = {
		frontSize = 30,
		color = cc.c3b(202, 208, 230)
	}

	local labelTitleMagrinTop = 10
	local labelTitle = display.newTTFLabel({text = bm.LangUtil.getText("AUCTION_MARKET", "FIXED_PRICE_AUCTION"), size = titleLabelParam.frontSize, color = titleLabelParam.color, align = ui.TEXT_ALIGN_CENTER})
	labelTitle:pos(bgPanelSize.width / 2, bgPanelSize.height - labelTitle:getContentSize().height / 2 - labelTitleMagrinTop)
		:addTo(self.background_)

	local closeBtnPosAdjust = {
		x = 8,
		y = 8
	}

	local closeBtnSize = {
		width = 42,
		height = 42
	}

	local closeBtn = cc.ui.UIPushButton.new({normal = "#panel_close_btn_up.png", pressed = "#panel_close_btn_down.png"}, {scale9 = false})
		:onButtonClicked(buttontHandler(self, self.onCloseBtnCallBack_))
		:pos(bgPanelSize.width - closeBtnSize.width / 2 - closeBtnPosAdjust.x, bgPanelSize.height - closeBtnSize.height / 2 - closeBtnPosAdjust.y)
		:addTo(self.background_)
end

function AucteProdFixedPricePopup:drawMainBlock(UIParam)
	-- body
	local imgLoaderUrl = nil
	local prodContDesc = nil
	local remainTimeSec = nil
	local price = nil
	local aucttioneer = nil

	if UIParam then
		--todo
		self.itemId_ = UIParam.itemId or ""
		imgLoaderUrl = UIParam.imgUrl or ""

		prodContDesc = UIParam.contName or "prodContDesc"
		remainTimeSec = UIParam.timeRemain or 0
		price = UIParam.price or 0

		aucttioneer = UIParam.nickName or "name"
	else
		self.itemId_ = ""
		imgLoaderUrl = ""

		prodContDesc = "prodContDesc"
		remainTimeSec = 0
		price = 0

		aucttioneer = "name"
	end

	self.auctPrice_ = price

	local bgPanelSize = self.background_:getContentSize()

	-- ProdInfo Area --
	-- Aucttioneer Label
	local nickNamePaddingTop = 60

	local nickNameLabelParam = {
		frontSize = 24,
		color = cc.c3b(190, 194, 199)
	}

	local nickNameShownSize = {
		width = 465,
		height = 30
	}

	local nickNameLabel = display.newTTFLabel({text = bm.LangUtil.getText("AUCTION_MARKET", "AUCTIONEER") .. ": " .. aucttioneer, size = nickNameLabelParam.frontSize,
		color = nickNameLabelParam.color, dimensions = cc.size(nickNameShownSize.width, nickNameShownSize.height), align = ui.TEXT_ALIGN_CENTER})
	nickNameLabel:pos(bgPanelSize.width / 2, bgPanelSize.height - nickNamePaddingTop - nickNameLabel:getContentSize().height / 2)
		:addTo(self.background_)

	local prodInfoBlockSize = {
		width = 345,
		height = 100
	}
	local prodInfoBgPaddingTop = 100

	local prodInfoBg = display.newScale9Sprite("#aucMar_bgProdInfo.png", bgPanelSize.width / 2,
		bgPanelSize.height - prodInfoBgPaddingTop - prodInfoBlockSize.height / 2, cc.size(prodInfoBlockSize.width, prodInfoBlockSize.height))
		:addTo(self.background_)

	local prodLightBgMagrinLeft = 50
	local prodLightBg = display.newSprite("#aucMar_bgLightProd.png")
	prodLightBg:pos(prodLightBg:getContentSize().width / 2 + prodLightBgMagrinLeft, prodInfoBg:getContentSize().height / 2)
		:addTo(prodInfoBg)

	self.prodIcon_ = display.newSprite("#aucMar_icProd.png")
		:pos(prodLightBg:getPositionX(), prodLightBg:getPositionY())
		:addTo(prodInfoBg)

	self.prodIconLoaderId_ = nk.ImageLoader:nextLoaderId()

	nk.ImageLoader:loadAndCacheImage(self.prodIconLoaderId_, imgLoaderUrl, handler(self, self.onIconLoadComplete_))

	local mainBlockInfoLabelParam = {
		prodDesc = {
			frontSize = 22,
			color = display.COLOR_WHITE
		},

		remTime = {
			frontSize = 25,
			color = display.COLOR_GREEN
		},

		priceDesc = {
			frontSize = 32,
			color = styles.FONT_COLOR.GOLDEN_TEXT
		},

		auctPrice = {
			frontSize = 35,
			color = styles.FONT_COLOR.GOLDEN_TEXT
		},

		surBtn = {
			frontSize = 32,
			color = display.COLOR_WHITE
		},

		descBot = {
			frontSize = 20,
			color = cc.c3b(216, 184, 107)
		}
	}

	local prodInfoDescPosYShift = - 5

	local prodDescShownSize = {
		width = 160,
		height = 60
	}

	-- local prodDescShownWidth = 180
	self.prodContDesc_ = display.newTTFLabel({text = prodContDesc, size = mainBlockInfoLabelParam.prodDesc.frontSize,
		color = mainBlockInfoLabelParam.prodDesc.color, dimensions = cc.size(prodDescShownSize.width, prodDescShownSize.height), align = ui.TEXT_ALIGN_LEFT})
	self.prodContDesc_:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER_LEFT])
	self.prodContDesc_:pos(prodInfoBlockSize.width / 2, prodInfoBlockSize.height / 2 + prodInfoDescPosYShift + self.prodContDesc_:getContentSize().height / 2)
		:addTo(prodInfoBg)

	local remTimePosYShift = 15
	self.remainTime_ = display.newTTFLabel({text = "00:00", size = mainBlockInfoLabelParam.remTime.frontSize,
		color = mainBlockInfoLabelParam.remTime.color, align = ui.TEXT_ALIGN_CENTER})
	self.remainTime_:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER_LEFT])
	self.remainTime_:pos(prodInfoBlockSize.width / 2, prodInfoBlockSize.height / 2 - prodInfoDescPosYShift - remTimePosYShift - self.remainTime_:getContentSize().height / 2)
		:addTo(prodInfoBg)

	self.remainTime = remainTimeSec -- 该值不允许在中途更改，会引起计算错误导致UI显示问题
	self:timeTickDown()

	local priceDescLabelMagrinLeft = 82
	local priceDescLabelMagrinTop = 15
	local priceDesc = display.newTTFLabel({text = bm.LangUtil.getText("AUCTION_MARKET", "FIXED_PRICE"), size = mainBlockInfoLabelParam.priceDesc.frontSize,
		color = mainBlockInfoLabelParam.priceDesc.color, align = ui.TEXT_ALIGN_CENTER})
	priceDesc:pos(priceDescLabelMagrinLeft + priceDesc:getContentSize().width / 2, bgPanelSize.height / 2 - priceDescLabelMagrinTop)
		:addTo(self.background_)

	local auctPriceBgMagrinLeft = 15
	local auctPriceBg = display.newSprite("#aucMar_bgPriEditBor.png")
	local auctPriceBgSize = auctPriceBg:getContentSize()

	auctPriceBg:pos(priceDesc:getPositionX() + priceDesc:getContentSize().width / 2 + auctPriceBgSize.width / 2 + auctPriceBgMagrinLeft,
		bgPanelSize.height / 2 - priceDescLabelMagrinTop)
		:addTo(self.background_)

	self.fixedPrice_ = display.newTTFLabel({text = bm.formatNumberWithSplit(price), size = mainBlockInfoLabelParam.auctPrice.frontSize,
		color = mainBlockInfoLabelParam.auctPrice.color, align = ui.TEXT_ALIGN_CENTER})
		:pos(auctPriceBgSize.width / 2, auctPriceBgSize.height / 2)
		:addTo(auctPriceBg)

	local ensBtnSize = {
		width = 188,
		height = 58
	}

	local ensureBtnMagrinTop = 40
	self.ensureBtn_ = cc.ui.UIPushButton.new({normal = "#common_green_btn_up.png", pressed = "#common_green_btn_down.png",
		disabled = "#common_btn_disabled.png"}, {scale9 = true})
		:setButtonSize(ensBtnSize.width, ensBtnSize.height)
		:setButtonLabel("normal", display.newTTFLabel({text = bm.LangUtil.getText("AUCTION_MARKET", "SURE_AUCTION_1"), size = mainBlockInfoLabelParam.surBtn.frontSize,
			color = mainBlockInfoLabelParam.surBtn.color, align = ui.TEXT_ALIGN_CENTER}))
		:onButtonClicked(buttontHandler(self, self.onSurBtnCallBack_))
		:pos(bgPanelSize.width / 2, bgPanelSize.height / 2 - auctPriceBgSize.height / 2 - ensureBtnMagrinTop - ensBtnSize.height / 2)
		:addTo(self.background_)

	local tipsShownWidth = 420
	local tipsBottomMagrinBottom = 15
	local tipsBottom = display.newTTFLabel({text = bm.LangUtil.getText("AUCTION_MARKET", "SURE_AUCTION_BOTTOM_TIP"), size = mainBlockInfoLabelParam.descBot.frontSize,
		dimensions = cc.size(tipsShownWidth, 0), color = mainBlockInfoLabelParam.descBot.color, align = ui.TEXT_ALIGN_CENTER})
	tipsBottom:pos(bgPanelSize.width / 2, tipsBottomMagrinBottom + tipsBottom:getContentSize().height / 2)
		:addTo(self.background_)
end

function AucteProdFixedPricePopup:timeTickDown()
	-- body

	if self.remainTime < 3600 then
		--todo
		local str_time = os.date("%M:%S", self.remainTime)

		self.remainTime_:setString(str_time)

		self.countDownShortAction_ = self:schedule(function()
			-- body
			self.remainTime = self.remainTime - 1

			if self.remainTime <= 0 then
				--todo
				self:stopAction(self.countDownShortAction_)
				self.countDownShortAction_ = nil
			else
				local str_time = os.date("%M:%S", self.remainTime)
				self.remainTime_:setString(str_time)
			end

		end, 1)
	else
		local timeTabel = bm.formatTimeStamp(2, self.remainTime)

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

		self.remainTime_:setString(hourShown .. ":" .. minShown .. ":" .. secShown)

		-- dump(str_time, "str_time :=========")
		self.countDownLongAction_ = self:schedule(function()
			-- body
			self.remainTime = self.remainTime - 1

			if self.remainTime < 3600 then
				--todo
				self:stopAction(self.countDownLongAction_)
				self.countDownLongAction_ = nil

				local time_str = bm.formatTimeStamp(1, self.remainTime)
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

				self.remainTime_:setString(minShown .. ":" .. secShown)
				-- local str_time = os.date("%M:%S", self.remainTime)
				-- self.remainTime_:setString(str_time)

				self.countDownShortAction_ = self:schedule(function()
					-- body
					self.remainTime = self.remainTime - 1

					-- Plan 1:
					-- if self.remainTime <= 0 then
					-- 	--todo
					-- 	self:stopAction(self.countDownShortAction_)
					-- 	self.countDownShortAction_ = nil
					-- else
					-- 	local str_time = os.date("%M:%S", self.remainTime)

					-- 	self.remainTime_:setString(str_time)
					-- end

					local time_str = bm.formatTimeStamp(1, self.remainTime)
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

					self.remainTime_:setString(minShown .. ":" .. secShown)

					if self.remainTime <= 0 then
						--todo
						self:stopAction(self.countDownShortAction_)
						self.countDownShortAction_ = nil
					end
				end, 1)
			else

				local timeTabel = bm.formatTimeStamp(2, self.remainTime)

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

				self.remainTime_:setString(hourShown .. ":" .. minShown .. ":" .. secShown)
			end
			
		end, 1)
	end

end

function AucteProdFixedPricePopup:onSurBtnCallBack_()
	-- body
	self.ensureBtn_:setButtonEnabled(false)
	
	if nk.userData["aUser.money"] < self.auctPrice_ then
		--todo
		nk.CenterTipManager:showCenterTip({text = bm.LangUtil.getText("AUCTION_MARKET", "NOT_ENOUGH_MONEY_FOR_FIXED_PRICE")})

		if self and self.hidePanel then
			--todo
			self:hidePanel()
		end
	else
		local auctParam = {}
		auctParam.itemId = self.itemId_
		auctParam.auctType = 2
		auctParam.auctPrice = self.auctPrice_

		self.controller_:auctProdByAttr(auctParam, function(data)
			-- body
			nk.CenterTipManager:showCenterTip({text = bm.LangUtil.getText("AUCTION_MARKET", "AUCTION_SUCC_FOR_WAIT"), messageType = 1000})

			-- if data and data.money then
				--todo
				-- nk.userData["aUser.money"] = data.money
			-- end
			
			if self and self.hidePanel then
				--todo
				self:hidePanel()
			end

		end, function(errData)
			-- body

			if errData.errorCode == - 6 then
				--todo

				nk.CenterTipManager:showCenterTip({text = bm.LangUtil.getText("AUCTION_MARKET", "AUCTION_FAIL_FOR_EXPIRE"), messageType = 1000})
			elseif errData.errorCode == - 8 then
				--todo

				nk.CenterTipManager:showCenterTip({text = bm.LangUtil.getText("AUCTION_MARKET", "AUCTION_FAIL_FOR_GONE"), messageType = 1000})
			else
				nk.CenterTipManager:showCenterTip({text = bm.LangUtil.getText("AUCTION_MARKET", "AUCTION_FAIL_FOR_RETRY"), messageType = 1000})
			end

			if self and self.hidePanel then
				--todo
				self:hidePanel()
			end
		end)
	end
end

function AucteProdFixedPricePopup:onCloseBtnCallBack_()
	-- body
	self:hidePanel()
end

function AucteProdFixedPricePopup:onIconLoadComplete_(success, sprite)
	-- body
	if success then

        local tex = sprite:getTexture()
        local texSize = tex:getContentSize()

        self.prodIcon_:setTexture(tex)
        self.prodIcon_:setTextureRect(cc.rect(0, 0, texSize.width, texSize.height))

        local prodIconShownSize = {
        	width = 68,
        	height = 68
    	}

        self.prodIcon_:setScaleX(prodIconShownSize.width / texSize.width)
        self.prodIcon_:setScaleY(prodIconShownSize.height / texSize.height)
    end

end

function AucteProdFixedPricePopup:showPanel()
	-- body
	nk.PopupManager:addPopup(self)
end

function AucteProdFixedPricePopup:onShowed()
	-- body
end

function AucteProdFixedPricePopup:hidePanel()
	-- body
	nk.PopupManager:removePopup(self)
end

function AucteProdFixedPricePopup:onEnter()
	-- body
end

function AucteProdFixedPricePopup:onExit()
	-- body

	if self.countDownShortAction_ then
		--todo
		self:stopAction(self.countDownShortAction_)
	end

	if self.countDownLongAction_ then
		--todo
		self:stopAction(self.countDownLongAction_)
	end
end

function AucteProdFixedPricePopup:onCleanup()
	-- body
	nk.ImageLoader:cancelJobByLoaderId(self.prodIconLoaderId_)
end

return AucteProdFixedPricePopup