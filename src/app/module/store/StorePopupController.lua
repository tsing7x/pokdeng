--
-- Author: tony
-- Date: 2014-08-12 18:53:42
--
local PurchaseManager = import(".managers.PurchaseManager")
local PurchaseType = import(".managers.PurchaseType")
local ProductChipListItem = import(".views.ProductChipListItem")
local ProductPropListItem = import(".views.ProductPropListItem")

local StorePopupController = class("StorePopupController")

function StorePopupController:ctor(view)
    self.view_ = view
end

function StorePopupController:initialize()
    self.schedulerPool_ = bm.SchedulerPool.new()
    if device.platform == "ios" then
        self.purchaseManager_ = PurchaseManager.new(PurchaseType.IN_APP_PURCHASE)
    else
        self.purchaseManager_ = PurchaseManager.new(PurchaseType.IN_APP_BILLING)
    end
    self.isSetuping_ = true
    self.isLoadingProducts_ = false
    self:onTabChanged(self.tabIndex_)
    self.purchaseManager_:setup(handler(self, self.onReady), handler(self, self.onPurchaseResult))
end

function StorePopupController:dispose()
    self.purchaseManager_:dispose()
    self.schedulerPool_:clearAll()
end

function StorePopupController:onReady(isSupported)
    print("isSupported ", isSupported)
    self.isSetuping_ = false
    if isSupported then
        self.isLoadingProducts_ = true
        self.purchaseManager_:loadProducts(handler(self, self.onProductLoaded))
    else
        nk.TopTipManager:showTopTip("不支持支付")
        self:onTabChanged(self.tabIndex_)
    end
end

function StorePopupController:onProductLoaded(success, productListOrMsg)
    print("StorePopupController:onProductLoaded", success, productListOrMsg)
    self.isLoadingProducts_ = false
    if success then
        self.view_:setChipList(productListOrMsg.chips)
        self.view_:setPropList(productListOrMsg.props)
    else
        if self.view_:getSelectedTabIndex() == 1 or self.view_:getSelectedTabIndex() == 2 then
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
        end
    end
    self:onTabChanged(self.tabIndex_)
end

function StorePopupController:makePurchase(pid)
    self.purchaseManager_:makePurchase(pid)
end

function StorePopupController:onPurchaseResult(success, result)
    print(success, result)
    if success then
        self:refreshHistory()
        self:refreshMyProps()
        bm.EventCenter:dispatchEvent(nk.eventNames.ROOM_REFRESH_HDDJ_NUM)
        self.monitorMoneyChangeTimes_ = 4
        self.schedulerPool_:clearAll()
        local userData = nk.userData
        local monitorMoney = userData.money
        local function monitorMoneyChange()
            self.monitorMoneyChangeTimes_ = self.monitorMoneyChangeTimes_ - 1
            if self.monitorMoneyChangeTimes_ > 0 then
                bm.HttpService.POST({mod="user", act="getUserProperty"}, function(ret)
                    local js = json.decode(ret)
                    if js then
                        if js.money ~= monitorMoney then
                            userData.money = js.money
                            return
                        end
                    end
                    self.schedulerPool_:delayCall(monitorMoneyChange, 10)
                end, function()
                    self.schedulerPool_:delayCall(monitorMoneyChange, 10)
                end)
            end
        end
        monitorMoneyChange()

        --获取道具数量
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

        --[[更新互动道具数量
        bm.HttpService.POST(
            {
                mod = "user", 
                act = "getUserFun"
            }, 
            function (data)
                nk.userData.hddjNum = tonumber(data)
            end
        )
        --]]
    end
end

function StorePopupController:onTabChanged(tabIndex)
    self.tabIndex_ = tabIndex

    if tabIndex == 1 then
        self.view_:setLoading(self.isSetuping_ or self.isLoadingProducts_)
        self.view_:emptyChipPrompt()
    elseif tabIndex == 2 then
        self.view_:setLoading(self.isSetuping_ or self.isLoadingProducts_)
        self.view_:emptyPropPrompt()
    elseif tabIndex == 3 then
        --我的道具
        if not self.myPropsData_ then
            self.view_:setLoading(true)
            self:loadMyProps_()
        else
            self.view_:setLoading(false)
            self.view_:setMyPropData(self.myPropsData_)
        end
    elseif tabIndex == 4 then
        --购买记录
        if not self.history_ then
            self.view_:setLoading(true)
            self:loadHistory_()
        else
            self.view_:setLoading(false)
            self.view_:setHistoryData(self.history_)
        end
    end
end

function StorePopupController:refreshHistory()
    self.history_ = nil
    self:onTabChanged(self.tabIndex_)
end

function StorePopupController:loadHistory_()
    if not self.isHistoryLoading_ then
        self.isHistoryLoading_ = true
        bm.HttpService.POST({mod="user", act="getpay", channel=nk.userData.channel}, function(data)
                self.isHistoryLoading_ = false
                if self.view_:getSelectedTabIndex() == 4 then
                    self.view_:setLoading(false)
                end
                local jarray = json.decode(data)
                if jarray and #jarray > 0 then
                end
                self.history_ = jarray
                self.view_:setHistoryData(self.history_)
            end,
            function()
                self.isHistoryLoading_ = false
                if self.view_:getSelectedTabIndex() == 4 then
                    self.view_:setLoading(false)
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
                end
            end)
    end
end

function StorePopupController:refreshMyProps()
    self.myPropsData_ = nil
    self:onTabChanged(self.tabIndex_)
end

function StorePopupController:loadMyProps_()
    do return end
    if not self.isMyPropsLoading_ then
        self.isMyPropsLoading_ = true
        bm.HttpService.POST({mod="user", act="getUserProps"}, function(data)
                self.isMyPropsLoading_ = false
                if self.view_:getSelectedTabIndex() == 3 then
                    self.view_:setLoading(false)
                end

                local list = json.decode(data)
                self.myPropsData_ = {}
                if list and #list > 0 then
                    for i, d in ipairs(list) do
                        if d.a == 1 then --铜卡
                        elseif d.a == 2 then --互动道具卡
                            table.insert(self.myPropsData_, {
                                title = bm.LangUtil.getText("STORE", "INTERACTIVE_PROP"),
                                propType = 2,
                                propId = d.a,
                                ramainNum = d.b,
                                ramainUnit = d.c,
                                ramainText = bm.LangUtil.getText("STORE", "REMAIN", d.b, d.c),
                                buttonType = "buy"
                            })
                        elseif d.a == 3 then --经验卡
                        elseif d.a == 6 then -- 银卡
                        elseif d.a == 7 then -- 金卡
                        elseif d.a == 8 then -- 钻石卡
                        elseif d.a == 30 then --小喇叭
                        elseif d.a == 32 then -- 大喇叭
                        end
                    end
                end
                --[[
                table.insert(self.myPropsData_, {
                                title = bm.LangUtil.getText("STORE", "INTERACTIVE_PROP"),
                                propType = 2,
                                propId = 26,
                                ramainNum = 300,
                                ramainUnit = "次",
                                ramainText = bm.LangUtil.getText("STORE", "REMAIN", 300, "次"),
                                buttonType = "buy"
                            })]]
                self.view_:setMyPropData(self.myPropsData_)
            end, function() 
                self.isMyPropsLoading_ = false
                if self.view_:getSelectedTabIndex() == 3 then
                    self.view_:setLoading(false)
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
                end
            end)
    end
end

return StorePopupController