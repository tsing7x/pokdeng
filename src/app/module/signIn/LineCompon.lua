--
-- Author: TsingZhang@boyaa.com
-- Date: 2015-11-04 10:11:58
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- Description: ComponItem Signature Complement.
--

local ComponItem = import(".ComponItem")

local LineCompon = class("LineCompon", function()
	-- body
	return display.newNode()
end)

function LineCompon:ctor(lineItemDataList, todayIdx)
	-- body
	self:setTouchEnabled(true)
	self:setTouchSwallowEnabled(false)

	local itemWidth = 100
	local itemMagrinEachRow = 5

	for i = 1, #lineItemDataList do
		local componItem = ComponItem.new(lineItemDataList[i], todayIdx)
			:pos((itemWidth + itemMagrinEachRow) * (i - 1), 0)
			:addTo(self)
	end
end

return LineCompon