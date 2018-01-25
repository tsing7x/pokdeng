--
-- Author: tony
-- Date: 2014-11-17 16:44:39
--
local InAppBillingPurchaseService = import(".services.InAppBillingPurchaseService")
local InAppPurchasePurchaseService = import(".services.InAppPurchasePurchaseService")
local Easy2PayPurchaseService = import(".services.Easy2PayPurchaseService")
local Easy2PayApiPurchaseService = import(".services.Easy2PayApiPurchaseService")
local Easy2PayWebPurchaseService = import(".services.Easy2PayWebPurchaseService")
local UnitryPurchaseService = import(".services.UnitryPurchaseService")
local MolPurchaseService = import(".services.MolPurchaseService")
local BluePayPurchaseService = import(".services.BluePayPurchaseService")
local GGPayPurchaseService = import(".services.GGPayPurchaseService")
local LinePayPurchaseService = import(".services.LinePayPurchaseService")
local BluePayIosPurchaseService = import(".services.BluePayIosPurchaseService")
local TruePayPurchaseService = import(".services.TruePayPurchaseService")
local ByCardPurchaseService = import(".services.ByCardPurchaseService")

local PURCHASE_TYPE = import(".PURCHASE_TYPE")

local PurchaseServiceManager = class("PurchaseServiceManager")

-- function PurchaseServiceManager:getInstance()
--     if not PurchaseServiceManager.instance_ then
--         PurchaseServiceManager.instance_ = PurchaseServiceManager.new()
--     end
--     return PurchaseServiceManager.instance_
-- end

function PurchaseServiceManager:ctor()
    self.availablePurchaseService_ = {}
    self.purchaseServices_ = {}
    if device.platform == "android" then
        self.availablePurchaseService_[PURCHASE_TYPE.IN_APP_BILLING] = InAppBillingPurchaseService
        self.availablePurchaseService_[PURCHASE_TYPE.EASY_2_PAY] = Easy2PayPurchaseService
        self.availablePurchaseService_[PURCHASE_TYPE.EASY_2_PAY_API] = Easy2PayApiPurchaseService
        self.availablePurchaseService_[PURCHASE_TYPE.UNITRY_GAMERTOPUP] = UnitryPurchaseService
        self.availablePurchaseService_[PURCHASE_TYPE.MOL_TRUE_MONEY] = MolPurchaseService
        self.availablePurchaseService_[PURCHASE_TYPE.MOL_Z_CARD] = MolPurchaseService
        self.availablePurchaseService_[PURCHASE_TYPE.MOL_POINT_CARD] = MolPurchaseService
        self.availablePurchaseService_[PURCHASE_TYPE.MOL_12_CALL] = MolPurchaseService
        self.availablePurchaseService_[PURCHASE_TYPE.BLUE_PAY] = BluePayPurchaseService
        self.availablePurchaseService_[PURCHASE_TYPE.GGPAY_GGCARD] = GGPayPurchaseService
        self.availablePurchaseService_[PURCHASE_TYPE.GGPAY_TMNCC] = GGPayPurchaseService
        self.availablePurchaseService_[PURCHASE_TYPE.GGPAY_DCARD] = GGPayPurchaseService
        self.availablePurchaseService_[PURCHASE_TYPE.LINE_PAY] = LinePayPurchaseService
        self.availablePurchaseService_[PURCHASE_TYPE.TRUE_SMS_PAY] = TruePayPurchaseService
        self.availablePurchaseService_[PURCHASE_TYPE.BY_CARD] = ByCardPurchaseService
    elseif device.platform == "ios" then
        self.availablePurchaseService_[PURCHASE_TYPE.IN_APP_PURCHASE] = InAppPurchasePurchaseService
        self.availablePurchaseService_[PURCHASE_TYPE.EASY_2_PAY_WEB] = Easy2PayWebPurchaseService
        self.availablePurchaseService_[PURCHASE_TYPE.MOL_TRUE_MONEY] = MolPurchaseService
        self.availablePurchaseService_[PURCHASE_TYPE.MOL_Z_CARD] = MolPurchaseService
        self.availablePurchaseService_[PURCHASE_TYPE.MOL_POINT_CARD] = MolPurchaseService
        self.availablePurchaseService_[PURCHASE_TYPE.MOL_12_CALL] = MolPurchaseService
        self.availablePurchaseService_[PURCHASE_TYPE.EASY_2_PAY] = Easy2PayPurchaseService
        self.availablePurchaseService_[PURCHASE_TYPE.LINE_PAY_IOS] = LinePayPurchaseService
        self.availablePurchaseService_[PURCHASE_TYPE.BLUE_PAY] = BluePayIosPurchaseService
        self.availablePurchaseService_[PURCHASE_TYPE.BY_CARD] = ByCardPurchaseService
    elseif device.platform == "windows" then
        self.availablePurchaseService_[PURCHASE_TYPE.IN_APP_BILLING] = InAppBillingPurchaseService
        self.availablePurchaseService_[PURCHASE_TYPE.IN_APP_PURCHASE] = InAppPurchasePurchaseService
        self.availablePurchaseService_[PURCHASE_TYPE.EASY_2_PAY] = Easy2PayPurchaseService
        self.availablePurchaseService_[PURCHASE_TYPE.EASY_2_PAY_API] = Easy2PayApiPurchaseService
        self.availablePurchaseService_[PURCHASE_TYPE.EASY_2_PAY_WEB] = Easy2PayWebPurchaseService
        self.availablePurchaseService_[PURCHASE_TYPE.UNITRY_GAMERTOPUP] = UnitryPurchaseService
        self.availablePurchaseService_[PURCHASE_TYPE.MOL_TRUE_MONEY] = MolPurchaseService
        self.availablePurchaseService_[PURCHASE_TYPE.MOL_Z_CARD] = MolPurchaseService
        self.availablePurchaseService_[PURCHASE_TYPE.MOL_POINT_CARD] = MolPurchaseService
        self.availablePurchaseService_[PURCHASE_TYPE.MOL_12_CALL] = MolPurchaseService
        self.availablePurchaseService_[PURCHASE_TYPE.BLUE_PAY] = BluePayPurchaseService
        self.availablePurchaseService_[PURCHASE_TYPE.BLUE_PAY] = BluePayIosPurchaseService
        self.availablePurchaseService_[PURCHASE_TYPE.GGPAY_GGCARD] = GGPayPurchaseService
        self.availablePurchaseService_[PURCHASE_TYPE.GGPAY_TMNCC] = GGPayPurchaseService
        self.availablePurchaseService_[PURCHASE_TYPE.GGPAY_DCARD] = GGPayPurchaseService
        self.availablePurchaseService_[PURCHASE_TYPE.LINE_PAY] = LinePayPurchaseService
        self.availablePurchaseService_[PURCHASE_TYPE.LINE_PAY_IOS] = LinePayPurchaseService
        self.availablePurchaseService_[PURCHASE_TYPE.TRUE_SMS_PAY] = TruePayPurchaseService
        self.availablePurchaseService_[PURCHASE_TYPE.BY_CARD] = ByCardPurchaseService
    end
end

function PurchaseServiceManager:isServiceAvailable(serviceId)
    return self.availablePurchaseService_[serviceId]
end

function PurchaseServiceManager:init(payConfig)
    dump(payConfig,"PurchaseServiceManager:init payConfig")
    for i, config in ipairs(payConfig) do
        dump(config,"PurchaseServiceManager:init")
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

function PurchaseServiceManager:getPurchaseService(serviceId)
    return self.purchaseServices_[serviceId]
end

function PurchaseServiceManager:autoDispose()
    for id, service in pairs(self.purchaseServices_) do
        service:autoDispose()
    end
end

return PurchaseServiceManager
