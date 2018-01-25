--
-- Author: tony
-- Date: 2014-08-19 15:24:19
--
local MatchChatMsgShortcutListItem = class("MatchChatMsgShortcutListItem", bm.ui.ListItem)

--need to be set before creating instances
MatchChatMsgShortcutListItem.WIDTH = 0
MatchChatMsgShortcutListItem.HEIGHT = 0
MatchChatMsgShortcutListItem.ON_ITEM_CLICKED_LISTENER = nil

function MatchChatMsgShortcutListItem:ctor()
    MatchChatMsgShortcutListItem.super.ctor(self, MatchChatMsgShortcutListItem.WIDTH, MatchChatMsgShortcutListItem.HEIGHT)
    self.btn_ = cc.ui.UIPushButton.new({normal="#room_chat_button_dark_background.png", pressed="#room_chat_button_light_background.png"}, {scale9=true})
            :setButtonLabel(cc.ui.UILabel.new({text="", size=20, color=cc.c3b(0xff, 0xff, 0xff)}))
            :setButtonSize(MatchChatMsgShortcutListItem.WIDTH, 64)
            :onButtonPressed(function(evt) 
                    self.btnPressedY_ = evt.y
                    self.btnClickCanceled_ = false
                end)
            :onButtonRelease(function(evt)
                    if math.abs(evt.y - self.btnPressedY_) > 5 then
                        self.btnClickCanceled_ = true
                    end
                end)
            :onButtonClicked(function(evt)
                    if not self.btnClickCanceled_ and MatchChatMsgShortcutListItem.ON_ITEM_CLICKED_LISTENER and self:getParent():getParent():getCascadeBoundingBox():containsPoint(cc.p(evt.x, evt.y)) then
                        MatchChatMsgShortcutListItem.ON_ITEM_CLICKED_LISTENER(self.data_)
                    end
                end)
    self.btn_:setTouchSwallowEnabled(false)
    self.btn_:pos(MatchChatMsgShortcutListItem.WIDTH * 0.5, 64 * 0.5)
    self.btn_:addTo(self)
end

function MatchChatMsgShortcutListItem:onDataSet(dataChanged, data)
    if dataChanged then
        self.btn_:setButtonLabelString(data)
    end
end

return MatchChatMsgShortcutListItem