--
-- Author: tony
-- Date: 2014-07-17 15:26:44
--
local TouchHelper = bm.TouchHelper

local MatchOperationButton = class("MatchOperationButton", function()
    return display.newNode()
end)

MatchOperationButton.BUTTON_WIDTH = 210
MatchOperationButton.BUTTON_HEIGHT = 72

function MatchOperationButton:ctor()
    self.touchHelper_ = TouchHelper.new(self, self.onTouch_)
    self.touchHelper_:enableTouch()

    self.isEnabled_ = true
    self.isCheckMode_ = false
    self.isChecked_ = false
    self.isPressed_ = false

    local btnW = MatchOperationButton.BUTTON_WIDTH
    local btnH = MatchOperationButton.BUTTON_HEIGHT
    self.backgrounds_ = {
        oprUp = display.newScale9Sprite("#room_opr_btn_up.png"):size(btnW, btnH):addTo(self),
        oprDown = display.newScale9Sprite("#room_opr_btn_down.png"):size(btnW, btnH):addTo(self),
        checkUp = display.newScale9Sprite("#room_opr_check_up.png"):size(btnW, btnH):addTo(self),
        checkDown = display.newScale9Sprite("#room_opr_check_down.png"):size(btnW, btnH):addTo(self),
        checkSelected = display.newScale9Sprite("#room_opr_check_selected.png"):size(btnW, btnH):addTo(self)
    }

    self.iconCheckBg_ = display.newSprite("#room_opr_check_bg.png"):pos(MatchOperationButton.BUTTON_WIDTH * -0.5 + 38, 0):addTo(self)
    self.iconCheckIcon_ = display.newSprite("#room_opr_check_icon.png"):pos(MatchOperationButton.BUTTON_WIDTH * -0.5 + 38, 0):addTo(self)

    self.label_ = display.newTTFLabel({text="", size=24, align=ui.TEXT_ALIGN_CENTER, color=cc.c3b(0xcf, 0xea, 0xd0)}):addTo(self)
    self:updateView_()
end

function MatchOperationButton:setEnabled(isEnabled)
    self.isEnabled_ = isEnabled
    self:updateView_()
    return self
end

function MatchOperationButton:setLabel(label_)
    self.label_:setString(label_)
    return self
end

function MatchOperationButton:getLabel()
    return self.label_:getString()
end

function MatchOperationButton:isChecked()
    return self.isChecked_
end

function MatchOperationButton:setChecked(isChecked, triggerHandler)
    local oldChecked = self.isChecked_
    self.isChecked_ = isChecked
    if isChecked ~= oldChecked and self.checkHandler_ and triggerHandler then
        self.checkHandler_(self, isChecked)
    end
    self:updateView_()
    return self
end

function MatchOperationButton:setCheckMode(isCheckMode)
    self.isCheckMode_ = isCheckMode
    self:updateView_()
    return self
end

function MatchOperationButton:onTouch(touchHandler)
    self.touchHandler_ = touchHandler
    return self
end

function MatchOperationButton:onCheck(checkHandler)
    self.checkHandler_ = checkHandler
    return self
end

function MatchOperationButton:onTouch_(evt)
    if self.isEnabled_ then
        if evt == TouchHelper.CLICK then
            nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
            self.isPressed_ = false
            if self.isCheckMode_ then
                self.isChecked_ = not self.isChecked_
                if self.checkHandler_ then
                    self.checkHandler_(self, self.isChecked_)
                end
            end
        elseif evt == TouchHelper.TOUCH_BEGIN then
            self.isPressed_ = true
        elseif evt == TouchHelper.TOUCH_END then
            self.isPressed_ = false
        end
        self:updateView_()

        if self.touchHandler_ then
            self.touchHandler_(evt)
        end
    end
end

function MatchOperationButton:updateView_()
    if self.isCheckMode_ then
        self.iconCheckBg_:show()
        if self.isChecked_ then
            self.iconCheckIcon_:show()
        else
            self.iconCheckIcon_:hide()
        end
        self.label_:pos(20, 0)
    else
        self.iconCheckBg_:hide()
        self.iconCheckIcon_:hide()
        self.label_:pos(0, 0)
    end

    if not self.isEnabled_ then
        self:selectBackground("checkDown")
        self.label_:setTextColor(cc.c3b(0x83, 0x88, 0x91))
    elseif self.isCheckMode_ then
        if self.isPressed_ then
            self:selectBackground("checkDown")
            self.label_:setTextColor(cc.c3b(0x5f, 0x8e, 0x60))
        elseif self.isChecked_ then
            self:selectBackground("checkSelected")
            self.label_:setTextColor(cc.c3b(0xcf, 0xea, 0xd0))
        else
            self:selectBackground("checkUp")
            self.label_:setTextColor(cc.c3b(0xcf, 0xea, 0xd0))
        end
    else
        if self.isPressed_ then
            self:selectBackground("oprDown")
            self.label_:setTextColor(cc.c3b(0x5f, 0x8e, 0x60))
        else
            self:selectBackground("oprUp")
            self.label_:setTextColor(cc.c3b(0xcf, 0xea, 0xd0))
        end
    end
end

function MatchOperationButton:selectBackground(name)
    for k, v in pairs(self.backgrounds_) do
        if k == name then
            v:show()
        else
            v:hide()
        end
    end
end

return MatchOperationButton