--
-- Author: tony
-- Date: 2014-12-08 17:56:15
--
local PurchaseHelper = import("app.module.newstore.PurchaseHelper")
local UnitryPurchaseService = class("UnitryPurchaseService", import("app.module.newstore.PurchaseServiceBase"))

function UnitryPurchaseService:ctor()
    UnitryPurchaseService.super.ctor(self, "UnitryPurchaseService")
    self.helper_ = PurchaseHelper.new("UnitryPurchaseService")
end

function UnitryPurchaseService:init(config)
    self.config_ = config
    self.purchaseURLPattern_ = self.config_.purchaseURL  .. "?pid=%s&uid=%s&mtkey=%s&skey=%s&device=%s&payTypeId=%s&version=%s&rand=%s&sig=%s"
    self.active_ = true
    self.helper_:cacheConfig(config.configURL, handler(self, self.configLoadHandler_))
end

function UnitryPurchaseService:autoDispose()
    self.active_ = false
    self.loadChipRequested_ = false
    self.loadPropRequested_ = false
    self.loadChipCallback_ = nil
    self.loadPropCallback_ = nil
    self.purchaseCallback_ = nil
    if self.appForegroundListenerId_ then
        bm.EventCenter:removeEventListener(self.appForegroundListenerId_)
        self.appForegroundListenerId_ = nil
    end
end

--callback(payType, isComplete, data)
function UnitryPurchaseService:loadChipProductList(callback)
    self.loadChipCallback_ = callback
    self.loadChipRequested_ = true
    self:loadProcess_()
end

--callback(payType, isComplete, data)
function UnitryPurchaseService:loadPropProductList(callback)
    self.loadPropCallback_ = callback
    self.loadPropRequested_ = true
    self:loadProcess_()
end

function UnitryPurchaseService:loadProcess_()
    if not self.products_ then
        self.logger:debug("remote config is loading..")
        self.helper_:cacheConfig(self.config_.configURL, handler(self, self.configLoadHandler_))
        self:invokeCallback_(3, false)
    elseif self.loadChipRequested_ or self.loadPropRequested_ then
        self.helper_:updateDiscount(self.products_, self.config_)
        local notProductTip = bm.LangUtil.getText("STORE", "NO_PRODUCT_HINT")
        self:invokeCallback_(1, true, #(checktable(self.products_.chips)) > 0 and (self.products_.chips) or notProductTip)
        self:invokeCallback_(2, true, #(checktable(self.products_.props)) > 0 and (self.products_.props) or notProductTip)
        self:invokeCallback_(4, true, #(checktable(self.products_.tickets)) > 0 and (self.products_.tickets) or notProductTip)
        self:invokeCallback_(5, true, #(checktable(self.products_.cash)) > 0 and (self.products_.cash) or notProductTip)
    else
        self:invokeCallback_(3, false)
    end
end

function UnitryPurchaseService:invokeCallback_(flag, isComplete, data)
    if self.loadChipRequested_ and self.loadChipCallback_ and (flag == 1 or flag == 3) then
        self.loadChipCallback_(self.config_, isComplete, data)
    end
    if self.loadPropRequested_ and self.loadPropCallback_ and (flag == 2 or flag == 3)  then
        self.loadPropCallback_(self.config_, isComplete, data)
    end
end

function UnitryPurchaseService:filterProducts(datas)
    if (self.config_ and #(checktable(self.config_.filter)) > 0) and (datas and table.nums(datas) > 0) then

        local filter = {}
        for _,v in pairs(self.config_.filter) do
            filter[(v .. "")] = true
        end

        local productTypeTb = table.keys(datas)
        for _,ptype in pairs(productTypeTb) do
            local temp = {}
            if datas[ptype] and type(datas[ptype] == "table") then
                for k,v in pairs(datas[ptype]) do
                    if not filter[(v.id .. "")] then
                        temp[(#temp + 1)] = v
                    end
                end
                datas[ptype] = temp
            end
        end
    end
end

function UnitryPurchaseService:configLoadHandler_(succ, content)
    if succ then
        self.logger:debug("remote config file loaded.")
        local jsonObj = json.decode(content)
        self:filterProducts(jsonObj)
        self.products_ = self.helper_:parseConfig(jsonObj, function(category, json, product)
            product.priceLabel = string.format("%dTHB", product.price)
            product.priceNum = product.price
            product.priceDollar = "THB"
        end)
        self:loadProcess_()
    else
        self.logger:debug("remote config file load failed.")
        self:invokeCallback_(3, true, bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
    end
end

function UnitryPurchaseService:makePurchase(pid, callback)
    self.purchaseCallback_ = callback
    self.logger:debug("make purchase ", pid)
    local userData = nk.userData
    local rand = bm.getTime()
    local purchaseURL = string.format(self.purchaseURLPattern_,
        pid,
        userData.uid,
        userData.mtkey,
        userData.skey,
        device.platform == "windows" and "android" or device.platform,
        self.config_.id,
        BM_UPDATE and BM_UPDATE.VERSION or nk.Native:getAppVersion(),
        rand,
        crypto.md5("bmsig@2014" .. pid .. userData.uid .. userData.mtkey .. userData.skey .. rand)
    )
    self.logger:debugf("open purchase url -> %s", purchaseURL)
    if not self.appForegroundListenerId_ then
        self.appForegroundListenerId_ = bm.EventCenter:addEventListener(nk.eventNames.APP_ENTER_FOREGROUND, handler(self, self.onOpenURLReturned_))
    end
    device.openURL(purchaseURL)
end

function UnitryPurchaseService:onOpenURLReturned_()
    if self.appForegroundListenerId_ then
        bm.EventCenter:removeEventListener(self.appForegroundListenerId_)
        self.appForegroundListenerId_ = nil
    end
    if self.purchaseCallback_ then
        self.purchaseCallback_(true)
    end
end

return UnitryPurchaseService