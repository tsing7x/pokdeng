

local ChooseMatchNormalItem = class("ChooseMatchNormalItem", bm.ui.ListItem)

ChooseMatchNormalItem.ITEM_HEIGHT = 90
ChooseMatchNormalItem.BUTTON_WIDHT = 168

function ChooseMatchNormalItem:ctor()
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
	self:setNodeEventEnabled(true)
	ChooseMatchNormalItem.super.ctor(self,display.width - 40, ChooseMatchNormalItem.ITEM_HEIGHT)
	self.bg_ = display.newScale9Sprite("#hall_match_list_room_bg.png",0,0,cc.size(display.width-40-ChooseMatchNormalItem.BUTTON_WIDHT,ChooseMatchNormalItem.ITEM_HEIGHT))
	:addTo(self)
	:pos((display.width - 40-ChooseMatchNormalItem.BUTTON_WIDHT)/2,ChooseMatchNormalItem.ITEM_HEIGHT/2)
	

	self.btn_ = cc.ui.UIPushButton.new({normal = "#hall_apply_match_btn_up.png", pressed = "#hall_apply_match_btn_down.png",disabled = "#hall_apply_match_btn_disable.png"})
    :onButtonClicked(buttontHandler(self, self.applyClick_))
    :pos((display.width - 40)-ChooseMatchNormalItem.BUTTON_WIDHT/2, ChooseMatchNormalItem.ITEM_HEIGHT/2)
    :addTo(self)
  
    self.btn_:setTouchSwallowEnabled(false)

    --styles.FONT_COLOR.LIGHT_TEXT
    self.buttonLabel = display.newTTFLabel({text = bm.LangUtil.getText("MATCH", "JOIN_MATCH"), color =cc.c3b(0x87,0x43,0x61) , size = 28, align = ui.TEXT_ALIGN_CENTER})
  
    self.btn_:setButtonLabel("normal", self.buttonLabel)

    self.icon1_ = display.newSprite("#popup_tab_bar_bg.png")
    :addTo(self)
    :pos(60,45)
   

   self.matchName_ = display.newTTFLabel({text = "", color = cc.c3b(0xFF, 0xED, 0xA4), size = 18, align = ui.TEXT_ALIGN_CENTER})
        :align(display.LEFT_CENTER)
        :addTo(self)
        :pos(130,60)

  

    self.playerIcon_ = display.newSprite("#hall_match_list_playerIcon.png")
         :align(display.LEFT_CENTER, 130, 25)
         :addTo(self)
         

    self.playerCountLabel_ = display.newTTFLabel({text = "0", color = cc.c3b(0xaF, 0xff, 0x51), size = 18, align = ui.TEXT_ALIGN_CENTER})
        :align(display.LEFT_CENTER, 130+35, 25)
        :addTo(self)
     


    self.infoBg_ = display.newScale9Sprite("#hall_match_item_info_bg.png",0,0,cc.size(210,66))
    :addTo(self)
    :pos(display.cx,45)
  

    self.infoLabel_  = display.newTTFLabel({text = "", color = styles.FONT_COLOR.LIGHT_TEXT, size = 18,dimensions = cc.size(210, 66), align = ui.TEXT_ALIGN_CENTER})
        :pos(display.cx,45)
        :addTo(self)
    
       

    self.matchIconId_ = nk.ImageLoader:nextLoaderId() -- 头像加载id

end


function ChooseMatchNormalItem:loadImageTexture(data)
    
    if data.icon1 and string.len(data.icon1) > 0 then
        nk.ImageLoader:loadAndCacheImage(
            self.matchIconId_, 
            data.icon1, 
            handler(self, self.onAvatarLoadComplete_1), 
            nk.ImageLoader.CACHE_TYPE_MATCH
            )
    end
end



function ChooseMatchNormalItem:onAvatarLoadComplete_1(success, sprite)
    -- do return end
    if success then
        self.icon1_:show()
         local tex = sprite:getTexture()
         local texSize = tex:getContentSize()
         self.icon1_:setTexture(tex)
         self.icon1_:setTextureRect(cc.rect(0, 0, texSize.width, texSize.height))
         -- self.icon1_:setScaleX(60 / texSize.width)
         -- self.icon1_:setScaleY(60 / texSize.height)
         if self.data_ and self.data_.open == 0 then
            self.icon1_:hide()
        end
    end
end


function ChooseMatchNormalItem:applyClick_()
    self:dispatchEvent({name="ITEM_EVENT", data = self.data_})
end
function ChooseMatchNormalItem:onCleanup()
	if self.matchIconId_ then
        nk.ImageLoader:cancelJobByLoaderId(self.matchIconId_)
        self.matchIconId_ = nil
    end
end



function ChooseMatchNormalItem:setPlayerCount(count)
    if count >= 0 then
        
        self.playerCountLabel_:setString(bm.formatNumberWithSplit(count))
        -- self.playerCountLabel_:show()

        if self.data_ and tonumber(self.data_.open) == 0 then
            self.playerCountLabel_:setString("0")
        end
        --     :setPositionX(self.playerCountIcon_:getPositionX() + iconWidth + 6)
    end
end



function ChooseMatchNormalItem:onDataSet(dataChanged, data)

    self.data_ = data
    self.matchName_:setString(data.name or "")
    self:loadImageTexture(data)

    local prize = ""
    if data.prizeDesc and data.prizeDesc[1] then
        prize = string.gsub(data.prizeDesc[1],",","\n")

    end

    self.infoLabel_:setString(prize or "")


    self:setPlayerCount(data.playerCount or 0)
   
end


return ChooseMatchNormalItem