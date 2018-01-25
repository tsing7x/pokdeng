--
-- Author: tony
-- Date: 2014-08-26 15:01:15
--
local GrabRoomMenuPopup = class("GrabRoomMenuPopup", function() return display.newNode() end)

local ITEM_HEIGHT = 86
local ITEM_WIDTH = 316
local WIDTH = ITEM_WIDTH + 4
local HEIGHT = ITEM_HEIGHT * 4 + 6
local TOP = HEIGHT * 0.5
local LEFT = WIDTH * -0.5

function GrabRoomMenuPopup:ctor(callback)
    self.background_ = display.newScale9Sprite("#room_chat_panel_background.png", 0, 0, cc.size(WIDTH, HEIGHT))
    -- self.background_:setCapInsets(cc.rect(8, 8, 24, 26))
    self.background_:addTo(self)
    self:setTouchEnabled(true)
    self:setTouchSwallowEnabled(true)

    self:pos(WIDTH * 0.5 + 8, display.top + HEIGHT * 0.5)

    self.backToHallBtn_ = cc.ui.UIPushButton.new({normal="#transparent.png", pressed="#room_menu_pressed_top.png"}, {scale9=true})
        :setButtonSize(ITEM_WIDTH, ITEM_HEIGHT)
        :onButtonPressed(function() 
                self.backToHallIcon_:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("icon_back_to_hall_down.png"))
            end)
        :onButtonRelease(function()
                self.backToHallIcon_:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("icon_back_to_hall_up.png"))
            end)
        :onButtonClicked(function()
                nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
                if callback then
                    callback(1)
                end
                self:hidePanel(true)
            end)
        :setButtonLabel("normal", display.newTTFLabel({size=32, color=cc.c3b(0x8b, 0xa7, 0xc0), align=ui.TEXT_ALIGN_CENTER}))
        :setButtonLabel("pressed", display.newTTFLabel({size=32, color=cc.c3b(0xd7, 0xe5, 0xf5), align=ui.TEXT_ALIGN_CENTER}))
        :setButtonLabelString(bm.LangUtil.getText("ROOM", "BACK_TO_HALL"))
        :setButtonLabelOffset(32, 0)
        :pos(0, TOP - ITEM_HEIGHT * 0.5 - 2)
        :addTo(self)

    self.backToHallIcon_ = display.newSprite("#icon_back_to_hall_up.png"):pos(LEFT + 48, self.backToHallBtn_:getPositionY()):addTo(self)

    self.split1_ = display.newSprite("#room_menu_split.png", 0, TOP - ITEM_HEIGHT - 2):addTo(self)
    self.split1_:setScaleX((WIDTH - 16) / 2)

    self.changeRoomBtn_ = cc.ui.UIPushButton.new({normal="#transparent.png", pressed="#room_menu_pressed_middle.png"}, {scale9=true})
        :setButtonSize(ITEM_WIDTH, ITEM_HEIGHT)
        :onButtonPressed(function() 
                self.changeRoomIcon_:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("icon_change_room_down.png"))
            end)
        :onButtonRelease(function()
                self.changeRoomIcon_:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("icon_change_room_up.png"))
            end)
        :onButtonClicked(function()
                nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
                if callback then
                    callback(2)
                end
                self:hidePanel()
            end)
        :setButtonLabel("normal", display.newTTFLabel({size=32, color=cc.c3b(0x8b, 0xa7, 0xc0), align=ui.TEXT_ALIGN_CENTER}))
        :setButtonLabel("pressed", display.newTTFLabel({size=32, color=cc.c3b(0xd7, 0xe5, 0xf5), align=ui.TEXT_ALIGN_CENTER}))
        :setButtonLabelString(bm.LangUtil.getText("ROOM", "CHANGE_ROOM"))
        :setButtonLabelOffset(32, 0)
        :pos(0, TOP - ITEM_HEIGHT * 1.5 - 2)
        :addTo(self)

    --,nil,nil,{class=CCFilteredSpriteWithOne}
    self.changeRoomIcon_ = display.newSprite("#icon_change_room_up.png"):pos(LEFT + 48, self.changeRoomBtn_:getPositionY()):addTo(self)

    local roomInfo = bm.DataProxy:getData(nk.dataKeys.ROOM_INFO)
    if not roomInfo or (roomInfo.roomType ~= consts.ROOM_TYPE.PERSONAL_NORMAL) then
        self.changeRoomBtn_:setButtonEnabled(true)
        self.changeRoomBtn_:setOpacity(255)
        self.changeRoomIcon_:setOpacity(255)
        -- local newFilter = filter.newFilter("RGB")
        -- self.changeRoomIcon_:setFilter(newFilter)
        -- self.changeRoomBtn_:setFilter(newFilter)
        
    else
        self.changeRoomBtn_:setButtonEnabled(false)
        self.changeRoomBtn_:setOpacity(70)
        self.changeRoomIcon_:setOpacity(70)
        -- local newFilter = filter.newFilter("GRAY")
        -- self.changeRoomIcon_:setFilter(newFilter)
        -- self.changeRoomBtn_:setFilter(newFilter)

        
    end

    self.settingUserinfoBtn_ = cc.ui.UIPushButton.new({normal="#transparent.png", pressed="#room_menu_pressed_middle.png"}, {scale9=true})
        :setButtonSize(ITEM_WIDTH, ITEM_HEIGHT)
        :onButtonPressed(function() 
                self.userInforIcon_:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("icon_useinfo_down.png"))
            end)
        :onButtonRelease(function()
                self.userInforIcon_:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("icon_useinfo_up.png"))
            end)
        :onButtonClicked(function()
                nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
                if callback then
                    callback(4)
                end
                self:hidePanel()
            end)
        :setButtonLabel("normal", display.newTTFLabel({size=32, color=cc.c3b(0x8b, 0xa7, 0xc0), align=ui.TEXT_ALIGN_CENTER}))
        :setButtonLabel("pressed", display.newTTFLabel({size=32, color=cc.c3b(0xd7, 0xe5, 0xf5), align=ui.TEXT_ALIGN_CENTER}))
        :setButtonLabelString(bm.LangUtil.getText("ROOM","USER_INFO_ROOM"))
        :setButtonLabelOffset(32, 0)
        :pos(0, TOP - ITEM_HEIGHT * 2.5 - 2)
        :addTo(self)


    self.userInforIcon_ = display.newSprite("#icon_useinfo_up.png"):pos(LEFT + 48, self.settingUserinfoBtn_:getPositionY()):addTo(self)

    self.split2_ = display.newSprite("#room_menu_split.png", 0, TOP - ITEM_HEIGHT * 2 - 2):addTo(self)
    self.split2_:setScaleX((WIDTH - 16) / 2)

    self.settingBtn_ = cc.ui.UIPushButton.new({normal="#transparent.png", pressed="#room_menu_pressed_bottom.png"}, {scale9=true})
        :setButtonSize(ITEM_WIDTH, ITEM_HEIGHT)
        :onButtonPressed(function() 
                self.settingIcon_:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("icon_setting_down.png"))
            end)
        :onButtonRelease(function()
                self.settingIcon_:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("icon_setting_up.png"))
            end)
        :onButtonClicked(function()
                nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
                if callback then
                    callback(3)
                end
                self:hidePanel()
            end)
        :setButtonLabel("normal", display.newTTFLabel({size=32, color=cc.c3b(0x8b, 0xa7, 0xc0), align=ui.TEXT_ALIGN_CENTER}))
        :setButtonLabel("pressed", display.newTTFLabel({size=32, color=cc.c3b(0xd7, 0xe5, 0xf5), align=ui.TEXT_ALIGN_CENTER}))
        :setButtonLabelString(bm.LangUtil.getText("ROOM", "SETTING"))
        :setButtonLabelOffset(32, 0)
        :pos(0, TOP - ITEM_HEIGHT * 3.5 - 2)
        :addTo(self)

    self.settingIcon_ = display.newSprite("#icon_setting_up.png"):pos(LEFT + 48, self.settingBtn_:getPositionY()):addTo(self)

    self.split3_ = display.newSprite("#room_menu_split.png", 0, TOP - ITEM_HEIGHT * 3 - 2):addTo(self)
    self.split3_:setScaleX((WIDTH - 16) / 2)
    
end

function GrabRoomMenuPopup:showPanel()
    nk.PopupManager:addPopup(self, true, false, true, false)
    return self
end

function GrabRoomMenuPopup:hidePanel(immediatlyClose)
    self.immediatlyClose_ = immediatlyClose
    nk.PopupManager:removePopup(self)
end

function GrabRoomMenuPopup:onShowPopup()
    self:stopAllActions()
    transition.moveTo(self, {time=0.2, y=display.top - HEIGHT * 0.5 - 8, easing="OUT", onComplete=function()
        if self.onShow then
            self:onShow()
        end
        -- local cbox = self:getCascadeBoundingBox()
        -- cbox:setRect(cbox.x, cbox.y, WIDTH, HEIGHT)
        -- self:setCascadeBoundingBox(cbox)
    end})
end

function GrabRoomMenuPopup:onRemovePopup(removeFunc)
    self:stopAllActions()
    if self.immediatlyClose_ then
        removeFunc()
    else
        transition.moveTo(self, {time=0.2, y=display.top + HEIGHT * 0.5, easing="OUT", onComplete=function() 
            removeFunc()
        end})
    end
end

return GrabRoomMenuPopup