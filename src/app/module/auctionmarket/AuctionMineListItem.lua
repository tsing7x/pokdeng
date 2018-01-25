
AuctionMineListItem = class("AuctionMineListItem",bm.ui.ListItem)

local ITEM_W = 863
local ITEM_H = 76


function AuctionMineListItem:ctor()
	AuctionMineListItem.super.ctor(self, ITEM_W, ITEM_H)
	cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
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


	self.curPriceBg_ = display.newSprite("#main/auctionStatusBg_1.png")
	:align(display.CENTER_LEFT)
	:pos( labelW * 3  + labelMarLeft,ITEM_H/2)
	:addTo(self)
	:hide()

	self.currentPriceLabel_ = display.newTTFLabel({text = "", size = 24, align = ui.TEXT_ALIGN_CENTER,color = cc.c3b(0xff,0xd3,0x00),dimensions = cc.size(labelW-3, ITEM_H)})
		:align(display.CENTER_LEFT)
		:pos( labelW * 3  + labelMarLeft,ITEM_H/2)
		:addTo(self)

	self.timeLabel_ = display.newTTFLabel({text = "", size = 24, align = ui.TEXT_ALIGN_CENTER,color = cc.c3b(0x67,0xd8,0x32),dimensions = cc.size(labelW-3, ITEM_H)})
		:align(display.CENTER_LEFT)
		:pos( labelW * 4  + labelMarLeft,ITEM_H/2)
		:addTo(self)


	self.bidderLabel_ = display.newTTFLabel({text = "", size = 24, align = ui.TEXT_ALIGN_CENTER,color = cc.c3b(0xff,0xd3,0x00),dimensions = cc.size(labelW-4, ITEM_H)})
		:align(display.CENTER_LEFT)
		:pos( labelW * 5  + labelMarLeft,ITEM_H/2)
		:addTo(self)

	self.auctionBtnBg_ = display.newSprite("#main/auctionBtn.png")
    local bgsize = self.auctionBtnBg_:getContentSize()
    self.auctionBtnBg_
    :align(display.CENTER_LEFT)
    :pos( labelW * 6  + labelMarLeft+ 2,ITEM_H/2)
    :addTo(self)
    self.auctionBtn_ = cc.ui.UIPushButton.new({normal="#transparent.png", pressed="#common_button_pressed_cover.png"}, {scale9=true})
    self.auctionBtn_:setButtonSize(bgsize.width - 4, bgsize.height - 4)
    self.auctionBtn_:align(display.CENTER_LEFT)
    self.auctionBtn_:onButtonClicked(handler(self,self.onAddAuctionBtn))
    self.auctionBtn_:pos( labelW * 6  + labelMarLeft+ 2 ,ITEM_H/2)
    self.auctionBtn_:setButtonLabel(display.newTTFLabel({text = "",size=24, color=cc.c3b(0xff, 0xff, 0xff), align=ui.TEXT_ALIGN_CENTER}))
	self.auctionBtn_:addTo(self)


end

function AuctionMineListItem:onAddAuctionBtn()
	-- 此处添加竞拍物品，弹框
	self:dispatchEvent({name="ITEM_EVENT", data = self.data_})
end

function AuctionMineListItem:onIconLoadComplete_(success, sprite)
    if success then
        local tex = sprite:getTexture()
        local texSize = tex:getContentSize()
        self.icon_:setTexture(tex)
        self.icon_:setTextureRect(cc.rect(0, 0, texSize.width, texSize.height))
        self.icon_:setScaleX(self.iconWidth / texSize.width)
        self.icon_:setScaleY(self.iconHeight / texSize.height)
    end
end


function AuctionMineListItem:onDataSet(dataChanged, data)

	self.data_ = data
	local isEmpty = data.isEmpty
	-- dump(data,"AuctionMineListItem:onDataSet")
	if isEmpty == 1 then
		--可添加拍卖商品
		-- self.auctionBtn_:show()
		if self.action_ then
        	self:stopAction(self.action_)
    	end
    	
		self.auctionBtn_:setButtonLabelString(bm.LangUtil.getText("AUCTION_MARKET","ADD"))
		self.auctionBtn_:setButtonEnabled(true)

		self.auctionBtnBg_:setSpriteFrame(display.newSpriteFrame("main/auctionBtn.png"))

		self.numLabel_:setString(bm.LangUtil.getText("AUCTION_MARKET","EMPTY"))
		-- self.auctorLabel_:setString(bm.LangUtil.getText("AUCTION_MARKET","EMPTY"))
		self.originalPriceLabel_:setString(bm.LangUtil.getText("AUCTION_MARKET","EMPTY"))
		self.currentPriceLabel_:setString(bm.LangUtil.getText("AUCTION_MARKET","EMPTY"))
		self.timeLabel_:setString(bm.LangUtil.getText("AUCTION_MARKET","EMPTY"))
		self.bidderLabel_:setString(bm.LangUtil.getText("AUCTION_MARKET","EMPTY"))
		self.curPriceBg_:hide()
		


  		local tex = cc.Director:getInstance():getTextureCache():addImage("aucMar_icProd.png")
  		-- local tex = display.newSprite("#aucMar_icProd.png"):getTexture()
		if tex then
			local texSize = tex:getContentSize()
        	self.icon_:setTexture(tex)
        	self.icon_:setTextureRect(cc.rect(0, 0, texSize.width, texSize.height))
        	self.icon_:setScaleX(self.iconWidth / texSize.width)
        	self.icon_:setScaleY(self.iconHeight / texSize.height)

		end

		
	else
		--不可添加拍卖商品
		-- self.auctionBtn_:hide()
		self.auctionBtn_:setButtonLabelString(bm.LangUtil.getText("AUCTION_MARKET","IS_AUCTIONING"))
		self.auctionBtn_:setButtonEnabled(false)

		self.auctionBtnBg_:setSpriteFrame(display.newSpriteFrame("main/auctionStatusBg_2.png"))
		self.numLabel_:setString(data.num)
		-- self.auctorLabel_:setString(data.nick)
		self.originalPriceLabel_:setString(bm.formatBigNumber(data.money))
	
		self.bidderLabel_:setString(data.aucter or "")

		if 2 == data.flag then
			self.currentPriceLabel_:setString(bm.LangUtil.getText("AUCTION_MARKET", "FIXED_PRICE")) 
			self.curPriceBg_:show()
		else
			self.curPriceBg_:hide()
			self.currentPriceLabel_:setString(bm.formatBigNumber(data.prentmoney))
		end
		
		
		nk.ImageLoader:loadAndCacheImage(
                self.iconLoaderId_, 
                data.imgurl or "", 
                handler(self, self.onIconLoadComplete_)
            )

		self.timeLabel_:setString("")
		local controller = self:getOwner().controller_
		if controller and controller["getNowTime"] then
			local nowTime = controller:getNowTime()
			if nowTime then
				local expire = data.expire
				local remainTime = expire - nowTime
				self.remainTime_ = remainTime
				self:showTime()
				self:countFun()
			end
		end

	end
	


end


function AuctionMineListItem:countFun()
	
	if self.action_ then
        self:stopAction(self.action_)
    end

	if self.remainTime_ > 0 then
		self.action_ = self:schedule(function ()
            self.remainTime_ = self.remainTime_ - 1
            self:showTime()
        end, 1)
    else
    	self.timeLabel_:setString(bm.LangUtil.getText("AUCTION_MARKET","EXPIRE_TIP"))  
	end
	  

end

function AuctionMineListItem:showTime() 
    timeStr = (self.remainTime_ > 0 and bm.TimeUtil:getTimeDayString(self.remainTime_)) or bm.LangUtil.getText("AUCTION_MARKET","EXPIRE_TIP")
    if self.timeLabel_ then
        self.timeLabel_:setString(timeStr)
    end
    
end

function AuctionMineListItem:onCleanup()
    nk.ImageLoader:cancelJobByLoaderId(self.iconLoaderId_)
end


return AuctionMineListItem