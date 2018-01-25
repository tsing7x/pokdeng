-- module app.module.newstore.services.MolPurchaseService.lua
-- Author: tony
-- Date: 2014-12-16 20:29:21
--
local PurchaseHelper = import("app.module.newstore.PurchaseHelper")
local PURCHASE_TYPE = import("app.module.newstore.PURCHASE_TYPE")
local MolPurchaseService = class("MolPurchaseService", import("app.module.newstore.PurchaseServiceBase"))

function MolPurchaseService:ctor()
    MolPurchaseService.super.ctor(self, "MolPurchaseService")
    self.helper_ = PurchaseHelper.new("MolPurchaseService")
end

function MolPurchaseService:init(config)
    if config then
        if config.id == PURCHASE_TYPE.MOL_TRUE_MONEY or config.id == PURCHASE_TYPE.MOL_12_CALL then
            config.inputType = "singleLine"
        else
            config.inputType = "twoLine"
        end
    end
    self.config_ = config
    self.active_ = true
    self.isPurchasing_ = false
    self.helper_:cacheConfig(config.configURL, handler(self, self.configLoadHandler_))
end

-- 目前MOL 支付渠道只有 泰语版 (?), 所以这里没有多语言支持

function MolPurchaseService:prepareEditBox(input1, input2, submitBtn)
    if self.config_.id == PURCHASE_TYPE.MOL_TRUE_MONEY then
        --=14个数字密码
        input1:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
        input1:setMaxLength(14)
        input1:setPlaceHolder("กรุณากรอกรหัสเติมเงินตรงนี้ค่ะ")
    elseif self.config_.id == PURCHASE_TYPE.MOL_12_CALL then
        --<=16个数字密码
        input1:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
        input1:setMaxLength(16)
        input1:setPlaceHolder("กรุณากรอกรหัสเติมเงินตรงนี้ค่ะ")
    elseif self.config_.id == PURCHASE_TYPE.MOL_Z_CARD then
        --=12位数字+字母账号
        input1:setMaxLength(12)
        input1:setPlaceHolder("กรุณากรอกหมายเลขSerialที่นี้ค่ะ")
        --=12位数字+字母密码
        input2:setMaxLength(12)
        input2:setPlaceHolder("กรุณากรอกPINที่นี้ค่ะ")
    elseif self.config_.id == PURCHASE_TYPE.MOL_POINT_CARD then
        --=10位数字+字母账号
        input1:setMaxLength(10)
        input1:setPlaceHolder("กรุณากรอกหมายเลขSerialที่นี้ค่ะ")
        --=14位数字+字母密码
        input2:setMaxLength(14)
        input2:setPlaceHolder("กรุณากรอกPINที่นี้ค่ะ")
    end
end

function MolPurchaseService:onInputCardInfo(productType, input1, input2, submitBtn, callback)

    if nk.userData.best  then
        nk.userData.best.paylog = 1
    end
    
    local serial_no = nil
    local pin_no = nil
    local cardInput1 = input1:getText()
    local cardInput2 = input2:getText()
    cardInput1 = (cardInput1 and string.trim(cardInput1) or nil)
    cardInput2 = (cardInput2 and string.trim(cardInput2) or nil)
    if cardInput1 == "" then cardInput1 = nil end
    if cardInput2 == "" then cardInput2 = nil end
    if self.config_.id == PURCHASE_TYPE.MOL_TRUE_MONEY then
        if not cardInput1 then
            self:toptip("กรุณากรอกรหัสเติมเงินก่อนค่ะ")
            return
        end
        pin_no = cardInput1
    elseif self.config_.id == PURCHASE_TYPE.MOL_12_CALL then
        if not cardInput1 then
            self:toptip("กรุณากรอกรหัสเติมเงินก่อนค่ะ")
            return
        end
        pin_no = cardInput1
    elseif self.config_.id == PURCHASE_TYPE.MOL_Z_CARD then
        if not cardInput1 or not cardInput2 then
            self:toptip("กรุณากรอกSerialและPINก่อนค่ะ")
            return
        end
        serial_no = cardInput1
        pin_no = cardInput2
    elseif self.config_.id == PURCHASE_TYPE.MOL_POINT_CARD then
        if not cardInput1 or not cardInput2 then
            self:toptip("กรุณากรอกSerialและPINก่อนค่ะ")
            return
        end
        serial_no = cardInput1
        pin_no = cardInput2
    end

    self.purchaseCallback_ = callback
    local request
    local retry = 3
    submitBtn:setButtonEnabled(false)

    request = function()

        local params = {}
        local pid = 0

        --如果商品列表不为空，随便取特定类型的一个商品id,暂定第一个
        if self.products_ and productType and self.products_[productType] and (#self.products_[productType] > 0) then
            local p = self.products_[productType][1]
            pid =  p.id
        end

        if (not pid) or (pid == 0) then
            self:toptip(bm.LangUtil.getText("STORE", "PURCHASE_FAILED_MSG"))
            return
        end

        params.id = pid
        params.pmode = self.config_.pmode
        params.serial_no = serial_no
        params.pin_no = pin_no
        params.channel = self.config_.name

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
            local errCode = callData.errCode -- 错误码（成功返回：200）
            local errMsg = callData.errMsg    --错误描述（成功返回：suc）


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

            local errCode = callData.errCode -- 错误码（成功返回：200）
            local errMsg = callData.errMsg    --错误描述（成功返回：suc）
            --]]

            if RET == 0 then
                self:toptip(bm.LangUtil.getText("STORE", "DELIVERY_SUCC_MSG"))
                submitBtn:setButtonEnabled(true)
                if self.purchaseCallback_ then
                    self.purchaseCallback_(true)
                end

            else
                -- self:toptip(jsn.msg)
                -- submitBtn:setButtonEnabled(true)
                retry = retry - 1
                if retry > 0 then
                    request()
                else
                    submitBtn:setButtonEnabled(true)
                    nk.badNetworkToptip()
                end
            end

        end,function(errData)
            self.callPayOrderReqId_ = nil
            retry = retry - 1
            if retry > 0 then
                request()
            else
                submitBtn:setButtonEnabled(true)
                nk.badNetworkToptip()
            end
        end)

        
    end


    --[[
    request = function()
        local secret = "boomeggMOLPay!@!^"
        local ptype = productType
        local uid = nk.userData.uid
        local rand = tostring(bm.getTime())
        local sig = crypto.md5(secret .. ptype .. pin_no .. uid .. rand)
        bm.HttpService.POST({
                mod="molPayment",
                act="createOrderId",
                payTypeId=self.config_.id,
                ptype = ptype,
                pin_no=pin_no,
                serial_no=serial_no,
                rand=rand,
                sig=sig
            }, function(data)
                local jsn = json.decode(data)
                if jsn and jsn.ret == 0 then
                    self:toptip(bm.LangUtil.getText("STORE", "DELIVERY_SUCC_MSG"))
                    submitBtn:setButtonEnabled(true)
                    if self.purchaseCallback_ then
                        self.purchaseCallback_(true)
                    end
                elseif jsn and jsn.msg then
                    self:toptip(jsn.msg)
                    submitBtn:setButtonEnabled(true)
                else
                    retry = retry - 1
                    if retry > 0 then
                        request()
                    else
                        submitBtn:setButtonEnabled(true)
                        nk.badNetworkToptip()
                    end
                end
            end,
            function()
                retry = retry - 1
                if retry > 0 then
                    request()
                else
                    submitBtn:setButtonEnabled(true)
                    nk.badNetworkToptip()
                end
            end)
    end
    --]]
    request()
end

function MolPurchaseService:autoDispose()
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
        nk.http.cancel(callPayOrderReqId_)
        self.callPayOrderReqId_ = nil
    end
end

--callback(payType, isComplete, data)
function MolPurchaseService:loadChipProductList(callback)
    self.loadChipCallback_ = callback
    self.loadChipRequested_ = true
    self:loadProcess_()
end

--callback(payType, isComplete, data)
function MolPurchaseService:loadPropProductList(callback)
    self.loadPropCallback_ = callback
    self.loadPropRequested_ = true
    self:loadProcess_()
end

function MolPurchaseService:loadTicketProductList(callback)
    self.loadTicketCallback_ = callback
    self.loadTicketRequested_ = true
    self:loadProcess_()
end

function MolPurchaseService:loadCashProductList(callback)
    -- body
    self.loadCashCallback_ = callback
    self.loadCashRequested_ = true
    self:loadProcess_()
end

function MolPurchaseService:loadProcess_()
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

function MolPurchaseService:invokeCallback_(flag, isComplete, data)
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



function MolPurchaseService:filterProducts(datas)
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

function MolPurchaseService:configLoadHandler_(succ, content)
    if succ then
        self.logger:debug("remote config file loaded.")
        local jsonObj = json.decode(content)
        self:filterProducts(jsonObj)
        self.products_ = self.helper_:parseConfig(jsonObj, function(category, json, product)
            -- if category == "chips" then elseif category == "props" then end
            product.buyButtonEnabled = false
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

function MolPurchaseService:makePurchase(pid, callback)
end

function MolPurchaseService:toptip(msg)
    nk.TopTipManager:showTopTip(msg)
end

return MolPurchaseService
