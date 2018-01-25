

local WheelController = class("WheelController")

function WheelController:ctor(view)
    self.view_ = view
    self.isTimesReady_ = false
    self.isConfigReady_ = false
end

function WheelController:isTimesReady()
    return self.isTimesReady_
end

function WheelController:isConfigReady()
    return self.isConfigReady_
end

function WheelController:isAllReady()
    return self.isTimesReady_ and self.isConfigReady_
end

function WheelController:getPlayTimes(callback)

    self.playTimesId = nk.http.getWheelInitInfo(
        function(retData)
            if retData then
                self.isTimesReady_ = true
                self.freeTimes_ = retData.num
                callback(true, retData)
                --
            end
        end,
        function(errData)
            -- if errData and errData.errorCode then

            -- else

            -- end

            self.isTimesReady_ = false
            callback(false)
        end
    )

    --[[
    self.playTimesId = bm.HttpService.POST(
        {
            mod = "luckyWheel",
            act = "getFreeTimes"
        },
        function(data)
            local retData = json.decode(data)
            if retData and retData.ret == 0 then
                self.isTimesReady_ = true
                self.freeTimes_ = retData.freeTimes
                callback(true, retData.freeTimes)
            end
        end,
        function()
            self.isTimesReady_ = false
            callback(false)
        end
    )
    --]]
end

function WheelController:getConfig(callback)
    bm.cacheFile(nk.userData.WHEEL_CONF, function(result, content)
        if result == "success" then
            self.isConfigReady_ = true
            local wheelItems_ = json.decode(content)
            callback(true, wheelItems_)
        else
            self.isConfigReady_ = false
            callback(false)
        end
    end, "wheel")
end

function WheelController:playNow(callback)
    self.playNowId = nk.http.getWheelRewardInfo(
        function(retData)
            if retData then
                callback(true, retData)

                if retData.money then
                    local addMoney = retData.money.addMoney
                    local money = retData.money.money

                    -- nk.userData["aUser.money"] = money
                end

                if retData.props then
                    -- local pnid == retData.props.pnid
                    -- if pnid~=nil and pnid == 2001 then

                    -- end
                    --获取互动道具数量
                    nk.http.getUserProps(2,function(pdata)
                        if pdata then
                            for _,v in pairs(pdata) do
                                if tonumber(v.pnid) == 2001 then
                                    nk.userData.hddjNum = checkint(v.pcnter)
                                    break
                                end
                            end
                        end
                        
                    end,function()
                        
                    end)

                end
            end
        end,
        function() 
            callback(false) 
        end)
    --[[
    self.playNowId = bm.HttpService.POST( {
            mod = "luckyWheel", act = "playLuckyWheel"
        },
        function(data)
            local retData = json.decode(data)
            if retData and retData.ret == 0 then
                local rewardResult = retData.result
                callback(true, rewardResult)
            end
        end,
        function() callback(false) end
    )
    --]]
end
function WheelController:shareToGetChance()
    self.getchanceReuqest_ = nk.http.shareWheel(function(data)
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("WHEEL", "SHARE_GET_CHANCE"))--
        self.view_:getPlayTimes()
    end, function(errordata)

    end)
end

function WheelController:dispose()
    nk.http.cancel(self.playTimesId)
    nk.http.cancel(self.playNowId)
    nk.http.cancel(self.getchanceReuqest_)
end

return WheelController