--
-- Author: tony
-- Date: 2014-11-19 21:36:36
--
local PurchaseHelper = import("app.module.newstore.PurchaseHelper")
local InAppBillingPurchaseService = class("InAppBillingPurchaseService", import("app.module.newstore.PurchaseServiceBase"))

function InAppBillingPurchaseService:ctor()
    InAppBillingPurchaseService.super.ctor(self, "InAppBillingPurchaseService")

    self.helper_ = PurchaseHelper.new("InAppBillingPurchaseService")

    if device.platform == "android" then
        self.invokeJavaMethod_ = self:createJavaMethodInvoker("com/boyaa/cocoslib/iab/InAppBillingBridge")
        self.invokeJavaMethod_("setSetupCompleteCallback", {handler(self, self.onSetupComplete_)}, "(I)V")
        self.invokeJavaMethod_("setLoadProductsCompleteCallback", {handler(self, self.onLoadProductsComplete_)}, "(I)V")
        self.invokeJavaMethod_("setPurchaseCompleteCallback", {handler(self, self.onPurchaseComplete_)}, "(I)V")
        self.invokeJavaMethod_("setDeliveryMethod", {handler(self, self.doDelivery_)}, "(I)V")
        self.invokeJavaMethod_("setConsumeCompleteCallback", {handler(self, self.onConsumeComplete_)}, "(I)V")
    else
        self.invokeJavaMethod_ = function(method, param, sig)
            if method == "setup" then
                self.schedulerPool_:delayCall(function()
                    self:onSetupComplete_("true")
                end, 1)
            elseif method == "makePurchase" then
                -- self:onPurchaseComplete_([[{"sku":"com.boomegg.nineke.fakepid", "originalJson":"{}", "signature":"fakesignature"}]])
                
                -- just for player test pyrchase --
                self.schedulerPool_:delayCall(function()
                    if self.purchaseCallback_ then
                        self.purchaseCallback_(true)
                    end
                end, 1)
                -- end --
            elseif method == "loadProductList" then
                self.schedulerPool_:delayCall(function()
                    self:onLoadProductsComplete_([[ [{"sku":"com.boomegg.nineke.vn.chip6m","price":"21.000 đ"}] ]])
                end, 1)
            end
        end
    end
end

function InAppBillingPurchaseService:init(config)
    -- dump(config, "InAppBillingPurchaseService:init.config :=================")

    self.config_ = config
    self.active_ = true
    local success, ret = self.invokeJavaMethod_("isSetupComplete", {}, "()Z")
    if success then
        self.isSetupComplete_ = ret
    end
    success, ret = self.invokeJavaMethod_("isSupported", {}, "()Z")
    if success then
        self.isSupported_ = ret
    end
    if not self.isSetupComplete_ then
        self.isSetuping_ = true
        self.logger:debug("start setup..")
        self.invokeJavaMethod_("setup", {}, "()V")
    end

    if not self.products_ then
        self.logger:debug("remote config is loading..")
        self.helper_:cacheConfig(self.config_.configURL, handler(self, self.configLoadHandler_))
    end
end

function InAppBillingPurchaseService:autoDispose()
    self.active_ = false
    self.isProductPriceLoaded_ = false  --确保每次重新load价格，触发发货检查
    self.isProductRequesting_ = false
    self.loadChipRequested_ = false
    self.loadPropRequested_ = false
    self.loadTicketRequested_ = false
    self.loadCashRequested_ = false

    self.loadChipCallback_ = nil
    self.loadPropCallback_ = nil
    self.loadTicketCallback_ = nil
    self.loadCashCallback_ = nil

    self.purchaseCallback_ = nil
    self.isSetupComplete_ = nil
    self.isSetuping_ = nil
    self.isSupported_ = nil
    self.invokeJavaMethod_("delayDispose", {60}, "(I)V")

    if self.callPayOrderReqId_ then
        nk.http.cancel(self.callPayOrderReqId_)
        self.callPayOrderReqId_ = nil
    end
end

--callback(payType, isComplete, data)
function InAppBillingPurchaseService:loadChipProductList(callback)
    self.loadChipCallback_ = callback
    self.loadChipRequested_ = true
    self:loadProcess_()
end

--callback(payType, isComplete, data)
function InAppBillingPurchaseService:loadPropProductList(callback)
    self.loadPropCallback_ = callback
    self.loadPropRequested_ = true
    self:loadProcess_()
end

function InAppBillingPurchaseService:loadTicketProductList(callback)
    self.loadTicketCallback_ = callback
    self.loadTicketRequested_ = true
    self:loadProcess_()
end

function InAppBillingPurchaseService:loadCashProductList(callback)
    -- body
    self.loadCashCallback_ = callback
    self.loadCashRequested_ = true
    self:loadProcess_()
end

function InAppBillingPurchaseService:makePurchase(pid, callback,goodData)
    self.purchaseCallback_ = callback
    local params = {}
    params.id = goodData.pid
    params.pmode = goodData.pmode

    self.callPayOrderReqId_ = self.helper_:callPayOrder(params,function(callData)
        self.callPayOrderReqId_ = nil


            -- callData = {
            --     "APPID"        = "1243"
            --     "ITEMID"       = "119539"
            --     "MID"          = "178"
            --     "MSG"          = "SUCC"
            --     "ORDER"        = 3150083915
            --     "PAMOUNT"      = "0.99"
            --     "PAMOUNT_RATE" = "1"
            --     "PAMOUNT_UNIT" = "USD"
            --     "PAMOUNT_USD"  = 0.99
            --     "PAYCONFID"    = "119539"
            --     "PID"          = "3150083915"
            --     "PMODE"        = "12"
            --     "RET"          = 0
            --     "SID"          = "7"
            --     "SITEMID"      = "C4:6A:B7:61:7E:C1"
            --     "X-MSG"        = "SUCC"
            --     "X-RET"        = 200
            --  }


        local APPID = checkint(callData.APPID)
        local ITEMID = callData.ITEMID
        local MID = callData.MID
        local MSG = callData.MSG
        local ORDER = callData.ORDER
        local PAMOUNT = callData.PAMOUNT
        local PAMOUNT_RATE = callData.PAMOUNT_RATE
        local PAMOUNT_UNIT = callData.PAMOUNT_UNIT
        local PAMOUNT_USD = callData.PAMOUNT_USD
        local PAYCONFID = callData.PAYCONFID
        local PID = callData.PID
        local PMODE = callData.PMODE
        local RET = callData.RET
        local SID = callData.SID
        local SITEMID = callData.SITEMID
        local X_MSG = callData["X-MSG"]
        local X_RET = callData["X-RET"]


        --[[ old
        local RET = callData.RET
        local MSG = callData.MSG
        local ORDER = callData.ORDER
        local SID = callData.SID
        local APPID = callData.APPID
        local CURRENCY = callData.CURRENCY
        local DESC = callData.DESC
        local PAMOUNT = callData.PAMOUNT
        local PAYCONFID = callData.PAYCONFID
        local PCARD = callData.PCARD
        local PCHIPS = callData.PCHIPS
        local PCOINS = callData.PCOINS
        local PMODE = callData.PMODE
        local PNUM = callData.PNUM
        local SITEMID = callData.SITEMID
        local macid = callData.macid
        local user_ip = callData.user_ip
        --]]

        -- RET -- 0:success  非0:errorCode
        if 0 == RET then
            local orderId = ORDER
            local uid = tostring(nk.userData.uid) or ""
            local channel = tostring(appconfig.ROOT_CGI_SID) or ""
            self.invokeJavaMethod_("makePurchase", {orderId, tostring(pid), uid, channel}, "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V")
        else


        end
        
    end,function()
        self.callPayOrderReqId_ = nil
    end)


    -- local orderId = ""
    -- local uid = tostring(nk.userData.uid) or ""
    -- local channel = tostring(nk.userData.channel) or ""
    -- self.invokeJavaMethod_("makePurchase", {orderId, pid, uid, channel}, "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V")
end

--加载商品信息流程
function InAppBillingPurchaseService:loadProcess_()
    if not self.products_ then
        self.logger:debug("remote config is loading..")
        self.helper_:cacheConfig(self.config_.configURL, handler(self, self.configLoadHandler_))
    end
    if self.isSetupComplete_ then
        if self.isSupported_ then
            if self.loadChipRequested_ or self.loadPropRequested_ or self.loadTicketRequested_ or self.loadCashRequested_ then
                if self.products_ then
                    if self.isProductPriceLoaded_ then
                        --更新折扣
                        -- dump(self.products_, "InAppBillingPurchaseService:loadProcess_[self.products_] :=============")

                        self.helper_:updateDiscount(self.products_, self.config_)
                        local notProductTip = bm.LangUtil.getText("STORE", "NO_PRODUCT_HINT")
                        self:invokeCallback_(1, true, #(checktable(self.products_.chips)) > 0 and (self.products_.chips) or notProductTip)
                        self:invokeCallback_(2, true, #(checktable(self.products_.props)) > 0 and (self.products_.props) or notProductTip)
                        self:invokeCallback_(4, true, #(checktable(self.products_.tickets)) > 0 and (self.products_.tickets) or notProductTip)
                        self:invokeCallback_(5, true, #(checktable(self.products_.cash)) > 0 and (self.products_.cash) or notProductTip)
                    elseif not self.isProductRequesting_ then
                        self.isProductRequesting_ = true
                        local joinedSkuList = table.concat(self.products_.skus, ",")
                        self.logger:debug("start loading price...")
                        self:invokeCallback_(3, false)
                        self.invokeJavaMethod_("loadProductList", {joinedSkuList}, "(Ljava/lang/String;)V")
                    else
                        self:invokeCallback_(3, false)
                    end
                else
                    self:invokeCallback_(3, false)
                end
            end
        else
            self.logger:debug("iab not supported")
            self:invokeCallback_(3, true, bm.LangUtil.getText("STORE", "NOT_SUPPORT_MSG"))
        end
    elseif self.isSetuping_ then
        self.logger:debug("setuping ...")
        self:invokeCallback_(3, false)
    else
        self.isSetuping_ = true
        self.logger:debug("start setup..")
        self:invokeCallback_(3, false)
        self.invokeJavaMethod_("setup", {}, "()V")
    end
end

--Java call lua
function InAppBillingPurchaseService:onSetupComplete_(isSupported)
    self.logger:debug("setup complete.")
    self.isSetuping_ = false
    self.isSetupComplete_ = true
    self.isSupported_ = (isSupported == "true")
    self.logger:debug("isSupported raw:", isSupported)
    self:loadProcess_()
end

--Java call lua
function InAppBillingPurchaseService:onLoadProductsComplete_(jsonString)
    self.logger:debug("price load complete -> " .. jsonString)
    local success = (jsonString ~= "fail")
    self.isProductRequesting_ = false
    if success then
        local products = json.decode(jsonString)
        --更新价格
        -- dump(products, "products:===============")
        if products then
            for i, prd in ipairs(products) do
                if self.products_.chips then
                    for j, chip in ipairs(self.products_.chips) do
                        if prd.sku == chip.pid then
                            chip.priceLabel = prd.price
                            if prd.priceNum and prd.priceDollar then
                                chip.priceNum = prd.priceNum
                                chip.priceDollar = prd.priceDollar
                            end
                        end
                    end
                end
                if self.products_.props then
                    for j, prop in ipairs(self.products_.props) do
                        if prd.sku == prop.pid then
                            prop.priceLabel = prd.price
                            if prd.priceNum and prd.priceDollar then
                                prop.priceNum = prd.priceNum
                                prop.priceDollar = prd.priceDollar
                            end
                        end
                    end
                end
                if self.products_.coins then
                    for j, coin in ipairs(self.products_.coins) do
                        if prd.sku == coin.pid then
                            coin.priceLabel = prd.price
                            if prd.priceNum and prd.priceDollar then
                                coin.priceNum = prd.priceNum
                                coin.priceDollar = prd.priceDollar
                            end
                        end
                    end
                end

                if self.products_.tickets then
                    for j, ticket in ipairs(self.products_.tickets) do
                        if prd.sku == ticket.pid then
                            ticket.priceLabel = prd.price
                            if prd.priceNum and prd.priceDollar then
                                ticket.priceNum = prd.priceNum
                                ticket.priceDollar = prd.priceDollar
                            end
                        end
                    end
                end

                if self.products_.cash then
                    --todo
                    for j, cash in ipairs(self.products_.cash) do
                        if prd.sku == cash.pid then
                            cash.priceLabel = prd.price
                            if prd.priceNum and prd.priceDollar then
                                cash.priceNum = prd.priceNum
                                cash.priceDollar = prd.priceDollar
                            end
                        end
                    end
                end
            end
            self.isProductPriceLoaded_ = true
            self:loadProcess_()
            return
        end
    end
    self:invokeCallback_(3, true, bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
end

--Java call lua
function InAppBillingPurchaseService:onPurchaseComplete_(jsonString)
    self.logger:debug("purchase complete -> ", jsonString)
    local success = (string.sub(jsonString, 1, 4) ~= "fail")
    if success then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("STORE", "PURCHASE_SUCC_AND_DELIVERING"))
        local json = json.decode(jsonString)
        self:delivery(json.sku, json.originalJson, json.signature, true)
    elseif string.sub(jsonString, 6) == "canceled" then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("STORE", "PURCHASE_CANCELED_MSG"))
        if self.purchaseCallback_ then
            self.purchaseCallback_(false, "canceled")
        end
    else
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("STORE", "PURCHASE_FAILED_MSG"))
        if self.purchaseCallback_ then
            self.purchaseCallback_(false, "error")
        end
    end
end

--Java call lua
function InAppBillingPurchaseService:doDelivery_(jsonString)
    self.logger:debug("doDelivery_ ", jsonString)
    local json = json.decode(jsonString)
    self:delivery(json.sku, json.originalJson, json.signature, false)
end

--Java call lua
function InAppBillingPurchaseService:onConsumeComplete_(jsonString)
    self.logger:debug("onConsumeComplete_", jsonString)
end

function InAppBillingPurchaseService:invokeCallback_(flag, isComplete, data)
    if self.loadChipRequested_ and self.loadChipCallback_ and (flag == 1 or flag == 3) then
        self.loadChipCallback_(self.config_, isComplete, data)
    end
    if self.loadPropRequested_ and self.loadPropCallback_ and (flag == 2 or flag == 3)  then
        self.loadPropCallback_(self.config_, isComplete, data)
    end
    if self.loadTicketRequested_ and self.loadTicketCallback_ and (flag == 4 or flag == 3)  then
        self.loadTicketCallback_(self.config_, isComplete, data)
    end

    if self.loadCashRequested_ and self.loadCashCallback_ and (flag == 5 or flag == 3) then
        --todo
        self.loadCashCallback_(self.config_, isComplete, data)
    end
end


function InAppBillingPurchaseService:filterProducts(datas)
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


function InAppBillingPurchaseService:configLoadHandler_(succ, content)
    if succ then
        self.logger:debug("remote config file loaded.")
        local jsonObj = json.decode(content)
        self:filterProducts(jsonObj)
        self.products_ = self.helper_:parseConfig(jsonObj, function(category, json, product)
        end)
        self.isProductPriceLoaded_ = false
        self:loadProcess_()
    else
        self.logger:debug("remote config file load failed.")
        self:invokeCallback_(3, true, bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
    end
end

function InAppBillingPurchaseService:delivery(sku, receipt, signature, showMsg)

    if nk.userData.best  then
        nk.userData.best.paylog = 1
    end

    local retryLimit = 6
    local deliveryFunc
    local params = {}
    params.signedData = crypto.encodeBase64(receipt)
    params.signature = signature
    params.pmode = self.config_.pmode
    deliveryFunc = function()
        self.helper_:callPayDelivery(params,function(json)
                -- local json = json.decode(data)

                dump(json,"InAppBillingPurchaseService-callPayDeliverySucc")
                if json and tonumber(json.RET) == 0 then
                    self.logger:debug("dilivery success, consume it")
                    self.invokeJavaMethod_("consume", {sku}, "(Ljava/lang/String;)V")
                    if showMsg then
                        nk.TopTipManager:showTopTip(bm.LangUtil.getText("STORE", "DELIVERY_SUCC_MSG"))
                        if self.purchaseCallback_ then
                            self.purchaseCallback_(true)
                        end
                    end
                else
                    self.logger:debug("delivery failed => " .. (json and json.MSG or "nil"))
                    retryLimit = retryLimit - 1
                    if retryLimit > 0 then
                        self.schedulerPool_:delayCall(function()
                            deliveryFunc()
                        end, 5)
                    else
                        if showMsg then
                            nk.TopTipManager:showTopTip(bm.LangUtil.getText("STORE", "DELIVERY_FAILED_MSG"))
                            if self.purchaseCallback_ then
                                self.purchaseCallback_(false, "error")
                            end
                        end
                    end
                end
            end, function(errData) 
                dump(errData,"InAppBillingPurchaseService-callPayDeliveryFail")
                retryLimit = retryLimit - 1
                if retryLimit > 0 then
                    self.schedulerPool_:delayCall(function()
                        deliveryFunc()
                    end, 5)
                else
                    if showMsg then
                        nk.TopTipManager:showTopTip(bm.LangUtil.getText("STORE", "DELIVERY_FAILED_MSG"))
                        if self.purchaseCallback_ then
                            self.purchaseCallback_(false, "error")
                        end
                    end
                end
            end)
    end
    deliveryFunc()
end

return InAppBillingPurchaseService