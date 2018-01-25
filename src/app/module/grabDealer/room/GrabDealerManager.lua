--
-- Author: tony
-- Date: 2014-07-08 13:22:01
--
local GrabDealerManager = class("GrabDealerManager")
local RoomViewPosition = import(".views.GrabRoomViewPosition")
local RoomDealer = import(".views.GrabRoomDealer")

function GrabDealerManager:ctor()
end

function GrabDealerManager:createNodes()
    -- 加入荷官
    -- self.roomDealer_ = RoomDealer.new(1)
    --     :pos(display.cx, RoomViewPosition.SeatPosition[1].y + 6)
    --     :addTo(self.scene.nodes.dealerNode)
end

function GrabDealerManager:kissPlayer()
    --self.roomDealer_:kissPlayer()

    return self
end

function GrabDealerManager:tapTable()
   -- self.roomDealer_:tapTable()

    return self
end

function GrabDealerManager:dispose()
end

return GrabDealerManager