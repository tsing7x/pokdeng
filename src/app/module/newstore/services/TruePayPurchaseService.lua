--
-- Author: Vanfo
-- Date: 2015-12-16 16:22:20
--
local PurchaseHelper = import("app.module.newstore.PurchaseHelper")
local TruePayPurchaseService = class("TruePayPurchaseService", import("app.module.newstore.PurchaseServiceBase"))

function TruePayPurchaseService:ctor()
    TruePayPurchaseService.super.ctor(self, "TruePayPurchaseService")
    self.helper_ = PurchaseHelper.new("TruePayPurchaseService")
end

function TruePayPurchaseService:init(config)
    self.config_ = config
    self.active_ = true
    self.isPurchasing_ = false

    if not self.products_ then
        self.logger:debug("remote config is loading..")
        self.helper_:cacheConfig(self.config_.configURL, handler(self, self.configLoadHandler_))
    end
end

function TruePayPurchaseService:autoDispose()
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

    if self.callPayOrderReqId_ then
        nk.http.cancel(self.callPayOrderReqId_)
        self.callPayOrderReqId_ = nil
    end

    --  if self.appForegroundListenerId_ then
    --     bm.EventCenter:removeEventListener(self.appForegroundListenerId_)
    --     self.appForegroundListenerId_ = nil
    -- end
    
end

--callback(payType, isComplete, data)
function TruePayPurchaseService:loadChipProductList(callback)
    self.loadChipCallback_ = callback
    self.loadChipRequested_ = true
    self:loadProcess_()
end

--callback(payType, isComplete, data)
function TruePayPurchaseService:loadPropProductList(callback)
    self.loadPropCallback_ = callback
    self.loadPropRequested_ = true
    self:loadProcess_()
end

function TruePayPurchaseService:loadTicketProductList(callback)
    self.loadTicketCallback_ = callback
    self.loadTicketRequested_ = true
    self:loadProcess_()
end

function TruePayPurchaseService:loadCashProductList(callback)
    -- body
    self.loadCashCallback_ = callback
    self.loadCashRequested_ = true
    self:loadProcess_()
end

function TruePayPurchaseService:makePurchase(pid, callback,goodData)

    if nk.userData.best  then
        nk.userData.best.paylog = 1
    end
    
    self.purchaseCallback_ = callback
    local params = {}
    params.id = goodData.pid
    params.pmode = goodData.pmode

    nk.ui.Dialog.new({
            messageText = bm.LangUtil.getText("STORE", "CHECK_BUY", goodData.title),
            -- secondBtnText = bm.LangUtil.getText("STORE", "SURE_COST_BUY", goodData.price),
            hasCloseButton = true,
            callback = function (ctype)
                if ctype == nk.ui.Dialog.SECOND_BTN_CLICK then
                    self.callPayOrderReqId_ = self.helper_:callPayOrder(params,function(callData)
                        self.callPayOrderReqId_ = nil


                        if checkint(callData.code) ~= 0 then
                            --某些原因下单失败
                            local errTips = (callData.msg == nil or callData.msg == "") and (bm.LangUtil.getText("STORE", "PURCHASE_FAILED_MSG")) or callData.msg
                            nk.TopTipManager:showTopTip(errTips)

                            -- self.purchaseCallback_(false, "Wrong In PayOrder Process！")
                        else
                            --成功下单
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

                            local terminal = callData["terminal"]
                            local content = callData["content"]

                            -- RET -- 0:success  非0:errorCode
                            if 0 == RET then
                                if (terminal and terminal ~= "") and (content and content ~= "") then
                                    if not self.appForegroundListenerId_ then
                                        self.appForegroundListenerId_ = bm.EventCenter:addEventListener(nk.eventNames.APP_ENTER_FOREGROUND, handler(self, self.onSendSmsReturned_))
                                    end
                                    self:payBySMS(content,terminal)
                                end
                            else
                                -- self.purchaseCallback_(false, "Wrong In PayOrder Return！")
                            end
                        end
                    end,function()
                        self.callPayOrderReqId_ = nil
                        -- self.purchaseCallback_(false, "Wrong In PayOrder Process！")
                    end)
                else
                    -- self.purchaseCallback_(false, "Cancel By User！")
                end
            end
    }):show()
end

function TruePayPurchaseService:payBySMS(content,terminal)
    nk.Native:sendSms(content,terminal)
end

function TruePayPurchaseService:onSendSmsReturned_()
    if self.appForegroundListenerId_ then
        bm.EventCenter:removeEventListener(self.appForegroundListenerId_)
        self.appForegroundListenerId_ = nil
    end
    if self.purchaseCallback_ then
        self.purchaseCallback_(true)
    end
end

--加载商品信息流程
function TruePayPurchaseService:loadProcess_()
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

function TruePayPurchaseService:invokeCallback_(flag, isComplete, data)
    if self.loadChipRequested_ and self.loadChipCallback_ and (flag == 1 or flag == 3) then
        self.loadChipCallback_(self.config_, isComplete, data)
    end
    if self.loadPropRequested_ and self.loadPropCallback_ and (flag == 2 or flag == 3)  then
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

function TruePayPurchaseService:filterProducts(datas)
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

function TruePayPurchaseService:configLoadHandler_(succ, content)
    if succ then
        self.logger:debug("remote config file loaded.")
        local jsonObj = json.decode(content)
        self:filterProducts(jsonObj)
        self.products_ = self.helper_:parseConfig(jsonObj, function(category, json, product)
            product.priceLabel = string.format("%dTHB", product.price)
            product.priceNum = product.price
            product.priceDollar = "THB"
        end)
        self.isProductPriceLoaded_ = false
        self:loadProcess_()
    else
        self.logger:debug("remote config file load failed.")
        self:invokeCallback_(3, true, bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
    end
end

function TruePayPurchaseService:delivery(sku, receipt, signature, showMsg)
   
end

return TruePayPurchaseService