local ComponItemParam = {
	WIDTH = 122,
	HEIGHT = 108,

	frontSizes = {
		name = 18,
		price = 20,
		deadDay = 20
	},

	colors = {
		name = {
			nor = cc.c3b(100, 129, 162),
			sel = display.COLOR_WHITE
		},

		price = styles.FONT_COLOR.GOLDEN_TEXT,
		deadDay = cc.c3b(141, 141, 141)
	}
}

local GiftProdComponItem = class("GiftProdComponItem", function()
	-- body
	return display.newNode()
end)

function GiftProdComponItem:ctor(componData)
	-- body
	self:setTouchEnabled(true)
	self:setTouchSwallowEnabled(false)

	self:setNodeEventEnabled(true)

	-- self.data_ = componData.data_
	-- self.idx_ = componData.idx_
	if componData.data_ then
		--todo
		self.pid = tonumber(componData.data_.pnid)
		self.imgUrl = componData.data_.image
		self.money = componData.data_.money

		self.deadDay = componData.data_.expire
		self.name = componData.data_.name

		local bgItemPosYShift = 10
		if componData.idx_ == 1 then
			--todo
			self.isGiftSelected_ = true

			self.bgItem_ = display.newSprite("#gstore_bgItem_sel.png")
				:pos(ComponItemParam.WIDTH / 2, ComponItemParam.HEIGHT / 2 + bgItemPosYShift)
				:addTo(self)
		else
			self.bgItem_ = display.newSprite("#gstore_bgItem_nor.png")
				:pos(ComponItemParam.WIDTH / 2, ComponItemParam.HEIGHT / 2 + bgItemPosYShift)
				:addTo(self)
		end

		bm.TouchHelper.new(self.bgItem_, handler(self, self.onItemTouched_))
		self.bgItem_:setTouchSwallowEnabled(false)

		local giftIconPosYShift = 15

		self.giftImageLoaderId_ = nk.ImageLoader:nextLoaderId()
		self.giftIcon_ = display.newSprite("#chip_icon.png")
			:pos(self.bgItem_:getContentSize().width / 2, self.bgItem_:getContentSize().height / 2 + giftIconPosYShift)
			:addTo(self.bgItem_)

		local giftNameMagrinBottom = 2
		self.giftName_ = display.newTTFLabel({text = self.name, size = ComponItemParam.frontSizes.name, color = ComponItemParam.colors.name.nor, align = ui.TEXT_ALIGN_CENTER})
		self.giftName_:pos(self.bgItem_:getContentSize().width / 2, giftNameMagrinBottom + self.giftName_:getContentSize().height / 2)
			:addTo(self.bgItem_)

		local priceLabelMagrinLeft = 10
		local priceLabel = display.newTTFLabel({text = self.money, size = ComponItemParam.frontSizes.price, color = ComponItemParam.colors.price, align = ui.TEXT_ALIGN_CENTER})
		-- priceLabel:setAnchorPoint(display.ANCHOR_POINTS[display.LEFT_CENTER])
		priceLabel:pos(priceLabel:getContentSize().width / 2 + priceLabelMagrinLeft, priceLabel:getContentSize().height / 2)
			:addTo(self)

		local deadDaysMagrinLeft = 5
		local deadDays = display.newTTFLabel({text = "(" .. self.deadDay .. bm.LangUtil.getText("GIFT", "DATA_LABEL") .. ")", size = ComponItemParam.frontSizes.deadDay, 
			color = ComponItemParam.colors.deadDay, align = ui.TEXT_ALIGN_CENTER})
		deadDays:pos(priceLabelMagrinLeft + priceLabel:getContentSize().width + deadDaysMagrinLeft + deadDays:getContentSize().width / 2,
			deadDays:getContentSize().height / 2)
			:addTo(self)

		nk.ImageLoader:loadAndCacheImage(self.giftImageLoaderId_, self.imgUrl, handler(self, self.onGiftImgDownLoadComlete_), 
		             	nk.ImageLoader.CACHE_TYPE_GIFT)
	end
end

function GiftProdComponItem:onGiftImgDownLoadComlete_(success, sprite)
	-- body
	local giftShownSize = {
		width = 45,
		height = 45
	}
	if success then
		--todo
		local texture = sprite:getTexture()
		local texSize = texture:getContentSize()

		self.giftIcon_:setTexture(texture)
		self.giftIcon_:setTextureRect(cc.rect(0, 0, texSize.width, texSize.height))
        self.giftIcon_:setScaleX(giftShownSize.width / texSize.width)
        self.giftIcon_:setScaleY(giftShownSize.height / texSize.height)
		
	else
		dump("_onGiftImgDownLoadComlete wrong!")
	end
end

function GiftProdComponItem:onItemTouched_(target, evt)
	-- body
	if evt == bm.TouchHelper.CLICK then
		--todo
		if self.isGiftSelected_ then
			--todo
			return
		end

		self.isGiftSelected_ = true
		bm.EventCenter:dispatchEvent({name = nk.eventNames.STORE_GIFT_SELECT_CHANG, data = self.pid})

	end
end

function GiftProdComponItem:checkGiftSelectChanged(evt)
	-- body
	if evt.data == self.pid then
		--todo
		self.bgItem_:setSpriteFrame(display.newSpriteFrame("gstore_bgItem_sel.png"))
		-- 修改字体颜色
		self.giftName_:setTextColor(ComponItemParam.colors.name.sel)
	else
		if self.isGiftSelected_ then
			--todo
			self.bgItem_:setSpriteFrame(display.newSpriteFrame("gstore_bgItem_nor.png"))
			self.giftName_:setTextColor(ComponItemParam.colors.name.nor)
			self.isGiftSelected_ = false
		end

	end

end

function GiftProdComponItem:onEnter()
	-- body
	bm.EventCenter:addEventListener(nk.eventNames.STORE_GIFT_SELECT_CHANG, handler(self, self.checkGiftSelectChanged))
end

function GiftProdComponItem:onExit()
	-- body
	if self.giftImageLoaderId_ then
		--todo
		nk.ImageLoader:cancelJobByLoaderId(self.giftImageLoaderId_)
	end

	bm.EventCenter:removeEventListenersByEvent(nk.eventNames.STORE_GIFT_SELECT_CHANG)
end

function GiftProdComponItem:onCleanup()
	-- body
end

return GiftProdComponItem