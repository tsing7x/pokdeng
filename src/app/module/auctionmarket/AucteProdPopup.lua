--
-- Author: TsingZhang@boyaa.com
-- Date: 2016-01-14 16:24:49
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- Description: AucteProdPopup.lua by tsing.
--
local AuctionMarketPopupController = import(".AuctionMarketPopupController")
local AucteProdPopup = class("AucteProdPopup", function()
	-- body
	return display.newNode()
end)

-- local AuctePanelParam = {
-- 	WIDTH = 642,
-- 	HEIGHT = 450
-- }

-- 需要外部传参时作判断，如果用户 nk.userData["aUser.money"] < 当前竞价,则提示筹码不足.

-- @param args:必要UI参数 #table args.contName :物品详情描述, args.timeRemain :剩余竞拍时间(秒为单位的时间戳), args.minPrice :起拍价格,
-- args.slidRate :竞拍价格默认比率
function AucteProdPopup:ctor(args, controller)
	-- body
	-- self.super.ctor(self, {AuctePanelParam.WIDTH, AuctePanelParam.HEIGHT})
	self.background_ = display.newSprite("#aucMar_bgAcutProdMain.png")
		:addTo(self)
	self.background_:setTouchEnabled(true)
	-- self.background_:setTouchSwallowEnabled(true)
	self:setNodeEventEnabled(true)

	self.controller_ = controller
	self:renderTitleBlock()
	self:renderMainBlock(args)
end

function AucteProdPopup:renderTitleBlock()
	-- body
	-- local blockSizeWidthFix = 2
	-- local blockDentPanelSize = {
	-- 	width = AuctePanelParam.WIDTH - blockSizeWidthFix * 2,
	-- 	height = 55
	-- }

	-- local titleDentBlock = display.newScale9Sprite("#aucMar_helpTitleBlock.png", 0,
	-- 	AuctePanelParam.HEIGHT / 2 - blockDentPanelSize.height / 2, cc.size(blockDentPanelSize.width, blockDentPanelSize.height))
	-- 	:addTo(self)

	local bgPanelSize = self.background_:getContentSize()

	local titleLabelParam = {
		frontSize = 30,
		color = cc.c3b(111, 129, 175)
	}

	local labelTitleMagrinTop = 10
	local labelTitle = display.newTTFLabel({text = bm.LangUtil.getText("AUCTION_MARKET", "NORMAL_AUCTION"), size = titleLabelParam.frontSize, color = titleLabelParam.color, align = ui.TEXT_ALIGN_CENTER})
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

	-- self.controller_:getCanAuctionData(function()
	-- 	-- body
	-- end, function()
	-- 	-- body
	-- end)
end

function AucteProdPopup:renderMainBlock(params)
	-- body
	-- self.itemId_ = params.itemId or ""
	local imgLoaderUrl = nil
	local prodContDesc = nil
	local timeRemainSec = nil
	local minAuctPrice = nil
	local silderRate = nil
	-- local isFirst = nil
	local aucttioneer = nil

	if params then
		--todo
		self.itemId_ = params.itemId or ""
		imgLoaderUrl = params.imgUrl or ""

		prodContDesc = params.contName or "prodDesc"
		timeRemainSec = params.timeRemain or 0
		minAuctPrice = params.minPrice or 0
		silderRate = params.slidRate or 0

		self.isFirstAuct_ = params.isFirstAuct
		aucttioneer = params.nickName or "name"
	else
		self.itemId_ = ""
		imgLoaderUrl = ""

		prodContDesc = "prodDesc"
		timeRemainSec = 0
		minAuctPrice = 0
		silderRate = 0

		self.isFirstAuct_ = false
		aucttioneer = "name"
	end

	local bgPanelSize = self.background_:getContentSize()
	-- ProdInfo Block --

	-- Auctioneer Label
	local nickNameLabelParam = {
		frontSize = 24,
		color = cc.c3b(190, 194, 199)
	}
	local nickNameMagrinTop = 60

	local nickNameShownSize = {
		width = 465,
		height = 30
	}
	local nickNameLabel = display.newTTFLabel({text = bm.LangUtil.getText("AUCTION_MARKET", "AUCTIONEER") .. ": " .. aucttioneer, size = nickNameLabelParam.frontSize,
		color = nickNameLabelParam.color, dimensions = cc.size(nickNameShownSize.width, nickNameShownSize.height),align = ui.TEXT_ALIGN_CENTER})
	nickNameLabel:pos(bgPanelSize.width / 2, bgPanelSize.height - nickNameMagrinTop - nickNameLabel:getContentSize().height / 2)
		:addTo(self.background_)

	local prodInfoBgPaddingTop = 90

	local prodInfoBgSize = {
		width = 360,
		height = 90
	}

	-- InfoMain
	local prodInfoBg = display.newScale9Sprite("#aucMar_bgProdInfo.png", bgPanelSize.width / 2,
		bgPanelSize.height - prodInfoBgPaddingTop - prodInfoBgSize.height / 2, cc.size(prodInfoBgSize.width, prodInfoBgSize.height))
		:addTo(self.background_)

	local prodIconBgMagrinLeft = 50
	local prodIconBg = display.newSprite("#aucMar_bgLightProd.png")
	prodIconBg:pos(prodIconBg:getContentSize().width / 2 + prodIconBgMagrinLeft, prodInfoBgSize.height / 2)
		:addTo(prodInfoBg)

	self.prodIcon_ = display.newSprite("#aucMar_icProd.png")
		:pos(prodIconBg:getPositionX(), prodIconBg:getPositionY())
		:addTo(prodInfoBg)

	-- dump(params, "params:============")

	self.prodIconLoaderId_ = nk.ImageLoader:nextLoaderId()

	nk.ImageLoader:loadAndCacheImage(self.prodIconLoaderId_, imgLoaderUrl, handler(self, self.onIconLoadComplete_))

	-- LabelParam --
	local infoLabelParam = {
		prodDesc = {
			frontSize = 20,
			color = display.COLOR_WHITE
		},

		remTime = {
			frontSize = 25,
			color = display.COLOR_GREEN
		},

		limPrice = {
			frontSize = 20,
			color = cc.c3b(144, 167, 201)
		},

		limDesc = {
			frontSize = 24,
			color = cc.c3b(144, 167, 201)
		},

		auctPrice = {
			frontSize = 35,
			color = styles.FONT_COLOR.GOLDEN_TEXT,
		},

		conBtn = {
			frontSize = 32,
			color = display.COLOR_WHITE
		},

		descBottom = {
			frontSize = 16,
			color = cc.c3b(216, 184, 107)
		}
	}

	local prodInfoLabelPosYShift = - 5

	local prodDescShownSize = {
		width = 165,
		height = 60
	}
	-- local prodDescShownWidth = 180
	self.prodDesc_ = display.newTTFLabel({text = prodContDesc, size = infoLabelParam.prodDesc.frontSize,
		color = infoLabelParam.prodDesc.color, dimensions = cc.size(prodDescShownSize.width, prodDescShownSize.height),align = ui.TEXT_ALIGN_LEFT})
	self.prodDesc_:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER_LEFT])
	self.prodDesc_:pos(prodInfoBgSize.width / 2, prodInfoBgSize.height / 2 + prodInfoLabelPosYShift + self.prodDesc_:getContentSize().height / 2)
		:addTo(prodInfoBg)

	local remTimePosYShift = 10
	self.remTime_ = display.newTTFLabel({text = "00:00", size = infoLabelParam.remTime.frontSize,
		color = infoLabelParam.remTime.color, align = ui.TEXT_ALIGN_CENTER})
	self.remTime_:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER_LEFT])
	self.remTime_:pos(prodInfoBgSize.width / 2, prodInfoBgSize.height / 2 - prodInfoLabelPosYShift - remTimePosYShift - self.remTime_:getContentSize().height / 2)
		:addTo(prodInfoBg)

	self.remainTime = timeRemainSec -- 该值不允许在中途更改，会引起计算错误导致UI显示问题
	self:timeTickDown()

	-- MainFuncCtr Area --
	-- self.priceEditBox_ = cc.ui.UIInput.new({image = "#aucMar_bgPriEdit.png", listener = handler(), size = cc.size()})
	local priceShownBgPosYAdjust = 10
	local priceShownBg = display.newSprite("#aucMar_bgPriEditBor.png")
		:pos(bgPanelSize.width / 2, bgPanelSize.height / 2 + priceShownBgPosYAdjust)
		:addTo(self.background_)

	self.auctPriceNum = nil

	self.minAuctPirce = nil

	if self.isFirstAuct_ then
		--todo
		self.minAuctPirce = minAuctPrice
		self.auctPriceNum = minAuctPrice
	else
		if math.ceil(minAuctPrice / 10000) * 10000 > nk.userData["aUser.money"] and nk.userData["aUser.money"] >= minAuctPrice then
			--todo
			self.auctPriceNum = nk.userData["aUser.money"]
			self.minAuctPirce = nk.userData["aUser.money"]
		else
			local auctPriceFact = math.ceil(minAuctPrice / 10000) * 10000 +
				(nk.userData["aUser.money"] - math.ceil(minAuctPrice / 10000) * 10000) * silderRate

			if auctPriceFact > math.floor(nk.userData["aUser.money"] / 10000) * 10000 then
				--todo
				self.auctPriceNum = nk.userData["aUser.money"]
			else
				self.auctPriceNum = math.ceil(auctPriceFact / 10000) * 10000
			end
			-- self.auctPriceNum = math.ceil(minAuctPrice / 10000) * 10000 +
			-- 	(math.floor(nk.userData["aUser.money"] / 10000) * 10000 - math.ceil(minAuctPrice / 10000) * 10000) * silderRate

			self.minAuctPirce = math.ceil(minAuctPrice / 10000) * 10000
		end
	end
	

	local auctpriceStr = bm.formatNumberWithSplit(self.auctPriceNum)
	local minAuctPriceStr = bm.formatNumberWithSplit(self.minAuctPirce)
	local maxAuctprice = bm.formatNumberWithSplit(nk.userData["aUser.money"])
	-- 作长度限制判断 如果超出了UI边界,则科学计数法bm.formatBigNumber(num)记录显示字符,暂时先做这种处理!

	self.auctPrice_ = display.newTTFLabel({text = auctpriceStr, size = infoLabelParam.auctPrice.frontSize,
		color = infoLabelParam.auctPrice.color, align = ui.TEXT_ALIGN_CENTER})
		:pos(priceShownBg:getContentSize().width / 2, priceShownBg:getContentSize().height / 2)
		:addTo(priceShownBg)

	-- Price Controller Bar --
	local priceLimitMagrinLeftRight = 45

	local priceBgSize = {
		width = 80,
		height = 80
	}
	local priceMinLimitBg = cc.ui.UIPushButton.new("#aucMar_bgPriCtr.png", {scale9 = false})
		:onButtonClicked(buttontHandler(self, self.onMinAuctPriceBtnCallBack_))
		:onButtonPressed(handler(self, self.onMinAuctPriceContiCallBack_))
		:onButtonRelease(handler(self, self.onMinAuctPriceRelCallBack_))
		:pos(priceBgSize.width / 2 + priceLimitMagrinLeftRight,
			priceShownBg:getPositionY() - priceShownBg:getContentSize().height / 2 - priceBgSize.height / 2)
		:addTo(self.background_)

	-- priceMinLimitBg:pos(priceMinLimitBg:getContentSize().width / 2 + priceLimitMagrinLeftRight,
	-- 	priceShownBg:getPositionY() - priceShownBg:getContentSize().height / 2 - priceMinLimitBg:getContentSize().height / 2)
	-- 	:addTo(self.background_)

	-- local minAuctPriceBtn = cc.ui.UIPushButton.new("#aucMar_icPriMinus.png", {scale9 = false})
	-- 	:onButtonClicked(buttontHandler(self, self.onMinAuctPriceBtnCallBack_))
	-- 	:pos(priceMinLimitBg:getContentSize().width / 2, priceMinLimitBg:getContentSize().height / 2)
	-- 	:addTo(priceMinLimitBg)

	local minAuctPriceIcon = display.newSprite("#aucMar_icPriMinus.png")
		:addTo(priceMinLimitBg)

	-- bm.TouchHelper.new(priceMinLimitBg, handler(self, self.on))

	local priceMaxLimitBg = cc.ui.UIPushButton.new("#aucMar_bgPriCtr.png", {scale9 = false})
		:onButtonClicked(buttontHandler(self, self.onPluAuctPriceBtnCallBack_))
		:onButtonPressed(handler(self, self.onPluAuctPriceContiCallBack_))
		:onButtonRelease(handler(self, self.onPluAuctPriceRelCallBack_))
		:pos(bgPanelSize.width - priceLimitMagrinLeftRight - priceBgSize.width / 2,
		priceShownBg:getPositionY() - priceShownBg:getContentSize().height / 2 - priceBgSize.height / 2)
		:addTo(self.background_)

	-- display.newSprite("#aucMar_bgPriCtr.png")
	-- priceMaxLimitBg:pos(bgPanelSize.width - priceLimitMagrinLeftRight - priceMaxLimitBg:getContentSize().width / 2,
	-- 	priceShownBg:getPositionY() - priceShownBg:getContentSize().height / 2 - priceMaxLimitBg:getContentSize().height / 2)
	-- 	:addTo(self.background_)

	-- local maxAuctPriceBtn = cc.ui.UIPushButton.new("#aucMar_icPriPlus.png", {scale9 = false})
	-- 	:onButtonClicked(buttontHandler(self, self.onPluAuctPriceBtnCallBack_))
	-- 	:pos(priceMaxLimitBg:getContentSize().width / 2, priceMaxLimitBg:getContentSize().height / 2)
	-- 	:addTo(priceMaxLimitBg)
	local maxAuctPriceIcon = display.newSprite("#aucMar_icPriPlus.png")
		:addTo(priceMaxLimitBg)

	-- Silder Controll --
	self.auctPriceSilder_ = cc.ui.UISlider.new(display.LEFT_TO_RIGHT, {bar = "#aucMar_bgSlid.png",
		button = "#aucMar_btnSlidBar.png"}, {scale9 = false})
        :onSliderValueChanged(handler(self, self.onAuctPriceSlideCallBack_))
        :onSliderRelease(handler(self, self.onAuctPriceSlldFixCallBack_))
        -- :setSliderSize(barWidth, barHeight)
        :setSliderValue(silderRate * 100)
        :align(display.CENTER, bgPanelSize.width / 2, priceMinLimitBg:getPositionY())
        :addTo(self.background_)
    self.slidValFix_ = silderRate * 100

	-- Min Auctprice --
	self.minAuctPrice_ = display.newTTFLabel({text = minAuctPriceStr, size = infoLabelParam.limPrice.frontSize,
		color = infoLabelParam.limPrice.color, align = ui.TEXT_ALIGN_CENTER})
	self.minAuctPrice_:pos(priceMinLimitBg:getPositionX(), priceShownBg:getPositionY() + self.minAuctPrice_:getContentSize().height / 2)
		:addTo(self.background_)

	local labelMin = display.newTTFLabel({text = "Min", size = infoLabelParam.limDesc.frontSize,
		color = infoLabelParam.limDesc.color, align = ui.TEXT_ALIGN_CENTER})
	labelMin:pos(priceMinLimitBg:getPositionX(), priceShownBg:getPositionY() - labelMin:getContentSize().height / 2)
		:addTo(self.background_)
	
	-- Max AuctPrice --
	self.maxAuctPrice_ = display.newTTFLabel({text = maxAuctprice, size = infoLabelParam.limPrice.frontSize,
		color = infoLabelParam.limPrice.color, align = ui.TEXT_ALIGN_CENTER})
	self.maxAuctPrice_:pos(priceMaxLimitBg:getPositionX(), priceShownBg:getPositionY() + self.maxAuctPrice_:getContentSize().height / 2)
		:addTo(self.background_)

	local labelMax = display.newTTFLabel({text = "Max", size = infoLabelParam.limDesc.frontSize,
		color = infoLabelParam.limDesc.color, align = ui.TEXT_ALIGN_CENTER})
	labelMax:pos(priceMaxLimitBg:getPositionX(), priceShownBg:getPositionY() - labelMax:getContentSize().height / 2)
		:addTo(self.background_)

	local confirmBtnSize = {
		width = 188,
		height = 60
	}

	local confirmBtnMagrinTop = 10
	self.confirmBtn_ = cc.ui.UIPushButton.new({normal = "#common_green_btn_up.png", pressed = "#common_green_btn_down.png",
		disabled = "#common_btn_disabled.png"}, {scale9 = true})
		:setButtonSize(confirmBtnSize.width, confirmBtnSize.height)
		:setButtonLabel("normal", display.newTTFLabel({text = bm.LangUtil.getText("AUCTION_MARKET", "SURE_AUCTION_1"), size = infoLabelParam.conBtn.frontSize,
			color = infoLabelParam.conBtn.color, align = ui.TEXT_ALIGN_CENTER}))
		:onButtonClicked(buttontHandler(self, self.onConfrBtnCallBack_))
		:pos(bgPanelSize.width / 2, priceMaxLimitBg:getPositionY() - priceBgSize.height / 2 - confirmBtnSize.height / 2 - confirmBtnMagrinTop)
		:addTo(self.background_)

	local bottomTipsShownWidth = bgPanelSize.width

	local bottomTipsMagrinBottom = 10
	local bottomTips = display.newTTFLabel({text = bm.LangUtil.getText("AUCTION_MARKET", "TIME_OVER_BOTTOM_TIP"), size = infoLabelParam.descBottom.frontSize,
		dimensions = cc.size(bottomTipsShownWidth, 0), color = infoLabelParam.descBottom.color, align = ui.TEXT_ALIGN_CENTER})
	bottomTips:pos(bgPanelSize.width / 2, bottomTips:getContentSize().height / 2 + bottomTipsMagrinBottom)
		:addTo(self.background_)
end

function AucteProdPopup:timeTickDown()
	-- body

	if self.remainTime < 3600 then
		--todo
		-- local str_time = os.date("%M:%S", self.remainTime)

		-- self.remTime_:setString(str_time)

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

		self.remTime_:setString(minShown .. ":" .. secShown)

		self.countDownShortAction_ = self:schedule(function()
			-- body
			self.remainTime = self.remainTime - 1

			-- if self.remainTime <= 0 then
			-- 	--todo
			-- 	self:stopAction(self.countDownShortAction_)
			-- 	self.countDownShortAction_ = nil
			-- else
			-- 	local str_time = os.date("%M:%S", self.remainTime)
			-- 	self.remTime_:setString(str_time)
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

			self.remTime_:setString(minShown .. ":" .. secShown)

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

		self.remTime_:setString(hourShown .. ":" .. minShown .. ":" .. secShown)

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

				self.remTime_:setString(minShown .. ":" .. secShown)
				-- local str_time = os.date("%M:%S", self.remainTime)
				-- self.remTime_:setString(str_time)

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

					-- 	self.remTime_:setString(str_time)
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

					self.remTime_:setString(minShown .. ":" .. secShown)

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

				self.remTime_:setString(hourShown .. ":" .. minShown .. ":" .. secShown)
			end
			
		end, 1)
	end
end

function AucteProdPopup:onMinAuctPriceBtnCallBack_()
	-- body

	if self.minAuctPirce == nk.userData["aUser.money"] or math.floor(nk.userData["aUser.money"] / 10000) <= math.ceil(self.minAuctPirce / 10000) then
		--todo

		if self.isFirstAuct_ then
			--todo
			if math.floor(nk.userData["aUser.money"] / 10000) == math.ceil(self.minAuctPirce / 10000) and nk.userData["aUser.money"] >= math.ceil(self.minAuctPirce / 10000) * 10000 then
				--todo
				local slidVal = self.auctPriceSilder_:getSliderValue()

				if slidVal == 100 then
					--todo
					local silderRate = nil

					if nk.userData["aUser.money"] == self.minAuctPirce then
						--todo
						silderRate = 0
					else
						silderRate = (math.ceil(self.minAuctPirce / 10000) * 10000 - self.minAuctPirce) /
							(nk.userData["aUser.money"] - self.minAuctPirce) * 100
					end
					-- local silderRate = (math.ceil(self.minAuctPirce / 10000) * 10000 - self.minAuctPirce) /
					-- 	(nk.userData["aUser.money"] - self.minAuctPirce) * 100

					self.auctPriceSilder_:setSliderValue(silderRate)

					return
				end
			end
		end
		self.auctPriceSilder_:setSliderValue(0)

		return
	end

	local slidVal = self.auctPriceSilder_:getSliderValue()
	

	-- if self.isFirstAuct_ then
	-- 	--todo
	-- 	local auctPriceSlid = self.minAuctPirce +
	-- 		(nk.userData["aUser.money"] - self.minAuctPirce) * (slidVal / 100)

	-- 	if auctPriceSlid < math.ceil(self.minAuctPirce / 10000) * 10000 then
	-- 		--todo
	-- 		slidRate = (math.ceil(self.minAuctPirce / 10000) * 10000 - self.minAuctPirce) / 
	-- 			(nk.userData["aUser.money"] - self.minAuctPirce)
	-- 	else
	-- 		slidRate = slidVal + 10000 / (nk.userData["aUser.money"] - self.minAuctPirce)
	-- 			* 100
	-- 	end
	-- else
	-- 	slidRate = slidVal - 10000 / (nk.userData["aUser.money"] - math.ceil(self.minAuctPirce / 10000) * 10000)
	-- 		* 100
	-- end
	local slidRate = slidVal - 10000 / (nk.userData["aUser.money"] - math.ceil(self.minAuctPirce / 10000) * 10000)
		* 100

	if slidRate <= 0 then
		--todo
		self.auctPriceSilder_:setSliderValue(0)
	else
		self.auctPriceSilder_:setSliderValue(slidRate)
	end

end

function AucteProdPopup:onMinAuctPriceContiCallBack_()
	-- body

	if not self.minAuctPriContiAnim_ then
		--todo
		self.minAuctPriContiAnim_ = self:schedule(function()
			-- body
			self:onMinAuctPriceBtnCallBack_()
		end, 0.12)
	end
end

function AucteProdPopup:onMinAuctPriceRelCallBack_()
	-- body

	if self.minAuctPriContiAnim_ then
		--todo
		self:stopAction(self.minAuctPriContiAnim_)
		self.minAuctPriContiAnim_ = nil
	end
end

function AucteProdPopup:onPluAuctPriceBtnCallBack_()
	-- body
	if self.minAuctPirce == nk.userData["aUser.money"] or math.floor(nk.userData["aUser.money"] / 10000) <= math.ceil(self.minAuctPirce / 10000) then
		--todo
		if self.isFirstAuct_ then
			--todo
			if math.floor(nk.userData["aUser.money"] / 10000) == math.ceil(self.minAuctPirce / 10000) and nk.userData["aUser.money"] >= math.ceil(self.minAuctPirce / 10000) * 10000 then
				--todo
				local slidVal = self.auctPriceSilder_:getSliderValue()

				if slidVal == 0 then
					--todo
					local silderRate = nil

					if nk.userData["aUser.money"] == self.minAuctPirce then
						--todo
						silderRate = 100
					else
						silderRate = (math.ceil(self.minAuctPirce / 10000) * 10000 - self.minAuctPirce) /
							(nk.userData["aUser.money"] - self.minAuctPirce) * 100
					end
					-- local silderRate = (math.ceil(self.minAuctPirce / 10000) * 10000 - self.minAuctPirce) /
					-- 	(nk.userData["aUser.money"] - self.minAuctPirce) * 100


					self.auctPriceSilder_:setSliderValue(silderRate)

					return
				end
			end
		end

		self.auctPriceSilder_:setSliderValue(100)

		return
	end

	local slidVal = self.auctPriceSilder_:getSliderValue()
	local slidRate = 0

	if self.isFirstAuct_ then
		--todo
		-- local midValLeft = (self.minAuctPirce + math.ceil(self.minAuctPirce / 10000) * 10000) / 2

		local auctPriceSlid = self.minAuctPirce +
			(nk.userData["aUser.money"] - self.minAuctPirce) * (slidVal / 100)

		if auctPriceSlid < math.ceil(self.minAuctPirce / 10000) * 10000 then
			--todo
			slidRate = (math.ceil(self.minAuctPirce / 10000) * 10000 - self.minAuctPirce) / 
				(nk.userData["aUser.money"] - self.minAuctPirce) * 100
		else
			slidRate = slidVal + 10000 / (nk.userData["aUser.money"] - self.minAuctPirce)
				* 100
		end

	else
		slidRate = slidVal + 10000 / (nk.userData["aUser.money"] - math.ceil(self.minAuctPirce / 10000) * 10000)
			* 100
	end
	
	if slidRate >= 100 then
		--todo
		self.auctPriceSilder_:setSliderValue(100)

	else
		self.auctPriceSilder_:setSliderValue(slidRate)
	end

end

function AucteProdPopup:onPluAuctPriceContiCallBack_()
	-- body

	if not self.pluAuctPriContiAnim_ then
		--todo
		self.pluAuctPriContiAnim_ = self:schedule(function()
			-- body
			self:onPluAuctPriceBtnCallBack_()
		end, 0.12)
	end
end

function AucteProdPopup:onPluAuctPriceRelCallBack_()
	-- body
	if self.pluAuctPriContiAnim_ then
		--todo
		self:stopAction(self.pluAuctPriContiAnim_)
		self.pluAuctPriContiAnim_ = nil
	end
end

function AucteProdPopup:onAuctPriceSlideCallBack_()
	-- body
	if self.minAuctPirce == nk.userData["aUser.money"] or math.floor(nk.userData["aUser.money"] / 10000) <= math.ceil(self.minAuctPirce / 10000) then
		--todo
		local slidVal = self.auctPriceSilder_:getSliderValue()

		if self.isFirstAuct_ then
			--todo
			if nk.userData["aUser.money"] == self.minAuctPirce then
				--todo
				if slidVal >= 50 then
					--todo
					self.slidValFix_ = 100

					-- self.auctPriceNum = self.minAuctPirce
					-- local auctpriceStr = bm.formatNumberWithSplit(self.auctPriceNum)  -- 需要动态改变的话,做长度限制判断
					-- self.auctPrice_:setString(auctpriceStr)
				else
					self.slidValFix_ = 0

					-- self.auctPriceNum = nk.userData["aUser.money"]
					-- local auctpriceStr = bm.formatNumberWithSplit(self.auctPriceNum)  -- 需要动态改变的话,做长度限制判断
					-- self.auctPrice_:setString(auctpriceStr)
				end

				return
			end

			if math.floor(nk.userData["aUser.money"] / 10000) == math.ceil(self.minAuctPirce / 10000) and nk.userData["aUser.money"] >= math.ceil(self.minAuctPirce / 10000) * 10000 then
				--todo
				-- local slidVal = self.auctPriceSilder_:getSliderValue()
				local midValLeft = (self.minAuctPirce + math.ceil(self.minAuctPirce / 10000) * 10000) / 2
				local midValRight = (math.ceil(self.minAuctPirce / 10000) * 10000 + nk.userData["aUser.money"]) / 2

				local auctPriceSlid = self.minAuctPirce +
					(nk.userData["aUser.money"] - self.minAuctPirce) * (slidVal / 100)
					
				if auctPriceSlid >= midValLeft and auctPriceSlid <= midValRight then
					--todo
					local silderRate = (math.ceil(self.minAuctPirce / 10000) * 10000 - self.minAuctPirce) /
						(nk.userData["aUser.money"] - self.minAuctPirce) * 100

					-- self.auctPriceSilder_:setSliderValue(silderRate)
					self.slidValFix_ = silderRate

					self.auctPriceNum = math.ceil(self.minAuctPirce / 10000) * 10000
					local auctpriceStr = bm.formatNumberWithSplit(self.auctPriceNum)  -- 需要动态改变的话,做长度限制判断
					self.auctPrice_:setString(auctpriceStr)

				elseif auctPriceSlid < midValLeft then
					--todo
					self.slidValFix_ = 0

					self.auctPriceNum = self.minAuctPirce

					local auctpriceStr = bm.formatNumberWithSplit(self.auctPriceNum)  -- 需要动态改变的话,做长度限制判断
					self.auctPrice_:setString(auctpriceStr)
				else
					self.slidValFix_ = 100

					self.auctPriceNum = nk.userData["aUser.money"]

					local auctpriceStr = bm.formatNumberWithSplit(self.auctPriceNum)  -- 需要动态改变的话,做长度限制判断
					self.auctPrice_:setString(auctpriceStr)
				end

				return
			end
		end

		if slidVal >= 50 then
			--todo
			self.slidValFix_ = 100
			self.auctPriceNum = nk.userData["aUser.money"]

			local auctpriceStr = bm.formatNumberWithSplit(self.auctPriceNum)  -- 需要动态改变的话,做长度限制判断
			self.auctPrice_:setString(auctpriceStr)
		else
			self.slidValFix_ = 0
			self.auctPriceNum = self.minAuctPirce

			local auctpriceStr = bm.formatNumberWithSplit(self.auctPriceNum)  -- 需要动态改变的话,做长度限制判断
			self.auctPrice_:setString(auctpriceStr)
		end
		
		return
	end

	local slidVal = self.auctPriceSilder_:getSliderValue()

	if self.isFirstAuct_ then
		--todo
		local auctPriceSlid = self.minAuctPirce +
			(nk.userData["aUser.money"] - self.minAuctPirce) * (slidVal / 100)

		if auctPriceSlid > math.floor(nk.userData["aUser.money"] / 10000) * 10000 then
			--todo
			self.auctPriceNum = nk.userData["aUser.money"]
			self.slidValFix_ = 100
		else
			local midValLeft = (self.minAuctPirce + math.ceil(self.minAuctPirce / 10000) * 10000) / 2
			if auctPriceSlid < midValLeft then
				--todo
				self.auctPriceNum = self.minAuctPirce

				self.slidValFix_ = 0
			else
				local midValLeft = (self.minAuctPirce + math.ceil(self.minAuctPirce / 10000) * 10000) / 2
				-- if auctPriceSlid == math.ceil(self.minAuctPirce / 10000) * 10000 then
				-- 	--todo
				-- 	self.auctPriceNum = math.ceil(self.minAuctPirce / 10000) * 10000

				-- 	self.slidValFix_ = (self.auctPriceNum - self.minAuctPirce) /
				-- 		(nk.userData["aUser.money"] - self.minAuctPirce) * 100
				-- else
				-- 	self.auctPriceNum = math.ceil(auctPriceSlid / 10000) * 10000

				-- 	self.slidValFix_ = (self.auctPriceNum - self.minAuctPirce) /
				-- 		(nk.userData["aUser.money"] - self.minAuctPirce) * 100
				-- end

				self.auctPriceNum = math.ceil(auctPriceSlid / 10000) * 10000

				self.slidValFix_ = (self.auctPriceNum - self.minAuctPirce) /
					(nk.userData["aUser.money"] - self.minAuctPirce) * 100

				-- 	(nk.userData["aUser.money"] - self.minAuctPirce) * (self.slidValFix_ / 100))
			end
			
		end
	else
		local auctPriceSlid = math.ceil(self.minAuctPirce / 10000) * 10000 +
			(nk.userData["aUser.money"] - math.ceil(self.minAuctPirce / 10000) * 10000) * (slidVal / 100)

		-- local auctPriceFact = math.ceil(minAuctPrice / 10000) * 10000 +
		-- 		(nk.userData["aUser.money"] - math.ceil(minAuctPrice / 10000) * 10000) * silderRate

		if auctPriceSlid > math.floor(nk.userData["aUser.money"] / 10000) * 10000 then
			--todo

			self.auctPriceNum = nk.userData["aUser.money"]
			self.slidValFix_ = 100
		else
			self.auctPriceNum = math.ceil(auctPriceSlid / 10000) * 10000
			self.slidValFix_ = (self.auctPriceNum - math.ceil(self.minAuctPirce / 10000) * 10000) /
				(nk.userData["aUser.money"] - math.ceil(self.minAuctPirce / 10000) * 10000) * 100
		end
	end
	

	-- if slidVal == 100 then
	-- 	--todo
	-- 	self.auctPriceNum = nk.userData["aUser.money"]
	-- else
	-- 	self.auctPriceNum = math.floor(auctPriceSlid / 10000) * 10000
	-- end

	-- self.slidValFix_ = (math.floor(auctPriceSlid / 10000) * 10000 - math.ceil(self.minAuctPirce / 10000) * 10000) /
	-- 	(math.floor(nk.userData["aUser.money"] / 10000) * 10000 - math.ceil(self.minAuctPirce / 10000) * 10000) * 100
	
	local auctpriceStr = bm.formatNumberWithSplit(self.auctPriceNum)  -- 需要动态改变的话,做长度限制判断
	self.auctPrice_:setString(auctpriceStr)
	
end

function AucteProdPopup:onAuctPriceSlldFixCallBack_()
	-- body
	self.auctPriceSilder_:setSliderValue(self.slidValFix_)
end

function AucteProdPopup:onConfrBtnCallBack_()
	-- body
	-- local auctPrice = self.auctPriceNum
	self.confirmBtn_:setButtonEnabled(false)

	local auctParam = {}
	auctParam.itemId = self.itemId_
	auctParam.auctType = 1
	auctParam.auctPrice = self.auctPriceNum

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
		elseif errData.errorCode == - 7 then
			--todo

			nk.CenterTipManager:showCenterTip({text = bm.LangUtil.getText("AUCTION_MARKET", "AUCTION_FAIL_FOR_RETRY"), messageType = 1000})
		elseif errData.errorCode == - 8 then
			--todo

			nk.CenterTipManager:showCenterTip({text = bm.LangUtil.getText("AUCTION_MARKET", "AUCTION_FAIL_FOR_GONE"), messageType = 1000})
		elseif errData.errorCode == -10 then
			-- 竞拍人是自己，不能再拍
			nk.CenterTipManager:showCenterTip({text = bm.LangUtil.getText("AUCTION_MARKET", "AUCTION_FAIL_FOR_HAS_AUCTION"), messageType = 1000})
		else
			nk.CenterTipManager:showCenterTip({text = bm.LangUtil.getText("AUCTION_MARKET", "AUCTION_FAIL_FOR_RETRY"), messageType = 1000})

			return
		end
		-- nk.CenterTipManager:showCenterTip({text = "网络错误,竞拍失败！", messageType = 1000})

		if self and self.hidePanel then
			--todo
			self:hidePanel()
		end
	end)

end

function AucteProdPopup:onCloseBtnCallBack_()
	-- body
	self:hidePanel()
end

function AucteProdPopup:onIconLoadComplete_(success, sprite)
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

function AucteProdPopup:showPanel()
	-- body
	-- self:showPanel_()
	nk.PopupManager:addPopup(self)
end

function AucteProdPopup:onShowed()
	-- body
end

function AucteProdPopup:hidePanel()
	-- body
	nk.PopupManager:removePopup(self)
end

function AucteProdPopup:onEnter()
	-- body
end

function AucteProdPopup:onExit()
	-- body
	if self.countDownShortAction_ then
		--todo
		self:stopAction(self.countDownShortAction_)
	end

	if self.countDownLongAction_ then
		--todo
		self:stopAction(self.countDownLongAction_)
	end

	if self.pluAuctPriContiAnim_ then
		--todo
		self:stopAction(self.pluAuctPriContiAnim_)
	end

	if self.minAuctPriContiAnim_ then
		--todo
		self:stopAction(self.minAuctPriContiAnim_)
	end
end

function AucteProdPopup:onCleanup()
	-- body
	nk.ImageLoader:cancelJobByLoaderId(self.prodIconLoaderId_)
end

return AucteProdPopup