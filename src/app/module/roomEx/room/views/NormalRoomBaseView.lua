
local RoomViewPosition = import("app.module.roomEx.room.views.RoomViewPosition")
local NormalRoomBaseView = class("NormalRoomBaseView",function()
	return display.newNode()
end)


local TOP_BUTTOM_WIDTH   = 78
local TOP_BUTTOM_HEIGHT  = 58


function NormalRoomBaseView:ctor(ctx)
	self.ctx = ctx

    self:setNodeEventEnabled(true)

	self.backgroundImg_ = display.newSprite("room_background.jpg", display.cx, display.cy)
        :addTo(self)

    if display.width / display.height > 1140 / 640 then
        self.backgroundImg_:setScale(display.width / 1140)
    else
        self.backgroundImg_:setScale(display.height / 640)
    end

    if nk.config.CHRISTMAS_THEME_ENABLED then
        --todo

        local snowWindwPosShift = {
            x = 1,
            y = 1
        }

        local getSnowPosXYByRot = {
            [1] = function(snowWindwSpr)
                -- body

                return snowWindwSpr:getContentSize().width / 2 + snowWindwPosShift.x, snowWindwSpr:getContentSize().height / 2 + snowWindwPosShift.y
            end,

            [2] = function(snowWindwSpr)
                -- body

                return snowWindwSpr:getContentSize().width / 2 + snowWindwPosShift.x, display.height - snowWindwSpr:getContentSize().height / 2 - snowWindwPosShift.y
            end,

            [3] = function(snowWindwSpr)
                -- body
                return display.width - snowWindwSpr:getContentSize().width / 2 - snowWindwPosShift.x, display.height - snowWindwSpr:getContentSize().height / 2 - snowWindwPosShift.y
            end,

            [4] = function(snowWindwSpr)
                -- body
                return display.width - snowWindwSpr:getContentSize().width / 2 - snowWindwPosShift.x, snowWindwSpr:getContentSize().height / 2 + snowWindwPosShift.y
            end
        }

        self.chirstmasAmbNode_ = display.newNode()
            :addTo(self)

        for i = 1, 4 do
            local snowWindwEffect = display.newSprite("#christ_snowCorner_right.png")
                :rotation(90 * i)

            snowWindwEffect:pos(getSnowPosXYByRot[i](snowWindwEffect))
                :addTo(self.chirstmasAmbNode_)
        end
    end


     --一把真皮凳子
    display.newSprite("#grab_dealer_seat.png")
    :addTo(self)
    :pos(RoomViewPosition.SeatPosition[10].x,RoomViewPosition.SeatPosition[10].y+10)
    -- batchNode
    local batchNode = display.newBatchNode("room_texture.png"):addTo(self)

    

    --加入桌子
    local roomTableLeft = display.newSprite("#room_table.png")
    roomTableLeft:setAnchorPoint(cc.p(1, 0.5))
    roomTableLeft:pos(display.cx + 3, RoomViewPosition.SeatPosition[1].y - roomTableLeft:getContentSize().height * 0.5):addTo(batchNode)
    local roomTableRight = display.newSprite("#room_table.png")
    roomTableRight:setAnchorPoint(cc.p(1, 0.5))
    roomTableRight:setScaleX(-1)
    roomTableRight:pos(display.cx - 3, RoomViewPosition.SeatPosition[1].y - roomTableRight:getContentSize().height * 0.5):addTo(batchNode)

    --房间信息
    self.roomInfo_ = display.newTTFLabel({size=24, text="", color=cc.c3b(0x0, 0xB2, 0x3F)}):pos(display.cx, display.cy):addTo(self)

    local marginLeft = 32
    local marginTop = -30

    --菜单按钮
    self.topNode_ = display.newNode():pos(display.left + 8, display.top - 8):addTo(self)
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
    local isShowPay = nk.OnOff:check("payGuide")
    local isPay = nk.userData.best and nk.userData.best.paylog == 1 or false
    -- local isAlmChargeFavPay = nk.userData.bagPayList and nk.userData.bagPayList.almRechgFav == 1 or false

    local shopPosX = display.right - 56
    local shopPosY = marginTop

    -- 暂时写死，未有现金币首次充值优惠！
    -- 报错，未能及时取到 model.roomInfo.roomType, 暂行放置！
    -- if self.ctx.model.roomInfo.rmType == consts.ROOM_TYPE_EX.GRAB_CASH then
    --     --todo
    --     isPay = true
    -- end
    if isShowPay and not isPay then
        --todo
        local firstChargeIconPath = nil

        if device.platform == "android" or device.platform == "windows" then
            --todo
            if nk.OnOff:check("firstchargeFavGray") then
                --todo
                firstChargeIconPath = "#chgFirFav_entry.png"
            else
                firstChargeIconPath = "#chargeFav_entry.png"
            end
        elseif device.platform == "ios" then
            --todo
            if nk.OnOff:check("firstchargeFavGray") then
                --todo
                firstChargeIconPath = "#chgFirFav_entry.png"
            else
                firstChargeIconPath = "#chargeFav_entry_ios.png"
            end
            -- firstChargeIconPath = "#chargeFav_entry_ios.png"
        end

        self._firstChargeEntryBtn = cc.ui.UIPushButton.new(firstChargeIconPath, {scale9 = false})
            :pos(shopPosX, shopPosY)
            :addTo(self.topNode_)
            :onButtonClicked(buttontHandler(self, self._onChargeFavCallBack))

    else

        local rechargeFavAccess = nk.userData.bagPayList and nk.userData.bagPayList.access == 1 or false
        if nk.OnOff:check("rechargeFavGray") and isShowPay and isPay and rechargeFavAccess then
            --todo
            local reChargeIconResKey = {}

            reChargeIconResKey[1] = "#chgAgnFav_entry_nor.png"  -- nor
            reChargeIconResKey[2] = "#chgAgnFav_entry_pre.png"  -- pre
            reChargeIconResKey[3] = "#chgAgnFav_entry_nor.png"  -- dis

            self._almRechargeEntryBtn = cc.ui.UIPushButton.new({normal = reChargeIconResKey[1], pressed = reChargeIconResKey[2],
                disabled = reChargeIconResKey[3]}, {scale9 = false})
                :onButtonClicked(buttontHandler(self, self.onAlmRechargeFavCallBack_))
                :pos(shopPosX, shopPosY)
                :addTo(self.topNode_)
        else
            if device.platform == "ios" and not isShowPay and isPay then
                --todo
                self._firstChargeEntryBtn = cc.ui.UIPushButton.new("#chargeFav_entry_ios.png", {scale9 = false})
                    :pos(shopPosX, shopPosY)
                    :addTo(self.topNode_)
                    :onButtonClicked(buttontHandler(self, self.onShopClick_))
            else
                self.shopIcon_ = display.newSprite("#room_ic_quickPay.png")
                    :pos(shopPosX, shopPosY)
                    :addTo(self.topNode_)

                local flagPosAdjust = {
                    x = 2,
                    y = 22
                }

                self.shopFg_ = display.newSprite("#room_fg_quickPay.png")
                    :pos(shopPosX - flagPosAdjust.x, shopPosY - flagPosAdjust.y)
                    :addTo(self.topNode_)

                self._quickPayBtn = cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png" --[[, pressed = "#rounded_rect_6.png"]]}, {scale9 = true})
                    :setButtonSize(TOP_BUTTOM_WIDTH, TOP_BUTTOM_HEIGHT)
                    :onButtonClicked(buttontHandler(self, self.onShopClick_))
                    :pos(shopPosX, shopPosY)
                    :addTo(self.topNode_)
                
                self.shopOffBg_ = display.newSprite("#room_store_off_bg.png", self._quickPayBtn:getPositionX() - 16, self._quickPayBtn:getPositionY() + 8)
                    :addTo(self.topNode_)

                self.shopOffLabel_ = display.newTTFLabel({size=16, color=cc.c3b(0xFE, 0xF5, 0xD0), text=""})
                    :pos(self.shopOffBg_:getPositionX() - 6, self.shopOffBg_:getPositionY() + 6)
                    :rotation(-45)
                    :addTo(self.topNode_)
                    
                self:setStoreDiscount()
            end
        end
        -- display.newScale9Sprite("#top_btn_bg.png", 0, 0, cc.size(TOP_BUTTOM_WIDTH + 4, TOP_BUTTOM_HEIGHT + 4))
        --     :pos(shopPosX, shopPosY)
        --     :addTo(self.topNode_)

        -- display.newSprite("#room_icon_store.png")
        --     :pos(shopPosX, shopPosY)
        --     :addTo(self.topNode_)

        -- self.shopBtn_ = cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#rounded_rect_6.png"}, {scale9 = true})
        --     :setButtonSize(TOP_BUTTOM_WIDTH, TOP_BUTTOM_HEIGHT)
        --     :onButtonClicked(buttontHandler(self, self.onShopClick_))
        --     :pos(shopPosX, shopPosY)
        --     :addTo(self.topNode_)

        -- self.shopOffBg_ = display.newSprite("#room_store_off_bg.png", self.shopBtn_:getPositionX() - 16, self.shopBtn_:getPositionY() + 8)
        --     :addTo(self.topNode_)

        -- self.shopOffLabel_ = display.newTTFLabel({size=16, color=cc.c3b(0xFE, 0xF5, 0xD0), text=""})
        --     :pos(self.shopOffBg_:getPositionX() - 6, self.shopOffBg_:getPositionY() + 6)
        --     :rotation(-45)
        --     :addTo(self.topNode_)
    end

    -- 牌局回顾 -- 
    local reviewBtnSize = {
        width = 35,
        height = 60
    }

    local reviewBtnPosXFix = 8

    local reviewPosX = display.right - reviewBtnSize.width / 2 - reviewBtnPosXFix
    local reviewPosY = - display.height / 2

    --[[display.newSprite("#top_btn_bg.png", 0, 0, cc.size(TOP_BUTTOM_WIDTH + 8, TOP_BUTTOM_HEIGHT + 8))
        :pos(reviewPosX, reviewPosY)
        :addTo(self.topNode_)

    display.newSprite("#room_ic_review.png")
        :pos(reviewPosX, reviewPosY)
        :addTo(self.topNode_)

    self._reviewBtn = cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#rounded_rect_6.png"}, {scale9 = true})
        :setButtonSize(TOP_BUTTOM_WIDTH + 8, TOP_BUTTOM_HEIGHT + 8)
        :onButtonClicked(buttontHandler(self, onReviewClick))
        :pos(reviewPosX, reviewPosY)
        :addTo(self.topNode_)]]

    -- self._reviewBtn = cc.ui.UIPushButton.new({normal = "#room_ic_review_normal.png", pressed = "#room_ic_review_pressed.png"}, {scale9 = true})
    --     :onButtonClicked(buttontHandler(self, self.onReviewClick_))
    --     -- :setButtonSize(reviewBtnSize.width, reviewBtnSize.height)

    -- self._reviewBtn:pos(reviewPosX, reviewPosY)
    -- self._reviewBtn:addTo(self.topNode_)

   
   
    

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


     display.newSprite("#card_record_bt_bg.png")
    :addTo(self.topNode_)
    :pos(cardTypePosX+90, cardTypePosY)


    self.cardNode_ = display.newNode()
    :addTo(self.topNode_)
    :pos(cardTypePosX+90, cardTypePosY)

    cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png"},{scale9 = true})
    :setButtonSize(74,66)
    :onButtonClicked(buttontHandler(self, self.onRecordClick_))
    :addTo(self.topNode_)
    :pos(cardTypePosX+90, cardTypePosY)
    --:pos(reviewPosX-20-97,reviewPosY-40-153)


    self.toDealerSendChip_ = cc.ui.UIPushButton.new({normal="#room_dealer_send_chip_up.png", pressed="#room_dealer_send_chip_down.png"})
        :onButtonClicked(buttontHandler(self, self.toDelearSendChipHandler))
        :pos(display.cx - 110, -60)
        :addTo(self.topNode_)
       -- :hide()


    local isFirstSendDearlerChip = cc.UserDefault:getInstance():getBoolForKey(nk.cookieKeys.USER_FIRST_DEALER_SEND_CHIP .. nk.userData.uid, false)

    if  not isFirstSendDearlerChip then

        self.sendDealerChipIcon = display.newSprite("#room_dealer_send_chip_prompt_icon.png")
        self.sendDealerChipIcon:setScaleX(0.7)
        self.sendDealerChipIcon:setScaleY(0.7)
        self.sendDealerChipIcon:pos(display.cx - 110, -60)
        self.sendDealerChipIcon:addTo(self.topNode_)
        --self.sendDealerChipIcon:hide()--隐藏送荷官小费按钮
    end


    local matchInvitePosX = display.right - 150
    local matchInvitePosY =  -37
    self.matchInviteBtn_ = display.newNode():addTo(self.topNode_):hide()
    display.newScale9Sprite("#top_btn_bg.png", 0, 0, cc.size(TOP_BUTTOM_WIDTH + 4, TOP_BUTTOM_HEIGHT + 4))
        :pos(matchInvitePosX, matchInvitePosY)
        :addTo(self.matchInviteBtn_)
    display.newSprite("#room_icon_match_invite.png")
        :pos(matchInvitePosX, matchInvitePosY)
        :addTo(self.matchInviteBtn_)
    cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#rounded_rect_6.png"}, {scale9 = true})
        :setButtonSize(TOP_BUTTOM_WIDTH, TOP_BUTTOM_HEIGHT)
        :onButtonClicked(buttontHandler(self, self.onGrabInviteClick_))
        :pos(matchInvitePosX, matchInvitePosY)
        :addTo(self.matchInviteBtn_)
    display.newTTFLabel({text = bm.LangUtil.getText("GRAB_DEALER","INVITE_TO_GRAB"),color = cc.c3b(0xde, 0xe9, 0xf1), size = 24, align = ui.TEXT_ALIGN_CENTER})
    :pos(matchInvitePosX, matchInvitePosY - TOP_BUTTOM_HEIGHT*0.5 -12)
    :addTo(self.matchInviteBtn_)

    self:updataCards({nil,1})
    self:addDataObservers()
end

function NormalRoomBaseView:addDataObservers()
    -- body
    self.onChargeFavOnOffObserver = bm.DataProxy:addDataObserver(nk.dataKeys.CHARGEFAV_ONOFF, handler(self, self.refreshFirstChargeFavEntryUi))
    self.onAlmRechargeFavOnOffObserver = bm.DataProxy:addDataObserver(nk.dataKeys.ALMRECHARGEFAV_ONOFF, handler(self, self.refreshAlmRechargeFavEntryUi))
    self.onSelfCardsObserver = bm.DataProxy:addDataObserver(nk.dataKeys.PRE_GAME_CARDS, handler(self, self.updataCards))
end

function NormalRoomBaseView:updataCards(data)
    local result = data[2]

    if self.icon_bg_ then
        self.icon_bg_:removeFromParent()
        self.icon_bg_ = nil
        self.icon_:removeFromParent()
        self.icon_ = nil
    end

    if self.pokerCardList then
        for i=1,#self.pokerCardList do
            self.pokerCardList[i]:removeFromParent()
        end
        self.pokerCardList = nil
        
    end

    local pokerCard = nk.ui.PokerCard
    local selfCards = data[1]
    if not selfCards then  selfCards  = {0x2B,0x29} end
    self.pokerCardList = {}
    self.cardIndex_ = 0
    for i = 1,#selfCards do

        self.pokerCardList[i] = pokerCard.new()
                        :setCard(selfCards[i])
                        :showFront()
        self.pokerCardList[i]:scale(.35)
        self.pokerCardList[i]:addTo(self.cardNode_)
        :pos(i*10-18,0)
    end

    self.pokerCardList[1]:rotation(-12)
    self.pokerCardList[2]:rotation(0)
    if self.pokerCardList[3] then
        self.pokerCardList[3]:rotation(12)
    else
        self.pokerCardList[2]:rotation(8)
    end

    --以下为输赢设置。。。
    if result>0 then
        self.icon_bg_ = display.newSprite("#gameRecord_win_bg.png")
        :addTo(self.cardNode_)
        :pos(-5,-12)

        self.icon_ = display.newSprite("#gameRecord_win_icon.png")
        :addTo(self.cardNode_)
        :pos(-5,-12)

    elseif result==0 then
        self.icon_bg_ = display.newSprite("#gameRecord_dogfall_bg.png")
        :addTo(self.cardNode_)
        :pos(-5,-12)

        self.icon_ = display.newSprite("#gameRecord_dogfall_icon.png")
        :addTo(self.cardNode_)
        :pos(-5,-12)
    else
        self.icon_bg_ = display.newSprite("#gameRecord_lose_bg.png")
        :addTo(self.cardNode_)
        :pos(-5,-12)

        self.icon_ = display.newSprite("#gameRecord_lose_icon.png")
        :addTo(self.cardNode_)
        :pos(-5,-12)

    end
end

function NormalRoomBaseView:setStoreDiscount(discount)
    
    if self.shopOffBg_ == nil then
        --todo
        return
    end

    if discount and discount ~= 1 then

        self.shopOffBg_:show()
        self.shopOffLabel_:show()
        self.shopOffLabel_:setString(string.format("%+d%%", math.round((discount - 1) * 100)))
    else
        self.shopOffBg_:hide()
        self.shopOffLabel_:hide()
    end
end

function NormalRoomBaseView:setRoomInfoText(roomInfo)
    
    local roomFiled = bm.LangUtil.getText("HALL", "ROOM_LEVEL_TEXT")[1]
    local info = bm.LangUtil.getText("ROOM", "ROOM_INFO", roomFiled, roomInfo.tid, roomInfo.blind)
    self.roomInfo_:setString(info)
    --self.roomInfo_:setString(T("抢庄房")..roomInfo.tid)

    --self.roomInfo_:setString("NEW GAME TEST ROOM\n"..roomInfo.tid.."\n底注:"..roomInfo.blind)
end

function NormalRoomBaseView:onGrabInviteClick_()  
    if self. ctx.scene["onGrabInviteClick_"] then
        self.ctx.scene:onGrabInviteClick_()
    end
end
function NormalRoomBaseView:setMatchInviteButtonVisible(visible)
    if not visible then
        self.matchInviteBtn_:hide()
    else
        self.matchInviteBtn_:show()
    end
end
function NormalRoomBaseView:setChangeRoomButtonMode(mode)
    if mode == 1 then
         self.changeRoomBtn_:show()
        self.standupBtn_:hide()
    else
         self.changeRoomBtn_:hide()
        self.standupBtn_:show()
    end
end

function NormalRoomBaseView:refreshFirstChargeFavEntryUi(isOpen)
    -- body
    if not isOpen then
        --todo

        if self._firstChargeEntryBtn then
            --todo
            self._firstChargeEntryBtn:removeFromParent()
            self._firstChargeEntryBtn = nil

            -- 做出判断,绘制慈善礼包UI Below!--
            local isShowPay = nk.OnOff:check("payGuide")
            local isPay = nk.userData.best and nk.userData.best.paylog == 1 or false
            -- local isAlmChargeFavPay = nk.userData.bagPayList and nk.userData.bagPayList.almRechgFav == 1 or false

            local marginTop = - 30

            local shopPosX = display.right - 56
            local shopPosY = marginTop
            
            local rechargeFavAccess = nk.userData.bagPayList and nk.userData.bagPayList.access == 1 or false
            if nk.OnOff:check("rechargeFavGray") and isShowPay and isPay and rechargeFavAccess then
                --todo
                local reChargeIconResKey = {}

                reChargeIconResKey[1] = "#chgAgnFav_entry_nor.png"  -- nor
                reChargeIconResKey[2] = "#chgAgnFav_entry_pre.png"  -- pre
                reChargeIconResKey[3] = "#chgAgnFav_entry_nor.png"  -- dis

                self._almRechargeEntryBtn = cc.ui.UIPushButton.new({normal = reChargeIconResKey[1], pressed = reChargeIconResKey[2],
                    disabled = reChargeIconResKey[3]}, {scale9 = false})
                    :onButtonClicked(buttontHandler(self, self.onAlmRechargeFavCallBack_))
                    :pos(shopPosX, shopPosY)
                    :addTo(self.topNode_)
            else

                display.newSprite("#room_ic_quickPay.png")
                    :pos(shopPosX, shopPosY)
                    :addTo(self.topNode_)
                    
                local flagPosAdjust = {
                    x = 2,
                    y = 22
                }

                display.newSprite("#room_fg_quickPay.png")
                    :pos(shopPosX - flagPosAdjust.x, shopPosY - flagPosAdjust.y)
                    :addTo(self.topNode_)

                self._quickPayBtn = cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png"--[[, pressed = "#rounded_rect_6.png"]]}, {scale9 = true})
                    :setButtonSize(TOP_BUTTOM_WIDTH, TOP_BUTTOM_HEIGHT)
                    :onButtonClicked(buttontHandler(self, self.onShopClick_))
                    :pos(shopPosX, shopPosY)
                    :addTo(self.topNode_)
                
                self.shopOffBg_ = display.newSprite("#room_store_off_bg.png", self._quickPayBtn:getPositionX() - 16, self._quickPayBtn:getPositionY() + 8)
                    :addTo(self.topNode_)

                self.shopOffLabel_ = display.newTTFLabel({size=16, color=cc.c3b(0xFE, 0xF5, 0xD0), text=""})
                    :pos(self.shopOffBg_:getPositionX() - 6, self.shopOffBg_:getPositionY() + 6)
                    :rotation(-45)
                    :addTo(self.topNode_)

                self:setStoreDiscount()
            end

            

            -- display.newScale9Sprite("#top_btn_bg.png", 0, 0, cc.size(TOP_BUTTOM_WIDTH + 4, TOP_BUTTOM_HEIGHT + 4))
            --     :pos(shopPosX, shopPosY)
            --     :addTo(self.topNode_)

            -- display.newSprite("#room_icon_store.png")
            --     :pos(shopPosX, shopPosY)
            --     :addTo(self.topNode_)

            -- self.shopBtn_ = cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#rounded_rect_6.png"}, {scale9 = true})
            --     :setButtonSize(TOP_BUTTOM_WIDTH, TOP_BUTTOM_HEIGHT)
            --     :onButtonClicked(buttontHandler(self, self.onShopClick_))
            --     :pos(shopPosX, shopPosY)
            --     :addTo(self.topNode_)

            -- self.shopOffBg_ = display.newSprite("#room_store_off_bg.png", self.shopBtn_:getPositionX() - 16, self.shopBtn_:getPositionY() + 8)
            --     :addTo(self.topNode_)

            -- self.shopOffLabel_ = display.newTTFLabel({size=16, color=cc.c3b(0xFE, 0xF5, 0xD0), text=""})
            --     :pos(self.shopOffBg_:getPositionX() - 6, self.shopOffBg_:getPositionY() + 6)
            --     :rotation(-45)
            --     :addTo(self.topNode_)
        end
    end
end

function NormalRoomBaseView:refreshAlmRechargeFavEntryUi(isOn)
    -- body
    if not isOn then
        --todo
        if self._almRechargeEntryBtn then
            --todo
            self._almRechargeEntryBtn:removeFromParent()
            self._almRechargeEntryBtn = nil

            local marginTop = - 30

            local shopPosX = display.right - 56
            local shopPosY = marginTop

            display.newSprite("#room_ic_quickPay.png")
                :pos(shopPosX, shopPosY)
                :addTo(self.topNode_)
                
            local flagPosAdjust = {
                x = 2,
                y = 22
            }

            display.newSprite("#room_fg_quickPay.png")
                :pos(shopPosX - flagPosAdjust.x, shopPosY - flagPosAdjust.y)
                :addTo(self.topNode_)

            self._quickPayBtn = cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png"--[[, pressed = "#rounded_rect_6.png"]]}, {scale9 = true})
                :setButtonSize(TOP_BUTTOM_WIDTH, TOP_BUTTOM_HEIGHT)
                :onButtonClicked(buttontHandler(self, self.onShopClick_))
                :pos(shopPosX, shopPosY)
                :addTo(self.topNode_)
            
            self.shopOffBg_ = display.newSprite("#room_store_off_bg.png", self._quickPayBtn:getPositionX() - 16, self._quickPayBtn:getPositionY() + 8)
                :addTo(self.topNode_)

            self.shopOffLabel_ = display.newTTFLabel({size=16, color=cc.c3b(0xFE, 0xF5, 0xD0), text=""})
                :pos(self.shopOffBg_:getPositionX() - 6, self.shopOffBg_:getPositionY() + 6)
                :rotation(-45)
                :addTo(self.topNode_)

            -- display.newScale9Sprite("#top_btn_bg.png", 0, 0, cc.size(TOP_BUTTOM_WIDTH + 4, TOP_BUTTOM_HEIGHT + 4))
            --     :pos(shopPosX, shopPosY)
            --     :addTo(self.topNode_)

            -- display.newSprite("#room_icon_store.png")
            --     :pos(shopPosX, shopPosY)
            --     :addTo(self.topNode_)

            -- self.shopBtn_ = cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#rounded_rect_6.png"}, {scale9 = true})
            --     :setButtonSize(TOP_BUTTOM_WIDTH, TOP_BUTTOM_HEIGHT)
            --     :onButtonClicked(buttontHandler(self, self.onShopClick_))
            --     :pos(shopPosX, shopPosY)
            --     :addTo(self.topNode_)

            -- self.shopOffBg_ = display.newSprite("#room_store_off_bg.png", self.shopBtn_:getPositionX() - 16, self.shopBtn_:getPositionY() + 8)
            --     :addTo(self.topNode_)

            -- self.shopOffLabel_ = display.newTTFLabel({size=16, color=cc.c3b(0xFE, 0xF5, 0xD0), text=""})
            --     :pos(self.shopOffBg_:getPositionX() - 6, self.shopOffBg_:getPositionY() + 6)
            --     :rotation(-45)
            --     :addTo(self.topNode_)

            self:setStoreDiscount()
        end
    end
end

function NormalRoomBaseView:onStandupClick_()
	if self.ctx.scene["onStandupClick_"] then
		self.ctx.scene:onStandupClick_()
	end
end

function NormalRoomBaseView:onReviewClick_()
    if self.ctx.scene["onReviewClick_"] then
		self.ctx.scene:onReviewClick_()
	end
end

function NormalRoomBaseView:onRecordClick_()
    if self.ctx.scene["onRecordClick_"] then
        self.ctx.scene:onRecordClick_()
    end
end

function NormalRoomBaseView:onShopClick_()
    if self.ctx.scene["onShopClick_"] then
		self.ctx.scene:onShopClick_()
	end
end

function NormalRoomBaseView:_onChargeFavCallBack()
    -- body
    if self.ctx.scene.onChargeFavClick_ then
        --todo
        self.ctx.scene:onChargeFavClick_()
    end
end

function NormalRoomBaseView:onAlmRechargeFavCallBack_(evt)
    -- body
    if self.ctx.scene.onAlmRechargeFavClick_ then
        --todo
        self.ctx.scene.onAlmRechargeFavClick_()
    end
end

function NormalRoomBaseView:onCardTypeClick_()
    if self.ctx.scene["onCardTypeClick_"] then
		self.ctx.scene:onCardTypeClick_()
	end
end


function NormalRoomBaseView:onMenuClick_()
	if self.ctx.scene["onMenuClick_"] then
		self.ctx.scene:onMenuClick_()
	end
end


function NormalRoomBaseView:onChangeRoomClick_()
	if self.ctx.scene["onChangeRoomClick_"] then
		self.ctx.scene:onChangeRoomClick_()
	end
end


function NormalRoomBaseView:toDelearSendChipHandler()
	if self.ctx.scene["toDelearSendChipHandler"] then
		self.ctx.scene:toDelearSendChipHandler()
	end
end

function NormalRoomBaseView:onCleanup()
    -- body
    bm.DataProxy:removeDataObserver(nk.dataKeys.PRE_GAME_CARDS,self.onSelfCardsObserver)
    bm.DataProxy:removeDataObserver(nk.dataKeys.CHARGEFAV_ONOFF, self.onChargeFavOnOffObserver)
    bm.DataProxy:removeDataObserver(nk.dataKeys.ALMRECHARGEFAV_ONOFF, self.onAlmRechargeFavOnOffObserver)
end

return NormalRoomBaseView