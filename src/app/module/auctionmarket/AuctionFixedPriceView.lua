-- Author: Vanfo
-- Date: 2016-01-8 14:20:00
local AucteProdFixedPricePopup = import(".AucteProdFixedPricePopup")
local AuctionFixedPriceListItem = import(".AuctionFixedPriceListItem")
-- local listDataGlobal = {}
--一口价拍卖视图
local AuctionFixedPriceView = class("AuctionFixedPriceView",function()
    return display.newNode()
end)

local LIST_WIDTH = 863
local LIST_HEIGHT = 355


function AuctionFixedPriceView:ctor()
	self:setNodeEventEnabled(true)
	-- self:createListView_()

	-- self:setListData({1,2,3,4,5,6,7,8,9})
    self.cur_pages = 0
    self.total_pages = 1
    self.notDataTipsLabel_ = display.newTTFLabel({text = bm.LangUtil.getText("AUCTION_MARKET", "NOT_DATA_TIP"), size = 30, align = ui.TEXT_ALIGN_CENTER,color = cc.c3b(0xff,0x93,0xb3)})  
        :pos(0,50)
        :addTo(self)
        :hide()
end

function AuctionFixedPriceView:setIndex(index)
    self.index_ = index
end


function AuctionFixedPriceView:getIndex()
    return self.index_
end


function AuctionFixedPriceView:setDelegate(delegate)
    self.delegate_ = delegate
end

function AuctionFixedPriceView:setController(controller)
    self.controller_ = controller
end


function AuctionFixedPriceView:reset()
    self.cur_pages = 0
    self.total_pages = 1
    self.listDatas_ = {}
    if self.list_ then
        self.list_:setData({})
    end
    
end


function AuctionFixedPriceView:getAuctionFixedPriceData()
    self:requestListDataByPage()
end


function AuctionFixedPriceView:sortTbByKey(tb,state,key)
    table.sort(tb,function(t1,t2)
        if state == 1 then
            return (t1[key] > t2[key])
        else
            return (t1[key] < t2[key])
        end
        
    end)
end

function AuctionFixedPriceView:sortTbByKeySpec(tb,state)
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

function AuctionFixedPriceView:onFilterBarSort(index,state)
   
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
        self.list_:setData(tempTb)
    end
    
end

function AuctionFixedPriceView:onFilterBarTypeSelect(typeData)
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


-- 根据页码请求数据
function AuctionFixedPriceView:requestListDataByPage()
    if self.cur_pages >= self.total_pages then
        -- dump("not data","requestGrabRoomListDataByPage")
        return
    end

    self.cur_pages = self.cur_pages + 1
    -- 调用接口
    --category,curPage,pageNum,sortkey,order
    self.controller_:getAuctionFixedPriceData(nil,self.cur_pages,PAGE_ITEM_NUM,nil,nil)

end


function AuctionFixedPriceView:createListView_(datas)
    if not self.list_ then
        self.list_ = bm.ui.ListView.new(
            {
                viewRect = cc.rect(-LIST_WIDTH * 0.5, -LIST_HEIGHT * 0.5, LIST_WIDTH, LIST_HEIGHT),
                upRefresh = handler(self, self.onListUpFrefresh_)
            }, 
            AuctionFixedPriceListItem
        )
        :pos(0, 0)
        :addTo(self)
        self.list_.controller_ = self.controller_
        self.list_:addEventListener("ITEM_EVENT", handler(self, self.onItemEvent_))

    end

    if datas then
         self.list_:appendData(datas)
    end

end

function AuctionFixedPriceView:onItemEvent_(evt)
    -- dump(evt,"AuctionFixedPriceView:onItemEvent_")

    local userLevelFact = nk.Level:getLevelByExp(nk.userData["aUser.exp"])
    if userLevelFact < 10 then
        --todo
        nk.CenterTipManager:showCenterTip({text = bm.LangUtil.getText("AUCTION_MARKET", "NOT_ENOUGH_LEVEL_FOR_FIXED_PRICE"), messageType = 1000})

        return
    end
    
    if nk.userData["aUser.money"] < 10000000 then
        --todo
        nk.CenterTipManager:showCenterTip({text = bm.LangUtil.getText("AUCTION_MARKET", "NOT_ENOUGH_MONEY_FOR_FIXED_PRICE"), messageType = 1000})

        return
    end

    local data = evt.data
    --次数应该弹出竞拍框
    -- dump(data, "AuctionFixedPriceView.data:==============")

    local prodAttr = {}

    if data.typeName then
        --todo
        prodAttr.contName = data.typeName .. "*" .. (data.num or 0)
    end
    
    prodAttr.nickName = data.nick
    prodAttr.imgUrl = data.imgurl
    prodAttr.timeRemain = data.timeCount or 0  -- timeRemain 由 evt.data 中countDown数值而来 
    prodAttr.price = data.money or 0
    prodAttr.itemId = data.itemid

    AucteProdFixedPricePopup.new(prodAttr, self.controller_):showPanel()
end


function AuctionFixedPriceView:onGetAuctionFixedPriceDataSucc_(data,params)
    if data and data.data then

        local oldPage = self.cur_pages
        self.total_pages = data.pagecount or 1
        self.cur_pages = data.currentpage or 0

        if not self.listDatas_ then
            self.listDatas_ = {}
        end

        local origData = data.data

        local tempArr = {}
        local count = 0
        local newItemId
        local oldItemId
        for _,new in pairs(origData) do
            -- dump(new,"origData")
            count = 0
            newItemId = (new.itemid) or -1
            for __,old in pairs(self.listDatas_) do
                oldItemId = (old.itemid) or -1

                -- dump(oldItemId == newItemId,"filltempArr111")
                -- dump(oldItemId,"filltempArr2222")
                -- dump(newItemId,"filltempArr33333")
                if (oldItemId ~= -1 and newItemId ~= -1 ) and (oldItemId == newItemId) then
                    break
                end
                count = count + 1
               
            end
            if count == #self.listDatas_ then
                table.insert(tempArr,new)
            end
           
        end

        -- dump(tempArr,"filltempArr")
        table.insertto(self.listDatas_,tempArr)

        local tempItemsArr
        if self.typeData_ then
            tempItemsArr = {}
            for _,v in pairs(tempArr) do
                if v.category == self.typeData_.category then
                    table.insert(tempItemsArr,v)
                end
            end
        end

        if tempItemsArr and #tempItemsArr > 0 then
            self:createListView_(tempItemsArr)
        else
            self:createListView_(tempArr)
        end
        
        -- self:createListView_(tempArr)
    end

    if (not self.listDatas_) or (0 == #self.listDatas_) then
        self.notDataTipsLabel_:show()
        self.list_:hide()
    else
        self.notDataTipsLabel_:hide()
        self.list_:show()
    end
    
end



--列表上拉刷新
function AuctionFixedPriceView:onListUpFrefresh_()
    self:requestListDataByPage()
end



function AuctionFixedPriceView:setListData(data)
	self.list_:setData(data)
end


return AuctionFixedPriceView