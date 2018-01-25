-- Author: thinkeras3@163.com
-- Date: 2015-10-19 10:0:39
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- 报名弹窗4--N名奖励Item

local MatchApplyAwardItemEx = class("MatchApplyAwardItemEx", bm.ui.ListItem)

--local BoxActRecordItem = class("BoxActRecordItem",function() return display.newNode() end)
--local ITEM_WIDTH = 276
local ITEM_HEIGHT = 24
local WIDTH = 828

function MatchApplyAwardItemEx:ctor()

	self:setNodeEventEnabled(true)
    MatchApplyAwardItemEx.super.ctor(self, WIDTH, ITEM_HEIGHT)

    

    

    

    display.newScale9Sprite("#common_transparent_skin.png",0,0,cc.size(WIDTH,24))
    :addTo(self)
    :pos(WIDTH/2,ITEM_HEIGHT/2)

    self.rank_ = display.newTTFLabel({text = "第N名奖励: i don't know", color = cc.c3b(0x89, 0xa2, 0xc6), size = 20, dimensions = cc.size(WIDTH, 24),align = ui.TEXT_ALIGN_LEFT})
    :addTo(self)
    :pos(WIDTH/2,ITEM_HEIGHT/2)
end

function MatchApplyAwardItemEx:setData(data)
	local str = ""
	for i=1,#data.desc do
		str= str..data.desc[i].."  "
	end

	self.rank_:setString(bm.LangUtil.getText("MATCH", "HOW_RANK",data.rank)..": "..str)
end

return MatchApplyAwardItemEx