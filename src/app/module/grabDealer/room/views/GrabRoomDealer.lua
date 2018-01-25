--
-- Author: johnny@boomegg.com
-- Date: 2014-08-20 13:32:49
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

local GrabRoomDealer = class("GrabRoomDealer", function ()
    return display.newNode()
end)

function GrabRoomDealer:ctor(dealerId)
    self.dealerId_ = dealerId
    self.batchNode_ = display.newBatchNode("room_texture.png")
        :addTo(self)
    self.mainBody_ = display.newSprite("#room_dealer.png")
        :addTo(self.batchNode_)
    self.tapSpr_ = display.newSprite("#room_dealer_tap_table_1.png")
        :pos(11, -80)
        :addTo(self.batchNode_)
    self.blinkTwoEyesAction_ = self.mainBody_:schedule(handler(self, self.blinkTwoEyes_), 3)
end

function GrabRoomDealer:blinkTwoEyes_()
    local blinkTwoSpr = display.newSprite("#room_dealer_blink_1.png")
        :pos(13.80, 44.77)
        :addTo(self.batchNode_)
    blinkTwoSpr:performWithDelay(function ()
        blinkTwoSpr:setSpriteFrame(display.newSpriteFrame("room_dealer_blink_2.png"))
    end, 0.05)
    blinkTwoSpr:performWithDelay(function ()
        blinkTwoSpr:setSpriteFrame(display.newSpriteFrame("room_dealer_blink_1.png"))
    end, 0.15)
    blinkTwoSpr:performWithDelay(function ()
        blinkTwoSpr:removeFromParent()
    end, 0.20)
end

-- 亲嘴玩家
function GrabRoomDealer:kissPlayer()
    -- 先眨眼
    if self.blinkSingleSpr_ then
        self.blinkSingleSpr_:removeFromParent()
    end
    self.blinkSingleSpr_ = display.newSprite("#room_dealer_single_blink_1.png")
        :pos(23, 45)
        :addTo(self.batchNode_)
    
    self.blinkSingleSpr_:performWithDelay(function ()
        self.blinkSingleSpr_:setSpriteFrame(display.newSpriteFrame("room_dealer_single_blink_2.png"))
    end, 0.05)
    self.blinkSingleSpr_:performWithDelay(function ()
        self.blinkSingleSpr_:setSpriteFrame(display.newSpriteFrame("room_dealer_single_blink_1.png"))
    end, 0.15)
    self.blinkSingleSpr_:performWithDelay(function ()
        self.blinkSingleSpr_:removeFromParent()
        self.blinkSingleSpr_ = nil

        -- 后亲嘴
        local kissSpr = display.newSprite("#room_dealer_kiss_1.png")
            :pos(11, 24)
            :addTo(self.batchNode_)
        kissSpr:performWithDelay(function ()
            kissSpr:setSpriteFrame(display.newSpriteFrame("room_dealer_kiss_2.png"))
        end, 0.05)
        kissSpr:performWithDelay(function ()
            kissSpr:setSpriteFrame(display.newSpriteFrame("room_dealer_kiss_1.png"))
        end, 0.15)
        kissSpr:performWithDelay(function ()
            kissSpr:removeFromParent()
        end, 0.20)
    end, 0.20)
end

-- 敲桌子
function GrabRoomDealer:tapTable()
    local tapSpr = self.tapSpr_
    if tapSpr:getNumberOfRunningActions() >= 1 then
        tapSpr:stopAllActions()
    end
    
    tapSpr:performWithDelay(function ()
        nk.SoundManager:playSound(nk.SoundManager.TAP_TABLE)
        tapSpr:setSpriteFrame(display.newSpriteFrame("room_dealer_tap_table_2.png"))
    end, 0.25)
    tapSpr:performWithDelay(function ()
        tapSpr:setSpriteFrame(display.newSpriteFrame("room_dealer_tap_table_3.png"))
    end, 0.40)
    tapSpr:performWithDelay(function ()
        tapSpr:setSpriteFrame(display.newSpriteFrame("room_dealer_tap_table_2.png"))
    end, 0.55)
    tapSpr:performWithDelay(function ()
        tapSpr:setSpriteFrame(display.newSpriteFrame("room_dealer_tap_table_3.png"))
    end, 0.65)
    tapSpr:performWithDelay(function ()
        tapSpr:setSpriteFrame(display.newSpriteFrame("room_dealer_tap_table_1.png"))
    end, 0.90)
end

return GrabRoomDealer