--
-- Author: tony
-- Date: 2014-08-11 17:41:24
--

local InAppBillingPlugin = class("InAppBillingPlugin", import(".PurchasePluginBase"))
local logger = bm.Logger.new("InAppBillingPlugin")

InAppBillingPlugin.CONFIG_KEY = "PAY_CONF"

local isAndroid = (device.platform == "android")

function InAppBillingPlugin:ctor()
    InAppBillingPlugin.super.ctor(self)
    if isAndroid then
        self.onSetupCompleteHandler_ = {handler(self, self.onSetupComplete_)}
        self.onLoadProductsCompleteHandler_ = {handler(self, self.onLoadProductsComplete_)}
        self.onPurchaseCompleteHandler_ = {handler(self, self.onPurchaseComplete_)}
        self.doDeliveryHandler_ = {handler(self, self.doDelivery_)}
        self.onConsumeCompleteHandler_ = {handler(self, self.onConsumeComplete_)}

        self:call_("setSetupCompleteCallback", self.onSetupCompleteHandler_, "(I)V")
        self:call_("setLoadProductsCompleteCallback", self.onLoadProductsCompleteHandler_, "(I)V")
        self:call_("setPurchaseCompleteCallback", self.onPurchaseCompleteHandler_, "(I)V")
        self:call_("setDeliveryMethod", self.doDeliveryHandler_, "(I)V")
        self:call_("setConsumeCompleteCallback", self.onConsumeCompleteHandler_, "(I)V")
    end

    self.isSetupCompleted_ = false
    self.isSupported_ = false
    self.loadProductsRequested_ = false

    if device.platform == "windows" then
        self.isSetupCompleted_ = true
        self.isSupported_ = true
    end
end

function InAppBillingPlugin:call_(javaMethodName, javaParams, javaMethodSig)
    if device.platform == "android" then
        local ok, ret = luaj.callStaticMethod("com/boyaa/cocoslib/iab/InAppBillingBridge", javaMethodName, javaParams, javaMethodSig)
        if not ok then
            if ret == -1 then
                logger:errorf("call %s failed, -1 不支持的参数类型或返回值类型", javaMethodName)
            elseif ret == -2 then
                logger:errorf("call %s failed, -2 无效的签名", javaMethodName)
            elseif ret == -3 then
                logger:errorf("call %s failed, -3 没有找到指定的方法", javaMethodName)
            elseif ret == -4 then
                logger:errorf("call %s failed, -4 Java 方法执行时抛出了异常", javaMethodName)
            elseif ret == -5 then
                logger:errorf("call %s failed, -5 Java 虚拟机出错", javaMethodName)
            elseif ret == -6 then
                logger:errorf("call %s failed, -6 Java 虚拟机出错", javaMethodName)
            end
        end
        return ok, ret
    else
        logger:debugf("call %s failed, not in android platform", javaMethodName)
        return false, nil
    end
end

--////////////////////////////////////////////////////
--// java methods
--////////////////////////////////////////////////////

function InAppBillingPlugin:isSetupComplete()
    if device.platform == "windows" then
        return true
    else
        local success, ret = self:call_("isSetupComplete", {}, "()Z")
        if success then
            return ret
        else
            return false
        end
    end
end

function InAppBillingPlugin:isSupported()
    if device.platform == "windows" then
        return true
    else
        local success, ret = self:call_("isSupported", {}, "()Z")
        if success then
            return ret
        else
            return false
        end
    end
end

function InAppBillingPlugin:setup()
    self.isDisposed_ = false
    if device.platform == "windows" then
        self:onSetupComplete_("true")
    else
        self:call_("setup", {}, "()V")
    end
end

function InAppBillingPlugin:loadProductList(skuList)
    if device.platform == "windows" then
        self:onLoadProductsComplete_(true, {})
    else
        local joinedSkuList = table.concat(skuList, ",")
        self:call_("loadProductList", {joinedSkuList}, "(Ljava/lang/String;)V")
    end
end

function InAppBillingPlugin:makePurchase(sku, uid, channel)
    if device.platform == "windows" then
        self:onPurchaseComplete_("{}")
    else
        local orderId = ""
        self:call_("makePurchase", {orderId, sku, uid, channel}, "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V")
    end
end

function InAppBillingPlugin:consume(sku)
    if device.platform == "windows" then
    else
        self:call_("consume", {sku}, "(Ljava/lang/String;)V")
    end
end

function InAppBillingPlugin:delayDispose(delaySeconds)
    if device.platform == "windows" then
    else
        self:call_("delayDispose", {delaySeconds}, "(I)V")
    end
end

--////////////////////////////////////////////////////
--// lua methods for java
--////////////////////////////////////////////////////

function InAppBillingPlugin:onSetupComplete_(isSupported)
    self.isSetupCompleted_ = true
    logger:debug("InAppBillingPlugin isSupported raw:", isSupported)
    self.isSupported_ = (isSupported == "true")
    if self.setupCompleteCallback_ then
        self.setupCompleteCallback_(self.isSupported_)
    end
    if self.isSupported_ then
        if self.loadProductsRequested_ then
            self.loadProductsRequested_ = false
            self:loadProductList(self.loadProductsRequestParam_)
        end
    end
end

function InAppBillingPlugin:onLoadProductsComplete_(jsonString)
    logger:debug("InAppBillingPlugin onLoadProductsComplete_ :", jsonString)
    local success = (jsonString ~= "fail")
    if self.loadProductsCallback_ then
        if success then
            local products = json.decode(jsonString)
            self.loadProductsCallback_(true, products)
        else
            self.loadProductsCallback_(false)
        end
    else
        logger:debug("loadProductsCallback_ is nil")
    end
end

function InAppBillingPlugin:onPurchaseComplete_(jsonString)
    logger:debug("InAppBillingPlugin onPurchaseComplete_ :", jsonString)
    local success = (string.sub(jsonString, 1, 4) ~= "fail")
    if success then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("STORE", "PURCHASE_SUCC_AND_DELIVERING"))
        local json = json.decode(jsonString)
        self:delivery(json.sku, json.originalJson, json.signature, true)
        if self.purchaseResultCallback_ then
            self.purchaseResultCallback_(true, "")
        end
    elseif string.sub(jsonString, 6) == "canceled" then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("STORE", "PURCHASE_CANCELED_MSG"))
        if self.purchaseResultCallback_ then
            self.purchaseResultCallback_(false, "canceled")
        end
    else
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("STORE", "PURCHASE_FAILED_MSG"))
        if self.purchaseResultCallback_ then
            self.purchaseResultCallback_(false)
        end
    end
end

function InAppBillingPlugin:doDelivery_(jsonString)
    logger:debug("InAppBillingPlugin doDelivery_ ", jsonString)
    local json = json.decode(jsonString)
    self:delivery(json.sku, json.originalJson, json.signature, false)
end

function InAppBillingPlugin:onConsumeComplete_(jsonString)
    logger:debug("InAppBillingPlugin onConsumeComplete_")
end


--////////////////////////////////////////////////////
--// billing logic
--////////////////////////////////////////////////////

function InAppBillingPlugin:startup(setupCallback, purchaseResultCallback)
    self.setupCompleteCallback_ = setupCallback
    self.purchaseResultCallback_ = purchaseResultCallback
    if not self.isSetupCompleted_ and not self:isSetupComplete() then
        self:setup()
    else
        self.isSupported_ = self:isSupported()
        setupCallback(self.isSupported_)
    end
end

function InAppBillingPlugin:canMakePurchases()
    return self:isSetupComplete() and self.isSupported_ and self.isPurchasing_ ~= true
end

function InAppBillingPlugin:loadProducts(config, callback)
    local skuList = config.skus
    local loadProductsCallback = function(success, result)
        print("InAppBillingPlugin:loadProducts callback", success, result)
        if success then
            --更新价格
            if result then
                for i, prd in ipairs(result) do
                    if config.chips then
                        for j, chip in ipairs(config.chips) do
                            if prd.sku == chip.pid then
                                chip.priceLabel = prd.price
                            end
                        end
                    end
                    if config.props then
                        for j, prop in ipairs(config.props) do
                            if prd.sku == prop.pid then
                                prop.priceLabel = prd.price
                            end
                        end
                    end
                    if config.coins then
                        for j, coin in ipairs(config.coins) do
                            if prd.sku == coin.pid then
                                coin.priceLabel = prd.price
                            end
                        end
                    end
                end
            end
            callback(true, config)
        else
            callback(false, result)
        end
    end
    if not self:isSetupComplete() then
        logger:debug("InAppBillingPlugin loadProducts setup not complete, do setup")
        self:setup()
        self.loadProductsRequested_ = true
        self.loadProductsCallback_ = loadProductsCallback
    elseif self.isSupported_ then
        logger:debug("InAppBillingPlugin loadProducts")
        self.loadProductsCallback_ = loadProductsCallback
        self:loadProductList(skuList)
    else
        logger:debug("InAppBillingPlugin NOT SUPPORTED")
        loadProductsCallback(false, "NOT SUPPORTED!!")
    end
end

function InAppBillingPlugin:delivery(sku, receipt, signature, showMsg, isRetry, retryTimes)
    if isRetry then
        retryTimes = retryTimes - 1
        if retryTimes <= 0 then
            print("retry failed")
            if showMsg then
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("STORE", "DELIVERY_FAILED_MSG"))
            end
            return
        end
    end
    print(nk.userData.PAY_CGI_ROOT)
    local params = {}
    params.mod = "pay"
    params.act = "delivery"
    params.receipt = receipt
    params.signature = signature
    bm.HttpService.POST_URL(nk.userData.PAY_CGI_ROOT, params, function(data)
            local json = json.decode(data)
            if json and json.ret == 0 then
                print("dilivery success, consume it")
                self:consume(sku)
                if showMsg then
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("STORE", "DELIVERY_SUCC_MSG"))
                end
            else
                if DEBUG > 0 then
                    print("发货失败" .. data)
                end
            end
        end, function() 
            if self and (not self.isDisposed_ or bm.getTime() - self.disposedTime_ < 60) then
                self.schedulerPool_:delayCall(function()
                        self:delivery(sku, receipt, signature, showMsg, true, retryTimes or 10)
                    end, 10)
            end
        end)
end

function InAppBillingPlugin:autoDispose(delaySeconds)
    self.schedulerPool_:clearAll()
    self:delayDispose(delaySeconds)
    self.isSetupCompleted_ = false
    self.isSupported_ = false
    self.isDisposed_ = true
    self.disposedTime_ = bm.getTime()
    self.loadProductsRequested_ = false
    self.setupCompleteCallback_ = nil
    self.loadProductsCallback_ = nil
end




return InAppBillingPlugin