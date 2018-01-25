--
-- Author: viking@boomegg.com
-- Date: 2014-11-25 15:37:06
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--
local BetChipBar = class("BetChipBar", function()
    return display.newNode()
end)

local BetChip = import(".BetChip")

function BetChipBar:ctor(preBlind, callback)
    self.callback_ = callback
    local betWidth = BetChip.WIDTH
    local betHeight = BetChip.HEIGHT
    --筹码1
    local betChip1MarginLeft = 24
    local betChipMarginBottom = 5

    local CHIP_Y = betHeight / 2 + betChipMarginBottom

    local betChip1 = BetChip.new({
            normal = "#slot_bet_chip1_unselected.png", 
            glow = "#slot_bet_chip1_selected.png", 
            text = tostring(preBlind * 1), 
            callback = handler(self, self.selectedCallback_)
        })
        :pos(betWidth/2 + betChip1MarginLeft, CHIP_Y)
        :addTo(self)

    --筹码2
    local padding = 22
    local betChip2MarginLeft = betChip1MarginLeft + padding
    local betChip2 = BetChip.new({
            normal = "#slot_bet_chip2_unselected.png", 
            glow = "#slot_bet_chip2_selected.png", 
            text = tostring(preBlind * 2), 
            callback = handler(self, self.selectedCallback_)
        })
        :pos(betWidth/2 * 3 + betChip2MarginLeft, CHIP_Y)
        :addTo(self)

    --筹码3
    local betChip3MarginLeft = betChip2MarginLeft + padding
    local betChip3 = BetChip.new({
            normal = "#slot_bet_chip3_unselected.png", 
            glow = "#slot_bet_chip3_selected.png", 
            text = tostring(preBlind * 3), 
            callback = handler(self, self.selectedCallback_)
        })
        :pos(betWidth/2 * 5 + betChip3MarginLeft, CHIP_Y)
        :addTo(self)

    self.betChips = {betChip1, betChip2, betChip3}

    self:initBetStatus()
    self.betChips[1]:setGlow(true)
    self.bet_ = self.bet_ or self.betChips[1]:getBet()
    print("BetChipBar:ctor", self.bet_)
end

function BetChipBar:initBetStatus()
    for _, betChip in ipairs(self.betChips) do
        betChip:setGlow(false)
    end
end

function BetChipBar:setPreBlind(preBlind,timeArr)
    print("BetChipBar:setPreBlind", preBlind)
    for i = 1, 3 do
        local betChip = self.betChips[i]
        local time = timeArr and timeArr[i] or -1
        if not time or time == -1 then
            time = i
        end
       -- betChip:setBetLabel(preBlind * time)
       betChip:setBetLabel(checkint(time))
    end

    self:initBetStatus()
    self.betChips[1]:setGlow(true)
    self.bet_ = self.betChips[1]:getBet()
    print("BetChipBar:setPreBlind", self.bet_)
    if self.callback_ then
        self.callback_(self.bet_)
    end
end

function BetChipBar:selectedCallback_(target)
    self:initBetStatus()
    target:setGlow(true)
    self.bet_ = target:getBet()
    print("BetChipBar:selectedCallback_", self.bet_)
    if self.callback_ then
        self.callback_(self.bet_)
    end
end

function BetChipBar:getBet()
    return self.bet_ or 0
end

function BetChipBar:dispose()
    -- body
end

return BetChipBar
