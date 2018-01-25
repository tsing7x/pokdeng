--
-- Author: tony
-- Date: 2014-11-24 21:31:14
--
local PurchaseHelper = import("app.module.newstore.PurchaseHelper")
local Easy2PayPurchaseService = class("Easy2PayPurchaseService", import("app.module.newstore.PurchaseServiceBase"))

local RES_CODE = {}

RES_CODE.EVENT_USER_CANCEL_CHARGE                 = "201"
RES_CODE.EVENT_EASY2PAY_IS_CHARGING               = "202"
RES_CODE.EVENT_EASY2PAY_IS_CHARGING_IN_BACKGROUND = "203"

RES_CODE.ERROR_CANNOT_GET_PRICE_LIST              = "301"
RES_CODE.ERROR_CANNOT_GET_PINCODE                 = "302"
RES_CODE.ERROR_SIMCARD_NOTFOUND                   = "303"
RES_CODE.ERROR_PRICE_IS_INVALID                   = "304"
RES_CODE.ERROR_CANNOT_SEND_SMS                    = "305"
RES_CODE.ERROR_CANNOT_CHARGING                    = "306"

function Easy2PayPurchaseService:ctor()
    Easy2PayPurchaseService.super.ctor(self, "Easy2PayPurchaseService")
    self.helper_ = PurchaseHelper.new("Easy2PayPurchaseService")

    if device.platform == "android" then
        self.invokeJavaMethod_ = self:createJavaMethodInvoker("com/boyaa/cocoslib/easy2pay/Easy2PayBridge")
        self.invokeJavaMethod_("setCallback", {handler(self, self.onSdkResult_)}, "(I)V")
    elseif device.platform == "ios" then
    else
        self.invokeJavaMethod_ = function(method, param, sig)
            if method == "makePurchase" then
                self:onSdkResult_([[{"type":"RESULT", "purchaseCode":"200"}]])
            end
        end
    end
end

function Easy2PayPurchaseService:init(config)
    self.config_ = config
    self.active_ = true
    self.isPurchasing_ = false
    self.helper_:cacheConfig(config.configURL, handler(self, self.configLoadHandler_))
end

function Easy2PayPurchaseService:autoDispose()
    self.active_ = false
    self.loadChipRequested_ = false
    self.loadPropRequested_ = false
     self.loadTicketRequested_ = false
    self.loadCashRequested_ = false
    self.loadChipCallback_ = nil
    self.loadPropCallback_ = nil
    self.loadTicketCallback_ = nil
    self.loadCashCallback_ = nil
    self.purchaseCallback_ = nil
end

--callback(payType, isComplete, data)
function Easy2PayPurchaseService:loadChipProductList(callback)
    self.loadChipCallback_ = callback
    self.loadChipRequested_ = true
    self:loadProcess_()
end

--callback(payType, isComplete, data)
function Easy2PayPurchaseService:loadPropProductList(callback)
    self.loadPropCallback_ = callback
    self.loadPropRequested_ = true
    self:loadProcess_()
end

function Easy2PayPurchaseService:loadTicketProductList(callback)
    self.loadTicketCallback_ = callback
    self.loadTicketRequested_ = true
    self:loadProcess_()
end

function Easy2PayPurchaseService:loadCashProductList(callback)
    -- body
    self.loadCashCallback_ = callback
    self.loadCashRequested_ = true
    self:loadProcess_()
end

function Easy2PayPurchaseService:loadProcess_()
    if not self.products_ then
        self.logger:debug("remote config is loading..")
        self.helper_:cacheConfig(self.config_.configURL, handler(self, self.configLoadHandler_))
        self:invokeCallback_(3, false)
    elseif self.loadChipRequested_ or self.loadPropRequested_ or self.loadTicketRequested_ or self.loadCashRequested_ then
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

function Easy2PayPurchaseService:invokeCallback_(flag, isComplete, data)
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
        -- dump("---self.loadCashCallback_ Call!---")
        self.loadCashCallback_(self.config_, isComplete, data)
    end

end

function Easy2PayPurchaseService:filterProducts(datas)
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


function Easy2PayPurchaseService:configLoadHandler_(succ, content)
    if succ then
        self.logger:debug("remote config file loaded.")
        local payInfo = {}
        local jsonObj = json.decode(content)
        local payInfo = {}
        self.products_ = self.helper_:parseConfig(jsonObj, function(category, json, product)
            if category == "chips" then
                payInfo[product.pid] = {
                    merchantId="4056",
                    priceId = tostring(product.price),
                }
            elseif category == "props" then
                payInfo[product.pid] = {
                    merchantId="4057",
                    priceId = tostring(product.price),
                }
            end
            product.priceLabel = string.format("%dTHB", product.price)
            product.priceNum = product.price
            product.priceDollar = "THB"
        end)
        if self.products_ then
            self.products_.payInfo = payInfo
        end
        self:loadProcess_()
    else
        self.logger:debug("remote config file load failed.")
        self:invokeCallback_(3, true, bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
    end
end

function Easy2PayPurchaseService:makePurchase(pid, callback)
    if self.isPurchasing_ then
        self:toptip(bm.LangUtil.getText("STORE", "BUSY_PURCHASING_MSG"))
        return
    end


    self.isPurchasing_ = true
    self.purchaseCallback_ = callback
    self.logger:debug("make purchase ", pid)
    local generateOrderIdFunc
    local retryTimes = 4
    local userId = tostring(nk.userData.uid)
    local payInfo = self.products_.payInfo[pid]
    if userId and payInfo and pid and userId ~= "" and payInfo.merchantId and payInfo.priceId then
        generateOrderIdFunc = function()
            bm.HttpService.POST({
                mod="easyTwoPay",
                act="createOrderId",
                payTypeId=self.config_.id,
                pid=pid,
            },
            function(data)
                if not self.active_ then return end
                local tb = json.decode(data)
                if tb and tb.ret == 0 then
                    self.logger:debugf("call makePurchase -> %s, %s, %s, %s", tb.orderId, userId, payInfo.merchantId, payInfo.priceId)

                    if device.platform == 'ios' then

                        local function start()
                        end
                        local function finish()
                            if not tolua.isnull(self.openWebviewLoading) then
                                self.openWebviewLoading:hide()
                            end
                        end
                        local function fail(error_info)
                            if not tolua.isnull(self.openWebviewLoading) then
                                self.openWebviewLoading:hide()
                            end
                        end
                        local function userClose()

                            self.bgLayer:removeFromParent()
                            self.bgLayer = nil
                            self.openWebviewLoading = nil -- child of bgLayer
                            nk.SoundManager:playSound(nk.SoundManager.CLOSE_BUTTON)

                            -- 清除 正在支付 状态
                            self.isPurchasing_ = false
                        end

                        -- webview
                        local W, H = 860, 614 - 72
                        local x, y = display.cx - W / 2, display.cy - H / 2

                        local view, err = Webview.create(start, finish, fail, userClose)
                        if view then
                            view:show(x,y,W,H)
                            view:updateURL(tb.url)
                        end

                        self.bgLayer = display.newNode():addTo(display.getRunningScene(), 10000)
                        self.bgLayer:setTouchEnabled(true)
                        self.bgLayer:addNodeEventListener(cc.NODE_TOUCH_EVENT, function() return true end)

                        display.newColorLayer(cc.c4b(0, 0, 0, 128)):addTo(self.bgLayer)
                        self.openWebviewLoading = nk.ui.Juhua.new()
                            :addTo(self.bgLayer)
                            :pos(display.cx, display.cy)
                            :show()

                    else
                        local args = {tb.orderId, userId, payInfo.merchantId, payInfo.priceId}
                        local sig = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V"
                        self.invokeJavaMethod_("makePurchase", args, sig)
                    end
                else
                    retryTimes = retryTimes - 1
                    if retryTimes > 0 then
                        generateOrderIdFunc()
                    else
                        self.isPurchasing_ = false
                        nk.badNetworkToptip()
                    end
                end
            end,
            function()
                if not self.active_ then return end
                retryTimes = retryTimes - 1
                if retryTimes > 0 then
                    generateOrderIdFunc()
                else
                    self.isPurchasing_ = false
                    nk.badNetworkToptip()
                end
            end)
        end
        generateOrderIdFunc()
    else
        self.isPurchasing_ = false
        nk.badNetworkToptip()
    end
end

function Easy2PayPurchaseService:onSdkResult_(jsonString)
    self.logger:debug("purchase result:", jsonString)
    local tb = json.decode(jsonString)
    if tb.type == "ERROR" then
        if tb.desc and tb.desc ~= "" then
            self:toptip(tb.desc)
        else
            local errCode = tb.errCode
            if errCode == RES_CODE.ERROR_CANNOT_GET_PRICE_LIST then
                self:toptip("Price ID is invalid or your mobile network does not support!")
            elseif errCode == RES_CODE.ERROR_CANNOT_GET_PINCODE then
                self:toptip(string.format("SDK internal error (error code:%s)", errCode))
            elseif errCode == RES_CODE.ERROR_SIMCARD_NOTFOUND then
                self:toptip("Sorry! We can not detect your mobile country and network code. It may cause of you are not inserted a sim card.")
            elseif errCode == RES_CODE.ERROR_PRICE_IS_INVALID then
                self:toptip("Price ID is invalid or your mobile network does not support!")
            elseif errCode == RES_CODE.ERROR_CANNOT_SEND_SMS then
                self:toptip("SMS sending fail")
            elseif errcode == RES_CODE.ERROR_CANNOT_CHARGING then
                self:toptip("Charging fail! Please try again later.")
            else
                self:toptip("Unknown error! Please try again later.")
            end
        end
        self.isPurchasing_ = false
    elseif tb.type == "EVENT" then
        if tb.desc and tb.desc ~= "" then
            self:toptip(tb.desc)
        else
            local eventCode = tb.eventCode
            if eventCode == RES_CODE.EVENT_USER_CANCEL_CHARGE then
                self.isPurchasing_ = false
                self:toptip(bm.LangUtil.getText("STORE", "PURCHASE_CANCELED_MSG"))
            elseif eventCode == RES_CODE.EVENT_EASY2PAY_IS_CHARGING then
                self:toptip("Charging .. Please wait")
            elseif eventCode == RES_CODE.EVENT_EASY2PAY_IS_CHARGING_IN_BACKGROUND then
                self:toptip("Charging .. Please wait")
            end
        end
    elseif tb.type == "RESULT" then
        self.isPurchasing_ = false
        --[[
          100 - No MO : The txid and pin code have been initiated but no SMS MO from end-user.
          200 - Success : Billing successful.
          201 - Pending : Billing not finish yet because Easy2Pay waiting for DN from telco.
          400 - Bad request : The parameter(s) not complete or invalid.
          401 - Unauthorized : 'sig' does not match with partner calculated.
          404 - txId not found.
          500 - Internal server error.
          609 - Telco return fail (telco status code : telco status detail).
          669 - Insufficient Balance.
        ]]
        local purchaseCode = tb.purchaseCode
        if tb.desc and tb.desc ~= "" then
            self:toptip(tb.desc)
        else
            if purchaseCode == "200" then
                self:toptip(bm.LangUtil.getText("STORE", "DELIVERY_SUCC_MSG"))
            elseif purchaseCode == "669" then
                self:toptip("Sorry, you have not enough balance")
            elseif purchaseCode == "201" then
                self:toptip("processing ..")
            else
                self:toptip(bm.LangUtil.getText("STORE", "PURCHASE_FAILED_MSG"))
            end
        end
        if purchaseCode == "200" then
            if self.purchaseCallback_ then
                self.purchaseCallback_(true)
            end
        end
    end
end

function Easy2PayPurchaseService:toptip(msg)
    nk.TopTipManager:showTopTip(msg)
end

return Easy2PayPurchaseService
