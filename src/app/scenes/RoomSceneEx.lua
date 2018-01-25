--
-- Author: Johnny Lee
-- Date: 2014-07-08 11:26:08
--
local RoomController = import("app.module.roomEx.room.RoomController")
local RoomViewPosition = import("app.module.roomEx.room.views.RoomViewPosition")
local RoomImageButton = import("app.module.roomEx.room.views.RoomImageButton")
local RoomMenuPopup = import("app.module.roomEx.room.views.RoomMenuPopup")
local CardTypePopup = import("app.module.roomEx.room.views.CardTypePopup")
local StorePopup = import("app.module.newstore.StorePopup")
local CountDownBox = import("app.module.act.CountDownBox")
local SettingAndHelpPopup = import("app.module.settingAndhelp.SettingAndHelpPopup")
local RoomChatBubble = import("app.module.roomEx.room.views.RoomChatBubble")
local UserInfoPopup = import("app.module.userInfo.UserInfoPopup")
local SlotPopup = import("app.module.slot.SlotPopup")
local HallController = import("app.module.hall.HallController")
local GameReviewPopup = import("app.module.gameReview.GameReviewPopup")
local GameCardRecordPopup = import("app.module.gameRecord.GameCardRecordPopup")
local UserCrash = import("app.module.room.userCrash.UserCrash")
local PayGuide = import("app.module.room.purchGuide.PayGuide")
local FirChargePayGuidePopup = import("app.module.newstore.firChrgGuide.FirChrgPayGuidePopup")
local AgnChargePayGuidePopup = import("app.module.newstore.agnChrgGuide.AgnChrgPayGuidePopup")
local QuickShortBillPay = import("app.module.newstore.quickSortPay.QuickShortBillPay")
local SeatInviteView = import("app.module.roomEx.room.views.SeatInviteView")
local GrabDealerBuyInPopup = import("app.module.roomEx.room.views.DealerBuyInPopup")
local GrabAddDealerAnteMoneyPopup = import("app.module.roomEx.room.views.AddDealerAnteMoneyPopup")

local NormalRoomBaseView = import("app.module.roomEx.room.views.NormalRoomBaseView")
local PersonalRoomBaseView = import("app.module.roomEx.room.views.PersonalRoomBaseView")
local InvitePlayPopup = import("app.module.invitePlay.InvitePlayPopup")

local PswEntryPopup = import("app.module.hall.personalRoomDialog.PswEntryPopup")
local GrabDealerLeftTimeTip = import("app.module.roomEx.room.views.DealerLeftTimeTip")
-- local GrabDealerAdvanceNotice = import("app.module.roomEx.room.views.DealerAdvanceNotice")
local GrabDealerPaoPaoTip = import("app.module.roomEx.room.views.DealerPaoPaoTip")
local RoomSceneEx = class("RoomSceneEx", function()
    return display.newScene("RoomSceneEx")
end)
local logger = bm.Logger.new("RoomSceneEx")

local TOP_BUTTOM_WIDTH   = 78
local TOP_BUTTOM_HEIGHT  = 58

RoomSceneEx.EVT_BACKGROUND_CLICK = "EVT_BACKGROUND_CLICK"

function RoomSceneEx:ctor()
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    self:createNodes_()

    self.sendDealerChipBubbleListenerId_ = bm.EventCenter:addEventListener(nk.eventNames.SEND_DEALER_CHIP_BUBBLE_VIEW, handler(self, self.playDealerBubble))
    self.logoutByMsg_ = bm.EventCenter:addEventListener(nk.eventNames.DOUBLE_LOGIN_LOGINOUT,handler(self, self.doubleLoginOut_))

    ---老虎机
    local isSlotOpen = nk.OnOff:check("slotopen")
    if nk.config.SLOT_ENABLED and isSlotOpen then
        display.addSpriteFrames("slot_texture.plist", "slot_texture.png", function()
            self.slotPopup = SlotPopup.new(true):addTo(self.nodes.popupNode):show()
        end)
    end

    -- 房间总控
    self.controller = RoomController.new(self)
    self.ctx = self.controller.ctx


    --房间基本试图 test
    local roomInfo = bm.DataProxy:getData(nk.dataKeys.ROOM_INFO)
    if not roomInfo or (roomInfo.roomType ~= consts.ROOM_TYPE.PERSONAL_NORMAL) then
        self.roomBaseView_ = NormalRoomBaseView.new(self.ctx):addTo(self.nodes.backgroundNode)

    else
        self.roomBaseView_ = PersonalRoomBaseView.new(self.ctx):addTo(self.nodes.backgroundNode)
    end
    
   

    -- count down box
    self.actNode = CountDownBox.new(self.ctx)
                    :pos(display.right, display.bottom)
                    :addTo(self.nodes.lampNode)

    --创建其他元素
    self.controller:createNodes()

    self:setChangeRoomButtonMode(1)

    if nk.OnOff:check("roomInvite") then
        local lastLoginType = nk.userDefault:getStringForKey(nk.cookieKeys.LAST_LOGIN_TYPE)
        if lastLoginType ==  "FACEBOOK" then
            self.seatInviteView = SeatInviteView.new(self.ctx):addTo(self.nodes.seatNode):hide()
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

    --上庄倒计时提示
    self.grabLeftTimeTips_  = GrabDealerLeftTimeTip.new(
        function()
            self.grabLeftTimeTips_:hide()
        end
    )
    :addTo(self.nodes.grabDealerUINode)
    :hide()

    --上庄预告
    -- self.grabAdvanceNotice_ = GrabDealerAdvanceNotice.new()
    -- :addTo(self.nodes.grabDealerUINode)

    --抢庄泡泡提示
    self.grabDealerPaoPao_  = GrabDealerPaoPaoTip.new()
    :align(display.LEFT_CENTER)
    :addTo(self.nodes.grabDealerUINode)


    --抢庄按钮
    self.grabDealerBtn = cc.ui.UIPushButton.new({normal = "#grab_dealer_room_btn.png", pressed = "#grab_dealer_room_btn_down.png", disabled = "#common_btn_disabled.png"})
        :pos(RoomViewPosition.SeatPosition[10].x+120,RoomViewPosition.SeatPosition[10].y+20)
        :addTo(self.nodes.grabDealerUINode)
        :onButtonClicked(buttontHandler(self, function()
           
           local isCashRoom = 0
           local myMoney;
           if self.ctx.model.roomInfo.rmType == consts.ROOM_TYPE_EX.GRAB_CASH then
               myMoney = nk.userData['match.point']
               isCashRoom = 1
           else
                myMoney = nk.userData["aUser.money"]
           end

            local door = self.ctx.model:getGrabDealerNeedCoin()
           -- local roomExchangeMoney = self.ctx.model:getExchangeMoney()
            local betMoney = self.ctx.model:getCurBetMoney()
           --nk.TopTipManager:showTopTip("money:"..myMoney.." betMoney:"..betMoney.." door:"..door)
            if myMoney-betMoney - door <0 then
                if isCashRoom == 0 then
                    --
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("GRAB_DEALER", "GRAB_ROOM_NOT_MONEY2",door))
                else
                    --nk.TopTipManager:showTopTip(T("您的现金币不足"))
                    local tipString = bm.LangUtil.getText("GRAB_DEALER", "GRAB_ROOM_NOT_CASH",door)
                     nk.ui.Dialog.new({
                        messageText = tipString, 
                        hasCloseButton = true,
                        callback = function (type)
                            if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                                --nk.TopTipManager:showTopTip("前往支付")
                                StorePopup.new(2):showPanel()
                            end
                        end
                    }):show()
                end
                return
            end
            -- nk.TopTipManager:showTopTip("my: "..nk.userData["aUser.money"]
            --     .."bet: "..betMoney.." ex: "..roomExchangeMoney)
            --local myAnteMoney = nk.userData['aUser.anteMoney'] or 0
            local maxBuyIn = myMoney-betMoney;
            if maxBuyIn == door then
                nk.server:userGrabDealer(maxBuyIn)
                return 
            end
            --现金币抢庄直接买入最大
            if isCashRoom == 1 then
                nk.server:userGrabDealer(maxBuyIn)
                return
            else
                nk.server:userGrabDealer(maxBuyIn)
                return
            end
            --以下代码将不再执行。抢庄场全部采用最大值进入，买入，坐下。
            GrabDealerBuyInPopup.new({
                    isCash= isCashRoom,
                    minBuyIn = door,
                    maxBuyIn = myMoney-betMoney,
                    isAutoBuyin = false,
                    callback = function(buyinChips, isAutoBuyin1)
                        nk.server:userGrabDealer(buyinChips)
                    end
            }):showPanel()

            
        end))
        :hide()
    --庄家补币按钮
    --grab_add_dealer_coin
    self.dealerAddCoinBtn_ = cc.ui.UIPushButton.new({normal = "#grab_add_dealer_coin.png", pressed = "#grab_add_dealer_coin.png", disabled = "#common_btn_disabled.png"})
        :pos(RoomViewPosition.SeatPosition[10].x+70,RoomViewPosition.SeatPosition[10].y-70)
        :addTo(self.nodes.grabDealerUINode)
        :onButtonClicked(buttontHandler(self, function()

           local isCashRoom = 0
           local myMoney;
           if self.ctx.model.roomInfo.rmType == consts.ROOM_TYPE_EX.GRAB_CASH then
               myMoney = nk.userData['match.point']
               isCashRoom =1
           else
               myMoney = nk.userData["aUser.money"]
           end

            local needCoin = self.ctx.model:getDealerAddCoinNum()
            if needCoin == 0 then
                needCoin = 1
            end
            local myAnteMoney =  nk.userData['aUser.anteMoney'] or 0
            local canBuyInMoney = myMoney-myAnteMoney
            if canBuyInMoney - needCoin < 0 then
                if isCashRoom == 0 then
                    nk.TopTipManager:showTopTip(T("金币不足"))
                else
                    nk.TopTipManager:showTopTip(T("您的现金币不足"))
                end
                return
            end
            --local door = self.ctx.model.gameInfo.grabDoor
            local door = self.ctx.model:getGrabDealerNeedCoin()

            --当其剩余金币小于其门槛值的时候，需要判断玩家的剩余金币是否能补够门槛金币
            if myAnteMoney < door then
                needCoin = door - myAnteMoney
                if canBuyInMoney < door-myAnteMoney then
                    if isCashRoom == 0 then
                        nk.TopTipManager:showTopTip(T("金币不足"))
                    else
                        nk.TopTipManager:showTopTip(T("您的现金币不足"))
                    end
                    return
                end
            end

            if needCoin == canBuyInMoney then
                nk.server:addDealerHandCoin(needCoin)
                return 
            end

            GrabAddDealerAnteMoneyPopup.new({
                    isCash  = isCashRoom,
                    minBuyIn = needCoin,
                    maxBuyIn = canBuyInMoney,
                    isAutoBuyin = false,
                    callback = function(buyinChips, isAutoBuyin1)
                        nk.server:addDealerHandCoin(buyinChips)
                    end
            }):showPanel()

            
        end)) 
        :hide()
end
--设置抢庄倒计时
function RoomSceneEx:setGrabLeftTime(leftTime)
    if leftTime == 0 then
        self.grabLeftTimeTips_:hide()
    else
        local isCashRoom = 0
        if self.ctx.model.roomInfo.rmType == consts.ROOM_TYPE_EX.GRAB_CASH then
            isCashRoom = 1
        end
        local door = self.ctx.model.gameInfo.grabDoor;--抢庄门槛
        self.grabLeftTimeTips_:show()
        self.grabLeftTimeTips_:showTime(leftTime,door,isCashRoom)
    end
end
--设置抢庄预告
function RoomSceneEx:setGrabPlayerData(data)

    if self.ctx.model:getHaveDealer() == 0 then
        self.grabDealerPaoPao_:show(data)
        local paopaoWidth = self.grabDealerPaoPao_:getWidth()
        self.grabDealerPaoPao_:pos(RoomViewPosition.SeatPosition[10].x+paopaoWidth/2+60,RoomViewPosition.SeatPosition[10].y-20)
    else
        -- self.grabAdvanceNotice_:addMsg(data)
    end
    self.grabLeftTimeTips_:hide()
end
--更新抢庄预告局数
function RoomSceneEx:updataGrabAdvance()
    -- self.grabAdvanceNotice_:update()
end
--庄家补币预告
function RoomSceneEx:dealerAddCoin(data)
    self:setGrabAdvanceStop()
    self.grabDealerPaoPao_:show({msg = T("庄家保庄成功!")})
    local paopaoWidth = self.grabDealerPaoPao_:getWidth()
    self.grabDealerPaoPao_:pos(RoomViewPosition.SeatPosition[10].x+paopaoWidth/2+60,RoomViewPosition.SeatPosition[10].y-20)
end
--设置抢庄按钮显示
function RoomSceneEx:showGrabDealerBtn(pack)
    if pack.errno == 0 then
        self.grabDealerBtn:show()
    else
        self.grabDealerBtn:hide()
    end
end
--抢庄预告停止(新庄家坐下)
function RoomSceneEx:setGrabAdvanceStop()
    -- self.grabAdvanceNotice_:stop()
end
--设置庄家补币按钮显示
function RoomSceneEx:showDealerAddCoinBtn(isShow)
    if isShow == true then
        self.dealerAddCoinBtn_:show()
    else
        self.dealerAddCoinBtn_:hide()
    end
end
function RoomSceneEx:toDelearSendChipHandler()
    -- if roomType == consts.ROOM_TYPE.NORMAL or roomType == consts.ROOM_TYPE.PRO then
        if self.ctx.model:isSelfInSeat() then
            local roomData = nk.getRoomDataByLevel(self.ctx.model.roomInfo.roomType)

            if not roomData then --and self.ctx.model.roomInfo.roomType == consts.ROOM_TYPE.PERSONAL_NORMAL then
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

            local blind = self.ctx.model.roomInfo.blind
            local grablistConfig = bm.DataProxy:getData(nk.dataKeys.GRAB_ROOM_LIST)
            if grablistConfig then
                if self.ctx.model.roomInfo.rmType == consts.ROOM_TYPE_EX.GRAB_CASH then
                    if grablistConfig.point and grablistConfig.point[tostring(blind)] then
                        local grabData = grablistConfig.point[tostring(blind)]
                        if grabData then
                            --dealertip:荷官小费
                            --sendInRoom:赠送筹码
                            --facial:表情收费
                         
                            if roomData and grabData.sendInRoom and grabData.sendInRoom ~= "" then
                                roomData.sendChips = string.split(grabData.sendInRoom,",")
                            end
                            if roomData and ((not roomData.sendChips) or (#roomData.sendChips == 0)) then
                                 roomData.sendChips =  {500,2000,5000,20000}
                            end

                            if roomData and grabData.dealertip then
                                roomData.fee = tonumber(grabData.dealertip)
                            end
                        end
                        
                    end
                else
                    if grablistConfig.money and grablistConfig.money[tostring(blind)] then
                        local grabData = grablistConfig.money[tostring(blind)]
                        if grabData then
                            --dealertip:荷官小费
                            --sendInRoom:赠送筹码
                            --facial:表情收费
                            if roomData and grabData.sendInRoom and grabData.sendInRoom ~= "" then
                                roomData.sendChips =  string.split(grabData.sendInRoom,",")
                            end
                            if roomData and ((not roomData.sendChips) or (#roomData.sendChips == 0)) then
                                roomData.sendChips = {500,2000,5000,20000}
                            end

                            if roomData and grabData.dealertip then
                                roomData.fee = tonumber(grabData.dealertip)
                            end
                        end
                    end
                end
            end

            if not roomData or not roomData.fee then
                --nk.TopTipManager:showTopTip("not fee")
                return
            end
            if not self.delearFeeRequests_ then
                self.delearFeeRequests_ = {}
                self.delearFeeRequest_ = 0
            end
            local room_type = 1
           if self.ctx.model.roomInfo.rmType == consts.ROOM_TYPE_EX.GRAB_CASH then
                room_type = 2
            end

            --sendDealerChipEx
            local currentBet = self.ctx.model:getCurBetMoney()
            if (nk.userData["aUser.money"] -  tonumber(roomData.fee)-currentBet ) > roomData.minBuyIn then
                self.delearFeeRequest_ = self.delearFeeRequest_ + 1
                self.delearFeeRequests_[self.delearFeeRequest_] = nk.http.sendDealerChipEx(roomData.blind,1,room_type,function(callData)
                    -- dump(callData, "sendDealerChipEx.data :==================")

                   if callData then
                        nk.userData["aUser.money"] = callData.money
                        nk.server:sendDealerChip(callData.subMoney or roomData.fee,1)
                        bm.EventCenter:dispatchEvent({name = nk.eventNames.UPDATE_SEAT_ANTE_CHIP, data = {chip = -callData.subMoney}})
                   end
                    self.delearFeeRequests_[self.delearFeeRequest_] = nil
                end,function(errData)
                    -- dump(errData, "sendDealerChipEx.errData :===================")

                    if errData and (checkint(errData.errorCode) == -2 or checkint(errData.errorCode) == -3) then
                        nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "SELF_CHIP_NO_ENOUGH_SEND_DELEAR"))
                    end
                    self.delearFeeRequests_[self.delearFeeRequest_] = nil
                end)
               
            else
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "SELF_CHIP_NO_ENOUGH_SEND_DELEAR"))
            end


            cc.UserDefault:getInstance():setBoolForKey(nk.cookieKeys.USER_FIRST_DEALER_SEND_CHIP .. nk.userData.uid, true)
            if  self.sendDealerChipIcon then
                self.sendDealerChipIcon:removeFromParent()
                self.sendDealerChipIcon = nil
            end
        else
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "SEND_CHIP_NOT_IN_SEAT"))
        end
    -- else
        -- nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "SEND_CHIP_NOT_NORMAL_ROOM_MSG"))
    -- end
end

function RoomSceneEx:setStoreDiscount(discount)
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

function RoomSceneEx:setRoomInfoText(roomInfo)
    if self.roomBaseView_ and self.roomBaseView_["setRoomInfoText"]then
        self.roomBaseView_:setRoomInfoText(roomInfo)

    end

    do return end

    local roomFiled = bm.LangUtil.getText("HALL", "ROOM_LEVEL_TEXT")[math.floor((roomInfo.roomType - 101) / 6) + 1]
    local info = bm.LangUtil.getText("ROOM", "ROOM_INFO", roomFiled, roomInfo.tid, roomInfo.blind)
    self.roomInfo_:setString(info)
end
function RoomSceneEx:onGrabInviteClick_()
    self:setMatchInviteButtonVisible(false)
    local baseAnte = self.ctx.model.roomInfo.blind
    nk.http.sendGrabBroadCast(baseAnte,function(data)
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("MATCH", "INVITE_HAD_SEND_TIP"))
    end,function(errData)
       -- nk.TopTipManager:showTopTip(T("发送失败"))
    end)
end
function RoomSceneEx:setMatchInviteButtonVisible(visible)
    if self.roomBaseView_ and self.roomBaseView_["setMatchInviteButtonVisible"] then
        self.roomBaseView_:setMatchInviteButtonVisible(visible)
    end
end
function RoomSceneEx:setSlotBlind(roomInfo)
    if self.slotPopup then
        local roomData = nk.getRoomDataByLevel(roomInfo.roomType)
        local timeArr = roomData and roomData.slot or {}
        self.slotPopup:setPreBlind(roomInfo,timeArr)
    end
end

function RoomSceneEx:setChangeRoomButtonMode(mode)

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

function RoomSceneEx:onStandupClick_()
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

function RoomSceneEx:doBackToHall(msg, jumpType)
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

function RoomSceneEx:doBackToLogin(msg)
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

function RoomSceneEx:doBackToLoginByDoubleLogin(msg)
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

function RoomSceneEx:onMenuClick_()
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
                           -- self:doBackToHall()
                        end
                    end
                }):show()
            else              
                nk.server:logoutRoom()
               -- self:doBackToHall()
            end
        elseif tag == 2 then
            --换桌
            if self.ctx.model.roomInfo.rmType == consts.ROOM_TYPE_EX.GRAB_CASH then
                nk.TopTipManager:showTopTip(T("现金币场不可换桌。"))
                return 
            end
            --只要在座位上就不让换桌，避免在保护期间内,会报错
            if self.ctx.model:isSelfInSeat() then

                if self.ctx.model:selfSeatId() == 9 then
                    nk.TopTipManager:showTopTip(T("坐下后不可换桌"))
                else
                    nk.ui.Dialog.new({
                        messageText = bm.LangUtil.getText("ROOM", "CHANGE_ROOM_IN_GAME_MSG"), 
                        hasCloseButton = false,
                        callback = function (type)
                            if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                                self:onChangeRoom_()
                            end
                        end
                    }):show()
                end
                 
            else              
                self:onChangeRoom_()
            end
        elseif tag == 3 then
            --弹出设置菜单
            SettingAndHelpPopup.new(true):show()
        elseif tag == 4 then
            if self.ctx.model:isSelfInGame() then
                UserInfoPopup.new():show(true, nil, handler(self, self.onChangeRoomClick_),self.ctx.model:isSelfInGame())
            else
                UserInfoPopup.new():show(true, nil, handler(self, self.onChangeRoomClick_),self.ctx.model:isSelfInGame())
            end
        end
    end):showPanel()
end

function RoomSceneEx:onChangeRoomClick_()
    if self.ctx.model.roomInfo.rmType == consts.ROOM_TYPE_EX.GRAB_CASH then
        nk.TopTipManager:showTopTip(T("现金币场不可换桌。"))
        return 
    end
    --只要在座位上就不让换桌，避免在保护期间内,会报错
    if self.ctx.model:isSelfInSeat() then
         nk.TopTipManager:showTopTip(T("坐下后不可换桌"))
    else
        self:onChangeRoom_()
    end
end

function RoomSceneEx:removeLoading()
    if self.roomLoading_ then 
        self.roomLoading_:removeFromParent()
        self.roomLoading_ = nil
    end
end

function RoomSceneEx:onChangeRoom_(doNotUpdateRoomInfo, isPlayNow)
    if self.logoutEventHandlerId_ then
        bm.EventCenter:removeEventListener(self.logoutEventHandlerId_)
        self.logoutEventHandlerId_ = nil
    end
    if self.loginEventHandlerId_ then
        bm.EventCenter:removeEventListener(self.loginEventHandlerId_)
        self.loginEventHandlerId_ = nil
    end

    if nk.userData.bankruptcyGrant and nk.userData["aUser.money"] < nk.userData.bankruptcyGrant.maxBmoney then
        --todo
        if nk.userData["aUser.bankMoney"] >= nk.userData.bankruptcyGrant.maxsafebox then
            --todo
            local userCrash = UserCrash.new(0, 0, 0, 0, true, true)
            userCrash:show()
        else
            local rewardTime = nk.userData.bankruptcyGrant.bankruptcyTimes + 1
            local bankruptcyTimes = nk.userData.bankruptcyGrant.bankruptcyTimes
            local rewardMoney = nk.userData.bankruptcyGrant.money[rewardTime] or 0
            local limitDay = nk.userData.bankruptcyGrant.day or 1
            local limitTimes = nk.userData.bankruptcyGrant.num or 0
            local userCrash = UserCrash.new(bankruptcyTimes, rewardMoney, limitDay, limitTimes)
            userCrash:show()
        end

        return
    end

    self.isChangeRoom = true
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
    nk.server:changeRoomAndLogin(self.ctx.model.roomInfo.roomType, tid)
end

function RoomSceneEx:logoutRoomOk(backHallAction)
    --普通场退出房间，是发送0x1002退出命令切客户端同时退出到大厅，
    --并未处理1008退出成功的协议，
    --抢庄场有很多退出失败的情况，所以要当server回1008的包客户端才能执行退出。
    --换房间这里也发送退出命令，所以要严格区分开来
    --玩家退出的操作要执行退出，而换房的操作不执行

    if self.isChangeRoom then
        self.isChangeRoom = false
    else
        if backHallAction then
            --todo
            self:doBackToHall(nil, backHallAction)
        else
            self:doBackToHall()
        end
    end
end

function RoomSceneEx:onSearchPersonalRoom(data)
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


function RoomSceneEx:onReviewClick_()
    GameReviewPopup.new():show()
end
function RoomSceneEx:onRecordClick_()
    GameCardRecordPopup.new():showPanel()
end

-- 快捷支付
-- @param tag:标识跳转方向,目前仅有nil, userData,其中1表示从轮播消息跳转而来,userData为点击按钮事件而来
function RoomSceneEx:onShopClick_(tag)
    local isShowPay = nk.OnOff:check("payGuide")

    if tag == nil and isShowPay and nk.OnOff:check("quickShortPay") then
        --todo
        local getBillIdxByRoomAnte = {
            [100] = 1,
            [500] = 2,
            [1000] = 3,
            [5000] = 4,
            [10000] = 5,
            [20000] = 5
        }
        if self.ctx.model.roomInfo.blind and getBillIdxByRoomAnte[self.ctx.model.roomInfo.blind] then
            --todo
            QuickShortBillPay.new(false, getBillIdxByRoomAnte[self.ctx.model.roomInfo.blind])
        else
            local isPay = nk.userData.best and nk.userData.best.paylog == 1 or false

            local roomData = nk.getRoomDataByLevel(self.controller.model.roomInfo.roomType)
            
            local payGuideShownType = 1
            local isThirdPayOpen = isShowPay
            local isFirstCharge = not isPay
            local payBillType = nil
            -- 需要取到当前房间的类型。

            if roomData ~= nil then
                payBillType = roomData.roomGroup
            end

            -- if nk.OnOff:check("firstchargeFavGray") and isThirdPayOpen and isFirstCharge then
            --     --todo
            --     FirChargePayGuidePopup.new():showPanel(nil, nil, true)
            -- else
            --     local params = {}

            --     params.isOpenThrPartyPay = isThirdPayOpen
            --     params.isFirstCharge = isFirstCharge
            --     params.sceneType = payGuideShownType
            --     params.payListType = payBillType

            --     PayGuide.new(params):show(nil, nil, true)
            -- end

            local params = {}

            params.isOpenThrPartyPay = isThirdPayOpen
            params.isFirstCharge = isFirstCharge
            params.sceneType = payGuideShownType
            params.payListType = payBillType

            PayGuide.new(params):show(nil, nil, true)
        end

    else
        local isPay = nk.userData.best and nk.userData.best.paylog == 1 or false

        local roomData = nk.getRoomDataByLevel(self.controller.model.roomInfo.roomType)
        
        local payGuideShownType = 1
        local isThirdPayOpen = isShowPay
        local isFirstCharge = not isPay
        local payBillType = nil
        -- 需要取到当前房间的类型。

        if roomData ~= nil then
            payBillType = roomData.roomGroup
        end

        -- if nk.OnOff:check("firstchargeFavGray") and isThirdPayOpen and isFirstCharge then
        --     --todo
        --     FirChargePayGuidePopup.new():showPanel(nil, nil, true)
        -- else
        --     local params = {}

        --     params.isOpenThrPartyPay = isThirdPayOpen
        --     params.isFirstCharge = isFirstCharge
        --     params.sceneType = payGuideShownType
        --     params.payListType = payBillType

        --     PayGuide.new(params):show(nil, nil, true)
        -- end

        local params = {}

        params.isOpenThrPartyPay = isThirdPayOpen
        params.isFirstCharge = isFirstCharge
        params.sceneType = payGuideShownType
        params.payListType = payBillType

        PayGuide.new(params):show(nil, nil, true)
    end
end


-- 首冲 --
function RoomSceneEx:onChargeFavClick_(tag)
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
                [500] = 2,
                [1000] = 3,
                [5000] = 4,
                [10000] = 5,
                [20000] = 5
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

-- 慈善礼包 --
function RoomSceneEx:onAlmRechargeFavClick_()
    -- body
    AgnChargePayGuidePopup.new():showPanel(nil, nil, true)
end

function RoomSceneEx:onCardTypeClick_()

    -- local msgInfo = {
    --     type = 2,
    --     content = "通知:唉纱布的骄傲比我都看见爱我不打开！",
    --     location = "gograbdealer",
    --     color = "ffed2f"
    -- }
    -- local msgJson = json.encode(msgInfo)

    -- self.controller:SVR_SUONA_BROADCAST_RECV({msg_info = msgJson})
    -- do return end
    
    CardTypePopup.new():showPanel()
end

function RoomSceneEx:onInviteBtnClick_( )
    InvitePlayPopup.new():show()
end

function RoomSceneEx:onLoadedHallTexture_()
    app:enterHallScene({bm.DataProxy:getData(nk.dataKeys.CURRENT_HALL_VIEW), self.jumpAction_})

    local isAdSceneOpen = nk.OnOff:check("unionAd")
    dump(isAdSceneOpen,"onLoadedHallTexture_")
    if isAdSceneOpen and nk.AdSceneSdk then
        nk.AdSceneSdk:setShowRecommendBar(1)
    end
end

function RoomSceneEx:onLoadedHallTextureLogout_()
    app:enterHallScene({HallController.LOGIN_GAME_VIEW, "logout"})

    local isAdSceneOpen = nk.OnOff:check("unionAd")
    if isAdSceneOpen and nk.AdSceneSdk then
        nk.AdSceneSdk:setShowRecommendBar(0)
    end
end

function RoomSceneEx:isOffSlot(isOff)
    if isOff == 1 and self.slotPopup then
        self.slotPopup:closeSlot()
        self.slotPopup = nil
    end
end

function RoomSceneEx:onLoadedHallTextureDoubleLogin_()
    app:enterHallScene({HallController.LOGIN_GAME_VIEW, "doublelogin"})
end

function RoomSceneEx:playDealerBubble(evt)
    local currentTime = bm.getTime()
    self.prevPlayDealerBubbleTime_ = self.prevPlayDealerBubbleTime_ or 0
    if currentTime - self.prevPlayDealerBubbleTime_ > 3 then
        local btype = evt.type or 1
         if btype == 1 then
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
                self:showDealerBubble(DEALER_SPEEK_ARRAY[textId])
            end
        elseif btype == 2 then
             local txtStr = evt.text
            if txtStr and txtStr ~= "" then
                self.prevPlayDealerBubbleTime_ = currentTime
                self:showDealerBubble(txtStr)
            end
        end
  
    end
    
end

-- function RoomSceneEx:showBubble(textId, DEALER_SPEEK_ARRAY)
--     local bubble = RoomChatBubble.new(DEALER_SPEEK_ARRAY[textId], RoomChatBubble.DIRECTION_LEFT)
--     bubble:show(self, display.cx + 60, display.cy + 220)
--     if bubble then
--         bubble:runAction(transition.sequence({cc.DelayTime:create(3), cc.CallFunc:create(function() 
--             bubble:removeFromParent()
--         end)}))
--     end
-- end

function RoomSceneEx:showDealerBubble(text)
    local bubble = RoomChatBubble.new(text, RoomChatBubble.DIRECTION_LEFT)
    bubble:show(self, display.cx + 60, display.cy + 220)
    if bubble then
        bubble:runAction(transition.sequence({cc.DelayTime:create(3), cc.CallFunc:create(function() 
            bubble:removeFromParent()
        end)}))
    end
end

--[[
RoomSceneEx nodes:
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
function RoomSceneEx:createNodes_()
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
    self.nodes.grabDealerUINode = display.newNode():addTo(self, 11)

    self.backgroundTouchHelper_ = bm.TouchHelper.new(self.nodes.backgroundNode, handler(self, self.onBackgroundTouch_))
    self.backgroundTouchHelper_:enableTouch()
end

function RoomSceneEx:onEnter()
    -- nk.SoundManager:preload("roomSounds")
    -- nk.SoundManager:preload("hddjSounds")
    --清空房间聊天记录
    bm.DataProxy:clearData(nk.dataKeys.ROOM_CHAT_HISTORY)

    if device.platform == "android" or device.platform == "ios" then
        cc.analytics:doCommand{command = "beginScene",
                    args = {sceneName = "RoomSceneEx"}}
    end
end

function RoomSceneEx:onExit()
    --清空房间聊天记录
    bm.DataProxy:clearData(nk.dataKeys.ROOM_CHAT_HISTORY)
    if device.platform == "android" or device.platform == "ios" then
        cc.analytics:doCommand{command = "endScene",
                    args = {sceneName = "RoomSceneEx"}}
    end

    nk.schedulerPool:delayCall(function()
        cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    end, 0.1)

    bm.DataProxy:setData(nk.dataKeys.LAST_ENTER_SCENE,"RoomSceneEx")
end

function RoomSceneEx:onCleanup()
    -- 控制器清理
    self.controller:dispose()

    -- 移除事件
    self:removeAllEventListeners()

    -- remove data observer
    if self.actNode then
        self.actNode:release()
    end

    -- 卸载预加载的声音
    -- nk.SoundManager:unload("roomSounds")
    -- nk.SoundManager:unload("hddjSounds")

    -- 清除房间纹理
    display.removeSpriteFramesWithFile("room_texture.plist", "room_texture.png")
    display.removeSpriteFramesWithFile("slot_texture.plist", "slot_texture.png")

    display.removeSpriteFramesWithFile("grabDealerRoom.plist", "grabDealerRoom.png")

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

function RoomSceneEx:onBackgroundTouch_(target, evt)
    if evt == bm.TouchHelper.CLICK then
        self:dispatchEvent({name=RoomSceneEx.EVT_BACKGROUND_CLICK})
    end
end

function RoomSceneEx:doubleLoginOut_(evt)
    nk.socket.RoomSocket:sendLogout()
    self:doBackToLoginByDoubleLogin()
end

return RoomSceneEx