--
-- Author: viking@boomegg.com
-- Date: 2014-11-21 17:19:04
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--
local FlashBar = class("FlashBar", function()
    return display.newNode()
end)

function FlashBar:ctor()
    self.schedulerPool_ = bm.SchedulerPool.new()
    --背景
    display.newSprite("#slot_flashbar_bg.png"):addTo(self)

    --第二背景
    display.newSprite("#slot_flashbar_fg.png"):addTo(self):opacity(0.2 * 255)

    --文字
    self.tipLabel_ = display.newTTFLabel({
             text = bm.LangUtil.getText("SLOT", "FLASHBAR_TIP", "$1000000"),
             size = 22, 
             color = cc.c3b(0xff, 0xff, 0xff),
             align = ui.TEXT_ALIGN_CENTER
        })
        :addTo(self)

    --大点
    self.bigDot_ = display.newSprite("#slot_flashbar_big_dot.png"):addTo(self)
    self.isBig_ = true

    --小点
    self.smallDot_ = display.newSprite("#slot_flashbar_small_dot.png"):addTo(self)
end

function FlashBar:setTip(chips)
    self.tipLabel_:setString(bm.LangUtil.getText("SLOT", "FLASHBAR_TIP", chips * 100))
end

function FlashBar:flash(winMoney)
    if winMoney > 0 then
        self.tipLabel_:setString(bm.LangUtil.getText("SLOT", "FLASHBAR_WIN", winMoney))
        self.schedulerPool_:clearAll()
        self.poolId = self.schedulerPool_:loopCall(handler(self, self.start), 0.25)
    else
        self.tipLabel_:setString(bm.LangUtil.getText("SLOT", "PLAY_LOSE"))
    end
    
   
end

function FlashBar:start()
    -- print("FlashBar:flash")
    if self.isBig_ then
        self.smallDot_:show()
        self.bigDot_:hide()
        self.isBig_ = false
    else
        self.smallDot_:hide()
        self.bigDot_:show()
        self.isBig_ = true
    end
    return true
end

function FlashBar:stop()
    self.schedulerPool_:clear(self.poolId)
    self.smallDot_:show()
    self.bigDot_:show()
end

function FlashBar:delayStop(delay, callback)
    self.schedulerPool_:delayCall(function()
        self:stop()
        if callback then
            callback()
        end
    end, delay)
end

function FlashBar:dispose()
    self.schedulerPool_:clearAll()
end

return FlashBar