--
-- Author: johnny@boomegg.com
-- Date: 2014-08-31 20:13:50
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

local FriendPopupController = class("FriendPopupController")
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")

function FriendPopupController:ctor(view)
    self.view_ = view
end

function FriendPopupController:onMainTabChange(selectedTab)
    self.mainSelectedTab_ = selectedTab
    requestRetryTimes_ = 2
    if self.mainSelectedTab_ == 1 then
        if (not self.friendData_) or ( #self.friendData_ == 0 and nk.userData.friendUidList and #nk.userData.friendUidList > 0) then
            self.friendData_ = nil
            self.view_:setNoDataTip(true)
            self:requestFriendData_()
            self.view_:setLoading(true)
            self.view_:setNoDataTip(false)
        else
            if  #self.friendData_ > 0 then    
                self.view_:setListData(self.friendData_)
            else
                self.view_:setNoDataTip(true)
            end
        end
    end
end

function FriendPopupController:getDelFriendData()
    self.mainSelectedTab_  = 0
    requestRetryTimes_ = 2
    self:requestDelFriendData_()
    self.view_:setLoading(true)
    self.view_:setDelListNoDataTip(false)
end

-- 获取好友列表
function FriendPopupController:requestFriendData_()
    if not self.friendData_ then

    self.friendDataRequestId_ = nk.http.getHallFriendList(
        handler(self, self.onGetFriendData_), 
        function ()
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

function FriendPopupController:onGetFriendData_(data)
    if self.view_ and self.view_.setLoading then
        --todo
        self.view_:setLoading(false)
    end
    -- dump(data, "FriendPopupController:onGetFriendData_.data :===================")

    if data then
        self.friendData_ = data

        local uidList = {}
        for i, v in ipairs(self.friendData_) do
            uidList[#uidList + 1] = v.fid
        end

        nk.userData.friendUidList = uidList
        if self.mainSelectedTab_ == 1 then
            if #self.friendData_ > 0 then
                self.view_:setListData(self.friendData_)
            else
                self.view_:setNoDataTip(true)
            end
        end
    else
        self.friendDataRequestScheduleHandle_ = scheduler.performWithDelayGlobal(handler(self, self.requestFriendData_), 2)
    end
end

function FriendPopupController:sendChip(friendListItem)

    -- dump(friendListItem:getData().fid,"friendid")
    self.sendChipRequestId_ = nk.http.sendCoinForFriend(friendListItem:getData().fid,
        function (data)
            self:onSendChip_(data, friendListItem)
        end, 
        function (errorData)
            local retData = errorData;
            if retData.errorCode then
                if retData.errorCode == -5 then
                    -- 金币不够
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("FRIEND", "SEND_CHIP_TOO_POOR"))
                elseif retData.errorCode == -2 then
                    -- 赠送次数用完
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("FRIEND", "SEND_CHIP_COUNT_OUT"))
                elseif retData.errorCode == -3 then 
                    --赠送失败

                elseif retData.errorCode == -4 then
                    --好友接受失败

                else
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
                end
            end
        end
    )

end

function FriendPopupController:onSendChip_(data, friendListItem)
    if data then
        nk.userData["aUser.money"] = checkint(data.remainMoney);
         -- 赠送成功
        friendListItem:onSendChipSucc()
    else
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
    end
end


function FriendPopupController:requestDelFriendData_()
        self.delFriendDataRequestId_ = nk.http.getDeleteFriendsList(handler(self, self.onGetDelFriendData_),
            function ()
                requestRetryTimes_ = requestRetryTimes_ - 1
                if requestRetryTimes_ > 0 then
                    self.delFriendDataRequestScheduleHandle_ = scheduler.performWithDelayGlobal(handler(self, self.requestDelFriendData_), 1)
                else
                    nk.ui.Dialog.new({
                        messageText = bm.LangUtil.getText("COMMON", "REQUEST_DATA_FAIL"), 
                        secondBtnText = bm.LangUtil.getText("COMMON", "RETRY"), 
                        callback = function (type)
                            if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                                self:requestDelFriendData_()
                            end
                        end
                    }):show()
                end
             end
        ) 
end

function FriendPopupController:onGetDelFriendData_(data)   
    --[{"uid":"10105","s_picture":"https:\/\/graph.facebook.com\/787488638025887\/picture","sex":"m","nick":"Zhang Mike","money":650500}]
    if data then
        local retData = data;
        if retData then
            self.delFriendData_ = retData;
            if self.mainSelectedTab_ == 0 then
                if #self.delFriendData_ > 0 then
                    self.view_:setDelListData(self.delFriendData_)
                else
                    self.view_:setDelListNoDataTip(true)
                end
                self.view_:setLoading(false)
            end
        else
            self.view_:setDelListNoDataTip(true)
            self.view_:setLoading(false)
        end
    else
        self.friendDataRequestScheduleHandle_ = scheduler.performWithDelayGlobal(handler(self, self.requestDelFriendData_), 2)
    end
end

function FriendPopupController:restoreFriend(friendListItem)
    local fuid = friendListItem:getData().fid;

    nk.http.recoveryFriends(fuid,
        function()
                if nk.userData.friendUidList and not table.indexof(nk.userData.friendUidList, fuid) then
                table.insert(nk.userData.friendUidList, fuid)                
                end
                self:restoreFriendSuccess_(friendListItem)
            end,
        function ()
             nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "ADD_FRIEND_FAILED_MSG"))
        end
    )
end

function FriendPopupController:restoreFriendSuccess_(friendListItem)
    if friendListItem:getOwner() then
        local list2 = friendListItem:getOwner()
        local data2 = list2:getData()
        local itemData2 = data2[friendListItem:getIndex()]
        table.remove(data2, friendListItem:getIndex())
        list2:setData(nil)
        list2:setData(data2)
    end
end

function FriendPopupController:sendFriendFlower(friendListItem)
    dump(friendListItem:getData().fid,"friendid")
    local fuid = friendListItem:getData().fid;
    nk.http.sendFlowerForFriend(fuid,
        function(data)
            nk.TopTipManager:showTopTip("ส่งดอกมะลิให้เพื่อนสำเร็จ  คุณถูกหักดอกมะลิ -10 ดอก");
            friendListItem:onSendFlowerSucc()
        end,
        function(errorData)
            if errorData and errorData.errorCode then
                if errorData.errorCode == -2 then
                    nk.TopTipManager:showTopTip("ดอกมะลิของคุณไม่ถึง 10 ดอก ไม่สามารถส่งได้ค่ะ")  
                elseif errorData.errorCode==0 then
                    nk.TopTipManager:showTopTip("วันนี้ส่งแล้ว")
                else
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "REQUEST_DATA_FAIL"))
                end
            end
        end

    )
end

function FriendPopupController:dispose()
    nk.http.cancel(self.friendDataRequestId_)
    nk.http.cancel(self.delFriendDataRequestId_)
    nk.http.cancel(self.sendChipRequestId_)
    if self.friendDataRequestScheduleHandle_ then
        scheduler.unscheduleGlobal(self.friendDataRequestScheduleHandle_)
    end
    if self.delFriendDataRequestScheduleHandle_ then
        scheduler.unscheduleGlobal(self.delFriendDataRequestScheduleHandle_)
    end
end

return FriendPopupController