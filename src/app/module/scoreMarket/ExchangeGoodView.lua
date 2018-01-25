
local CENTER_CONTENT_BG_WIDHT = 704
local CENTER_CONTENT_BG_HEIGHT = 480

local BG_WIDTH = 722
local BG_HEIGHT = 382

local PIC_BG_WIDTH = 256
local PIC_BG_HEIGHT = 217

local TITLE_BG_WIDTH = 280

local LOAD_IMG_TAG = 999
local ExchangeGoodAddressPopup = import(".ExchangeGoodAddressPopup")
local ExchangeGoodView = class("ExchangeGoodView", function()
    return display.newNode();
end)
function ExchangeGoodView:ctor(control,data)
	self.data_ = data
	self.control_ = control
	self:setTouchEnabled(true)
    self:setTouchSwallowEnabled(true)
    self:setNodeEventEnabled(true)
	self:createNode_()
end
function ExchangeGoodView:createNode_()
	-- body
	-- display.newScale9Sprite("#score_content_bg.png",0, 0, cc.size(CENTER_CONTENT_BG_WIDHT,CENTER_CONTENT_BG_HEIGHT ))
	-- :addTo(self)
	-- :pos(display.cx+100,display.cy-70)
	 display.newScale9Sprite("#score_exchange_bg.png", 0, 0, cc.size(BG_WIDTH, BG_HEIGHT)):addTo(self)
	 :pos(display.cx+100,display.cy-50)--

	 display.newScale9Sprite("#socre_exchange_good_bg.png", 0, 0, cc.size(PIC_BG_WIDTH, PIC_BG_HEIGHT)):addTo(self)
	 :pos(display.cx-60,display.cy-30)

	 display.newSprite("#score_good_back_flower.png")
	 :addTo(self)
	 :pos(display.cx-60,display.cy-30)
	 :setScale(0.7)

	self.avatar_= display.newSprite("#common_transparent_skin.png")
    :pos(display.cx-60,display.cy-30)
    :addTo(self)

    self.userAvatarLoaderId_ = nk.ImageLoader:nextLoaderId() -- 头像加载id



	 display.newScale9Sprite("#score_words_rect_bg.png", 0, 0, cc.size(TITLE_BG_WIDTH, 41)):addTo(self)
	 :pos(display.cx+TITLE_BG_WIDTH/2 + 110,display.cy+85)

	display.newTTFLabel({text = ""..self.data_.giftname, color = cc.c3b(0x7f,0xe0,0x44), size = 28,dimensions = cc.size(TITLE_BG_WIDTH - 10, 40), align = ui.TEXT_ALIGN_CENTER})
    :addTo(self)
    :pos(display.cx+TITLE_BG_WIDTH/2 + 110,display.cy+85)

   --local desc_str = "i am a good boy !! \ni am a good boy !! \ni am a good boy !!"

    display.newTTFLabel({text = self.data_.desc, color = cc.c3b(0xff,0xf1,0x93), size = 22,dimensions = cc.size(300, 120), align = ui.TEXT_ALIGN_LEFT})
    :addTo(self)
    :align(display.TOP_LEFT)
    :pos(display.cx + 120,display.cy+50)

    local tempWidth = 260
	 display.newScale9Sprite("#score_words_rect_bg.png", 0, 0, cc.size(tempWidth, 41)):addTo(self)
	 :pos(display.cx+tempWidth/2 + 110,display.cy-90)

	 --兑换条件
	 display.newTTFLabel({text = bm.LangUtil.getText("SCOREMARKET","EXCHANGE_CONDITION"), color = cc.c3b(0x7f,0xe0,0x44), size = 28,dimensions = cc.size(tempWidth - 10, 40), align = ui.TEXT_ALIGN_CENTER})
    :addTo(self)
    :pos(display.cx+tempWidth/2 + 110,display.cy-90)

    -- local exchangeConDes = bm.LangUtil.getText("SCOREMARKET","EXCHANGE_CONDITION_DESC",self.data_.price)
    -- if self.data_ and self.data_.category == 3 then
    --     exchangeConDes = bm.LangUtil.getText("SCOREMARKET","EXCHANGE_CONDITION_DESC_2",self.data_.price)
    -- end
    -- if self.data_ and self.data_.exchangeMethod == "chip" then
    --     exchangeConDes = bm.LangUtil.getText("SCOREMARKET","EXCHANGE_CONDITION_DESC_3",self.data_.price)
    -- end

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
    local needCoin = exchangeConDes
    display.newTTFLabel({text = ""..needCoin, color = cc.c3b(0xff,0xf1,0x93), size = 22, align = ui.TEXT_ALIGN_LEFT})
    :addTo(self)
    :align(display.LEFT_CENTER)
    :pos(display.cx + 120,display.cy-140)

    local leftNum = bm.LangUtil.getText("SCOREMARKET","EXCHANGE_LEFT_CNT",self.data_.num)
    display.newTTFLabel({text = leftNum, color = cc.c3b(0x99,0x8f,0x9a), size = 22, align = ui.TEXT_ALIGN_LEFT})
    :addTo(self)
    :align(display.LEFT_CENTER)
    :pos(display.cx + 120,display.cy-170)
	 
	 local EX_BT_WIDHT = 210
	 local EX_BT_HEIGHT = 59
     --
	 display.newScale9Sprite("#score_exchange_bt.png", 0, 0, cc.size(EX_BT_WIDHT, EX_BT_HEIGHT)):addTo(self)
	 :pos(display.cx + 110,display.cy-BG_HEIGHT/2-40)

	 self.exchangeBtn_ = cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed="#rounded_rect_10.png"},{scale9 = true})
            :pos(display.cx + 110,display.cy-BG_HEIGHT/2-40)
            :setButtonSize(EX_BT_WIDHT-5,EX_BT_HEIGHT-5)
        :setButtonLabel("normal", display.newTTFLabel({text = bm.LangUtil.getText("SCOREMARKET","CONFIRM_EXCHANGE") , color = cc.c3b(0xff, 0xff, 0xff), size = 28, align = ui.TEXT_ALIGN_CENTER}))
            :onButtonClicked(function() 
                    --if self.closeBack then
                    	--self.closeBack()
                    	if tonumber(self.data_.category) == 1 or tonumber(self.data_.category) == 3 then
                    		ExchangeGoodAddressPopup.new(self.control_,self.data_):show()
                    	else
                    		self:openBuyGoodsTip(self.data_)
                    	end
                    --end
                    nk.SoundManager:playSound(nk.SoundManager.CLOSE_BUTTON)
                end)
            :addTo(self)

	 self.closeBtn_ = cc.ui.UIPushButton.new({normal = "#socre_exchange_back.png", pressed="#socre_exchange_back_click.png"})
            :pos(display.cx+100  - BG_WIDTH/2 + 10,display.cy-50 + BG_HEIGHT/2 - 10)
            :onButtonClicked(function() 
                    if self.closeBack then
                    	self.closeBack()
                    end
                    nk.SoundManager:playSound(nk.SoundManager.CLOSE_BUTTON)
                end)
            :addTo(self)



   nk.ImageLoader:loadAndCacheImage(
                    self.userAvatarLoaderId_, 
                    self.data_.imgurl, 
                    handler(self, self.onAvatarLoadComplete_), 
                    nk.ImageLoader.CACHE_TYPE_USER_HEAD_IMG
                )
end
-- function ExchangeGoodView:show()
--     nk.PopupManager:addPopup(self)
--     return self
-- end

function ExchangeGoodView:onAvatarLoadComplete_(success, sprite)
    if success then
        local tex = sprite:getTexture()
        local texSize = tex:getContentSize()
        local xxScale = 120/texSize.width
        local yyScale = 106/texSize.height
        sprite:scale(xxScale<yyScale and xxScale or yyScale)
        :addTo(self.avatar_,0,LOAD_IMG_TAG)
    end
end
function ExchangeGoodView:onCleanup() 
    nk.ImageLoader:cancelJobByLoaderId(self.userAvatarLoaderId_)
end

function ExchangeGoodView:openBuyGoodsTip(data)--CONFIRM_EXCHANGE 
	 nk.ui.Dialog.new({
                    messageText = bm.LangUtil.getText("SCOREMARKET","CONFIRM_EXCHANGE")..data.giftname.."?", 
                    secondBtnText = bm.LangUtil.getText("SCOREMARKET","EXCHANGE_CONFIRM"), 
                    callback = function (type)
                        if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                            self.control_:buyGood(data)
                        end
                    end
                })
                    :show()
end
function ExchangeGoodView:setCloseBack(callback)
	self.closeBack = callback
end
return ExchangeGoodView