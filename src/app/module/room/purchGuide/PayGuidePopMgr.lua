local PayGuide = import("app.module.room.purchGuide.PayGuide")
local FirChargePayGuidePopup = import("app.module.newstore.firChrgGuide.FirChrgPayGuidePopup")
local AgnChargePayGuidePopup = import("app.module.newstore.agnChrgGuide.AgnChrgPayGuidePopup")
local UserCrash = import("app.module.room.userCrash.UserCrash")
local EnterRoomTip = import("app.module.room.purchGuide.RoomEnterTip")
-- local StorePopup = import("app.module.newstore.StorePopup")

local PayGuidePopMgr = class("PayGuidePopMgr")

function PayGuidePopMgr:ctor(data)
	-- body
    self._blind = data.blind
	self._threshMin = data.enterLimit or data.minBuyIn
	self._threshMax = data.maxBuyIn

    self._roomType = data.roomType  -- 追加字段：房间类型,低于破产阀值或最小房间的最小准入时，传入nil。
end

function PayGuidePopMgr:showViews()
	-- body

	-- 是否显示破产支付引导
    local isShowPay = nk.OnOff:check("payGuide")
    local isPay = nk.userData.best and nk.userData.best.paylog == 1 or false
    -- local isAlmChargeFavPay = nk.userData.bagPayList and nk.userData.bagPayList.almRechgFav == 1 or false
	if self._threshMax ~= 0 then
            --todo

        if nk.userData["aUser.money"] >= self._threshMin and nk.userData["aUser.money"] <= self._threshMax then
            --todo
            return true
        else
           	if nk.userData["aUser.money"] < self._threshMin then
                --todo

                -- 有最大准入筹码值 && 筹码不足

                -- 低于破产阀值
            	if nk.userData["aUser.money"] < nk.userData.bankruptcyGrant.maxBmoney then
                    --todo
                    if nk.userData["aUser.bankMoney"] >= nk.userData.bankruptcyGrant.maxsafebox then
                        --保险箱的钱大于设定值，引导保险箱取钱
                        local userCrash = UserCrash.new(0,0,0,0,true,self.inRoom_)
                        userCrash:show()

                    else
                         if nk.userData.bankruptcyGrant.bankruptcyTimes == 0 then
                            --todo
                            local shownScene = 3
                            local isThirdPayOpen = isShowPay
                            local isFirstCharge = not isPay

                            -- 这里要取到当前要进的房间类型信息 --
                            local payBillType = self._roomType
                            -- end --

                            if nk.OnOff:check("firstchargeFavGray") and isThirdPayOpen and isFirstCharge then
                                --todo
                                FirChargePayGuidePopup.new(0):showPanel(0, nil, self.inRoom_)
                            else

                                local rechargeFavAccess = nk.userData.bagPayList and nk.userData.bagPayList.access == 1 or false
                                if nk.OnOff:check("rechargeFavGray") and isThirdPayOpen and isPay and rechargeFavAccess then
                                    --todo
                                    AgnChargePayGuidePopup.new():showPanel(0, nil, self.inRoom_)
                                else
                                    local params = {}

                                    params.isOpenThrPartyPay = isThirdPayOpen
                                    params.isFirstCharge = isFirstCharge
                                    params.sceneType = shownScene
                                    params.payListType = payBillType

                                    PayGuide.new(params):show(0, nil, self.inRoom_)
                                end
                            end
                        else
                            if nk.userData.bankruptcyGrant then
                                --todo
                                local rewardTime = nk.userData.bankruptcyGrant.bankruptcyTimes + 1
                                local bankruptcyTimes = nk.userData.bankruptcyGrant.bankruptcyTimes
                                local rewardMoney = nk.userData.bankruptcyGrant.money[rewardTime] or 0
                                local limitDay = nk.userData.bankruptcyGrant.day or 1
                                local limitTimes = nk.userData.bankruptcyGrant.num or 0
                                local userCrash = UserCrash.new(bankruptcyTimes,rewardMoney,limitDay,limitTimes)
                                userCrash:show()
                            end
                        end

                    end

                    -- if nk.userData.bankruptcyGrant.bankruptcyTimes == 0 then
                    --     --todo
                    --     local shownScene = 3
                    --     local isThirdPayOpen = isShowPay
                    --     local isFirstCharge = not isPay

                    --     -- 这里要取到当前要进的房间类型信息 --
                    --     local payBillType = self._roomType
                    --     -- end --
                    --     local params = {}

                    --     params.isOpenThrPartyPay = isThirdPayOpen
                    --     params.isFirstCharge = isFirstCharge
                    --     params.sceneType = shownScene
                    --     params.payListType = payBillType

                    --     PayGuide.new(params):show(0)
                    -- else
                    --     if nk.userData.bankruptcyGrant then
                    --         --todo
                    --         local rewardTime = nk.userData.bankruptcyGrant.bankruptcyTimes + 1
                    --         local bankruptcyTimes = nk.userData.bankruptcyGrant.bankruptcyTimes
                    --         local rewardMoney = nk.userData.bankruptcyGrant.money[rewardTime] or 0
                    --         local limitDay = nk.userData.bankruptcyGrant.day or 1
                    --         local limitTimes = nk.userData.bankruptcyGrant.num or 0
                    --         local userCrash = UserCrash.new(bankruptcyTimes,rewardMoney,limitDay,limitTimes)
                    --         userCrash:show()
                    --     end
                    -- end
                    
                else
                   	-- 在破产阀值和最小准入之间
                    local shownScene = 2
                    local isThirdPayOpen = isShowPay
                    local isFirstCharge = not isPay

                    -- 这里要取到当前要进的房间类型信息 --
                    local payBillType = self._roomType
                    -- end --

                    if nk.OnOff:check("firstchargeFavGray") and isThirdPayOpen and isFirstCharge then
                        --todo
                        FirChargePayGuidePopup.new(2):showPanel(1, nil, self.inRoom_)
                    else

                        local rechargeFavAccess = nk.userData.bagPayList and nk.userData.bagPayList.access == 1 or false
                        if nk.OnOff:check("rechargeFavGray") and isThirdPayOpen and isPay and rechargeFavAccess then
                            --todo
                            AgnChargePayGuidePopup.new():showPanel(1, nil, self.inRoom_)
                        else
                            local params = {}

                            params.isOpenThrPartyPay = isThirdPayOpen
                            params.isFirstCharge = isFirstCharge
                            params.sceneType = shownScene
                            params.payListType = payBillType

                            PayGuide.new(params):show(1, nil, self.inRoom_)
                        end
                    end
                end
            else
                --todo
                local roomInfo = {}
                roomInfo.blind = self._blind
                roomInfo.minBuyIn = self._threshMin
                roomInfo.maxBuyIn = self._threshMax

                EnterRoomTip.new(roomInfo):show()
            end

           	return false
        end
    else
        --todo
        if nk.userData["aUser.money"] >= self._threshMin then
            --todo
            return true
        else

            if nk.userData["aUser.money"] < nk.userData.bankruptcyGrant.maxBmoney then

                if nk.userData["aUser.bankMoney"] >= nk.userData.bankruptcyGrant.maxsafebox then
                    --保险箱的钱大于设定值，引导保险箱取钱
                    local userCrash = UserCrash.new(0,0,0,0,true,self.inRoom_)
                    userCrash:show()

                else
                    --todo
                    if nk.userData.bankruptcyGrant.bankruptcyTimes == 0 then
                            --todo
                        local shownScene = 3
                        local isThirdPayOpen = isShowPay
                        local isFirstCharge = not isPay

                        -- 这里要取到当前要进的房间类型信息 --
                        local payBillType = self._roomType
                        -- end --

                        if nk.OnOff:check("firstchargeFavGray") and isThirdPayOpen and isFirstCharge then
                            --todo
                            FirChargePayGuidePopup.new(0):showPanel(0, nil, self.inRoom_)
                        else

                            local rechargeFavAccess = nk.userData.bagPayList and nk.userData.bagPayList.access == 1 or false
                            if nk.OnOff:check("rechargeFavGray") and isThirdPayOpen and isPay and rechargeFavAccess then
                                --todo
                                AgnChargePayGuidePopup.new():showPanel(0, nil, self.inRoom_)
                            else
                                local params = {}

                                params.isOpenThrPartyPay = isThirdPayOpen
                                params.isFirstCharge = isFirstCharge
                                params.sceneType = shownScene
                                params.payListType = payBillType

                                PayGuide.new(params):show(0, nil, self.inRoom_)
                            end
                        end
                    else
                        if nk.userData.bankruptcyGrant then
                            --todo
                            local rewardTime = nk.userData.bankruptcyGrant.bankruptcyTimes + 1
                            local bankruptcyTimes = nk.userData.bankruptcyGrant.bankruptcyTimes
                            local rewardMoney = nk.userData.bankruptcyGrant.money[rewardTime] or 0
                            local limitDay = nk.userData.bankruptcyGrant.day or 1
                            local limitTimes = nk.userData.bankruptcyGrant.num or 0
                            local userCrash = UserCrash.new(bankruptcyTimes,rewardMoney,limitDay,limitTimes)
                            userCrash:show()
                        end
                    end

                end

             	-- --todo
              --   if nk.userData.bankruptcyGrant.bankruptcyTimes == 0 then
              --           --todo
              --       local shownScene = 3
              --       local isThirdPayOpen = isShowPay
              --       local isFirstCharge = not isPay

              --       -- 这里要取到当前要进的房间类型信息 --
              --       local payBillType = self._roomType
              --       -- end --
              --       local params = {}

              --       params.isOpenThrPartyPay = isThirdPayOpen
              --       params.isFirstCharge = isFirstCharge
              --       params.sceneType = shownScene
              --       params.payListType = payBillType

              --       PayGuide.new(params):show(0)
              --   else
              --       if nk.userData.bankruptcyGrant then
              --           --todo
              --           local rewardTime = nk.userData.bankruptcyGrant.bankruptcyTimes + 1
              --           local bankruptcyTimes = nk.userData.bankruptcyGrant.bankruptcyTimes
              --           local rewardMoney = nk.userData.bankruptcyGrant.money[rewardTime] or 0
              --           local limitDay = nk.userData.bankruptcyGrant.day or 1
              --           local limitTimes = nk.userData.bankruptcyGrant.num or 0
              --           local userCrash = UserCrash.new(bankruptcyTimes,rewardMoney,limitDay,limitTimes)
              --           userCrash:show()
              --       end
              --   end

            else
                -- 在破产阀值和最小准入之间
                local shownScene = 2
                local isThirdPayOpen = isShowPay
                local isFirstCharge = not isPay

                -- 这里要取到当前要进的房间类型信息 --
                local payBillType = self._roomType
                -- end --
                if nk.OnOff:check("firstchargeFavGray") and isThirdPayOpen and isFirstCharge then
                    --todo
                    FirChargePayGuidePopup.new(2):showPanel(1, nil, self.inRoom_)
                else
                    local rechargeFavAccess = nk.userData.bagPayList and nk.userData.bagPayList.access == 1 or false
                    if nk.OnOff:check("rechargeFavGray") and isThirdPayOpen and isPay and rechargeFavAccess then
                        --todo
                        AgnChargePayGuidePopup.new():showPanel(1, nil, self.inRoom_)
                    else
                        local params = {}

                        params.isOpenThrPartyPay = isThirdPayOpen
                        params.isFirstCharge = isFirstCharge
                        params.sceneType = shownScene
                        params.payListType = payBillType

                        PayGuide.new(params):show(1, nil, self.inRoom_)
                    end
                end
            end

            return false

        end
    end
end

function PayGuidePopMgr:show(inRoom)
	-- body
    self.inRoom_ = inRoom
	return self:showViews()
end

return PayGuidePopMgr