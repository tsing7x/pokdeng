--
-- Author: ThinkerWang
-- Date: 2015-12-04 16:20:50
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- 兑换实物商品的二次确认框

local WIDTH = 725
local HEIGHT = 475
local TOP_HEIGHT = 338
local LOAD_IMG_TAG = 999

local PIC_BG_WIDTH = 256
local PIC_BG_HEIGHT = 217
local ScoreAddressPopup = import(".ScoreAddressPopup")
local ExchangeGoodAddressPopup = class("ExchangeGoodAddressPopup",nk.ui.Panel)
local GetRealGoodsSuccessPopup = import(".GetRealGoodsSuccessPopup")

function ExchangeGoodAddressPopup:ctor(control,data)
	self.control_ = control
	self.data_ = data
	self:setTouchEnabled(true)
    self:setTouchSwallowEnabled(true)
    self:setNodeEventEnabled(true)
	self:createNode_()
end 

function ExchangeGoodAddressPopup:createNode_()
	display.newScale9Sprite("#sm_dialog_bg.png", 0, 0, cc.size(WIDTH,HEIGHT ))
    :pos(0,0)
    :addTo(self)
   
	display.newScale9Sprite("#sm_dialog_border.png", 0, 0, cc.size(WIDTH-40,TOP_HEIGHT ))
    :pos(0,10)
    :addTo(self)


     self.backBtn_ = cc.ui.UIPushButton.new({normal = "#sm_close2.png"})
        -- :setButtonSize(sz.width, sz.height)
        :onButtonClicked(function(evt)
            nk.SoundManager:playSound(nk.SoundManager.CLOSE_BUTTON)
            self:onClose();
        end)
        :onButtonPressed(function(evt)
            
        end)
        :onButtonRelease(function(evt)
  
        end)
        :pos(WIDTH/2-10, HEIGHT/2-12)
        :align(display.RIGHT_TOP)
        :addTo(self)

    display.newScale9Sprite("#socre_exchange_good_bg.png", 0, 0, cc.size(PIC_BG_WIDTH, PIC_BG_HEIGHT)):addTo(self)
	 :pos(-180,15)

	 display.newSprite("#score_good_back_flower.png")
	 :addTo(self)
	 :pos(-180,15)
	 :setScale(0.7)

	self.avatar_= display.newSprite("#common_transparent_skin.png")
   	:pos(-180,15)
    :addTo(self)


    local exchangeConDes = ""
    local priceData = self.data_.price
    if checkint(priceData)>0 then
        --金币兑换
        if self.data_.exchangeMethod == "chip" then
            exchangeConDes = bm.LangUtil.getText("SCOREMARKET","EXCHANGE_CONDITION_DESC_3",priceData)
         --现金币兑换
        elseif self.data_.exchangeMethod == "point" then
             exchangeConDes = bm.LangUtil.getText("SCOREMARKET","EXCHANGE_CONDITION_DESC",priceData)
        end

    else
        priceData = json.decode(priceData)
         --现金币＋筹码　
        if checkint(priceData.money) > 0  and checkint(priceData.point)>0 then
            exchangeConDes = bm.LangUtil.getText("SCOREMARKET","RECHANGENUM",priceData.point)
            exchangeConDes = exchangeConDes..bm.LangUtil.getText("SCOREMARKET","RECHANGE_CHIP",priceData.money)
          --现金币+兑换券
        elseif checkint(priceData.point) > 0 and checkint(priceData.ticket)> 0 then
            exchangeConDes = bm.LangUtil.getText("SCOREMARKET","RECHANGENUM",priceData.point)
            exchangeConDes = exchangeConDes..bm.LangUtil.getText("SCOREMARKET","RECHANGE_TICKET",priceData.ticket)
        end
    end


    
    --local price = bm.LangUtil.getText("SCOREMARKET","CONSUME_SCORE",self.data_.price)
    display.newTTFLabel({text = exchangeConDes, color = cc.c3b(0xf6,0xff,0x00), size = 22, align = ui.TEXT_ALIGN_LEFT})
    :addTo(self)
    --:align(display.LEFT_CENTER)
    :pos(-180,40 + PIC_BG_HEIGHT/2)

    display.newScale9Sprite("#score_good_word_bg.png", 0, 0, cc.size(PIC_BG_WIDTH-30, 42))
	 :addTo(self)
	 :pos(-180,-PIC_BG_HEIGHT/2-15)

	display.newTTFLabel({text = self.data_.giftname, color = cc.c3b(0xf6,0xff,0x00), size = 22, align = ui.TEXT_ALIGN_LEFT})
    :addTo(self)
    :pos(-180, -PIC_BG_HEIGHT/2-15)


    display.newSprite("#score_warring.png")
	 :addTo(self)
	 :pos(10,PIC_BG_HEIGHT/2)
	 
	display.newTTFLabel({text = bm.LangUtil.getText("SCOREMARKET","CONFIRM_ADDRESS_TIP"), color = cc.c3b(0xff,0xff,0xff), size = 20, align = ui.TEXT_ALIGN_LEFT})
    :addTo(self)
    :align(display.LEFT_CENTER)
    :pos(30,PIC_BG_HEIGHT/2)

    local lbls = {
        bm.LangUtil.getText("SCOREMARKET", "USER_NAME").." :",
        bm.LangUtil.getText("SCOREMARKET", "MOBEL_TEL").." :",
        bm.LangUtil.getText("SCOREMARKET", "DETAIL_ADDRESS").." :",
        "",
        bm.LangUtil.getText("SCOREMARKET", "EMAIL").." :"
    };

    local txtWidth = 100
    for i=1,5 do
    	display.newTTFLabel({text = lbls[i], color = cc.c3b(0xff,0xff,0xff), size = 20, align = ui.TEXT_ALIGN_RIGHT,
        dimensions=cc.size(txtWidth,0)})
	    :addTo(self)
	    :align(display.RIGHT_CENTER)
	    :pos(80,PIC_BG_HEIGHT/2 - i*35 - 10)
    end

    self.myName_ = display.newTTFLabel({text = "", color = cc.c3b(0xff,0xff,0xff), size = 20, align = ui.TEXT_ALIGN_LEFT})
    :addTo(self)
    :align(display.LEFT_CENTER)
	:pos(txtWidth,PIC_BG_HEIGHT/2 - 45)	

	self.myPhone_ = display.newTTFLabel({text = "", color = cc.c3b(0xff,0xff,0xff), size = 20, align = ui.TEXT_ALIGN_LEFT})
    :addTo(self)
    :align(display.LEFT_CENTER)
	:pos(txtWidth,PIC_BG_HEIGHT/2 - 2*35 - 10)	

	self.myAddress_ = display.newTTFLabel({text = "", color = cc.c3b(0xff,0xff,0xff), size = 20, align = ui.TEXT_ALIGN_LEFT,dimensions=cc.size(240,68)})
    :addTo(self)
    :align(display.LEFT_CENTER)
	:pos(txtWidth,PIC_BG_HEIGHT/2 - 3*35 - 20)

	self.myEmail_ = display.newTTFLabel({text = "", color = cc.c3b(0xff,0xff,0xff), size = 20, align = ui.TEXT_ALIGN_LEFT})
    :addTo(self)
    :align(display.LEFT_CENTER)
	:pos(txtWidth,PIC_BG_HEIGHT/2 - 5*35 - 10)

	display.newScale9Sprite("#score_words_line.png",0, 0, cc.size(120, 2))
	 :addTo(self)
	 :pos(200,PIC_BG_HEIGHT/2 - 6*35 - 35)

	cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png"},{scale9 = true})
	:setButtonSize(120,25)
    :setButtonLabel("normal", display.newTTFLabel({text = bm.LangUtil.getText("SCOREMARKET", "MODIFY_INFO") , color = cc.c3b(0x3d, 0xab, 0xff), size = 20, align = ui.TEXT_ALIGN_CENTER}))
    :addTo(self)
    :pos(200,PIC_BG_HEIGHT/2 - 6*35 - 25)
    :onButtonClicked(function() 
    	ScoreAddressPopup.new(self.control_):showPanel()
    	self:onClose()
    end)


    display.newScale9Sprite("#score_green_btn.png",0, 0, cc.size(168, 50))
	 :addTo(self)
	 :pos(0,-HEIGHT/2 + 40)

	self.exchangeTxt_ = display.newTTFLabel({text = bm.LangUtil.getText("SCOREMARKET", "EXCHANGE"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 20, align = ui.TEXT_ALIGN_CENTER})
 	cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#rounded_rect_10.png"}, {scale9 = true})
    :setButtonSize(168, 45)
    :addTo(self)
    :setButtonLabel("normal", self.exchangeTxt_)
    :onButtonClicked(buttontHandler(self, self.onExchange))
    :pos(0,-HEIGHT/2 + 40)
end
function ExchangeGoodAddressPopup:show()
	self:showPanel_()
end

function ExchangeGoodAddressPopup:onShowed()
	 self.userAvatarLoaderId_ = nk.ImageLoader:nextLoaderId() -- 头像加载id

     nk.ImageLoader:loadAndCacheImage(
                    self.userAvatarLoaderId_, 
                    self.data_.imgurl, 
                    handler(self, self.onAvatarLoadComplete_), 
                    nk.ImageLoader.CACHE_TYPE_USER_HEAD_IMG
                )

    self.requestUserAddress_ = nk.http.getUserAddress(
		function(data)
            self.addressData_ = data
			-- self.savedCity_ = data.city
        	self.myEmail_:setString(data.mail or ""); -- self.emailEdit_:setPlaceHolder(bm.LangUtil.getText("SCOREMARKET", "EMAIL"));
	        self.myName_:setString(data.name or "");
	        self.myPhone_:setString(data.tel or "");
            local city = ""
            if data.city then
                city = data.city
            end
            local address = ""
            if data.address then
                address = data.address
            end
	        self.myAddress_:setString(city..address);
		end,
		function(error)

		end
	)
end
function ExchangeGoodAddressPopup:onAvatarLoadComplete_(success, sprite)
    if success then
        local tex = sprite:getTexture()
        local texSize = tex:getContentSize()
        local xxScale = 120/texSize.width
        local yyScale = 106/texSize.height
        sprite:scale(xxScale<yyScale and xxScale or yyScale)
        :addTo(self.avatar_,0,LOAD_IMG_TAG)
    end
end
function ExchangeGoodAddressPopup:onExchange()
	--GetRealGoodsSuccessPopup.new(self.data_):show()


    if not self.addressData_ then
        ScoreAddressPopup.new(self.control_):showPanel()
        self:onClose()
        return
    end

    if self.addressData_  then
        if not self.addressData_.mail or not self.addressData_.name or not self.addressData_.tel or not self.addressData_.address then
            ScoreAddressPopup.new(self.control_):showPanel()
            self:onClose()
            return
        end
    end
	self.control_:buyGood(self.data_,
		function(data)
			GetRealGoodsSuccessPopup.new(self.data_):show()
			self:onClose()
		end
	)
end
function ExchangeGoodAddressPopup:onCleanup()
	nk.http.cancel(self.requestUserAddress_)
end


return ExchangeGoodAddressPopup