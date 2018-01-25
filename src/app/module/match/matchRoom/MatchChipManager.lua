--
-- Author: tony
-- Date: 2014-07-08 15:00:15
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

local MatchChipManager = class("MatchChipManager")

local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
local ChipData = import(".model.MatchChipData")
local BetChipView = import(".views.MatchBetChipView")
local PotChipView = import(".views.MatchPotChipView")
local RoomViewPosition = import(".views.MatchRoomViewPosition")
local BP = RoomViewPosition.BetPosition
local PP = RoomViewPosition.PotPosition
local logger = bm.Logger.new("MatchChipManager")

function MatchChipManager:ctor()
end

function MatchChipManager:createNodes()
    -- 文字背景层，不移动，根据positionId确定位置
    self.textBgBatchNode_ = display.newBatchNode("room_texture.png")
        :addTo(self.scene.nodes.chipNode)
    self.betChipTextBgs_ = {}
    for i = 1, 9 do
        self.betChipTextBgs_[i] = display.newSprite("#room_chip_text_bg.png")
            :addTo(self.textBgBatchNode_)
            :pos(BP[i].x, BP[i].y)
            :hide()
    end
    self.potChipTextBgs_ = {}
    for i = 1, 9 do
        self.potChipTextBgs_[i] = display.newSprite("#room_chip_text_bg.png")
            :addTo(self.textBgBatchNode_)
            :pos(PP[i].x, PP[i].y)
            :hide()
    end

    -- 文字标签层，不移动，根据positionId或者potId确定位置
    self.betChipTextLabels_ = {}
    for i = 1, 9 do
        self.betChipTextLabels_[i] = display.newTTFLabel({text = "999.9M", size = 20, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(255, 204, 0)})
            :addTo(self.scene.nodes.chipNode)
            :pos(BP[i].x, BP[i].y)
            :hide()
    end
    self.potChipTextLabels_ = {}
    for i = 1, 9 do
        self.potChipTextLabels_[i] = display.newTTFLabel({text = "999.9M", size = 20, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(255, 204, 0)})
            :addTo(self.scene.nodes.chipNode)
            :pos(PP[i].x, PP[i].y)
            :hide()
    end

    -- 筹码对象池
    local function funcFactory(filename, oddOrEven, key)
        return function()
            return ChipData.new(filename, oddOrEven, key)
        end
    end
    self.chipPool_ = {}
    self.chipPool_.odd = {}
    self.chipPool_.odd[1] = bm.ObjectPool.new(funcFactory("#room_chip_odd_1.png", "odd", 1), true, 10, 15, true)
    self.chipPool_.odd[2] = bm.ObjectPool.new(funcFactory("#room_chip_odd_2.png", "odd", 2), true, 10, 15, true)
    self.chipPool_.odd[5] = bm.ObjectPool.new(funcFactory("#room_chip_odd_5.png", "odd", 5), true, 10, 15, true)
    self.chipPool_.even = {}
    self.chipPool_.even[1] = bm.ObjectPool.new(funcFactory("#room_chip_even_1.png", "even", 1), true, 10, 15, true)
    self.chipPool_.even[2] = bm.ObjectPool.new(funcFactory("#room_chip_even_2.png", "even", 2), true, 10, 15, true)
    self.chipPool_.even[5] = bm.ObjectPool.new(funcFactory("#room_chip_even_5.png", "even", 5), true, 10, 15, true)

    -- 筹码容器
    self.chipBatchNode_ = display.newBatchNode("room_texture.png")
        :addTo(self.scene.nodes.chipNode)
    -- 下注筹码试图，key由seatId确定
    self.betChipViews_ = {}
    for i = 0, 8 do
        self.betChipViews_[i] = BetChipView.new(self.chipBatchNode_, self, i)
    end
    -- 下注筹码试图，key由potId确定
    self.potChipViews_ = {}
    for i = 1, 9 do
        self.potChipViews_[i] = PotChipView.new(self.chipBatchNode_, self, i)
    end
end

-- 登录成功，设置登录筹码堆
function MatchChipManager:setLoginChipStacks()
    local gameInfo = self.model.gameInfo
    local playerList = self.model.playerList
    -- 奖池筹码堆
    for _, v in pairs(gameInfo.pots) do
        self.potChipViews_[v.potIdx]:resetChipStack(v.potChips)
        self:modifyPotText(v.potChips, v.potIdx)
    end


    -- 下注筹码堆
    for i = 0, 8 do
        if playerList[i] then
            local betTotalChips = playerList[i].curBet
            local seatId        = playerList[i].seatId
            local positionId    = self.seatManager:getSeatPositionId(seatId)
            self.betChipViews_[seatId]:resetChipStack(betTotalChips)
            self:modifyBetText(betTotalChips, positionId)
        end
    end




    do return end
    local gameInfo = self.model.gameInfo
    local playerList = self.model.playerList

    -- 奖池筹码堆
    --self.potChipViews_[1]:resetChipStack(self.model.gameInfo.totalAnte)
    --self:modifyPotText(self.model.gameInfo.totalAnte, 1)

    -- 下注筹码堆
    for i = 0, 8 do
        if playerList[i] then
            local betTotalChips = playerList[i].nCurAnte
            local seatId        = playerList[i].seatId
            local positionId    = self.seatManager:getSeatPositionId(seatId)
            self.betChipViews_[seatId]:resetChipStack(betTotalChips)
            self:modifyBetText(betTotalChips, positionId)
        end
    end
end

-- 坐下动画，移动筹码堆
function MatchChipManager:moveChipStack()
    for i = 0, 8 do
        local positionId = self.seatManager:getSeatPositionId(i)
        self.betChipViews_[i]:rotate(positionId)
        self:modifyBetText(self.betChipViews_[i]:getBetTotalChips(), positionId)
    end
end

-- 筹码下注动画
function MatchChipManager:betChip(player)

    local betNeedChips  = player.betNeedChips
    local betTotalChips = player.betChips
    local seatId        = player.seatId
    local positionId    = self.seatManager:getSeatPositionId(seatId)

    -- dump(betNeedChips,"betChip:betNeedChips")
    -- dump(betTotalChips,"betChip:betTotalChips")
    -- dump(seatId,"betChip:seatId")
    -- dump(positionId,"betChip:positionId")

    -- 播放下注动画
    self.betChipViews_[seatId]:moveFromSeat(betNeedChips, betTotalChips)
    if betTotalChips > 0 then
        self:modifyBetText(betTotalChips, positionId)
    end

    -- local nCurAnte  = player.nCurAnte
    -- local seatId        = player.seatId
    -- local positionId    = self.seatManager:getSeatPositionId(seatId)
    -- -- 播放下注动画
    -- self.betChipViews_[seatId]:moveFromSeat(nCurAnte, nCurAnte)
    -- if nCurAnte > 0 then
    --     self:modifyBetText(nCurAnte, positionId)
    -- end
end

function MatchChipManager:clearChip(seatId)    
    local positionId    = self.seatManager:getSeatPositionId(seatId)
    self.betChipViews_[seatId]:reset(0)
    self:modifyBetText(0, positionId)
end

-- 设置下注筹码数字
function MatchChipManager:modifyBetText(chips, positionId)
    if chips > 0 then
        self.betChipTextBgs_[positionId]:show()
        self.betChipTextLabels_[positionId]:show():setString(bm.formatBigNumber(chips))
    else
        self.betChipTextBgs_[positionId]:hide()
        self.betChipTextLabels_[positionId]:hide()
    end
end

-- 合奖池动画
function MatchChipManager:gatherPot()
    -- 设置需要移至奖池区的筹码数据
    for i = 0, 8 do
        self.betChipViews_[i]:setPotChipData()
    end

    if self.gatherPotScheduleHandle_ then
        scheduler.unscheduleGlobal(self.gatherPotScheduleHandle_)
    end

    -- self.gatherPotScheduleHandle_ = scheduler.performWithDelayGlobal(
    --     handler(self, self.gatherPotDelayCallback_), 
    --     BetChipView.MOVE_FROM_SEAT_DURATION 
    -- )

     -- 前注奖池包，多延迟1秒合奖池
    local delayTime = BetChipView.MOVE_FROM_SEAT_DURATION + 0.3
    if self.roomController:isPreCall() then
        delayTime = delayTime + 0.3
    end
    self.gatherPotScheduleHandle_ = scheduler.performWithDelayGlobal(
        handler(self, self.gatherPotDelayCallback_), 
        delayTime
    )

end

function MatchChipManager:gatherPotDelayCallback_()
    for seatId = 0, 8 do
        self.betChipViews_[seatId]:moveToPot()
        self:modifyBetText(self.betChipViews_[seatId]:getBetTotalChips(), self.seatManager:getSeatPositionId(seatId))
    end
    self.createPotScheduleHandle_ = scheduler.performWithDelayGlobal(
        handler(self, self.createPotDelayCallback_), 
        BetChipView.MOVE_TO_POT_DURATION
    )
end

function MatchChipManager:createPotDelayCallback_()    

     for _, v in pairs(self.model.gameInfo.pots) do
        self.potChipViews_[v.potIdx]:resetChipStack(v.potChips)
        self:modifyPotText(v.potChips, v.potIdx)
    end

    -- self.potChipViews_[1]:resetChipStack(self.model.gameInfo.totalAnte)
    -- self:modifyPotText(self.model.gameInfo.totalAnte, 1) 
end

-- 设置奖池筹码数字
function MatchChipManager:modifyPotText(chips, potId)
    if chips > 0 then
        self.potChipTextBgs_[potId]:show()
        self.potChipTextLabels_[potId]:show():setString(bm.formatBigNumber(chips))
    else
        self.potChipTextBgs_[potId]:hide()
        self.potChipTextLabels_[potId]:hide()
    end
    -- self.potChipTextBgs_[potId]:hide()
    -- self.potChipTextLabels_[potId]:hide()
end

-- 分奖池
function MatchChipManager:splitPots()
    local potsData = self.model.gameInfo.splitPots
    if potsData then
        -- 获取奖池数量
        self.potsNum_ = 1
        if #potsData > 0 then
            self:startSplit()
            if (potsData[1].cardType and potsData[1].cardType:getCardTypeValue() >= 4) and not self.model:canShowHandcard() then
                nk.SoundManager:playSound(nk.SoundManager.APPLAUSE)
            end
        end
        if #potsData > 1 then
            self.splitPotsScheduleHandle_ = scheduler.scheduleGlobal(handler(self, self.startSplit), 3)
        end
    end



    --[[
    do return end
    self.potChipViews_[1]:reset()
    for i=0,8 do
        local player = self.model.playerList[i]
        if player then
            local seatId = player.seatId
            local positionId = self.seatManager:getSeatPositionId(seatId)
            if player.trunMoney ~= nil and player.trunMoney > 0 then
                if  player.trunMoney ~= player.nCurAnte then
                    self.seatManager:playSeatWinAnimation(seatId)
                end            
                self.potChipViews_[seatId + 1]:resetChipStack(player.trunMoney)
                self.potChipViews_[seatId + 1]:moveToSeat(positionId, function(localPotChips) 
                    local player = self.model.playerList[seatId]
                    if player then
                        player.nCurAnte = 0
                        --player.seatChips = player.seatChips + winChips - fee
                        self.seatManager:updateSeatState(seatId)
                    end
                end)

                -- 播放筹码声音
                nk.SoundManager:playSound(nk.SoundManager.MOVE_CHIP)

                -- 如果是自己，播放赢牌动画
                if self.model:selfSeatId() == seatId and player.trunMoney ~= player.nCurAnte then
                    self.animManager:playYouWinAnim()
                end
            end
        end
    end

    --]]
end


-- 分奖池动画
function MatchChipManager:startSplit()
    -- 测试，避免空值
    local potsData = self.model.gameInfo.splitPots or {}
    -- dump(self.potsNum_,"self.potsNum_")
    -- dump(potsData,"startSplit",10)

    if potsData[self.potsNum_] then
        local pot = potsData[self.potsNum_]
        local playerList = pot.playerList
        local potIdx = pot.potIdx
        local points = pot.points

        local playerCount = #playerList
        local positionIdArr = {}
        for _,v in pairs(playerList) do
            local positionId = self.seatManager:getSeatPositionId(v.seatId)
            table.insert(positionIdArr,positionId)
        end



        local seatId = pot.seatId
        local winChips = pot.winChips
        local fee = pot.fee or 0
        -- local positionId = self.seatManager:getSeatPositionId(seatId)
        --桌子播放赢牌动画
        -- if pot.isReallyWin then
        --     self.seatManager:playSeatWinAnimation(seatId)
        -- end
        self.potChipViews_[self.potsNum_]:moveToSeat(positionIdArr, function(localPotChips)  
                if playerList then
                    for _,v in pairs(playerList) do
                        local player = self.model.playerList[v.seatId]
                        if player then
                            player.betChips = 0
                            -- player.seatChips = player.seatChips + v.winPoints
                            self.seatManager:updateSeatState(v.seatId)
                             -- turnPoints >=0 : 平局或者赢牌
                            if player.turnPoints >= 0 then
                                -- 如果是自己，播放赢牌动画
                                if self.model:selfSeatId() == v.seatId then
                                    self.animManager:playYouWinAnim()
                                else
                                    self.seatManager:playSeatWinAnimation(v.seatId)
                                end

                            end
                            

                        end
                    end

                end
                --[[
                local player = self.model.playerList[seatId]
                if player then
                    player.betChips = 0
                    player.seatChips = player.seatChips + winChips - fee
                    self.seatManager:updateSeatState(seatId)
                end
--]]
            end
            )

        
        -- 修改奖池筹码数字
        self:modifyPotText(0, self.potsNum_)
        -- 播放筹码声音
        nk.SoundManager:playSound(nk.SoundManager.MOVE_CHIP)
       
       
    end

    -- 判断奖池是否分发完毕
    if self.potsNum_ == #potsData and self.splitPotsScheduleHandle_ then
        scheduler.unscheduleGlobal(self.splitPotsScheduleHandle_)
    else
        self.potsNum_ = self.potsNum_ + 1
    end
end


-- 从对象池获取筹码数据
function MatchChipManager:getChipData(chips)
    local numStr = tostring(chips)
    local strLen = string.len(numStr)
    local chipDataArr = {}
    for i = strLen, 1, -1 do
        local oddOrEven
        local value
        if (strLen - i + 1) % 2 == 0 then
            oddOrEven = "even"
        else
            oddOrEven = "odd"
        end
        value = string.sub(numStr, i, i) + 0
        if value > 5 then
            table.insert(chipDataArr, self.chipPool_[oddOrEven][5]:retrive())
            value = value - 5
        end
        while value >= 2 do
            table.insert(chipDataArr, self.chipPool_[oddOrEven][2]:retrive())
            value = value - 2
        end
        if value == 1 then
            table.insert(chipDataArr, self.chipPool_[oddOrEven][1]:retrive())
        end
    end
    return chipDataArr
end

-- 回收筹码数据
function MatchChipManager:recycleChipData(chipDataArr)
    if chipDataArr then
        for _, chipData in pairs(chipDataArr) do
            chipData:getSprite():opacity(255):removeFromParent()
            self.chipPool_[chipData:getOddOrEven()][chipData:getKey()]:recycle(chipData)
        end
    end
end

-- 重置筹码视图
function MatchChipManager:reset()
    -- 重置定时器
    if self.gatherPotScheduleHandle_ then
        scheduler.unscheduleGlobal(self.gatherPotScheduleHandle_)
    end
    if self.createPotScheduleHandle_ then
        scheduler.unscheduleGlobal(self.createPotScheduleHandle_)
    end
    if self.splitPotsScheduleHandle_ then
        scheduler.unscheduleGlobal(self.splitPotsScheduleHandle_)
    end

    -- 重置筹码堆
    for _, v in pairs(self.betChipViews_) do
        v:reset()
    end
    for _, v in pairs(self.potChipViews_) do
        v:reset()
    end

    -- 隐藏文字显示区
    for i = 1, 9 do
        self.betChipTextBgs_[i]:hide()
        self.potChipTextBgs_[i]:hide()
        self.betChipTextLabels_[i]:hide()
        self.potChipTextLabels_[i]:hide()
    end
end

-- 清理
function MatchChipManager:dispose()
    -- 重置定时器
    if self.gatherPotScheduleHandle_ then
        scheduler.unscheduleGlobal(self.gatherPotScheduleHandle_)
    end
    if self.createPotScheduleHandle_ then
        scheduler.unscheduleGlobal(self.createPotScheduleHandle_)
    end
    if self.splitPotsScheduleHandle_ then
        scheduler.unscheduleGlobal(self.splitPotsScheduleHandle_)
    end

    -- 释放下注和奖池筹码视图
    for _, v in pairs(self.betChipViews_) do
        v:dispose()
    end
    for _, v in pairs(self.potChipViews_) do
        v:dispose()
    end

    -- 释放对象池
    for _, v in pairs(self.chipPool_.odd) do
        v:dispose()
    end
    for _, v in pairs(self.chipPool_.even) do
        v:dispose()
    end
end

return MatchChipManager