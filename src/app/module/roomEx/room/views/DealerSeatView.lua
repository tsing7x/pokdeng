--
-- Author: tony
-- Date: 2014-07-08 14:28:57
--
local HandCard = import(".HandCard")
local SeatStateMachine = import("app.module.roomEx.room.model.SeatStateMachine")
-- local GiftShopPopUp = import("app.module.gift.GiftShopPopup")
local UserInfoPopup = import("app.module.userInfo.UserInfoPopup")
-- local StorePopup = import("app.module.newstore.StorePopup")
local GiftStorePopup = import("app.module.newstore.GiftStorePopup")

local LoadGiftControl = import("app.module.gift.LoadGiftControl")

local DealerSeatView = class("DealerSeatView", function() 
    return display.newNode()
end)

DealerSeatView.CLICKED = "DealerSeatView.CLICKED"
DealerSeatView.WIDTH = 108
DealerSeatView.HEIGHT = 164

function DealerSeatView:ctor(ctx, seatId)
    self:retain()
    self.ctx = ctx
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    self:setNodeEventEnabled(true)
    --2 桌子背景
    self.background_ = display.newScale9Sprite("#room_seat_bg.png", 0, 0, cc.size(DealerSeatView.WIDTH, DealerSeatView.HEIGHT)):addTo(self, 2)

    --3 赢牌座位金色边框
    self.winBorderBatch_ = display.newBatchNode("room_texture.png", 3):addTo(self, 3, 3):hide()
    self.winBorder_ = display.newSprite("#room_seat_win_border.png"):addTo(self.winBorderBatch_)

    --白色星星1
    self.star1_ = display.newSprite("#room_you_win_flash.png"):addTo(self.winBorderBatch_)
    --白色星星2
    self.star2_ = display.newSprite("#room_you_win_flash.png"):addTo(self.winBorderBatch_)

    self.seatId_ = seatId
    self.positionId_ = seatId + 1
    self.seatImageLoaderId_ = nk.ImageLoader:nextLoaderId()
    self.seatGiftImageLoaderId_ = nk.ImageLoader:nextLoaderId()

    --坐下图片
    self.sitdown_ = display.newSprite("#room_sitdown_icon.png")
    --用户头像容器
    self.image_ = display.newNode():add(display.newSprite("#common_male_avatar.png"), 1, 1):pos(0, -100)

    --4 用户头像剪裁节点
    self.clipNode_ = cc.ClippingNode:create()

    local stencil = display.newDrawNode()
    local pn = {{-50, -50}, {-50, 50}, {50, 50}, {50, -50}}  
    local clr = cc.c4f(255, 0, 0, 255)  
    stencil:drawPolygon(pn, clr, 1, clr)

    self.clipNode_:setStencil(stencil)
    self.clipNode_:addChild(self.sitdown_, 1, 1)
    self.clipNode_:addChild(self.image_, 2, 2)
    self.clipNode_:addTo(self, 4, 4)

    --5 头像灰色覆盖
    self.cover_ = display.newRect(100, 100, {fill=true, fillColor=cc.c4f(0, 0, 0, 0.6)}):addTo(self, 5, 5):hide()

    --6 状态文字
    if appconfig.LANG == "vn" then
        self.state_ = display.newTTFLabel({text = "Seat" .. seatId, size = 20, align = ui.TEXT_ALIGN_CENTER, color=cc.c3b(0xff, 0xd1, 0x0) })
    else
        self.state_ = display.newTTFLabel({text = "Seat" .. seatId, size = 24, align = ui.TEXT_ALIGN_CENTER, color=cc.c3b(0xff, 0xd1, 0x0) })
    end
    self.state_:pos(0, 64):addTo(self, 6, 6)

    --7 座位筹码文字
    self.cash_icon_ = display.newSprite("#cash_coin_icon.png")
    :addTo(self)
    :pos(-40,-66)
    :scale(.7)
    self.cash_icon_:hide()
    self.chips_ = display.newTTFLabel({text = "", size = 24, align = ui.TEXT_ALIGN_CENTER, color=cc.c3b(0xff, 0xd1, 0x00)})
        :pos(0, -66)
        :addTo(self, 7, 7)

     --8 手牌
    self.handCards_ = HandCard.new(0.8):addTo(self, 9, 8):hide()

    -- 礼物
    if nk.config.GIFT_SHOP_ENABLED then
           self.giftImage_ = cc.ui.UIPushButton.new({normal = "#gift-icon-up.png",pressed = "#gift-icon-down.png"}):addTo(self, 8, 10):hide()
            :onButtonClicked(buttontHandler(self, self.openGiftPopUpHandler))
    end
    

    --9 winner动画
    self.winnerAnimBatch_ = display.newBatchNode("room_texture.png", 8):addTo(self, 99, 99):hide()
    --winner文字

    self.winner_ = display.newSprite("#room_seat_win_winner.png"):pos(0, -4):addTo(self.winnerAnimBatch_)
    --星星1
    self.winnerStar1_ = display.newSprite("#room_you_win_star.png"):addTo(self.winnerAnimBatch_)
    --星星2
    self.winnerStar2_ = display.newSprite("#room_you_win_star.png"):addTo(self.winnerAnimBatch_)
    --星星3
    self.winnerStar3_ = display.newSprite("#room_you_win_star.png"):addTo(self.winnerAnimBatch_)
    --星星4
    self.winnerStar4_ = display.newSprite("#room_you_win_star.png"):addTo(self.winnerAnimBatch_)

    --10 牌型背景
    self.cardTypeBackground_ = display.newScale9Sprite("#room_seat_card_type_light_bg.png", 0, 0, cc.size(118,32)):addTo(self, 10, 10):hide()

    --11 牌型文字
    self.cardType_ = display.newTTFLabel({
        size = 24,
        align = ui.TEXT_ALIGN_CENTER,
        valign = ui.TEXT_VALIGN_CENTER,
        color=cc.c3b(0x0d, 0xd3, 0x3e)
    }):addTo(self, 11, 11):hide()

    --12 博定
    self.pokdengIcon_ = display.newNode():pos(100 + 50, -20 + 50):addTo(self, 12)
    self.pokdengIcon_.showIcon = function(point) 
        self.pokdengIcon_:removeAllChildren()
        self.pokdengIcon_.isShow = false
        if point ~= 0 then
            self.pokdengIcon_.isShow = true
            local icon = display.newSprite("#pokdeng"..point..".png"):addTo(self.pokdengIcon_)
            if self.pokdengIcon_.value ~= point then
                icon:scale(0):scaleTo(0.2, 1)             
                self.pokdengIcon_.value = point
            end
        else
            self.pokdengIcon_.value = 0
        end
    end   
    
    --13 倍数
    self.XIcon_ = display.newNode():pos(100 + 50, -20 + 50):addTo(self, 13)
    self.XIcon_.showIcon = function(X) 
        self.XIcon_:removeAllChildren()
        if X > 1 then            
            local xBg = display.newSprite("#X_bg.png"):addTo(self.XIcon_)
            local xIcon = display.newSprite("#X"..X..".png"):addTo(self.XIcon_)
            if self.XIcon_.value ~= X then
                xBg:scale(0):scaleTo(0.2, 1)
                xIcon:scale(0):scaleTo(0.2, 1)
                self.XIcon_.value = X
            end
            if self.pokdengIcon_.isShow then
                xBg:pos(20,20)
                xIcon:pos(20,20)
            end
            local eventIdName = "";
            if X == 2 then
                eventIdName = "card_two_multiple"
            elseif X == 3 then
                eventIdName = "card_three_multiple"
            else
                eventIdName = "card_five_multiple"
                if checkint(self.seatData_.uid) == nk.userData["aUser.mid"] then
                    nk.userData["aUser.card_five_multiple_"] = 1;
                end
            end
            if checkint(self.seatData_.uid) == nk.userData["aUser.mid"] then
               
                if device.platform == "android" or device.platform == "ios" then
                    cc.analytics:doCommand{command = "event",
                    args = {eventId = eventIdName}}
                end
               
            end

        else
            self.XIcon_.value = 0
        end
    end

    --座位触摸
    self.touchHelper_ = bm.TouchHelper.new(self.background_, handler(self, self.onTouch_))
    self.touchHelper_:enableTouch()

    --初始为站起状态
    self:standUpState_()
end

function DealerSeatView:playSitDownAnimation(onCompleteCallback)
    transition.moveTo(self.image_:pos(0, 100):show(), {time=0.5, easing="backOut", x=0, y=0})
    transition.moveTo(self.sitdown_:pos(0, 0):show(), {time=0.5, easing="backOut", x=0, y=-100, onComplete=function() 
        self.sitdown_:hide()
        if onCompleteCallback then
            onCompleteCallback()
        end
    end})
end

function DealerSeatView:playStandUpAnimation(onCompleteCallback)
    transition.moveTo(self.image_:pos(0, 0):show(), {time=0.5, easing="backOut", x=0, y=110})
    transition.moveTo(self.sitdown_:pos(0, -100):show(), {time=0.5, easing="backOut", x=0, y=0, onComplete=function() 
        self.image_:hide()
        if onCompleteCallback then
            onCompleteCallback()
        end
    end})
end

function DealerSeatView:fade()
    if self.dealerStatus_ == 1 then return end
    transition.execute(self.cover_:show(), cc.FadeIn:create(0.2))
end

function DealerSeatView:unfade()
    self.cover_:hide()
end

function DealerSeatView:sitDownState_()
    if self.dealerStatus_ == 1 then return end
    self.image_:stopAllActions()
    self.sitdown_:stopAllActions()
    self.image_:pos(0, 0):show()
    self.sitdown_:pos(0, -100):hide()
    if (nk.config.GIFT_SHOP_ENABLED) then
        self.giftImage_:show()
    end
end

function DealerSeatView:standUpState_()
    --if self.dealerStatus_ == 1 then return end
    self.image_:stopAllActions()
    self.sitdown_:stopAllActions()
    self.image_:pos(0, 100):hide()
    self.sitdown_:pos(0, 0):show()
    if (nk.config.GIFT_SHOP_ENABLED) then
        self.giftImage_:hide()
    end
    
end

function DealerSeatView:userImageLoadCallback_(success, sprite)
    if success and self.image_ then
        local img = self.image_:getChildByTag(1)
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
        
        sprite:pos(seatSize.width * 0.5, seatSize.height * 0.5):addTo(self.image_, 1, 1)
    end
end

function DealerSeatView:isEmpty()
    return not self.seatData_
end

function DealerSeatView:getPositionId()
    return self.positionId_
end

function DealerSeatView:setPositionId(id)
    self.positionId_ = id
    if (nk.config.GIFT_SHOP_ENABLED) then
        if id then
            if ((id == 1) or (id == 2) or (id == 3) or (id == 5) or (id==10)) then
                self.giftImage_:pos(-55, 0)
            else
                self.giftImage_:pos(55, 0)
            end
        end
    end

end

function DealerSeatView:resetToEmpty()
    self.seatData_ = nil
    self:updateState()
end

function DealerSeatView:setSeatData(seatData)
    self.seatData_ = seatData   

    if seatData and seatData.isSelf then
        self.handCards_:pos(100, 0):scale(1)
        self.cardTypeBackground_:pos(100, -40)
        self.cardType_:pos(100, -40)
        self.pokdengIcon_:pos(100 + 50, -20 + 50)
        self.XIcon_:pos(100 + 50, -20 + 50)
    else
        self.handCards_:pos(0, 21 - 30 + 9):scale(0.8)
        self.cardTypeBackground_:pos(0, -37 -5 - 30)
        self.cardType_:pos(0, -37 - 5 - 30)
        self.pokdengIcon_:pos(0 + 40, 26 + 40 - 5 -30):scale(0.8)
        self.XIcon_:pos(0 + 40, 26 + 40 - 5 - 30):scale(0.8)
    end
    
    if not seatData then
        self:reset()
        self:standUpState_()
    else
        self:sitDownState_()
        local img = self.image_:getChildByTag(1)
        if img then
            img:removeFromParent()
        end
        if seatData.userInfo.msex == "2" then
            display.newSprite("#common_female_avatar.png"):addTo(self.image_, 1, 1)
        else
            display.newSprite("#common_male_avatar.png"):addTo(self.image_, 1, 1)
        end
        
        if string.len(seatData.userInfo.mavatar) > 5 then
            local imgurl = seatData.userInfo.mavatar
            if string.find(imgurl, "facebook") then
                if string.find(imgurl, "?") then
                    imgurl = imgurl .. "&width=100&height=100"
                else
                    imgurl = imgurl .. "?width=100&height=100"
                end
            end
            nk.ImageLoader:loadAndCacheImage(self.seatImageLoaderId_,
                imgurl, 
                handler(self,self.userImageLoadCallback_),
                nk.ImageLoader.CACHE_TYPE_USER_HEAD_IMG
            )
        end
        
        if nk.config.GIFT_SHOP_ENABLED then
            if self.giftUrlReqId_ then
                LoadGiftControl:getInstance():cancel(self.giftUrlReqId_)
            end

            self.reqGetUserLastGiftId_ = nk.http.getUserGift(seatData.uid, function(retData)
                -- body
                -- dump(retData, "nk.http.getUserGift.retData :===================")
                local userGiftId = nil

                if retData.pnid then
                    --todo
                    userGiftId = retData.pnid

                    seatData.userInfo.giftId = userGiftId
                else
                    userGiftId = seatData.userInfo.giftId
                end

                self.giftUrlReqId_ = LoadGiftControl:getInstance():getGiftUrlById(userGiftId, function(url)
                    self.giftUrlReqId_ = nil
                    if url and string.len(url) > 5 then
                        nk.ImageLoader:cancelJobByLoaderId(self.seatGiftImageLoaderId_)
                        nk.ImageLoader:loadAndCacheImage(self.seatGiftImageLoaderId_, url, handler(self,self.userGiftImageLoadCallback_),
                            nk.ImageLoader.CACHE_TYPE_GIFT)
                    end
                end)
            end, function(errData)
                -- body
                dump(errData, "nk.http.getUserGift.errData :===================")
                self.reqGetUserLastGiftId_ = nil
                self.giftUrlReqId_ = LoadGiftControl:getInstance():getGiftUrlById(seatData.userInfo.giftId, function(url)
                    self.giftUrlReqId_ = nil
                    if url and string.len(url) > 5 then
                        nk.ImageLoader:cancelJobByLoaderId(self.seatGiftImageLoaderId_)
                        nk.ImageLoader:loadAndCacheImage(self.seatGiftImageLoaderId_, url, handler(self,self.userGiftImageLoadCallback_),
                            nk.ImageLoader.CACHE_TYPE_GIFT)
                    end
                end)
            end)
        end
    end

end

function DealerSeatView:getSeatData()
    return self.seatData_
end


function DealerSeatView:userGiftImageLoadCallback_(success, sprite)
    if success then
         local tex = sprite:getTexture()
         local texSize = tex:getContentSize()
         self.giftImage_:setButtonImage("normal",tex)
         self.giftImage_:setButtonImage("pressed",tex)
         self.giftImage_:scale(0.5)
    else
        self.giftImage_:setButtonImage("normal", "#gift-icon-up.png")
        self.giftImage_:setButtonImage("pressed", "#gift-icon-down.png")
        self.giftImage_:scale(1)
    end
end



function DealerSeatView:updateGiftUrl(gift_Id)
    if nk.config.GIFT_SHOP_ENABLED then
        if self.giftUrlReqId_ then
            LoadGiftControl:getInstance():cancel(self.giftUrlReqId_)
        end
        self.giftUrlReqId_ = LoadGiftControl:getInstance():getGiftUrlById(gift_Id, function(url)
            self.giftUrlReqId_ = nil
            if url and string.len(url) > 5 then
                nk.ImageLoader:cancelJobByLoaderId(self.seatGiftImageLoaderId_)
                nk.ImageLoader:loadAndCacheImage(self.seatGiftImageLoaderId_,
                    url, 
                    handler(self,self.userGiftImageLoadCallback_),
                    nk.ImageLoader.CACHE_TYPE_GIFT
                )
            end
        end)

        --更新礼物数据
        if self.seatData_ then
            self.seatData_.userInfo.giftId = gift_Id
        end
    end
end

function DealerSeatView:updateHeadImage(imgurl)
    if string.len(imgurl) > 5 then
        if string.find(imgurl, "facebook") then
            if string.find(imgurl, "?") then
                imgurl = imgurl .. "&width=100&height=100"
            else
                imgurl = imgurl .. "?width=100&height=100"
            end
        end
        nk.ImageLoader:loadAndCacheImage(self.seatImageLoaderId_,
            imgurl, 
            handler(self,self.userImageLoadCallback_),
            nk.ImageLoader.CACHE_TYPE_USER_HEAD_IMG
        )
    end
end

function DealerSeatView:updateState()
    if self.seatData_ == nil then
        if self.ctx.model:isSelfInSeat() then
            self:hide()
        else
            self:show()
            self.state_:hide()
            self.chips_:hide()
            self.cash_icon_:hide()
            self.sitdown_:show()
            if self.userImage_ then
                self.userImage_:removeFromParent()
                self.userImage_ = nil
            end
        end
    else
        self:show()
        self.state_:show()
        self.chips_:show()
        self.sitdown_:hide()       
        self.state_:setString(nk.Native:getFixedWidthText("", 24, self.seatData_.statemachine:getStateText(), 110))
        
        if self.seatData_.anteMoney < 100000 then
            self.chips_:setString(bm.formatNumberWithSplit(self.seatData_.anteMoney))
        else
            self.chips_:setString(bm.formatBigNumber(self.seatData_.anteMoney))
        end
        if self.ctx.model.roomInfo.rmType == consts.ROOM_TYPE_EX.GRAB_CASH then
            self.cash_icon_:show()
        else
            self.cash_icon_:hide()
        end
        --self.betInChips_:setString(self.seatData_.betChips)
        local sm = self.seatData_.statemachine
        local st = sm:getState()

        if st ~= SeatStateMachine.STATE_GETTING then
            self.handCards_:stopShakeAll()
        end

        if st == SeatStateMachine.STATE_WAIT_START then
            self.cover_:show()
        else
            self.cover_:hide()
        end
    end
    if self.dealerStatus_ == 1 then
        self:setDealerStatus(false)
    end
end

function DealerSeatView:setHandCardValue(cards)
    if cards then
        printf("DealerSeatView[%s]setHandCardValue [%x %x %x][%s %s %s][%s %s %s]", self.seatId_ or -1, cards[1] or 0, cards[2] or 0, cards[3] or 0, cards[1] or 0, cards[2] or 0, cards[3] or 0, nk.getCardDesc(cards[1]), nk.getCardDesc(cards[2]), nk.getCardDesc(cards[3]))
    end
    self.handCards_:setCards(cards)
end

function DealerSeatView:setHandCardNum(num)
    self.handCards_:setCardNum(num)
end

function DealerSeatView:showHandCards()
    self.handCards_:show()
end

function DealerSeatView:hideHandCards()
    self.handCards_:hide()
end

function DealerSeatView:showHandCardBackAll()
    self.handCards_:showBackAll()
end

function DealerSeatView:showHandCardFrontAll()
    self.handCards_:showFrontAll()
end

function DealerSeatView:flipAllHandCards()
    self.handCards_:flipAll()
end

function DealerSeatView:hideAllHandCardsElement()
    self.handCards_:hideAllCards()
end

function DealerSeatView:showAllHandCardsElement()
    self.handCards_:showAllCards()
end

function DealerSeatView:showHandCardsElement(idx)
    self.handCards_:showWithIndex(idx)
end

function DealerSeatView:flipHandCardsElement(idx)
    self.handCards_:flipWithIndex(idx)
end

function DealerSeatView:shakeAllHandCards()
    self.handCards_:shakeWithNum(3)
end

-- 三公结束亮出自己手牌在博定中无用
function DealerSeatView:showHandCardsAnimation()
    local sequence = transition.sequence({
        cc.ScaleTo:create(0.1, 1.2),
        cc.MoveTo:create(0.35, cc.p(240, 165)),
        cc.ScaleTo:create(0.2, 0.8),
        cc.CallFunc:create(function() 
            nk.SoundManager:playSound(nk.SoundManager.SHOW_HAND_CARD)
        end),
    })
    self.handCards_:runAction(sequence)    
    self.showedHandCardAnimRound_ = self.ctx.model.gameInfo.roundCount
    self.showedHandCardAnim_ = true
end

function DealerSeatView:showCardTypeIf()
    local getFrame = display.newSpriteFrame
    if self.seatData_ and self.seatData_.HandPoker and self.seatData_.HandPoker:getTypeLabel() then
        if self.seatData_.HandPoker:isBadType() then
            self.cardTypeBackground_:setSpriteFrame(getFrame("room_seat_card_type_dark_bg.png"))
        else
            self.cardTypeBackground_:setSpriteFrame(getFrame("room_seat_card_type_light_bg.png"))
        end
        self.cardTypeBackground_:setContentSize(118,32)
        self.cardTypeBackground_:show()
        self.cardType_:setString(self.seatData_.HandPoker:getTypeLabel())
        self.cardType_:show()
        if self.seatData_.HandPoker:isPokdeng() then
            self.pokdengIcon_.showIcon(self.seatData_.HandPoker:getPoint())
        end
        self.XIcon_.showIcon(self.seatData_.HandPoker:getX())
    else
        self.cardTypeBackground_:hide()
        self.cardType_:hide()
        self.pokdengIcon_.showIcon(0)
        self.XIcon_.showIcon(0)
    end
end

function DealerSeatView:playExpChangeAnimation(expChange)
    if expChange > 0 then
        local node = display.newNode()
        node:setCascadeOpacityEnabled(true)
        local exp = display.newSprite("#room_seat_exp.png"):addTo(node)
        local num = display.newTTFLabel({
            text = "+"..expChange, 
            color = cc.c3b(0x1D, 0xBC, 0xFC), 
            size = 24, 
            align = ui.TEXT_ALIGN_CENTER
        }):addTo(node)
        local expW = exp:getContentSize().width
        local numW = num:getContentSize().width
        local w =  expW + numW
        exp:pos(w * -0.5 + expW * 0.5, 0)
        num:pos(w * 0.5 - numW * 0.5, 0)

        node:addTo(self, 99)
            :scale(0.4)
            :moveBy(0.8, 0, 92)
            :scaleTo(0.8, 1)
        node:runAction(transition.sequence({
            cc.FadeIn:create(0.4),
            cc.DelayTime:create(1.2),


            cc.FadeOut:create(0.2),
            cc.CallFunc:create(function()
                node:removeFromParent()
            end),
        }))
    end
end

function DealerSeatView:playAutoBuyinAnimation(buyinChips)
    local buyInBg = display.newSprite("#buyin-action-yellowbackground.png")
        :addTo(self, 6)
    local buyInBgSize = buyInBg:getContentSize()
    buyInBg:pos(0, -DealerSeatView.HEIGHT/2 + buyInBgSize.height/2)
    local buyInSequence = transition.sequence({
            cc.FadeIn:create(0.5),
            cc.FadeOut:create(0.5),
            cc.CallFunc:create(function()
                buyInBg:removeFromParent()
            end),
        })
    buyInBg:runAction(buyInSequence)

    local buyInLabelPaddding = 20
    local buyInLabel = display.newTTFLabel({
            text = "+"..buyinChips, 
            color = cc.c3b(0xf4, 0xcd, 0x56), 
            size = 32, 
            align = ui.TEXT_ALIGN_CENTER
        }):addTo(self, 6):pos(0, -DealerSeatView.HEIGHT/2 + buyInBgSize.height/2 + buyInLabelPaddding)

    local function spawn(actions)
        if #actions < 1 then return end
        if #actions < 2 then return actions[1] end

        local prev = actions[1]
        for i = 2, #actions do
            prev = cc.Spawn:create(prev, actions[i])
        end
        return prev
    end

    local buyInLabelSequence = transition.sequence({
            spawn({
                cc.FadeTo:create(1, 0.7 * 255),
                cc.MoveTo:create(1, cc.p(0, DealerSeatView.HEIGHT/2 - buyInBgSize.height/2 - buyInLabelPaddding)),
            }),
            cc.CallFunc:create(function()
                buyInLabel:removeFromParent()
            end),
        })
    buyInLabel:runAction(buyInLabelSequence)
end

function DealerSeatView:playWinAnimation()
   -- if self.dealerStatus_ == 1 then return end
    if not self.seatData_ then return end

    --停止未播放完的动画
    self:stopWinAnimation_()

    --开始新的动画
    if self.dealerStatus_ ~= 1 then
        self.winBorderBatch_:show()
    end
    --
    self.winnerAnimBatch_:show()

    self:showCardTypeIf()
    
    local offsetX = 100
    if self.seatData_.isSelf then
        offsetX = 100
        self.winner_:hide()
    else
        offsetX = 0
        self.winner_:show()
        self.winner_:stopAllActions()
        self.winner_:scale(0.4)
        self.winner_:setOpacity(0.3 * 255)
        self.winner_:fadeTo(0.5, 255)
        transition.execute(self.winner_, transition.sequence({
            cc.EaseBackOut:create(cc.ScaleTo:create(0.5, 1, 1)),
            cc.DelayTime:create(2.5),
        }))
    end

    self.star1_:pos(46, 86)
    transition.execute(self.star1_, cc.RepeatForever:create(transition.sequence({
        cc.ScaleTo:create(0, 0.7, 0.7),
        cc.ScaleTo:create(0.3, 1.1, 1.1),
        cc.ScaleTo:create(0.3, 0.7, 0.7),
        })))

    self.star2_:pos(-57, -71)
    transition.execute(self.star2_, cc.RepeatForever:create(transition.sequence({
        cc.ScaleTo:create(0, 0.9, 0.9),
        cc.ScaleTo:create(0.3, 1.2, 1.2),
        cc.ScaleTo:create(0.2, 0.9, 0.9),
        })))

    self.winnerStar1_:pos(offsetX-70, -10):scale(0.4):setOpacity(255 * 0.8)
    self.winnerStar1_:rotateBy(3, 360 * 0.5)
    self.winnerStar1_:scaleTo(3, 0.8)
    self.winnerStar1_:fadeTo(1.5, 255)
    local path = {
        cc.p(offsetX - 70, - 10),
        cc.p(offsetX - 80, 16),
        cc.p(offsetX - 70, 30)
    }

    transition.execute(self.winnerStar1_, cc.CatmullRomTo:create(3, path), {onComplete=function()
        self.winBorderBatch_:hide()
        self.winnerAnimBatch_:hide()
        self.winner_:stopAllActions()
        self.star1_:stopAllActions()
        self.star2_:stopAllActions()
        self.winnerStar1_:stopAllActions()
        self.winnerStar2_:stopAllActions()
        self.winnerStar3_:stopAllActions()
        self.winnerStar4_:stopAllActions()
    end})

    self.winnerStar2_:pos(offsetX + 40, -10):scale(0.4):setOpacity(255 * 0.6)
    self.winnerStar2_:rotateBy(3, 360 * 0.5)
    self.winnerStar2_:scaleTo(1.5, 1.2)
    self.winnerStar2_:fadeTo(1.5, 255 * 1)
    path = {
        cc.p(offsetX + 40, - 10),
        cc.p(offsetX + 60, 0),
        cc.p(offsetX + 50, 20)
    }

    transition.execute(self.winnerStar2_, cc.RepeatForever:create(cc.CatmullRomTo:create(3, path)))

    self.winnerStar3_:pos(offsetX + 10, -10):scale(0.4):setOpacity(255 * 0.4)
    self.winnerStar3_:rotateBy(3, 360 * -1)
    self.winnerStar3_:scaleTo(3, 2)
    self.winnerStar3_:fadeTo(1.5, 255 * 0.8)
    self.winnerStar3_:moveTo(3, offsetX + 20, 15)

    self.winnerStar4_:pos(offsetX-20, -20):scale(0.2):setOpacity(255)
    self.winnerStar4_:rotateBy(3, 360 * 0.8)
    self.winnerStar4_:scaleTo(3, 5)
    self.winnerStar4_:fadeTo(3, 255 * 0.6)
    self.winnerStar4_:moveTo(3, offsetX-30, 5)
end

function DealerSeatView:stopWinAnimation_()
    self.winBorderBatch_:hide()
    self.winnerAnimBatch_:hide()
    self.winner_:stopAllActions()
    self.star1_:stopAllActions()
    self.star2_:stopAllActions()
    self.winnerStar1_:stopAllActions()
    self.winnerStar2_:stopAllActions()
    self.winnerStar3_:stopAllActions()
    self.winnerStar4_:stopAllActions()
end

function DealerSeatView:onTouch_(target, evt)
    if evt == bm.TouchHelper.CLICK then
        nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
        self:dispatchEvent({name=DealerSeatView.CLICKED, seatId=self.seatId_, target=self})
    end
end

function DealerSeatView:reset()
    self.handCards_:showAllCards()
    self.handCards_:showBackAll()
    self.handCards_:removeDarkAll()
    self.handCards_:stopShakeAll()
    self.handCards_:hide()
    self.cover_:hide()

    self:stopWinAnimation_()
    self.cardTypeBackground_:hide()
    self.cardType_:hide()
    self.pokdengIcon_.showIcon(0)
    self.XIcon_.showIcon(0)
end
function DealerSeatView:setDealerStatus(isShow)

    if isShow then
        self.dealerStatus_ = 0
        if self.giftImage_ then
            self.giftImage_:show()
        end
        self.background_:show()
        self.image_:show()
        self.chips_:show()
        self.clipNode_:show()
       -- self.cover_:show()
        self.state_:show()
    else
        self.dealerStatus_ = 1
        if self.giftImage_ then
            self.giftImage_:hide()
        end
        self.background_:hide()
        self.image_:hide()
        self.chips_:hide()
        self.clipNode_:hide()
        self.cover_:hide()
        self.state_:hide()
    end
end
function DealerSeatView:openGiftPopUpHandler()
    local roomUid = ""
    local roomOtherUserUidArray = ""
    local tableNum = 0
    local toUidArr = {}
    for i=0,8  do
        if self.ctx.model.playerList[i] then
            if self.ctx.model.playerList[i].uid > 0 then
                tableNum = tableNum + 1
                roomUid = roomUid..","..self.ctx.model.playerList[i].uid
                roomOtherUserUidArray = string.sub(roomUid,2)
                table.insert(toUidArr, self.ctx.model.playerList[i].uid)
            end
        end
    end
    if self.ctx.model.playerList[self.seatId_] then

        if self.ctx.model.playerList[self.seatId_].uid == nk.userData.uid then
            --todo
            local tableInfo = {}
            tableInfo.tableAllUid = roomOtherUserUidArray
            tableInfo.toUidArr = toUidArr
            tableInfo.tableNum = tableNum
            if self.ctx.model.roomInfo.rmType == consts.ROOM_TYPE_EX.GRAB_CASH then
                tableInfo.isCash = 1
            end

            UserInfoPopup.new(3):show(true, tableInfo,nil,self.ctx.model:isSelfInGame())
        else
            local inRoomInfo = {}
            inRoomInfo.isInRoom = true
            inRoomInfo.toUid = self.ctx.model.playerList[self.seatId_].uid
            inRoomInfo.toUidArr = toUidArr
            inRoomInfo.tableNum = tableNum
            inRoomInfo.allTabId = roomOtherUserUidArray

            -- StorePopup.new(3, nil):showPanel(nil, inRoomInfo)
            GiftStorePopup.new():showPanel(nil, inRoomInfo)
        end
        

        -- GiftShopPopUp.new():show(true,self.ctx.model.playerList[self.seatId_].uid,roomOtherUserUidArray,tableNum,toUidArr)
    end
end

function DealerSeatView:onCleanup()
    if self.seatGiftImageLoaderId_ then
        nk.ImageLoader:cancelJobByLoaderId(self.seatGiftImageLoaderId_)
    end

    if self.seatImageLoaderId_ then
        nk.ImageLoader:cancelJobByLoaderId(self.seatImageLoaderId_)
    end

    if self.reqGetUserLastGiftId_ then
        --todo
        nk.http.cancel(self.reqGetUserLastGiftId_)
    end
end

function DealerSeatView:updateAnte(money)
    self.seatData_.anteMoney = checkint(self.seatData_.anteMoney)+money
    if self.seatData_.anteMoney < 100000 then
        self.chips_:setString(bm.formatNumberWithSplit(self.seatData_.anteMoney))
    else
        self.chips_:setString(bm.formatBigNumber(self.seatData_.anteMoney))
    end
end
function DealerSeatView:dispose()
    self.handCards_:dispose()
    self:release()
end

return DealerSeatView