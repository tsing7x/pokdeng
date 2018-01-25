--
-- Author: johnny@boomegg.com
-- Date: 2014-07-18 16:25:22
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

local BetChipView = class("BetChipView")
local RoomViewPosition = import(".RoomViewPosition")
local SP = RoomViewPosition.SeatPosition
local BP = RoomViewPosition.BetPosition
local PP = RoomViewPosition.PotPosition

BetChipView.MOVE_FROM_SEAT_DURATION = 0.4
BetChipView.MOVE_TO_POT_DURATION = 0.5
local MOVE_DELAY_DURATION = 0.075

local GAP_WITH_CHIPS = 4

function BetChipView:ctor(parent, manager, seatId)
    self.parent_ = parent
    self.manager_ = manager
    self.seatId_ = seatId
    self.betTotalChips_ = 0
end

function BetChipView:rotate(positionId)
    if self.betGrabChipData_ then
        for i, GrabChipData in ipairs(self.betGrabChipData_) do
            GrabChipData:getSprite():pos(BP[positionId].x, BP[positionId].y + 28 + (i - 1) * GAP_WITH_CHIPS)
        end
        return self
    end
end

-- 创建筹码堆
function BetChipView:createChipStack()
    if self.betGrabChipData_ then
        local positionId = self.manager_.seatManager:getSeatPositionId(self.seatId_)
        for i, GrabChipData in ipairs(self.betGrabChipData_) do
            local sp = GrabChipData:getSprite()
            if sp:getParent() then
                sp:pos(BP[positionId].x, BP[positionId].y + 28 + (i - 1) * GAP_WITH_CHIPS):opacity(255)
            else
                sp:pos(BP[positionId].x, BP[positionId].y + 28 + (i - 1) * GAP_WITH_CHIPS):opacity(255):addTo(self.parent_)
            end
        end

        return self
    end
end

-- 重置筹码堆
function BetChipView:resetChipStack(betChips)
    if self.betTotalChips_ == betChips then
        return self
    else
        self.betTotalChips_ = betChips
    end
    if self.betTotalChips_ > 0 then
        self.manager_:recycleGrabChipData(self.betGrabChipData_)
        self.betGrabChipData_ = self.manager_:getGrabChipData(self.betTotalChips_)

        -- 替换筹码堆
        self:createChipStack()
    end

    return self
end
 
-- 获取某一轮当前下注筹码
function BetChipView:getBetTotalChips()
    return self.betTotalChips_ or 0
end

-- 从座位飞出
function BetChipView:moveFromSeat(betNeedChips, betTotalChips)
    if betNeedChips > 0 and betTotalChips > 0 then
        -- 回收正在运动中的筹码数据
        if self.lastBetGrabChipData_ then
            if self.lastBetGrabChipData_ == self.potGrabChipData_ then
                self.potGrabChipData_ = nil
            end
            self.manager_:recycleGrabChipData(self.lastBetGrabChipData_)
            self.lastBetGrabChipData_ = nil
        end
        if self.movingGrabChipData_ then
            self.manager_:recycleGrabChipData(self.movingGrabChipData_)
            self.movingGrabChipData_ = nil
            self:createChipStack() -- 替换筹码堆
        end

        -- 设置上次下注的筹码数据
        self.lastBetGrabChipData_ = self.betGrabChipData_
        local lastBetChipNum = 0
        if self.lastBetGrabChipData_ then
            lastBetChipNum = #self.lastBetGrabChipData_
        end

        -- 获取本次筹码数据
        self.movingGrabChipData_ = self.manager_:getGrabChipData(betNeedChips)
        self.betGrabChipData_ = self.manager_:getGrabChipData(betTotalChips)
        self.betTotalChips_ = betTotalChips

        -- 动画
        local positionId = self.manager_.seatManager:getSeatPositionId(self.seatId_)
        for i, GrabChipData in ipairs(self.movingGrabChipData_) do
            local sp = GrabChipData:getSprite():pos(SP[positionId].x, SP[positionId].y):opacity(0):addTo(self.parent_)
            if i < #self.movingGrabChipData_ then
                transition.execute(
                    sp, 
                    cc.MoveTo:create(
                        BetChipView.MOVE_FROM_SEAT_DURATION, 
                        cc.p(BP[positionId].x, BP[positionId].y + 28 + (i + lastBetChipNum - 1) * GAP_WITH_CHIPS)
                    ), 
                    {delay = (i - 1) * MOVE_DELAY_DURATION}
                )
            else
                transition.execute(
                    sp, 
                    cc.MoveTo:create(
                        BetChipView.MOVE_FROM_SEAT_DURATION, 
                        cc.p(BP[positionId].x, BP[positionId].y + 28 + (i + lastBetChipNum - 1) * GAP_WITH_CHIPS)
                    ), 
                    {delay = (i - 1) * MOVE_DELAY_DURATION, onComplete = handler(self, self.moveFromSeatComplete_)}
                )
            end
            transition.execute(
                sp, 
                cc.FadeTo:create(
                    BetChipView.MOVE_FROM_SEAT_DURATION, 
                    255
                ), 
                {delay = (i - 1) * MOVE_DELAY_DURATION}
            )
        end
    end

    return self
end

function BetChipView:moveFromSeatComplete_()
    -- 有上一次的下注筹码数据，则回收
    if self.lastBetGrabChipData_ then
        if self.lastBetGrabChipData_ == self.potGrabChipData_ then
            self.potGrabChipData_ = nil
        end
        self.manager_:recycleGrabChipData(self.lastBetGrabChipData_)
        self.lastBetGrabChipData_ = nil
    end
    -- 运动中的筹码数据与总下注筹码数据不相等，则回收运动中的筹码数据，同时由总下注筹码数据创建新的筹码堆
    if self.movingGrabChipData_ then
        self.manager_:recycleGrabChipData(self.movingGrabChipData_)
        self.movingGrabChipData_ = nil
    end
    self:createChipStack() -- 替换筹码堆
end

--[[
    设置移动至奖池的筹码数据
    先保存self.betGrabChipData_数据，以防出现收筹码动画时，刚好有人下注的情况
]]
function BetChipView:setPotGrabChipData()
    if self.betGrabChipData_ and self.betTotalChips_ > 0 then
        if self.potGrabChipData_ and self.potGrabChipData_ ~= self.betGrabChipData_ then
            if self.potGrabChipData_ == self.lastBetGrabChipData_ then
                self.lastBetGrabChipData_ = nil
            end
            self.manager_:recycleGrabChipData(self.potGrabChipData_)
        end
        self.potGrabChipData_ = self.betGrabChipData_
    end
    self.betTotalChips_ = 0

    return self
end

-- 移动至奖池
function BetChipView:moveToPot()
    if self.potGrabChipData_ then
        -- 回收正在运动中的筹码数据
        if self.potGrabChipData_ == self.betGrabChipData_ then
            if self.lastBetGrabChipData_ then
                self.manager_:recycleGrabChipData(self.lastBetGrabChipData_)
                self.lastBetGrabChipData_ = nil
            end
            if self.movingGrabChipData_ then
                self.manager_:recycleGrabChipData(self.movingGrabChipData_)
                self.movingGrabChipData_ = nil
                self:createChipStack() -- 替换筹码堆
            end
        end

        local positionId = self.manager_.seatManager:getSeatPositionId(self.seatId_)
        local chipNum = #self.potGrabChipData_
        for i, GrabChipData in ipairs(self.potGrabChipData_) do
            local sp = GrabChipData:getSprite()
            -- 这里获取的sprite不一定已经添加在舞台，所以需要重新添加至舞台并设置位置
            if sp:getParent() then
                sp:pos(BP[positionId].x, BP[positionId].y + 28 + (i - 1) * GAP_WITH_CHIPS):opacity(255)
            else
                sp:pos(BP[positionId].x, BP[positionId].y + 28 + (i - 1) * GAP_WITH_CHIPS):opacity(255):addTo(self.parent_)
            end
            if i > 1 then
                transition.execute(
                    sp, 
                    cc.MoveTo:create(
                        BetChipView.MOVE_TO_POT_DURATION, 
                        cc.p(PP[1].x, PP[1].y + 28 + (i - 1) * GAP_WITH_CHIPS)
                    ), 
                    {delay = (chipNum - i) * MOVE_DELAY_DURATION}
                )
            else
                transition.execute(
                    sp, 
                    cc.MoveTo:create(
                        BetChipView.MOVE_TO_POT_DURATION, 
                        cc.p(PP[1].x, PP[1].y + 28 + (i - 1) * GAP_WITH_CHIPS)
                    ), 
                    {delay = (chipNum - i) * MOVE_DELAY_DURATION, onComplete = handler(self, self.moveToPotComplete_)}
                )
            end
            transition.execute(
                sp, 
                cc.FadeTo:create(
                    BetChipView.MOVE_TO_POT_DURATION, 
                    0
                ), 
                {delay = (chipNum - i) * MOVE_DELAY_DURATION}
            )
        end
    end

    return self
end

function BetChipView:moveToPotComplete_()
    if self.potGrabChipData_ == self.betGrabChipData_ then
        self.betGrabChipData_ = nil
    end
    if self.potGrabChipData_ == self.lastBetGrabChipData_ then
        self.lastBetGrabChipData_ = nil
    end
    self.manager_:recycleGrabChipData(self.potGrabChipData_)
    self.potGrabChipData_ = nil
end

function BetChipView:reset()
    -- 回收筹码数据
    if self.lastBetGrabChipData_ then
        if self.lastBetGrabChipData_ == self.betGrabChipData_ then
            self.betGrabChipData_ = nil
        end
        if self.lastBetGrabChipData_ == self.potGrabChipData_ then
            self.potGrabChipData_ = nil
        end
        self.manager_:recycleGrabChipData(self.lastBetGrabChipData_)
        self.lastBetGrabChipData_ = nil
    end
    if self.potGrabChipData_ then
        if self.potGrabChipData_ == self.betGrabChipData_ then
            self.betGrabChipData_ = nil
        end
        self.manager_:recycleGrabChipData(self.potGrabChipData_)
        self.potGrabChipData_ = nil
    end
    if self.movingGrabChipData_ then
        self.manager_:recycleGrabChipData(self.movingGrabChipData_)
        self.movingGrabChipData_ = nil
    end
    if self.betGrabChipData_ then
        self.manager_:recycleGrabChipData(self.betGrabChipData_)
        self.betGrabChipData_ = nil
    end
    self.betTotalChips_ = 0
end

-- 清理
function BetChipView:dispose()
    self:reset()
end

return BetChipView