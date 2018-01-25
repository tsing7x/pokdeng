--
-- Author: tony
-- Date: 2014-11-19 21:54:34
--

local PURCHASE_CATEGORY = import(".PURCHASE_CATEGORY")
local PurchaseHelper = class("PurchaseHelper")

local DEFAULT_CACHE_DIR = device.writablePath .. "cache" .. device.directorySeparator .. "remotedata" .. device.directorySeparator
bm.mkdir(DEFAULT_CACHE_DIR)

function PurchaseHelper:ctor(name)
    self.logger = bm.Logger.new(name .. ".PurchaseHelper")
end

-- process config from cache or url
function PurchaseHelper:cacheConfig(url, callback)
    self.cacheConfigCallback_ = callback

    if self.isCachingConfig_ then return end

    self.isCachingConfig_ = true

    local filename = crypto.md5(url)
    local filepath = DEFAULT_CACHE_DIR .. filename

    dump(url,"PurchaseHelper:cacheConfig -- url")

    if io.exists(filepath) then
        dump(filepath,"PurchaseHelper:cacheConfig -- exists:filepath")
        -- try read from file
        local content = io.readfile(filepath)
        dump(content,"PurchaseHelper:cacheConfig -- exists:content")
        self.logger:debug(content)
        if self.cacheConfigCallback_ then
            self.cacheConfigCallback_(true, content)
            self.cacheConfigCallback_ = nil
        end
        self.isCachingConfig_ = false
    else
        dump(filepath,"PurchaseHelper:cacheConfig -- not exists:filepath")
        -- download from url
        local retryLimit = 3
        local loadContent
        local function retryLoad()
            retryLimit = retryLimit - 1
            if retryLimit > 0 then
                loadContent()
            else
                if self.cacheConfigCallback_ then
                    self.cacheConfigCallback_(false)
                    self.cacheConfigCallback_ = nil
                end
                self.isCachingConfig_ = false
            end
        end
        loadContent = function ()
            bm.HttpService.GET_URL(url, {}, function(data)
                dump(data,"PurchaseHelper:loadContent -- content")
                if data then
                    io.writefile(filepath, data, "w+")
                    if self.cacheConfigCallback_ then
                        self.cacheConfigCallback_(true, data)
                        self.cacheConfigCallback_ = nil
                    end
                    self.isCachingConfig_ = false
                else
                    retryLoad()
                end
            end, retryLoad)
        end
        loadContent()
    end
end

function PurchaseHelper:parsePrice(p)
    local s, e = string.find(p, "%d")
    local partDollar
    local partNumber
    local partNumberLen
    if s <= 1 then
        local lastNumIdx = 1
        while true do
            local st, ed = string.find(p, "%d", lastNumIdx + 1)
            if ed then
                lastNumIdx = ed
            else
                partDollar = string.sub(p, lastNumIdx + 1)
                partNumber = string.sub(p, 1, lastNumIdx)
                partNumberLen = string.len(partNumber)
                break
            end
        end
    else
        partDollar = string.sub(p, 1, s - 1)
        partNumber = string.sub(p, s)
        partNumberLen = string.len(partNumber)
    end

    local priceNum = 0
    local split, dot = "", ""
    local s1, e1 = string.find(partNumber, "%p")
    if s1 then
        --找到第一个标点
        local firstP = string.sub(partNumber, s1, e1)
        local s2, e2 = string.find(partNumber, "%p", s1 + 1)
        if s2 then
            --至少2个标点
            local secondP = string.sub(partNumber, s2, e2)
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


function PurchaseHelper:callPayOrder(params,resultCallback,errorCallback)
    assert(params and params.id, "callPayDelivery must has 'id'") --商品ID
    assert(params and params.pmode, "callPayDelivery must has 'pmode'") -- 支付渠道标识
    local mid = nk.userData["aUser.mid"]
    local sitemid = nk.userData["aUser.sitemid"]
    params.mid = mid
    params.sitemid = sitemid
    nk.http.callPayOrder(params,function(callData)
        if resultCallback then
            resultCallback(callData)
        end
    end,function(errData)
        if errorCallback then
            errorCallback(errData)
        end
    end)
end

function PurchaseHelper:callPayDelivery(params,resultCallback,errorCallback)
    assert(params and params.pmode, "callPayDelivery must has 'pmode'")
    nk.http.callClientPayment(params,function(callData)
        if resultCallback then
            resultCallback(callData)
        end
    end,function(errData)
        if errorCallback then
            errorCallback(errData)
        end
    end)
end

function PurchaseHelper:getChipIcon(i,pchips)
    local iconArr = {100,101,102,103,104,105}
    if i then
        return iconArr[i]
    end
    return iconArr[(math.random(1,5))]
end

function PurchaseHelper:getTicketIcon(i)
    return "tong_big_ticket.png"
end

function PurchaseHelper:getCashIcon(idx, chips)
    -- body
    return "store_cash_icon.png"
end

function PurchaseHelper:parseConfig(jsonObj, itemCallback)
    -- self.logger:debug(json.encode(jsonObj))
    -- local jsonObj = json.decode(jsonString)
    local result = {}
    result.skus = {}

    -- dump(jsonObj, "configJson:=================")

    if jsonObj.chips then
        table.sort(jsonObj.chips,function(t1,t2)
            return tonumber(t1.pamount) < tonumber(t2.pamount)
        end)
        local chips = {}
        result.chips = chips
        for i = 1, #jsonObj.chips do

            local chip = jsonObj.chips[i]
            local prd = {}
            prd.pid = chip.pid or chip.id or ""
            prd.id = chip.id
            prd.sid = chip.sid
            prd.appid = chip.appid
            prd.pmode = chip.pmode
            prd.pamount = chip.pamount
            prd.discount = chip.discount
            prd.pcoins = chip.pcoins
            prd.pchips = chip.pchips
            prd.pcard = chip.pcard
            prd.ptype = chip.ptype
            prd.pnum = chip.pnum
            prd.getname = chip.getname
            prd.desc = chip.desc
            prd.stag = chip.stag
            prd.currency= chip.currency
            prd.prid= chip.prid
            prd.expire= chip.expire
            prd.state= chip.state
            prd.device= chip.device
            prd.sortid= chip.sortid
            prd.etime= chip.etime
            prd.status= chip.status
            prd.use_status= chip.use_status
            prd.item_id = chip.item_id

            --三公原有字段兼容处理
            prd.price = chip.pamount or 0
            prd.chipNum = chip.pchips or 0
            prd.ticketNum = chip.pnum or 0
            prd.cashCions = chip.pcoins or 0
            prd.title = chip.getname or ""
            prd.tag = chip["tag"] == 1 and "hot" or (chip["tag"] == 2 and "new" or "")
            prd.category = PURCHASE_CATEGORY.CHIPS
            -- prd.img = chip.u and chip.u ~= "" and chip.u or prd.id
            local imgIdx = i;
            if imgIdx > 5 then
                imgIdx = 5
            end
            prd.img = self:getChipIcon(imgIdx,chip.pchips)

            -- prd.img = chip.u and chip.u ~= "" and chip.u or prd.id
            -- prd.title = chip.n or ""
            -- prd.chipNum = chip.ch or ""
            -- prd.tag = chip["if"] == 1 and "hot" or (chip["if"] == 2 and "new" or "")
            if itemCallback then
                itemCallback("chips", chip, prd)
            end
            table.insert(chips, prd)
            table.insert(result.skus, prd.pid)


            --[[
            local chip = jsonObj.chips[i]
            local prd = {}
            prd.pid = chip.pid
            prd.id = chip.id
            prd.price = chip.p
            prd.img = chip.u and chip.u ~= "" and chip.u or prd.id
            prd.title = chip.n
            prd.chipNum = chip.ch
            prd.tag = chip["if"] == 1 and "hot" or (chip["if"] == 2 and "new" or "")
            if itemCallback then
                itemCallback("chips", chip, prd)
            end
            table.insert(chips, prd)
            table.insert(result.skus, prd.pid)
            --]]
        end
    end

    if jsonObj.props then
        local props = {}
        result.props = props
        for i = 1, #jsonObj.props do
            local prop = jsonObj.props[i]
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
            prd.category = PURCHASE_CATEGORY.PROPS
            if itemCallback then
                itemCallback("props", prop, prd)
            end
            table.insert(props, prd)
            table.insert(result.skus, prd.pid)
        end
    end

    if jsonObj.coins then
        local coins = {}
        result.coins = coins
        for i = 1, #jsonObj.coins do
            local coin = jsonObj.coins[i]
            local prd = {}
            prd.pid = coin.pid
            prd.id = coin.id
            prd.price = coin.p
            prd.img = coin.u and coin.u ~= "" and coin.u or prd.id
            prd.title = coin.n
            prd.coinNum = coin.co
            prd.tag = coin["if"] == 1 and "hot" or (coin["if"] == 2 and "new" or "")
            prd.category = PURCHASE_CATEGORY.COINS
            if itemCallback then
                itemCallback("coins", coin, prd)
            end
            table.insert(coins, prd)
            table.insert(result.skus, prd.pid)
        end
    end

    if jsonObj.tickets then
        table.sort(jsonObj.tickets,function(t1,t2)
            return tonumber(t1.pamount) < tonumber(t2.pamount)
        end)
        local tickets = {}
        result.tickets = tickets
        for i = 1, #jsonObj.tickets do

            local ticket = jsonObj.tickets[i]
            local prd = {}
            prd.pid = ticket.pid or ticket.id or ""
            prd.id = ticket.id
            prd.sid = ticket.sid
            prd.appid = ticket.appid
            prd.pmode = ticket.pmode
            prd.pamount = ticket.pamount
            prd.discount = ticket.discount
            prd.pcoins = ticket.pcoins
            prd.pchips = ticket.pchips
            prd.pcard = ticket.pcard
            prd.ptype = ticket.ptype
            prd.pnum = ticket.pnum
            prd.getname = ticket.getname
            prd.desc = ticket.desc
            prd.stag = ticket.stag
            prd.currency= ticket.currency
            prd.prid= ticket.prid
            prd.expire= ticket.expire
            prd.state= ticket.state
            prd.device= ticket.device
            prd.sortid= ticket.sortid
            prd.etime= ticket.etime
            prd.status= ticket.status
            prd.use_status= ticket.use_status
            prd.item_id = ticket.item_id

            --三公原有字段兼容处理
            prd.price = ticket.pamount or 0
            prd.chipNum = ticket.pchips or 0
            prd.ticketNum = ticket.pnum or 0
            prd.cashCions = ticket.pcoins or 0
            prd.title = ticket.getname or ""
            prd.tag = ticket["tag"] == 1 and "hot" or (ticket["tag"] == 2 and "new" or "")
            -- prd.img = chip.u and chip.u ~= "" and chip.u or prd.id
            prd.category = PURCHASE_CATEGORY.TICKETS

            local imgIdx = i;
            if imgIdx > 5 then
                imgIdx = 5
            end
            prd.img = self:getTicketIcon(imgIdx,ticket.pchips)

            -- prd.img = chip.u and chip.u ~= "" and chip.u or prd.id
            -- prd.title = chip.n or ""
            -- prd.chipNum = chip.ch or ""
            -- prd.tag = chip["if"] == 1 and "hot" or (chip["if"] == 2 and "new" or "")
            if itemCallback then
                itemCallback("tickets", ticket, prd)
            end
            table.insert(tickets, prd)
            table.insert(result.skus, prd.pid)


            --[[
            local chip = jsonObj.chips[i]
            local prd = {}
            prd.pid = chip.pid
            prd.id = chip.id
            prd.price = chip.p
            prd.img = chip.u and chip.u ~= "" and chip.u or prd.id
            prd.title = chip.n
            prd.chipNum = chip.ch
            prd.tag = chip["if"] == 1 and "hot" or (chip["if"] == 2 and "new" or "")
            if itemCallback then
                itemCallback("chips", chip, prd)
            end
            table.insert(chips, prd)
            table.insert(result.skus, prd.pid)
            --]]
        end
    end

    if jsonObj.cash then
        table.sort(jsonObj.cash,function(t1,t2)
            return tonumber(t1.pamount) < tonumber(t2.pamount)
        end)
        local cashes = {}
        result.cash = cashes
        for i = 1, #jsonObj.cash do

            local cash = jsonObj.cash[i]
            local prd = {}
            prd.pid = cash.pid or cash.id or ""
            prd.id = cash.id
            prd.sid = cash.sid
            prd.appid = cash.appid
            prd.pmode = cash.pmode
            prd.pamount = cash.pamount
            prd.discount = cash.discount
            prd.pcoins = cash.pcoins
            prd.pchips = cash.pchips
            prd.pcard = cash.pcard
            prd.ptype = cash.ptype
            prd.pnum = cash.pnum
            prd.getname = cash.getname
            prd.desc = cash.desc
            prd.stag = cash.stag
            prd.currency= cash.currency
            prd.prid= cash.prid
            prd.expire= cash.expire
            prd.state= cash.state
            prd.device= cash.device
            prd.sortid= cash.sortid
            prd.etime= cash.etime
            prd.status= cash.status
            prd.use_status= cash.use_status
            prd.item_id = cash.item_id

            --三公原有字段兼容处理
            prd.price = cash.pamount or 0
            prd.chipNum = cash.pchips or 0
            prd.ticketNum = cash.pnum or 0
            prd.cashCions = cash.pcoins or 0
            prd.title = cash.getname or ""
            prd.tag = cash["tag"] == 1 and "hot" or (cash["tag"] == 2 and "new" or "")
            prd.category = PURCHASE_CATEGORY.CASH
            -- prd.img = chip.u and chip.u ~= "" and chip.u or prd.id
            local imgIdx = i
            if imgIdx > 5 then
                imgIdx = 5
            end
            prd.img = self:getCashIcon(imgIdx, cash.pchips)

            -- prd.img = chip.u and chip.u ~= "" and chip.u or prd.id
            -- prd.title = chip.n or ""
            -- prd.chipNum = chip.ch or ""
            -- prd.tag = chip["if"] == 1 and "hot" or (chip["if"] == 2 and "new" or "")
            if itemCallback then
                itemCallback("cash", cash, prd)
            end
            table.insert(cashes, prd)
            table.insert(result.skus, prd.pid)


            --[[
            local chip = jsonObj.chips[i]
            local prd = {}
            prd.pid = chip.pid
            prd.id = chip.id
            prd.price = chip.p
            prd.img = chip.u and chip.u ~= "" and chip.u or prd.id
            prd.title = chip.n
            prd.chipNum = chip.ch
            prd.tag = chip["if"] == 1 and "hot" or (chip["if"] == 2 and "new" or "")
            if itemCallback then
                itemCallback("chips", chip, prd)
            end
            table.insert(chips, prd)
            table.insert(result.skus, prd.pid)
            --]]
        end
    end

    return result
end

function PurchaseHelper:updateDiscount(products, paytypeConfig)
    if not products or not paytypeConfig then return end
    local itemDiscount = paytypeConfig.discount or {}
    local chipDiscount = paytypeConfig.chipDiscount or 1
    local coinDiscount = paytypeConfig.coinDiscount or 1
    local ticketDiscount = paytypeConfig.ticketDiscount or 1
    local cashDiscount = paytypeConfig.cashDiscount or 1

    if products.chips then
        for i, chip in ipairs(products.chips) do
            local byIdDiscount = itemDiscount[chip.pid] and itemDiscount[chip.pid].dis
            local byIdDiscountExpire = itemDiscount[chip.pid] and itemDiscount[chip.pid].expire
            chip.discount = byIdDiscount or chipDiscount

            chip.discountExpire = byIdDiscountExpire
            if not chip.priceLabel then
                chip.priceLabel = "$" .. chip.price
            end
            local partDollar, priceNum
            if chip.priceNum and chip.priceDollar then
                partDollar = chip.priceDollar
                priceNum = chip.priceNum
            elseif not chip.priceNum then
                partDollar, priceNum = self:parsePrice(chip.priceLabel)
                chip.priceNum = priceNum
                chip.priceDollar = partDollar
            else
                priceNum = chip.priceNum
                chip.priceDollar = self:parsePrice(chip.priceLabel)
            end
            if chip.discount ~= 1 then
                chip.rate = chip.chipNum * chip.discount / priceNum
                chip.chipNumOff = chip.chipNum * chip.discount
            else
                chip.rate = chip.chipNum / priceNum
            end
            chip.rate = tonumber(string.format("%.2f", chip.rate))
        end
    end
    if products.coins then
        for i, coin in ipairs(products.coins) do
            local byIdDiscount = itemDiscount[coin.pid] and itemDiscount[coin.pid].dis
            local byIdDiscountExpire = itemDiscount[coin.pid] and itemDiscount[coin.pid].expire
            coin.discount = byIdDiscount or coinDiscount
            coin.discountExpire = byIdDiscountExpire
            if not coin.priceLabel then
                coin.priceLabel = "$" .. coin.price / 100
            end
            local partDollar, priceNum
            if coin.priceNum and coin.priceDollar then
                partDollar = coin.priceDollar
                priceNum = coin.priceNum
            elseif not coin.priceNum then
                partDollar, priceNum = self:parsePrice(coin.priceLabel)
                coin.priceNum = priceNum
                coin.priceDollar = partDollar
            else
                priceNum = coin.priceNum
                coin.priceDollar = self:parsePrice(coin.priceLabel)
            end
            if coin.discount ~= 1 then
                coin.rate = coin.coinNum * coin.discount / priceNum
                coin.coinNumOff = coin.coinNum * coin.discount
            else
                coin.rate = coin.coinNum / priceNum
            end
            coin.rate = tonumber(string.format("%.2f", coin.rate))
        end
    end
    if products.props then
        for i, prop in ipairs(products.props) do
            if not prop.priceLabel then
                prop.priceLabel = "$" .. prop.price / 100
            end
        end
    end

    if products.tickets then
        for i, ticket in ipairs(products.tickets) do
            local byIdDiscount = itemDiscount[ticket.pid] and itemDiscount[ticket.pid].dis
            local byIdDiscountExpire = itemDiscount[ticket.pid] and itemDiscount[ticket.pid].expire
            ticket.discount = byIdDiscount or ticketDiscount
            ticket.discountExpire = byIdDiscountExpire
            if not ticket.priceLabel then
                ticket.priceLabel = "$" .. ticket.price 
            end
            local partDollar, priceNum
            if ticket.priceNum and ticket.priceDollar then
                partDollar = ticket.priceDollar
                priceNum = ticket.priceNum
            elseif not ticket.priceNum then
                partDollar, priceNum = self:parsePrice(ticket.priceLabel)
                ticket.priceNum = priceNum
                ticket.priceDollar = partDollar
            else
                priceNum = ticket.priceNum
                ticket.priceDollar = self:parsePrice(ticket.priceLabel)
            end
            if ticket.discount ~= 1 then
                ticket.rate = ticket.ticketNum * ticket.discount / priceNum
                ticket.ticketNumOff = ticket.ticketNum * ticket.discount
            else
                ticket.rate = ticket.ticketNum / priceNum
            end
            ticket.rate = tonumber(string.format("%.2f", ticket.rate))
        end

    end

    if products.cash then
        --todo
        for i, cash in ipairs(products.cash) do
            local byIdDiscount = itemDiscount[cash.pid] and itemDiscount[cash.pid].dis
            local byIdDiscountExpire = itemDiscount[cash.pid] and itemDiscount[cash.pid].expire
            -- cash.discount = byIdDiscount or ticketDiscount
            cash.discount = byIdDiscount or cashDiscount
            -- cash.discount = 5
            cash.discountExpire = byIdDiscountExpire
            if not cash.priceLabel then
                cash.priceLabel = "$" .. cash.price 
            end
            local partDollar, priceNum
            if cash.priceNum and cash.priceDollar then
                partDollar = cash.priceDollar
                priceNum = cash.priceNum
            elseif not cash.priceNum then
                partDollar, priceNum = self:parsePrice(cash.priceLabel)
                cash.priceNum = priceNum
                cash.priceDollar = partDollar
            else
                priceNum = cash.priceNum
                cash.priceDollar = self:parsePrice(cash.priceLabel)
            end
            if cash.discount ~= 1 then
                cash.rate = cash.cashCions * cash.discount / priceNum
                cash.cashNumOff = cash.cashCions * cash.discount
            else
                cash.rate = cash.cashCions / priceNum
            end
            cash.rate = tonumber(string.format("%.2f", cash.rate))
        end
    end

end

return PurchaseHelper
