local PropProdItemPanelParam = {
	WIDTH = 560,
	HEIGHT = 128,

	frontSizes = {
		name = 20,
		desc = 18,
		price = 20
	},

	colors = {
		name = display.COLOR_WHITE,
		desc = cc.c3b(107, 132, 163),
		price = styles.FONT_COLOR.GOLDEN_TEXT
	}
}

-- 参照 GiftProdComponItem 添加时间，结束战斗！--
local PropProdListItem = class("PropProdListItem", bm.ui.ListItem)

function PropProdListItem:ctor(data)
	-- body
	self:setTouchEnabled(true)
	self:setTouchSwallowEnabled(false)

	self:setNodeEventEnabled(true)

	self:initViews()
end

function PropProdListItem:initViews()
	-- body
	local itemBgSize = {
		width = PropProdItemPanelParam.WIDTH,
		height = 120
	}

	PropProdListItem.super.ctor(self, PropProdItemPanelParam.WIDTH, PropProdItemPanelParam.HEIGHT)

	self.bgItem_ = display.newScale9Sprite("#gstore_bgItem_nor.png", itemBgSize.width / 2, itemBgSize.height / 2, cc.size(itemBgSize.width, itemBgSize.height))
		:addTo(self)
	bm.TouchHelper.new(self.bgItem_, handler(self, self.onItemTouched_))
	self.bgItem_:setTouchSwallowEnabled(false)

	local iconBgSize = {
		width = 170,
		height = 85
	}

	local iconBgMagrins = {
		left = 2,
		bottom = 25
	}

	local blockRightSizeHFix = 0.5
	local itemRightBlockSize = {
		width = itemBgSize.width - iconBgSize.width - iconBgMagrins.left * 2,
		height = iconBgSize.height - blockRightSizeHFix * 2
	}

	local itemBlockRightPosShift = {
		x = 0,
		y = 8
	}

	local itemBlockRight = display.newScale9Sprite("#gstore_bgBlockItemRight.png", iconBgMagrins.left + iconBgSize.width + itemRightBlockSize.width / 2 + itemBlockRightPosShift.x,
		iconBgSize.height / 2 + iconBgMagrins.bottom + itemBlockRightPosShift.y, cc.size(itemRightBlockSize.width, itemRightBlockSize.height))
		:addTo(self)

	self.bgIcon_ = display.newScale9Sprite("#gstore_bgPropIcon_nor.png", iconBgSize.width / 2 + iconBgMagrins.left,
		iconBgSize.height / 2 + iconBgMagrins.bottom + itemBlockRightPosShift.y, cc.size(iconBgSize.width, iconBgSize.height))
		:addTo(self)

	local propIcon = display.newSprite("#gstore_icProp.png")
		:pos(iconBgSize.width / 2 + iconBgMagrins.left, iconBgSize.height / 2 + iconBgMagrins.bottom + itemBlockRightPosShift.y)
		:addTo(self)

	propIcon:scale(0.6)

	local nameLabelMagrins = {
		left = 5,
		top = 5
	}

	self.propName_ = display.newTTFLabel({text = "name * 20", size = PropProdItemPanelParam.frontSizes.name, color = PropProdItemPanelParam.colors.name, align = ui.TEXT_ALIGN_CENTER})
	self.propName_:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER_LEFT])
	self.propName_:pos(iconBgMagrins.left + iconBgSize.width + nameLabelMagrins.left, itemBgSize.height - nameLabelMagrins.top - self.propName_:getContentSize().height / 2)
		:addTo(self)

	local propDescShownWidth = 362
	local propDescMagrinTop = 5
	local propDesc = display.newTTFLabel({text = bm.LangUtil.getText("STORE", "PROPITEM_DESC"), size = PropProdItemPanelParam.frontSizes.desc, color = PropProdItemPanelParam.colors.desc,
		dimensions = cc.size(propDescShownWidth, 0), align = ui.TEXT_ALIGN_LEFT})
	propDesc:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER_LEFT])
	propDesc:pos(iconBgMagrins.left + iconBgSize.width + nameLabelMagrins.left,
		itemBgSize.height - nameLabelMagrins.top - self.propName_:getContentSize().height - propDescMagrinTop - propDesc:getContentSize().height / 2)
		:addTo(self)

	local priceLabelMagrinBottom = 5
	self.price_ = display.newTTFLabel({text = "$8888", size = PropProdItemPanelParam.frontSizes.price, color = PropProdItemPanelParam.colors.price, align = ui.TEXT_ALIGN_CENTER})
	self.price_:pos(itemBgSize.width / 2, self.price_:getContentSize().height / 2 + priceLabelMagrinBottom)
		:addTo(self)

end

function PropProdListItem:onDataSet(dataChanged, data)
	-- body

	-- dump(data, "PropProdListItem Data:================")
	if dataChanged then
		--todo
		local itemIdx = data.idx_
		local itemData = data.data_
		if itemData then
			--todo
			self.propPid = itemData.pnid
			self.propId = itemData.id

			self.propName_:setString(bm.LangUtil.getText("STORE", "PROP_PACK") .. itemData.num)

			self.price_:setString(itemData.money)

			if itemIdx == 1 then
				--todo
				local itemBgSize = {
					width = PropProdItemPanelParam.WIDTH,
					height = 120
				}

				local iconBgSize = {
					width = 170,
					height = 85
				}

				self.isPropSelected_ = true
				self.bgItem_:setSpriteFrame(display.newSpriteFrame("gstore_bgItem_sel.png"))
				self.bgItem_:setContentSize(itemBgSize.width, itemBgSize.height)
				self.bgItem_:setTouchSwallowEnabled(false)

				self.bgIcon_:setSpriteFrame(display.newSpriteFrame("gstore_bgPropIcon_sel.png"))
				self.bgIcon_:setContentSize(iconBgSize.width, iconBgSize.height)
			end
		end

	end
end

function PropProdListItem:onItemTouched_(target, evt)
	-- body
	if evt == bm.TouchHelper.CLICK then
		--todo
		if self.isPropSelected_ then
			--todo
			return
		end

		self.isPropSelected_ = true
		bm.EventCenter:dispatchEvent({name = nk.eventNames.STORE_PROP_SELECT_CHANG, data = self.propId})

	end
end

function PropProdListItem:checkPropSelectChanged(evt)
	-- body
	local itemBgSize = {
		width = PropProdItemPanelParam.WIDTH,
		height = 120
	}

	local iconBgSize = {
		width = 170,
		height = 85
	}

	if evt.data == self.propId then
		--todo
		self.bgItem_:setSpriteFrame(display.newSpriteFrame("gstore_bgItem_sel.png"))
		self.bgItem_:setContentSize(itemBgSize.width, itemBgSize.height)
		self.bgItem_:setTouchSwallowEnabled(false)

		self.bgIcon_:setSpriteFrame(display.newSpriteFrame("gstore_bgPropIcon_sel.png"))
		self.bgIcon_:setContentSize(iconBgSize.width, iconBgSize.height)
	else
		if self.isPropSelected_ then
			--todo
			self.bgItem_:setSpriteFrame(display.newSpriteFrame("gstore_bgItem_nor.png"))
			self.bgItem_:setContentSize(itemBgSize.width, itemBgSize.height)
			self.bgItem_:setTouchSwallowEnabled(false)

			self.bgIcon_:setSpriteFrame(display.newSpriteFrame("gstore_bgPropIcon_nor.png"))
			self.bgIcon_:setContentSize(iconBgSize.width, iconBgSize.height)
			
			self.isPropSelected_ = false
		end

	end
end

function PropProdListItem:onEnter()
	-- body
	bm.EventCenter:addEventListener(nk.eventNames.STORE_PROP_SELECT_CHANG, handler(self, self.checkPropSelectChanged))
end

function PropProdListItem:onExit()
	-- body
	bm.EventCenter:removeEventListenersByEvent(nk.eventNames.STORE_PROP_SELECT_CHANG)
end

function PropProdListItem:onCleanup()
	-- body
end

return PropProdListItem