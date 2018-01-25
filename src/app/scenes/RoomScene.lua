--
-- Author: Johnny Lee
-- Date: 2014-07-08 11:26:08
--
local RoomController = import("app.module.room.RoomController")
local RoomViewPosition = import("app.module.room.views.RoomViewPosition")
local RoomImageButton = import("app.module.room.views.RoomImageButton")
local RoomMenuPopup = import("app.module.room.views.RoomMenuPopup")
local CardTypePopup = import("app.module.room.views.CardTypePopup")
local StorePopup = import("app.module.newstore.StorePopup")
local CountDownBox = import("app.module.act.CountDownBox")
local SettingAndHelpPopup = import("app.module.settingAndhelp.SettingAndHelpPopup")
local RoomChatBubble = import("app.module.room.views.RoomChatBubble")
local UserInfoPopup = import("app.module.userInfo.UserInfoPopup")
local SlotPopup = import("app.module.slot.SlotPopup")
local HallController = import("app.module.hall.HallController")
local GameReviewPopup = import("app.module.gameReview.GameReviewPopup")
local PayGuide = import("app.module.room.purchGuide.PayGuide")
local QuickShortBillPay = import("app.module.newstore.quickSortPay.QuickShortBillPay")
local SeatInviteView = import("app.module.room.views.SeatInviteView")

-- local FirChargePayGuidePopup = import("app.module.newstore.firChrgGuide.FirChrgPayGuidePopup")
-- local AgnChargePayGuidePopup = import("app.module.newstore.agnChrgGuide.AgnChrgPayGuidePopup")
local NormalRoomBaseView = import("app.module.room.views.NormalRoomBaseView")
local PersonalRoomBaseView = import("app.module.room.views.PersonalRoomBaseView")
local InvitePlayPopup = import("app.module.invitePlay.InvitePlayPopup")

local PswEntryPopup = import("app.module.hall.personalRoomDialog.PswEntryPopup")

local RoomScene = class("RoomScene", function()
    return display.newScene("RoomScene")
end)
local logger = bm.Logger.new("RoomScene")

local TOP_BUTTOM_WIDTH   = 78
local TOP_BUTTOM_HEIGHT  = 58

RoomScene.EVT_BACKGROUND_CLICK = "EVT_BACKGROUND_CLICK"

function RoomScene:ctor()
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    self:createNodes_()

    self.sendDealerChipBubbleListenerId_ = bm.EventCenter:addEventListener(nk.eventNames.SEND_DEALER_CHIP_BUBBLE_VIEW, handler(self, self.playDealerBubble))
    self.logoutByMsg_ = bm.EventCenter:addEventListener(nk.eventNames.DOUBLE_LOGIN_LOGINOUT,handler(self, self.doubleLoginOut_))

    -- 老虎机
    -- local isSlotOpen = nk.OnOff:check("slotopen")
    -- if nk.config.SLOT_ENABLED and isSlotOpen then
    --     display.addSpriteFrames("slot_texture.plist", "slot_texture.png", function()
    --         self.slotPopup = SlotPopup.new(true):addTo(self.nodes.popupNode):show()
    --     end)
    -- end

    -- 老虎机测试 --
    -- display.addSpriteFrames("slot_texture.plist", "slot_texture.png", function()
    --         self.slotPopup = SlotPopup.new(true):addTo(self.nodes.popupNode):show()
    --     end)
   -- end --

    -- 房间总控
    self.controller = RoomController.new(self)
    self.ctx = self.controller.ctx

    --房间基本试图 test
    local roomInfo = bm.DataProxy:getData(nk.dataKeys.ROOM_INFO)
    if not roomInfo or (roomInfo.roomType ~= consts.ROOM_TYPE.PERSONAL_NORMAL) then
        self.roomBaseView_ = NormalRoomBaseView.new(self.ctx):addTo(self.nodes.backgroundNode)

        self.actNode = CountDownBox.new(self.ctx)
            :pos(display.right, display.bottom)
            :addTo(self.nodes.lampNode)
    else
        self.roomBaseView_ = PersonalRoomBaseView.new(self.ctx):addTo(self.nodes.backgroundNode)
    end
    
    self.controller:createNodes()

    self:setChangeRoomButtonMode(1)
    if nk.OnOff:check("roomInvite") then
        local lastLoginType = nk.userDefault:getStringForKey(nk.cookieKeys.LAST_LOGIN_TYPE)
        if lastLoginType ==  "FACEBOOK" then
            self.seatInviteView = SeatInviteView.new(self.ctx):addTo(self.nodes.seatNode)--:hide()
            :pos(-100,-100)
        end
    end

    if device.platform == "android" then
        self.touchLayer_ = display.newLayer()
        self.touchLayer_:addNodeEventListener(cc.KEYPAD_EVENT, function(event)
            if event.key == "back" then
                if not nk.PopupManager:removeTopPopupIf() then
                    self:onMenuClick_()
                end
            elseif event.key == "menu" then
                if self.menuPop_ then
                    --todo
                    self.menuPop_:hidePanel(false)
                    self.menuPop_ = nil
                else
                    self:onMenuClick_()
                end
            end
        end)
        self.touchLayer_:setKeypadEnabled(true)
        self:addChild(self.touchLayer_)
    end
end

function RoomScene:toDelearSendChipHandler()
    -- if roomType == consts.ROOM_TYPE.NORMAL or roomType == consts.ROOM_TYPE.PRO then
        if self.ctx.model:isSelfInSeat() then
            local roomData = nk.getRoomDataByLevel(self.ctx.model.roomInfo.roomType)

            if not roomData and self.ctx.model.roomInfo.roomType == consts.ROOM_TYPE.PERSONAL_NORMAL then
            --私人房，按底注 100% 计算
                local roomInfo = self.ctx.model.roomInfo
                roomData = {}
                roomData.minBuyIn = roomInfo.minBuyIn
                roomData.maxBuyIn = roomInfo.maxBuyIn
                roomData.roomType = roomInfo.roomType
                roomData.blind = roomInfo.blind
                roomData.sendChips = {500,2000,5000,20000}
                roomData.fee = roomInfo.blind

            end

            if not roomData or not roomData.fee then
                return
            end
            if not self.delearFeeRequests_ then
                self.delearFeeRequests_ = {}
                self.delearFeeRequest_ = 0
            end

            if (nk.userData["aUser.money"] - tonumber(roomData.fee)) > roomData.minBuyIn then

                self.delearFeeRequest_ = self.delearFeeRequest_ + 1
                self.delearFeeRequests_[self.delearFeeRequest_] = nk.http.sendDealerChip(roomData.blind,1,function(callData)
                    -- dump(callData, "sendDealerChip.data:================")

                   if callData then
                        nk.userData["aUser.money"] = callData.money
                        nk.server:sendDealerChip(callData.subMoney or roomData.fee, 1)
                   end
                    self.delearFeeRequests_[self.delearFeeRequest_] = nil
                end,function(errData)
                    -- dump(errData, "sendDealerChip.errData:================")

                    if errData and (checkint(errData.errorCode) == -2 or checkint(errData.errorCode) == -3) then
                        nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "SELF_CHIP_NO_ENOUGH_SEND_DELEAR"))
                    end
                    self.delearFeeRequests_[self.delearFeeRequest_] = nil
                end)
               
            else
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "SELF_CHIP_NO_ENOUGH_SEND_DELEAR"))
            end
            cc.UserDefault:getInstance():setBoolForKey(nk.cookieKeys.USER_FIRST_DEALER_SEND_CHIP.. nk.userData.uid, true)
        else
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "SEND_CHIP_NOT_IN_SEAT"))
        end
    -- else
    --     nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "SEND_CHIP_NOT_NORMAL_ROOM_MSG"))
    -- end
end

function RoomScene:setStoreDiscount(discount)
    if self.roomBaseView_ and self.roomBaseView_["setStoreDiscount"]then
        self.roomBaseView_:setStoreDiscount(discount)

    end
    do return end
    if discount and discount ~= 1 then
        self.shopOffBg_:show()
        self.shopOffLabel_:show()
        self.shopOffLabel_:setString(string.format("%+d%%", math.round((discount - 1) * 100)))
    else
        self.shopOffBg_:hide()
        self.shopOffLabel_:hide()
    end
end

function RoomScene:setRoomInfoText(roomInfo)
    if self.roomBaseView_ and self.roomBaseView_["setRoomInfoText"]then
        self.roomBaseView_:setRoomInfoText(roomInfo)

    end

    do return end

    local roomFiled = bm.LangUtil.getText("HALL", "ROOM_LEVEL_TEXT")[math.floor((roomInfo.roomType - 101) / 6) + 1]
    local info = bm.LangUtil.getText("ROOM", "ROOM_INFO", roomFiled, roomInfo.tid, roomInfo.blind)
    self.roomInfo_:setString(info)
end

function RoomScene:setSlotBlind(roomInfo)
    
    if self.slotPopup then
        local roomData = nk.getRoomDataByLevel(roomInfo.roomType)
        local timeArr = roomData and roomData.slot or {}
        self.slotPopup:setPreBlind(roomInfo,timeArr)
    end
end

function RoomScene:setChangeRoomButtonMode(mode)

     if self.roomBaseView_ and self.roomBaseView_["setChangeRoomButtonMode"] then

        self.roomBaseView_:setChangeRoomButtonMode(mode)
    end
    do return end
    if mode == 1 then
        self.changeRoomBtn_:show()
        self.standupBtn_:hide()
    else
        self.changeRoomBtn_:hide()
        self.standupBtn_:show()
    end
end

function RoomScene:onStandupClick_()
    if self.ctx.model:isSelfInGame() and self.ctx.model:hasCardActive() then
        nk.ui.Dialog.new({
            messageText = bm.LangUtil.getText("ROOM", "STAND_UP_IN_GAME_MSG"), 
            hasCloseButton = false,
            showStandUpTips = 1,
            callback = function (type)
                if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                    nk.server:standUp()
                end
            end,
            standUpCallback = function()
                self.controller:setOverStandUp();
            end
        }):show()
    else
        nk.server:standUp()
    end
end

function RoomScene:doBackToHall(msg, jumpType)
    msg = msg or bm.LangUtil.getText("ROOM", "OUT_MSG")
    self.jumpAction_ = jumpType

    if self.roomLoading_ then 
        self.roomLoading_:removeFromParent()
        self.roomLoading_ = nil
    end
    display.addSpriteFrames("hall_texture.plist", "hall_texture.png", handler(self, self.onLoadedHallTexture_))
    self.roomLoading_ = nk.ui.RoomLoading.new(msg)
        :pos(display.cx, display.cy)
        :addTo(self, 100)
end

function RoomScene:doBackToLogin(msg)
    msg = msg or bm.LangUtil.getText("ROOM", "OUT_MSG")
    if self.roomLoading_ then 
        self.roomLoading_:removeFromParent()
        self.roomLoading_ = nil
    end
    display.addSpriteFrames("hall_texture.plist", "hall_texture.png", handler(self, self.onLoadedHallTextureLogout_))
    self.roomLoading_ = nk.ui.RoomLoading.new(msg)
        :pos(display.cx, display.cy)
        :addTo(self, 100)
end

function RoomScene:doBackToLoginByDoubleLogin(msg)
    msg = msg or bm.LangUtil.getText("ROOM", "OUT_MSG")
    if self.roomLoading_ then 
        self.roomLoading_:removeFromParent()
        self.roomLoading_ = nil
    end
    display.addSpriteFrames("hall_texture.plist", "hall_texture.png", handler(self, self.onLoadedHallTextureDoubleLogin_))
    self.roomLoading_ = nk.ui.RoomLoading.new(msg)
        :pos(display.cx, display.cy)
        :addTo(self, 100)
end

function RoomScene:onMenuClick_()
    self.menuPop_ = RoomMenuPopup.new(function(tag)
        if tag == 1 then
            --返回
            if self.ctx.model:isSelfInGame() and self.ctx.model:hasCardActive() then
                nk.ui.Dialog.new({
                    messageText = bm.LangUtil.getText("ROOM", "EXIT_IN_GAME_MSG"), 
                    hasCloseButton = false,
                    callback = function (type)
                        if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                            nk.server:logoutRoom()
                            self:doBackToHall()
                        end
                    end
                }):show()
            else              
                nk.server:logoutRoom()
                self:doBackToHall()
            end
        elseif tag == 2 then
            --换桌
            if self.ctx.model:isSelfInGame() and self.ctx.model:hasCardActive() then
                nk.ui.Dialog.new({
                    messageText = bm.LangUtil.getText("ROOM", "CHANGE_ROOM_IN_GAME_MSG"), 
                    hasCloseButton = false,
                    callback = function (type)
                        if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                            self:onChangeRoom_()
                        end
                    end
                }):show()
            else              
                self:onChangeRoom_()
            end
        elseif tag == 3 then
            --弹出设置菜单
            SettingAndHelpPopup.new(true):show()
        elseif tag == 4 then
            UserInfoPopup.new():show(true, nil, handler(self, self.onChangeRoomClick_), self.ctx.model:isSelfInGame())
        end
    end):showPanel()
end

function RoomScene:onChangeRoomClick_()
    -- self:onChangeRoom_()
    -- self.menuPop_.callBack_(2)
    if self.ctx.model:isSelfInGame() and self.ctx.model:hasCardActive() then
        nk.ui.Dialog.new({
            messageText = bm.LangUtil.getText("ROOM", "CHANGE_ROOM_IN_GAME_MSG"), 
            hasCloseButton = false,
            callback = function (type)
                if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                    self:onChangeRoom_()
                end
            end
        }):show()
    else              
        self:onChangeRoom_()
    end
end

function RoomScene:playNowChangeRoom()
    self:onChangeRoom_(false, true)
end

function RoomScene:removeLoading()
    if self.roomLoading_ then 
        self.roomLoading_:removeFromParent()
        self.roomLoading_ = nil
    end
end

function RoomScene:onChangeRoom_(doNotUpdateRoomInfo, isPlayNow)
    if self.logoutEventHandlerId_ then
        bm.EventCenter:removeEventListener(self.logoutEventHandlerId_)
        self.logoutEventHandlerId_ = nil
    end
    if self.loginEventHandlerId_ then
        bm.EventCenter:removeEventListener(self.loginEventHandlerId_)
        self.loginEventHandlerId_ = nil
    end

    --显示正在更换房间
    if self.roomLoading_ then 
        self.roomLoading_:removeFromParent()
        self.roomLoading_ = nil
    end
    self.roomLoading_ = nk.ui.RoomLoading.new(bm.LangUtil.getText("ROOM", "CHANGING_ROOM_MSG"))
        :pos(display.cx, display.cy)
        :addTo(self, 100)

    local tid = self.ctx.model.roomInfo.tid
    nk.server:logoutRoom()
    -- local rlevel = nk.getRoomLevelByMoney2(nk.userData['aUser.money'])
    nk.server:changeRoomAndLogin((self.ctx.model.roomInfo.roomType), tid)
end


function RoomScene:onSearchPersonalRoom(data)
    local ret = data.ret
    dump(data,"onSearchPersonalRoom")
    if ret == 0 then
         if data.hasPwd == 1 then
            --有密码，弹密码框
            PswEntryPopup.new(data, handler(self, self.onPswPopCallback)):show() 
            --传入这个回调 handler(self,self.onPswPopCallback)
        else
            --无密码，直接进
            nk.server:loginPersonalRoom(nil,data.tableID)
        end
    end
end


function RoomScene:onReviewClick_()
    GameReviewPopup.new():show()
end

function RoomScene:onShopClick_(tag)
    -- StorePopup.new():showPanel()
    local isShowPay = nk.OnOff:check("payGuide")

    local isPay = nk.userData.best and nk.userData.best.paylog == 1 or false

    local roomData = nk.getRoomDataByLevel(self.controller.model.roomInfo.roomType)
    
    local payGuideShownType = 1
    local isThirdPayOpen = isShowPay
    local isFirstCharge = not isPay
    local payBillType = nil

    if roomData ~= nil then
        payBillType = roomData.roomGroup
    end

    local params = {}

    params.isOpenThrPartyPay = isThirdPayOpen
    params.isFirstCharge = isFirstCharge
    params.sceneType = payGuideShownType
    params.payListType = payBillType

    PayGuide.new(params):show(nil, nil, true)
end

-- @param tag:标识跳转方向,目前仅有1, userData,其中1表示从轮播消息跳转而来,userData为点击按钮事件而来
function RoomScene:onChargeFavClick_(tag)
    -- body
    local payGuideShownType = 1
    local isThirdPayOpen = true
    local isFirstCharge = true
    local payBillType = nil

    if nk.OnOff:check("firstchargeFavGray") then
        --todo
        FirChargePayGuidePopup.new():showPanel(nil, nil, true)
    else

        if tag == nil and nk.OnOff:check("quickShortPay") then
            --todo
            local getBillIdxByRoomAnte = {
                [100] = 1,
                [1000] = 1,
                [10000] = 2,
                [50000] = 3,
                [100000] = 4,
                [200000] = 4
            }

            if self.ctx.model.roomInfo.blind and getBillIdxByRoomAnte[self.ctx.model.roomInfo.blind] then
                --todo
                QuickShortBillPay.new(false, getBillIdxByRoomAnte[self.ctx.model.roomInfo.blind])
            else
                local params = {}

                params.isOpenThrPartyPay = isThirdPayOpen
                params.isFirstCharge = isFirstCharge
                params.sceneType = payGuideShownType
                params.payListType = payBillType

                PayGuide.new(params):show(nil, nil, true)
            end
        else
            local params = {}

            params.isOpenThrPartyPay = isThirdPayOpen
            params.isFirstCharge = isFirstCharge
            params.sceneType = payGuideShownType
            params.payListType = payBillType

            PayGuide.new(params):show(nil, nil, true)
        end
    end

    -- local shownSence = 1
    -- PayGuide.new(true, shownSence):show()
end

function RoomScene:onAlmRechargeFavClick_()
    -- body
    AgnChargePayGuidePopup.new():showPanel(nil, nil, true)
end

function RoomScene:onCardTypeClick_()
    -- local msgInfo = {
    --     type = 2,
    --     content = "通知:唉纱布的骄傲比我都看见爱我不打开暗红色的金卡和贷款还逗我还等哈啊肯定会！          ",
    --     location = "fillawrdaddr",
    --     color = "ffed2f"
    -- }
    -- local msgJson = json.encode(msgInfo)

    -- self.controller:SVR_SUONA_BROADCAST_RECV({msg_info = msgJson})
    -- do return end

    CardTypePopup.new():showPanel()
end

function RoomScene:onInviteBtnClick_( )
    InvitePlayPopup.new():show()
end

function RoomScene:onLoadedHallTexture_()
    app:enterHallScene({bm.DataProxy:getData(nk.dataKeys.CURRENT_HALL_VIEW), self.jumpAction_})

    local isAdSceneOpen = nk.OnOff:check("unionAd")
    dump(isAdSceneOpen,"onLoadedHallTexture_")
    if isAdSceneOpen and nk.AdSceneSdk then
        nk.AdSceneSdk:setShowRecommendBar(true)
    end
end

function RoomScene:onLoadedHallTextureLogout_()
    app:enterHallScene({HallController.LOGIN_GAME_VIEW, "logout"})

    local isAdSceneOpen = nk.OnOff:check("unionAd")
    if isAdSceneOpen and nk.AdSceneSdk then
        nk.AdSceneSdk:setShowRecommendBar(false)
    end
end

function RoomScene:onLoadedHallTextureDoubleLogin_()
    app:enterHallScene({HallController.LOGIN_GAME_VIEW, "doublelogin"})
end

function RoomScene:playDealerBubble(evt)
    local currentTime = bm.getTime()
    self.prevPlayDealerBubbleTime_ = self.prevPlayDealerBubbleTime_ or 0
    if currentTime - self.prevPlayDealerBubbleTime_ > 3 then
        local DEALER_SPEEK_ARRAY = bm.LangUtil.getText("ROOM", "DEALER_SPEEK_ARRAY")
        local array = {}
        for i,v in ipairs(DEALER_SPEEK_ARRAY) do
            local kk = bm.LangUtil.formatString(v, evt.nick or "")
            table.insert(array, kk)
        end
        DEALER_SPEEK_ARRAY = array

        local dealerSpeakLengt = #DEALER_SPEEK_ARRAY
        local textId = math.round(math.random(1, dealerSpeakLengt))
        if textId <= dealerSpeakLengt then
            if textId == 0 then
                textId = 3
            end
            self.prevPlayDealerBubbleTime_ = currentTime
            self:showBubble(textId, DEALER_SPEEK_ARRAY)
        end
    end
    
end

function RoomScene:showBubble(textId, DEALER_SPEEK_ARRAY)
    local bubble = RoomChatBubble.new(DEALER_SPEEK_ARRAY[textId], RoomChatBubble.DIRECTION_LEFT)
    bubble:show(self, display.cx + 60, display.cy + 220)
    if bubble then
        bubble:runAction(transition.sequence({cc.DelayTime:create(3), cc.CallFunc:create(function() 
            bubble:removeFromParent()
        end)}))
    end
end

--[[
RoomScene nodes:
    animLayer:动画层
    oprNode:操作按钮层
    lampNode:桌面灯光层
    chipNode:桌面筹码层
    dealCardNode:手牌层
    seatNode:桌子层
        seat1~9:桌子
            giftImage:礼物图片(*)
            userImage:用户头像
            backgroundImage:桌子背景
    backgroundNode:背景层
        dealerImage:荷官图片
        tableTextLayer:桌面文字
        tableImage:桌子图片
        backgroundImage:背景图片
]]
function RoomScene:createNodes_()
    self.nodes = {}
    self.nodes.backgroundNode = display.newNode():addTo(self, 1)
    self.nodes.dealerNode = display.newNode():addTo(self, 2)
    self.nodes.seatNode = display.newNode():addTo(self, 3)
    self.nodes.chipNode = display.newNode():addTo(self, 4)
    self.nodes.dealCardNode = display.newNode():addTo(self, 5)
    self.nodes.lampNode = display.newNode():addTo(self, 6)
    self.nodes.oprNode = display.newNode():addTo(self, 7)
    self.nodes.animNode = display.newNode():addTo(self, 8)
    self.topNode_ = display.newNode():pos(display.left + 8, display.top - 8):addTo(self, 9)
    self.nodes.popupNode = display.newNode():addTo(self, 10)

    self.backgroundTouchHelper_ = bm.TouchHelper.new(self.nodes.backgroundNode, handler(self, self.onBackgroundTouch_))
    self.backgroundTouchHelper_:enableTouch()
end

function RoomScene:onEnter()
    nk.SoundManager:preload("roomSounds")
    nk.SoundManager:preload("hddjSounds")
    --清空房间聊天记录
    bm.DataProxy:clearData(nk.dataKeys.ROOM_CHAT_HISTORY)

    if device.platform == "android" or device.platform == "ios" then
        cc.analytics:doCommand{command = "beginScene",
                    args = {sceneName = "RoomScene"}}
    end
end

function RoomScene:onExit()
    --清空房间聊天记录
    bm.DataProxy:clearData(nk.dataKeys.ROOM_CHAT_HISTORY)
    if device.platform == "android" or device.platform == "ios" then
        cc.analytics:doCommand{command = "endScene",
                    args = {sceneName = "RoomScene"}}
    end

    nk.schedulerPool:delayCall(function()
        cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    end, 0.1)

    bm.DataProxy:setData(nk.dataKeys.LAST_ENTER_SCENE,"RoomScene")
end

function RoomScene:onCleanup()
    -- 控制器清理
    self.controller:dispose()

    -- 移除事件
    self:removeAllEventListeners()

    -- remove data observer
    if self.actNode then
        self.actNode:release()
    end

    -- 卸载预加载的声音
    nk.SoundManager:unload("roomSounds")
    nk.SoundManager:unload("hddjSounds")

    -- 清除房间纹理
    display.removeSpriteFramesWithFile("room_texture.plist", "room_texture.png")
    display.removeSpriteFramesWithFile("slot_texture.plist", "slot_texture.png")

    if self.sendDealerChipBubbleListenerId_ then
        bm.EventCenter:removeEventListener(self.sendDealerChipBubbleListenerId_)
        self.sendDealerChipBubbleListenerId_ = nil
    end
    if self.logoutByMsg_ then
        bm.EventCenter:removeEventListener(self.logoutByMsg_)
        self.logoutByMsg_ = nil
    end


    --清除小费请求，下次挪到roomControl
    if self.delearFeeRequests_ then
        for k,v in pairs(self.delearFeeRequests_ ) do
            nk.http.cancel(v)
            self.delearFeeRequests_[k] = nil
        end
        self.delearFeeRequest_ = nil;
    end

end

function RoomScene:onBackgroundTouch_(target, evt)
    if evt == bm.TouchHelper.CLICK then
        self:dispatchEvent({name=RoomScene.EVT_BACKGROUND_CLICK})
    end
end

function RoomScene:doubleLoginOut_(evt)
    nk.socket.RoomSocket:sendLogout()
    self:doBackToLoginByDoubleLogin()
end

return RoomScene