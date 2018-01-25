-- 
-- 快速支付
-- @author leoluo
--
local Easy2PayPurchaseService = import(".services.Easy2PayPurchaseService")
local BluePayPurchaseService = import(".services.BluePayPurchaseService")
local BluePayIosPurchaseService = import(".services.BluePayIosPurchaseService")
local QuickPurchaseServiceManager = class("QuickPurchaseServiceManager")
local InAppBillingPurchaseService = import(".services.InAppBillingPurchaseService")
local InAppPurchasePurchaseService = import(".services.InAppPurchasePurchaseService")
local MolPurchaseService = import(".services.MolPurchaseService")
local LinePayPurchaseService = import(".services.LinePayPurchaseService")
local PURCHASE_TYPE = import(".PURCHASE_TYPE")
local logger = bm.Logger.new("QuickPurchaseServiceManager")

function QuickPurchaseServiceManager:ctor()

	self.availablePurchaseService_ = {}
    self.purchaseServices_ = {}
    if device.platform == "android" then
        self.availablePurchaseService_[PURCHASE_TYPE.IN_APP_BILLING] = InAppBillingPurchaseService
        -- self.availablePurchaseService_[PURCHASE_TYPE.EASY_2_PAY] = Easy2PayPurchaseService
        -- self.availablePurchaseService_[PURCHASE_TYPE.UNITRY_GAMERTOPUP] = UnitryPurchaseService
        -- self.availablePurchaseService_[PURCHASE_TYPE.MOL_TRUE_MONEY] = MolPurchaseService
        -- self.availablePurchaseService_[PURCHASE_TYPE.MOL_Z_CARD] = MolPurchaseService
        -- self.availablePurchaseService_[PURCHASE_TYPE.MOL_POINT_CARD] = MolPurchaseService
        self.availablePurchaseService_[PURCHASE_TYPE.MOL_12_CALL] = MolPurchaseService
        self.availablePurchaseService_[PURCHASE_TYPE.BLUE_PAY] = BluePayPurchaseService
        self.availablePurchaseService_[PURCHASE_TYPE.LINE_PAY] = LinePayPurchaseService
    elseif device.platform == "ios" then
        self.availablePurchaseService_[PURCHASE_TYPE.IN_APP_PURCHASE] = InAppPurchasePurchaseService
        self.availablePurchaseService_[PURCHASE_TYPE.BLUE_PAY] = BluePayIosPurchaseService
        -- self.availablePurchaseService_[PURCHASE_TYPE.MOL_TRUE_MONEY] = MolPurchaseService
        -- self.availablePurchaseService_[PURCHASE_TYPE.MOL_Z_CARD] = MolPurchaseService
        -- self.availablePurchaseService_[PURCHASE_TYPE.MOL_POINT_CARD] = MolPurchaseService
        -- self.availablePurchaseService_[PURCHASE_TYPE.MOL_12_CALL] = MolPurchaseService
        -- self.availablePurchaseService_[PURCHASE_TYPE.EASY_2_PAY] = Easy2PayPurchaseService
    elseif device.platform == "windows" then
        self.availablePurchaseService_[PURCHASE_TYPE.IN_APP_BILLING] = InAppBillingPurchaseService
        self.availablePurchaseService_[PURCHASE_TYPE.IN_APP_PURCHASE] = InAppPurchasePurchaseService
        -- self.availablePurchaseService_[PURCHASE_TYPE.EASY_2_PAY] = Easy2PayPurchaseService
        -- self.availablePurchaseService_[PURCHASE_TYPE.UNITRY_GAMERTOPUP] = UnitryPurchaseService
        -- self.availablePurchaseService_[PURCHASE_TYPE.MOL_TRUE_MONEY] = MolPurchaseService
        -- self.availablePurchaseService_[PURCHASE_TYPE.MOL_Z_CARD] = MolPurchaseService
        -- self.availablePurchaseService_[PURCHASE_TYPE.MOL_POINT_CARD] = MolPurchaseService
        self.availablePurchaseService_[PURCHASE_TYPE.MOL_12_CALL] = MolPurchaseService
        self.availablePurchaseService_[PURCHASE_TYPE.BLUE_PAY] = BluePayPurchaseService
        self.availablePurchaseService_[PURCHASE_TYPE.LINE_PAY] = LinePayPurchaseService
    end

	-- self.easy2pay_ = Easy2PayPurchaseService.new()
	self.schedulerPool_ = bm.SchedulerPool.new()
end



function QuickPurchaseServiceManager:isServiceAvailable(serviceId)
    return self.availablePurchaseService_[serviceId]
end

function QuickPurchaseServiceManager:init(payConfig)
    -- dump(payConfig, "QuickPurchaseServiceManager:init.payConfig :===================")
    for i, config in ipairs(payConfig) do
        -- dump(config,"QuickPurchaseServiceManager:init")
        local PurchaseServiceClass = self.availablePurchaseService_[config.id]
        local purchaseServiceInstance_ = self.purchaseServices_[config.id]
        if PurchaseServiceClass then
            if not purchaseServiceInstance_ then
                purchaseServiceInstance_ = PurchaseServiceClass.new()
                self.purchaseServices_[config.id] = purchaseServiceInstance_
            end
            purchaseServiceInstance_:init(config)
        end
    end
end

-- callback 0 成功 1 失败
function QuickPurchaseServiceManager:loadPayConfig(callback)


	local retryTimes = 3
    local loadPayConfig
    self.getGetPayConfigReqId_ = nil
    loadPayConfig = function ()
        self.getGetPayConfigReqId_ = nk.http.getPayTypeConfig(BM_UPDATE.VERSION,
        function(data)
            if data then
                -- logger:debug("loadPayConfig complete")
                -- dump(data, "getPayTypeConfig.data: =====================")
                local payTypeAvailable = {}
                for i, p in ipairs(data) do
                    if self:isServiceAvailable(p.id) then
                        payTypeAvailable[#payTypeAvailable + 1] = p
                    end
                end

                self:init(payTypeAvailable)
                callback(0,payTypeAvailable)
            else
                retryTimes = retryTimes - 1
                if retryTimes > 0 then
                    loadPayConfig()
                else
                    nk.badNetworkToptip()
                    callback(1,nil)
                end
            end
        end,
        function()
            retryTimes = retryTimes - 1
            if retryTimes > 0 then
                loadPayConfig()
            else
                nk.badNetworkToptip()
                callback(1,nil)
            end
        end)
    end
    loadPayConfig()
end

function QuickPurchaseServiceManager:getPurchaseService(serviceId)
    return self.purchaseServices_[serviceId]
end

function QuickPurchaseServiceManager:autoDispose()
    if self.getGetPayConfigReqId_ then
        nk.http.cancel(self.getGetPayConfigReqId_)
        self.getGetPayConfigReqId_ = nil
    end

    for id, service in pairs(self.purchaseServices_) do
        service:autoDispose()
    end
end


--callback(paytype, isComplete, data)
function QuickPurchaseServiceManager:loadChipProductList(paytype, callback)
    local service = self:getPurchaseService(paytype)
    if service then
		service:loadChipProductList(callback)
    end
end

--callback(paytype, isComplete, data)
function QuickPurchaseServiceManager:loadTicketProductList(paytype, callback)
    local service = self:getPurchaseService(paytype)
    if service then
        service:loadTicketProductList(callback)
    end
end

function QuickPurchaseServiceManager:loadCashProductList(paytype, callback)
    -- body
    local service = self:getPurchaseService(paytype)
    if service then
        service:loadCashProductList(callback)
    end
end

function QuickPurchaseServiceManager:loadPropProductList(paytype, callback)
    local service = self:getPurchaseService(paytype)
    if service then
        service:loadPropProductList(callback)
    end
end


function QuickPurchaseServiceManager:setPurchaseCallback(callback)
    self.purchaseCallback_ = callback
end

function QuickPurchaseServiceManager:makePurchase(paytype, pid, goodData)
    local service = self:getPurchaseService(paytype)
    if service then
        if device.platform == "windows" then
            --todo
            local function hackPurchaseSucc()
                -- body
                -- log("hackPurchaseSucc !")
                self:purchaseResult_(true, "succ")
            end

            self.schedulerPool_:delayCall(hackPurchaseSucc, 1.5)
            -- self:purchaseResult_(true, "succ")
            return
        end
		service:makePurchase(pid, handler(self, self.purchaseResult_), goodData)
    end
    
end

function QuickPurchaseServiceManager:purchaseResult_(succ, result)
    if succ then
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

    nk.http.getMemberInfo(nk.userData["aUser.mid"], function(retData)
        -- body
        nk.userData["aUser.money"] = retData.aUser.money or nk.userData["aUser.money"] or 0
        nk.userData["aUser.gift"] = retData.aUser.gift or nk.userData["aUser.gift"] or 0
        nk.userData["aUser.mlevel"] = retData.aUser.mlevel or nk.userData["aUser.mlevel"] or 1
        nk.userData["aUser.exp"] = retData.aUser.exp or nk.userData["aUser.exp"] or 0

        nk.userData["aBest.maxmoney"] = retData.aBest.maxmoney or nk.userData["aBest.maxmoney"] or 0
        nk.userData["aBest.maxwmoney"] = retData.aBest.maxwmoney or nk.userData["aBest.maxwmoney"] or 0
        nk.userData["aBest.maxwcard"] = retData.aBest.maxwcard or nk.userData["aBest.maxwcard"] or 0
        nk.userData["aBest.rankMoney"] = retData.aBest.rankMoney or nk.userData["aBest.rankMoney"] or 0

        nk.userData["match"] = retData.match
        nk.userData['match.point'] = retData.match.point
        nk.userData['match.highPoint'] = retData.match.highPoint
    end, function(errData)
        -- body
        dump(errData, "getMemberInfo.errData :====================")
    end)

    if self.purchaseCallback_ then
        self.purchaseCallback_(succ, result)
    end
end

return QuickPurchaseServiceManager