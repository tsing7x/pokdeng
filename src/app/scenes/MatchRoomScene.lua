--
-- Author: Vanfo
-- Date: 2015-10-10 
--
local RoomController = import("app.module.match.matchRoom.MatchRoomController")
local RoomViewPosition = import("app.module.match.matchRoom.views.MatchRoomViewPosition")
local RoomImageButton = import("app.module.match.matchRoom.views.MatchRoomImageButton")
local RoomMenuPopup = import("app.module.match.matchRoom.views.MatchRoomMenuPopup")
local CardTypePopup = import("app.module.match.matchRoom.views.MatchCardTypePopup")
local StorePopup = import("app.module.newstore.StorePopup")
--local CountDownBox = import("app.module.act.CountDownBox")
local SettingAndHelpPopup = import("app.module.settingAndhelp.SettingAndHelpPopup")
local RoomChatBubble = import("app.module.match.matchRoom.views.MatchRoomChatBubble")
local UserInfoPopup = import("app.module.userInfo.UserInfoPopup")
local SlotPopup = import("app.module.slot.SlotPopup")
local HallController = import("app.module.hall.HallController")
local GameReviewPopup = import("app.module.gameReview.GameReviewPopup")
local PayGuide = import("app.module.room.purchGuide.PayGuide")
local FirChargePayGuidePopup = import("app.module.newstore.firChrgGuide.FirChrgPayGuidePopup")
local AgnChargePayGuidePopup = import("app.module.newstore.agnChrgGuide.AgnChrgPayGuidePopup")
-- local SeatInviteView = import("app.module.match.matchRoom.views.MatchSeatInviteView");

local NormalRoomBaseView = import("app.module.match.matchRoom.views.MatchNormalRoomBaseView")
local PersonalRoomBaseView = import("app.module.match.matchRoom.views.MatchPersonalRoomBaseView")
-- local InvitePlayPopup = import("app.module.invitePlay.InvitePlayPopup")

-- local PswEntryPopup = import("app.module.hall.personalRoomDialog.PswEntryPopup")

local AnimationDownNum = import("app.module.common.views.AnimationDownNum")
local MatchExitTipPopup = import("app.module.match.views.MatchExitTipPopup")
local MatchRoomAIView = import("app.module.match.matchRoom.views.MatchRoomAIView")


local MatchRoomScene = class("MatchRoomScene", function()
    return display.newScene("MatchRoomScene")
end)
local logger = bm.Logger.new("MatchRoomScene")

local TOP_BUTTOM_WIDTH   = 78
local TOP_BUTTOM_HEIGHT  = 58

MatchRoomScene.EVT_BACKGROUND_CLICK = "EVT_BACKGROUND_CLICK"

function MatchRoomScene:ctor()
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    self:createNodes_()

    self.sendDealerChipBubbleListenerId_ = bm.EventCenter:addEventListener(nk.eventNames.SEND_DEALER_CHIP_BUBBLE_VIEW, handler(self, self.playDealerBubble))
    self.logoutByMsg_ = bm.EventCenter:addEventListener(nk.eventNames.DOUBLE_LOGIN_LOGINOUT,handler(self, self.doubleLoginOut_))
    --加入重复背景
    --display.newTilesSprite("repeat/room_repeat_tex.png", cc.rect(0, 0, display.width, display.height))

    -- self.roomBaseView_ = NormalRoomBaseView.new():addTo(self.nodes.backgroundNode)
    --[[


    self.backgroundImg_ = display.newSprite("room_background.jpg", display.cx, display.cy)
        :addTo(self.nodes.backgroundNode)

    if display.width / display.height > 1140 / 640 then
        self.backgroundImg_:setScale(display.width / 1140)
    else
        self.backgroundImg_:setScale(display.height / 640)
    end

    -- batchNode
    local batchNode = display.newBatchNode("room_texture.png"):addTo(self.nodes.backgroundNode)

    --加入桌子
    local roomTableLeft = display.newSprite("#room_table.png")
    roomTableLeft:setAnchorPoint(cc.p(1, 0.5))
    roomTableLeft:pos(display.cx + 3, RoomViewPosition.SeatPosition[1].y - roomTableLeft:getContentSize().height * 0.5):addTo(batchNode)
    local roomTableRight = display.newSprite("#room_table.png")
    roomTableRight:setAnchorPoint(cc.p(1, 0.5))
    roomTableRight:setScaleX(-1)
    roomTableRight:pos(display.cx - 3, RoomViewPosition.SeatPosition[1].y - roomTableRight:getContentSize().height * 0.5):addTo(batchNode)

    --房间信息
    self.roomInfo_ = display.newTTFLabel({size=24, text="", color=cc.c3b(0x0, 0xB2, 0x3F)}):pos(display.cx, display.cy):addTo(self.nodes.backgroundNode)

    -- 顶部操作栏
    -- self.topNode_ = display.newNode():pos(display.left + 8, display.top - 8):addTo(self)
    local marginLeft = 32
    local marginTop = -30

    --菜单按钮
    local menuPosX = marginLeft + 10
    local menuPosY = marginTop
    display.newScale9Sprite("#top_btn_bg.png", 0, 0, cc.size(TOP_BUTTOM_WIDTH + 4, TOP_BUTTOM_HEIGHT + 4))
        :pos(menuPosX, menuPosY)
        :addTo(self.topNode_)
    display.newSprite("#room_icon_menu.png")
        :pos(menuPosX, menuPosY)
        :addTo(self.topNode_)
    self.menuBtn_ = cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#rounded_rect_6.png"}, {scale9 = true})
        :setButtonSize(TOP_BUTTOM_WIDTH, TOP_BUTTOM_HEIGHT)
        :onButtonClicked(buttontHandler(self, self.onMenuClick_))
        :pos(menuPosX, menuPosY)
        :addTo(self.topNode_)

    --站起按钮
    local standupPosX = marginLeft + 100
    local standupPosY = marginTop
    self.standupBtn_ = display.newNode():addTo(self.topNode_):hide()
    display.newScale9Sprite("#top_btn_bg.png", 0, 0, cc.size(TOP_BUTTOM_WIDTH + 4, TOP_BUTTOM_HEIGHT + 4))
        :pos(standupPosX, standupPosY)
        :addTo(self.standupBtn_)
    display.newSprite("#room_icon_standup.png")
        :pos(standupPosX, standupPosY)
        :addTo(self.standupBtn_)
    cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#rounded_rect_6.png"}, {scale9 = true})
        :setButtonSize(TOP_BUTTOM_WIDTH, TOP_BUTTOM_HEIGHT)
        :onButtonClicked(buttontHandler(self, self.onStandupClick_))
        :pos(standupPosX, standupPosY)
        :addTo(self.standupBtn_)

    --换桌按钮
    local changeRoomPosX = marginLeft + 100
    local changeRoomPosY = marginTop
    self.changeRoomBtn_ = display.newNode():addTo(self.topNode_):hide()
    display.newScale9Sprite("#top_btn_bg.png", 0, 0, cc.size(TOP_BUTTOM_WIDTH + 4, TOP_BUTTOM_HEIGHT + 4))
        :pos(changeRoomPosX, changeRoomPosY)
        :addTo(self.changeRoomBtn_)
    display.newSprite("#room_icon_change_room.png")
        :pos(changeRoomPosX, changeRoomPosY)
        :addTo(self.changeRoomBtn_)
    cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#rounded_rect_6.png"}, {scale9 = true})
        :setButtonSize(TOP_BUTTOM_WIDTH, TOP_BUTTOM_HEIGHT)
        :onButtonClicked(buttontHandler(self, self.onChangeRoomClick_))
        :pos(changeRoomPosX, changeRoomPosY)
        :addTo(self.changeRoomBtn_)

    --商城按钮
    local shopPosX = display.right - 56
    local shopPosY = marginTop
    display.newScale9Sprite("#top_btn_bg.png", 0, 0, cc.size(TOP_BUTTOM_WIDTH + 4, TOP_BUTTOM_HEIGHT + 4))
        :pos(shopPosX, shopPosY)
        :addTo(self.topNode_)
    display.newSprite("#room_icon_store.png")
        :pos(shopPosX, shopPosY)
        :addTo(self.topNode_)
    self.shopBtn_ = cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#rounded_rect_6.png"}, {scale9 = true})
        :setButtonSize(TOP_BUTTOM_WIDTH, TOP_BUTTOM_HEIGHT)
        :onButtonClicked(buttontHandler(self, self.onShopClick_))
        :pos(shopPosX, shopPosY)
        :addTo(self.topNode_)

    -- 牌局回顾 -- 
    local reviewBtnSize = {
        width = 35,
        height = 60
    }

    local reviewBtnPosXFix = 8

    local reviewPosX = display.right - reviewBtnSize.width / 2 - reviewBtnPosXFix
    local reviewPosY = - display.height / 2

    

    self._reviewBtn = cc.ui.UIPushButton.new({normal = "#room_ic_review_normal.png", pressed = "#room_ic_review_pressed.png"}, {scale9 = true})
        :onButtonClicked(buttontHandler(self, self.onReviewClick_))
        -- :setButtonSize(reviewBtnSize.width, reviewBtnSize.height)

    self._reviewBtn:pos(reviewPosX, reviewPosY)
    self._reviewBtn:addTo(self.topNode_)

    self.shopOffBg_ = display.newSprite("#room_store_off_bg.png", self.shopBtn_:getPositionX() - 16, self.shopBtn_:getPositionY() + 8)
        :addTo(self.topNode_)
    self.shopOffLabel_ = display.newTTFLabel({size=16, color=cc.c3b(0xFE, 0xF5, 0xD0), text=""})
        :pos(self.shopOffBg_:getPositionX() - 6, self.shopOffBg_:getPositionY() + 6)
        :rotation(-45)
        :addTo(self.topNode_)

    --牌型按钮
    local cardTypePosX = marginLeft + 10
    local cardTypePosY = -display.height + 128
    display.newScale9Sprite("#top_btn_bg.png", 0, 0, cc.size(TOP_BUTTOM_WIDTH + 4, TOP_BUTTOM_HEIGHT + 4))
        :pos(cardTypePosX, cardTypePosY)
        :addTo(self.topNode_)
    display.newSprite("#room_icon_card_type.png")
        :pos(cardTypePosX, cardTypePosY)
        :addTo(self.topNode_)
    self.cardTypeBtn_ = cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#rounded_rect_6.png"}, {scale9 = true})
        :setButtonSize(TOP_BUTTOM_WIDTH, TOP_BUTTOM_HEIGHT)
        :onButtonClicked(buttontHandler(self, self.onCardTypeClick_))
        :pos(cardTypePosX, cardTypePosY)
        :addTo(self.topNode_)


    self.toDealerSendChip_ = cc.ui.UIPushButton.new({normal="#room_dealer_send_chip_up.png", pressed="#room_dealer_send_chip_down.png"})
        :onButtonClicked(buttontHandler(self, self.toDelearSendChipHandler))
        :pos(display.cx - 68, -60)
        :addTo(self.topNode_)


    local isFirstSendDearlerChip = cc.UserDefault:getInstance():getBoolForKey(nk.cookieKeys.USER_FIRST_DEALER_SEND_CHIP .. nk.userData.uid, false)

    if  not isFirstSendDearlerChip then

        self.sendDealerChipIcon = display.newSprite("#room_dealer_send_chip_prompt_icon.png")
        self.sendDealerChipIcon:setScaleX(0.7)
        self.sendDealerChipIcon:setScaleY(0.7)
        self.sendDealerChipIcon:pos(display.cx - 68, -60)
        self.sendDealerChipIcon:addTo(self.topNode_)

    end
 --]]
    --老虎机
    if nk.config.SLOT_ENABLED and nk.userData and nk.userData.GAMBLE_PORT and nk.userData.GAMBLE_PORT > 0 then
        display.addSpriteFrames("slot_texture.plist", "slot_texture.png", function()
            self.slotPopup = SlotPopup.new(true):addTo(self.nodes.popupNode):show()
        end)
    end

   
   --AI在房间最上层
    self.matchRoomAIView_=MatchRoomAIView.new(self)
    :addTo(self.nodes.AINode)
    :hide()

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
    -- self.actNode = CountDownBox.new(self.ctx)
    --                 :pos(display.right, display.bottom)
    --                 :addTo(self.nodes.lampNode)

    --创建其他元素
    self.controller:createNodes()

    self:setChangeRoomButtonMode(1)

    -- if nk.OnOff:check("roomInvite") then
    --     local lastLoginType = nk.userDefault:getStringForKey(nk.cookieKeys.LAST_LOGIN_TYPE)
    --     if lastLoginType ==  "FACEBOOK" then
    --         self.seatInviteView = SeatInviteView.new(self.ctx):addTo(self.nodes.seatNode)--:hide()
    --     end
    -- end



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

function MatchRoomScene:toDelearSendChipHandler()
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

            if (nk.userData["aUser.money"] -  tonumber(roomData.fee) ) > roomData.minBuyIn then
                self.delearFeeRequest_ = self.delearFeeRequest_ + 1
                self.delearFeeRequests_[self.delearFeeRequest_] = nk.http.sendDealerChip(roomData.blind,1,function(callData)
                   if callData then
                        nk.userData["aUser.money"] = callData.money
                        nk.server:sendDealerChip(callData.subMoney or roomData.fee,1)
                   end
                    self.delearFeeRequests_[self.delearFeeRequest_] = nil
                end,function(errData)
                    if errData and (checkint(errData.errorCode) == -2 or checkint(errData.errorCode) == -3) then
                        nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "SELF_CHIP_NO_ENOUGH_SEND_DELEAR"))
                    end
                    self.delearFeeRequests_[self.delearFeeRequest_] = nil
                end)
               
            else
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "SELF_CHIP_NO_ENOUGH_SEND_DELEAR"))
            end
            cc.UserDefault:getInstance():setBoolForKey(nk.cookieKeys.USER_FIRST_DEALER_SEND_CHIP.. nk.userData.uid, true)
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

function MatchRoomScene:setStoreDiscount(discount)
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

function MatchRoomScene:setRoomInfoText(roomInfo)
    if self.roomBaseView_ and self.roomBaseView_["setRoomInfoText"]then
        self.roomBaseView_:setRoomInfoText(roomInfo)

    end
end


function MatchRoomScene:setRoomTipText(text)
    if self.roomBaseView_ and self.roomBaseView_["setRoomTipText"]then
        self.roomBaseView_:setRoomTipText(text)
    end
end

function MatchRoomScene:setMatchRoomIndicator(data)
     if self.roomBaseView_ and self.roomBaseView_["setMatchRoomIndicator"]then
        self.roomBaseView_:setMatchRoomIndicator(data)
    end
end
function MatchRoomScene:setTimeMatchIndicator(data)
    if self.roomBaseView_ and self.roomBaseView_["setMatchRoomIndicator"]then
        self.roomBaseView_:setTimeMatchIndicator(data)
    end
end

function MatchRoomScene:setSlotBlind(roomInfo)
    
    if self.slotPopup then
        self.slotPopup:setPreBlind(roomInfo)
    end
end

function MatchRoomScene:setChangeRoomButtonMode(mode)

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


function MatchRoomScene:setMatchInviteButtonVisible(visible)
    if self.roomBaseView_ and self.roomBaseView_["setMatchInviteButtonVisible"] then
        self.roomBaseView_:setMatchInviteButtonVisible(visible)
    end
end

function MatchRoomScene:onStandupClick_()
    if self.ctx.model:isSelfInGame() then
        -- nk.ui.Dialog.new({
        --     messageText = bm.LangUtil.getText("ROOM", "STAND_UP_IN_GAME_MSG"), 
        --     hasCloseButton = false,
        --     showStandUpTips = 1,
        --     callback = function (type)
        --         if type == nk.ui.Dialog.SECOND_BTN_CLICK then
        --             nk.server:standUp()
        --         end
        --     end,
        --     standUpCallback = function()
        --         self.controller:setOverStandUp();
        --     end
        -- }):show()

        -- MatchExitTipPopup.new(
        --     function()
        --         nk.server:standUp()
        --     end
        -- ):show()
    else
        nk.server:standUp()
    end
end

function MatchRoomScene:doBackToHall(msg, jumpType)
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

function MatchRoomScene:doBackToLogin(msg)
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

function MatchRoomScene:doBackToLoginByDoubleLogin(msg)
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

function MatchRoomScene:onMenuClick_()
    self.menuPop_ = RoomMenuPopup.new(function(tag)
        if tag == 1 then
            --返回
            --定时赛直接强退
            if self.ctx.model.roomInfo.matchType > 100 then
                if self.ctx.model:isSelfInMatch() then
                    nk.ui.Dialog.new({
                        messageText = bm.LangUtil.getText("MATCH", "MATCH_EXIT_TIP"), 
                        hasCloseButton = false,
                        callback = function (type)
                            if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                                 nk.server:matchForceExitGame()
                            end
                        end
                    }):show()
                else
                    if self.ctx.model:isSelfKnockOut() then
                        --如果被淘汰出局，需要调用退赛协议
                        nk.server:matchQuit()
                    end             
                    -- nk.server:logoutRoom()
                    self:doBackToHall()
                end
                return
            end
            --以下为定人赛逻辑、
            if self.ctx.model:isSelfInMatch() then
                if self.ctx.model.gameInfo.gameStatus == consts.SVR_MATCH_GAME_STATUS.APPLY then

                    local requestBackToHall = function()
                            self.matchOutRequestId_ = nk.http.matchOut(function(data)
                                    self.matchOutRequestId_ = nil
                                     if data and data.money then
                                        nk.userData["aUser.money"] = tonumber(data.money)
                                     end
                                     self:doBackToHall()
                                end, function(errorCode)
                                    self.matchOutRequestId_ = nil
                                    nk.TopTipManager:showTopTip(T("退赛失败，请继续比赛"))
                                end
                            )
                        end

                    self.matchExitLeftTimeRequestId_ = nk.http.getMatchExitLeftTime(self.ctx.model.roomInfo.matchType,
                    function(data)
                        self.matchExitLeftTimeRequestId_ = nil
                        if tonumber(data.remainTime) > 0 then
                            MatchExitTipPopup.new(requestBackToHall, data.remainTime):show()
                       else
                            requestBackToHall()
                       end
                    end, function(errData)
                        self.matchExitLeftTimeRequestId_ = nil
                        requestBackToHall()
                    end)

                else
                   -- nk.TopTipManager:showTopTip(T("比赛已经开始，不可退赛"))
                    nk.server:matchExitGetLeftTime()
                end
            else
                if self.ctx.model:isSelfKnockOut() then
                    --如果被淘汰出局，需要调用退赛协议
                    nk.server:matchQuit()
                end             
                -- nk.server:logoutRoom()
                self:doBackToHall()
            end
        elseif tag == 2 then
            --换桌
            -- if self.ctx.model:isSelfInGame() then
            --     nk.ui.Dialog.new({
            --         messageText = bm.LangUtil.getText("ROOM", "CHANGE_ROOM_IN_GAME_MSG"), 
            --         hasCloseButton = false,
            --         callback = function (type)
            --             if type == nk.ui.Dialog.SECOND_BTN_CLICK then
            --                 self:onChangeRoom_()
            --             end
            --         end
            --     }):show()
            -- else              
            --     self:onChangeRoom_()
            -- end
            nk.TopTipManager:showTopTip(T("比赛场不可换桌"))
        elseif tag == 3 then
            --弹出设置菜单
            SettingAndHelpPopup.new(true):show()
        elseif tag == 4 then
            UserInfoPopup.new():show(true)
        end
    end):showPanel()
end

function MatchRoomScene:onChangeRoomClick_()
    -- self:onChangeRoom_()
    -- self.menuPop_.callBack_(2)
    nk.TopTipManager:showTopTip(T("比赛场不可换桌"))
end

function MatchRoomScene:playNowChangeRoom()
    self:onChangeRoom_(false, true)
end

function MatchRoomScene:removeLoading()
    if self.roomLoading_ then 
        self.roomLoading_:removeFromParent()
        self.roomLoading_ = nil
    end
end

function MatchRoomScene:onChangeRoom_(doNotUpdateRoomInfo, isPlayNow)
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


function MatchRoomScene:onSearchPersonalRoom(data)
    -- local ret = data.ret
    -- dump(data,"onSearchPersonalRoom")
    -- if ret == 0 then
    --      if data.hasPwd == 1 then
    --         --有密码，弹密码框
    --         PswEntryPopup.new(data, handler(self, self.onPswPopCallback)):show() 
    --         --传入这个回调 handler(self,self.onPswPopCallback)
    --     else
    --         --无密码，直接进
    --         nk.server:loginPersonalRoom(nil,data.tableID)

    --     end

    -- end
end

local sitid_ = 0
function MatchRoomScene:onReviewClick_()
    do return end
    --GameReviewPopup.new():show()
    local player = {}
    player.betNeedChips = 1
     player.betChips=2
     player.seatId = sitid_
     sitid_ = sitid_+1
     if sitid_ == 9 then sitid_ = 0 end
    self.ctx.chipManager:betChip(player) 
end


function MatchRoomScene:onMatchInviteClick_()
    self:setMatchInviteButtonVisible(false)
    nk.http.matchBroadcastRoomReq(function(data)
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("MATCH", "INVITE_HAD_SEND_TIP"))
    end,function(errData)
        dump(errData, "nk.http.matchBroadcastRoomReq.errData :================")
    end)
end

function MatchRoomScene:onShopClick_()
   -- StorePopup.new(2):showPanel()
end

function MatchRoomScene:onChargeFavClick_()
    -- body

    local isThirdPayOpen = nk.OnOff:check("payGuide")

    if nk.OnOff:check("firstchargeFavGray") and isThirdPayOpen then
        --todo
        FirChargePayGuidePopup.new():showPanel()
    else
        local params = {}

        params.isOpenThrPartyPay = isThirdPayOpen
        params.isFirstCharge = true
        params.sceneType = 1
        params.payListType = nil
        params.isSellCashCoin = true

        if isThirdPayOpen then
            --todo
            PayGuide.new(params):show()
        else
            local cashPaymentPageIdx = 2
            StorePopup.new(cashPaymentPageIdx):showPanel()
        end
        
    end
end

-- 慈善礼包 --
function MatchRoomScene:onAlmRechargeFavClick_()
    -- body
    AgnChargePayGuidePopup.new():showPanel(nil, nil, true)
end

function MatchRoomScene:onCardTypeClick_()
    -- local msgInfo = {
    --     type = 2,
    --     content = "通知:唉纱布的骄傲比我都看见爱我不打开！     ",
    --     location = "matchlist",
    --     color = "ffed2f"
    -- }
    -- local msgJson = json.encode(msgInfo)

    -- self.controller:SVR_SUONA_BROADCAST_RECV({msg_info = msgJson})
    -- do return end
    
    CardTypePopup.new():showPanel()
end

function MatchRoomScene:onInviteBtnClick_( )
    -- InvitePlayPopup.new():show()
    dump("Can't Invite Friends In MatchRoom!")
end

function MatchRoomScene:onLoadedHallTexture_()
    app:enterHallScene({bm.DataProxy:getData(nk.dataKeys.CURRENT_HALL_VIEW), self.jumpAction_})

    local isAdSceneOpen = nk.OnOff:check("unionAd")
    dump(isAdSceneOpen,"onLoadedHallTexture_")
    if isAdSceneOpen and nk.AdSceneSdk then
        nk.AdSceneSdk:setShowRecommendBar(true)
    end
end

function MatchRoomScene:onLoadedHallTextureLogout_()
    app:enterHallScene({HallController.LOGIN_GAME_VIEW, "logout"})

    local isAdSceneOpen = nk.OnOff:check("unionAd")
    if isAdSceneOpen and nk.AdSceneSdk then
        nk.AdSceneSdk:setShowRecommendBar(false)
    end
end

function MatchRoomScene:onLoadedHallTextureDoubleLogin_()
    app:enterHallScene({HallController.LOGIN_GAME_VIEW, "doublelogin"})
end


function MatchRoomScene:playAnimCountDown(time)
    self.animationDownNum_ = AnimationDownNum.new({
        parent=self,
        px=display.cx,
        py=display.cy+50, 
        time=time, 
        scale=0.5, 
        refreshCallback=function(retVal)
            -- self:refreshRenderInfo(retVal);
        end,
        callback=function()
            -- self:endDownTimeCallback();
            -- nk.TopTipManager:showTopTip( bm.LangUtil.getText("MATCH", "GAME_START"))
            self:setRoomTipText("")
            bm.EventCenter:dispatchEvent({name = nk.eventNames.SEND_DEALER_CHIP_BUBBLE_VIEW, text = bm.LangUtil.getText("MATCH", "GAME_START"),type = 2})
        end});
end

function MatchRoomScene:playDealerBubble(evt)

    -- evt.type 1:送荷官消费 2：普通tips
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
function MatchRoomScene:setAIState(visible)
    if self.matchRoomAIView_ then
        if visible then
            self.matchRoomAIView_:show()
        else
            self.matchRoomAIView_:hide()
        end
    end
end
--[[
function MatchRoomScene:showBubble(textId, DEALER_SPEEK_ARRAY)
    local bubble = RoomChatBubble.new(DEALER_SPEEK_ARRAY[textId], RoomChatBubble.DIRECTION_LEFT)
    bubble:show(self, display.cx + 60, display.cy + 220)
    if bubble then
        bubble:runAction(transition.sequence({cc.DelayTime:create(3), cc.CallFunc:create(function() 
            bubble:removeFromParent()
        end)}))
    end
end
--]]

function MatchRoomScene:showDealerBubble(text)
    local bubble = RoomChatBubble.new(text, RoomChatBubble.DIRECTION_LEFT)
    bubble:show(self, display.cx + 60, display.cy + 220)
    if bubble then
        bubble:runAction(transition.sequence({cc.DelayTime:create(3), cc.CallFunc:create(function() 
            bubble:removeFromParent()
        end)}))
    end
end

--[[
MatchRoomScene nodes:
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
function MatchRoomScene:createNodes_()
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
    self.nodes.AINode = display.newNode():addTo(self, 11)

    self.backgroundTouchHelper_ = bm.TouchHelper.new(self.nodes.backgroundNode, handler(self, self.onBackgroundTouch_))
    self.backgroundTouchHelper_:enableTouch()
end

function MatchRoomScene:onEnter()
    nk.SoundManager:preload("roomSounds")
    nk.SoundManager:preload("hddjSounds")
    --清空房间聊天记录
    bm.DataProxy:clearData(nk.dataKeys.ROOM_CHAT_HISTORY)

    if device.platform == "android" or device.platform == "ios" then
        cc.analytics:doCommand{command = "beginScene",
                    args = {sceneName = "MatchRoomScene"}}
    end
end

function MatchRoomScene:onExit()
    --清空房间聊天记录
    bm.DataProxy:clearData(nk.dataKeys.ROOM_CHAT_HISTORY)
    if device.platform == "android" or device.platform == "ios" then
        cc.analytics:doCommand{command = "endScene",
                    args = {sceneName = "MatchRoomScene"}}
    end

    nk.schedulerPool:delayCall(function()
        cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    end, 0.1)

    bm.DataProxy:setData(nk.dataKeys.LAST_ENTER_SCENE,"MatchRoomScene")
end

function MatchRoomScene:onCleanup()
    -- 控制器清理
    self.controller:dispose()

    -- 移除事件
    self:removeAllEventListeners()

    -- remove data observer
    -- if self.actNode then
    --     self.actNode:release()
    -- end

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

    if self.matchExitLeftTimeRequestId_ then
        nk.http.cancel(self.matchExitLeftTimeRequestId_)
        self.matchExitLeftTimeRequestId_ = nil
    end

    if self.matchOutRequestId_ then
        nk.http.cancel(self.matchOutRequestId_)
        self.matchOutRequestId_ = nil
    end

end

function MatchRoomScene:onBackgroundTouch_(target, evt)
    if evt == bm.TouchHelper.CLICK then
        self:dispatchEvent({name=MatchRoomScene.EVT_BACKGROUND_CLICK})
    end
end

function MatchRoomScene:doubleLoginOut_(evt)
    nk.socket.RoomSocket:sendLogout()
    self:doBackToLoginByDoubleLogin()
end

return MatchRoomScene