--
-- Author: johnny@boomegg.com
-- Date: 2014-08-09 17:27:11
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
-- Description: Modify By TsingZhang.

local ChooseRoomChip = class("ChooseRoomChip", function ()
    return display.newNode()
end)

function ChooseRoomChip:ctor(chipSkin, textColor)
    self.bgChipDent_ = display.newSprite("#chipChos_bgDent_chip_unSel.png")
        :addTo(self)

    self.chip_ = display.newSprite(chipSkin)
        :addTo(self)
    self.chip_:setTouchEnabled(true)
    self.chip_:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.onTouch_))

    -- 前注
    self.preCallLabel_= display.newTTFLabel({text = "", color = textColor, size = 35, align = ui.TEXT_ALIGN_CENTER})
        :pos(0, 18)
        :addTo(self)

    display.newTTFLabel({text = bm.LangUtil.getText("HALL", "PRE_CALL_TEXT"), color = textColor, size = 20, align = ui.TEXT_ALIGN_CENTER})
        :pos(0, - 5)
        :addTo(self)

    self.playerCountBg_ = display.newScale9Sprite("#chipChos_bg_playerCount.png", 0, - 25, cc.size(42, 20))
        :addTo(self)

    -- 在玩人数
    self.playerCountIcon_ = display.newSprite("#chipChos_ic_playerCount.png")
        :align(display.LEFT_CENTER, 0, - 25)
        :addTo(self)
        :hide()

    -- cc.c3b(0xA7, 0xF2, 0xB0) Org CountLabel Color
    self.playerCountLabel_ = display.newTTFLabel({text = "", size = 18, align = ui.TEXT_ALIGN_CENTER})
        :align(display.LEFT_CENTER, 0, - 25)
        :addTo(self)
        :hide()
    self:setPlayerCount(0)

    -- 最小买入
    local bgPosY = - (self.chip_:getContentSize().height * 0.5 + 22)

    display.newScale9Sprite("#player_count_bg.png", 0, 0, cc.size(148, 30))
        :pos(0, bgPosY)
        :addTo(self)

    self.minBuyInLabel_ = display.newTTFLabel({text = bm.LangUtil.getText("HALL", "MIN_IN_TO_ROOM_TEXT", 0), color = cc.c3b(0x6C, 0xAA, 0x34), size = 18, align = ui.TEXT_ALIGN_CENTER})
        :pos(0, bgPosY)
        :addTo(self)
end

function ChooseRoomChip:onTouch_(evt)
    self.touchInSprite_ = self.chip_:getCascadeBoundingBox():containsPoint(cc.p(evt.x, evt.y))
    if evt.name == "began" then
        -- self:scaleTo(0.05, 0.9)
        self.bgChipDent_:setSpriteFrame(display.newSpriteFrame("chipChos_bgDent_chip_sel.png"))

        self.clickCanced_ = false
        return true
    elseif evt.name == "moved" then
        if not self.touchInSprite_ and not self.clickCanced_ then
            self:scaleTo(0.05, 1)
            self.clickCanced_ = true
        end
    elseif evt.name == "ended" or name == "cancelled" then
        self.bgChipDent_:setSpriteFrame(display.newSpriteFrame("chipChos_bgDent_chip_unSel.png"))

        if not self.clickCanced_ then
            nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
            self:scaleTo(0.05, 1)
            if self.callback_ then
                self.callback_(self.preCall_)
            end
        end
    end
end

function ChooseRoomChip:setPlayerCount(count)
    if count >= 0 then
        -- if self.preCall_ then
        --     count = self.preCall_[6] * count
        -- end
        self.playerCountLabel_:setString(bm.formatNumberWithSplit(count))
        local iconWidth = self.playerCountIcon_:getContentSize().width
        local labelWidth = self.playerCountLabel_:getContentSize().width
        self.playerCountIcon_:show()
            :setPositionX(-(iconWidth + labelWidth + 6) * 0.5)
        self.playerCountLabel_:show()
            :setPositionX(self.playerCountIcon_:getPositionX() + iconWidth + 6)

        self.playerCountBg_:setContentSize(iconWidth * 3 / 2 + labelWidth + 6, 20)
    end
end

function ChooseRoomChip:setPreCall(val)
    self.preCall_ = val
    if self.preCall_ and #self.preCall_ > 4 then        
        self.preCallLabel_:setString(bm.formatBigNumber(self.preCall_[2]))
        self.minBuyInLabel_:setString(bm.LangUtil.getText("HALL", "MIN_IN_TO_ROOM_TEXT", bm.formatBigNumber(self.preCall_[13])))
    end
end

function ChooseRoomChip:getValue()
    return (self.preCall_ and self.preCall_[2] or 0)
end


function ChooseRoomChip:getPreCall()
    return self.preCall_
end

function ChooseRoomChip:onChipClick(callback)
    assert(type(callback) == "function", "callback should be a function")
    self.callback_ = callback
    return self
end

return ChooseRoomChip