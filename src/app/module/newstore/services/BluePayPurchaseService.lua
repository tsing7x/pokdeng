-- Author: Vanfo
local PURCHASE_CATEGORY = import("..PURCHASE_CATEGORY")
local PurchaseHelper = import("app.module.newstore.PurchaseHelper")
local BluePayPurchaseService = class("BluePayPurchaseService", import("app.module.newstore.PurchaseServiceBase"))

function BluePayPurchaseService:ctor()
    BluePayPurchaseService.super.ctor(self, "BluePayPurchaseService")

    self.helper_ = PurchaseHelper.new("BluePayPurchaseService")

    if device.platform == "android" then
        self.invokeJavaMethod_ = self:createJavaMethodInvoker("com/boyaa/cocoslib/bluepay/BluePayBridge")
        self.invokeJavaMethod_("setSetupCompleteCallback", {handler(self, self.onSetupComplete_)}, "(I)V")
        self.invokeJavaMethod_("setPurchaseCompleteCallback", {handler(self, self.onPurchaseComplete_)}, "(I)V")
    else
        self.invokeJavaMethod_ = function(method, param, sig)
            if method == "setup" then
                self.schedulerPool_:delayCall(function()
                    self:onSetupComplete_("true")
                end, 1)
            elseif method == "payBySMS" then
                self.schedulerPool_:delayCall(function()
                    self:onPurchaseComplete_([[{"isSuccess":"true", "code":"200", "result":"fakesignature","title":"bluepay"}]])
                end, 1)
            elseif method == "isSetupComplete" then
            	return true,true
            elseif method == "isSupported" then
            	return true,true
            end
        end
    end
end

function BluePayPurchaseService:init(config)
	dump(config,"BluePayPurchaseService:init")
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

function BluePayPurchaseService:autoDispose()
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

    if self.callPayOrderReqId_ then
        nk.http.cancel(self.callPayOrderReqId_)
        self.callPayOrderReqId_ = nil
    end
   
end

--callback(payType, isComplete, data)
function BluePayPurchaseService:loadChipProductList(callback)
    self.loadChipCallback_ = callback
    self.loadChipRequested_ = true
    self:loadProcess_()
end

function BluePayPurchaseService:loadTicketProductList(callback)
    self.loadTicketCallback_ = callback
    self.loadTicketRequested_ = true
    self:loadProcess_()
end

function BluePayPurchaseService:loadCashProductList(callback)
    -- body
    self.loadCashCallback_ = callback
    self.loadCashRequested_ = true
    self:loadProcess_()
end

--callback(payType, isComplete, data)
function BluePayPurchaseService:loadPropProductList(callback)
    self.loadPropCallback_ = callback
    self.loadPropRequested_ = true
    self:loadProcess_()
end

function BluePayPurchaseService:makePurchase(pid, callback, goodData)
    self.purchaseCallback_ = callback
    local params = {}
    params.id = goodData.pid
    params.pmode = goodData.pmode

    -- dump(goodData, "BluePayPurchaseService:makePurchase.goodData :====================")
    local discount = checkint(goodData.discount) or 1
    local checkBuyTip = nil

    if discount > 1 then
        --todo
        if goodData.category == PURCHASE_CATEGORY.CHIPS then
            --todo
            checkBuyTip = bm.LangUtil.getText("STORE", "CHECK_PERFER_BUY", checkint(goodData.pchips), checkint(goodData.pchips) * (discount - 1))
            -- checkBuyTip = "是否购买" .. checkint(goodData.pchips) .. " +" .. checkint(goodData.pchips) * (discount - 1) .. "筹码加赠优惠"
        elseif goodData.category == PURCHASE_CATEGORY.CASH then
            --todo
            checkBuyTip = bm.LangUtil.getText("STORE", "CHECK_PERFER_BUY", checkint(goodData.pcoins), checkint(goodData.pcoins) * (discount - 1))
            -- checkBuyTip = "是否购买" .. checkint(goodData.pcoins) .. " +" .. checkint(goodData.pcoins) * (discount - 1) .. "现金币加赠优惠"
        elseif goodData.category == PURCHASE_CATEGORY.PROPS then
            --todo
            dump("Props Not For Sale Here！")
            checkBuyTip = bm.LangUtil.getText("STORE", "CHECK_BUY", goodData.title)
            -- checkBuyTip = "是否购买" .. checkint(goodData.pnum) " +" .. checkint(goodData.pnum) * (discount - 1) .. "道具加赠优惠"
        elseif goodData.category == PURCHASE_CATEGORY.COINS then
            --todo
            dump("No Coins For Sale！")
            checkBuyTip = bm.LangUtil.getText("STORE", "CHECK_BUY", goodData.title)
        elseif goodData.category == PURCHASE_CATEGORY.TICKETS then
            --todo
            dump("Ticket May Not Sale！")
            checkBuyTip = bm.LangUtil.getText("STORE", "CHECK_BUY", goodData.title)
            -- checkBuyTip = "是否购买" .. checkint(goodData.ticketNum) " +" .. checkint(goodData.ticketNum) * (discount - 1) .. "现金币加赠优惠"  -- 去掉门票
        end
    else
        checkBuyTip = bm.LangUtil.getText("STORE", "CHECK_BUY", goodData.title)
    end

    nk.ui.Dialog.new({
            messageText = checkBuyTip,
            secondBtnText = bm.LangUtil.getText("STORE", "SURE_COST_BUY", goodData.price),
            hasCloseButton = true,
            callback = function (ctype)
                if ctype == nk.ui.Dialog.SECOND_BTN_CLICK then
                    self.callPayOrderReqId_ = self.helper_:callPayOrder(params, function(callData)
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

                        --[[
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
                            local transactionId = ORDER
                            local uid = tostring(nk.userData.uid) or ""
                            local channel = tostring(appconfig.ROOT_CGI_SID) or ""
                            local pid = PAYCONFID
                            local currency = "THB"
                            local price = tonumber(PAMOUNT) * 100 -- (X100 是BluePay要求,平台上的泰铢是真实世界中泰铢的1/100,免得小数点 )
                            local smsId = 0
                            local propsName = goodData.getname
                            local isShowDialog = false
                            if self.products_ and self.products_.payInfo and self.products_.payInfo.smsIds then
                                local smsIds = self.products_.payInfo.smsIds
                                if smsIds[(pid .. "")] ~= nil then
                                    smsId = tonumber(smsIds[(pid .. "")])
                                end
                                
                            end
                            self:payBySMS(uid,pid,transactionId,currency,price,smsId,propsName,isShowDialog)
                        else
                            self.purchaseCallback_(false, "Wrong In PayOrder Return！")
                        end
                        
                    end,function(errData)
                        self.callPayOrderReqId_ = nil
                        self.purchaseCallback_(false, "Wrong In PayOrder Process！")
                    end)
                else
                    self.purchaseCallback_(false, "Cancel By User！")
                end
            end
    }):show()
end

function BluePayPurchaseService:payBySMS(uid,pid,transactionId,currency,price,smsId,propsName,isShowDialog)
	self.invokeJavaMethod_("payBySMS", {uid,pid,transactionId,currency,price,smsId,propsName,isShowDialog}, "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;ILjava/lang/String;Z)V")
end

function BluePayPurchaseService:payByCashcard(uid,pid,transactionId,propsName,publicer,cardNo,serialNo)
	self.invokeJavaMethod_("payByCashcard", {uid,pid,transactionId,propsName,publicer,cardNo,serialNo}, "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V")
end

function BluePayPurchaseService:payBySteps(uid,pid,transactionId,currency,price,smsId,propsName,mode,isShowDialog)
    self.invokeJavaMethod_("payBySteps", {uid,pid,transactionId,currency,price,smsId,propsName,mode,isShowDialog}, "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;ILjava/lang/String;IZ)V")
end

function BluePayPurchaseService:payByBank(uid,pid,transactionId,currency,price,propsName,isShowDialog)
    self.invokeJavaMethod_("payByBank", {uid,pid,transactionId,currency,price,propsName,isShowDialog}, "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V")
end

--加载商品信息流程
function BluePayPurchaseService:loadProcess_()
    if not self.products_ then
        self.logger:debug("remote config is loading..")
        self.helper_:cacheConfig(self.config_.configURL, handler(self, self.configLoadHandler_))
        -- self:invokeCallback_(3, false)
    end
    if self.isSetupComplete_ then
        if self.isSupported_ then
            if self.loadChipRequested_ or self.loadPropRequested_ or self.loadTicketRequested_ or self.loadCashRequested_ then
                if self.products_ then
                   
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
        else
            self.logger:debug("bluepay not supported")
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
function BluePayPurchaseService:onSetupComplete_(isSupported)
    self.logger:debug("setup complete.")
    self.isSetuping_ = false
    self.isSetupComplete_ = true
    self.isSupported_ = (isSupported == "true")
    self.logger:debug("isSupported raw:", isSupported)
    self:loadProcess_()
end

--Java call lua
function BluePayPurchaseService:onLoadProductsComplete_(jsonString)
    self.logger:debug("price load complete -> " .. jsonString)
    local success = (jsonString ~= "fail")
    self.isProductRequesting_ = false
    if success then
        local products = json.decode(jsonString)
        --更新价格
        if products then
            -- dump(products, "products:====================")

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

            self.isProductPriceLoaded_ = true
            self:loadProcess_()
            return
        end
    end
    self:invokeCallback_(3, true, bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
end


--[[
    返回码         说明           适用场景
    200    当前流程成功结束    服务端通知，表示所有流程结束
    201    当前步骤流程结束，还有后续步骤SDK给游戏返回的计费请求已经发送，或其他还需要有后续异步流程的场景
    
    400    请求参数错误   SDK返回游戏，比如必填参数为空或参数无效。
    401    未授权          SDK返回游戏，当前游戏没有获得当前接口的使用权。
    402    双卡错误             SDK返回游戏, 用户为双卡手机, 发送短信出现异常
    403    SIM卡异常   SDK 返回游戏, 1. 用户没有SIM卡2. 非支持的SIM卡类型. 3. 运营商不支持的SIM卡
    404    请求数据不存在或请求异常    通用于服务端validPIN, queryTrans等请求，查询数据结果为空
    405    SDK使用错误    SDK返回游戏, 用户使用SDK错误, 或参数填写错误, 或是非UI环境调用函数
    406    Cash card调用失败   SDK返回游戏, SDK调用cash card接口时失败
    407    短信发送错误     SDK返回游戏, 短信无法发出. (不是指发送过程中被拦截.)

    500    JMT内部错误         所有因为JMT服务错误导致的失败。
    501    SDK与JMT服务通信异常      SDK返回游戏，因为网络原因导致的通信异常，可以提示用户稍后再试。
    502    JMT在运营商测服务异常      属于JMT异常，运营商侧服务变更导致。
    503    网络限制    用户访问网络不允许，通常是当前接口只能支持无线网络计费，不支持wifi。
    504    用户当日累计消费超过日限制   属于业务异常，可以提示用户次日再试。
    505    用户当月累计消费超过月限制   属于业务异常，可以提示用户下个月再试。
    506    用户黑名单   当前用户已经被添加入黑名单，需要联系BLUEPAY客服处理
    507    用户消费间隔时间少于60s   当前用户上一次操作到本次操作少于60s，请稍候再试。 
    508    待确认密码已经被使用  适用于短信上行的web充值流程、trueMony充值卡，12call充值卡，当前使用的密码已经被使用过。
    509    待确认密码不存在或非法 适用于短信上行的web充值流程、trueMony充值卡，12call充值卡，当前充值密码状态不正常
    510    待确认密码已经过期   适用于短信上行的web充值流程、trueMoney充值卡，12call充值卡，当前输入的确认密码已经过期
    511    当前用户频繁试错，请稍候再试  适用于短信上行的web充值流程、trueMoney充值卡，12call充值卡，
           当前用户频繁试错 可能存在机器欺诈行为，一个小时内将不能再次进行交易

    600    运营商服务错误 所有因为运营商服务错误导致的失败，提示用户稍后再试
    601    用户余额不足  用户余额不足导致计费失败，提示用户充钱后再试
    602    用户状态异常  因为用户状态异常导致的运营商拒绝服务，提示用户检查运营商侧的服务状态
    603    用户取消操作  用户在付费过程中取消，提示用户
    604    系统预留            不会出现在用户使用流程中
    605    用户重复使用相同transaction id付费    如果当前的短信计费请求使用了与以前相同的transaction id，会得到这个错误码。 一般来说可能会出现在QR code计费流程中
--]]

--Java call lua
function BluePayPurchaseService:onPurchaseComplete_(jsonString)
    self.logger:debug("purchase complete -> ", jsonString)
    -- local success = (string.sub(jsonString, 1, 4) ~= "fail")
    local jsonData = json.decode(jsonString)
    local success = (jsonData.isSuccess == "true") and true or false
    local code = jsonData.code
    local result = jsonData.result
    local title = jsonData.title
    local desc = jsonData.desc
    local transationID = jsonData.transationID
    if success then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("STORE", "PURCHASE_SUCC_AND_DELIVERING"))
        -- local json = json.decode(jsonString)
        -- self:delivery(json.sku, json.originalJson, json.signature, true)
    -- elseif string.sub(jsonString, 6) == "canceled" then
    --     nk.TopTipManager:showTopTip(bm.LangUtil.getText("STORE", "PURCHASE_CANCELED_MSG"))
        if self.purchaseCallback_ then
            self.purchaseCallback_(true, jsonData)
        end
    else
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("STORE", "PURCHASE_FAILED_MSG"))
        if self.purchaseCallback_ then
            self.purchaseCallback_(false, "error")
        end
    end

    if nk.userData.best  then
        nk.userData.best.paylog = 1
    end
    
    self:reportBluePayInfo(jsonData)
end

function BluePayPurchaseService:invokeCallback_(flag, isComplete, data)
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

function BluePayPurchaseService:filterProducts(datas)
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

function BluePayPurchaseService:configLoadHandler_(succ, content)
    if succ then
        self.logger:debug("remote config file loaded.")
        local payInfo = {}
        local jsonObj = json.decode(content)
        self:filterProducts(jsonObj)
        self.products_ = self.helper_:parseConfig(jsonObj, function(category, json, product)
        	product.priceLabel = string.format("%dTHB", product.price)
	        product.priceNum = product.price
	        product.priceDollar = "THB"

	        if self.config_ and self.config_.smsIds then
				payInfo.smsIds = self.config_.smsIds
	        end 
        end)
        -- self.isProductPriceLoaded_ = false
        if self.products_ then
            self.products_.payInfo = payInfo
        end

        self:loadProcess_()
    else
        self.logger:debug("remote config file load failed.")
        self:invokeCallback_(3, true, bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
    end
end


function BluePayPurchaseService:reportBluePayInfo(jsonData)
    if device.platform ~= "android" and device.platform ~= "ios" then
        return
    end

    if not jsonData then
        return
    end

    local success = (jsonData.isSuccess == "true") and true or false
    local code = jsonData.code
    local result = jsonData.result
    local title = jsonData.title
    local desc = jsonData.desc
    local transationID = jsonData.transationID
    if success then
       -- cc.analytics:doCommand {
       --              command = 'eventCustom',
       --              args = {
       --                  eventId    = 'blue_pay_success',
       --                  attributes = 'fail_times,' .. (i-1) .. "|success_times," .. (v.check or i) .. "|succ_," .. (v.check or i) .. "," .. (v.time or 0),
       --                  counter    = 1,
       --              },
       -- }
    else
       cc.analytics:doCommand {
                    command = 'eventCustom',
                    args = {
                        eventId    = 'blue_pay_fail',
                        attributes = 'fail_code,' .. (code or -99) .. "|desc," .. (desc or ""),
                        counter    = 1,
                    },
                }
    end    
end

return BluePayPurchaseService

