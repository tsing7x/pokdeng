
local RoomViewPosition = import("app.module.match.matchRoom.views.MatchRoomViewPosition")
local MatchRoomIndicator = import("app.module.match.matchRoom.views.MatchRoomIndicator")

local MatchNormalRoomBaseView = class("MatchNormalRoomBaseView",function()
	return display.newNode()
end)


local TOP_BUTTOM_WIDTH   = 78
local TOP_BUTTOM_HEIGHT  = 58


function MatchNormalRoomBaseView:ctor(ctx)
	self.ctx = ctx

    self:setNodeEventEnabled(true)

	self.backgroundImg_ = display.newSprite("room_background.jpg", display.cx, display.cy)
        :addTo(self)

    if display.width / display.height > 1140 / 640 then
        self.backgroundImg_:setScale(display.width / 1140)
    else
        self.backgroundImg_:setScale(display.height / 640)
    end

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

     -- 扑克堆
    for i = 1, 6 do
        display.newSprite("#room_dealed_hand_card.png"):pos(RoomViewPosition.DealCardPosition[10].x, RoomViewPosition.DealCardPosition[10].y + i)
            :rotation(180)
            :addTo(batchNode)
    end

    
    --房间信息
    self.roomInfo_ = display.newTTFLabel({size=24, text="", color=cc.c3b(0x0, 0xB2, 0x3F)}):pos(display.cx, display.cy):addTo(self)
    self.roomTableTip_ = display.newTTFLabel({size=22, text="", color=cc.c3b(0x0, 0xB2, 0x3F)}):pos(display.cx, display.cy+30):addTo(self)

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



    -- --商城按钮
    -- local isShowPay = nk.OnOff:check("payGuide")
    -- local isPay = nk.userData.best.ispay == 1 or false

    -- local shopPosX = display.right - 56
    -- local shopPosY = marginTop

    -- if isShowPay and not isPay then
    --     --todo
    --     self._firstChargeEntryBtn = cc.ui.UIPushButton.new("#chargeFav_entry.png", {scale9 = false})
    --         :pos(shopPosX, shopPosY)
    --         :addTo(self.topNode_)
    --         :onButtonClicked(buttontHandler(self, self._onChargeFavCallBack))
    -- else

    --     display.newSprite("#room_ic_quickPay.png")
    --         :pos(shopPosX, shopPosY)
    --         :addTo(self.topNode_)

    --     local flagPosAdjust = {
    --         x = 2,
    --         y = 22
    --     }

    --     display.newSprite("#room_fg_quickPay.png")
    --         :pos(shopPosX - flagPosAdjust.x, shopPosY - flagPosAdjust.y)
    --         :addTo(self.topNode_)

    --     self._quickPayBtn = cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png" --[[, pressed = "#rounded_rect_6.png"]]}, {scale9 = true})
    --         :setButtonSize(TOP_BUTTOM_WIDTH, TOP_BUTTOM_HEIGHT)
    --         :onButtonClicked(buttontHandler(self, self.onShopClick_))
    --         :pos(shopPosX, shopPosY)
    --         :addTo(self.topNode_)
        
    --     self.shopOffBg_ = display.newSprite("#room_store_off_bg.png", self._quickPayBtn:getPositionX() - 16, self._quickPayBtn:getPositionY() + 8)
    --         :addTo(self.topNode_)

    --     self.shopOffLabel_ = display.newTTFLabel({size=16, color=cc.c3b(0xFE, 0xF5, 0xD0), text=""})
    --         :pos(self.shopOffBg_:getPositionX() - 6, self.shopOffBg_:getPositionY() + 6)
    --         :rotation(-45)
    --         :addTo(self.topNode_)
    -- end

    --比赛邀请广播按钮
    local matchInvitePosX = display.right - 60
    local matchInvitePosY = -display.height + 140
    self.matchInviteBtn_ = display.newNode():addTo(self.topNode_):hide()
    display.newScale9Sprite("#top_btn_bg.png", 0, 0, cc.size(TOP_BUTTOM_WIDTH + 4, TOP_BUTTOM_HEIGHT + 4))
        :pos(matchInvitePosX, matchInvitePosY)
        :addTo(self.matchInviteBtn_)
    display.newSprite("#room_icon_match_invite.png")
        :pos(matchInvitePosX, matchInvitePosY)
        :addTo(self.matchInviteBtn_)
    cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#rounded_rect_6.png"}, {scale9 = true})
        :setButtonSize(TOP_BUTTOM_WIDTH, TOP_BUTTOM_HEIGHT)
        :onButtonClicked(buttontHandler(self, self.onMatchInviteClick_))
        :pos(matchInvitePosX, matchInvitePosY)
        :addTo(self.matchInviteBtn_)
    display.newTTFLabel({text = bm.LangUtil.getText("MATCH","INVITE_FRIEND_JOIN_MATCH"),color = cc.c3b(0xde, 0xe9, 0xf1), size = 24, align = ui.TEXT_ALIGN_CENTER})
    :pos(matchInvitePosX, matchInvitePosY - TOP_BUTTOM_HEIGHT*0.5 -12)
    :addTo(self.matchInviteBtn_)

    

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

    self._reviewBtn = cc.ui.UIPushButton.new({normal = "#room_ic_review_normal.png", pressed = "#room_ic_review_pressed.png"}, {scale9 = true})
        :onButtonClicked(buttontHandler(self, self.onReviewClick_))
        -- :setButtonSize(reviewBtnSize.width, reviewBtnSize.height)

    self._reviewBtn:pos(reviewPosX, reviewPosY)
    self._reviewBtn:addTo(self.topNode_)
    self._reviewBtn:hide()

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

    self.matchRoomIndicator_ = MatchRoomIndicator.new(self.ctx):addTo(self)

    self:addDataObservers()
end

function MatchNormalRoomBaseView:addDataObservers()
    -- body
    self.onChargeFavOnOffObserver = bm.DataProxy:addDataObserver(nk.dataKeys.CHARGEFAV_ONOFF, handler(self, self.refreshFirstChargeFavEntryUi))
end

function MatchNormalRoomBaseView:setStoreDiscount(discount)
    
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


function MatchNormalRoomBaseView:setMatchRoomIndicator(data)
    if self.matchRoomIndicator_ then
        self.matchRoomIndicator_:setMatchRoomIndicator(data)
    end
end
function MatchNormalRoomBaseView:setTimeMatchIndicator(data)
    if self.matchRoomIndicator_ then
        self.matchRoomIndicator_:setTimeMatchIndicator(data)
    end
end

function MatchNormalRoomBaseView:setRoomInfoText(roomInfo)
    
    -- local roomFiled = bm.LangUtil.getText("HALL", "ROOM_LEVEL_TEXT")[math.floor((roomInfo.roomType - 101) / 6) + 1]
    -- local info = bm.LangUtil.getText("ROOM", "ROOM_INFO", roomFiled, roomInfo.tid, roomInfo.blind)
    local matchType = roomInfo.matchType
    local matchId = roomInfo.matchId
    local tid = roomInfo.tid
    local matchInfo ;
    if matchType > 100 then
        matchInfo = nk.MatchConfigEx:getMatchDataById(matchType)
    else
        matchInfo  = nk.MatchConfigEx:getMatchDataById(matchType)
    end
    local matchName = ""
    local infoTxt = ""
    if matchInfo then
        matchName = matchInfo.name

        infoTxt =  matchId ~= nil and (matchId .. "/" .. matchName) or (matchName)
    end
   
    self.roomInfo_:setString(infoTxt)
end


function MatchNormalRoomBaseView:setRoomTipText(text)
    text = text or ""
    self.roomTableTip_:setString(text)
end

function MatchNormalRoomBaseView:setMatchInviteButtonVisible(visible)
    if not visible then
        self.matchInviteBtn_:hide()
    else
        self.matchInviteBtn_:show()
    end
end

function MatchNormalRoomBaseView:setChangeRoomButtonMode(mode)
    do return end
    if mode == 1 then
        self.changeRoomBtn_:show()
        self.standupBtn_:hide()
    else
        self.changeRoomBtn_:hide()
        self.standupBtn_:show()
    end
end

function MatchNormalRoomBaseView:refreshFirstChargeFavEntryUi(isOpen)
    -- body
    if not isOpen then
        --todo

        if self._firstChargeEntryBtn then
            --todo
            self._firstChargeEntryBtn:removeFromParent()
            self._firstChargeEntryBtn = nil

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

function MatchNormalRoomBaseView:onMatchInviteClick_()
    if self.ctx.scene["onMatchInviteClick_"] then
        self.ctx.scene:onMatchInviteClick_()
    end
end

function MatchNormalRoomBaseView:onStandupClick_()
    do return end
	if self.ctx.scene["onStandupClick_"] then
		self.ctx.scene:onStandupClick_()

	end
end


function MatchNormalRoomBaseView:onReviewClick_()
    if self.ctx.scene["onReviewClick_"] then
		self.ctx.scene:onReviewClick_()
	end
end

function MatchNormalRoomBaseView:onShopClick_()
    if self.ctx.scene["onShopClick_"] then
		self.ctx.scene:onShopClick_()
	end
end

function MatchNormalRoomBaseView:_onChargeFavCallBack()
    -- body
    if self.ctx.scene.onChargeFavClick_ then
        --todo
        self.ctx.scene:onChargeFavClick_()
    end
end

function MatchNormalRoomBaseView:onCardTypeClick_()
    if self.ctx.scene["onCardTypeClick_"] then
		self.ctx.scene:onCardTypeClick_()
	end
end


function MatchNormalRoomBaseView:onMenuClick_()
	if self.ctx.scene["onMenuClick_"] then
		self.ctx.scene:onMenuClick_()
	end
end


function MatchNormalRoomBaseView:onChangeRoomClick_()
	if self.ctx.scene["onChangeRoomClick_"] then
		self.ctx.scene:onChangeRoomClick_()
	end
end


function MatchNormalRoomBaseView:toDelearSendChipHandler()
	if self.ctx.scene["toDelearSendChipHandler"] then
		self.ctx.scene:toDelearSendChipHandler()
	end
end

function MatchNormalRoomBaseView:onCleanup()
    -- body

    bm.DataProxy:removeDataObserver(nk.dataKeys.CHARGEFAV_ONOFF, self.onChargeFavOnOffObserver)
end

return MatchNormalRoomBaseView