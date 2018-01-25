--
-- Author: TsingZhang@boyaa.com
-- Date: 2015-12-09 18:16:27
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- Description: MsgLogRecItem By tsing.
--

local MsgLogRecItem = class("MsgLogRecItem", bm.ui.ListItem)

local MsgLogRecItemParam = {
	WIDTH = 662,
	HEIGHT = 16
}

function MsgLogRecItem:ctor()
	-- body
	MsgLogRecItem.super.ctor(self, MsgLogRecItemParam.WIDTH, MsgLogRecItemParam.HEIGHT)

	-- local msgRecShownWidth = 555

	local recItemMsgLabelParam = {
		frontSize = 18,
		color = cc.c3b(121, 121, 121)
	}
	self.recMsg_ = display.newTTFLabel({text = "00:00 " .. " [xxxxxxxx] 说 : " .. "xxxxxxxxxaaaaaaaaaaaxxxxxxx", size = recItemMsgLabelParam.frontSize, color = recItemMsgLabelParam.color,
		dimensions = cc.size(MsgLogRecItemParam.WIDTH, 0), align = ui.TEXT_ALIGN_LEFT})
	self.recMsg_:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER_LEFT])

	self.recMsg_:addTo(self)
end

function MsgLogRecItem:onDataSet(isChanged, data)
	-- body
	-- dump(data, "MsgLogRecItem.data: ===========")

	--[[ data 中应包含如下信息 :
		recTime :消息发送时间
		fromUserName : 发送人
		recMsg : 消息内容

		可能包含如下必要的信息 :
		toUserName : 接收人
	]]

	-- 在 controller 中重组了Data, 包含了上述信息
	if isChanged then
		--todo
		self.recMsg_:setString(data)

		local itemHeight = self.recMsg_:getContentSize().height + 10

		self:setContentSize(MsgLogRecItemParam.WIDTH, itemHeight)
	end
end

return MsgLogRecItem