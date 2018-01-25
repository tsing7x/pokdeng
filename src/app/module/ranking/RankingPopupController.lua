--
-- Author: johnny@boomegg.com
-- Date: 2014-08-25 22:04:49
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

local RankingPopupController = class("RankingPopupController")
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")

local requestRetryTimes_ = 2

RankingPopupController.currentRankingType = 1 -- 1代表资产排行，2代表等级排行

function RankingPopupController:ctor(view)
    self.view_ = view
end

function RankingPopupController:onMainTabChange(selectedTab)
    self.mainSelectedTab_ = selectedTab
    dump(selectedTab,"selectedTab")
    nk.http.cancel(self.friendDataRequestId_)
    nk.http.cancel(self.rankingDataRequestId_)

    requestRetryTimes_ = 2
    if self.mainSelectedTab_ == 1 then
        if self.friendData_ then
            -- 好友排行
            if self.subSelectedTab_ == 1 then
                -- 资产排行
                table.sort(self.friendData_, function(o1, o2)
                    return checkint(o1.money) > checkint(o2.money)
                end)
                RankingPopupController.currentRankingType = 1
                self.view_:setListData(self.friendData_)
            elseif self.subSelectedTab_ == 2 then
                -- 等级排行
                table.sort(self.friendData_, function(o1, o2)
                    return checkint(o1.exp) > checkint(o2.exp)
                end)
                RankingPopupController.currentRankingType = 2
                self.view_:setListData(self.friendData_)
            elseif self.subSelectedTab_ == 3 then
                -- 现金币排行
                table.sort(self.friendData_, function(o1, o2)
                    return checkint(o1.point) > checkint(o2.point)
                end)
                RankingPopupController.currentRankingType = 4
                self.view_:setListData(self.friendData_)
            end
        else
            if self.subSelectedTab_ == 1 then
                RankingPopupController.currentRankingType = 1
            elseif self.subSelectedTab_ == 2 then
                RankingPopupController.currentRankingType = 2
            elseif self.subSelectedTab_ == 3 then
                RankingPopupController.currentRankingType = 4
            end
            self:requestFriendData_()
            self.view_:setLoading(true)
        end
    else
        if self.rankingData_ then
            -- 总排行
            if self.subSelectedTab_ == 1 then
                -- 资产排行
                RankingPopupController.currentRankingType = 1
                self.view_:setListData(self.rankingData_.money)
            elseif self.subSelectedTab_ == 2 then
                -- 等级排行
                RankingPopupController.currentRankingType = 2
                self.view_:setListData(self.rankingData_.level)
            elseif self.subSelectedTab_ == 3 then
                RankingPopupController.currentRankingType = 3
                self.view_:setListData(self.rankingData_.winMoney)
            elseif self.subSelectedTab_ == 4 then
                RankingPopupController.currentRankingType = 4
                self.view_:setListData(self.rankingData_.point)
            end
        else
            if self.subSelectedTab_ == 1 then
                RankingPopupController.currentRankingType = 1
            elseif self.subSelectedTab_ == 2 then
                RankingPopupController.currentRankingType = 2
            elseif self.subSelectedTab_ == 3 then
                RankingPopupController.currentRankingType = 3
            elseif self.subSelectedTab_ == 4 then
                RankingPopupController.currentRankingType = 4
            end
            self:requestRankingData_()
            self.view_:setLoading(true)
        end
    end
end

function RankingPopupController:onSubTabChange(selectedTab)
    self.subSelectedTab_ = selectedTab
    if self.mainSelectedTab_ == 1 and self.friendData_ then
        -- 好友排行
        if self.subSelectedTab_ == 1 then
            -- 资产排行
            table.sort(self.friendData_, function(o1, o2)
                return checkint(o1.money) > checkint(o2.money)
            end)
            RankingPopupController.currentRankingType = 1
            self.view_:setListData(self.friendData_)
        elseif self.subSelectedTab_ == 2 then
            -- 等级排行
            table.sort(self.friendData_, function(o1, o2)
                return checkint(o1.exp) > checkint(o2.exp)
            end)
            RankingPopupController.currentRankingType = 2           
            self.view_:setListData(self.friendData_)


        elseif self.subSelectedTab_ == 3 then
             table.sort(self.friendData_, function(o1, o2)
                return checkint(o1.point) > checkint(o2.point)
            end)
            RankingPopupController.currentRankingType = 4           
            self.view_:setListData(self.friendData_)
        end
    elseif self.mainSelectedTab_ == 2 and self.rankingData_ then
        -- 总排行
        if self.subSelectedTab_ == 1 then
            -- 资产排行
            RankingPopupController.currentRankingType = 1
            self.view_:setListData(self.rankingData_.money)
        elseif self.subSelectedTab_ == 2 then
            -- 等级排行
            RankingPopupController.currentRankingType = 2
            self.view_:setListData(self.rankingData_.level)
        
        elseif self.subSelectedTab_ == 3 then
            --盈利排行
            RankingPopupController.currentRankingType = 3
            self.view_:setListData(self.rankingData_.winMoney)
        elseif self.subSelectedTab_ == 4 then
            --现金币排行
            RankingPopupController.currentRankingType = 4
            self.view_:setListData(self.rankingData_.point)
        end
    elseif self.mainSelectedTab_ == 1 then
        if self.subSelectedTab_ == 1 then
            RankingPopupController.currentRankingType = 1
        elseif self.subSelectedTab_ == 2 then
            RankingPopupController.currentRankingType = 2
        elseif self.subSelectedTab_ == 3 then
            RankingPopupController.currentRankingType = 4
        end
    elseif self.mainSelectedTab_ == 2 then
        if self.subSelectedTab_ == 1 then
            RankingPopupController.currentRankingType = 1
        elseif self.subSelectedTab_ == 2 then
            RankingPopupController.currentRankingType = 2
        elseif self.subSelectedTab_ == 3 then
            RankingPopupController.currentRankingType = 3
        elseif self.subSelectedTab_ == 4 then
            RankingPopupController.currentRankingType = 4
        end
    end
    
end

-- 获取好友列表
function RankingPopupController:requestFriendData_()
    if not self.friendData_ then
        self.friendDataRequestId_ = nk.http.getHallFriendList(
        handler(self, self.onGetFriendData_), 
        function ()
            self.friendDataRequestId_ = nil
            requestRetryTimes_ = requestRetryTimes_ - 1
            if requestRetryTimes_ > 0 then
                self.friendDataRequestScheduleHandle_ = scheduler.performWithDelayGlobal(handler(self, self.requestFriendData_), 1)
            else
                nk.ui.Dialog.new({
                    messageText = bm.LangUtil.getText("COMMON", "REQUEST_DATA_FAIL"), 
                    secondBtnText = bm.LangUtil.getText("COMMON", "RETRY"), 
                    callback = function (type)
                        if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                            self:requestFriendData_()
                        end
                    end
                })
                    :show()
            end
        end
       )
    end
end

function RankingPopupController:onGetFriendData_(data)
    self.friendDataRequestId_ = nil
    if data then
        self.friendData_ = data
        -- 获取数据后，把自己的数据添加进去
        local selfData = {
            name = nk.userData["aUser.name"], 
            micon = nk.userData["aUser.micon"], 
            money = nk.userData["aUser.money"], 
            exp = nk.userData["aUser.exp"]
        }
        table.insert(self.friendData_, selfData)
        if self.mainSelectedTab_ == 1 then
            if self.subSelectedTab_ == 1 then
               table.sort(self.friendData_, function (a, b) return checkint(a.money) > checkint(b.money) end)
                self.view_:setListData(self.friendData_)
            else
                table.sort(self.friendData_, function (a, b) return checkint(a.exp) > checkint(b.exp) end)
                self.view_:setListData(self.friendData_)
            end
            
            self.view_:setLoading(false)
        end
    else
        self.friendDataRequestScheduleHandle_ = scheduler.performWithDelayGlobal(handler(self, self.requestFriendData_), 2)
    end
end

-- 获取总排行榜数据
function RankingPopupController:requestRankingData_()
    if not self.rankingData_ then
       self.rankingDataRequestId_ = nk.http.getAllServerRank(
            handler(self, self.onGetRankingData_),
            function ()
                self.rankingDataRequestId_ = nil
                requestRetryTimes_ = requestRetryTimes_ - 1
                if requestRetryTimes_ > 0 then
                    self.rankingDataRequestScheduleHandle_ = scheduler.performWithDelayGlobal(handler(self, self.requestRankingData_), 2)
                else
                    nk.ui.Dialog.new({
                        messageText = bm.LangUtil.getText("COMMON", "REQUEST_DATA_FAIL"), 
                        secondBtnText = bm.LangUtil.getText("COMMON", "RETRY"), 
                        callback = function (type)
                            if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                                self:requestRankingData_()
                            end
                        end
                    })
                        :show()
                end
            end
        )
   end
end

function RankingPopupController:onGetRankingData_(data)
    self.rankingDataRequestId_ = nil
    -- dump(data, "nk.http.getAllServerRank.data :==================")

    if data then
        self.rankingData_ = data
        if self.mainSelectedTab_ == 2 then
            if self.subSelectedTab_ == 1 then
                self.view_:setListData(self.rankingData_.money)
            elseif self.subSelectedTab_ == 2 then
                self.view_:setListData(self.rankingData_.level)
            else
                self.view_:setListData(self.rankingData_.winMoney)
            end
             self.view_:setLoading(false)
        end
    else
        self.rankingDataRequestScheduleHandle_ = scheduler.performWithDelayGlobal(handler(self, self.requestRankingData_), 2)
    end
end

function RankingPopupController:dispose()

    if self.friendDataRequestId_ then
        nk.http.cancel(self.friendDataRequestId_)
        self.friendDataRequestId_ = nil
    end
    if self.rankingDataRequestId_ then
        nk.http.cancel(self.rankingDataRequestId_)
        self.rankingDataRequestId_ = nil
    end
    
    
    if self.friendDataRequestScheduleHandle_ then
        scheduler.unscheduleGlobal(self.friendDataRequestScheduleHandle_)
    end
    if self.rankingDataRequestScheduleHandle_ then
        scheduler.unscheduleGlobal(self.rankingDataRequestScheduleHandle_)
    end
end

return RankingPopupController