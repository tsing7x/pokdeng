--
-- Author: tony
-- Date: 2015-12-10 18:13:55
--
local CommonSignalIndicator = class("CommonSignalIndicator", function() return display.newNode() end)

local Margin = 10
local TipTextH = 30

local BG_W = 200
local BG_H = 150

function CommonSignalIndicator:ctor()
    self.signalbg_ = display.newScale9Sprite("#common_signal_bg.png", 0, 0,cc.size(BG_W,BG_H)):addTo(self)
    self.signal1_ = display.newSprite("#common_signal_1.png", 0, 30):addTo(self)
    self.signal2_ = display.newSprite("#common_signal_2.png", 0, 30):addTo(self)
    self.signal3_ = display.newSprite("#common_signal_3.png", 0, 30):addTo(self)
    self.signal4_ = display.newSprite("#common_signal_4.png", 0, 30):addTo(self)
    self.tipLabel_ = display.newTTFLabel({text = "", color = styles.FONT_COLOR.LIGHT_TEXT, size = 26, align = ui.TEXT_ALIGN_CENTER,dimensions=cc.size(BG_W-10, 100)})
        :pos(0, -40)
        :addTo(self)
    self.isFlashing_ = false
    self.isFlashing2_ = false
end


function CommonSignalIndicator:showNetWordTips(str)
    str = str or ""
    self.tipLabel_:setString(str)
    self:flash2_(true)
end



function CommonSignalIndicator:flash2_(isFlash)
    if self.isFlashing2_ ~= isFlash then
        self.isFlashing2_ = isFlash
        -- self:stopAllActions();
        self.signal2_:stopAllActions()
        self.signal3_:stopAllActions()
        self.signal4_:stopAllActions()
        if isFlash then
            self.signal2_:runAction(cc.RepeatForever:create(transition.sequence({
                
                cc.Hide:create(),
                cc.DelayTime:create(0.2),
                cc.Show:create(),
                cc.DelayTime:create(1)
            })))

            self.signal3_:runAction(cc.RepeatForever:create(transition.sequence({
                cc.Hide:create(),
                cc.DelayTime:create(0.4),
                cc.Show:create(),
                cc.DelayTime:create(0.8)
            })))

            self.signal4_:runAction(cc.RepeatForever:create(transition.sequence({
                cc.Hide:create(),
                cc.DelayTime:create(0.6),
                cc.Show:create(),
                cc.DelayTime:create(0.6)
            })))
        else
            self.signal2_:show()
            self.signal3_:show()
            self.signal4_:show()
        end
    end
end


return CommonSignalIndicator