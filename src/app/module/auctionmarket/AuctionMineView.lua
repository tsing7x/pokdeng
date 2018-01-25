-- Author: Vanfo
-- Date: 2016-01-8 14:20:00

local AuctionMineListItem = import(".AuctionMineListItem")

--我的拍卖视图
local AuctSellProdPopup = import(".AuctSellProdPopup")
-- local listDataGlobal = {}
local AuctionMineView = class("AuctionMineView",function()
    return display.newNode()
end)

local LIST_WIDTH = 863
local LIST_HEIGHT = 220


function AuctionMineView:ctor()
	self:setNodeEventEnabled(true)
	-- self:createListView_()

	-- self:setListData({1,2,3,4,5,6,7,8,9})
    self.cur_pages = 0
    self.total_pages = 1

    self.auctionTipTitle_ = display.newTTFLabel({text = bm.LangUtil.getText("AUCTION_MARKET","READING_TITLE"), size = 24, align = ui.TEXT_ALIGN_CENTER,color = cc.c3b(0xff,0xff,0xff)})
        :align(display.CENTER_LEFT)
        :pos(-LIST_WIDTH*0.5, -LIST_HEIGHT * 0.5-20)
        :addTo(self)

        local tipTb = bm.LangUtil.getText("AUCTION_MARKET","READING_CONTENT")
        local str = ""
        for i=1,#tipTb do
            str = str.. tipTb[i] .." \n"
        end
        
        display.newTTFLabel({text = str, size = 18,color = cc.c3b(0xff,0xff,0xff),dimensions = cc.size(835, 115), align=ui.TEXT_ALIGN_LEFT})
        :align(display.LEFT_TOP)
        :pos(-LIST_WIDTH*0.5, -LIST_HEIGHT * 0.5-30)
        :addTo(self)

        --404 114
        display.newSprite("#aucMar_myCardBg.png")
        :addTo(self)
        :pos(-LIST_WIDTH*0.5+657, -LIST_HEIGHT * 0.5-70)
        :hide()

        display.newTTFLabel({text = bm.LangUtil.getText("AUCTION_MARKET","MY_EXCHANGEABLE_ITEM_TITLE"), size = 20,color = cc.c3b(0xff,0xff,0xff), align=ui.TEXT_ALIGN_LEFT})
        :align(display.LEFT_TOP)
        :pos(-LIST_WIDTH*0.5+465, -LIST_HEIGHT * 0.5-20)
        :addTo(self)
        :hide()

        self.exchangableLabel_ =  display.newTTFLabel({text = bm.LangUtil.getText("AUCTION_MARKET","MY_EXCHANGEABLE_ITEM_TIP"), size = 20,color = cc.c3b(0xff,0xff,0xff), align=ui.TEXT_ALIGN_LEFT})
        :align(display.LEFT_TOP)
        :pos(-LIST_WIDTH*0.5+600, -LIST_HEIGHT * 0.5-60)
        :addTo(self)
        :hide()

end


function AuctionMineView:setIndex(index)
    self.index_ = index
end


function AuctionMineView:getIndex()
    return self.index_
end


function AuctionMineView:setDelegate(delegate)
    self.delegate_ = delegate
end

function AuctionMineView:setController(controller)
    self.controller_ = controller
end

function AuctionMineView:createListView_()
	if not self.list_ then
		self.list_ = bm.ui.ListView.new(
            {
                viewRect = cc.rect(-LIST_WIDTH * 0.5, -LIST_HEIGHT * 0.5, LIST_WIDTH, LIST_HEIGHT),
                upRefresh = handler(self, self.onListUpFrefresh_)
            }, 
            AuctionMineListItem
        )
        :pos(0, 0)
        :addTo(self)
        self.list_.controller_ = self.controller_
        self.list_:addEventListener("ITEM_EVENT", handler(self, self.onItemEvent_))
	end

end


function AuctionMineView:onItemEvent_(evt)
    local data = evt.data
    --次数应该弹出添加竞拍物品框
    -- dump(data, "AuctionMineView.data:===============")

    local defualtAuctSellType = 1

    AuctSellProdPopup.new(defualtAuctSellType, self.controller_):showPanel()
end


function AuctionMineView:getMyAuctionData()
    self.controller_:getMyAuctionData()
end


function AuctionMineView:sortTbByKey(tb,state,key)
    table.sort(tb,function(t1,t2)
        if state == 1 then
            return (t1[key] > t2[key])
        else
            return (t1[key] < t2[key])
        end
        
    end)
end

function AuctionMineView:sortTbByKeySpec(tb,state)
    table.sort(tb,function(t1,t2)
        local expire1 = t1.expire
        local now1 = t1.now
        local remainTime1 = expire1 - now1

        local expire2 = t2.expire
        local now2 = t2.now
        local remainTime2 = expire2 - now2 

        if state == 1 then
            return (remainTime1 > remainTime2)
        else
            return ( remainTime1 < remainTime2)
        end
       
    end)
end

function AuctionMineView:onFilterBarSort(index,state)
   
    if self.listDatas_ then
        if index == 3 then
            self:sortTbByKey(self.listDatas_,state,"money")
        elseif index == 4 then  
            self:sortTbByKey(self.listDatas_,state,"prentmoney")
        elseif index == 5 then
            self:sortTbByKeySpec(self.listDatas_,state)
        end
        -- self.list_:setData(self.listDatas_)
    end


    -- if listDataGlobal  then
    --     if index == 3 then
    --         self:sortTbByKey(listDataGlobal,state,"money")
    --     elseif index == 4 then  
    --         self:sortTbByKey(listDataGlobal,state,"prentmoney")
    --     elseif index == 5 then
    --         self:sortTbByKeySpec(listDataGlobal,state)
    --     end
    -- end 

    local tempTb
    if self.list_ then
        tempTb = self.list_:getData()
        if tempTb then
            if index == 3 then
                self:sortTbByKey(tempTb,state,"money")
            elseif index == 4 then  
                self:sortTbByKey(tempTb,state,"prentmoney")
            elseif index == 5 then
                self:sortTbByKeySpec(tempTb,state)
            end
        end
    end 

    if self.list_ and tempTb then
        self:createListView_()
        self.list_:setData(tempTb)
    end
    
end


function AuctionMineView:onFilterBarTypeSelect(typeData)
    if not self.listDatas_ then
        return
    end
    self.typeData_ = typeData

    -- listDataGlobal = clone(self.listDatas_)

    if not typeData or (typeData.category == 0) then
        self:createListView_()
        self.list_:setData(self.listDatas_)
    else
        local tempArr = {}
        for _,v in pairs(self.listDatas_) do
            if v.category == typeData.category then
                table.insert(tempArr,v)
            end
        end
        self:createListView_()
        self.list_:setData(tempArr)
    end
    
end


function AuctionMineView:onGetMyAuctionDataSucc_(data)


    local tempData = {}
    for i = 1,3 do
        if (not data) or (not data.itemdata) or (not data.itemdata[i]) then
            table.insert(tempData,{isEmpty = 1})
        else
            data.itemdata[i].isEmpty = 0
            table.insert(tempData,data.itemdata[i])
        end
    end
    self.listDatas_ = tempData
    self:createListView_()
    self.list_:setData(tempData)
end

--列表上拉刷新
function AuctionMineView:onListUpFrefresh_()
    
end

function AuctionMineView:setListData(data)
    self:createListView_()
	self.list_:setData(data)
end

return AuctionMineView