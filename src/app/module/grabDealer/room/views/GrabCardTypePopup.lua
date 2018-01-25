--
-- Author: tony
-- Date: 2014-08-28 15:14:46
--
local GrabCardTypePopup = class("GrabCardTypePopup", function() return display.newNode() end)

GrabCardTypePopup.WIDTH = 460
GrabCardTypePopup.HEIGHT = 551

function GrabCardTypePopup:ctor()
    self.content_ = display.newSprite("room_card_type.png"):addTo(self)
    self.content_:setTouchEnabled(true)
    self.content_:setTouchSwallowEnabled(true)
    self:pos(-GrabCardTypePopup.WIDTH * 0.5, GrabCardTypePopup.HEIGHT * 0.5 + 80)
end

function GrabCardTypePopup:showPanel()
    nk.PopupManager:addPopup(self, true, false, true, false)
end

function GrabCardTypePopup:hidePanel()
    nk.PopupManager:removePopup(self)
end

function GrabCardTypePopup:onRemovePopup(removeFunc)
    self:stopAllActions()
    transition.moveTo(self, {time=0.3, x=-GrabCardTypePopup.WIDTH * 0.5, easing="OUT", onComplete=function() 
        removeFunc()
    end})
end

function GrabCardTypePopup:onShowPopup()
    self:stopAllActions()
    transition.moveTo(self, {time=0.3, x=GrabCardTypePopup.WIDTH * 0.5 + 8, easing="OUT", onComplete=function()
        if self.onShow then
            self:onShow()
        end
    end})
end

return GrabCardTypePopup