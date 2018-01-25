--
-- Author: TsingZhang@boyaa.com
-- Date: 2016-01-19 15:40:06
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- Description: AuctSellProdChooseItem By tsing.
--

local AuctSellProdChooseItem = class("AuctSellProdChooseItem", bm.ui.ListItem)

function AuctSellProdChooseItem:ctor()
	-- body
	local itemSize = {
		width = 382,
		height = 52
	}

	cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
	AuctSellProdChooseItem.super.ctor(self, itemSize.width, itemSize.height)
	self:setNodeEventEnabled(true) -- 框架直接执行 onCleanup

	-- 目前暂时使用这个背景当做Item的Bg,等待后面的UI调整
	local bgSizeHFix = 0.5

	local itemBg = display.newScale9Sprite("#aucMar_bgProdNameItem.png", itemSize.width / 2, itemSize.height / 2,
		cc.size(itemSize.width, itemSize.height - bgSizeHFix * 2))
		:addTo(self)

	-- 等待需求确定后调整！
	local itemNameLabelParam = {
		frontSize = 24,
		color = display.COLOR_WHITE
	}
	local itemNameMagrinLeft = 20
	self.itemName_ = display.newTTFLabel({text = "name", size = itemNameLabelParam.frontSize, color = itemNameLabelParam.color,
		align = ui.TEXT_ALIGN_CENTER})
	self.itemName_:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER_LEFT])
	self.itemName_:pos(itemNameMagrinLeft, itemSize.height / 2)
		:addTo(itemBg)

	local selectBtn = cc.ui.UIPushButton.new("#common_transparent_skin.png", {scale9 = true})
		:setButtonSize(itemSize.width, itemSize.height)
		:onButtonClicked(buttontHandler(self, self.onItemChooseCallBack_))
		:pos(itemSize.width / 2, itemSize.height / 2)
		:addTo(self)

	selectBtn:setTouchSwallowEnabled(false)
end

function AuctSellProdChooseItem:onDataSet(isChanged, data)
	-- body
	self.data_ = data

	if isChanged then
		--todo
		self.itemName_:setString(self.data_.title)
	end
end

function AuctSellProdChooseItem:onItemChooseCallBack_()
	-- body
	self:dispatchEvent({name = "ITEM_EVENT", type = "DROPDOWN_LIST_SELECT", data = self.data_})
end

return AuctSellProdChooseItem