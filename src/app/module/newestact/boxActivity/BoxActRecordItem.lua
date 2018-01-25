local BoxActRecordItem = class("BoxActRecordItem", bm.ui.ListItem)
local config = import(".BoxActConfig")
--local BoxActRecordItem = class("BoxActRecordItem",function() return display.newNode() end)
--local ITEM_WIDTH = 276
local ITEM_HEIGHT = 38
local WIDTH = 570

local PANDDING = 7.5

function BoxActRecordItem:ctor()

	self:setNodeEventEnabled(true)
    BoxActRecordItem.super.ctor(self, WIDTH, ITEM_HEIGHT)

	display.newScale9Sprite("#actBox_itemBg.png", 0, 0, cc.size(WIDTH/2-16,ITEM_HEIGHT))
	:addTo(self)
	:pos(-WIDTH/4 + PANDDING+285,ITEM_HEIGHT*0.5)

	self.time_ = display.newTTFLabel({text = "", color = cc.c3b(0xff, 0xff, 0xff), size = 22, align = ui.TEXT_ALIGN_CENTER})
	:addTo(self)
	:pos(-WIDTH/4 + PANDDING+285,ITEM_HEIGHT*0.5)

	display.newScale9Sprite("#actBox_itemBg.png", 0, 0, cc.size(WIDTH/2-16,ITEM_HEIGHT))
	:addTo(self)
	:pos(WIDTH/4 - PANDDING+285,ITEM_HEIGHT*0.5)

	self.gift_ = display.newTTFLabel({text = "", color = cc.c3b(0xff, 0xff, 0xff), size = 22, align = ui.TEXT_ALIGN_CENTER})
	:addTo(self)
	:pos(WIDTH/4 - PANDDING+285,ITEM_HEIGHT*0.5)

	-- display.newScale9Sprite("#actBox_itemBg.png", 0, 0, cc.size(WIDTH,ITEM_HEIGHT))
	-- :addTo(self)
	-- :pos(WIDTH/2,ITEM_HEIGHT*0.5)

	-- display.newScale9Sprite("#actBox_itemBg.png", 0, 0, cc.size(WIDTH,ITEM_HEIGHT))
	-- :addTo(self)
	-- :pos(0,0)
	
end

function BoxActRecordItem:setData(data)
	self.time_:setString(data.time)
	local name = config.gidforName[checkint(data.rid)+1]
	self.gift_:setString(name)
end

return BoxActRecordItem