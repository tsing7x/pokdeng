--
-- Author: tony
-- Date: 2014-09-24 14:36:15
--
local Store = import(".Store")
local InAppPurchasePlugin = class("InAppPurchasePlugin", import(".PurchasePluginBase"))
local logger = bm.Logger.new("InAppPurchasePlugin")

InAppPurchasePlugin.CONFIG_KEY = "PAY_CONF"

local store

function InAppPurchasePlugin:sharedInAppPurchasePlugin()
    if not store then
        store = Store.new()
        InAppPurchasePlugin.store = store
    end
    InAppPurchasePlugin.instance_ = InAppPurchasePlugin.instance_ or InAppPurchasePlugin.new()
    store:restore()
    return InAppPurchasePlugin.instance_
end

function InAppPurchasePlugin:ctor()
    self.loadProductFinishedHandlerId_ = store:addEventListener(Store.LOAD_PRODUCTS_FINISHED, handler(self, self.loadProductFinished_))
    self.transactionPurchasedHanlderId_ = store:addEventListener(Store.TRANSACTION_PURCHASED, handler(self, self.transactionPurchased_))
    self.transactionRestoredHandlerId_ = store:addEventListener(Store.TRANSACTION_RESTORED, handler(self, self.transactionRestored_))
    self.transactionFailedHandlerId_ = store:addEventListener(Store.TRANSACTION_FAILED, handler(self, self.transactionFailed_))
    self.transactionUnknownErrorHandlerId_ = store:addEventListener(Store.TRANSACTION_UNKNOWN_ERROR, handler(self, self.transactionUnkownError_))
end

function InAppPurchasePlugin:dispose()
    --[[
    store:removeEventListener(self.loadProductFinishedHandlerId_)
    store:removeEventListener(self.transactionPurchasedHanlderId_)
    store:removeEventListener(self.transactionRestoredHandlerId_)
    store:removeEventListener(self.transactionFailedHandlerId_)
    store:removeEventListener(self.transactionUnknownErrorHandlerId_)
    ]]
    self.loadProductsCallback_ = nil
    self.purchaseResultCallback_ = nil
end

function InAppPurchasePlugin:loadProductFinished_(evt)
    self.isProductLoading_ = false
    if self.loadProductsCallback_ then
        if evt.products and #evt.products > 0 then
            self.loadProductsCallback_(true, evt.products)
        else
            self.loadProductsCallback_(false, "load product fail")
        end
    else
        logger:debug("loadProductsCallback_ is nil")
    end
end

function InAppPurchasePlugin:transactionPurchased_(evt)
    nk.TopTipManager:showTopTip(bm.LangUtil.getText("STORE", "PURCHASE_SUCC_AND_DELIVERING"))
    self:delivery(evt.transaction)
end

function InAppPurchasePlugin:transactionRestored_(evt)
    self:delivery(evt.transaction)
end

function InAppPurchasePlugin:delivery(transaction)
    local retryLimit = 4
    local deliveryFunc
    deliveryFunc = function()
        retryLimit = retryLimit - 1
        if retryLimit > 0 then
            bm.HttpService.POST({
                    mod = "pay",
                    act = "delivery",
                    receipt = crypto.encodeBase64(transaction.receipt),
                }, function(ret)
                    local jsn = json.decode(ret)
                    if jsn and tonumber(jsn.ret) == 0 then
                        --v3
                        --store:finishTransaction(transaction.transactionIdentifier)
                        --v2
                        store:finishTransaction(transaction)
                        if self.purchaseResultCallback_ then
                            self.purchaseResultCallback_(true, transaction)
                        end
                        nk.TopTipManager:showTopTip(bm.LangUtil.getText("STORE", "DELIVERY_SUCC_MSG"))
                        return
                    end
                    deliveryFunc()
                end, function()
                    deliveryFunc()
                end)
        else
            if self.purchaseResultCallback_ then
                self.purchaseResultCallback_(false, "server return fail")
            end
        end
    end
    deliveryFunc()
end

function InAppPurchasePlugin:transactionFailed_(evt)
    nk.TopTipManager:showTopTip(bm.LangUtil.getText("STORE", "PURCHASE_FAILED_MSG"))
    if self.purchaseResultCallback_ then
        self.purchaseResultCallback_(false, "ERROR")
    end
end

function InAppPurchasePlugin:transactionUnkownError_(evt)
    nk.TopTipManager:showTopTip(bm.LangUtil.getText("STORE", "PURCHASE_FAILED_MSG"))
    if self.purchaseResultCallback_ then
        self.purchaseResultCallback_(false, "ERROR")
    end
end

function InAppPurchasePlugin:startup(setupCallback, purchaseResultCallback)
    self.purchaseResultCallback_ = purchaseResultCallback
    if device.platform == "windows" then
        self.isSupported_ = true
    else
        self.isSupported_ = store:canMakePurchases()
    end
    setupCallback(self.isSupported_)
end

function InAppPurchasePlugin:canMakePurchases()
    return self.isSupported_ or store:canMakePurchases()
end

function InAppPurchasePlugin:makePurchase(sku, uid, channel)
    if device.platform == "windows" then
        self:onPurchaseComplete_("{}")
    else
        store:purchaseProduct(sku)
    end
end

function InAppPurchasePlugin:loadProducts(config, callback)
    local loadProductcallback = function(success, result)
        print("InAppPurchasePlugin:loadProducts callback", success, result)
        if success then
            --更新价格
            if result then
                for i, prd in ipairs(result) do
                    if config.chips then
                        for j, chip in ipairs(config.chips) do
                            if prd.productIdentifier == chip.pid then
                                local ok, price = luaoc.callStaticMethod(
                                    "LuaOCBridge", 
                                    "getPriceLabel", 
                                    {
                                        priceLocale = prd.priceLocale, 
                                        price = prd.price, 
                                    }
                                )
                                if ok then
                                    chip.priceLabel = price
                                else
                                    chip.priceLabel = prd.price
                                end
                                chip.priceNum = prd.price
                            end
                        end
                    end
                    if config.props then
                        for j, prop in ipairs(config.props) do
                            if prd.productIdentifier == prop.pid then
                                local ok, price = luaoc.callStaticMethod(
                                    "LuaOCBridge", 
                                    "getPriceLabel", 
                                    {
                                        priceLocale = prd.priceLocale, 
                                        price = prd.price, 
                                    }
                                )
                                if ok then
                                    prop.priceLabel = price
                                else
                                    prop.priceLabel = prd.price
                                end
                                prop.priceNum = prd.price
                            end
                        end
                    end
                    if config.coins then
                        for j, coin in ipairs(config.coins) do
                            if prd.productIdentifier == coin.pid then
                                local ok, price = luaoc.callStaticMethod(
                                    "LuaOCBridge", 
                                    "getPriceLabel", 
                                    {
                                        priceLocale = prd.priceLocale, 
                                        price = prd.price, 
                                    }
                                )
                                if ok then
                                    coin.priceLabel = price
                                else
                                    coin.priceLabel = prd.price
                                end
                                coin.priceNum = prd.price
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
    if self.isSupported_ then
        logger:debug("InAppPurchasePlugin loadProducts")
        self.loadProductsCallback_ = loadProductcallback
        if not self.isProductLoading_ then
            self.isProductLoading_ = true
            store:loadProducts(config.skus)
        end
    else
        logger:debug("InAppPurchasePlugin NOT SUPPORTED")
        loadProductcallback(false, "NOT SUPPORTED!!")
    end
end

function InAppPurchasePlugin:parseConfig(jsonString)
    print(jsonString)
    local json = json.decode(jsonString)
    local result = {}
    result.skus = {}
    if json.chips then
        local chips = {}
        result.chips = chips
        for i = 1, #json.chips do
            local chip = json.chips[i]
            local prd = {}
            prd.pid = chip.pid
            prd.id = chip.id
            prd.price = chip.p
            prd.img = chip.u and chip.u ~= "" and chip.u or prd.id
            prd.title = chip.n
            prd.chipNum = chip.ch
            prd.tag = chip["if"] == 1 and "hot" or (chip["if"] == 2 and "new" or "")
            table.insert(chips, prd)
            table.insert(result.skus, prd.pid)
        end
    end
    if json.props then
        local props = {}
        result.props = props
        for i = 1, #json.props do
            local prop = json.props[i]
            local prd = {}
            prd.pid = prop.pid
            prd.id = prop.id
            prd.detail = prop.d
            prd.price = prop.p
            prd.img = prop.u and prop.u ~= "" and prop.u or prd.id
            prd.title = prop.n
            prd.propId = prop.pr
            prd.tag = prop["if"] == 1 and "hot" or (prop["if"] == 2 and "new" or "")
            prd.propType = prop.pt
            table.insert(props, prd)
            table.insert(result.skus, prd.pid)
        end
    end
    if json.coins then
        local coins = {}
        result.coins = coins
        for i = 1, #json.coins do
            local coin = json.coins[i]
            local prd = {}
            prd.pid = coin.pid
            prd.id = coin.id
            prd.price = coin.p
            prd.img = coin.u and coin.u ~= "" and coin.u or prd.id
            prd.title = coin.n
            prd.coinNum = coin.co
            prd.tag = coin["if"] == 1 and "hot" or (coin["if"] == 2 and "new" or "")
            table.insert(coins, prd)
            table.insert(result.skus, prd.pid)
        end
    end
    return result
end

return InAppPurchasePlugin