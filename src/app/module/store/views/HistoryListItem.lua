--
-- Author: tony
-- Date: 2014-08-19 21:24:31
--


local HistoryListItem = class("HistoryListItem", bm.ui.ListItem)

function HistoryListItem:ctor()
    HistoryListItem.super.ctor(self, HistoryListItem.WIDTH, HistoryListItem.HEIGHT)

    self.background_ = display.newScale9Sprite("#store_item_background.png")
    self.background_:setContentSize(cc.size(HistoryListItem.WIDTH - 4, 72))
    self.background_:addTo(self)
    self.background_:pos(HistoryListItem.WIDTH * 0.5 - 1, HistoryListItem.HEIGHT * 0.5)

    self.detail_ = display.newTTFLabel({text="", size=24, color=cc.c3b(0xBA, 0xE9, 0xFF), align=ui.TEXT_ALIGN_LEFT})
    self.detail_:setAnchorPoint(cc.p(0, 0.5))
    self.detail_:pos(12, HistoryListItem.HEIGHT * 0.5)
    self.detail_:addTo(self)

    self.status_ = display.newTTFLabel({text="", size=24, color=cc.c3b(0xBA, 0xE9, 0xFF), align=ui.TEXT_ALIGN_CENTER})
    self.status_:setAnchorPoint(cc.p(0.5, 0.5))
    self.status_:pos(HistoryListItem.WIDTH - 82, HistoryListItem.HEIGHT * 0.5)
    self.status_:addTo(self)

    self.date_ = display.newTTFLabel({text="", size=24, color=cc.c3b(0xBA, 0xE9, 0xFF), align=ui.TEXT_ALIGN_CENTER})
    self.date_:setAnchorPoint(cc.p(0.5, 0.5))
    self.date_:pos(HistoryListItem.WIDTH - 220, HistoryListItem.HEIGHT * 0.5)
    self.date_:addTo(self)
end

function HistoryListItem:onDataSet(dataChanged, data)
    if dataChanged then
        if data.buyMoney and data.buyMoney > 0 then
            self.detail_:setString(bm.LangUtil.getText("STORE", "BUY_CHIPS", bm.formatBigNumber(data.buyMoney)))
        elseif data.detail then
            self.detail_:setString(data.detail)
        end
        self.status_:setString(bm.LangUtil.getText("STORE", "RECORD_STATUS")[data.status])
        self.date_:setString(os.date("%Y-%m-%d", data.buyTime))
    end
end

return HistoryListItem