--
-- Author: tony
-- Date: 2014-07-08 13:22:01
--
local DealerManager = class("DealerManager")
local RoomViewPosition = import(".views.RoomViewPosition")
local RoomDealer = import(".views.RoomDealer")

function DealerManager:ctor()
end

function DealerManager:createNodes()
    -- 加入荷官
     self.roomDealer_ = RoomDealer.new(1)
         :pos(display.cx-5, RoomViewPosition.SeatPosition[1].y + 6)
         :addTo(self.scene.nodes.dealerNode)
end
function DealerManager:hideDealer()
	self.roomDealer_:hide()
end

function DealerManager:showDealer()
	self.roomDealer_:show()
end
function DealerManager:kissPlayer()
    --self.roomDealer_:kissPlayer()

    return self
end

function DealerManager:tapTable()
   -- self.roomDealer_:tapTable()

    return self
end

function DealerManager:dispose()
end

return DealerManager