local ItemContSize = {
	width = 680,
	height = 66
}

local ItemTxtFrontSize = 20
local ItemTxtColor = cc.c3b(182, 182, 182)

local CornMyRecItem = class("CornMyRecItem", function()
	-- body
	return display.newNode()
end)

function CornMyRecItem:ctor(itemData,parent)
	self.fid_ = itemData.mid
	self.parent_ = parent
	-- body
	self:setContentSize(cc.size(ItemContSize.width, ItemContSize.height))  -- 对Item坐标调节有帮助！！？

	local ContWidgPosX = {40, 135, 260, 365, 485, 600}

	self._dateTTF = display.newTTFLabel({text = "8-13", size = ItemTxtFrontSize, color = ItemTxtColor, align = ui.TEXT_ALIGN_CENTER})
	-- self._dateTTF:setAnchorPoint(display.ANCHOR_POINTS[display.LEFT_CENTER])
	self._dateTTF:pos(ContWidgPosX[1], ItemContSize.height / 2)
	self._dateTTF:addTo(self)

	self._timeTTF = display.newTTFLabel({text = "15:22:20", size = ItemTxtFrontSize, color = ItemTxtColor, align = ui.TEXT_ALIGN_CENTER})
	-- self._timeTTF:setAnchorPoint(display.ANCHOR_POINTS[display.LEFT_CENTER])
	self._timeTTF:pos(ContWidgPosX[2], ItemContSize.height / 2)
	self._timeTTF:addTo(self)

	self._cornNameTTF = display.newTTFLabel({text = "GlodSeed", size = ItemTxtFrontSize, color = ItemTxtColor, align = ui.TEXT_ALIGN_CENTER})
	-- self._cronNameTTF:setAnchorPoint(display.ANCHOR_POINTS[display.LEFT_CENTER])
	self._cornNameTTF:pos(ContWidgPosX[3], ItemContSize.height / 2)
	self._cornNameTTF:addTo(self)

	self._numTTF = display.newTTFLabel({text = "2000", size = ItemTxtFrontSize, color = ItemTxtColor, align = ui.TEXT_ALIGN_CENTER})
	self._numTTF:pos(ContWidgPosX[4], ItemContSize.height / 2)
	self._numTTF:addTo(self)

	self._fromNameTTF = display.newTTFLabel({text = "Aken", size = ItemTxtFrontSize, color = ItemTxtColor, align = ui.TEXT_ALIGN_CENTER})
	self._fromNameTTF:pos(ContWidgPosX[5], ItemContSize.height / 2)
	self._fromNameTTF:addTo(self)

	local btnLabelFrontSize = 15

	self._detailBtn = cc.ui.UIPushButton.new({normal = "#farm_itenBt-myRec.png", pressed="#farm_itenBt-myRec.png"})
	:pos(ContWidgPosX[6], ItemContSize.height / 2)
	:setButtonLabel("normal", display.newTTFLabel({text = bm.LangUtil.getText("DORNUCOPIA","HIES_FARM"), size = btnLabelFrontSize, align = ui.TEXT_ALIGN_CENTER}))
	:onButtonClicked(buttontHandler(self, self.detailBtnCallBack))
	:addTo(self)

	self:resetAllWidgetTxt(itemData)
end

function CornMyRecItem:detailBtnCallBack()
	self.parent_:toFriendCor(self.fid_)
end
function CornMyRecItem:resetAllWidgetTxt(itemData)
	-- body
	local getSeedNameByID = {
		["401"] = bm.LangUtil.getText("DORNUCOPIA","SILVER_SEED"),
			
		["402"] = bm.LangUtil.getText("DORNUCOPIA","GOLD_SEED")
			
	}
	local date = itemData.date
	local fromUid = itemData.mid
	local num = itemData.money
	local time = itemData.time
	local seedType = itemData.type
	local name = itemData.name

	local nameTTFWidthLimit = 130
	
	self._dateTTF:setString(tostring(date))
	self._timeTTF:setString(tostring(time))

	self._cornNameTTF:setString(getSeedNameByID[seedType])
	self._numTTF:setString(tostring(num))
	---self._fromNameTTF:setString(tostring(name))

	self._fromNameTTF:setString(nk.Native:getFixedWidthText("", ItemTxtFrontSize, (tostring(name) or ""), nameTTFWidthLimit))

end

return CornMyRecItem