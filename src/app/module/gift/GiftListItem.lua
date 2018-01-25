--
-- Author: Tom
-- Date: 2014-11-26 14:44:23
--
local GiftListItem = class("GiftListItem", bm.ui.ListItem)
local LoadGiftControl = import(".LoadGiftControl")

local giftGroup = {}



function GiftListItem:ctor(uid,useIdArray,toUidArr)
    self:setNodeEventEnabled(true)
    GiftListItem.super.ctor(self, 708, 120)

    local posY = self.height_ * 0.5
    -- 分割线
    self.imgLoaderId_1 =  nk.ImageLoader:nextLoaderId() -- 头像加载id
    self.imgLoaderId_2 =  nk.ImageLoader:nextLoaderId() -- 头像加载id
    self.imgLoaderId_3 =  nk.ImageLoader:nextLoaderId() -- 头像加载id
    self.imgLoaderId_4 =  nk.ImageLoader:nextLoaderId() -- 头像加载id
    self.imgLoaderId_5 =  nk.ImageLoader:nextLoaderId() -- 头像加载id

    self.giftIcon_1 = display.newSprite("#popup_tab_bar_bg.png")
        :pos(80, posY + 17)
        :addTo(self)
        :hide()
    self.hotIcon_1 = display.newSprite("#store_label_hot.png")
        :pos(40, posY + 22)
        :addTo(self)
        :hide()
    self.newIcon_1 = display.newSprite("#store_label_new.png")
        :pos(40, posY + 22)
        :addTo(self)
        :hide()
    self.btnGroup_1 = cc.ui.UICheckBoxButton.new({off="#gift-shop-unselect-icon.png", on="#gift-shop-select-icon.png"})
            :setButtonLabel(display.newTTFLabel({text="", size=24, color=cc.c3b(0xb2, 0xdc, 0xff), align=ui.TEXT_ALIGN_CENTER}))
            :setButtonLabelOffset(0, -36)
            :setButtonLabelAlignment(display.CENTER)
            :pos(80, posY)
            :onButtonStateChanged(handler(self, self.selectChangeListener))
            :addTo(self)
            :hide()
    self.validityTime_normal_1 = display.newTTFLabel({text="", size=20, color=cc.c3b(0xff, 0xff, 0xff), align=ui.TEXT_ALIGN_CENTER})
        :pos(-13, posY - 95)
        :addTo(self.btnGroup_1)
        :hide()
    self.validityTime_normal_1:setAnchorPoint(cc.p(0, 0.5))

    self.validityTime_desc_1 = display.newTTFLabel({text="", size=20, color=cc.c3b(0xff, 0x1a, 0x41), align=ui.TEXT_ALIGN_CENTER})
        :pos(0, posY - 95)
        :addTo(self.btnGroup_1)
        :hide()
    self.validityTime_desc_1:setAnchorPoint(cc.p(0, 0.5))

    
    
    self.giftIcon_2 = display.newSprite("#popup_tab_bar_bg.png")
        :pos(self.giftIcon_1:getPositionX() + self.giftIcon_1:getContentSize().width + 75, posY + 17)
        :addTo(self)
        :hide()
    self.hotIcon_2 = display.newSprite("#store_label_hot.png")
        :pos(self.giftIcon_1:getPositionX() + self.giftIcon_1:getContentSize().width + 35, posY + 22)
        :addTo(self)
        :hide()
    self.newIcon_2 = display.newSprite("#store_label_new.png")
        :pos(self.giftIcon_1:getPositionX() + self.giftIcon_1:getContentSize().width + 35, posY + 22)
        :addTo(self)
        :hide()
    self.btnGroup_2 = cc.ui.UICheckBoxButton.new({off="#gift-shop-unselect-icon.png", on="#gift-shop-select-icon.png"})
            :setButtonLabel(display.newTTFLabel({text="", size=24, color=cc.c3b(0xb2, 0xdc, 0xff), align=ui.TEXT_ALIGN_CENTER}))
            :setButtonLabelOffset(0, -36)
            :setButtonLabelAlignment(display.CENTER)
            :pos(self.btnGroup_1:getPositionX() + self.btnGroup_1:getContentSize().width + 136 , posY)
            :onButtonStateChanged(handler(self, self.selectChangeListener))
            :addTo(self)
            :hide()
    self.validityTime_normal_2 = display.newTTFLabel({text="", size=20, color=cc.c3b(0xff, 0xff, 0xff), align=ui.TEXT_ALIGN_CENTER})
        :pos(-13, posY - 95)
        :addTo(self.btnGroup_2)
        :hide()
    self.validityTime_normal_2:setAnchorPoint(cc.p(0, 0.5))

    self.validityTime_desc_2 = display.newTTFLabel({text="", size=20, color=cc.c3b(0xff, 0x1a, 0x41), align=ui.TEXT_ALIGN_CENTER})
        :pos(0, posY - 95)
        :addTo(self.btnGroup_2)
        :hide()
    self.validityTime_desc_2:setAnchorPoint(cc.p(0, 0.5))
    

    self.giftIcon_3 = display.newSprite("#popup_tab_bar_bg.png")
        :pos(self.giftIcon_2:getPositionX() + self.giftIcon_2:getContentSize().width + 75, posY + 17)
        :addTo(self)
        :hide()
    self.hotIcon_3 = display.newSprite("#store_label_hot.png")
        :pos(self.giftIcon_2:getPositionX() + self.giftIcon_2:getContentSize().width + 33, posY + 22)
        :addTo(self)
        :hide()
    self.newIcon_3 = display.newSprite("#store_label_new.png")
        :pos(self.giftIcon_2:getPositionX() + self.giftIcon_2:getContentSize().width + 32, posY + 22)
        :addTo(self)
        :hide()
    self.btnGroup_3 = cc.ui.UICheckBoxButton.new({off="#gift-shop-unselect-icon.png", on="#gift-shop-select-icon.png"})
            :setButtonLabel(display.newTTFLabel({text="", size=24, color=cc.c3b(0xb2, 0xdc, 0xff), align=ui.TEXT_ALIGN_CENTER}))
            :setButtonLabelOffset(0, -36)
            :setButtonLabelAlignment(display.CENTER)
            :pos(self.btnGroup_2:getPositionX() + self.btnGroup_2:getContentSize().width + 136, posY)
            :onButtonStateChanged(handler(self, self.selectChangeListener))
            :addTo(self)
            :hide()
    self.validityTime_normal_3 = display.newTTFLabel({text="", size=20, color=cc.c3b(0xff, 0xff, 0xff), align=ui.TEXT_ALIGN_CENTER})
        :pos(-13, posY - 95)
        :addTo(self.btnGroup_3)
        :hide()
    self.validityTime_normal_3:setAnchorPoint(cc.p(0, 0.5))

    self.validityTime_desc_3 = display.newTTFLabel({text="", size=20, color=cc.c3b(0xff, 0x1a, 0x41), align=ui.TEXT_ALIGN_CENTER})
        :pos(0, posY - 95)
        :addTo(self.btnGroup_3)
        :hide()
    self.validityTime_desc_3:setAnchorPoint(cc.p(0, 0.5))



    self.giftIcon_4 = display.newSprite("#popup_tab_bar_bg.png")
        :pos(self.giftIcon_3:getPositionX() + self.giftIcon_3:getContentSize().width + 75, posY + 17)
        :addTo(self)
        :hide()
    self.hotIcon_4 = display.newSprite("#store_label_hot.png")
        :pos(self.giftIcon_3:getPositionX() + self.giftIcon_3:getContentSize().width + 30, posY + 22)
        :addTo(self)
        :hide()
    self.newIcon_4 = display.newSprite("#store_label_new.png")
        :pos(self.giftIcon_3:getPositionX() + self.giftIcon_3:getContentSize().width + 30, posY + 22)
        :addTo(self)
        :hide()
    self.btnGroup_4 = cc.ui.UICheckBoxButton.new({off="#gift-shop-unselect-icon.png", on="#gift-shop-select-icon.png"})
            :setButtonLabel(display.newTTFLabel({text="", size=24, color=cc.c3b(0xb2, 0xdc, 0xff), align=ui.TEXT_ALIGN_CENTER}))
            :setButtonLabelOffset(0, -36)
            :setButtonLabelAlignment(display.CENTER)
            :pos(self.btnGroup_3:getPositionX() + self.btnGroup_3:getContentSize().width + 136, posY)
            :onButtonStateChanged(handler(self, self.selectChangeListener))
            :addTo(self)
            :hide()
    self.validityTime_normal_4 = display.newTTFLabel({text="", size=20, color=cc.c3b(0xff, 0xff, 0xff), align=ui.TEXT_ALIGN_CENTER})
        :pos(-13, posY - 95)
        :addTo(self.btnGroup_4)
        :hide()
    self.validityTime_normal_4:setAnchorPoint(cc.p(0, 0.5))

    self.validityTime_desc_4 = display.newTTFLabel({text="", size=20, color=cc.c3b(0xff, 0x1a, 0x41), align=ui.TEXT_ALIGN_CENTER})
        :pos(0, posY - 95)
        :addTo(self.btnGroup_4)
        :hide()
    self.validityTime_desc_4:setAnchorPoint(cc.p(0, 0.5))


    self.giftIcon_5 = display.newSprite("#popup_tab_bar_bg.png")
        :pos(self.giftIcon_4:getPositionX() + self.giftIcon_4:getContentSize().width + 75, posY + 17)
        :addTo(self)
        :hide()
    self.hotIcon_5 = display.newSprite("#store_label_hot.png")
        :pos(self.giftIcon_4:getPositionX() + self.giftIcon_4:getContentSize().width + 27, posY + 22)
        :addTo(self)
        :hide()
    self.newIcon_5 = display.newSprite("#store_label_new.png")
        :pos(self.giftIcon_4:getPositionX() + self.giftIcon_4:getContentSize().width + 27, posY + 22)
        :addTo(self)
        :hide()
    self.btnGroup_5 = cc.ui.UICheckBoxButton.new({off="#gift-shop-unselect-icon.png", on="#gift-shop-select-icon.png"})
            :setButtonLabel(display.newTTFLabel({text="", size=24, color=cc.c3b(0xb2, 0xdc, 0xff), align=ui.TEXT_ALIGN_CENTER}))
            :setButtonLabelOffset(0, -36)
            :setButtonLabelAlignment(display.CENTER)
            :pos(self.btnGroup_4:getPositionX() + self.btnGroup_4:getContentSize().width + 136, posY)
            :onButtonStateChanged(handler(self, self.selectChangeListener))
            :addTo(self)
            :hide()
    self.validityTime_normal_5 = display.newTTFLabel({text="", size=20, color=cc.c3b(0xff, 0xff, 0xff), align=ui.TEXT_ALIGN_CENTER})
        :pos(-13, posY - 95)
        :addTo(self.btnGroup_5)
        :hide()
    self.validityTime_normal_5:setAnchorPoint(cc.p(0, 0.5))

    self.validityTime_desc_5 = display.newTTFLabel({text="", size=20, color=cc.c3b(0xff, 0x1a, 0x41), align=ui.TEXT_ALIGN_CENTER})
        :pos(0, posY - 95)
        :addTo(self.btnGroup_5)
        :hide()
    self.validityTime_desc_5:setAnchorPoint(cc.p(0, 0.5))


    self.checkBoxArr_ = {self.btnGroup_1, self.btnGroup_2, self.btnGroup_3, self.btnGroup_4, self.btnGroup_5}
    for _, btn_ in pairs(self.checkBoxArr_) do
        btn_:setTouchSwallowEnabled(false)
    end
end


function GiftListItem:setData(data, btnGroup, args)
    local dataChanged = (self.data_ ~= data)
    self.data_ = data
    if self.onDataSet then
        self:onDataSet(dataChanged, data, btnGroup, args)
    end
    return self
end

function GiftListItem:onDataSet(dataChanged, data, btnGroup, args)
    for i = 1, 5 do
        if #data >= i then
            btnGroup:addButton(self.checkBoxArr_[i]:show(), data[i].pnid)
        else
            self.checkBoxArr_[i]:hide()
        end
    end
    -- 加载礼物纹理
    self:loadImageTexture(data)
    -- 加载礼物价格
    self:loadGiftPrice(data)

    -- 加载礼物ID
    self:loadGiftId(data)

end

function GiftListItem:loadGiftId(data)
    if #data >= 1 and data[1].pnid then
        self.btnGroup_1.ID = data[1].pnid 
        self.btnGroup_1.positionId = 1
    end
    if #data >= 2 and data[2].pnid then
        self.btnGroup_2.ID = data[2].pnid 
        self.btnGroup_2.positionId = 2
    end
    if #data >= 3 and data[3].pnid then
        self.btnGroup_3.ID = data[3].pnid
        self.btnGroup_3.positionId = 3
    end
    if #data >= 4 and data[4].pnid then
        self.btnGroup_4.ID = data[4].pnid 
        self.btnGroup_4.positionId = 4
    end
    if #data >= 5 and data[5].pnid then
        self.btnGroup_5.ID = data[5].pnid
        self.btnGroup_5.positionId = 5 
    end
end

function GiftListItem:loadGiftPrice(data)
    if #data >= 1 and data[1].money then
        if tonumber(data[1].expire)  > 1 then
            self.btnGroup_1:setButtonLabel("off", display.newTTFLabel({text=data[1].money.."("..data[1].expire ..bm.LangUtil.getText("GIFT","DATA_LABEL")..")" , color=cc.c3b(255, 255, 255), align=ui.TEXT_ALIGN_CENTER}))
        else
            if data[1].giftType == 1 then
                self.validityTime_normal_1:show()
                self.validityTime_normal_1:setString(data[1].money)
                self.validityTime_normal_1:setPosition(- self.validityTime_normal_1:getContentSize().width, self.height_ * 0.5 - 95)
                self.validityTime_desc_1:show()
                self.validityTime_desc_1:setString("("..1 ..bm.LangUtil.getText("GIFT","DATA_LABEL")..")")
                self.validityTime_desc_1:setPosition(self.validityTime_normal_1:getPositionX() + self.validityTime_normal_1:getContentSize().width  , self.validityTime_desc_1:getPositionY())
            else
                self.btnGroup_1:setButtonLabel("off", display.newTTFLabel({text=data[1].money.."("..data[1].expire ..bm.LangUtil.getText("GIFT","DATA_LABEL")..")" , color=cc.c3b(255, 255, 255), align=ui.TEXT_ALIGN_CENTER}))
            end
            
        end

        if data[1].ext_property then
            if data[1].ext_property == "1" then
                self.hotIcon_1:show()
            elseif data[1].ext_property == "2" then
                self.newIcon_1:show()
            else
                self.hotIcon_1:hide()
                self.newIcon_1:hide()
            end
        end

    end

    if #data >= 2 and data[2].money then
        if tonumber(data[2].expire)  > 1  then
            self.btnGroup_2:setButtonLabel("off", display.newTTFLabel({text=data[2].money.."("..data[2].expire ..bm.LangUtil.getText("GIFT","DATA_LABEL")..")" , color=cc.c3b(255, 255, 255), align=ui.TEXT_ALIGN_CENTER}))
        else
            if data[2].giftType == 1 then
                self.validityTime_normal_2:show()
                self.validityTime_normal_2:setString(data[2].money)
                self.validityTime_normal_2:setPosition(- self.validityTime_normal_2:getContentSize().width, self.height_ * 0.5 - 95)
                self.validityTime_desc_2:show()
                self.validityTime_desc_2:setString("("..1 ..bm.LangUtil.getText("GIFT","DATA_LABEL")..")")
                self.validityTime_desc_2:setPosition(self.validityTime_normal_2:getPositionX() + self.validityTime_normal_2:getContentSize().width , self.validityTime_desc_2:getPositionY())
            else
                self.btnGroup_2:setButtonLabel("off", display.newTTFLabel({text=data[2].money.."("..data[2].expire ..bm.LangUtil.getText("GIFT","DATA_LABEL")..")" , color=cc.c3b(255, 255, 255), align=ui.TEXT_ALIGN_CENTER}))
            end
        end

        if data[2].ext_property then
            if data[2].ext_property == "1" then
                self.hotIcon_2:show()
            elseif data[2].ext_property == "2" then
                self.newIcon_2:show()
            else
                self.hotIcon_2:hide()
                self.newIcon_2:hide()
            end
        end
    end

    if #data >= 3 and data[3].money then
        if tonumber(data[3].expire)  > 1  then
            self.btnGroup_3:setButtonLabel("off", display.newTTFLabel({text=data[3].money.."("..data[3].expire ..bm.LangUtil.getText("GIFT","DATA_LABEL")..")" , color=cc.c3b(255, 255, 255), align=ui.TEXT_ALIGN_CENTER}))
        else
            if data[3].giftType == 1 then
                self.validityTime_normal_3:show()
                self.validityTime_normal_3:setString(data[3].money)
                self.validityTime_normal_3:setPosition(- self.validityTime_normal_3:getContentSize().width, self.height_ * 0.5 - 95)
                self.validityTime_desc_3:show()
                self.validityTime_desc_3:setString("("..1 ..bm.LangUtil.getText("GIFT","DATA_LABEL")..")")
                self.validityTime_desc_3:setPosition(self.validityTime_normal_3:getPositionX() + self.validityTime_normal_3:getContentSize().width, self.validityTime_desc_3:getPositionY())
            else
                self.btnGroup_3:setButtonLabel("off", display.newTTFLabel({text=data[3].money.."("..data[3].expire ..bm.LangUtil.getText("GIFT","DATA_LABEL")..")" , color=cc.c3b(255, 255, 255), align=ui.TEXT_ALIGN_CENTER}))
            end
            
        end
        if data[3].ext_property then
            if data[3].ext_property == "1" then
                self.hotIcon_3:show()
            elseif data[3].ext_property == "2" then
                self.newIcon_3:show()
            else
                self.hotIcon_3:hide()
                self.newIcon_3:hide()
            end
        end
    end


    if #data >= 4 and data[4].money then
        if tonumber(data[4].expire)  > 1  then
            self.btnGroup_4:setButtonLabel("off", display.newTTFLabel({text=data[4].money.."("..data[4].expire ..bm.LangUtil.getText("GIFT","DATA_LABEL")..")" , color=cc.c3b(255, 255, 255), align=ui.TEXT_ALIGN_CENTER}))
        else
            if data[4].giftType == 1 then
                self.validityTime_normal_4:show()
                self.validityTime_normal_4:setString(data[4].money)
                self.validityTime_normal_4:setPosition(- self.validityTime_normal_4:getContentSize().width, self.height_ * 0.5 - 95)
                self.validityTime_desc_4:show()
                self.validityTime_desc_4:setString("("..1 ..bm.LangUtil.getText("GIFT","DATA_LABEL")..")")
                self.validityTime_desc_4:setPosition(self.validityTime_normal_4:getPositionX() + self.validityTime_normal_4:getContentSize().width, self.validityTime_desc_4:getPositionY())
            else
                self.btnGroup_4:setButtonLabel("off", display.newTTFLabel({text=data[4].money.."("..data[4].expire ..bm.LangUtil.getText("GIFT","DATA_LABEL")..")" , color=cc.c3b(255, 255, 255), align=ui.TEXT_ALIGN_CENTER}))
            end
            
        end
        if data[4].ext_property then
            if data[4].ext_property == "1" then
                self.hotIcon_4:show()
            elseif data[4].ext_property == "2" then
                self.newIcon_4:show()
            else
                self.hotIcon_4:hide()
                self.newIcon_4:hide()
            end
        end
    end

    if #data >= 5 and data[5].money then
        if tonumber(data[5].expire)  > 1  then
            self.btnGroup_5:setButtonLabel("off", display.newTTFLabel({text=data[5].money.."("..data[5].expire ..bm.LangUtil.getText("GIFT","DATA_LABEL")..")" , color=cc.c3b(255, 255, 255), align=ui.TEXT_ALIGN_CENTER}))
        else
            if data[5].giftType == 1 then
                self.validityTime_normal_5:show()
                self.validityTime_normal_5:setString(data[5].money)
                self.validityTime_normal_5:setPosition(- self.validityTime_normal_5:getContentSize().width, self.height_ * 0.5 - 95)
                self.validityTime_desc_5:show()
                self.validityTime_desc_5:setString("("..1 ..bm.LangUtil.getText("GIFT","DATA_LABEL")..")")
                self.validityTime_desc_5:setPosition(self.validityTime_normal_5:getPositionX() + self.validityTime_normal_5:getContentSize().width, self.validityTime_desc_5:getPositionY())
            else
                self.btnGroup_5:setButtonLabel("off", display.newTTFLabel({text=data[5].money.."("..data[5].expire ..bm.LangUtil.getText("GIFT","DATA_LABEL")..")" , color=cc.c3b(255, 255, 255), align=ui.TEXT_ALIGN_CENTER}))
            end
            
        end
        if data[5].ext_property then
            if data[5].ext_property == "1" then
                self.hotIcon_5:show()
            elseif data[5].ext_property == "2" then
                self.newIcon_5:show()
            else
                self.hotIcon_5:hide()
                self.newIcon_5:hide()
            end
        end
    end
end

function GiftListItem:loadImageTexture(data)
    if #data >= 1 and data[1].pnid then
        if data[1].image and string.len(data[1].image) > 0 then
        nk.ImageLoader:loadAndCacheImage(
            self.imgLoaderId_1, 
            data[1].image, 
             handler(self, self.onAvatarLoadComplete_1), 
              nk.ImageLoader.CACHE_TYPE_GIFT
            )
        end
    end

    if #data >= 2 and data[2].pnid then
        if data[2].image and string.len(data[2].image) > 0 then
        nk.ImageLoader:loadAndCacheImage(
            self.imgLoaderId_2, 
            data[2].image, 
             handler(self, self.onAvatarLoadComplete_2), 
              nk.ImageLoader.CACHE_TYPE_GIFT
            )
        end
    end

    if #data >= 3 and data[3].pnid then
        if data[3].image and string.len(data[3].image) > 0 then
        nk.ImageLoader:loadAndCacheImage(
            self.imgLoaderId_3, 
            data[3].image, 
             handler(self, self.onAvatarLoadComplete_3), 
              nk.ImageLoader.CACHE_TYPE_GIFT
            )
        end
    end

    if #data >= 4 and data[4].pnid then
        if data[4].image and string.len(data[4].image) > 0 then
        nk.ImageLoader:loadAndCacheImage(
            self.imgLoaderId_4, 
            data[4].image, 
             handler(self, self.onAvatarLoadComplete_4), 
              nk.ImageLoader.CACHE_TYPE_GIFT
            )
        end
    end

    if #data >= 5 and data[5].pnid then
        print("data[5].imagedata[5].imagedata[5].image",data[5].image)
        if data[5].image and string.len(data[5].image) > 0 then
        nk.ImageLoader:loadAndCacheImage(
            self.imgLoaderId_5, 
            data[5].image, 
             handler(self, self.onAvatarLoadComplete_5), 
              nk.ImageLoader.CACHE_TYPE_GIFT
            )
        end
    end
end


function GiftListItem:onAvatarLoadComplete_1(success, sprite)
    if success then
        self.giftIcon_1:show()
         local tex = sprite:getTexture()
         local texSize = tex:getContentSize()
         self.giftIcon_1:setTexture(tex)
         self.giftIcon_1:setTextureRect(cc.rect(0, 0, texSize.width, texSize.height))
         self.giftIcon_1:setScaleX(60 / texSize.width)
         self.giftIcon_1:setScaleY(60 / texSize.height)
    end
end

function GiftListItem:onAvatarLoadComplete_2(success, sprite)
    if success then
        self.giftIcon_2:show()
         local tex = sprite:getTexture()
         local texSize = tex:getContentSize()
         self.giftIcon_2:setTexture(tex)
         self.giftIcon_2:setTextureRect(cc.rect(0, 0, texSize.width, texSize.height))
         self.giftIcon_2:setScaleX(60 / texSize.width)
         self.giftIcon_2:setScaleY(60 / texSize.height)
    end
end

function GiftListItem:onAvatarLoadComplete_3(success, sprite)
    if success then
        self.giftIcon_3:show()
         local tex = sprite:getTexture()
         local texSize = tex:getContentSize()
         self.giftIcon_3:setTexture(tex)
         self.giftIcon_3:setTextureRect(cc.rect(0, 0, texSize.width, texSize.height))
         self.giftIcon_3:setScaleX(60 / texSize.width)
         self.giftIcon_3:setScaleY(60 / texSize.height)
    end
end

function GiftListItem:onAvatarLoadComplete_4(success, sprite)
    if success then
        self.giftIcon_4:show()
         local tex = sprite:getTexture()
         local texSize = tex:getContentSize()
         self.giftIcon_4:setTexture(tex)
         self.giftIcon_4:setTextureRect(cc.rect(0, 0, texSize.width, texSize.height))
         self.giftIcon_4:setScaleX(60 / texSize.width)
         self.giftIcon_4:setScaleY(60 / texSize.height)
    end
end

function GiftListItem:onAvatarLoadComplete_5(success, sprite)
    if success then
        self.giftIcon_5:show()
         local tex = sprite:getTexture()
         local texSize = tex:getContentSize()
         self.giftIcon_5:setTexture(tex)
         self.giftIcon_5:setTextureRect(cc.rect(0, 0, texSize.width, texSize.height))
         self.giftIcon_5:setScaleX(60 / texSize.width)
         self.giftIcon_5:setScaleY(60 / texSize.height)
    end
end

function GiftListItem:selectChangeListener(event)
    if event.target:isButtonSelected()  then
        local selectGiftId = event.target.ID
        local selectGiftName = event.target.name
        local positionId = event.target.positionId
        bm.EventCenter:dispatchEvent({name = nk.eventNames.GET_CUR_SELECT_GIFT_ID, data = {giftId = selectGiftId}})
    else
        
    end
end


function GiftListItem:resetStatus()
     self.group:setButtonImage("off","#gift-shop-unselect-icon.png")
end

function GiftListItem:onCleanup()
    nk.ImageLoader:cancelJobByLoaderId(self.imgLoaderId_1)
    nk.ImageLoader:cancelJobByLoaderId(self.imgLoaderId_2)
    nk.ImageLoader:cancelJobByLoaderId(self.imgLoaderId_3)
    nk.ImageLoader:cancelJobByLoaderId(self.imgLoaderId_4)
    nk.ImageLoader:cancelJobByLoaderId(self.imgLoaderId_5)
end


return GiftListItem