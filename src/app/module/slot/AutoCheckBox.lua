--
-- Author: viking@boomegg.com
-- Date: 2014-11-25 18:52:46
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--
local AutoCheckBox = class("AutoCheckBox", function()
    return display.newNode()
end)

function AutoCheckBox:ctor(callback)
    self.callback_ = callback

    --背景
    local redWidth = 175
    local redHeight = 59
    local redMarginBottom = 0
    local touchNode_ = display.newScale9Sprite("#slot_checkbox_bg.png"):size(redWidth, redHeight):addTo(self):pos(0, redMarginBottom)
    bm.TouchHelper.new(touchNode_, handler(self, self.onCheckChangeListner_))
    self.isChecked_ = false

    --checkbox
    local frameWidth = 21
    local frameHeight = 20
    local frameMarginLeft = 26 + 10
    local frameMarginBottom = 3
    local frameNode_ = display.newSprite("#slot_checkbox_frame.png"):addTo(self)
        :pos(-redWidth/2 + frameWidth/2 + frameMarginLeft, frameMarginBottom)
        :scale(1.2)

    --icon
    local iconWidth = 12
    local iconHeight = 12
    local iconMarginLeft = 5
    local iconMarginBottom = 8
    self.icon_ = display.newSprite("#slot_checkbox_icon.png"):addTo(frameNode_)
        :pos(iconWidth/2 + iconMarginLeft, iconHeight/2 + iconMarginBottom):scale(0.7):hide()

    --文字
    local labelMarginRight = 26 + 5
    local labelMarginBottom = 5
    local label_ = display.newTTFLabel({
             text = bm.LangUtil.getText("SLOT", "AUTO"),
             size = 22, 
             color = cc.c3b(0xff, 0xff, 0xff),
             align = ui.TEXT_ALIGN_CENTER
        })
        :addTo(self)
    local labelSize = label_:getContentSize()
    label_:setAnchorPoint(cc.p(1, 0.5))
    label_:pos(redWidth/2 - labelMarginRight, labelMarginBottom)
end

function AutoCheckBox:onCheckChangeListner_(target, evt)
    if evt == bm.TouchHelper.TOUCH_BEGIN then
        
    elseif evt == bm.TouchHelper.TOUCH_END then
        
    elseif evt == bm.TouchHelper.CLICK then
        self.isChecked_ = not self.isChecked_
        if self.isChecked_ then
            nk.SoundManager:playSound(nk.SoundManager.SLOT_AUTO_BET)
        end
        -- print("AutoCheckBox:onCheckChangeListner_", self.isChecked_)
        self.icon_:setVisible(self.isChecked_)
        if self.callback_ then
            self.callback_(self.isChecked_)
        end
    end
end

function AutoCheckBox:isChecked()
    return self.isChecked_
end

function AutoCheckBox:dispose()
    -- body
end

return AutoCheckBox