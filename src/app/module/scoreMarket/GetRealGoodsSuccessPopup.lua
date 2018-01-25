--
-- Author: ThinkerWang
-- Date: 2015-12-04 16:20:50
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- 兑换实物成功框框

local WIDTH = 725
local HEIGHT = 440
local TOP_HEIGHT = 310
local LOAD_IMG_TAG = 999

local PIC_BG_WIDTH = 250
local PIC_BG_HEIGHT = 215

local GetRealGoodsSuccessPopup = class("GetRealGoodsSuccessPopup",nk.ui.Panel)

function GetRealGoodsSuccessPopup:ctor(data)
	self.data_ = data
	self:setTouchEnabled(true)
    self:setTouchSwallowEnabled(true)
	self:createNode_()
end 

function GetRealGoodsSuccessPopup:createNode_()
	display.newScale9Sprite("#sm_dialog_bg.png", 0, 0, cc.size(WIDTH,HEIGHT ))
    :pos(0,0)
    :addTo(self)
   
	display.newScale9Sprite("#sm_dialog_border.png", 0, 0, cc.size(WIDTH-40,TOP_HEIGHT ))
    :pos(0,10)
    :addTo(self)

    display.newScale9Sprite("#socre_exchange_good_bg.png", 0, 0, cc.size(PIC_BG_WIDTH, PIC_BG_HEIGHT)):addTo(self)
	 :pos(-180,35)

	 display.newSprite("#score_good_back_flower.png")
	 :addTo(self)
	 :pos(-180,35)
	 :setScale(0.7)

	self.avatar_= display.newSprite("#common_transparent_skin.png")
    :pos(-180,35)
    :addTo(self)

    display.newScale9Sprite("#score_good_word_bg.png", 0, 0, cc.size(PIC_BG_WIDTH-30, 42))
     :addTo(self)
     :pos(-180,-PIC_BG_HEIGHT/2+5)

    display.newTTFLabel({text = self.data_.giftname, color = cc.c3b(0xf6,0xff,0x00), size = 22, align = ui.TEXT_ALIGN_LEFT})
    :addTo(self)
    :pos(-180, -PIC_BG_HEIGHT/2+5)


    display.newTTFLabel({text = bm.LangUtil.getText("SCOREMARKET", "EXCHANGE_SUCCESS_TIP"), color = cc.c3b(0xff,0xff,0xff), size = 40, align = ui.TEXT_ALIGN_LEFT})
    :addTo(self)
    :pos(100, 85)

    local str = bm.LangUtil.getText("SCOREMARKET", "EXCHANGE_SUCCESS_DESC",nk.userData["aUser.name"])
     display.newTTFLabel({text = str, color = cc.c3b(0xff,0xff,0xff), size = 22, align = ui.TEXT_ALIGN_LEFT,dimensions=cc.size(365,145)})
    :addTo(self)
    :pos(150, 0)
    

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

        --

    display.newScale9Sprite("#score_green_btn.png",0, 0, cc.size(168, 50))
     :addTo(self)
     :pos(0,-HEIGHT/2 + 40)

    self.exchangeTxt_ = display.newTTFLabel({text = bm.LangUtil.getText("SCOREMARKET", "EXCHANGE_CONFIRM"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 20, align = ui.TEXT_ALIGN_CENTER})
    cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#rounded_rect_10.png"}, {scale9 = true})
    :setButtonSize(168, 45)
    :addTo(self)
    :setButtonLabel("normal", self.exchangeTxt_)
    :onButtonClicked(buttontHandler(self, self.onClose))
    :pos(0,-HEIGHT/2 + 40)
end
function GetRealGoodsSuccessPopup:show()
	self:showPanel_()
end

function GetRealGoodsSuccessPopup:onShowed()
	 self.userAvatarLoaderId_ = nk.ImageLoader:nextLoaderId() -- 头像加载id

     nk.ImageLoader:loadAndCacheImage(
                    self.userAvatarLoaderId_, 
                    self.data_.imgurl, 
                    handler(self, self.onAvatarLoadComplete_), 
                    nk.ImageLoader.CACHE_TYPE_USER_HEAD_IMG
                )
end
function GetRealGoodsSuccessPopup:onAvatarLoadComplete_(success, sprite)
    if success then
        local tex = sprite:getTexture()
        local texSize = tex:getContentSize()
        local xxScale = 120/texSize.width
        local yyScale = 106/texSize.height
        sprite:scale(xxScale<yyScale and xxScale or yyScale)
        :addTo(self.avatar_,0,LOAD_IMG_TAG)
    end
end
function GetRealGoodsSuccessPopup:onCleanup()

end


return GetRealGoodsSuccessPopup