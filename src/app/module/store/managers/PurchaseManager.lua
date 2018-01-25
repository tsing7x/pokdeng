--
-- Author: tony
-- Date: 2014-08-12 15:57:24
--
local PurchaseType = import(".PurchaseType")
local InAppBillingPlugin = import("app.module.store.plugins.InAppBillingPlugin")
local InAppPurchasePlugin = import("app.module.store.plugins.InAppPurchasePlugin")

local PurchaseManager = class("PurchaseManager")

local DEFAULT_CACHE_DIR = device.writablePath .. "cache" .. device.directorySeparator .. "remotedata" .. device.directorySeparator
bm.mkdir(DEFAULT_CACHE_DIR)

function PurchaseManager:ctor(purchaseType)
    self.purchaseType_ = purchaseType
    if purchaseType == PurchaseType.IN_APP_BILLING then
        self.plugin = InAppBillingPlugin.new()
    elseif purchaseType == PurchaseType.IN_APP_PURCHASE then
        self.plugin = InAppPurchasePlugin:sharedInAppPurchasePlugin()
    end
end

function PurchaseManager:setup(onSetupCompleteCallback, purchaseResultCallback)
    if not nk.userData then return end

    --加载支付配置
    local url = nk.userData[self.plugin.CONFIG_KEY]
    if url then
        local filename = crypto.md5(url)
        local filepath = DEFAULT_CACHE_DIR .. filename
        if io.exists(filepath) then
            local content = io.readfile(filepath)
            local products = self.plugin:parseConfig(content)
            self.configLoaded_ = true
            self.config_ = products
            if self.onSetupCompleteCallback_ then
                self.onSetupCompleteCallback_(unpack(self.onSetupCompleteCallbackParam_))
                self.onSetupCompleteCallback_ = nil
                self.onSetupCompleteCallbackParam_ = nil
            end
        else
            bm.HttpService.GET_URL(url, {}, function(data)
                io.writefile(filepath, data, "w+")
                local products = self.plugin:parseConfig(data)
                self.configLoaded_ = true
                self.config_ = products
                if self.onSetupCompleteCallback_ then
                    self.onSetupCompleteCallback_(unpack(self.onSetupCompleteCallbackParam_))
                    self.onSetupCompleteCallback_ = nil
                    self.onSetupCompleteCallbackParam_ = nil
                end
            end, function()
                print("error loading url " .. url)
            end)
        end
    else
        --无需配置文件
        self.configLoaded_ = true
    end

    --调用支付SDK的初始化方法
    self.plugin:startup(function(...) 
        if self.configLoaded_ then
            onSetupCompleteCallback(...)
        else
            self.onSetupCompleteCallback_ = onSetupCompleteCallback
            self.onSetupCompleteCallbackParam_ = {...}
        end
    end, purchaseResultCallback)
end

function PurchaseManager:loadProducts(loadProductsCallback)
    print("call loadProducts ", json.encode(self.config_.skus))
    local callback = function(success, config)
        if success then
            --更新折扣
            local itemDiscount = nk.userData.itemDiscount or {}
            local chipDiscount = itemDiscount.chipDiscount or 0
            local coinDiscount = itemDiscount.coinDiscount or 0
            if config.chips then
                for i, chip in ipairs(config.chips) do
                    local byIdDiscount = itemDiscount["item" .. chip.id]
                    if byIdDiscount then
                        chip.discount = byIdDiscount
                    else
                        chip.discount = chipDiscount
                    end
                    --计算筹码比率
                    if not chip.priceLabel then
                        chip.priceLabel = "$" .. chip.price / 100
                    end
                    local partDollar, priceNum
                    if not chip.priceNum then
                        partDollar, priceNum = self:parsePrice(chip.priceLabel)
                        chip.priceNum = priceNum
                        chip.priceDollar = partDollar
                    else
                        priceNum = chip.priceNum
                        chip.priceDollar = self:parsePrice(chip.priceLabel)
                    end
                    if chip.discount ~= 0 then
                        if chip.discount > 0 then
                            chip.rate = chip.chipNum * (100 + chip.discount) / (100 * priceNum)
                            chip.chipNumOff = chip.chipNum * (100 + chip.discount) / 100
                        else
                            chip.rate = chip.chipNum * 100 / ((100 + chip.discount) * priceNum)
                            chip.chipNumOff = chip.chipNum * 100 / (100 + chip.discount)
                        end
                    else
                        chip.rate = chip.chipNum / priceNum
                    end
                    chip.rate = tonumber(string.format("%.2f", chip.rate))
                end
            end
            if config.coins then
                for i, coin in ipairs(config.coins) do
                    local byIdDiscount = itemDiscount["item" .. coin.id]
                    if byIdDiscount then
                        coin.discount = byIdDiscount
                    else
                        coin.discount = coinDiscount
                    end
                    --计算金币比率
                    if not coin.priceLabel then
                        coin.priceLabel = "$" .. coin.price / 100
                    end
                    local partDollar, priceNum
                    if not coin.priceNum then
                        partDollar, priceNum = self:parsePrice(coin.priceLabel)
                        coin.priceNum = priceNum
                        coin.priceDollar = partDollar
                    else
                        priceNum = coin.priceNum
                        coin.priceDollar = self:parsePrice(coin.priceLabel)
                    end
                    if coin.discount ~= 0 then
                        if coin.discount > 0 then
                            coin.rate = coin.coinNum * (100 + coin.discount) / (100 * priceNum)
                            coin.coinNumOff =  coin.coinNum * (100 + coin.discount) / 100
                        else
                            coin.rate = coin.coinNum * 100 / ((100 + coin.discount) * priceNum)
                            coin.coinNumOff =  coin.coinNum * 100 / (100 + coin.discount)
                        end
                    else
                        coin.rate = coin.coinNum / priceNum
                    end
                    coin.rate = tonumber(string.format("%.2f", coin.rate))
                end
            end
            if config.props then
                for i, prop in ipairs(config.props) do
                    --计算金币比率
                    if not prop.priceLabel then
                        prop.priceLabel = "$" .. prop.price / 100
                    end
                end
            end
        end
        if loadProductsCallback then
            loadProductsCallback(success, config)
        end
    end
    self.plugin:loadProducts(self.config_, callback)
end

function PurchaseManager:makePurchase(pid)
    local canMakePurchases = self.plugin:canMakePurchases()
    if canMakePurchases then
        --orderId, sku, uid, channel
        --bm.HttpService.POST({mod="tj", act="pay", id=pid})
        self.plugin:makePurchase(pid, nk.userData.uid, nk.userData.channel)
    else
        nk.ToptipManager:showToptip(bm.LangUtil.getText("STORE", "NOT_SUPPORT_MSG"))
    end
end

function PurchaseManager:dispose()
    if self.plugin then
        if self.purchaseType_ == PurchaseType.IN_APP_BILLING then
            self.plugin:autoDispose(60)
        else
            self.plugin:dispose()
        end
    end
end

function PurchaseManager:parsePrice(p)
    local s, e = string.find(p, "%d")
    local partDollar = string.sub(p, 1, s - 1)
    local partNumber = string.sub(p, s)
    local partNumberLen = string.len(partNumber)

    --print("partDollar", partDollar)
    --print("partNumber", partNumber)
    --print("partNumberLen", partNumberLen)
    local priceNum = 0
    local split, dot = "", ""
    local s1, e1 = string.find(partNumber, "%p")
    --print(s1, e1)
    if s1 then
        --找到第一个标点
        local firstP = string.sub(partNumber, s1, e1)
        --print(firstP)
        local s2, e2 = string.find(partNumber, "%p", s1 + 1)
        --print(s2, e2)
        if s2 then
            --至少2个标点
            local secondP = string.sub(partNumber, s2, e2)
            --print(secondP)
            if firstP == secondP then
                --2个一样的标点肯定分隔符
                split = firstP
                local str = string.gsub(partNumber, "%" .. firstP, "")
                local sdb, sde = string.find(str, "%p")
                if sdb then
                    --去掉分隔符之后的肯定是小数点
                    dot = string.sub(str, sdb, sde)
                    str = string.gsub(str, "%" .. dot, ".")
                end
                priceNum = tonumber(str)
            else
                --2个标点不一样，前面的是分隔符，后面的是小数点
                split = firstP
                dot = secondP
                local str = string.gsub(partNumber, "%" .. split, "")
                str = string.gsub(str, "%" .. dot, ".")
                priceNum = tonumber(str)
            end
        else
            --只有一个标点
            if string.sub(partNumber, 1, s1 - 1) == "0" then
                --标点前面为0，这个标点肯定是小数点
                dot = firstP
                --把这个标点替换为 "."
                local str = string.gsub(partNumber, "%" .. firstP, ".")
                priceNum = tonumber(str)
            elseif partNumberLen == e1 + 3 then
                --标点之后有3位，假定这个标点为分隔符
                split = firstP
                local str = string.gsub(partNumber, "%" .. firstP, "")
                priceNum = tonumber(str)
            elseif partNumberLen <= e1 + 2 then
                --标点之后有2或1位，假定这个标点为小数点
                dot = firstP
                local str = string.gsub(partNumber, "%" .. firstP, ".")
                priceNum = tonumber(str)
            elseif firstP == "," then
                --默认","为分隔符
                split = firstP
                local str = string.gsub(partNumber, "%" .. firstP, "")
                priceNum = tonumber(str)
            elseif firstP == "." then
                --默认"."为小数点
                dot = firstP
                local str = string.gsub(partNumber, "%" .. firstP, ".")
                priceNum = tonumber(str)
            else
                split = firstP
                local str = string.gsub(partNumber, "%" .. firstP, "")
                priceNum = tonumber(str)
            end
        end
    else
        --找不到标点
        priceNum = tonumber(partNumber)
    end

    return partDollar, priceNum, split, dot
end

return PurchaseManager