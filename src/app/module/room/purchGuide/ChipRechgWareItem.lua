local config = import(".Config")

local ListItem = bm.ui.ListItem
local ChipRechgWareItem = class("ChipRechgWareItem", ListItem)

function ChipRechgWareItem:ctor()
	-- body drawListViewItem --
	cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
	self:setNodeEventEnabled(true)

	ChipRechgWareItem.super.ctor(self, config.RechgListItemParam.WIDTH, config.RechgListItemParam.HEIGHT)

	self:initViews()
end

function ChipRechgWareItem:initViews()
	-- body
	local itemMagrinTopBottom = 8

	local ChipIconShiftParam = {
		x = 3,
		y = 2
	}

	local chipDescMagrins = {
		left = 0,
		top = 20,
		bottom = 20,
		lines = 15,
		rows = 5
	}

	local BtnSize = {
		width = 150,
		height = 62
	}

	local buyWareBtnMagrin = {
		top = 0,
		right = 25
	}

	self._bgPanel = display.newScale9Sprite("#payGuide_blockDentWhite.png", config.RechgListItemParam.WIDTH / 2, config.RechgListItemParam.HEIGHT / 2,
		cc.size(config.RechgListItemParam.WIDTH, config.RechgListItemParam.HEIGHT - itemMagrinTopBottom * 2))
		:addTo(self)

	self._chipIcon = display.newSprite("#payGuide_chipLess.png")
	self._chipIcon:pos(self._chipIcon:getContentSize().width / 2 - ChipIconShiftParam.x, self._bgPanel:getContentSize().height / 2 + ChipIconShiftParam.y)
		:addTo(self._bgPanel)

	self._chipPriceLabel = display.newTTFLabel({text = "00THB = ", size = config.RechgListItemParam.frontSizes.labelPrice, color = config.RechgListItemParam.colors.labelPrice, align = ui.TEXT_ALIGN_CENTER})
	self._chipPriceLabel:setAnchorPoint(display.ANCHOR_POINTS[display.LEFT_CENTER])
	self._chipPriceLabel:pos(self._chipIcon:getContentSize().width + chipDescMagrins.left,
		self._bgPanel:getContentSize().height - chipDescMagrins.top - self._chipPriceLabel:getContentSize().height / 2)
		:addTo(self._bgPanel)

	self._chipNumLabel = display.newTTFLabel({text = bm.LangUtil.getText("CPURCHGUIDE", "CHIPS_NUM", 2000), size = config.RechgListItemParam.frontSizes.labelPrice, color = config.RechgListItemParam.colors.labelPrice, align = ui.TEXT_ALIGN_CENTER})
	self._chipNumLabel:setAnchorPoint(display.ANCHOR_POINTS[display.LEFT_CENTER])
	self._chipNumLabel:pos(self._chipIcon:getContentSize().width + chipDescMagrins.left + self._chipPriceLabel:getContentSize().width + chipDescMagrins.rows,
		self._bgPanel:getContentSize().height - chipDescMagrins.top - self._chipNumLabel:getContentSize().height / 2)
		:addTo(self._bgPanel)

	self._avgPriceLabel = display.newTTFLabel({text = bm.LangUtil.getText("CPURCHGUIDE", "CHIP_AVG", 800), size = config.RechgListItemParam.frontSizes.labelAvgPrice, color = config.RechgListItemParam.colors.labelAvgPrice, align = ui.TEXT_ALIGN_CENTER})
	self._avgPriceLabel:setAnchorPoint(display.ANCHOR_POINTS[display.LEFT_CENTER])
	self._avgPriceLabel:pos(self._chipIcon:getContentSize().width + chipDescMagrins.left, chipDescMagrins.bottom + self._avgPriceLabel:getContentSize().height / 2)
		:addTo(self._bgPanel)

	local goBuyWareBtn = cc.ui.UIPushButton.new("#payGuide_btnGrnL.png", {scale9 = true})
		:setButtonSize(BtnSize.width, BtnSize.height)
		:setButtonLabel("normal", display.newTTFLabel({text = bm.LangUtil.getText("CPURCHGUIDE", "GET_CHARGE"), size = config.RechgListItemParam.frontSizes.labelBtn, color = config.RechgListItemParam.colors.labelBtn, align = ui.TEXT_ALIGN_CENTER}))
		:onButtonClicked(buttontHandler(self, self._onBuyingBtnCallBack))

	goBuyWareBtn:pos(config.RechgListItemParam.WIDTH - buyWareBtnMagrin.right - BtnSize.width / 2,
		self._bgPanel:getContentSize().height / 2)
		:addTo(self._bgPanel)

	local recommFlagPosShift = {
		x = 8,
		y = - 2
	}

	self._recommFlag = display.newSprite("#payGuide_tagRecomm.png")
		:pos(config.RechgListItemParam.WIDTH - buyWareBtnMagrin.right + recommFlagPosShift.x, self._bgPanel:getContentSize().height / 2 + BtnSize.height / 2 + recommFlagPosShift.y)
		:addTo(self._bgPanel)

	-- 默认不推荐该商品 -- 
	self._recommFlag:setVisible(false)
	
end

function ChipRechgWareItem:onDataSet(dataChanged, data)
	-- body


	if dataChanged then
		--todo
		self._data = data

		-- setSpriteFrame --
		if data._idx == 1 then
		--todo
			self._chipIcon:setSpriteFrame(display.newSpriteFrame("payGuide_chipLess.png"))
		else

			local ChipIconShiftParam = {
				x = 13,
				y = 3
			}

			self._chipIcon:setSpriteFrame(display.newSpriteFrame("payGuide_chipMulti.png"))

			self._chipIcon:pos(self._chipIcon:getContentSize().width / 2 - ChipIconShiftParam.x,
				self._bgPanel:getContentSize().height / 2 + ChipIconShiftParam.y)
		end

		-- set labels --
		
		self._chipPriceLabel:setString(tostring(data.price) .. tostring(data.priceDollar) .. " =")

		if data.isCashCoin then
			--todo

			self._chipIcon:setSpriteFrame(display.newSpriteFrame("cash_coin_icon.png"))

			local cashNum = data.pcoins
			-- 这个地方确认一下，原始票及优惠票的数目差异 --
			self._chipNumLabel:setString(tostring(cashNum) .. bm.LangUtil.getText("CPURCHGUIDE", "CASHCOIN_QUANT"))
			self._avgPriceLabel:setString("1" .. tostring(data.priceDollar) .. " = " .. string.format("%.2f", tonumber(data.rate) / tonumber(data.discount)) .. bm.LangUtil.getText("CPURCHGUIDE", "CASHCOIN_QUANT"))

		else
			self._chipNumLabel:setString(bm.LangUtil.getText("CPURCHGUIDE", "CHIPS_NUM", data.chipNum))
			
			self._avgPriceLabel:setString("1" .. tostring(data.priceDollar) .. " = " .. bm.LangUtil.getText("CPURCHGUIDE", "CHIPS_NUM", tonumber(data.rate) / tonumber(data.discount)))
		end

		local chipDescMagrins = {
			left = 0,
			top = 20,
			bottom = 20,
			lines = 15,
			rows = 5
		}

		if not data.isCashCoin then
			--todo
			if data._idx == 1 then
				--todo
				self._chipNumLabel:pos(self._chipIcon:getContentSize().width + chipDescMagrins.left + self._chipPriceLabel:getContentSize().width + chipDescMagrins.rows,
					self._bgPanel:getContentSize().height - chipDescMagrins.top - self._chipNumLabel:getContentSize().height / 2)
			else
				local chipIconChangesInPosX = 12 * 2

				self._chipNumLabel:pos(self._chipIcon:getContentSize().width + chipDescMagrins.left + self._chipPriceLabel:getContentSize().width + chipDescMagrins.rows - chipIconChangesInPosX,
					self._bgPanel:getContentSize().height - chipDescMagrins.top - self._chipNumLabel:getContentSize().height / 2)
			end
		end

		if tonumber(data.discount) > 1 then
			--todo
			-- PriceLabel Part --
			local deleteLineShownHeight = 4
			local deleteLineWidthFixSides = 0

			local deleteLinePriceTh = display.newScale9Sprite("#payGuide_lineTh.png", self._chipNumLabel:getContentSize().width / 2, self._chipNumLabel:getContentSize().height / 2, cc.size(self._chipNumLabel:getContentSize().width + deleteLineWidthFixSides * 2, deleteLineShownHeight))
			deleteLinePriceTh:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER_LEFT])
			deleteLinePriceTh:setPosition(self._chipNumLabel:getPosition())
			deleteLinePriceTh:addTo(self._bgPanel)

			local numOff = data.chipNumOff
			if data.isCashCoin then
				--todo
				numOff = data.cashNumOff
			end

			local ticketNumFactLabelMagrinLeft = 5
			local ticketNumFactLabe = display.newTTFLabel({text = tostring(numOff) .. bm.LangUtil.getText("CPURCHGUIDE", "CASHCOIN_QUANT"), size = config.RechgListItemParam.frontSizes.labelPrice, color = config.RechgListItemParam.colors.labelPrice, align = ui.TEXT_ALIGN_CENTER})
			ticketNumFactLabe:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER_LEFT])
			ticketNumFactLabe:pos(self._chipNumLabel:getPositionX() + self._chipNumLabel:getContentSize().width + deleteLineWidthFixSides * 2 + ticketNumFactLabelMagrinLeft, self._chipNumLabel:getPositionY())
				:addTo(self._bgPanel)

			-- AvgPrice Part --
			local eachWordWidth = 4.6
			local ticketQuantLabelWidth = 22
			
			local avgPriceLabelWidth = string.len(string.format("%.2f", tonumber(data.rate) / tonumber(data.discount))) * eachWordWidth + ticketQuantLabelWidth
			-- local avgPriceTitleWidthCalModel = display.newTTFLabel({text = "1" .. tostring(data.priceDollar) .. " = ", size = config.RechgListItemParam.frontSizes.labelAvgPrice, color = config.RechgListItemParam.colors.labelAvgPrice, align = ui.TEXT_ALIGN_CENTER})

			local deleteLineAvgMagrinRight = 0
			-- local deleteLineAvgPosX = avgPriceTitleWidthCalModel:getContentSize().width + deleteLineAvgMagrinLeft

			local deleteLineAvgPriceTh = display.newScale9Sprite("#payGuide_lineTh.png", 0, 0, cc.size(avgPriceLabelWidth, deleteLineShownHeight))
			deleteLineAvgPriceTh:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER_RIGHT])
			deleteLineAvgPriceTh:pos(self._avgPriceLabel:getPositionX() + self._avgPriceLabel:getContentSize().width - deleteLineAvgMagrinRight, self._avgPriceLabel:getPositionY())
			-- deleteLineAvgPriceTh:setPosition(self._avgPriceLabel:getPosition())
			deleteLineAvgPriceTh:addTo(self._bgPanel)

			local ticketAvgNumFactMagrinLeft = 5
			local ticketAvgNumFactLabe = display.newTTFLabel({text = tostring(data.rate) .. bm.LangUtil.getText("CPURCHGUIDE", "CASHCOIN_QUANT"), size = config.RechgListItemParam.frontSizes.labelAvgPrice, color = config.RechgListItemParam.colors.labelAvgPrice, align = ui.TEXT_ALIGN_CENTER})
			ticketAvgNumFactLabe:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER_LEFT])
			ticketAvgNumFactLabe:pos(self._avgPriceLabel:getPositionX() + self._avgPriceLabel:getContentSize().width + ticketAvgNumFactMagrinLeft, self._avgPriceLabel:getPositionY())
				:addTo(self._bgPanel)
		end

		if data.tag == "hot" then
		--todo
			self._recommFlag:setVisible(true)
		end
	end
end

function ChipRechgWareItem:_onBuyingBtnCallBack()
	-- body
	-- 派发购买事件 --
	self:dispatchEvent({name = "ITEM_EVENT", data = self._data})

end

return ChipRechgWareItem