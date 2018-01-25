--
-- Author: viking@boomegg.com
-- Date: 2014-11-21 10:51:55
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--
local SlotController = class("SlotController")

function SlotController:ctor(view)
    self.view_ = view
    self.isRuning_ = false
    self.gameOverHandler_ = bm.EventCenter:addEventListener(nk.DailyTasksEventHandler.REPORT_GAME_OVER, handler(self, self.onGameOver_))
    bm.EventCenter:addEventListener(nk.eventNames.SLOT_PLAY_RESULT, handler(self, self.onPlayResultListener_))
    bm.EventCenter:addEventListener(nk.eventNames.SLOT_BUY_RESULT, handler(self, self.onBuyResultListener_))
end

local sideBtnAminTime = 0.5
local sideBtnMinDistance = 10
function SlotController:sideBarCallback_(evtName, xArgs)
    local startX, currentX = xArgs.startX, xArgs.currentX
    local distance = currentX - startX
    local isOpening = self.isOpened or false
    if distance > 0 then
        isOpening = false
    else
        isOpening = true
    end

    -- local width = display.width
    local view_ = self.view_
    -- view_:closeUnVisible(false)
    local srcX = view_:getSrcX()
    local endX = view_:getEndX()
    local posX = view_:getPositionX()
    local moveX = (isOpening and srcX or endX) + distance

    if evtName == "began" then
        --todo
    elseif evtName == "moved" then

        if moveX < endX then
            moveX = endX
            self.isOpened = true
        elseif moveX > srcX then
            moveX = srcX
            self.isOpened = false
        end
        if math.abs(distance) > sideBtnMinDistance then
            view_:setPositionX(moveX)
        end
        -- print("SlotController:sideBarCallback_ moveX", self.isOpened, moveX)
    elseif evtName == "ended" then

        if moveX ~= srcX and moveX ~= endX then
            local srcY = view_:getPositionY()

            if isOpening then
                local sequence = transition.sequence({
                        cc.MoveTo:create(sideBtnAminTime, cc.p(endX, srcY)),
                        cc.CallFunc:create(function()
                            self.isOpened = true
                        end)
                    })
                view_:runAction(sequence)                
            else
                local sequence = transition.sequence({
                        cc.MoveTo:create(sideBtnAminTime, cc.p(srcX, srcY)),
                        cc.CallFunc:create(function()
                            self.isOpened = false
                        end)
                    })
                view_:runAction(sequence)
            end
        end

    elseif evtName == "clicked" then
        local srcY = view_:getPositionY()
        if self.isOpened then
            local sequence = transition.sequence({
                    cc.MoveTo:create(sideBtnAminTime, cc.p(srcX, srcY)),
                    cc.CallFunc:create(function()
                        -- self.isOpened = false
                    end)
                })
            view_:runAction(sequence)
            self.isOpened = false
        else
            local sequence = transition.sequence({
                    cc.MoveTo:create(sideBtnAminTime, cc.p(endX, srcY)),
                    cc.CallFunc:create(function()
                        -- self.isOpened = true
                    end)
                })
            view_:runAction(sequence)
            self.isOpened = true
        end

    end

    self.view_:getMinusMoneyView():stop()
    self.view_:getAddMoneyView():stop()
end

function SlotController:handlerCallback()
    -- print("SlotController:handlerCallback")
    if self:notEnoughMoney2Play() then
        return
    end

    local view_ = self.view_
    local betMoney = view_:getBetBar():getBet()
    if view_:isInRoom() then
        view_:getSideBar():handlerAnim()
    end

    -- nk.socket.SlotSocket:buySlot(betMoney, view_:getTid())
    self:buySlot_(tonumber(betMoney))
    if self.isOpened then
        nk.SoundManager:playSound(nk.SoundManager.SLOT_START)
    end
    view_:getFlashBar():stop()
    view_:getFlashBar():setTip(betMoney)
end

function SlotController:turningContentCallback(i, rewardMoney, isTopReward)
    if self.isOpened then
        nk.SoundManager:playSound(nk.SoundManager.SLOT_END)
    end
    local view_ = self.view_
    self.slotActive = false
    if i == 3 then
        self.isRuning_ = false
        nk.userData["aUser.money"] = self.finalMoney
        --中奖
        if rewardMoney > 0 then

            if isTopReward then
                --todo
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("SLOT", "TOP_PRIZE", nk.userData["aUser.name"], bm.formatBigNumber(tonumber(rewardMoney))))
            else
                -- nk.TopTipManager:showTopTip(bm.LangUtil.getText("SLOT", "PLAY_WIN", bm.formatBigNumber(tonumber(rewardMoney))))
            end

            --派发一个事件，周知座位管理器，减去或者加上金币
            if self.getedMoney ~= 0 then
                bm.EventCenter:dispatchEvent({name = nk.eventNames.UPDATE_SEAT_ANTE_CHIP, data = {chip = self.getedMoney}})
            end
            
            if self.isOpened then
                nk.SoundManager:playSound(nk.SoundManager.SLOT_WIN)
                local flashBar_ = view_:getFlashBar()
                flashBar_:flash(rewardMoney)
                flashBar_:delayStop(2, function()
                    if self.slotActive then
                        flashBar_:setTip(view_:getBetBar():getBet())
                    end
                end)
            else
                --没有打开
                view_:getSideBar():glowAnim()
                view_:getAddMoneyView():playAnim(rewardMoney)
            end
        else
            if self.isOpened then
                local flashBar_ = view_:getFlashBar()
                flashBar_:flash(rewardMoney)
                flashBar_:delayStop(2, function()
                    if self.slotActive then
                        flashBar_:setTip(view_:getBetBar():getBet())
                    end
                end)

            end
            

            -- nk.TopTipManager:showTopTip(bm.LangUtil.getText("SLOT", "PLAY_LOSE"))
        end

        --自动操作的情况
        if view_:getAutoCheckBox():isChecked() then
            view_:getHandler():loopAutoHandler()
        else
            view_:getHandler():setEnabled(true)
        end
    elseif i == 1 and self.loopSoundId then
        audio.stopSound(self.loopSoundId)
    end

    
end
function SlotController:onGameOver_()
    self.getedMoney = 0
end
function SlotController:autoCheckCallback(isChecked)
    -- print("SlotController:autoCheckCallback", isChecked)
    local view_ = self.view_
    local handler_ = view_:getHandler()
    if isChecked then
        if not self.slotActive then
            handler_:setEnabled(false)
            handler_:loopAutoHandler()
        end
    else
        if not self.slotActive then
            handler_:setEnabled(true)
        end
        handler_:stopLoopAutoHandler()
    end
end

function SlotController:onPlayResultListener_(evt)
    -- print("SlotController:onPlayResultListener_")
    if self.isOpened then
        self.loopSoundId = nk.SoundManager:playSound(nk.SoundManager.SLOT_LOOP, true)
    end
    local view_ = self.view_
    self.slotActive = true
    view_:getHandler():setEnabled(false)
    view_:getTurningContent():start(evt.data)
end

function SlotController:onBuyResultListener_(evt)
    --购买成功并且关闭
    if evt.data == 1 and not self.isOpened then
        local view_ = self.view_
        local betMoney = bm.formatBigNumber(view_:getBetBar():getBet())
        view_:getMinusMoneyView():playAnim(betMoney)
    end
end

function SlotController:notEnoughMoney2Play()
    -- local myMoney = nk.userData.money
    local myMoney = nk.userData["aUser.money"]
    local view_ = self.view_
    local betMoney = view_:getBetBar():getBet()

    if myMoney < betMoney then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("SLOT", "NOT_ENOUGH_MONEY"))
        return true
    end
    return false
end

function SlotController:Split(szFullString, szSeparator)
    local nFindStartIndex = 1
    local nSplitIndex = 1
    local nSplitArray = {}
    while true do
        local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex)
        if not nFindLastIndex then
            nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, string.len(szFullString))
            break
        end
        nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)
        nFindStartIndex = nFindLastIndex + string.len(szSeparator)
        nSplitIndex = nSplitIndex + 1
    end
    return nSplitArray
end

function SlotController:buySlot_(betMoney)
    if self.isRuning_ == true then 
        --nk.TopTipManager:showTopTip("请求被阻止")
        return 
    end
    self.isRuning_ = true

    local buySlotId = nk.http.buySlot(betMoney, function(data)
        -- body
        -- dump(data, "data: ===============1==")

        local ret = data[1]

        if ret == 1 then

             --先从座位上减掉已经下注的筹码
            bm.EventCenter:dispatchEvent({name = nk.eventNames.UPDATE_SEAT_ANTE_CHIP, data = {chip = -betMoney}})
            --todo
            local rewardMoney = tonumber(data[3])

            self.getedMoney = rewardMoney
           -- nk.TopTipManager:showTopTip("金币:"..self.getedMoney)


            -- local userMoney = tonumber(data[4])

            -- nk.userData["aUser.money"] = userMoney
            local rewardArr = self:Split(data[2], ",")

            local values = {tonumber(rewardArr[1]), tonumber(rewardArr[2]), tonumber(rewardArr[3])}

            bm.EventCenter:dispatchEvent({name = nk.eventNames.SLOT_BUY_RESULT, data = ret})
            bm.EventCenter:dispatchEvent({name = nk.eventNames.SLOT_PLAY_RESULT, data = {values = values, rewardMoney = rewardMoney}})
            self.finalMoney = data[4]
            --nk.userData["aUser.money"] = data[4]
        elseif ret == -3 then
            self.isRuning_ = false
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("SLOT", "NOT_ENOUGH_MONEY"))
        elseif ret == -4 then
            self.isRuning_ = false
            local betMoney = self.view_:getBetBar():getBet()
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("SLOT", "NOT_ENOUGH_MONEY_IN_POKECT2"))
           -- nk.TopTipManager:showTopTip(bm.LangUtil.getText("SLOT", "NOT_ENOUGH_MONEY_IN_POKECT", bm.formatBigNumber(tonumber(betMoney))))
        else
            self.isRuning_ = false
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("SLOT", "SYSTEM_ERROR"))
        end
    end, function(errData)
        -- body
        -- dump(errData, "errData: ================1==")
        self.isRuning_ = false
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("SLOT", "SYSTEM_ERROR"))
    end)
    
end

function SlotController:dispose()
    bm.EventCenter:removeEventListenersByEvent(nk.eventNames.SLOT_PLAY_RESULT)
    bm.EventCenter:removeEventListenersByEvent(nk.eventNames.SLOT_BUY_RESULT)
    if self.loopSoundId then
        audio.stopSound(self.loopSoundId)
    end
    local view_ = self.view_
    view_:getAddMoneyView():dispose()
    view_:getAutoCheckBox():dispose()
    view_:getBetBar():dispose()
    view_:getFlashBar():dispose()
    view_:getHandler():dispose()
    view_:getMinusMoneyView():dispose()
    if view_:isInRoom() then
        view_:getSideBar():dispose()
    end
    view_:getTurningContent():dispose()
    self.isRuning_ = false
end

return SlotController
