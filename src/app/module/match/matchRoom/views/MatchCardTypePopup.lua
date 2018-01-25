--
-- Author: tony
-- Date: 2014-08-28 15:14:46
--
local MatchCardTypePopup = class("MatchCardTypePopup", function() return display.newNode() end)

MatchCardTypePopup.WIDTH = 460
MatchCardTypePopup.HEIGHT = 551

function MatchCardTypePopup:ctor()
    self.content_ = display.newSprite("room_card_type.png"):addTo(self)
    self.content_:setTouchEnabled(true)
    self.content_:setTouchSwallowEnabled(true)
    self:pos(-MatchCardTypePopup.WIDTH * 0.5, MatchCardTypePopup.HEIGHT * 0.5 + 80)
end

function MatchCardTypePopup:showPanel()
    nk.PopupManager:addPopup(self, true, false, true, false)
end

function MatchCardTypePopup:hidePanel()
    nk.PopupManager:removePopup(self)
end

function MatchCardTypePopup:onRemovePopup(removeFunc)
    self:stopAllActions()
    transition.moveTo(self, {time=0.3, x=-MatchCardTypePopup.WIDTH * 0.5, easing="OUT", onComplete=function() 
        removeFunc()
    end})
end

function MatchCardTypePopup:onShowPopup()
    self:stopAllActions()
    transition.moveTo(self, {time=0.3, x=MatchCardTypePopup.WIDTH * 0.5 + 8, easing="OUT", onComplete=function()
        if self.onShow then
            self:onShow()
        end
    end})
end

return MatchCardTypePopup