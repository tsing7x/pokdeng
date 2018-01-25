--
-- Author: tony
-- Date: 2014-08-23 19:53:49
--

local MatchRoomChatBubble = class("MatchRoomChatBubble", function() return display.newNode() end)

MatchRoomChatBubble.DIRECTION_LEFT = 1
MatchRoomChatBubble.DIRECTION_RIGHT = 2

function MatchRoomChatBubble:ctor(label, direction)
    if direction == MatchRoomChatBubble.DIRECTION_LEFT then
        self.background_ = display.newScale9Sprite("#chat_left_msg_bubble.png")
    else
        self.background_ = display.newScale9Sprite("#chat_right_msg_bubble.png")
    end
    self.background_:setCapInsets(cc.rect(29, 25, 8, 5))
    self.background_:addTo(self)

    if appconfig.LANG == "vn" then
        self.label_ = display.newTTFLabel({text=label, size=18, color=cc.c3b(0x55, 0x5C, 0x64), align=ui.TEXT_ALIGN_CENTER})
    else
        self.label_ = display.newTTFLabel({text=label, size=22, color=cc.c3b(0x55, 0x5C, 0x64), align=ui.TEXT_ALIGN_CENTER})
    end
    if self.label_:getContentSize().width > 182 then
        self.label_:setDimensions(182, 0)
    end
    if self.label_:getContentSize().height > 72 then
        self.label_:setDimensions(182, 72)
    end
    self.label_:setAnchorPoint(cc.p(0.5, 0.5))
    self.label_:addTo(self)
    local lbsize = self.label_:getContentSize()
    local bgw = math.max(100, lbsize.width + 16)
    local bgh = math.max(lbsize.height + 11, 55)
    self.background_:setContentSize(cc.size(bgw, bgh))

    if direction == MatchRoomChatBubble.DIRECTION_LEFT then
        self.background_:pos(bgw * 0.5, bgh * 0.5)
        self.label_:pos(bgw * 0.5, math.floor((bgh + 11) * 0.5))
    else
        self.background_:pos(bgw * -0.5, bgh * 0.5)
        self.label_:pos(bgw * -0.5, math.floor((bgh + 11) * 0.5))
    end
end

function MatchRoomChatBubble:show(parent, x, y)
    if self:getParent() then
        self:removeFromParent()
    end
    self:pos(x, y):addTo(parent)
end

return MatchRoomChatBubble