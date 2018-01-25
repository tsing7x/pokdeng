--
-- Author: viking@boomegg.com
-- Date: 2014-12-08 15:02:08
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--
local UpgradeController = class("UpgradeController")

function UpgradeController:ctor(view_)
    self.view_ = view_
    self.getLevelRewardRetryTimes_ = 3
end

function UpgradeController:getReward()
    -- 领奖
    local level = nk.userData.nextRwdLevel
    self.rewardHttpId = nk.http.getLeverUpReward(level,function(data)
        if data then
            -- if retData.ret == 0 and data.prizeText ~= "" then
                nk.userData["aUser.mlevel"] = data.level;
                if data.prizeText then
                    self.view_:afterGetReward(data.prizeText)
                end
            -- else
                -- nk.userData.nextRwdLevel = 0
            -- end


            if data.money and data.addMoney then
                nk.userData["aUser.money"] = data.money
            end

            if data.props and (#data.props > 0) then
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


            self.view_:setLoading(false)

            --计算是否可升级
            local exp = checkint(nk.userData["aUser.exp"])
            local level = nk.userData["aUser.mlevel"]
            local maxLevel = nk.Level:getLevelByExp(exp);
            local dsLevel = maxLevel- level
            if (maxLevel > level) and (dsLevel >= 1) then
                nk.userData.nextRwdLevel = level + 1
            else
                nk.userData.nextRwdLevel = 0
            end

        end
        self.rewardHttpId = nil;
    end,function(errData)
        dump(errData," errData")
        if errData and errData.errorCode then
            nk.userData.nextRwdLevel = 0
            self.view_:setLoading(false)
        else
             if self.getLevelRewardRetryTimes_ > 0 then
                self:getReward()
                self.getLevelRewardRetryTimes_ = self.getLevelRewardRetryTimes_ - 1
            else
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
                self.view_:setLoading(false)
            end
        end
       
    end);

    --[[
    self.rewardHttpId = bm.HttpService.POST(
        {
            mod = "level", 
            act = "levelUpReward",
            level = nk.userData.nextRwdLevel
        }, 
        function (data)
            local retData = json.decode(data)
            local data = retData.data
            if retData.ret == 0 and data.prizeText ~= "" then
                nk.userData.nextRwdLevel = data.nextRwdLevel
                self.view_:afterGetReward(data.prizeText)
            else
                nk.userData.nextRwdLevel = 0
            end
            self.view_:setLoading(false)
        end, 
        function ()
            if self.getLevelRewardRetryTimes_ > 0 then
                self:getReward()
                self.getLevelRewardRetryTimes_ = self.getLevelRewardRetryTimes_ - 1
            else
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
                self.view_:setLoading(false)
            end
        end
    )
    --]]
end

function UpgradeController:dispose()
    if self.rewardHttpId then
        nk.http.cancel(self.rewardHttpId)
    end
end

return UpgradeController