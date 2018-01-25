--
-- Author: tony
-- Date: 2014-11-24 19:01:49
--
local PurchaseHelper = import("app.module.newstore.PurchaseHelper")
local Store = import("app.module.store.plugins.Store")

local InAppPurchasePurchaseService = class("InAppPurchasePurchaseService", import("app.module.newstore.PurchaseServiceBase"))

function InAppPurchasePurchaseService:ctor()
    InAppPurchasePurchaseService.super.ctor(self, "InAppPurchasePurchaseService")
    self.helper_ = PurchaseHelper.new("InAppPurchasePurchaseService")
    self.store_ = Store.new()
    self.store_:addEventListener(Store.LOAD_PRODUCTS_FINISHED, handler(self, self.loadProductFinished_))
    self.store_:addEventListener(Store.TRANSACTION_PURCHASED, handler(self, self.transactionPurchased_))
    self.store_:addEventListener(Store.TRANSACTION_RESTORED, handler(self, self.transactionRestored_))
    self.store_:addEventListener(Store.TRANSACTION_FAILED, handler(self, self.transactionFailed_))
    self.store_:addEventListener(Store.TRANSACTION_UNKNOWN_ERROR, handler(self, self.transactionUnkownError_))



    if device.platform == "ios" then 
        self.invokeStoreMethod_ = self:createStoreMethodInvoker()
        -- self.invokeStoreMethod_("addEventListener",Store.LOAD_PRODUCTS_FINISHED, handler(self, self.loadProductFinished_))
        -- self.invokeStoreMethod_("addEventListener",Store.TRANSACTION_PURCHASED, handler(self, self.transactionPurchased_))
        -- self.invokeStoreMethod_("addEventListener",Store.TRANSACTION_RESTORED, handler(self, self.transactionRestored_))
        -- self.invokeStoreMethod_("addEventListener",Store.TRANSACTION_FAILED, handler(self, self.transactionFailed_))
        -- self.invokeStoreMethod_("addEventListener",Store.TRANSACTION_UNKNOWN_ERROR, handler(self, self.transactionUnkownError_))
    else
        self.invokeStoreMethod_ = function(method,...)
            if method == "makePurchase" then
               
            elseif method == "canMakePurchases" then
                 return true
            elseif method == "loadProducts" then
                self:loadProductFinished_({products = {{}}})
            end
        end


    end
end

function InAppPurchasePurchaseService:init(config)
    self.active_ = true
    self.config_ = config
    -- self.isSupported_ = self.store_:canMakePurchases()
    self.isSupported_ = self.invokeStoreMethod_("canMakePurchases")
    if not self.products_ then
        self.logger:debug("remote config is loading..")
        self.helper_:cacheConfig(self.config_.configURL, handler(self, self.configLoadHandler_))
    end
    self.invokeStoreMethod_("restore")
    -- self.store_:restore()
end

function InAppPurchasePurchaseService:autoDispose()
    self.active_ = false
    self.loadChipRequested_ = false
    self.loadPropRequested_ = false
    self.loadTicketRequested_ = false
    self.loadCashRequested_ = false
    self.isProductPriceLoaded_ = false
    self.isProductRequesting_ = false

    self.loadChipCallback_ = nil
    self.loadPropCallback_ = nil
    self.loadTicketCallback_ = nil
    self.loadCashCallback_ = nil
    self.purchaseCallback_ = nil

    if self.callPayOrderReqId_ then
        nk.http.cancel(self.callPayOrderReqId_)
        self.callPayOrderReqId_ = nil
    end

    if self.store_ then
        self.store_:dispose()
        self.store_ = nil
    end
    
end

--callback(payType, isComplete, data)
function InAppPurchasePurchaseService:loadChipProductList(callback)
    self.loadChipCallback_ = callback
    self.loadChipRequested_ = true
    self:loadProcess_()
end

--callback(payType, isComplete, data)
function InAppPurchasePurchaseService:loadPropProductList(callback)
    self.loadPropCallback_ = callback
    self.loadPropRequested_ = true
    self:loadProcess_()
end

function InAppPurchasePurchaseService:loadTicketProductList(callback)
    self.loadTicketCallback_ = callback
    self.loadTicketRequested_ = true
    self:loadProcess_()
end

function InAppPurchasePurchaseService:loadCashProductList(callback)
    -- body
    self.loadCashCallback_ = callback
    self.loadCashRequested_ = true
    self:loadProcess_()
end

function InAppPurchasePurchaseService:loadProcess_()
    if not self.isSupported_ then
        self.logger:debug("iap not supported")
        self:invokeCallback_(3, true, bm.LangUtil.getText("STORE", "NOT_SUPPORT_MSG"))
    else
        if not self.products_ then
            self.logger:debug("remote config is loading..")
            self.helper_:cacheConfig(self.config_.configURL, handler(self, self.configLoadHandler_))
        end
        if self.loadChipRequested_ or self.loadPropRequested_ or self.loadTicketRequested_ or self.loadCashRequested_ then

            if self.products_ then
                if self.isProductPriceLoaded_ then
                    --更新折扣
                    self.helper_:updateDiscount(self.products_, self.config_)
                    local notProductTip = bm.LangUtil.getText("STORE", "NO_PRODUCT_HINT")
                    self:invokeCallback_(1, true, #(checktable(self.products_.chips)) > 0 and (self.products_.chips) or notProductTip)
                    self:invokeCallback_(2, true, #(checktable(self.products_.props)) > 0 and (self.products_.props) or notProductTip)
                    self:invokeCallback_(4, true, #(checktable(self.products_.tickets)) > 0 and (self.products_.tickets) or notProductTip)
                    self:invokeCallback_(5, true, #(checktable(self.products_.cash)) > 0 and (self.products_.cash) or notProductTip)
                elseif not self.isProductRequesting_ then
                    self.isProductRequesting_ = true
                    self.logger:debug("start loading price...")
                    self:invokeCallback_(3, false)
                    -- self.store_:loadProducts(self.products_.skus)
                    self.invokeStoreMethod_("loadProducts",self.products_.skus)
                else
                    self:invokeCallback_(3, false)
                end
            else
                self:invokeCallback_(3, false)
            end
        else
            self:invokeCallback_(3, false)
        end
    end
end

function InAppPurchasePurchaseService:invokeCallback_(flag, isComplete, data)
    if self.loadChipRequested_ and self.loadChipCallback_ and (flag == 1 or flag == 3) then
        self.loadChipCallback_(self.config_, isComplete, data)
    end
    if self.loadPropRequested_ and self.loadPropCallback_ and (flag == 2 or flag == 3) then
        self.loadPropCallback_(self.config_, isComplete, data)
    end
    if self.loadTicketRequested_ and self.loadTicketCallback_ and (flag == 4 or flag == 3) then
        self.loadTicketCallback_(self.config_, isComplete, data)
    end

    if self.loadCashRequested_ and self.loadCashCallback_ and (flag == 5 or flag == 3) then
        --todo
        self.loadCashCallback_(self.config_, isComplete, data)
    end
end


function InAppPurchasePurchaseService:filterProducts(datas)
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

function InAppPurchasePurchaseService:configLoadHandler_(succ, content)
    if succ then
        self.logger:debug("remote config file loaded.")
        local jsonObj = json.decode(content)
        self:filterProducts(jsonObj)
        self.products_ = self.helper_:parseConfig(jsonObj, function(category, json, product)
        end)


        if self.products_ and self.products_.skus then
            local canGetAppBunkleId = (nk ~= nil) and (nk["Native"] ~= nil) and (nk.Native["getAppBundleId"] ~= nil)
            if self.products_.chips then  
                for k,v in pairs(self.products_.chips) do
                    local key = table.keyof(self.products_.skus,v.pid)
                    if key then
                        local finalPid = (canGetAppBunkleId and nk.Native:getAppBundleId() or "com.boyaa.pokdeng") .. ".chips" .. v.pid
                        self.products_.skus[key] = finalPid
                    end
                end

            end


            if self.products_.props then  
                for k,v in pairs(self.products_.props) do
                    local key = table.keyof(self.products_.skus,v.pid)
                    if key then
                        local finalPid = (canGetAppBunkleId and nk.Native:getAppBundleId() or "com.boyaa.pokdeng") .. ".props" .. v.pid
                        self.products_.skus[key] = finalPid
                    end
                end

            end


            if self.products_.coins then  
                for k,v in pairs(self.products_.coins) do
                    local key = table.keyof(self.products_.skus,v.pid)
                    if key then
                        local finalPid = (canGetAppBunkleId and nk.Native:getAppBundleId() or "com.boyaa.pokdeng") .. ".coins" .. v.pid
                        self.products_.skus[key] = finalPid
                    end
                end

            end


            if self.products_.tickets then  
                for k,v in pairs(self.products_.tickets) do
                    local key = table.keyof(self.products_.skus,v.pid)
                    if key then
                        local finalPid = (canGetAppBunkleId and nk.Native:getAppBundleId() or "com.boyaa.pokdeng") .. ".tickets" .. v.pid
                        self.products_.skus[key] = finalPid
                    end
                end
            end

            if self.products_.cash then
                --todo
                for k, v in pairs(self.products_.cash) do
                    local key = table.keyof(self.products_.skus, v.pid)
                    if key then
                        local finalPid = (canGetAppBunkleId and nk.Native:getAppBundleId() or "com.boyaa.pokdeng") .. ".cash" .. v.pid
                        self.products_.skus[key] = finalPid
                    end
                end
            end
        end
        self:loadProcess_()
    else
        self.logger:debug("remote config file load failed.")
        self:invokeCallback_(3, true, bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
    end
end


function InAppPurchasePurchaseService:makePurchase2(pid, callback,goodData)
     if self.isPurchasing_ then
        self.logger:debug("makePurchase fail, purchase isPurchasing_")
        return
    end
    local canGetAppBunkleId = (nk ~= nil) and (nk["Native"] ~= nil) and (nk.Native["getAppBundleId"] ~= nil)
    local finalPid = (canGetAppBunkleId and nk.Native:getAppBundleId() or "com.boyaa.pokdeng") .. ".chips" .. pid
    -- self.store_:purchaseProduct(finalPid)
    self.invokeStoreMethod_("purchaseProduct",finalPid)
    self.isPurchasing_ = true
    -- self:restoreOrderInfo(pid,orderId,"chips")

end

function InAppPurchasePurchaseService:makePurchase(pid, callback,goodData)

    if self.isPurchasing_ then
        self.logger:debug("makePurchase fail, purchase isPurchasing_")
        return
    end

    self.purchaseCallback_ = callback
    local params = {}
    params.id = goodData.pid
    params.pmode = goodData.pmode
    self.isPurchasing_ = true
    self.callPayOrderReqId_ = self.helper_:callPayOrder(params,function(callData)
        self.callPayOrderReqId_ = nil

        
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
        dump(callData, "callData:==========")
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
            if self.products_ and self.products_.skus then
                for k,v in pairs(self.products_.skus) do
                    local suffixStr = string.match(v,"%a+%d+")
                    local typeStr = string.match(suffixStr,"%a+")
                    local pidStr = string.match(suffixStr,"%d+")

                    if (typeStr and typeStr ~= "") and (pidStr and pidStr ~= "") then

                        if (tonumber(pid) == tonumber(pidStr)) then
                            local orderId = ORDER
                            self.orderId_ = orderId
                            local uid = tostring(nk.userData.uid) or ""
                            local channel = tostring(appconfig.ROOT_CGI_SID) or ""
                            local canGetAppBunkleId = (nk ~= nil) and (nk["Native"] ~= nil) and (nk.Native["getAppBundleId"] ~= nil)
                            local finalPid = (canGetAppBunkleId and nk.Native:getAppBundleId() or "com.boyaa.pokdeng") .. "." .. typeStr .. pid
                            -- self.store_:purchaseProduct(finalPid)
                            self.invokeStoreMethod_("purchaseProduct",finalPid)
                            -- self.invokeJavaMethod_("makePurchase", {orderId, tostring(pid), uid, channel}, "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V")
                            self.isPurchasing_ = true
                            self:restoreOrderInfo(pid,orderId,typeStr)
                            break
                        end


                    end

                end


            end

            
        else
            self.isPurchasing_ = false
            self:clearOrderInfo()
        end
        
    end,function()
        self.isPurchasing_ = false
        self:clearOrderInfo()
        self.callPayOrderReqId_ = nil
    end)

end


function InAppPurchasePurchaseService:restoreOrderInfo(pid,orderId,ptype)
    local payInfoStr = pid .. "#" .. orderId .. "#" .. ptype
    nk.userDefault:setStringForKey(nk.cookieKeys.IOS_ORDER_INFO, payInfoStr)
    nk.userDefault:flush()
end

function InAppPurchasePurchaseService:clearOrderInfo()
    nk.userDefault:setStringForKey(nk.cookieKeys.IOS_ORDER_INFO, "")
    nk.userDefault:flush()
end

--OC to lua
function InAppPurchasePurchaseService:loadProductFinished_(evt)
    self.isProductRequesting_ = false
    local function getPriceLabel(prd)
        return luaoc.callStaticMethod(
                            "LuaOCBridge", 
                            "getPriceLabel", 
                            {
                                priceLocale = prd.priceLocale, 
                                price = prd.price, 
                            }
                        )
    end
    
    if evt.products and #evt.products > 0 then
        --更新价格
        for i, prd in ipairs(evt.products) do
            if self.products_.chips then
                for j, chip in ipairs(self.products_.chips) do
                    if prd.productIdentifier == chip.pid then
                        local ok, price = getPriceLabel(prd)
                        if ok then
                            chip.priceLabel = price
                        else
                            chip.priceLabel = prd.price
                        end
                        chip.priceNum = prd.price
                    end
                end
            end
            if self.products_.props then
                for j, prop in ipairs(self.products_.props) do
                    if prd.productIdentifier == prop.pid then
                        local ok, price = getPriceLabel(prd)
                        if ok then
                            prop.priceLabel = price
                        else
                            prop.priceLabel = prd.price
                        end
                        prop.priceNum = prd.price
                    end
                end
            end
            if self.products_.coins then
                for j, coin in ipairs(self.products_.coins) do
                    if prd.productIdentifier == coin.pid then
                        local ok, price = getPriceLabel(prd)
                        if ok then
                            coin.priceLabel = price
                        else
                            coin.priceLabel = prd.price
                        end
                        coin.priceNum = prd.price
                    end
                end
            end

            if self.products_.tickets then
                for j, ticket in ipairs(self.products_.tickets) do
                    if prd.productIdentifier == ticket.pid then
                        local ok, price = getPriceLabel(prd)

                        if ok then
                            ticket.priceLabel = price
                        else
                            ticket.priceLabel = prd.price
                        end
                        ticket.priceNum = prd.price
                    end
                end
            end

            if self.products_.cash then
                for j, cash in ipairs(self.products_.cash) do
                    if prd.productIdentifier == cash.pid then
                        local ok, price = getPriceLabel(prd)
                    
                        if ok then
                            cash.priceLabel = price
                        else
                            cash.priceLabel = prd.price
                        end
                        cash.priceNum = prd.price
                    end
                end
            end
        end
        self.isProductPriceLoaded_ = true
        self:loadProcess_()
        return
    end
    self:invokeCallback_(3, true, bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
end
--OC to lua
function InAppPurchasePurchaseService:transactionPurchased_(evt)
    nk.TopTipManager:showTopTip(bm.LangUtil.getText("STORE", "PURCHASE_SUCC_AND_DELIVERING"))
    self:delivery(evt.transaction, true)
    -- if device.platform == "windows" then
    --     --todo
    --     self.purchaseCallback_(true, "succ!")
    -- else
    --     self:delivery(evt.transaction, true)
    -- end
end
--OC to lua
function InAppPurchasePurchaseService:transactionRestored_(evt)
    
    local payInfoStr = nk.userDefault:getStringForKey(nk.cookieKeys.IOS_ORDER_INFO)
    if payInfoStr and payInfoStr ~= "" then
        local payTb = string.split(payInfoStr,"#")
        if payTb and payTb[2] then
          self.orderId_ = payTb[2]
        end
    end
    self.isPurchasing_ = true
    self:delivery(evt.transaction, false)
end
--OC to lua
function InAppPurchasePurchaseService:transactionFailed_(evt)
    nk.TopTipManager:showTopTip(bm.LangUtil.getText("STORE", "PURCHASE_FAILED_MSG"))
    if self.purchaseCallback_ then
        self.purchaseCallback_(false, "ERROR")
    end
    self.isPurchasing_ = false
    self:clearOrderInfo()
end
--OC to lua
function InAppPurchasePurchaseService:transactionUnkownError_(evt)
    nk.TopTipManager:showTopTip(bm.LangUtil.getText("STORE", "PURCHASE_FAILED_MSG"))
    if self.purchaseCallback_ then
        self.purchaseCallback_(false, "ERROR")
    end
    self.isPurchasing_ = false
    self:clearOrderInfo()
end

function InAppPurchasePurchaseService:delivery(transaction, showMsg)


    -- local testStr = "ewoJInNpZ25hdHVyZSIgPSAiQWhWZGNJTnMvY0s3YUJTU3hZY2ZSVDRKOWFsNC8yRXc0WDNaNWg3YS9LWkpVMGxnS3FXdHhEU0xrR2d0amVSLzVkcG1GeTZrVmtlK1ZmMkdrUzlpdlhCN1lENXBxTDFSSVVxbVRPQW42M3Zld0RPb1Q5SWRqUzlnNmVBUVRKWHl4VXE1aFR5a3JLVlphblRNUHJBS3FKdnBuMnVNeWhlOWxad0JSR3ltWEhHMEFBQURWekNDQTFNd2dnSTdvQU1DQVFJQ0NCdXA0K1BBaG0vTE1BMEdDU3FHU0liM0RRRUJCUVVBTUg4eEN6QUpCZ05WQkFZVEFsVlRNUk13RVFZRFZRUUtEQXBCY0hCc1pTQkpibU11TVNZd0pBWURWUVFMREIxQmNIQnNaU0JEWlhKMGFXWnBZMkYwYVc5dUlFRjFkR2h2Y21sMGVURXpNREVHQTFVRUF3d3FRWEJ3YkdVZ2FWUjFibVZ6SUZOMGIzSmxJRU5sY25ScFptbGpZWFJwYjI0Z1FYVjBhRzl5YVhSNU1CNFhEVEUwTURZd056QXdNREl5TVZvWERURTJNRFV4T0RFNE16RXpNRm93WkRFak1DRUdBMVVFQXd3YVVIVnlZMmhoYzJWU1pXTmxhWEIwUTJWeWRHbG1hV05oZEdVeEd6QVpCZ05WQkFzTUVrRndjR3hsSUdsVWRXNWxjeUJUZEc5eVpURVRNQkVHQTFVRUNnd0tRWEJ3YkdVZ1NXNWpMakVMTUFrR0ExVUVCaE1DVlZNd2daOHdEUVlKS29aSWh2Y05BUUVCQlFBRGdZMEFNSUdKQW9HQkFNbVRFdUxnamltTHdSSnh5MW9FZjBlc1VORFZFSWU2d0Rzbm5hbDE0aE5CdDF2MTk1WDZuOTNZTzdnaTNvclBTdXg5RDU1NFNrTXArU2F5Zzg0bFRjMzYyVXRtWUxwV25iMzRucXlHeDlLQlZUeTVPR1Y0bGpFMU93QytvVG5STStRTFJDbWVOeE1iUFpoUzQ3VCtlWnRERWhWQjl1c2szK0pNMkNvZ2Z3bzdBZ01CQUFHamNqQndNQjBHQTFVZERnUVdCQlNKYUVlTnVxOURmNlpmTjY4RmUrSTJ1MjJzc0RBTUJnTlZIUk1CQWY4RUFqQUFNQjhHQTFVZEl3UVlNQmFBRkRZZDZPS2RndElCR0xVeWF3N1hRd3VSV0VNNk1BNEdBMVVkRHdFQi93UUVBd0lIZ0RBUUJnb3Foa2lHOTJOa0JnVUJCQUlGQURBTkJna3Foa2lHOXcwQkFRVUZBQU9DQVFFQWVhSlYyVTUxcnhmY3FBQWU1QzIvZkVXOEtVbDRpTzRsTXV0YTdONlh6UDFwWkl6MU5ra0N0SUl3ZXlOajVVUllISytIalJLU1U5UkxndU5sMG5rZnhxT2JpTWNrd1J1ZEtTcTY5Tkluclp5Q0Q2NlI0Szc3bmI5bE1UQUJTU1lsc0t0OG9OdGxoZ1IvMWtqU1NSUWNIa3RzRGNTaVFHS01ka1NscDRBeVhmN3ZuSFBCZTR5Q3dZVjJQcFNOMDRrYm9pSjNwQmx4c0d3Vi9abEwyNk0ydWVZSEtZQ3VYaGRxRnd4VmdtNTJoM29lSk9PdC92WTRFY1FxN2VxSG02bTAzWjliN1BSellNMktHWEhEbU9Nazd2RHBlTVZsTERQU0dZejErVTNzRHhKemViU3BiYUptVDdpbXpVS2ZnZ0VZN3h4ZjRjemZIMHlqNXdOelNHVE92UT09IjsKCSJwdXJjaGFzZS1pbmZvIiA9ICJld29KSW05eWFXZHBibUZzTFhCMWNtTm9ZWE5sTFdSaGRHVXRjSE4wSWlBOUlDSXlNREUxTFRBNExUQTVJREExT2pBME9qRXdJRUZ0WlhKcFkyRXZURzl6WDBGdVoyVnNaWE1pT3dvSkluQjFjbU5vWVhObExXUmhkR1V0YlhNaUlEMGdJakUwTXpreE1qRTROVEF3T0RFaU93b0pJblZ1YVhGMVpTMXBaR1Z1ZEdsbWFXVnlJaUE5SUNJNE1UVXdaVFpsTkdWa05qSXhORFkyTURBMlpURmpOR0ZqWlRkbU1HSTBPRFU1TURRMk16TXlJanNLQ1NKdmNtbG5hVzVoYkMxMGNtRnVjMkZqZEdsdmJpMXBaQ0lnUFNBaU1qY3dNREF3TVRVMU56VTNNakkzSWpzS0NTSmlkbkp6SWlBOUlDSXhMakF1TWlJN0Nna2lZWEJ3TFdsMFpXMHRhV1FpSUQwZ0lqa3pPVFE0Tmpnek5pSTdDZ2tpZEhKaGJuTmhZM1JwYjI0dGFXUWlJRDBnSWpJM01EQXdNREUxTlRjMU56SXlOeUk3Q2draWNYVmhiblJwZEhraUlEMGdJakVpT3dvSkltOXlhV2RwYm1Gc0xYQjFjbU5vWVhObExXUmhkR1V0YlhNaUlEMGdJakUwTXpreE1qRTROVEF3T0RFaU93b0pJblZ1YVhGMVpTMTJaVzVrYjNJdGFXUmxiblJwWm1sbGNpSWdQU0FpTmpCRE5qWkZNamN0TlRoQ1F5MDBNVUZHTFVFNU4wWXRRekl3TkRoRU1FVkdNalUzSWpzS0NTSnBkR1Z0TFdsa0lpQTlJQ0k1TkRNek9EQXdOelFpT3dvSkluWmxjbk5wYjI0dFpYaDBaWEp1WVd3dGFXUmxiblJwWm1sbGNpSWdQU0FpTnpnMU9ETTFNREl3SWpzS0NTSndjbTlrZFdOMExXbGtJaUE5SUNKamIyMHVjMmhwZVdsdUxuTm9ablF1WjI5c1pEZzVPRFUySWpzS0NTSndkWEpqYUdGelpTMWtZWFJsSWlBOUlDSXlNREUxTFRBNExUQTVJREV5T2pBME9qRXdJRVYwWXk5SFRWUWlPd29KSW05eWFXZHBibUZzTFhCMWNtTm9ZWE5sTFdSaGRHVWlJRDBnSWpJd01UVXRNRGd0TURrZ01USTZNRFE2TVRBZ1JYUmpMMGROVkNJN0Nna2lZbWxrSWlBOUlDSmpiMjB1YzJocGVXbHVMbk5vWm5RaU93b0pJbkIxY21Ob1lYTmxMV1JoZEdVdGNITjBJaUE5SUNJeU1ERTFMVEE0TFRBNUlEQTFPakEwT2pFd0lFRnRaWEpwWTJFdlRHOXpYMEZ1WjJWc1pYTWlPd3A5IjsKCSJwb2QiID0gIjI3IjsKCSJzaWduaW5nLXN0YXR1cyIgPSAiMCI7Cn0="

    -- local tt = crypto.decodeBase64(testStr)

    -- dump(tt,"tt====")

    -- dump(transaction.receipt,"dd====")
    
    -- dump(transaction,"transaction")
    -- do return end
    local date = transaction.date
    local errorCode = transaction.errorCode
    local errorString = transaction.errorString
    local productIdentifier = transaction.productIdentifier
    local quantity = transaction.quantity
    local receipt = crypto.encodeBase64(transaction.receipt)
    -- local receiptObj = json.decode(receipt)
    -- local environment = receiptObj.environment -- "Sandbox"
    -- local pod = receiptObj.pod
    -- local signing_status = receiptObj["signing-status"]
    local receiptVerifyMode = transaction.receiptVerifyMode
    local receiptVerifyStatus = transaction.receiptVerifyStatus
    local state = transaction.state
    local transactionIdentifier = transaction.transactionIdentifier

    local productId = string.gsub(productIdentifier,"%D","")

    local params = {}
    params.pid = self.orderId_ or ""  -- 新流程不需要
    params.pdealno = transactionIdentifier
    params.receipt = receipt
    params.pmode = self.config_.pmode
    params.id = productId or ""

    dump(params,"params")

    if IS_SANDBOX then
        params.test = "test"
    end
    
    local retryLimit = 6
    local deliveryFunc
    deliveryFunc = function()

        self.helper_:callPayDelivery(params, function(jsn)
                -- local jsn = json.decode(ret)
                dump(jsn,"callPayDelivery")

                ---[[
                        -- ErrorCode 
                        -- 1:成功发货或已发货过 
                        -- 2:pid参数不正确
                        -- 5:sign fail
                        -- 6:交易号不一致(回调里面的交易号与调用苹果查询出的交易号不一致)
                        -- 7:bid 参数值非法
                        -- 8:receipt参数有误
                    if jsn then
                        local ErrorCode = tonumber(jsn.ErrorCode)
                        local ErrorDesc = jsn.ErrorDesc
                        local pdealno = jsn.pdealno
                        local pid = jsn.pid --10位订单号
                        local bid = jsn.bid --支付中心后台配置的苹果boundID
                        local appleBid = jsn.appleBid --苹果实际后台配置的boundID

                        if ErrorCode == 1 then
                            self.logger:debug("dilivery success, consume it")
                            self.invokeStoreMethod_("finishTransaction",transaction)
                            if showMsg then
                                nk.TopTipManager:showTopTip(bm.LangUtil.getText("STORE", "DELIVERY_SUCC_MSG"))
                                if self.purchaseCallback_ then
                                    self.purchaseCallback_(true)
                                end
                            end
                            self.isPurchasing_ = false
                            self:clearOrderInfo()


                        else
                            if showMsg then
                                nk.TopTipManager:showTopTip(bm.LangUtil.getText("STORE", "DELIVERY_FAILED_MSG"))
                                if self.purchaseCallback_ then
                                    self.purchaseCallback_(false, "error")
                                end
                            end
                            self.isPurchasing_ = false
                            self:clearOrderInfo()
                            --self.invokeStoreMethod_("finishTransaction",transaction)

                        -- elseif ErrorCode == 2 then
                            
                        -- elseif ErrorCode == 5 then

                        -- elseif ErrorCode == 6 then

                        -- elseif ErrorCode == 7 then

                        -- elseif ErrorCode == 8 then

                        end

                    else
                        self.logger:debug("delivery failed => " .. json.encode(jsn))
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
                            self.isPurchasing_ = false
                            self:clearOrderInfo()
                            --self.invokeStoreMethod_("finishTransaction",transaction)
                        end

                    end
                    


                --]]

                
                --[[
                -- ErrorCode 
                -- 0:已发货过
                -- 1:成功 
                -- 2:参数不正确
                -- 4:参数不完整
                -- 5:sign fail
                -- 6:交易号重复
                -- 7:bid 参数值非法
                
                if jsn then
                    local ErrorCode = tonumber(jsn.ErrorCode)
                    if ErrorCode == 1 then
                         self.logger:debug("dilivery success, consume it")
                        --v3
                        --store:finishTransaction(transaction.transactionIdentifier)
                        --v2
                        -- self.store_:finishTransaction(transaction)
                        self.invokeStoreMethod_("finishTransaction",transaction)
                        if showMsg then
                            nk.TopTipManager:showTopTip(bm.LangUtil.getText("STORE", "DELIVERY_SUCC_MSG"))
                            if self.purchaseCallback_ then
                                self.purchaseCallback_(true)
                            end
                        end
                        self.isPurchasing_ = false
                        self:clearOrderInfo()

                    elseif ErrorCode == 0 then
                        --发过货的订单
                        if showMsg then
                            nk.TopTipManager:showTopTip(bm.LangUtil.getText("STORE", "DELIVERY_FAILED_MSG"))
                            if self.purchaseCallback_ then
                                self.purchaseCallback_(false, "error")
                            end
                        end
                        self.isPurchasing_ = false
                        self:clearOrderInfo()
                        -- self.store_:finishTransaction(transaction)
                        self.invokeStoreMethod_("finishTransaction",transaction)
                    elseif ErrorCode == 6 then
                        --交易号重复的订单
                        local realPid = jsn.realPid
                        local realStatus = jsn.realStatus
                        if 0 == realStatus then
                            --交易号在其他订单号使用过，但未曾发货
                           
                            if params and realPid and realPid ~= "" then
                             --获取交易号所在的订单号重新请求发货
                                params.pid = realPid

                                retryLimit = retryLimit - 1
                                if retryLimit > 0 then
                                    self.schedulerPool_:delayCall(function()
                                        deliveryFunc()
                                    end, 10)
                                else
                                    if showMsg then
                                        nk.TopTipManager:showTopTip(bm.LangUtil.getText("STORE", "DELIVERY_FAILED_MSG"))
                                        if self.purchaseCallback_ then
                                            self.purchaseCallback_(false, "error")
                                        end
                                    end
                                    self.isPurchasing_ = false
                                    self:clearOrderInfo()
                                end

                            else
                                    -- self.store_:finishTransaction(transaction)
                                    self.invokeStoreMethod_("finishTransaction",transaction)
                                    if showMsg then
                                        nk.TopTipManager:showTopTip(bm.LangUtil.getText("STORE", "DELIVERY_FAILED_MSG"))
                                        if self.purchaseCallback_ then
                                            self.purchaseCallback_(false, "error")
                                        end
                                    end
                                    self.isPurchasing_ = false
                                    self:clearOrderInfo()

                            end
                            
                        elseif 2 == realStatus then
                            --交易号在其他订单号使用过，且已发货,需要清除IAP记录
                            -- self.store_:finishTransaction(transaction)
                            self.invokeStoreMethod_("finishTransaction",transaction)
                            self.isPurchasing_ = false
                            self:clearOrderInfo()
                        end
                    end
 
                else
                    self.logger:debug("delivery failed => " .. json.encode(jsn))
                    retryLimit = retryLimit - 1
                    if retryLimit > 0 then
                        self.schedulerPool_:delayCall(function()
                            deliveryFunc()
                        end, 10)
                    else
                        if showMsg then
                            nk.TopTipManager:showTopTip(bm.LangUtil.getText("STORE", "DELIVERY_FAILED_MSG"))
                            if self.purchaseCallback_ then
                                self.purchaseCallback_(false, "error")
                            end
                        end
                        self.isPurchasing_ = false
                        self:clearOrderInfo()
                    end
                end
                --]]

            end, function()
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
                    self.isPurchasing_ = false
                    self:clearOrderInfo()
                    --self.invokeStoreMethod_("finishTransaction",transaction)
                end
            end)
    end
    deliveryFunc()
end



function InAppPurchasePurchaseService:createStoreMethodInvoker()
    if device.platform ~= "ios" then
        self.logger:debugf("call %s failed, not in ios platform", storeMethodName)
        return function()
            return nil
        end
    end
    if not self.store_ then
        self.logger:debugf("call %s failed,self.store_ is nil", storeMethodName)
        return function()
            return nil
        end
    end
    return function(storeMethodName, ...)
        if self.store_ then
            return self.store_[storeMethodName](self.store_,...)
        end
    end

end



return InAppPurchasePurchaseService
