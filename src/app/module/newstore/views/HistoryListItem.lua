--
-- Author: tony
-- Date: 2014-11-24 15:47:18
--

local HistoryListItem = class("HistoryListItem", bm.ui.ListItem)

HistoryListItem.PADDING_LEFT = 2
HistoryListItem.PADDING_RIGHT = 2

function HistoryListItem:ctor()
    HistoryListItem.super.ctor(self, HistoryListItem.WIDTH, HistoryListItem.HEIGHT)
    display.newScale9Sprite("#pop_up_split_line.png", HistoryListItem.WIDTH * 0.5, 0, cc.size(HistoryListItem.WIDTH - HistoryListItem.PADDING_LEFT - HistoryListItem.PADDING_RIGHT, 2))
        :addTo(self)

    self.detail_ = display.newTTFLabel({text="", size=24, color=cc.c3b(0xBA, 0xE9, 0xFF), align=ui.TEXT_ALIGN_LEFT, dimensions=cc.size(480, 0)})
    self.detail_:setAnchorPoint(cc.p(0, 0.5))
    self.detail_:pos(16, HistoryListItem.HEIGHT * 0.5)
    self.detail_:addTo(self)

    self.status_ = display.newTTFLabel({text="", size=24, color=cc.c3b(0xBA, 0xE9, 0xFF), align=ui.TEXT_ALIGN_CENTER})
    self.status_:setAnchorPoint(cc.p(0.5, 0.5))
    self.status_:pos(HistoryListItem.WIDTH - 90, HistoryListItem.HEIGHT * 0.5)
    self.status_:addTo(self)

    self.date_ = display.newTTFLabel({text="", size=24, color=cc.c3b(0xBA, 0xE9, 0xFF), align=ui.TEXT_ALIGN_CENTER})
    self.date_:setAnchorPoint(cc.p(0.5, 0.5))
    self.date_:pos(HistoryListItem.WIDTH - 250, HistoryListItem.HEIGHT * 0.5)
    self.date_:addTo(self)
end

function HistoryListItem:onDataSet(dataChanged, data)
    if dataChanged then

        local getPurchasedItemByType = {
            [0] = function(itemNum)
                -- body
                return bm.LangUtil.getText("STORE", "BUY_CASHS", bm.formatNumberWithSplit(checkint(itemNum or 0)))
            end,
            
            [1] = function(itemNum)
                -- body
                return bm.LangUtil.getText("STORE", "BUY_CHIPS", bm.formatBigNumber(checkint(itemNum or 0)))
            end,

            [2] = function(itemNum)
                -- body
                return bm.LangUtil.getText("STORE", "BUY_TICKETS", bm.formatNumberWithSplit(checkint(itemNum or 0)))
            end,

            [6] = function(price)
                -- body
                return bm.LangUtil.getText("STORE", "BUY_GIFTBAGS", price or 29)
            end
        }

        -- if checkint(data.count) and checkint(data.count) > 0 then
        --     self.detail_:setString(bm.LangUtil.getText("STORE", "BUY_CHIPS", bm.formatBigNumber(checkint(data.count))))
        -- elseif data.detail then
        --     self.detail_:setString(data.detail)
        -- end

        if checkint(data.count) and checkint(data.count) > 0 then
            --todo
            self.detail_:setString(getPurchasedItemByType[checkint(data.object or 1)](checkint(data.count)))
        end
        
        self.status_:setString(bm.LangUtil.getText("STORE", "RECORD_STATUS")[checkint(data.status)])
        self.date_:setString(os.date("%Y-%m-%d", checkint(data.created)))
    end
end

return HistoryListItem