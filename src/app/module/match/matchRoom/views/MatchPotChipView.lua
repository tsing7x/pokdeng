--
-- Author: johnny@boomegg.com
-- Date: 2014-07-18 16:25:34
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

local MatchPotChipView = class("MatchPotChipView")

local RoomViewPosition = import(".MatchRoomViewPosition")
local SP = RoomViewPosition.SeatPosition
local PP = RoomViewPosition.PotPosition
local MOVE_TO_SEAT_DURATION = 0.5
local MOVE_DELAY_DURATION = 0.075
local GAP_WITH_CHIPS = 4
local logger = bm.Logger.new("MatchPotChipView")

function MatchPotChipView:ctor(parent, manager, potId)
    self.parent_ = parent
    self.manager_ = manager
    self.potId_ = potId
    self.potChips_ = 0
end

-- 创建筹码堆
function MatchPotChipView:createChipStack()
    for i, chipData in ipairs(self.potChipData_) do
        chipData:getSprite():pos(PP[self.potId_].x, PP[self.potId_].y + 28 + (i - 1) * GAP_WITH_CHIPS):opacity(255):addTo(self.parent_)
        -- chipData:getSprite():pos(PP[1].x, PP[1].y + 28 + (i - 1) * GAP_WITH_CHIPS):opacity(255):addTo(self.parent_)
    end

    return self
end

-- 重置筹码堆
function MatchPotChipView:resetChipStack(potChips)
    if self.potChips_ == potChips then
        return self
    else
        self.potChips_ = potChips
    end
    if self.potChips_ > 0 then
        self.manager_:recycleChipData(self.potChipData_)
        self.potChipData_ = self.manager_:getChipData(self.potChips_)

        -- 替换筹码堆
        self:createChipStack()
    end
    
    return self
end

function MatchPotChipView:moveToSeat(positionIdArr, completeCallback)

    local len = #positionIdArr
    local chipNum = #self.potChipData_
    local avrange1 = math.floor(chipNum/len)
    local avgMod = chipNum % len

    local posArr = {}
    local startIndex = 1
    local endIndex = 1
    for i,posId in ipairs(positionIdArr) do
        local posInfo = {}
        posInfo.positionId = posId
        if i <= avgMod then
            posInfo.chipNum = avrange1 + 1
        else
            posInfo.chipNum = avrange1
        end

        posInfo.startIndex = startIndex
        startIndex = startIndex + posInfo.chipNum

        endIndex = endIndex + posInfo.chipNum
        posInfo.endIndex = endIndex

        table.insert(posArr,posInfo)
    end

    self.moveToSeatCompleteCallback_ = completeCallback
    if self.potChipData_ then
        for _,posInfo in pairs(posArr) do
            local j = 0
            for i = posInfo.startIndex,(posInfo.endIndex-1) do
                local sp = self.potChipData_[i]:getSprite()
                j = j + 1
                if sp then
                    if j > 1 then
                        transition.execute(
                        sp, 
                            cc.MoveTo:create(
                                MOVE_TO_SEAT_DURATION, 
                                cc.p(SP[posInfo.positionId].x, SP[posInfo.positionId].y)
                            ), 
                            {delay = (posInfo.chipNum - j) * MOVE_DELAY_DURATION}
                        )
                    else
                        transition.execute(
                            sp, 
                            cc.MoveTo:create(
                                MOVE_TO_SEAT_DURATION, 
                                cc.p(SP[posInfo.positionId].x, SP[posInfo.positionId].y)
                            ), 
                            {delay = (posInfo.chipNum - j) * MOVE_DELAY_DURATION, onComplete = handler(self, self.moveToSeatComplete_)}
                        )
                    end

                    transition.execute(
                        sp, 
                        cc.FadeTo:create(
                            MOVE_TO_SEAT_DURATION, 
                            128
                        ), 
                        {
                            delay = (posInfo.chipNum - j) * MOVE_DELAY_DURATION, 
                            onComplete = function ()
                                sp:opacity(0)
                            end
                        }
                    )


                end
                

            end

        end


    end

    --[[
    self.moveToSeatCompleteCallback_ = completeCallback
    if self.potChipData_ then
        local chipNum = #self.potChipData_
        for i, chipData in ipairs(self.potChipData_) do
            local sp = chipData:getSprite()
            if i > 1 then
                transition.execute(
                    sp, 
                    cc.MoveTo:create(
                        MOVE_TO_SEAT_DURATION, 
                        cc.p(SP[positionId].x, SP[positionId].y)
                    ), 
                    {delay = (chipNum - i) * MOVE_DELAY_DURATION}
                )
            else
                transition.execute(
                    sp, 
                    cc.MoveTo:create(
                        MOVE_TO_SEAT_DURATION, 
                        cc.p(SP[positionId].x, SP[positionId].y)
                    ), 
                    {delay = (chipNum - i) * MOVE_DELAY_DURATION, onComplete = handler(self, self.moveToSeatComplete_)}
                )
            end
            transition.execute(
                sp, 
                cc.FadeTo:create(
                    MOVE_TO_SEAT_DURATION, 
                    128
                ), 
                {
                    delay = (chipNum - i) * MOVE_DELAY_DURATION, 
                    onComplete = function ()
                        sp:opacity(0)
                    end
                }
            )
        end
    end
    --]]
end

function MatchPotChipView:moveToSeatComplete_()
    if self.moveToSeatCompleteCallback_ then
        self.moveToSeatCompleteCallback_(self.potChips_)
        self.moveToSeatCompleteCallback_ = nil
    end
    if self.potChipData_ then
        self.manager_:recycleChipData(self.potChipData_)
        self.potChipData_ = nil
    end
    self.potChips_ = 0
end

function MatchPotChipView:reset()
    if self.potChipData_ then
        self.manager_:recycleChipData(self.potChipData_)
        self.potChipData_ = nil
    end
    self.potChips_ = 0
end

-- 清理
function MatchPotChipView:dispose()
    self:reset()
end

return MatchPotChipView