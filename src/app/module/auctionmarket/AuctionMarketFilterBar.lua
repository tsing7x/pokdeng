-- Author: Vanfo
-- Date: 2016-01-18 11:36:00

local logger = bm.Logger.new("AuctionMarketFilterBar")
local AuctionRow = import(".AuctionRow")
local AucteFilterListItem = import(".AucteFilterListItem")

local LIST_WIDTH = 90
local LIST_HEIGHT = 102
--列表过滤菜单栏
local AuctionMarketFilterBar = class("AuctionMarketFilterBar",function()
	return display.newNode()
end)

--[[
	labelTb:
	{
 		"拍卖物品",
 		"物品数量",
 		"拍卖人",
 		"初始价",
 		"当前竞价",
 		"剩余时间",
 		"竞拍人",
 		"-------"
 	}

--]]
function AuctionMarketFilterBar:ctor()
	cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
	self.sortBtnTb_ = {}

	self.labelCount_ = 8
	
	--background
 	local barBg = display.newSprite("#aucMar_bgGroupSort.png")
 	:addTo(self)
 	local barBgSize = barBg:getContentSize()
 	self:size(barBgSize.width,barBgSize.height)

 	

	self.width_ = barBgSize.width
	self.height_ = barBgSize.height


	self.labelCheckBoxGroup_ = nk.ui.CheckBoxButtonGroupEx.new()
	self.labelCheckBoxGroup_:onButtonSelectChanged(handler(self,self.onLabelCheckBoxGroupChangeed))
	self.labelCheckBoxGroup_:onButtonRepeatClicked(handler(self,self.onLabelCheckBoxGroupRepeatClicked))

end 


function AuctionMarketFilterBar:onLabelCheckBoxGroupRepeatClicked(event)
	print("onLabelCheckBoxGroupRepeatClicked", event.selected, event.last)
	if self.sortBtnTb_ and type(self.sortBtnTb_[event.selected]) == "userdata" then
		local angle = self.sortBtnTb_[event.selected]:getRotation()
		if angle == 0 then
			self:typeSortBtn(event.selected,1)
			self.sortBtnTb_[event.selected]:rotation(180)
		elseif angle == 180 then
			self.sortBtnTb_[event.selected]:rotation(0)
			self:typeSortBtn(event.selected,2)

		end
		
	end

	if 1 == event.selected then
		self:typeSortBtn2()

	end

	self:highlightSortLabel(event.selected)
end


function AuctionMarketFilterBar:onLabelCheckBoxGroupChangeed(event)
	print("onLabelCheckBoxGroupChangeed================================", event.selected, event.last)
	if self.sortBtnTb_ and type(self.sortBtnTb_[event.selected]) == "userdata" then
		local angle = self.sortBtnTb_[event.selected]:getRotation()
		if angle == 0 then
			self:typeSortBtn(event.selected,2)
		elseif angle == 180 then
			self:typeSortBtn(event.selected,1)

		end
	end

	

	if 1 == event.selected then
		self:typeSortBtn2()
	else
		if self.listBack_ then
			self:typeSortBtn2()
		end
	end

	-- self:performWithDelay(function()
		self:highlightSortLabel(event.selected)
	-- end,0.5)
end


function AuctionMarketFilterBar:setFilterBarBtnsEnable(tb)
	if not tb then
		return
	end

	for i = 1,#tb do
		local btn = self.labelCheckBoxGroup_:getButtonAtIndex(i)
		if btn then
			local enable = (tb[i] == 1 and true or false)
			btn:setButtonEnabled(enable)
			if not enable then
				self:disHighlightSortLabel(i)
				-- if i == 1 then
				-- 	if self.listBack_ then
				-- 		self:typeSortBtn2()
				-- 	end
				-- end
			end
		end
	end
end

function AuctionMarketFilterBar:setSortBtnTb(sortBtnTb)

	local newLen = #sortBtnTb
	local oldLen = 0

	if self.sortBtnTb_ then
		oldLen = #self.sortBtnTb_
		if oldLen > newLen then
			for i = newLen + 1,oldLen do
				if self.sortBtnTb_[i] and (type(self.sortBtnTb_[i]) == "userdata") then
					self.sortBtnTb_[i]:removeFromParent()
					self.sortBtnTb_[i] = 0
				end
			end
		end
	else
		self.sortBtnTb_ = {}
	end
	

	local labelMarLeft,labelMarRight = 8,8
 	local labelCount = #sortBtnTb
 	local labelW = (self.width_ - labelMarLeft - labelMarRight) / labelCount

	for i = 1,#sortBtnTb do
		if 1 == sortBtnTb[i] then
			local btn = self.labelCheckBoxGroup_:getButtonAtIndex(i)
			if btn and (not self.sortBtnTb_[i] or self.sortBtnTb_[i] == 0) then
				self.sortBtnTb_[i] = display.newSprite("#aucMar_arrowSortUp.png")
				local size = self.sortBtnTb_[i]:getContentSize()
				self.sortBtnTb_[i]:pos(labelW - size.width/2,0)
				:addTo(btn)
			end
			
		else
			if self.sortBtnTb_[i] and (type(self.sortBtnTb_[i]) == "userdata") then
				self.sortBtnTb_[i]:removeFromParent()
				self.sortBtnTb_[i] = 0
				
			end
			
		end
	end

end



function AuctionMarketFilterBar:setLabelTb(labelTb)
	local newLen = #labelTb
	local oldLen = 0
	local tempCount = 0
	local oldLen = self.labelCheckBoxGroup_:getButtonsCount()

	if oldLen > newLen then
		for i = newLen + 1,oldLen do
			self.labelCheckBoxGroup_:removeButtonAtIndex(i)
		end
	end
	

	local labelMarLeft,labelMarRight = 8,8
 	local labelCount = #labelTb
 	local labelW = (self.width_ - labelMarLeft - labelMarRight) / labelCount
 
 
 	for i = 1,labelCount do
 		local tempBtn = self.labelCheckBoxGroup_:getButtonAtIndex(i)
 		if tempBtn then
			tempBtn:setButtonSize(labelW, 24)
			:setButtonLabelOffset(-labelW*0.5,0)
			:align(display.CENTER_LEFT)
			tempBtn:setButtonLabelString(labelTb[i])
        	:pos(-self.width_ * 0.5 + labelW * (i-1) + labelMarLeft,0)
 		else
			local btn = cc.ui.UICheckBoxButton.new({
                on = "#common_transparent_skin.png",
                off = "#common_transparent_skin.png",
                off_disabled = "#common_transparent_skin.png",
            }, {scale9=true})
	        :setButtonLabel(display.newTTFLabel({text = labelTb[i], size = 24, align = ui.TEXT_ALIGN_CENTER,color = cc.c3b(0xff,0x93,0xb3),dimensions = cc.size(labelW-3, 0)})
	        	)
	        :setButtonSize(labelW, 24)
	        :align(display.CENTER_LEFT)
	        :setButtonLabelOffset(-labelW*0.5,0)
	        :pos(-self.width_ * 0.5 + labelW * (i-1) + labelMarLeft,0)
	        :addTo(self)
			self.labelCheckBoxGroup_:addButton(btn)
 		end
 		
 	end

end


function AuctionMarketFilterBar:hideTypeList()
	if self.listBack_ then
		self.listBack_:removeFromParent()
		self.list_:removeFromParent()
		self.list_ = nil
		self.listBack_ = nil

	end
	self:disHighlightSortLabel(1)
end

function AuctionMarketFilterBar:typeSortBtn(index,state)
	-- dump("index:" .. index .. " state:" .. state,(state == 1 and "升序" or "降序"))
	self:dispatchEvent({name="FILTER_BAR_SORT_EVENT", data = {index = index,state = state}})
end

function AuctionMarketFilterBar:typeSortBtn2()

	if self.listBack_ then
		self.listBack_:removeFromParent()
		self.list_:removeFromParent()
		self.list_ = nil
		self.listBack_ = nil
	else
		local initDatas = self.controller_:getInitInfo()
		if not initDatas then
			return
		end
		self.listBack_ = display.newScale9Sprite("#aucMar_typeItem.png", 0, 0, cc.size(LIST_WIDTH,LIST_HEIGHT))
		:addTo(self)
		:pos(-370,-67)
		self.list_ = bm.ui.ListView.new(
	            {
	                viewRect = cc.rect(-LIST_WIDTH * 0.5, -LIST_HEIGHT * 0.5, LIST_WIDTH, LIST_HEIGHT),
	                direction = bm.ui.ListView.DIRECTION_VERTICAL
	            }, 
	            AucteFilterListItem
	        )
	        :pos(-370,-67)
	        :addTo(self)
	    self.list_:addEventListener("ITEM_EVENT", handler(self, self.onItemEvent_))
	    
	    -- dump(initDatas,"AuctionMarketFilterBar:typeSortBtn2")
	    if initDatas.item then
	    	self.list_:setData(initDatas.item)
	    end
	    -- if self.setFilterTypeFun_ then
	    -- 	self.setFilterTypeFun_()
	    -- else

	    -- end

	end
end


function AuctionMarketFilterBar:setFilterTypes(tb)
	-- self.setFilterTypeFun_ = nil
	-- if self.list_ then
	-- 	self.list_:setData(tb)
	-- else
	-- 	self.setFilterTypeFun_ = function()
	-- 		self.list_:setData(tb)
	-- 	end
	-- end
	
end


function AuctionMarketFilterBar:setDelegate(delegate)
    self.delegate_ = delegate
end

function AuctionMarketFilterBar:setController(controller)
    self.controller_ = controller
end


function AuctionMarketFilterBar:onItemEvent_(event)
	local data = event.data
	if not data then
		return
	end

	local btn = self.labelCheckBoxGroup_:getButtonAtIndex(1)
	if btn then
		btn:setButtonLabelString(data.name)
	end

	self.listBack_:removeFromParent()
	self.list_:removeFromParent()
	self.list_ = nil
	self.listBack_ = nil

	self:highlightSortLabel(1)

	self:dispatchEvent({name="FILTER_BAR_TYPE_SELECT_EVENT", data = data})
end


function AuctionMarketFilterBar:disHighlightSortLabel(index)
	local count = self.labelCheckBoxGroup_:getButtonsCount()
	for i=1,count do
		local btn = self.labelCheckBoxGroup_:getButtonAtIndex(i)
		if btn then
			local label = btn:getButtonLabel("off")
			
			if label then
				if i == index then
					label:setTextColor(cc.c3b(0xff,0x93,0xb3))
				end
			end
			
		end
		
		
	end
end

function AuctionMarketFilterBar:highlightSortLabel(index)
	local count = self.labelCheckBoxGroup_:getButtonsCount()


	for i=1,count do
		local btn = self.labelCheckBoxGroup_:getButtonAtIndex(i)
		if btn then
			local label = btn:getButtonLabel("off")
			
			if label then
				if i ~= index then
					-- dump("setOtherLabelcolor")
					label:setTextColor(cc.c3b(0xff,0x93,0xb3))
					-- label:setTextColor(cc.c3b(0xff,0x6e,0x6e))
				else
					label:setTextColor(cc.c3b(0xff,0xd4,0x44))
					-- 0xff,0x93,0xb3
					-- ffd544
					-- label:setTextColor(cc.c3b(0xff,0xff,0xff))
					-- dump("setselectLabelcolor")
				end
			end
			
		end
		
		
	end
end

return AuctionMarketFilterBar