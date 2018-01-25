--
-- Author: tony
-- Date: 2014-08-31 13:49:30
--
local RoomSignalIndicator = class("RoomSignalIndicator", function() return display.newNode() end)

function RoomSignalIndicator:ctor()
    self.signal1_ = display.newSprite("#room_signal_1.png", 0, 0):addTo(self)
    self.signal2_ = display.newSprite("#room_signal_2.png", 0, 6):addTo(self)
    self.signal3_ = display.newSprite("#room_signal_3.png", 0, 10):addTo(self)
    self.signal4_ = display.newSprite("#room_signal_4.png", 0, 14):addTo(self)
    self.isFlashing_ = false
end

function RoomSignalIndicator:setSignalStrength(strength)
    self.signal2_:setVisible(strength == 0 or strength >= 2)
    self.signal3_:setVisible(strength == 0 or strength >= 3)
    self.signal4_:setVisible(strength == 0 or strength >= 4)
    self:flash_(strength == 0)
end

function RoomSignalIndicator:flash_(isFlash)
    if self.isFlashing_ ~= isFlash then
        self.isFlashing_ = isFlash
        self:stopAllActions();
        if isFlash then
            self:runAction(cc.RepeatForever:create(transition.sequence({
                cc.Show:create(),
                cc.DelayTime:create(0.8),
                cc.Hide:create(),
                cc.DelayTime:create(0.6)
            })))
        else
            self:show()
        end
    end
end

return RoomSignalIndicator