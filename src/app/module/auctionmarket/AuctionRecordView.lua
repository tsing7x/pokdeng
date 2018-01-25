-- Author: Vanfo
-- Date: 2016-01-8 14:20:00

local AuctionRecordListItem = import(".AuctionRecordListItem")

--拍卖记录视图
local AuctionRecordView = class("AuctionRecordView",function()
    return display.newNode()
end)

local LIST_WIDTH = 863
local LIST_HEIGHT = 355

-- local listDataGlobal = {}
function AuctionRecordView:ctor()
	self:setNodeEventEnabled(true)
	self:createListView_()

	-- self:setListData({1,2,3,4,5,6,7,8,9})
    self.notDataTipsLabel_ = display.newTTFLabel({text = bm.LangUtil.getText("AUCTION_MARKET", "NOT_RECODE_TIP"), size = 30, align = ui.TEXT_ALIGN_CENTER,color = cc.c3b(0xff,0x93,0xb3)})  
        :pos(0,50)
        :addTo(self)
        :hide()
end

function AuctionRecordView:setIndex(index)
    self.index_ = index
end


function AuctionRecordView:getIndex()
    return self.index_
end


function AuctionRecordView:setDelegate(delegate)
    self.delegate_ = delegate
end

function AuctionRecordView:setController(controller)
    self.controller_ = controller
end


function AuctionRecordView:createListView_()
	if not self.list_ then
		self.list_ = bm.ui.ListView.new(
            {
                viewRect = cc.rect(-LIST_WIDTH * 0.5, -LIST_HEIGHT * 0.5, LIST_WIDTH, LIST_HEIGHT),
                upRefresh = handler(self, self.onListUpFrefresh_)
            }, 
            AuctionRecordListItem
        )
        :pos(0, 0)
        :addTo(self)

	end

end

--列表上拉刷新
function AuctionRecordView:onListUpFrefresh_()
    
end


function AuctionRecordView:onFilterBarTypeSelect(typeData)
    if not self.listDatas_ then
        return
    end
    self.typeData_ = typeData
    
    -- listDataGlobal = clone(self.listDatas_)

    if not typeData or (typeData.category == 0) then
        self.list_:setData(self.listDatas_)
    else
        local tempArr = {}
        for _,v in pairs(self.listDatas_) do
            if v.category == typeData.category then
                table.insert(tempArr,v)
            end
        end

        self.list_:setData(tempArr)
    end
    
end


function AuctionRecordView:getAuctionRecordData()
    self.controller_:getAuctionRecordData()
end


function AuctionRecordView:onGetAuctionRecordDataSucc_(data)
    self.listDatas_ = data
    if (not self.listDatas_) or (0 == #self.listDatas_) then
        self.notDataTipsLabel_:show()
        self.list_:hide()
    else
        self.notDataTipsLabel_:hide()
        self.list_:setData(data)
        self.list_:show()
    end

    
    
end



function AuctionRecordView:setListData(data)
    data = data or {}
	self.list_:setData(data)
end

return AuctionRecordView