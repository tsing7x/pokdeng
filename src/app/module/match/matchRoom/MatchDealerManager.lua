--
-- Author: tony
-- Date: 2014-07-08 13:22:01
--
local MatchDealerManager = class("MatchDealerManager")
local RoomViewPosition = import(".views.MatchRoomViewPosition")
local RoomDealer = import(".views.MatchRoomDealer")

function MatchDealerManager:ctor()
end

function MatchDealerManager:createNodes()
    -- 加入荷官
    self.roomDealer_ = RoomDealer.new(1)
        :pos(display.cx, RoomViewPosition.SeatPosition[1].y + 6)
        :addTo(self.scene.nodes.dealerNode)
end

function MatchDealerManager:kissPlayer()
    self.roomDealer_:kissPlayer()

    return self
end

function MatchDealerManager:tapTable()
    self.roomDealer_:tapTable()

    return self
end

function MatchDealerManager:dispose()
end

return MatchDealerManager