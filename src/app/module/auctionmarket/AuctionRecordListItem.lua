
AuctionRecordListItem = class("AuctionRecordListItem",bm.ui.ListItem)

local ITEM_W = 863
local ITEM_H = 76


function AuctionRecordListItem:ctor()
	AuctionRecordListItem.super.ctor(self, ITEM_W, ITEM_H)
	self:setNodeEventEnabled(true)
	local bg = display.newSprite("#aucMar_bgListItem.png")
	:pos(ITEM_W/2,ITEM_H/2)
	:addTo(self)


	-- 商品图片
	local labelMarLeft,labelMarRight = 8,8
 	local labelCount = 7
 	local labelW = (ITEM_W - labelMarLeft - labelMarRight) / labelCount

 	self.iconWidth, self.iconHeight = 57, 57
	self.iconLoaderId_ = nk.ImageLoader:nextLoaderId() -- 头像加载id
	self.icon_ = display.newSprite("#aucMar_icProd.png")
    local iconSize = self.icon_:getContentSize()
    self.icon_:scale(self.iconWidth / iconSize.width)
        :align(display.CENTER_LEFT)
        :pos(labelMarLeft*5, ITEM_H/2)
        :addTo(self)

    self.numLabel_ = display.newTTFLabel({text = "", size = 24, align = ui.TEXT_ALIGN_CENTER,color = cc.c3b(0xff,0xd3,0x00),dimensions = cc.size(labelW-3, ITEM_H)})
		:align(display.CENTER_LEFT)
		:pos( labelW  + labelMarLeft,ITEM_H/2)
		:addTo(self)


	-- self.auctorLabel_ = display.newTTFLabel({text = "", size = 24, align = ui.TEXT_ALIGN_CENTER,color = cc.c3b(0xff,0xd3,0x00),dimensions = cc.size(labelW-3, 0)})
	-- 	:align(display.CENTER_LEFT)
	-- 	:pos( labelW * 2  + labelMarLeft,ITEM_H/2)
	-- 	:addTo(self)



	self.originalPriceLabel_ = display.newTTFLabel({text = "", size = 24, align = ui.TEXT_ALIGN_CENTER,color = cc.c3b(0xff,0xd3,0x00),dimensions = cc.size(labelW-3, ITEM_H)})
		:align(display.CENTER_LEFT)
		:pos( labelW * 2  + labelMarLeft,ITEM_H/2)
		:addTo(self)

	self.currentPriceLabel_ = display.newTTFLabel({text = "", size = 24, align = ui.TEXT_ALIGN_CENTER,color = cc.c3b(0xff,0xd3,0x00),dimensions = cc.size(labelW-3, ITEM_H)})
		:align(display.CENTER_LEFT)
		:pos( labelW * 3  + labelMarLeft,ITEM_H/2)
		:addTo(self)

	self.timeLabel_ = display.newTTFLabel({text = "", size = 24, align = ui.TEXT_ALIGN_CENTER,color = cc.c3b(0x67,0xd8,0x32),dimensions = cc.size(labelW-3, ITEM_H)})
		:align(display.CENTER_LEFT)
		:pos( labelW * 4  + labelMarLeft,ITEM_H/2)
		:addTo(self)


	self.bidderLabel_ = display.newTTFLabel({text = "", size = 24, align = ui.TEXT_ALIGN_CENTER,color = cc.c3b(0xff,0xd3,0x00),dimensions = cc.size(labelW-12, ITEM_H)})
		:align(display.CENTER_LEFT)
		:pos( labelW * 5  + labelMarLeft,ITEM_H/2)
		:addTo(self)

	self.auctionBtnBg_ = display.newSprite("#main/auctionStatusBg_1.png")
    local bgsize = self.auctionBtnBg_:getContentSize()
    self.auctionBtnBg_
    :align(display.CENTER_LEFT)
    :pos( labelW * 6  + labelMarLeft+ 2,ITEM_H/2)
    :addTo(self)
    self.auctionStateLabel_ = display.newTTFLabel({text = "", size = 24, align = ui.TEXT_ALIGN_CENTER,color = cc.c3b(0xff,0xff,0xff),dimensions = cc.size(bgsize.width, bgsize.height)})
	:align(display.CENTER_LEFT)
	 :pos( labelW * 6  + labelMarLeft+ 2,ITEM_H/2)
	:addTo(self)


end


function AuctionRecordListItem:onIconLoadComplete_(success, sprite)
    if success then
        local tex = sprite:getTexture()
        local texSize = tex:getContentSize()
        self.icon_:setTexture(tex)
        self.icon_:setTextureRect(cc.rect(0, 0, texSize.width, texSize.height))
        self.icon_:setScaleX(self.iconWidth / texSize.width)
        self.icon_:setScaleY(self.iconHeight / texSize.height)
    end
end



--[[
 name : ชิปเงินสด//物品名称
                    num  : 3//数量
                    adder: piao  po de ye//物品添加人
                    money: 500//低价
                    flag : 1//1 普通拍卖 2 一口价
                    aucter:deviceModel //竞拍人
                    success:1成功与否 0失败 1成功
--]]
function AuctionRecordListItem:onDataSet(dataChanged, data)
	self.numLabel_:setString(data.num)
	self.originalPriceLabel_:setString(bm.formatBigNumber(data.money))
	-- self.auctorLabel_:setString(data.adder)
	self.bidderLabel_:setString(data.aucter or "")
	self.timeLabel_:setString(bm.LangUtil.getText("AUCTION_MARKET","OVER_TIP"))

	if 1 == tonumber(data.flag) then
		self.currentPriceLabel_:setString(bm.LangUtil.getText("AUCTION_MARKET","TYPE_NORMAL"))
	elseif 2 == tonumber(data.flag) then
		self.currentPriceLabel_:setString(bm.LangUtil.getText("AUCTION_MARKET","TYPE_FIX_PRICE"))
	else

	end

	if 1 == tonumber(data.success) then
		if 1 == tonumber(data.aflag) then
			self.auctionStateLabel_:setString(bm.LangUtil.getText("AUCTION_MARKET","STATE_SUCC_FOR_AUCTION"))
		elseif 2 == tonumber(data.aflag) then
			self.auctionStateLabel_:setString(bm.LangUtil.getText("AUCTION_MARKET","STATE_SUCC"))
		end
		
		self.auctionBtnBg_:setSpriteFrame(display.newSpriteFrame("main/auctionStatusBg_1.png"))
	else
		if 1 == tonumber(data.aflag) then
			self.auctionStateLabel_:setString(bm.LangUtil.getText("AUCTION_MARKET","STATE_FAIL_FOR_AUCTION"))
		elseif 2 == tonumber(data.aflag) then
			self.auctionStateLabel_:setString(bm.LangUtil.getText("AUCTION_MARKET","STATE_FAIL"))
		end

		self.auctionBtnBg_:setSpriteFrame(display.newSpriteFrame("main/auctionStatusBg_2.png"))
	end

	nk.ImageLoader:loadAndCacheImage(
                self.iconLoaderId_, 
                data.imgurl or "", 
                handler(self, self.onIconLoadComplete_)
            )
end

function AuctionRecordListItem:onCleanup()
    nk.ImageLoader:cancelJobByLoaderId(self.iconLoaderId_)
end


return AuctionRecordListItem