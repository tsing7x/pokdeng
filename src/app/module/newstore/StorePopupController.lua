--
-- Author: tony
-- Date: 2014-11-17 16:33:16
--
local PurchaseServiceManager = import(".PurchaseServiceManager")
local LoadGiftControl = import("app.module.gift.LoadGiftControl")
local StorePopupController = class("StorePopupController")
local logger = bm.Logger.new("StorePopupController")

local test_json_pay_config = [[
            {
                "ret":0,
                "payTypes":[
                    {
                        "id":100,
                        "name":"GooglePlay",
                        "configURL":"http://d147wns3pm1voh.cloudfront.net/static/nineke/nineke/json/android-53a02243.json",
                        "deliveryURL":"http://d25t7ht5vi1l2.cloudfront.net/androidpay.php",
                        "discount":{
                            "com.boomegg.nineke.450k":1.2
                        },
                        "chipDiscount":1.1
                    },
                    {
                        "id":200,
                        "name":"AppStore",
                        "configURL":"http://d147wns3pm1voh.cloudfront.net/static/nineke/nineke/json/ios-bbc2affd.json",
                        "discount":{
                            "com.boomegg.nineke.450k":1.2
                        },
                        "chipDiscount":1.1
                    },
                    {
                        "id":400,
                        "name":"",
                        "configURL":"",
                        "purchaseURL":"",
                        "discount":{
                            "com.boomegg.nineke.450k":1.2
                        },
                        "chipDiscount":1.1
                    },
                ]
            }
]]


local testPayType = 
{

    
   ---[[
        {
            ["id"]= 504,
            ["name"]= "12call",
            ["purchaseURL"]= "",
            ["configURL"]= "http://pirates133.by.com/pokdeng/staticres/data/androidtl/12call-yk-20150717.json",
            ["deliveryURL"]= "",
            ["pmode"] = "472",
            ["discount"]={
                
            },
            ["chipDiscount"]= 1,
            ["moneyDiscount"]= 1,
            ["maxDiscount"]= 1
        },
        
        {
            ["id"]= 100,
            ["name"]= "GooglePlay",
            ["configURL"]= "http://pirates133.by.com/pokdeng/staticres/data/androidtl/android-yk-20150708.json",
            ["deliveryURL"]= "",
            ["discount"]= {},
            ["pmode"] = "12",
            ["chipDiscount"]= 1,
            ["moneyDiscount"]= 1,
            ["maxDiscount"]= 1
        },
        
        {
            ["id"]= 601,
            ["name"]= "BluePay",
            ["configURL"]= "http://pirates133.by.com/pokdeng/staticres/data/androidtl/BluePay-yk-20150721.json",
            -- ["configURL"]= "http://138.128.204.205/BluePay-yk-20150721.json",
            ["deliveryURL"]= "",
            ["discount"]= {},
            ["pmode"] = "240",
            ["chipDiscount"]= 1,
            ["moneyDiscount"]= 1,
            ["maxDiscount"]= 1,
            ["smsIds"] = {
            -- ["120340"] = 41,["12341"]=42,["120342"] = 43 ,["120343"]= 44 --FB 
            ["120344"] = 41,["12345"]=42,["120346"] = 43,["120347"]= 44} --游客
        }
    
    --]]
}


function StorePopupController:ctor(view)
    self.view_ = view
    self.manager_ = PurchaseServiceManager.new()
    -- self.schedulerPool_ = bm.SchedulerPool.new()
end

function StorePopupController:loadPayConfig()
    logger:debug("loadPayConfig ..")

    -- if false then
    --     local tb = testPayType
    --     local payTypeAvailable = {}
    --     for i, p in ipairs(tb) do
    --         if self.manager_:isServiceAvailable(p.id) then
    --             payTypeAvailable[#payTypeAvailable + 1] = p
    --         end
    --     end                                                                                                                                                          
    --     self.manager_:init(payTypeAvailable)
    --     self.view_:createMainUI(payTypeAvailable)
    --     return
    -- end

    local retryTimes = 3
    self.loadPayConfig_ = function ()
        -- dump(BM_UPDATE.VERSION, "BM_UPDATE.VERSION :=============")
        self.loadPayConfigId_ = nk.http.getPayTypeConfig(BM_UPDATE.VERSION,
        function(data)
            -- dump(data, "nk.http.getPayTypeConfig.data :==================")

            if data then
                logger:debug("loadPayConfig complete")
                local payTypeAvailable = {}
                for i, p in ipairs(data) do
                    if self.manager_:isServiceAvailable(p.id) then
                        payTypeAvailable[#payTypeAvailable + 1] = p
                    end
                end                                                                                                                                                          
                self.manager_:init(payTypeAvailable)

                -- dump(payTypeAvailable, "payTypeAvailable :==============")
                self.view_:createMainUI(payTypeAvailable)
            else
                retryTimes = retryTimes - 1
                if retryTimes > 0 then
                    self.loadPayConfig_()
                else
                    nk.badNetworkToptip()
                    self.view_:hidePanel()
                end
            end
        end,
        function()
            retryTimes = retryTimes - 1
            if retryTimes > 0 then
                self.loadPayConfig_()
            else
                nk.badNetworkToptip()
                self.view_:hidePanel()
            end
        end)
    end
    self.loadPayConfig_()
end

function StorePopupController:getPurchaseService_(paytype)
    return self.manager_:getPurchaseService(paytype.id)
end

function StorePopupController:loadChipProductList(paytype)
    local service = self:getPurchaseService_(paytype)
    service:loadChipProductList(handler(self, self.loadChipProductListResult_))
end

function StorePopupController:loadChipProductListResult_(paytype, isComplete, data)
    self.view_:setChipList(paytype, isComplete, data)
end

function StorePopupController:loadTicketProductList(paytype)
    local service = self:getPurchaseService_(paytype)
    service:loadTicketProductList(handler(self, self.loadTicketProductListResult_))
end

function StorePopupController:loadTicketProductListResult_(paytype, isComplete, data)
    self.view_:setTicketList(paytype, isComplete, data)
end

-- 添加load现金币订单的配置
function StorePopupController:loadCashProductList(payType)
    -- body
    local service = self:getPurchaseService_(payType)
    service:loadCashProductList(handler(self, self.loadCashProductListResult_))
end

function StorePopupController:loadCashProductListResult_(paytype, isComplete, data)
    -- body
    self.view_:setCashPaymentList(paytype, isComplete, data)
end

function StorePopupController:loadPropProductList(paytype)
    local service = self:getPurchaseService_(paytype)
    service:loadPropProductList(handler(self, self.loadPropProductListResult_))
end

function StorePopupController:loadPropShopProductList(propType)
    -- body
    local getPropShopProductListByType = {
        [1] = function()
            -- body
            -- self.hotGift_ = self.hotGift_ or {}
            -- self.boutiqueGift_ = self.boutiqueGift_ or {}
            -- self.festivalGift_ = self.festivalGift_ or {}
            -- self.otherGift_ = self.otherGift_ or {}

            if not self.selfShopGiftData then
                self.hotGift_ = {}
                self.boutiqueGift_ = {}
                self.festivalGift_ = {}
                self.otherGift_ = {}

                LoadGiftControl:getInstance():loadConfig(nk.userData.GIFT_JSON, function(success, data)
                    if success then
                        self.selfShopGiftData_ = data

                        -- dump(self.selfShopGiftData_, "self.selfShopGiftData_ :===================")
                        for i = 1, #data do
                            if data[i].status == "1"  then
                                if data[i].gift_category == "0" then
                                    table.insert(self.hotGift_, data[i])
                                elseif data[i].gift_category == "1" then
                                    table.insert(self.boutiqueGift_, data[i])
                                elseif data[i].gift_category == "2" then
                                    table.insert(self.festivalGift_, data[i])
                                elseif  data[i].gift_category == "3" then 
                                    table.insert(self.otherGift_, data[i])
                                end
                            end
                        end

                        -- dump(self.hotGift_, "self.hotGift_:==================")
                        -- self.view_:onPropListDataGet(propType)
                    else

                        if self.view_ and self.view_.onGetPropDataWrong then
                            --todo
                            self.view_:onGetPropDataWrong(propType)
                        end
                        -- self.view_:setLoading(false)
                    end
                end)
            end
        end,

        [2] = function()
            -- body
            self.requestPropShopListId_ = nk.http.getPropShopProdList(function(data)
                -- body
                -- dump(data, "data:==============")
                if data then
                    --todo
                    self.propShopDataList_ = {}
                    for i = 1, #data do
                        local propListDataItem = {}
                        propListDataItem.idx_ = i
                        propListDataItem.data_ = data[i]

                        table.insert(self.propShopDataList_, propListDataItem)
                    end

                    if self.view_ then
                        --todo
                        self.view_:onPropListDataGet()
                    end
                end
                self.requestPropShopListId_ = nil
            end,
            function(errData)
                -- body
                -- dump(errData, "errData:=================")
                self.requestPropShopListId_ = nil
                if self.view_ and self.view_.onGetPropDataWrong then
                    --todo
                    self.view_:onGetPropDataWrong(propType)
                end
            end)
        end
    }

    getPropShopProductListByType[propType]()

end

function StorePopupController:buyGiftRequest(giftId, callback)
    -- body
    if self.buyGiftRequestId_ then
        return 
    end
    -- dump(giftId, "nk.http.giftBuy @param giftId :==================")

    self.buyGiftRequestId_ = nk.http.giftBuy(giftId, nk.userData.uid, function(data)
        -- dump(data, "nk.http.giftBuy.retData :==================")
        if data then
            
            local money = checkint(data.money)
            local subMoney = checkint(data.subMoney)

            if money and money>=0 then
                nk.userData["aUser.money"] = money
            end
            if data.addMoney then
                local addMoney = checkint(data.addMoney)
                bm.EventCenter:dispatchEvent({name = nk.eventNames.UPDATE_SEAT_ANTE_CHIP, data = {chip = addMoney}})
            end
            self.purchGiftId_ = giftId
            -- nk.userData["aUser.gift"] = giftId
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("GIFT", "BUY_GIFT_SUCCESS_TOP_TIP"))

            if data.addMoney then
                local addMoney = checkint(data.addMoney)
                bm.EventCenter:dispatchEvent({name = nk.eventNames.UPDATE_SEAT_ANTE_CHIP, data = {chip = addMoney}})
            end

            if callback then
                callback()
            end
            -- if isRoom then
            --     -- nk.socket.RoomSocket:sendSetGift(self.selectGiftId_, nk.userData.uid)
            --     nk.server:sendRoomGift(self.selectGiftId_,{nk.userData.uid})
            -- end
            -- bm.EventCenter:dispatchEvent({name = nk.eventNames.HIDE_GIFT_POPUP})

            -- self:useBuyGiftRequest(giftId)
            -- self.view_:hidePanel()
        end
         self.buyGiftRequestId_ = nil
    end,function(errData)
        dump(errData, "nk.http.giftBuy.errData :==================")

        if errData.errorCode == - 6 then
            --todo
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("GIFT", "FAILD_NOTENOUGH_MONEY"))
        else
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("GIFT", "BUY_GIFT_FAIL_TOP_TIP"))
        end
        self.buyGiftRequestId_ = nil
    end)
end

function StorePopupController:useBuyGiftRequest()
    -- body
    if self.purchGiftId_ == nk.userData["aUser.gift"] or not self.purchGiftId_ then
        return 
    end
   
    nk.http.useProps(self.purchGiftId_, function(data)
        -- local callBackBuyData =  json.decode(data)
        -- local callBackBuyData =  data
        -- if callBackBuyData.ret == 1 then
            nk.userData["aUser.gift"] = self.purchGiftId_
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("GIFT", "SET_GIFT_SUCCESS_TOP_TIP"))
            -- if isRoom then
            --     nk.server:sendRoomGift(self.selectGiftId_,{nk.userData.uid})
            --     -- nk.socket.RoomSocket:sendSetGift(self.selectGiftId_, nk.userData.uid)
            -- end
            -- bm.EventCenter:dispatchEvent({name = nk.eventNames.HIDE_GIFT_POPUP})
        -- else
        --     nk.TopTipManager:showTopTip(bm.LangUtil.getText("GIFT", "SET_GIFT_FAIL_TOP_TIP"))
        -- end
        -- self.buyGiftRequestId_ = nil
    end,function()
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("GIFT", "SET_GIFT_FAIL_TOP_TIP"))
        -- self.buyGiftRequestId_ = nil
    end)
end

-- 给牌桌上某人购买
function StorePopupController:presentGiftToUid(giftId, toUid)
    -- body
    if self.presentGiftRequestId_ then
        --todo
        return
    end

    -- dump(giftId, "nk.http.giftBuy @param giftId :==================")
    if toUid == nk.userData.uid then
        --todo
        self:buyGiftRequest(giftId, function()
            nk.server:sendRoomGift(giftId, {toUid})
        end)
        
    else
        self.presentGiftRequestId_ = nk.http.giftBuy(giftId, toUid, function(data)

            -- dump(data, "nk.http.giftBuy.retData :====================")
            if data then
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("GIFT", "PRESENT_GIFT_SUCCESS_TOP_TIP"))
                --赠送礼物成功

                local money = checkint(data.money)
                local subMoney = checkint(data.subMoney)

                if money and money>=0 then
                    nk.userData["aUser.money"] = money
                end
                if data.addMoney then
                    local addMoney = checkint(data.addMoney)
                    bm.EventCenter:dispatchEvent({name = nk.eventNames.UPDATE_SEAT_ANTE_CHIP, data = {chip = addMoney}})
                end
                -- nk.socket.RoomSocket:sendPresentGift(self.selectGiftId_, nk.userData.uid, {self.uid_})
                nk.server:sendRoomGift(giftId, {toUid})

                if self.view and self.view_.hidePanel then
                    --todo
                    self.view_:hidePanel()
                end
                
                -- bm.EventCenter:dispatchEvent({name = nk.eventNames.HIDE_GIFT_POPUP})
            end
            self.presentGiftRequestId_ = nil
        end,function(errData)
                -- nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
                dump(errData, "nk.http.giftBuy.errData :====================")
                if errData.errorCode == - 6 then
                    --todo
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("GIFT", "FAILD_NOTENOUGH_MONEY"))
                else
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("GIFT", "BUY_GIFT_FAIL_TOP_TIP"))
                end
                self.presentGiftRequestId_ = nil
        end)
    end
    -- 参考 --
end

-- 给全桌购买
function StorePopupController:presentGiftToTable(giftId, toUidArr, allTableId)
    -- body
    if self.presentTableGiftRequestId_ then
        --todo
        return
    end
    self.presentTableGiftRequestId_ = nk.http.giftBuy(giftId, allTableId, function(data)
        if data then
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("GIFT", "PRESENT_TABLE_GIFT_SUCCESS_TOP_TIP"))

            nk.server:sendRoomGift(giftId, toUidArr)
            -- bm.EventCenter:dispatchEvent({name = nk.eventNames.HIDE_GIFT_POPUP})
            if data.addMoney then
                local addMoney = checkint(data.addMoney)
                bm.EventCenter:dispatchEvent({name = nk.eventNames.UPDATE_SEAT_ANTE_CHIP, data = {chip = addMoney}})
            end
            if self.view_ and self.view_.hidePanel then
                --todo
                self.view_:hidePanel()
            end
        end
        self.presentTableGiftRequestId_ = nil
    end,function(errData)
        dump(errData, "nk.http.giftBuy.errData :=====================")
        if errData.errorCode == - 6 then
            --todo
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("GIFT", "FAILD_NOTENOUGH_MONEY"))
        else
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("GIFT", "PRESENT_TABLE_GIFT_FAIL_TOP_TIP"))
        end
        self.presentTableGiftRequestId_ = nil
    end)
end

function StorePopupController:buyPropsById(propsPackId)
    -- body
    if self.buyPropsPackRequestId_ then
        --todo
        return
    end
    
    self.buyPropsPackRequestId_ = nk.http.buyProps(propsPackId, function (data)
        -- body
        -- dump(data, "buyProps.data:===============")

        nk.TopTipManager:showTopTip(bm.LangUtil.getText("STORE", "BUY_PROPPACK_SUCC"))
        nk.userData["aUser.money"] = data.money
        nk.userData.hddjNum = data.props

        self.buyPropsPackRequestId_ = nil

        if data.addMoney then
            local addMoney = checkint(data.addMoney)
            bm.EventCenter:dispatchEvent({name = nk.eventNames.UPDATE_SEAT_ANTE_CHIP, data = {chip = addMoney}})
        end
    end,
    function(errData)
        -- body
        -- dump(errData, "buyProps.errData:==============")
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("STORE", "BUY_PROP_FAILD"))
        self.buyPropsPackRequestId_ = nil
    end)
end

function StorePopupController:getGiftGroupByIdx(index)
    -- body
    local getGiftGroup = {
        [1] = function()
            -- body
            return self.hotGift_
        end,

        [2] = function()
            -- body
            return self.boutiqueGift_
        end,

        [3] = function()
            -- body
            return self.festivalGift_
        end,

        [4] = function()
            -- body
            return self.otherGift_
        end
    }

    return getGiftGroup[index]()
end

function StorePopupController:getPropListData()
    -- body
    return self.propShopDataList_
end

function StorePopupController:loadPropProductListResult_(paytype, isComplete, data)
    self.view_:setPropList(paytype, isComplete, data)
end

function StorePopupController:makePurchase(paytype, pid, goodData)
    local service = self:getPurchaseService_(paytype)
    service:makePurchase(pid, handler(self, self.purchaseResult_),goodData)
end

function StorePopupController:prepareEditBox(paytype, input1, input2, submitBtn)
    local service = self:getPurchaseService_(paytype)
    service:prepareEditBox(input1, input2, submitBtn)
end

function StorePopupController:onInputCardInfo(paytype, productType, input1, input2, submitBtn)
    local service = self:getPurchaseService_(paytype)
    service:onInputCardInfo(productType, input1, input2, submitBtn, handler(self, self.purchaseResult_))
end

function StorePopupController:purchaseResult_(succ, result)
    if succ then
        self.history_ = nil
        self:loadHistory()
        bm.EventCenter:dispatchEvent(nk.eventNames.ROOM_REFRESH_HDDJ_NUM)

        --[[
        local userData = nk.userData
        local monitorMoney = userData.money
        local retryTimes = 4
        local monitorMoneyChange
        monitorMoneyChange = function()
            bm.HttpService.POST({mod="user", act="getUserProperty"}, function(ret)
                    local js = json.decode(ret)
                    if js then
                        if js.money ~= monitorMoney then
                            userData.money = js.money
                            return
                        end
                    end
                    retryTimes = retryTimes - 1
                    if retryTimes > 0 then
                        self.schedulerPool_:delayCall(monitorMoneyChange, 10)
                    end
                end, function()
                    retryTimes = retryTimes - 1
                    if retryTimes > 0 then
                        self.schedulerPool_:delayCall(monitorMoneyChange, 10)
                    end
                end)
        end
        monitorMoneyChange()
        --]]


        --更新money等字段
        -- local params = {}
        -- table.insert(params,"money") 
        -- -- match.point
        -- nk.http.getInfoByKeys(params,function(data)
        --     if data and params then
        --         for _,key in pairs(params) do
        --             if data[key] then
        --                 nk.userData[("aUser." .. key)] = data[key]
        --             end
        --         end
        --     end
        -- end,function()
            
        -- end)
        
        nk.http.getMemberInfo(nk.userData["aUser.mid"], 
            function(retData)
                -- body
                if retData then
                    --todo
                    nk.userData["aUser.money"] = retData.aUser.money or nk.userData["aUser.money"] or 0

                    nk.userData["match"] = retData.match
                    nk.userData['match.point'] = retData.match.point
                    nk.userData['match.highPoint'] = retData.match.highPoint
                end
            end,function(errData)
                -- body
                dump(errData, "purchaseResult_:getMemberInfo.errData:===============")
        end)

        --更新互动道具数量
        nk.http.getUserProps(2,function(pdata)
            if pdata then
                for _,v in pairs(pdata) do
                    if tonumber(v.pnid) == 2001 then
                        nk.userData.hddjNum = checkint(v.pcnter)
                        break
                    end
                end
            end
            
        end,function()
            
        end)

    end
end

function StorePopupController:loadHistory()
    if self.history_ then
        if #self.history_ > 0 then
            self.view_:setHistoryList(true, self.history_)
        else
            self.view_:setHistoryList(true, bm.LangUtil.getText("STORE", "NO_BUY_HISTORY_HINT"))
        end
    elseif self.isHistoryLoading_ then
        self.view_:setHistoryList(false)
    else
        self.isHistoryLoading_ = true
        self.view_:setHistoryList(false)

        self.loadHistoryRequestId_ = nk.http.getPayRecord(function(callData)
                self.loadHistoryRequestId_ = nil
                self.isHistoryLoading_ = false
                local jarray = callData.list
                self.history_ = jarray
                if jarray then
                    if #jarray > 0 then
                        self.view_:setHistoryList(true, jarray)
                    else
                        self.view_:setHistoryList(true, bm.LangUtil.getText("STORE", "NO_BUY_HISTORY_HINT"))
                    end
                else
                    self.view_:setHistoryList(true, bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
                end
            end,
            function(errData)
                -- dump(errData, "getPayRecord.errData :======================")

                self.loadHistoryRequestId_ = nil
                self.isHistoryLoading_ = false
                self.view_:setHistoryList(true, bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
            end)




        --[[
        self.loadHistoryRequestId_ = bm.HttpService.POST({mod="user", act="getpay", channel=nk.userData.channel}, function(data)
                self.loadHistoryRequestId_ = nil
                self.isHistoryLoading_ = false
                local jarray = json.decode(data)
                self.history_ = jarray
                if jarray then
                    if #jarray > 0 then
                        self.view_:setHistoryList(true, jarray)
                    else
                        self.view_:setHistoryList(true, bm.LangUtil.getText("STORE", "NO_BUY_HISTORY_HINT"))
                    end
                else
                    self.view_:setHistoryList(true, bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
                end
            end,
            function()
                self.loadHistoryRequestId_ = nil
                self.isHistoryLoading_ = false
                self.view_:setHistoryList(true, bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
            end)
        --]]
    end
end

function StorePopupController:init()
    self.moneyWatcher_ = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "aUser.money", handler(self, self.onMoneyChanged_))
    self:loadPayConfig()
end

function StorePopupController:dispose()
    if self.loadHistoryRequestId_ then
        nk.http.cancel(self.loadHistoryRequestId_)
        self.loadHistoryRequestId_ = nil
    end
    if self.moneyWatcher_ then
        bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "aUser.money", self.moneyWatcher_)
        self.moneyWatcher_ = nil
    end
    if self.loadPayConfigId_ then
        --todo
        nk.http.cancel(self.loadPayConfigId_)
    end

    if self.requestPropShopListId_ then
        --todo
        nk.http.cancel(self.requestPropShopListId_)
    end

    if self.buyGiftRequestId_ then
        --todo
        nk.http.cancel(self.buyGiftRequestId_)
    end

    if self.presentGiftRequestId_ then
        --todo
        nk.http.cancel(self.presentGiftRequestId_)
    end

    if self.presentTableGiftRequestId_ then
        --todo
        nk.http.cancel(self.presentTableGiftRequestId_)
    end
    self.manager_:autoDispose()
end

function StorePopupController:onMoneyChanged_(money)

    if self.view_ and self.view_.setMoney then
        --todo
        self.view_:setMoney(money or 0)
    end
end

return StorePopupController
