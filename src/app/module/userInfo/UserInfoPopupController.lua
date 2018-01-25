--
-- Author: johnny@boomegg.com
-- Date: 2014-09-05 10:57:15
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

local UserInfoPopupController = class("UserInfoPopupController")

function UserInfoPopupController:ctor(view)
    self.view_ = view
end

function UserInfoPopupController:getHddjNum(callback)
    -- if nk.userData.hddjNum then
    --     self.view_:setHddjNum(nk.userData.hddjNum)
    -- else
    --获取道具数量
        nk.http.cancel(self.hddjNumRequestId_)
         
        self.hddjNumRequestId_ = nk.http.getUserProps("1,2,3,7,8",function(pdata)
            if pdata then
                for _,v in pairs(pdata) do
                    if tonumber(v.pnid) == 2001 then
                        nk.userData.hddjNum = checkint(v.pcnter)
                        break
                    end
                end
                if callback then 
                    callback(pdata)
                end
                -- dump(pdata, "getUserProps.data :============")

                self.view_:setPropsData(pdata)
            end
        
        end, function()   
        
        end)
    --end
end

function UserInfoPopupController:getMyGiftData()
    -- body
    if self.myGiftDataRequesting_ then return end
    local retryTimes = 3

    local request = function()
        self.myGiftDataRequesting_ = true
        self.myGiftDataRequestId_ = nk.http.giftMineInfo("0,2,3,4", handler(self, self.onMyGiftDataGet),
        function()
            -- self.myGiftDataRequestId_ = nil
            retryTimes = retryTimes - 1
            if retryTimes > 0 then
                if request then
                    --todo
                    request()
                else
                    dump("err Code!")
                end
            else
                self.myGiftDataRequesting_ = false
                nk.ui.Dialog.new({
                    messageText = bm.LangUtil.getText("COMMON", "REQUEST_DATA_FAIL"), 
                    secondBtnText = bm.LangUtil.getText("COMMON", "RETRY"), 
                    callback = function (type)
                        if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                            retryTimes = 3
                            
                            if request then
                                --todo
                                request()
                            else
                                dump("err Code!")
                            end
                        end
                    end
                }):show()
            end
        end)
    end
    request()

end

--pmode:'0,1,2,3,4,5'   //道具来源，0系统 1管理员添加 2商城购买 3好友赠送 4任务获得 5使用道具获得
function UserInfoPopupController:onMyGiftDataGet(data)
    -- body
    self.myGiftDataRequesting_ = false
    -- self.myGiftDataRequestId_ = nil

    local selfBuyGiftData = {}
    local friendPresentData = {}
    local systemPresentData = {}

    self._myGiftData = {}

    -- dump(data, "myGiftData :===============")
    if data then

        for i = 1, #data do

            local giftData = {}
            giftData._giftId = tonumber(data[i].pnid)
            giftData._giftDeadTime = data[i].day

            if checkint(data[i].pmode) == 2 then
                table.insert(selfBuyGiftData, giftData)

            elseif checkint(data[i].pmode) == 3 then
                table.insert(friendPresentData, giftData)

            elseif checkint(data[i].pmode) == 0 or checkint(data[i].pmode) == 4 then
                table.insert(systemPresentData, giftData)
            end
        end
    end


    self._myGiftData[1] = selfBuyGiftData
    self._myGiftData[2] = friendPresentData
    self._myGiftData[3] = systemPresentData

    self.view_:setLoading(false)

    -- local gotoTabIdx = 1

    -- if self._giftSubTabIndex then
    --     --todo
    -- end
    self.view_._myGiftListView:setData(self._myGiftData[self._giftSubTabIndex])

    if #self._myGiftData[self._giftSubTabIndex] <= 0 then
        --todo
        self.view_._noGiftOnShownTxt:show()
    else
        self.view_._noGiftOnShownTxt:hide()
    end
end

function UserInfoPopupController:onGiftSubTabChanged(tabId)
    -- body
    self._giftSubTabIndex = tabId
    if self.view_._myGiftListView then
        --todo
        self.view_._myGiftListView:setData(self._myGiftData[tabId])

        if #self._myGiftData[self._giftSubTabIndex] <= 0 then
        --todo
            self.view_._noGiftOnShownTxt:show()
        else
            self.view_._noGiftOnShownTxt:hide()
        end
    end
    
end

function UserInfoPopupController:setWareGiftId(giftId)
    -- body
    self._giftWaredId = giftId
end

function UserInfoPopupController:wareGiftBySelectedId(isInRoom)
    -- body
    if self._giftWaredId ~= nk.userData["aUser.gift"] then
        --todo
        nk.http.useProps(nk.userData["aUser.gift"], function(data)
            -- local callBackBuyData =  json.decode(data)
            -- dump(data,"data:===============")
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("GIFT", "SET_GIFT_SUCCESS_TOP_TIP"))

            self._giftWaredId = nk.userData["aUser.gift"]
            -- nk.userData["aUser.gift"] = self._giftWaredId
            if isInRoom then
                nk.server:updateRoomGift(nk.userData["aUser.gift"], nk.userData.uid)
            end
        end,function()
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("GIFT", "SET_GIFT_FAIL_TOP_TIP"))
            self._giftWaredId = nil
        end)
    end
end

function UserInfoPopupController:dispose()
    nk.http.cancel(self.hddjNumRequestId_)

    if self.myGiftDataRequestId_ then
        --todo
        nk.http.cancel(self.myGiftDataRequestId_)
    end
end

return UserInfoPopupController