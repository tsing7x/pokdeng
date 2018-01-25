local config = import(".Config")

local ListItem = bm.ui.ListItem
local ChipFrChgWareItem = class("ChipFrChgWareItem", ListItem)

function ChipFrChgWareItem:ctor()
	-- body drawListViewItem --
	cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
	self:setNodeEventEnabled(true)

	ChipFrChgWareItem.super.ctor(self, config.FirChgListItemParam.WIDTH, config.FirChgListItemParam.HEIGHT)

	self:initViews()
end

function ChipFrChgWareItem:initViews()
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

	self._bgPanel = display.newScale9Sprite("#payGuide_blockDentWhite.png", config.FirChgListItemParam.WIDTH / 2, config.FirChgListItemParam.HEIGHT / 2,
		cc.size(config.FirChgListItemParam.WIDTH, config.FirChgListItemParam.HEIGHT - itemMagrinTopBottom * 2))
		:addTo(self)

	self._chipIcon = display.newSprite("#payGuide_chipLess.png")

	self._chipIcon:pos(self._chipIcon:getContentSize().width / 2 - ChipIconShiftParam.x, self._bgPanel:getContentSize().height / 2 + ChipIconShiftParam.y)
		:addTo(self._bgPanel)

	-- labels draw --
	self._chipPriceTTF = display.newTTFLabel({text = "00THB = ", size = config.FirChgListItemParam.frontSizes.labelPrice, color = config.FirChgListItemParam.colors.labelPrice, align = ui.TEXT_ALIGN_CENTER})
	self._chipPriceTTF:setAnchorPoint(display.ANCHOR_POINTS[display.LEFT_CENTER])
	self._chipPriceTTF:pos(self._chipIcon:getContentSize().width + chipDescMagrins.left,
		self._bgPanel:getContentSize().height - chipDescMagrins.top - self._chipPriceTTF:getContentSize().height / 2)
		:addTo(self._bgPanel)

	self._oldChipNumTTF = display.newTTFLabel({text = "0000000", size = config.FirChgListItemParam.frontSizes.labelPrice, color = config.FirChgListItemParam.colors.labelPrice, align = ui.TEXT_ALIGN_CENTER})
	self._oldChipNumTTF:setAnchorPoint(display.ANCHOR_POINTS[display.LEFT_CENTER])
	self._oldChipNumTTF:pos(self._chipIcon:getContentSize().width + chipDescMagrins.left + self._chipPriceTTF:getContentSize().width + chipDescMagrins.rows,
		self._bgPanel:getContentSize().height - chipDescMagrins.top - self._oldChipNumTTF:getContentSize().height / 2)
		:addTo(self._bgPanel)

	self._favChipNumTTF = display.newTTFLabel({text = bm.LangUtil.getText("CPURCHGUIDE", "CHIPS_NUM", 0), size = config.FirChgListItemParam.frontSizes.labelPrice, color = config.FirChgListItemParam.colors.labelPrice, align = ui.TEXT_ALIGN_CENTER})
	self._favChipNumTTF:setAnchorPoint(display.ANCHOR_POINTS[display.LEFT_CENTER])
	self._favChipNumTTF:pos(self._chipIcon:getContentSize().width + chipDescMagrins.left + self._chipPriceTTF:getContentSize().width + self._oldChipNumTTF:getContentSize().width + chipDescMagrins.rows * 2,
		self._bgPanel:getContentSize().height - chipDescMagrins.top - self._favChipNumTTF:getContentSize().height / 2)
		:addTo(self._bgPanel)

	self._avgPriceTTF = display.newTTFLabel({text = "1THB = ", size = config.FirChgListItemParam.frontSizes.labelAvgPrice, color = config.FirChgListItemParam.colors.labelAvgPrice, align = ui.TEXT_ALIGN_CENTER})
	self._avgPriceTTF:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER_LEFT])
	self._avgPriceTTF:pos(self._chipIcon:getContentSize().width + chipDescMagrins.left, chipDescMagrins.bottom + self._avgPriceTTF:getContentSize().height / 2)
		:addTo(self._bgPanel)

	self._oldAvgChipNumTTF = display.newTTFLabel({text = "0000", size = config.FirChgListItemParam.frontSizes.labelAvgPrice, color = config.FirChgListItemParam.colors.labelAvgPrice, align = ui.TEXT_ALIGN_CENTER})
	self._oldAvgChipNumTTF:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER_LEFT])
	self._oldAvgChipNumTTF:pos(self._chipIcon:getContentSize().width + chipDescMagrins.left + self._avgPriceTTF:getContentSize().width,
		chipDescMagrins.bottom + self._oldAvgChipNumTTF:getContentSize().height / 2)
		:addTo(self._bgPanel)

	self._favAvgChipNumTTF = display.newTTFLabel({text = bm.LangUtil.getText("CPURCHGUIDE", "CHIPS_NUM", 0), size = config.FirChgListItemParam.frontSizes.labelAvgPrice, color = config.FirChgListItemParam.colors.labelAvgPrice, align = ui.TEXT_ALIGN_CENTER})
	self._favAvgChipNumTTF:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER_LEFT])
	self._favAvgChipNumTTF:pos(self._chipIcon:getContentSize().width + chipDescMagrins.left + self._avgPriceTTF:getContentSize().width + self._oldAvgChipNumTTF:getContentSize().width + chipDescMagrins.rows,
		chipDescMagrins.bottom + self._favAvgChipNumTTF:getContentSize().height / 2)
		:addTo(self._bgPanel)


	-- draw  line-through -- 
	local thLineHeight = 4
	local lineShownEachSide = 3

	self._thLineOldChipNum = display.newScale9Sprite("#payGuide_lineTh.png", self._oldChipNumTTF:getPositionX() + self._oldChipNumTTF:getContentSize().width / 2, self._oldChipNumTTF:getPositionY(),
		cc.size(self._oldChipNumTTF:getContentSize().width + lineShownEachSide * 2, thLineHeight))
		:addTo(self._bgPanel)

	self._thLineOldAvgChipNum = display.newScale9Sprite("#payGuide_lineTh.png", self._oldAvgChipNumTTF:getPositionX() + self._oldAvgChipNumTTF:getContentSize().width / 2, self._oldAvgChipNumTTF:getPositionY(),
		cc.size(self._oldAvgChipNumTTF:getContentSize().width, thLineHeight))
		:addTo(self._bgPanel)
	-- end --

	local btnSize = {
		width = 118,
		height = 70
	}

	local quickBuyBtnMagrinRight = 10

	local quickBuyBtn = cc.ui.UIPushButton.new("#payGuide_btnGrnL.png", {scale9 = true})
		:setButtonSize(btnSize.width, btnSize.height)
		:setButtonLabel("normal", display.newTTFLabel({text = bm.LangUtil.getText("CPURCHGUIDE", "GET_CHARGE"), size = config.FirChgListItemParam.frontSizes.labelBtn, color = config.FirChgListItemParam.colors.labelBtn, align = ui.TEXT_ALIGN_CENTER}))
		:onButtonClicked(buttontHandler(self, self._onBuyingBtnCallBack))

	quickBuyBtn:pos(self._bgPanel:getContentSize().width - quickBuyBtnMagrinRight - btnSize.width / 2, self._bgPanel:getContentSize().height / 2)
		:addTo(self._bgPanel)

	local recommFlagPosShift = {
		x = 8,
		y = 8
	}

	self._recommFlag = display.newSprite("#payGuide_tagRecomm.png")
		:pos(self._bgPanel:getContentSize().width - quickBuyBtnMagrinRight - recommFlagPosShift.x, self._bgPanel:getContentSize().height / 2 + btnSize.height / 2 - recommFlagPosShift.y)
		:addTo(self._bgPanel)

	-- 默认不推荐该商品 -- 
	self._recommFlag:setVisible(false)
	
end

function ChipFrChgWareItem:onDataSet(dataChanged, data)
	-- body

	-- dump(data, "data:======================")
	if dataChanged then
		--todo

		self._data = data

		if data._idx == 1 then
		--todo
			self._chipIcon:setSpriteFrame(display.newSpriteFrame("payGuide_chipLess.png"))
		else

			local ChipIconShiftParam = {
				x = 13,
				y = 4
			}

			self._chipIcon:setSpriteFrame(display.newSpriteFrame("payGuide_chipMulti.png"))

			self._chipIcon:pos(self._chipIcon:getContentSize().width / 2 - ChipIconShiftParam.x,
				self._bgPanel:getContentSize().height / 2 + ChipIconShiftParam.y)
		end

		local chipPrice = data.price
		local chipNum = data.chipNum
		local avgChipNum = data.rate

		local chipDescMagrins = {
			left = 0,
			top = 20,
			bottom = 20,
			lines = 15,
			rows = 5
		}


		-- set Labels --
		self._chipPriceTTF:setString(tostring(chipPrice) .. tostring(data.priceDollar) .. " = ")
		self._oldChipNumTTF:setString(tostring(chipNum))
		

		self._avgPriceTTF:setString("1" .. tostring(data.priceDollar) .. " = ")

		self._oldAvgChipNumTTF:setString(tostring(avgChipNum))

		if device.platform == "android" or device.platform == "windows" then
			--todo
			self._favChipNumTTF:setString(bm.LangUtil.getText("CPURCHGUIDE", "CHIPS_NUM", tonumber(chipNum) * 6))
			self._favAvgChipNumTTF:setString(bm.LangUtil.getText("CPURCHGUIDE", "CHIPS_NUM", tonumber(avgChipNum) * 6))
		elseif device.platform == "ios" then
			--todo
			self._favChipNumTTF:setString(bm.LangUtil.getText("CPURCHGUIDE", "CHIPS_NUM", tonumber(chipNum) * 2))
			self._favAvgChipNumTTF:setString(bm.LangUtil.getText("CPURCHGUIDE", "CHIPS_NUM", tonumber(avgChipNum) * 2))
		end

		-- adjust positions --

		if data._idx == 1 then
			--todo
			self._oldChipNumTTF:pos(self._chipIcon:getContentSize().width + chipDescMagrins.left + self._chipPriceTTF:getContentSize().width,
				self._bgPanel:getContentSize().height - chipDescMagrins.top - self._oldChipNumTTF:getContentSize().height / 2)

			self._favChipNumTTF:pos(self._chipIcon:getContentSize().width + chipDescMagrins.left + self._chipPriceTTF:getContentSize().width + self._oldChipNumTTF:getContentSize().width + chipDescMagrins.rows * 2,
				self._bgPanel:getContentSize().height - chipDescMagrins.top - self._favChipNumTTF:getContentSize().height / 2)

			self._oldAvgChipNumTTF:pos(self._chipIcon:getContentSize().width + chipDescMagrins.left + self._avgPriceTTF:getContentSize().width + chipDescMagrins.rows,
				chipDescMagrins.bottom + self._oldAvgChipNumTTF:getContentSize().height / 2)

			self._favAvgChipNumTTF:pos(self._chipIcon:getContentSize().width + chipDescMagrins.left + self._avgPriceTTF:getContentSize().width + self._oldAvgChipNumTTF:getContentSize().width + chipDescMagrins.rows * 2,
				chipDescMagrins.bottom + self._favAvgChipNumTTF:getContentSize().height / 2)
		else
			local chipIconChangesInPosX = 13 * 2

			self._oldChipNumTTF:pos(self._chipIcon:getContentSize().width + chipDescMagrins.left + self._chipPriceTTF:getContentSize().width - chipIconChangesInPosX,
				self._bgPanel:getContentSize().height - chipDescMagrins.top - self._oldChipNumTTF:getContentSize().height / 2)

			self._favChipNumTTF:pos(self._chipIcon:getContentSize().width + chipDescMagrins.left + self._chipPriceTTF:getContentSize().width + self._oldChipNumTTF:getContentSize().width + chipDescMagrins.rows * 2 - chipIconChangesInPosX,
				self._bgPanel:getContentSize().height - chipDescMagrins.top - self._favChipNumTTF:getContentSize().height / 2)

			self._oldAvgChipNumTTF:pos(self._chipIcon:getContentSize().width + chipDescMagrins.left + self._avgPriceTTF:getContentSize().width + chipDescMagrins.rows - chipIconChangesInPosX,
				chipDescMagrins.bottom + self._oldAvgChipNumTTF:getContentSize().height / 2)

			self._favAvgChipNumTTF:pos(self._chipIcon:getContentSize().width + chipDescMagrins.left + self._avgPriceTTF:getContentSize().width + self._oldAvgChipNumTTF:getContentSize().width + chipDescMagrins.rows * 2 - chipIconChangesInPosX,
				chipDescMagrins.bottom + self._favAvgChipNumTTF:getContentSize().height / 2)
		end

		-- draw thLines --
		local thLineHeight = 4
		local lineShownEachSide = 3
		local thLinePosYFix = 1

		self._thLineOldChipNum:size(self._oldChipNumTTF:getContentSize().width + lineShownEachSide * 2, thLineHeight)
		self._thLineOldChipNum:pos(self._oldChipNumTTF:getContentSize().width / 2, self._oldChipNumTTF:getContentSize().height / 2 + thLinePosYFix)

		self._thLineOldAvgChipNum:size(self._oldAvgChipNumTTF:getContentSize().width, thLineHeight)
		self._thLineOldAvgChipNum:pos(self._oldAvgChipNumTTF:getContentSize().width / 2, self._oldAvgChipNumTTF:getContentSize().height / 2 + thLinePosYFix)
		-- end --

		if data.tag == "hot" then
		--todo
			self._recommFlag:setVisible(true)
		end
	end
end

function ChipFrChgWareItem:_onBuyingBtnCallBack()
	-- body
	-- -- 派发购买事件 --
	self:dispatchEvent({name = "ITEM_EVENT", data = self._data})

end

return ChipFrChgWareItem