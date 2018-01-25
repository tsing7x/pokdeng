local ComponItem = import(".GiftProdComponItem")

local GiftProdLineCompon = class("GiftProdLineCompon", function()
	-- body
	return display.newNode()
end)

function GiftProdLineCompon:ctor(giftListData)
	-- body
	self:setTouchEnabled(true)
	self:setTouchSwallowEnabled(false)

	local componItemWidth = 122
	local itemMagrinEach = 20

	for i = 1, #giftListData do
		-- dump(giftListData, "giftListData:=============")
		local componItem = ComponItem.new(giftListData[i])
			:pos((componItemWidth + itemMagrinEach) * (i - 1), 0)
			:addTo(self)
	end
end

return GiftProdLineCompon