--
-- Author: tony
-- Date: 2014-08-04 11:30:13
--

local WIDTH = 600
local HEIGHT = 450
local LEFT = -WIDTH * 0.5
local TOP = HEIGHT * 0.5
local RIGHT = WIDTH * 0.5
local BOTTOM = -HEIGHT * 0.5

-- local StorePopup = import("app.module.newstore.StorePopup")
local GiftStorePopup = import("app.module.newstore.GiftStorePopup")
local UserInfoOtherDialog = class("UserInfoOtherDialog", function() return nk.ui.Panel.new({WIDTH, HEIGHT}) end)

function UserInfoOtherDialog:ctor(ctx)
    self:setNodeEventEnabled(true)
    self.ctx = ctx
    --头像背景
    self.headImgMaleBg_ = display.newScale9Sprite("#user_info_avatar_bg.png", LEFT + 12 + 60, TOP - 12 - 60, cc.size(116, 116)):addTo(self)
    self.headImgFemaleBg_ = display.newScale9Sprite("#user_info_avatar_bg.png", LEFT + 12 + 60, TOP - 12 - 60, cc.size(116, 116)):addTo(self):hide()
    --头像剪裁容器
    self.headImageLoaderId_ = nk.ImageLoader:nextLoaderId()
    self.headImgContainer_ = cc.ClippingNode:create()
    local stencil = display.newDrawNode()
    local pn = {{-50, -50}, {-50, 50}, {50, 50}, {50, -50}}  
    local clr = cc.c4f(255, 0, 0, 255)  
    stencil:drawPolygon(pn, clr, 1, clr)
    self.headImgContainer_:setStencil(stencil)
    self.headImgContainer_:pos(self.headImgMaleBg_:getPositionX(), self.headImgMaleBg_:getPositionY())
    self.headImgContainer_:addTo(self)

    --性别图标背景
    self.sexMaleBg_ = display.newSprite("#male_icon_with_bg.png"):pos(LEFT + 168, TOP - 42):addTo(self):hide()
    self.sexFemaleBg_ = display.newSprite("#female_icon_with_bg.png"):pos(LEFT + 168, TOP - 42):addTo(self):hide()
    self.sexMale_ = display.newSprite("#icon_male.png", self.sexMaleBg_:getPositionX(), self.sexMaleBg_:getPositionY()):addTo(self):hide()
    self.sexFemale_ = display.newSprite("#icon_female.png", self.sexMaleBg_:getPositionX(), self.sexMaleBg_:getPositionY()):addTo(self):hide()

    --筹码图标
    self.chipIcon_ = display.newSprite("#chip_icon.png", LEFT + 164, TOP - 100):addTo(self)
    --等级图标
    self.levelIcon_ = display.newSprite("#level_icon.png", LEFT + 415, TOP - 100):addTo(self)

    --互动道具背景
    self.hddjBg_ = display.newScale9Sprite("#panel_overlay.png", 0, BOTTOM + 12 + 86, cc.size(WIDTH - 24, 172))
    self.hddjBg_:addTo(self)

    --赠送筹码背景
    self.sendChipsBg_ = display.newScale9Sprite("#user_info_other_send_chip_title_bg.png", LEFT + 12, TOP - 226, cc.size(128, 44)):addTo(self)
    self.sendChipsBg_:setAnchorPoint(cc.p(0, 0.5))

    --加好友按钮
    self.isAddFriend_ = true
    self.addFriendBtn_ = cc.ui.UIPushButton.new({
                normal="#common_green_btn_up.png",
                pressed="#common_green_btn_down.png",
                disabled="#common_btn_disabled.png",
            }, {scale9=true})
        :setButtonSize(122, 47)
        :setButtonLabel(display.newTTFLabel({text=bm.LangUtil.getText("ROOM", "ADD_FRIEND"), size=22, color=cc.c3b(0xFF, 0xFF, 0xFF)}))
        :onButtonClicked(buttontHandler(self, self.onFriendClicked_))
        :pos(LEFT + 12 + 60, self.headImgMaleBg_:getPositionY() - 12 - 60 - 24)
        :setButtonEnabled(false)
        :addTo(self)

    --赠送筹码标签
    self.sendChipLabel_ = display.newTTFLabel({text=bm.LangUtil.getText("ROOM", "INFO_SEND_CHIPS"),size=24, color=cc.c3b(0xce, 0xe8, 0xff)})
    self.sendChipLabel_:pos(LEFT + 12 + 60, TOP - 226)
    self.sendChipLabel_:addTo(self)

    --绿色筹码按钮1

    local roomData = nk.getRoomDataByLevel(self.ctx.model.roomInfo.roomType)
    if not roomData and self.ctx.model.roomInfo.roomType == consts.ROOM_TYPE.PERSONAL_NORMAL then
        local roomInfo = self.ctx.model.roomInfo
        roomData = {}
        roomData.minBuyIn = roomInfo.minBuyIn
        roomData.maxBuyIn = roomInfo.maxBuyIn
        roomData.roomType = roomInfo.roomType
        roomData.blind = roomInfo.blind
        roomData.sendChips = {500,2000,5000,20000}
    end
    -- dump(roomData,"roomDatatata",10)

    self.sendChipBtn1_ = cc.ui.UIPushButton.new("#chip_big_green.png")
        :setButtonLabel(display.newTTFLabel({text=""..bm.formatBigNumber(roomData.sendChips[1]), size=24, color=cc.c3b(0xff, 0xd5, 0x31)}))
        :setButtonLabelOffset(0, -2)
        :onButtonPressed(function(event) end)
        :onButtonRelease(function(event) end)
        :onButtonClicked(function(event)
                nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
                self:sendChipClicked_(roomData.sendChips[1])
            end)
        :pos(LEFT + 200, TOP - 226)
        :addTo(self)

    --绿色筹码按钮2
    self.sendChipBtn2_ = cc.ui.UIPushButton.new("#chip_big_green.png")
        :setButtonLabel(display.newTTFLabel({text=""..bm.formatBigNumber(roomData.sendChips[2]), size=24, color=cc.c3b(0xff, 0xd5, 0x31)}))
        :setButtonLabelOffset(0, -2)
        :onButtonPressed(function(event) end)
        :onButtonRelease(function(event) end)
        :onButtonClicked(function(event)
                nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
                self:sendChipClicked_(roomData.sendChips[2])
            end)
        :pos(LEFT + 200 + 102, TOP - 226)
        :addTo(self)

    --红色筹码按钮1
    self.sendChipBtn3_ = cc.ui.UIPushButton.new("#chip_big_red.png")
        :setButtonLabel(display.newTTFLabel({text=""..bm.formatBigNumber(roomData.sendChips[3]), size=24, color=cc.c3b(0xff, 0xd5, 0x31)}))
        :setButtonLabelOffset(0, -2)
        :onButtonPressed(function(event) end)
        :onButtonRelease(function(event) end)
        :onButtonClicked(function(event)
                nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
                self:sendChipClicked_(roomData.sendChips[3])
            end)
        :pos(LEFT + 200 + 102 * 2, TOP - 226)
        :addTo(self)

    --红色筹码按钮2
    self.sendChipBtn4_ = cc.ui.UIPushButton.new("#chip_big_red.png")
        :setButtonLabel(display.newTTFLabel({text=""..bm.formatBigNumber(roomData.sendChips[4]), size=24, color=cc.c3b(0xff, 0xd5, 0x31)}))
        :setButtonLabelOffset(0, -2)
        :onButtonPressed(function(event) end)
        :onButtonRelease(function(event) end)
        :onButtonClicked(function(event)
                nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
                self:sendChipClicked_(roomData.sendChips[4])
            end)
        :pos(LEFT + 200 + 102 * 3, TOP - 226)
        :addTo(self)

    -- ios 审核 isSendChips 为0 是下掉，isSendChips 为1 是打开
    -- if nk.userData.isSendChips and nk.userData.isSendChips == 0 then
        self.sendChipsBg_:opacity(0)
        self.sendChipLabel_:opacity(0)
        self.sendChipBtn1_:opacity(0)
        self.sendChipBtn2_:opacity(0)
        self.sendChipBtn3_:opacity(0)
        self.sendChipBtn4_:opacity(0)

        self.sendChipBtn1_:setButtonEnabled(false)
        self.sendChipBtn2_:setButtonEnabled(false)
        self.sendChipBtn3_:setButtonEnabled(false)
        self.sendChipBtn4_:setButtonEnabled(false)
    -- end

    --昵称
    self.nick_ = display.newTTFLabel({text = "",size=24, color=cc.c3b(0xce, 0xe8, 0xff)})
    self.nick_:setAnchorPoint(cc.p(0, 0.5))
    self.nick_:pos(LEFT + 205, TOP - 42)
    self.nick_:addTo(self)
    --UID
    self.uid_ = display.newTTFLabel({text = "",size=24, color=cc.c3b(0xce, 0xe8, 0xff)})
    self.uid_:setAnchorPoint(cc.p(0, 0.5))
    self.uid_:pos(LEFT + 405, TOP - 42)
    self.uid_:addTo(self)
    --筹码
    self.chip_ = display.newTTFLabel({text = "",size=24, color=cc.c3b(0xff, 0xd5, 0x31)})
    self.chip_:setAnchorPoint(cc.p(0, 0.5))
    self.chip_:pos(LEFT + 186, TOP - 30 - 36 * 2)
    self.chip_:addTo(self)

    --等级
    self.level_ = display.newTTFLabel({text = "",size=24, color=cc.c3b(0xce, 0xe8, 0xff)})
    self.level_:setAnchorPoint(cc.p(0, 0.5))
    self.level_:pos(LEFT + 444, TOP - 30 - 36 * 2)
    self.level_:addTo(self)

    --排名
    self.ranking_ = display.newTTFLabel({text = "",size=24, color=cc.c3b(0xce, 0xe8, 0xff)})
    self.ranking_:setAnchorPoint(cc.p(0, 0.5))
    self.ranking_:pos(LEFT + 150, TOP - 42 - 36 * 3)
    self.ranking_:addTo(self)

    --胜率
    self.winRate_ = display.newTTFLabel({text = "",size=24, color=cc.c3b(0xce, 0xe8, 0xff)})
    self.winRate_:setAnchorPoint(cc.p(0, 0.5))
    self.winRate_:pos(LEFT + 370, TOP - 42 - 36 * 3)
    self.winRate_:addTo(self)

    local x, y = LEFT + 80, BOTTOM + 134
    for i = 1, 2 do
        for j = 1, 5 do
            local id = (i - 1) * 5 + j
            if id <= 2 and nk.OnOff:check("loyKraThongAct") then
                --todo
                id = 20 + id
            end

            local btn = cc.ui.UIPushButton.new({normal="#transparent.png", normal = "#user_info_other_hddj_item_up_bg.png",pressed="#user_info_other_hddj_item_down_bg.png"}, {scale9=true})
                :setButtonSize(80, 60)
                :onButtonClicked(function()
                        nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
                        self:sendHddjClicked_(id)
                    end)
                :pos(x, y)
                :addTo(self)
            if id == 1 then
                btn:setButtonLabel(display.newSprite("#hddj_egg_icon.png"))
            elseif id == 10 then
                btn:setButtonLabel(display.newSprite("#hddj_tissue_icon.png"):scale(1.1))
            elseif id == 4 then
                btn:setButtonLabel(display.newSprite("#hddj_kiss_lip_icon.png"):scale(1.3))
            elseif id == 5 then
                btn:setButtonLabel(display.newSprite("#hddj_" .. id .. ".png"):scale(0.75))
            elseif id == 6 then
                btn:setButtonLabel(display.newSprite("#hddj_" .. id .. ".png"):scale(0.5))
            elseif id == 7 then
                btn:setButtonLabel(display.newSprite("#hddj_" .. id .. ".png"):scale(1.4))
            elseif id == 8 then
                btn:setButtonLabel(display.newSprite("#hddj_" .. id .. ".png"):scale(0.9))
            elseif id > 20 then
                --todo
                btn:setButtonLabel(display.newSprite("#hddj_" .. id .. ".png"))
            else
                btn:setButtonLabel(display.newSprite("#hddj_" .. id .. ".png"):scale(0.6))
            end
            x = x + 110
        end
        x = LEFT + 82
        y = y - 75
    end

    self:loadFriendUidList()
end

function UserInfoOtherDialog:getFriendDataByUid(friendUid)
    -- body
    for i = 1, #self.friendDataList_ do
        if tonumber(self.friendDataList_[i].fid) == tonumber(friendUid) then
            --todo
            return self.friendDataList_[i]
        end
    end
end

function UserInfoOtherDialog:loadFriendUidList()

    -- dump(nk.userData.friendUidList, "nk.userData.friendUidList:=================")
    if nk.userData.friendUidList then
        --todo
        nk.userData.friendUidList = nil
    end

    self.addFriendBtn_:setButtonEnabled(false)
    self.getHallFriendRequestId_ = nk.http.getHallFriendList(function(data)

        self.friendDataList_ = data
        -- dump(data, "nk.http.getHallFriendList.data :=================")
        local uidList = {}
        local arr = data
        if arr then
            for i, v in ipairs(arr) do
                uidList[#uidList + 1] = tostring(v.fid)
            end
        end
        nk.userData.friendUidList = uidList
        self:setAddFriendStatus()
    end, function(errData)
        dump(errData, "nk.http.getHallFriendList.errData :=================")
    end)
end

function UserInfoOtherDialog:show(data)
    self:setData(data)
    self:showPanel_(true, true, true, true)
end

function UserInfoOtherDialog:hide()
    if self.hddjNumObserverId_ then
        bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "hddjNum", self.hddjNumObserverId_)
        self.hddjNumObserverId_ = nil
    end
    nk.ImageLoader:cancelJobByLoaderId(self.headImageLoaderId_)
    self:hidePanel_()
end

function UserInfoOtherDialog:setAddFriendStatus()
    if self.data_ and nk.userData.friendUidList then
        self.addFriendBtn_:setButtonEnabled(true)
        if not table.indexof(nk.userData.friendUidList, tostring(self.data_.uid)) then
            self.addFriendBtn_:setButtonImage("normal", "#common_green_btn_up.png", true)
            self.addFriendBtn_:setButtonImage("pressed", "#common_green_btn_down.png", true)
            self.addFriendBtn_:setButtonLabelString(bm.LangUtil.getText("ROOM", "ADD_FRIEND"))
            self.isAddFriend_ = true
        else
            local friendData = self:getFriendDataByUid(self.data_.uid)

            if checkint(friendData.isFBfriend or 0) == 1 then
                --todo
                self.isAddFriend_ = false
                self.addFriendBtn_:setButtonEnabled(false)
                self.addFriendBtn_:hide()
            else
                self.addFriendBtn_:setButtonImage("normal", "#common_red_btn_up.png", true)
                self.addFriendBtn_:setButtonImage("pressed", "#common_red_btn_down.png", true)
                self.addFriendBtn_:setButtonLabelString(bm.LangUtil.getText("ROOM", "DEL_FRIEND"))
                self.isAddFriend_ = false
            end
        end
    end
end

function UserInfoOtherDialog:setData(data)
    self.data_ = data
    if data then
        -- dump(data, "UserInfoOtherDialog:setData.data :====================")
        self.uid_:setString(bm.LangUtil.getText("ROOM", "INFO_UID", data.userId or data.uid))

        self.reqGetUserInfoData_ = nk.http.getMemberInfo(data.userId or data.uid, function(retData)
            -- body
            -- dump(retData, "(UserInfoOtherDialog)nk.http.getMemberInfo.retData :==================")
            self.nick_:setString(nk.Native:getFixedWidthText("", 24, retData.aUser.name or nk.userData["aUser.name"] or data.userInfo.name,
                150))
            self.chip_:setString(bm.formatBigNumber(retData.aUser.money or nk.userData["aUser.money"] or data.userInfo.money or 0))
            self.level_:setString(bm.LangUtil.getText("ROOM", "INFO_LEVEL", retData.aUser.mlevel or nk.userData["aUser.mlevel"] or
                data.userInfo.mlevel or nk.Level:getLevelByExp(data.userInfo.mexp)))

            local winRateCalReq = retData.aUser.win + retData.aUser.lose > 0 and math.round(retData.aUser.win * 100 / (retData.aUser.win + retData.aUser.lose))
            local winRateCalData = data.userInfo.mwin +  data.userInfo.mlose > 0 and math.round(data.userInfo.mwin * 100 / (data.userInfo.mwin + data.userInfo.mlose))
            self.winRate_:setString(bm.LangUtil.getText("ROOM", "INFO_WIN_RATE", winRateCalReq or winRateCalData or 0))

            local rankMoney =  retData.aBest.rankMoney or nk.userData["aBest.rankMoney"] or 0
            if rankMoney then
                --todo
                if rankMoney > 10000 then
                    --todo
                    self.ranking_:setString(bm.LangUtil.getText("ROOM", "INFO_RANKING", ">10,000"))
                else
                    self.ranking_:setString(bm.LangUtil.getText("ROOM", "INFO_RANKING", bm.formatNumberWithSplit(rankMoney or 0)))
                end
            else
                if data.userInfo.rankMoney then
                    --todo
                    if data.userInfo.rankMoney > 10000 then
                        --todo
                        self.ranking_:setString(bm.LangUtil.getText("ROOM", "INFO_RANKING", ">10,000"))
                    else
                        self.ranking_:setString(bm.LangUtil.getText("ROOM", "INFO_RANKING", bm.formatNumberWithSplit(data.userInfo.rankMoney or 0)))
                    end
                else
                    self.ranking_:setString(bm.LangUtil.getText("ROOM", "INFO_RANKING", ".."))
                end
            end

            local mUserSex = retData.aUser.msex or nk.userData["aUser.msex"] or data.userInfo.msex or 0
            if checkint(mUserSex) == 2 or checkint(mUserSex) == 0 then
                --todo
                self.sexMale_:hide()
                self.sexMaleBg_:hide()
                self.sexFemale_:show()
                self.sexFemaleBg_:show()
                self.headImgFemaleBg_:show()
                self:setImage_(display.newSprite("#common_female_avatar.png"))
            else
                self.sexMale_:show()
                self.sexMaleBg_:show()
                self.sexFemale_:hide()
                self.sexFemaleBg_:hide()
                self.headImgFemaleBg_:hide()
                self:setImage_(display.newSprite("#common_male_avatar.png"))
            end

            local userImgUrl = retData.aUser.micon or nk.userData["aUser.micon"] or data.userInfo.mavatar or ""
            if string.find(userImgUrl, "facebook") then
                if string.find(userImgUrl, "?") then
                    userImgUrl = userImgUrl .. "&width=100&height=100"
                else
                    userImgUrl = userImgUrl .. "?width=100&height=100"
                end
            end

            nk.ImageLoader:loadAndCacheImage(self.headImageLoaderId_, userImgUrl, handler(self, self.imageLoadCallback_),
                nk.ImageLoader.CACHE_TYPE_USER_HEAD_IMG)
        end, function(errData)
            -- body
            -- dump(errData, "(UserInfoOtherDialog)nk.http.getMemberInfo.errData :==================")
            self.reqGetUserInfoData_ = nil
            self.nick_:setString(nk.Native:getFixedWidthText("", 24, data.userInfo.name, 150))
            self.chip_:setString(bm.formatBigNumber(data.userInfo.money or 0))
            self.level_:setString(bm.LangUtil.getText("ROOM", "INFO_LEVEL", data.userInfo.mlevel or nk.Level:getLevelByExp(data.userInfo.mexp)))
            self.winRate_:setString(bm.LangUtil.getText("ROOM", "INFO_WIN_RATE", data.userInfo.mwin +  data.userInfo.mlose > 0 and math.round(data.userInfo.mwin * 100 / (data.userInfo.mwin + data.userInfo.mlose)) or 0))
            if data.userInfo.rankMoney then
                if data.userInfo.rankMoney > 10000 then
                    self.ranking_:setString(bm.LangUtil.getText("ROOM", "INFO_RANKING", ">10,000"))
                else
                    self.ranking_:setString(bm.LangUtil.getText("ROOM", "INFO_RANKING", bm.formatNumberWithSplit(data.userInfo.rankMoney or 0)))
                end
            else
                self.ranking_:setString(bm.LangUtil.getText("ROOM", "INFO_RANKING", ".."))
            end

            if checkint(data.userInfo.msex) == 2 or checkint(data.userInfo.msex) == 0 then
                self.sexMale_:hide()
                self.sexMaleBg_:hide()
                self.sexFemale_:show()
                self.sexFemaleBg_:show()
                self.headImgFemaleBg_:show()
                self:setImage_(display.newSprite("#common_female_avatar.png"))
            else
                self.sexMale_:show()
                self.sexMaleBg_:show()
                self.sexFemale_:hide()
                self.sexFemaleBg_:hide()
                self.headImgFemaleBg_:hide()
                self:setImage_(display.newSprite("#common_male_avatar.png"))
            end

            local imgurl = data.userInfo.mavatar or ""
            if string.find(imgurl, "facebook") then
                if string.find(imgurl, "?") then
                    imgurl = imgurl .. "&width=100&height=100"
                else
                    imgurl = imgurl .. "?width=100&height=100"
                end
            end

            nk.ImageLoader:loadAndCacheImage(self.headImageLoaderId_, imgurl, handler(self, self.imageLoadCallback_),
                nk.ImageLoader.CACHE_TYPE_USER_HEAD_IMG)
        end)

    else
        self.nick_:setString("")
        self.uid_:setString(bm.LangUtil.getText("ROOM", "INFO_UID", ""))
        self.chip_:setString("")
        self.level_:setString(bm.LangUtil.getText("ROOM", "INFO_LEVEL", 1))
        self.winRate_:setString(bm.LangUtil.getText("ROOM", "INFO_WIN_RATE", 0))
        self.ranking_:setString(bm.LangUtil.getText("ROOM", "INFO_RANKING", ""))
        self.sexMale_:show()
        self.sexMaleBg_:show()
        self.sexFemale_:hide()
        self.sexFemaleBg_:hide()
        nk.ImageLoader:cancelJobByLoaderId(self.headImageLoaderId_)
    end
    -- self:setAddFriendStatus()
end

function UserInfoOtherDialog:setImage_(sprite)
    local img = self.headImgContainer_:getChildByTag(1)
    if img then
        img:removeFromParent()
    end
    local spsize = sprite:getContentSize()
    if spsize.width > spsize.height then
        sprite:scale(100 / spsize.width)
    else
        sprite:scale(100 / spsize.height)
    end
    spsize = sprite:getContentSize()
    local seatSize = self:getContentSize()
    
    sprite:pos(seatSize.width * 0.5, seatSize.height * 0.5):addTo(self.headImgContainer_, 1, 1)
end

function UserInfoOtherDialog:imageLoadCallback_(success, sprite)
    if success then
        self:setImage_(sprite)
    elseif self.data_ and (self.data_.gender == 2 or self.data_.gender == 0) then
        self:setImage_(display.newSprite("#common_female_avatar.png"))
    else
        self:setImage_(display.newSprite("#common_male_avatar.png"))
    end
end

function UserInfoOtherDialog:onFriendClicked_(evt)
    if self.isAddFriend_ then
        self:onAddFriendClicked_(evt)
    else
        self:onDelFriendClicked_(evt)
    end
end

function UserInfoOtherDialog:onAddFriendClicked_(evt)
    if self.addFriendRequistId_ then
        return
    end
    
    self.addFriendBtn_:setButtonEnabled(false)

    self.addFriendRequistId_ = nk.http.addFriend(self.data_.uid, function(data)
        -- dump(data,"#### add friend ret:")
        self.addFriendRequistId_ = nil
        if data then
            if self.ctx.model:isSelfInSeat() then
                --自己在座位，广播加好友动画
                -- nk.socket.RoomSocket:sendAddFriend(self.ctx.model:selfSeatId(), self.data_.seatId)
                if self.data_ and (self.data_.seatId) then
                    nk.server:sendAddFriend(checkint(self.data_.seatId))
                end
                
            else
                --不在座位，只播放动画，别人看不到
                self.ctx.animManager:playAddFriendAnimation(-1, checkint(self.data_.seatId))
            end
            if nk.userData.friendUidList and not table.indexof(nk.userData.friendUidList, tostring(self.data_.uid)) then
                table.insert(nk.userData.friendUidList, tostring(self.data_.uid))
            end
            self:hide()
        elseif data == "-1" then
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("FRIEND", "TOO_MANY_FRIENDS_TO_ADD_FRIEND_MSG"))
            self:setAddFriendStatus()
        else
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "ADD_FRIEND_FAILED_MSG"))
            self:setAddFriendStatus()
        end
    end, function(errData)
        self.addFriendRequistId_ = nil
        if errData and errData.errorCode then
            if errData.errorCode == -2 then
                --已经添加过该好友
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "ADD_FRIEND_FAILED_MSG"))
                self:setAddFriendStatus()

            elseif errData.errorCode == -3 then
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "ADD_FRIEND_FAILED_MSG"))
                self:setAddFriendStatus()
            elseif errData.errorCode == -4 then
                --添加好友达到上限
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("FRIEND", "TOO_MANY_FRIENDS_TO_ADD_FRIEND_MSG"))
                self:setAddFriendStatus()
            else
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "ADD_FRIEND_FAILED_MSG"))
                self:setAddFriendStatus()
            end
        else
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "ADD_FRIEND_FAILED_MSG"))
            self:setAddFriendStatus()

        end
        
    end)

end

function UserInfoOtherDialog:onDelFriendClicked_(evt)
    if self.deleteFriendRequestId_ then
        return
    end

    self.addFriendBtn_:setButtonEnabled(false)
     self.deleteFriendRequestId_ = nk.http.deleteFriend(self.data_.uid,
        function (data)
            self.deleteFriendRequestId_ = nil
            local idx = nk.userData.friendUidList and table.indexof(nk.userData.friendUidList, tostring(self.data_.uid))
            if idx then
                table.remove(nk.userData.friendUidList, idx)
             end
             self:setAddFriendStatus()
        end,
        function()
            self.deleteFriendRequestId_ = nil
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "DELE_FRIEND_FAIL_MSG"))
            self:setAddFriendStatus()
        end

    )
end

function UserInfoOtherDialog:sendChipClicked_(chips)
    if self.ctx.model:isSelfInSeat() then
        local roomData = nk.getRoomDataByLevel(self.ctx.model.roomInfo.roomType)

        if not roomData and self.ctx.model.roomInfo.roomType == consts.ROOM_TYPE.PERSONAL_NORMAL then
            local roomInfo = self.ctx.model.roomInfo
            roomData = {}
            roomData.minBuyIn = roomInfo.minBuyIn
            roomData.maxBuyIn = roomInfo.maxBuyIn
            roomData.roomType = roomInfo.roomType
            roomData.blind = roomInfo.blind
            roomData.sendChips = {500,2000,5000,20000}
        end
        
        if not roomData then
            return
        end
        
        if (nk.userData["aUser.money"] -  chips ) > roomData.minBuyIn then
            nk.http.sendCoinForRoomEx(nk.userData.uid, self.data_.uid, chips, 1, self.ctx.model.roomInfo.blind,
                function (data)
                    -- dump(data, "nk.http.sendCoinForRoom.retData :====================")

                    self.data_.userInfo.money = self.data_.userInfo.money + chips
                    nk.server:sendCoinForRoomPlayer(self.data_.seatId, chips)
                    self:hide()
                end, function (errData)
                    dump(errData, "nk.http.sendCoinForRoom.errData :====================")

                    if errData and errData.errorCode then
                        if errData.errorCode == -7 then--送得太频繁
                            nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "SEND_CHIP_TOO_OFTEN"))
                        end
                        if errData.errorCode == -6 then--金币不够
                            nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "SEND_CHIP_NOT_ENOUGH_CHIPS"))
                        end
                        if errData.errorCode == -5 then
                            nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "SEND_CHIP_NOT_ENOUGH_CHIPS"))
                        end
                    end
                end
            )
        else
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "NOT_ENOUGH_MONEY_SENDCHIPS"))
        end
    else
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "SEND_CHIP_NOT_IN_SEAT"))
    end
end

function UserInfoOtherDialog:sendHddjClicked_(hddjId)
    local roomType = self.ctx.model:roomType()
    if self.ctx.model:roomType() == consts.ROOM_TYPE.TOURNAMENT  then
        --比赛场不能发送互动道具
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "SEND_HDDJ_IN_MATCH_ROOM_MSG"))
    else
        if self.ctx.model:isSelfInSeat() then
            self.sendHddjId_ = hddjId

            if self.sendHddjId_ > 20 then
                --todo
                self:doSendLoyKraThActHddj()
            else
                if nk.userData.hddjNum and nk.userData.hddjNum > 0 then
                    self:doSendHddj()
                else
                    self.hddjNumObserverId_ = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "hddjNum", handler(self, self.doSendHddj))
                    bm.EventCenter:dispatchEvent(nk.eventNames.ROOM_LOAD_HDDJ_NUM)
                end
            end
        else
            --不在座位不能发送互动道具
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "SEND_HDDJ_NOT_IN_SEAT"))
        end
    end
end

function UserInfoOtherDialog:doSendLoyKraThActHddj()
    -- body
    local pnid = 2500 + self.sendHddjId_ - 21

    nk.http.useProps(pnid, function(retData)
        -- dump(retData, "nk.http.useProps.retData :===============")

        if retData then
            --todo
            math.randomseed(tostring(os.time()):reverse():sub(1, 6))

            self.ctx.animManager:setAnimCompleteCallback(function()
                -- body
                local utters = bm.LangUtil.getText("LOYKRATH", "NAUGHTY_UTTERS")
                local utterRandom = utters[math.random(1, 3)]
                nk.server:sendRoomChat(utterRandom)
            end)

            nk.server:sendProp(self.sendHddjId_, {self.data_.seatId}, pnid)
            self.ctx.animManager:playHddjAnimation(self.ctx.model:selfSeatId(), self.data_.seatId, self.sendHddjId_)
            self:hide()
        end
    end,function(errData)
        dump(errData, "nk.http.useProps.errData :==================")

        if errData.errorCode == - 4 then
            --todo
            nk.ui.Dialog.new({messageText = bm.LangUtil.getText("LOYKRATH", "PROP_NOT_ENOUGH"), hasFirstButton = false, 
                callback = function(type)
                    if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                    end
                end}):show()
        else
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("LOYKRATH", "PROP_USE_FAIL"))
        end
    end)
end

function UserInfoOtherDialog:doSendHddj()
    if nk.userData.hddjNum and nk.userData.hddjNum > 0 then
        if self.hddjNumObserverId_ then
            bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "hddjNum", self.hddjNumObserverId_)
            self.hddjNumObserverId_ = nil
        end
        self:sendHddjAndHide_()
    else
        self:showHddjNotEnoughDialog_()
    end
end

function UserInfoOtherDialog:sendHddjAndHide_()
    nk.userData.hddjNum = nk.userData.hddjNum - 1

    local pnid = 2001 --互动表情道具
    nk.http.useProps(pnid,function(callData)
        if callData and callData.propList and callData.propList.pcnter then
            nk.userData.hddjNum = checkint(callData.propList.pcnter)
        end
    end,function(errData)
        dump(errData, "nk.http.useProps.errData :==================")
    end)

    nk.server:sendProp(self.sendHddjId_,{self.data_.seatId},pnid)
    self.ctx.animManager:playHddjAnimation(self.ctx.model:selfSeatId(), self.data_.seatId, self.sendHddjId_)
    self:hide()

end

function UserInfoOtherDialog:showHddjNotEnoughDialog_()
    nk.ui.Dialog.new({
        messageText = bm.LangUtil.getText("ROOM", "SEND_HDDJ_NOT_ENOUGH"), 
        firstBtnText = bm.LangUtil.getText("COMMON", "CANCEL"),
        secondBtnText = bm.LangUtil.getText("COMMON", "BUY"), 
        callback = function (type)
            if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                self:hide()
                GiftStorePopup.new(2):showPanel()
            else
                self:hide()
            end
        end
    }):show()
end


function UserInfoOtherDialog:onCleanup()
    if self.addFriendRequistId_ then
        nk.http.cancel(self.addFriendRequistId_)
    end

    if self.deleteFriendRequestId_ then
        nk.http.cancel(self.deleteFriendRequestId_)
    end
    nk.http.cancel(self.getHallFriendRequestId_)

    if self.reqGetUserInfoData_ then
        --todo
        nk.http.cancel(self.reqGetUserInfoData_)
    end
end

function UserInfoOtherDialog:onExit()
    nk.ImageLoader:cancelJobByLoaderId(self.headImageLoaderId_)

    if self.hddjNumObserverId_ then
        bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "hddjNum", self.hddjNumObserverId_)
        self.hddjNumObserverId_ = nil
    end
end

return UserInfoOtherDialog