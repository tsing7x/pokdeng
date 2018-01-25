local LayoutParam = {
	BgParam = {
		width = 690,
		height = 288
	},

	TabParam = {
		width = 690,
		height = 40,
		tabAmeY = 2
	},

	ContentParam = {
		width = 690,
		height = 245
	},

	FrontSizeTab = 20,

	LabelTabColor = cc.c3b(77, 94, 119)
}

local CornListMyRec = class("CornListMyRec", function()
	-- body
	return display.newNode()
end)

function CornListMyRec:ctor(parentNode)
	-- body
	self._parentNode = parentNode

	self._backgroundTab = display.newScale9Sprite("#farm_tab-myRec.png", 0, 0,
		cc.size(LayoutParam.TabParam.width, LayoutParam.TabParam.height))
			:pos(LayoutParam.TabParam.width / 2, LayoutParam.BgParam.height - LayoutParam.TabParam.height / 2 - LayoutParam.TabParam.tabAmeY)
			:addTo(self)

	local TabTxtPosX = {40, 135, 260, 365, 485}

	local dateDescTTF = display.newTTFLabel({text = bm.LangUtil.getText("DORNUCOPIA","DATE"), size = LayoutParam.FrontSizeTab, color = LayoutParam.LabelTabColor, align = ui.TEXT_ALIGN_CENTER})
		:pos(TabTxtPosX[1], LayoutParam.TabParam.height / 2)
		:addTo(self._backgroundTab)

	local timeDescTTF = display.newTTFLabel({text = bm.LangUtil.getText("DORNUCOPIA","TIME"), size = LayoutParam.FrontSizeTab, color = LayoutParam.LabelTabColor, align = ui.TEXT_ALIGN_CENTER})
		:pos(TabTxtPosX[2], LayoutParam.TabParam.height / 2)
		:addTo(self._backgroundTab)

	local cornTypeDescTTF = display.newTTFLabel({text = bm.LangUtil.getText("DORNUCOPIA","SEED"), size = LayoutParam.FrontSizeTab, color = LayoutParam.LabelTabColor, align = ui.TEXT_ALIGN_CENTER})
		:pos(TabTxtPosX[3], LayoutParam.TabParam.height / 2)
		:addTo(self._backgroundTab)

	local quantityDescTTF = display.newTTFLabel({text = bm.LangUtil.getText("DORNUCOPIA","CORNUM"), size = LayoutParam.FrontSizeTab, color = LayoutParam.LabelTabColor, align = ui.TEXT_ALIGN_CENTER})
		:pos(TabTxtPosX[4], LayoutParam.TabParam.height / 2)
		:addTo(self._backgroundTab)

	local stealerDescTTF = display.newTTFLabel({text = bm.LangUtil.getText("DORNUCOPIA","REAPER"), size = LayoutParam.FrontSizeTab, color = LayoutParam.LabelTabColor, align = ui.TEXT_ALIGN_CENTER})
		:pos(TabTxtPosX[5], LayoutParam.TabParam.height / 2)
		:addTo(self._backgroundTab)

	self._backgroundCont = display.newScale9Sprite("#farm_contBg-myRec.png", 0, 0,
		cc.size(LayoutParam.ContentParam.width, LayoutParam.ContentParam.height))
			:pos(LayoutParam.ContentParam.width / 2, LayoutParam.ContentParam.height / 2)
			:addTo(self)

	self:getMyStealList()

	-- self:initListView(nil)
end

function CornListMyRec:initListView(dataList)
	-- body
	local scrollContent = display.newNode()

	local container = display.newNode():addTo(scrollContent)

	local ListItemParam = {
		ItemWidth = 680,
		ItemHeight = 66,
		MarginLeft = 0,
		MarginLine = 10,
		DivLineHeight = 2
	}

	local ContainerPosYFix = 5

	local len = #dataList

	for i = 1, len do
		local listItem = require("app.module.cornucopia.CornMyRecItem").new(dataList[i],self)

		if i == 1 then
 			--todo
 			listItem:pos(ListItemParam.MarginLeft, 0)
 		else

 			-- 默认排列：从下往上 -- 
 			listItem:pos(ListItemParam.MarginLeft, ListItemParam.ItemHeight * (i - 1) + ListItemParam.MarginLine * 2 * (i - 1))
 			local divLineSp = display.newScale9Sprite("#farm_divLine-myRec.png", 0, 0,
 					cc.size(LayoutParam.ContentParam.width, 2))
 			divLineSp:pos(LayoutParam.ContentParam.width / 2, ListItemParam.ItemHeight * (i - 1) + ListItemParam.MarginLine * (2 * i - 3))
 			divLineSp:addTo(container)
 		end
 		listItem:addTo(container)
	end

	container:pos(- LayoutParam.ContentParam.width / 2, - (ListItemParam.ItemHeight * len + ListItemParam.MarginLine * 2 * len) / 2 + ContainerPosYFix)

	self._recList = bm.ui.ScrollView.new({viewRect = cc.rect(- LayoutParam.ContentParam.width / 2, - LayoutParam.ContentParam.height / 2,
			LayoutParam.ContentParam.width, LayoutParam.ContentParam.height),
		scrollContent = scrollContent, direction = bm.ui.ScrollView.DIRECTION_VERTICAL})
        :addTo(self._backgroundCont):pos(LayoutParam.ContentParam.width / 2, LayoutParam.ContentParam.height / 2)
end

function CornListMyRec:getMyStealList()
	-- body
	self._parentNode.controller_:getMyRec()
end

function CornListMyRec:setListData(dataTable)
	-- body
	self:initListView(dataTable)

	self._recList:setScrollContentTouchRect()

end

function CornListMyRec:toFriendCor(fid)
	self._parentNode:toFriendCor(fid)
end

return CornListMyRec