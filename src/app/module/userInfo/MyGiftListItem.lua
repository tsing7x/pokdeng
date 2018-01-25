--
-- Author: TsingZhang@boyaa.com
-- Date: 2015-11-13 09:57:32
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- Description: MyGiftListItem By Tsing.
--
local MyGiftItemParam = {
	WIDTH = 115,
	HEIGHT = 95,

	descLabelColor = {
		nor = cc.c3b(88, 112, 141),
		sel = display.COLOR_WHITE
	}
}

local LoadGiftController = import("app.module.gift.LoadGiftControl")

local MyGiftListItem = class("MyGiftListItem", bm.ui.ListItem)

function MyGiftListItem:ctor()
	-- body
	-- cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
	self:setNodeEventEnabled(true)

	MyGiftListItem.super.ctor(self, MyGiftItemParam.WIDTH, MyGiftItemParam.HEIGHT)
	
	-- self:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self._onItemTouched))

	self.giftImageLoaderId_ = nk.ImageLoader:nextLoaderId()
	self:initViews()
end

function MyGiftListItem:initViews()
	-- body
	local itemMagrinEach = 14

	local itemDescLabelParam = {
		frontSizes = {
			deadDays = 15,
			desc = 18
		},

		colors = {
			deadDays = cc.c3b(125, 125, 126),
			desc = cc.c3b(88, 112, 141)
		}
}

	self._itemBg = display.newSprite("#userInfo_bagItemGift_nor.png")
	self._itemBg:pos(itemMagrinEach / 2 + self._itemBg:getContentSize().width / 2, self._itemBg:getContentSize().height / 2)
		:addTo(self)
	bm.TouchHelper.new(self._itemBg, handler(self, self._onItemTouched))
	self._itemBg:setTouchSwallowEnabled(false)
	
	local deadDaysLabelPaddingBottom = 25
	self._itemDeadDays = display.newTTFLabel({text = "0 days", size = itemDescLabelParam.frontSizes.deadDays,
		color = itemDescLabelParam.colors.deadDays, align = ui.TEXT_ALIGN_CENTER})
	self._itemDeadDays:pos(self._itemBg:getContentSize().width / 2, deadDaysLabelPaddingBottom + self._itemDeadDays:getContentSize().height / 2)
		:addTo(self._itemBg)

	local descLabelPaddingBottom = 5
	self._itemDesc = display.newTTFLabel({text = "item", size = itemDescLabelParam.frontSizes.desc, color = itemDescLabelParam.colors.desc, align = ui.TEXT_ALIGN_CENTER})
	self._itemDesc:pos(self._itemBg:getContentSize().width / 2, descLabelPaddingBottom + self._itemDesc:getContentSize().height / 2)
		:addTo(self._itemBg)

	local itemIconPosYShift = 18
	self._itemIcon = display.newSprite("#userInfo_coinChip.png")
		:pos(self._itemBg:getContentSize().width / 2, self._itemBg:getContentSize().height / 2 + itemIconPosYShift)
		:addTo(self._itemBg)

	self._giftItemSelect = nil
end

function MyGiftListItem:_onItemTouched(target, evt)
	-- body

	if evt == bm.TouchHelper.CLICK then
		--todo
		self._giftItemSelect = true
		if self._giftPid ~= nk.userData["aUser.gift"] then
			--todo
			nk.userData["aUser.gift"] = self._giftPid
			bm.EventCenter:dispatchEvent({name = nk.eventNames.USERINFO_GIFT_WARE, data = self._giftPid})

		end

	end

end

function MyGiftListItem:checkGiftWare(evt)
	-- body
	-- dump(data, "MyGiftListItem:checkGiftWare :=====================")

	if evt.data == self._giftPid then
		--todo
		self._itemBg:setSpriteFrame(display.newSpriteFrame("userInfo_bagItemGift_sel.png"))
		-- 修改字体颜色
		self._itemDesc:setTextColor(MyGiftItemParam.descLabelColor.sel)
	else
		if self._giftItemSelect then
			--todo
			self._itemBg:setSpriteFrame(display.newSpriteFrame("userInfo_bagItemGift_nor.png"))
			self._itemDesc:setTextColor(MyGiftItemParam.descLabelColor.nor)
			self._giftItemSelect = false
		end

	end

end

function MyGiftListItem:onDataSet(dataChanged, data)
	-- body

	-- dump(data, "data :===================")
	if dataChanged then
		--todo

		bm.EventCenter:addEventListener(nk.eventNames.USERINFO_GIFT_WARE, handler(self, self.checkGiftWare))
		if data._giftId then
			--todo
			self._giftPid = tonumber(data._giftId)
			local deadTime = data._giftDeadTime

			self.getGiftUrlId_ = LoadGiftController:getInstance():getGiftUrlById(self._giftPid, handler(self, self._onGiftUrlGetCallBack))
			self.getGiftNameId_ = LoadGiftController:getInstance():getGiftNameById(self._giftPid, handler(self, self._onGiftNameGetCallBack))

			self._itemDeadDays:setString(tostring(deadTime) .. bm.LangUtil.getText("GIFT", "DATA_LABEL"))

			if self._giftPid == nk.userData["aUser.gift"] then
				--todo
				self._giftItemSelect = true
				self._itemBg:setSpriteFrame(display.newSpriteFrame("userInfo_bagItemGift_sel.png"))
				self._itemDesc:setTextColor(MyGiftItemParam.descLabelColor.sel)
			else

				if self._giftItemSelect then
					--todo
					self._giftItemSelect = false
					self._itemBg:setSpriteFrame(display.newSpriteFrame("userInfo_bagItemGift_nor.png"))
					self._itemDesc:setTextColor(MyGiftItemParam.descLabelColor.nor)
				end
				
				
			end
		end

	end
end

function MyGiftListItem:_onGiftUrlGetCallBack(imageUrl)
	-- body
	if imageUrl ~= nil and imageUrl ~= "" then
		--todo
		self._giftImgUrl = imageUrl
		nk.ImageLoader:loadAndCacheImage(self.giftImageLoaderId_, imageUrl, handler(self, self._onGiftImgDownLoadComlete), 
	             	nk.ImageLoader.CACHE_TYPE_GIFT)
	else
		dump("Get giftUrl Wrong!")
	end
end

function MyGiftListItem:_onGiftNameGetCallBack(giftName)
	-- body
	self._itemDesc:setString(giftName)
end

function MyGiftListItem:_onGiftImgDownLoadComlete(success, sprite)
	-- body
	local giftShownSize = {
		width = 48,
		height = 48
	}
	if success then
		--todo
		local texture = sprite:getTexture()
		local texSize = texture:getContentSize()

		self._itemIcon:setTexture(texture)
		self._itemIcon:setTextureRect(cc.rect(0, 0, texSize.width, texSize.height))
        self._itemIcon:setScaleX(giftShownSize.width / texSize.width)
        self._itemIcon:setScaleY(giftShownSize.height / texSize.height)
		
	else
		dump("_onGiftImgDownLoadComlete wrong!")
	end
end

function MyGiftListItem:onEnter()
	-- body
	bm.EventCenter:addEventListener(nk.eventNames.USERINFO_GIFT_WARE, handler(self, self.checkGiftWare))
end

function MyGiftListItem:onExit()
	-- body
	if self.giftImageLoaderId_ then
		--todo
		nk.ImageLoader:cancelJobByLoaderId(self.giftImageLoaderId_)

		self.giftImageLoaderId_ = nil
	end

	if self.getGiftUrlId_ then
		--todo
		LoadGiftController:getInstance():cancel(self.getGiftUrlId_)
	end

	if self.getGiftNameId_ then
		--todo
		LoadGiftController:getInstance():cancel(self.getGiftNameId_)
	end
	
	bm.EventCenter:removeEventListenersByEvent(nk.eventNames.USERINFO_GIFT_WARE)
end

function MyGiftListItem:onCleanup()
	-- body
	
end

return MyGiftListItem