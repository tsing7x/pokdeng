--
-- Author: Jonah0608@gmail.com
-- Date: 2015-10-14 16:32:14
--
local PurchaseHelper = import("app.module.newstore.PurchaseHelper")
local Easy2PayApiPurchaseService = class("Easy2PayApiPurchaseService", import("app.module.newstore.PurchaseServiceBase"))

local RES_CODE_SUCC              = "100"
local RES_CODE_NOT_SUPPORT       = "201"
local RES_CODE_NOT_OPERATORCODE  = "202"
local RES_CODE_SMS_SENT_FAIL     = "300"
local RES_CODE_SMS_TEXT_EMPTY    = "401"
local RES_CODE_SMS_ADDRESS_EMPTY = "402"
local RES_CODE_SMS_NOSIM         = "404"
local RES_CODE_SMS_NO_PRICEPOINT = "500"

function Easy2PayApiPurchaseService:ctor()
    self.payStatistics_ = {}
    Easy2PayApiPurchaseService.super.ctor(self, "Easy2PayApiPurchaseService")
    self.helper_ = PurchaseHelper.new("Easy2PayApiPurchaseService")

    if device.platform == "android" then
        self.invokeJavaMethod_ = self:createJavaMethodInvoker("com/boyaa/cocoslib/easy2payapi/Easy2PayApiBridge")
        self.invokeJavaMethod_("setCallback", {handler(self, self.onPayResult_)}, "(I)V")
    elseif device.platform == "ios" then
    else
         self.invokeJavaMethod_ = function(method, param, sig)
            if method == "makePurchase" then
                self:onPayResult_([[{"code":"100", "msg":""}]])
            end
        end
    end
end

function Easy2PayApiPurchaseService:init(config)
    self.config_ = config
    self.active_ = true
    self.isPurchasing_ = false
    self.helper_:cacheConfig(config.configURL, handler(self, self.configLoadHandler_))
end

function Easy2PayApiPurchaseService:autoDispose()
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
function Easy2PayApiPurchaseService:loadChipProductList(callback)
    self.loadChipCallback_ = callback
    self.loadChipRequested_ = true
    self:loadProcess_()
end

--callback(payType, isComplete, data)
function Easy2PayApiPurchaseService:loadPropProductList(callback)
    self.loadPropCallback_ = callback
    self.loadPropRequested_ = true
    self:loadProcess_()
end

function Easy2PayApiPurchaseService:loadTicketProductList(callback)
    self.loadTicketCallback_ = callback
    self.loadTicketRequested_ = true
    self:loadProcess_()
end

function Easy2PayApiPurchaseService:loadCashProductList(callback)
    -- body
    self.loadCashCallback_ = callback
    self.loadCashRequested_ = true
    self:loadProcess_()
end

function Easy2PayApiPurchaseService:loadProcess_()
    if not self.products_ then
        self.logger:debug("remote config is loading..")
        self.helper_:cacheConfig(self.config_.configURL, handler(self, self.configLoadHandler_))
        self:invokeCallback_(3, false)
    elseif self.loadChipRequested_ or self.loadPropRequested_ or self.loadTicketRequested_ or self.loadCashRequested_ then
        self.helper_:updateDiscount(self.products_, self.config_)
        local notProductTip = bm.LangUtil.getText("STORE", "NO_PRODUCT_HINT")

        dump(checktable(self.products_.cash),"(checktable(self.products_.cash)")
        self:invokeCallback_(1, true, #(checktable(self.products_.chips)) > 0 and (self.products_.chips) or notProductTip)
        self:invokeCallback_(2, true, #(checktable(self.products_.props)) > 0 and (self.products_.props) or notProductTip)
        self:invokeCallback_(4, true, #(checktable(self.products_.tickets)) > 0 and (self.products_.tickets) or notProductTip)
        self:invokeCallback_(5, true, #(checktable(self.products_.cash)) > 0 and (self.products_.cash) or notProductTip)
    else
        self:invokeCallback_(3, false)
    end
end

function Easy2PayApiPurchaseService:invokeCallback_(flag, isComplete, data)
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

function Easy2PayApiPurchaseService:configLoadHandler_(succ, content)
    if succ then
        self.logger:debug("remote config file loaded.")
        local payInfo = {}
        local jsonObj = json.decode(content)
        local payInfo = {}
        self.products_ = self.helper_:parseConfig(jsonObj, function(category, json, product)
            -- if category == "chips" then
            --     payInfo[product.pid] = {
            --         merchantId="4213",
            --         priceId = tostring(product.price),
            --     }
            -- elseif category == "props" then
            --     payInfo[product.pid] = {
            --         merchantId="4213",
            --         priceId = tostring(product.price),
            --     }
            -- end

            payInfo[product.pid] = 
            {
                merchantId="4213",
                priceId = tostring(product.price),
            }
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

function Easy2PayApiPurchaseService:makePurchase(pid, callback,goodData)
    if self.isPurchasing_ then
        self:toptip(bm.LangUtil.getText("STORE", "BUSY_PURCHASING_MSG"))
        return
    end

    self.purchaseCallback_ = callback

    local params = {}
    params.id = goodData.pid
    params.pmode = goodData.pmode

    nk.ui.Dialog.new({
            messageText = bm.LangUtil.getText("STORE", "CHECK_BUY", goodData.title),
            secondBtnText = bm.LangUtil.getText("STORE", "SURE_COST_BUY", goodData.price),
            hasCloseButton = true,
            callback = function (ctype)
                if ctype == nk.ui.Dialog.SECOND_BTN_CLICK then
                    self.isPurchasing_ = true
                    self.logger:debug("make purchase ", pid)
                    local generateOrderIdFunc
                    local retryTimes = 4
                    local userId = tostring(nk.userData.uid)
                    local payInfo = self.products_.payInfo[pid]

                    if userId and payInfo and pid and userId ~= "" and payInfo.merchantId and payInfo.priceId then
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
                                        -- local URL = callData["URL"]


                                        
                                        -- RET -- 0:success  非0:errorCode
                                        if 0 == RET then
                    

                                            local uid = tostring(nk.userData.uid) or ""

                                            if device.platform == "ios" then
                                                -- self:showPayWebView(URL);
                                            else
                                                local args = {ORDER, uid, payInfo.merchantId, payInfo.priceId}
                                                local sig = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V"
                                                self.invokeJavaMethod_("makePurchase", args, sig)
                                            end
                                        else
                                            self.purchaseCallback_(false, "Wrong In PayOrder Return！")
                                        end
                                        
                                    end,function()
                                        self.callPayOrderReqId_ = nil
                                        self.purchaseCallback_(false, "Wrong In PayOrder Process！")
                                    end)

                    else
                        self.isPurchasing_ = false
                        nk.badNetworkToptip()
                    end
                else
                    self.purchaseCallback_(false, "Cancel By User！")
                end
            end
    }):show()
end


function Easy2PayApiPurchaseService:onPayResult_(jsonString)
    self.isPurchasing_ = false
    local tb = json.decode(jsonString)
    self.isPurchasing_ = false
    if tb and tb.code then
         local errCode = tb.code
        if errCode == RES_CODE_SUCC then
            local str = bm.LangUtil.getText("E2P_TIPS","SMS_SUCC")
            self:toptip(str)
            if self.purchaseCallback_ then
                self.purchaseCallback_(true, self.pendingPid)
            end
            if nk.userData.best  then
                nk.userData.best.paylog = 1
            end
    
        elseif errCode == RES_CODE_NOT_SUPPORT then
            local str = bm.LangUtil.getText("E2P_TIPS","NOT_SUPPORT")
            self:toptip(str)
        elseif errCode == RES_CODE_NOT_OPERATORCODE then
            local str = bm.LangUtil.getText("E2P_TIPS","NOT_OPERATORCODE")
            self:toptip(str)
        elseif errCode >=300 and errCode <400 then
            local str = bm.LangUtil.getText("E2P_TIPS","SMS_SENT_FAIL")
            self:toptip(str)
        elseif errCode == RES_CODE_SMS_TEXT_EMPTY then
            local str = bm.LangUtil.getText("E2P_TIPS","SMS_TEXT_EMPTY")
            self:toptip(str)
        elseif errCode == RES_CODE_SMS_ADDRESS_EMPTY then
            local str = bm.LangUtil.getText("E2P_TIPS","SMS_ADDRESS_EMPTY")
            self:toptip(str)
        elseif errCode == RES_CODE_SMS_NOSIM then
            local str = bm.LangUtil.getText("E2P_TIPS","SMS_NOSIM")
            self:toptip(str)
        elseif errCode == RES_CODE_SMS_NO_PRICEPOINT then
            local str = bm.LangUtil.getText("E2P_TIPS","SMS_NO_PRICEPOINT")
            self:toptip(str)
        end
    else
        self:toptip(str)
    end
end

function Easy2PayApiPurchaseService:toptip(msg)
    nk.TopTipManager:showTopTip(msg)
end

return Easy2PayApiPurchaseService