--
-- Author: tony
-- Date: 2014-08-19 16:37:53
--
local GrabChatMsgHistoryListItem = class("GrabChatMsgHistoryListItem", bm.ui.ListItem)

--need to be set before creating new instances
GrabChatMsgHistoryListItem.WIDTH = 0
GrabChatMsgHistoryListItem.HEIGHT = 0

function GrabChatMsgHistoryListItem:ctor()
    GrabChatMsgHistoryListItem.super.ctor(self, GrabChatMsgHistoryListItem.WIDTH, GrabChatMsgHistoryListItem.HEIGHT)
    self.label_ = display.newTTFLabel({text="", size=20, color=cc.c3b(0x72, 0x7f, 0x89),dimensions=cc.size(GrabChatMsgHistoryListItem.WIDTH, 0), align=ui.TEXT_ALIGN_LEFT})
        :pos(GrabChatMsgHistoryListItem.WIDTH * 0.5, GrabChatMsgHistoryListItem.HEIGHT * 0.5)
        :addTo(self)
end

function GrabChatMsgHistoryListItem:onDataSet(dataChanged, data)
    if dataChanged then
        self.label_:setString(data.messageContent or "")
        if data.mtype == 1 then
            -- 大喇叭
            self.label_:setTextColor(cc.c3b(0xe0, 0x86, 0x1a))
        elseif data.mtype == 2 then
            -- 普通聊天消息
            self.label_:setTextColor(cc.c3b(0x72, 0x7f, 0x89))
        end
        local csize = self.label_:getContentSize()
        self.label_:pos(GrabChatMsgHistoryListItem.WIDTH * 0.5, csize.height * 0.5)
        self:setContentSize(cc.size(GrabChatMsgHistoryListItem.WIDTH, self.label_:getContentSize().height + 12))
    end
end

return GrabChatMsgHistoryListItem