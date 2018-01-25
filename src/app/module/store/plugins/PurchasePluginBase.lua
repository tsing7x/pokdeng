--
-- Author: tony
-- Date: 2014-09-25 10:42:12
--
local PurchasePluginBase = class("PurchasePluginBase")
local logger = bm.Logger.new("PurchasePluginBase")

function PurchasePluginBase:ctor()
    self.schedulerPool_ = bm.SchedulerPool.new()
end

function PurchasePluginBase:parseConfig(jsonString)
    logger:debug(jsonString)
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



return PurchasePluginBase