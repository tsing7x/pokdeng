--
-- Author: shanks
-- Date: 2014.09.09
-- ps:后台清数据：MOBILE_TREASURE_13892
--

local CountDownBox = class("CountDownBox", function()
    return display.newNode()
    end)

local timeStr
local action

local logger = bm.Logger.new("CountDownBox")

function CountDownBox:ctor(ctx)
    self.ctx = ctx



    --test
    -- local callData = {time=5,nextMoney=0,multiple = 3}
    -- self.isFinished = callData.remainTime <= 0 and callData.nextMoney == 0
    --             self.remainTime = callData.time
    --             self.reward = callData.nextMoney
    --             self.multiple = callData.multiple
    --             self:showFunc()

    -- do return end
    self:bindDataObserver()
    
    self.getCountDownBoxRequest_ = nk.http.getCountDownBoxInfo(
        function (callData)
            if callData then
                self.isFinished = callData.time <= 0 and callData.nextMoney == 0
                self.remainTime = callData.time
                self.reward = callData.nextMoney
                self.multiple = callData.multiple or 1
                self:showFunc()
            end
        end,
        function (errData)
            -- logger:debug("count_down_get:" .. data)
        end)

end

function CountDownBox:showFunc()
    timeStr = (self.remainTime > 0 and bm.TimeUtil:getTimeString(self.remainTime)) or ""
    self.timeLabel = display.newTTFLabel({text = timeStr, color = cc.c3b(0xff, 0xff, 0xff), size = 20, align = ui.TEXT_ALIGN_CENTER})
        :pos(-40, 100)
        :addTo(self)

    self.countDown = false

    self:showStatus()

    -- self:bindDataObserver()

    -- 重连
    if self.ctx.model:isSelfInSeat() then
        self:sitDownFunc()
    end
end

function CountDownBox:showStatus()
    if not self.finishedButton then
        self.finishedButton = cc.ui.UIPushButton.new({normal="#count_down_box_finished.png", pressed="#count_down_box_finished.png"})
            :onButtonClicked(handler(self, self.finishPrompt))
            :pos(-40, 120)    
            :addTo(self)
        self.rewardButton = cc.ui.UIPushButton.new({normal="#count_down_box_reward.png", pressed="#count_down_box_reward.png"})
            :onButtonClicked(handler(self, self.getReward))
            :pos(-40, 120)
            :addTo(self)
        self.countButton = cc.ui.UIPushButton.new({normal="#count_down_box_normal.png", pressed="#count_down_box_normal.png"})
            :onButtonClicked(handler(self, self.promptFunc))
            :pos(-40, 140)
            :addTo(self)
    end

    self.finishedButton:hide()
    self.rewardButton:hide()
    self.countButton:hide()

    if self.isFinished then
        logger:debug("status:finish")
        self:countDownStatus(false)
        self.finishedButton:show()
    elseif not self.isFinished and self.remainTime <= 0 then
        logger:debug("status:reward")
        self:countDownStatus(false)
        self.rewardButton:show()
    else
        logger:debug("status:count")
        self:countDownStatus(self.ctx.model:isSelfInSeat())
        self.countButton:show()
    end
end

function CountDownBox:countDownStatus(status)
    if self.countDown and not status then
        if action then
            self:stopAction(action)
            action = nil
        end
    end
    if not self.countDown and status then
        action = self:schedule(function ()
            self:countFunc()
        end, 1)    
    end
    self.countDown = status
end

function CountDownBox:countFunc()
    self.remainTime = self.remainTime - 1
    if self.remainTime <= 0 then
        self:showStatus()
    end

    self:showTime()
end

function CountDownBox:showTime() 
    timeStr = (self.remainTime > 0 and bm.TimeUtil:getTimeString(self.remainTime)) or ""
    if self.timeLabel then
        self.timeLabel:setString(timeStr)
    end
    
end 

function CountDownBox:finishPrompt()
    nk.TopTipManager:showTopTip(bm.LangUtil.getText("COUNTDOWNBOX", "FINISHED"))
    nk.SoundManager:playSound(nk.SoundManager.BOX_OPEN_NORMAL)
end 

function CountDownBox:getReward() 
    nk.SoundManager:playSound(nk.SoundManager.BOX_OPEN_REWARD)
    -- {"code":2,"remainTime":0,"nextRemainTime":420,"nextRewardChip":"3,000\u0e0a\u0e34\u0e1b"}
    self.getCountDownRewardRequest_ = nk.http.getCountDownBoxReward(
        function (callData)

            -- dump(callData, "nk.http.getCountDownBoxReward.retData :============")            
            if callData then
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("COUNTDOWNBOX", "REWARD", self.reward))
                bm.EventCenter:dispatchEvent({name = nk.eventNames.UPDATE_SEAT_ANTE_CHIP, data = {chip = self.reward}})
                self.isFinished = callData.nextTime <= 0 and callData.nextMoney == 0
                self.remainTime = callData.nextTime
                self.reward = callData.nextMoney

                if self.reward > 0 then
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("COUNTDOWNBOX", "NEXT_REWARD", self.reward))
                end

                self:showStatus()
                self:showTime()
            -- elseif callData.code == 0 then
            --     self.remainTime = callData.nextRemainTime
            --     self:showStatus()
            --     self:showTime()
            end
        end,
        function (errData)
            -- dump(errData, "nk.http.getCountDownBoxReward.errData :============")
            if errData and type(errData) == "table" and errData.errorCode then
                --时间未到，校正时间
                if errData.errorCode == -3 then
                    if errData.retData and errData.retData.data then
                        self.remainTime = checkint(errData.retData.data.nextTime)
                        self:showStatus()
                        self:showTime()

                    end
                    
                end
            end
            -- logger:debug("count_down_reward:" .. data)
        end)

end

function CountDownBox:promptFunc() 
    nk.SoundManager:playSound(nk.SoundManager.BOX_OPEN_NORMAL)
    if self.ctx.model:isSelfInSeat() then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("COUNTDOWNBOX", "NEEDTIME", 
            bm.TimeUtil:getTimeMinuteString(self.remainTime), bm.TimeUtil:getTimeSecondString(self.remainTime), self.reward))
    else
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("COUNTDOWNBOX", "SITDOWN"))
    end
end

function CountDownBox:bindDataObserver()
    self.onDataObserver = bm.DataProxy:addDataObserver(nk.dataKeys.SIT_OR_STAND, handler(self, self.sitStatusFunc))
end

function CountDownBox:unbindDataObserver()
    bm.DataProxy:removeDataObserver(nk.dataKeys.SIT_OR_STAND, self.onDataObserver)
end

function CountDownBox:sitStatusFunc(sitData)
    if not sitData then 
        return
    end
    local isSit = sitData.inSeat
    local seatId = sitData.seatId
    
    if isSit then
        self:sitDownFunc() 
    else 
        self:standUpFunc()
    end
end

function CountDownBox:sitDownFunc() 
    --  {"remainTime":0,"rewardChip":"1,500 \u0e0a\u0e34\u0e1b","code":0}
   

    self.getCownBoxInfoRequest_ = nk.http.getCountDownBoxInfo(
        function (callData)
            if callData then
                self.isFinished = callData.time <= 0 and callData.nextMoney == 0
                self.remainTime = callData.time
                self.reward = callData.nextMoney
                self.multiple = callData.multiple or 1
                self:showStatus()
            end
        end,
        function (errData)
            -- logger:debug("count_down_get:" .. data)
        end)

   
end

function CountDownBox:standUpFunc()
    self:countDownStatus(false)
end

function CountDownBox:release()
    self:unbindDataObserver()

    if action then
        self:stopAction(action)
        action = nil
    end
    nk.http.cancel(self.getCountDownBoxRequest_)
    nk.http.cancel(self.getCountDownRewardRequest_)
    nk.http.cancel(self.getCownBoxInfoRequest_)
end

return CountDownBox