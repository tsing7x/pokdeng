--
-- Author: tony
-- Date: 2014-07-08 12:45:14
--
local SeatManager = class("SeatManager")

local SeatView = import(".views.SeatView")
local GrabDealerSeatView = import(".views.DealerSeatView")
local RoomViewPosition = import(".views.RoomViewPosition")
local SeatProgressTimer = import(".views.SeatProgressTimer")
local UserInfoOtherDialog = import(".views.UserInfoOtherDialog")
local BuyInPopup = import(".views.BuyInPopup")
 local StorePopup = import("app.module.newstore.StorePopup")
local UserInfoPopup = import("app.module.userInfo.UserInfoPopup")
-- local PayGuide = import("app.module.room.purchGuide.PayGuide")
local PayGuidePopMgr = import("app.module.room.purchGuide.PayGuidePopMgr")
local GrabDealerBuyInPopup = import("app.module.roomEx.room.views.DealerBuyInPopup")

local SeatPosition = RoomViewPosition.SeatPosition

local SEAT_PROGRESS_TIMER_TAG = 8390

local SEATS_9 = {0, 1, 2, 3, 4, 5, 6, 7, 8}
local SEATS_5 = {0, 2, 4, 6, 8}
local SEATS_2 = {2, 6}
local SEATS_10 = {0, 1, 2, 3, 4, 5, 6, 7, 8,9}

local logger = bm.Logger.new("SeatManager")
local USE_COUNTER_POOL = false

function SeatManager:ctor(ctx)
    self.appEnterForegroundListenerId_ = bm.EventCenter:addEventListener(nk.eventNames.APP_ENTER_FOREGROUND, handler(self, self.onAppEnterForeground_))
    self.appEnterBackgroundListenerId_ = bm.EventCenter:addEventListener(nk.eventNames.APP_ENTER_BACKGROUND, handler(self, self.onAppEnterBackground_))
    self.addExpListenerId_ =  bm.EventCenter:addEventListener(nk.eventNames.SVR_BROADCAST_ADD_EXP, handler(self, self.onAddExp))
    self.addChipListenerId_ = bm.EventCenter:addEventListener(nk.eventNames.UPDATE_SEAT_ANTE_CHIP, handler(self, self.onUpdateAnte))
end

function SeatManager:createNodes()
    --创建座位
    self.seats_ = {}
    for i = 0, 8 do
        local seat = SeatView.new(self.ctx, i) --seatId 0~8
        cc.EventProxy.new(seat, self.scene)
            :addEventListener(SeatView.CLICKED, handler(self, self.onSeatClicked_))
        self.seats_[i] = seat
    end


    local seat = GrabDealerSeatView.new(self.ctx, 9) --- dealer seat
        cc.EventProxy.new(seat, self.scene)
            :addEventListener(GrabDealerSeatView.CLICKED, handler(self, self.onSeatClicked_))
        self.seats_[9] = seat
        seat:setPosition(display.cx, RoomViewPosition.SeatPosition[1].y + 6)
        seat:setPositionId(10)
        seat:updateState()
        seat:addTo(self.scene.nodes.seatNode, 10, 10)


    --倒计时对象池
    if USE_COUNTER_POOL then
        self.counterPool_ = bm.ObjectPool.new(function()
            return SeatProgressTimer.new(self.model.roomInfo.betExpire)
        end, true, 1, 4, true)
    end
end

function SeatManager:onAppEnterBackground_()
    logger:debug("onAppEnterBackground_", self.counterSeatId_)
    local counterSeatId = self.counterSeatId_
    self:stopCounter()
    if USE_COUNTER_POOL then
        self.counterPool_:dispose()
    end
    self.counterSeatId_ = counterSeatId
end

function SeatManager:onAppEnterForeground_()
    logger:debug("onAppEnterForeground_", self.counterSeatId_)
    if USE_COUNTER_POOL then
        self.counterPool_ = bm.ObjectPool.new(function()
            return SeatProgressTimer.new(self.model.roomInfo.betExpire)
        end, true, 1, 4, true)
    end

    --延时0.1s，如果这里直接开始计时, 测试时发现有可能导致材质损坏
    self.gameSchedulerPool:delayCall(function()
        local counterSeatId = self.counterSeatId_
        if counterSeatId then
            logger:debug("startCounter", counterSeatId)
            self:stopCounter()
            self:startCounter(counterSeatId)
        end
    end, 0.1)
end

function SeatManager:dispose()
    if self.seats_ then
        for i = 0, 9 do
            local seat = self.seats_[i]
            if seat then
                local counter = seat:getChildByTag(SEAT_PROGRESS_TIMER_TAG)
                if counter then
                    counter:removeFromParent()
                end
                seat:dispose()
            end
        end
    end
    if USE_COUNTER_POOL then
        self.counterPool_:dispose()
    end
    if self.appEnterForegroundListenerId_ then
        bm.EventCenter:removeEventListener(self.appEnterForegroundListenerId_)
        self.appEnterForegroundListenerId_ = nil
    end
    if self.appEnterBackgroundListenerId_ then
        bm.EventCenter:removeEventListener(self.appEnterBackgroundListenerId_)
        self.appEnterBackgroundListenerId_ = nil
    end
    if self.addExpListenerId_ then
        bm.EventCenter:removeEventListener(self.addExpListenerId_)
        self.addExpListenerId_ = nil
    end
    if self.addChipListenerId_ then
        bm.EventCenter:removeEventListener(self.addChipListenerId_)
        self.addChipListenerId_ = nil
    end
end

function SeatManager:getSeatView(seatId)
    return self.seats_[seatId]
end

function SeatManager:getSelfSeatView()
    return self:getSeatView(self.model:selfSeatId())
end

function SeatManager:getSeatPosition(seatId)
    local seat = self.seats_[seatId]
    if seat then
        return SeatPosition[seat:getPositionId()]
    end
    return nil
end

function SeatManager:getSeatPositionId(seatId)
    local seat = self.seats_[seatId]
    if seat then
        return seat:getPositionId()
    end
    return nil
end

function SeatManager:getEmptySeatId()
    if self.seatIds_ then
        local playerList = self.model.playerList
        for i, seatId in ipairs(self.seatIds_) do
            if not playerList[seatId] and seatId ~=9 then
                return seatId
            end
        end
    end
    return nil
end

function SeatManager:initSeats(seatsInfo, playerList)
    local model = self.model
    local scene = self.scene
    local seats = self.seats_
    assert(seatsInfo and seatsInfo.seatNum, "seatNum is nil")
    local P = SeatPosition
    local seatIds = nil
    if seatsInfo.seatNum == 9 then
        seatIds = SEATS_9
    elseif seatsInfo.seatNum == 5 then
        seatIds = SEATS_5
    elseif seatsInfo.seatNum == 2 then
        seatIds = SEATS_2
    elseif seatsInfo.seatNum == 10 then
        seatIds = SEATS_10
    end
    self.seatIds_ = seatIds

    self.dealCardManager:reset()
    for seatId = 0, 9 do
        local shouldShow = false
        if seatIds then
            for i, v in ipairs(seatIds) do
                if v == seatId  then
                    shouldShow = true
                    break
                end
            end
        end
        local seat = self.seats_[seatId]
        if shouldShow then
            local pos = P[seatId + 1]
            seat:setPosition(pos)
            seat:setPositionId(seatId + 1)
            local player = playerList[seatId]
            seat:resetToEmpty()
            seat:setSeatData(player)
            if not seat:getParent() then
                seat:addTo(scene.nodes.seatNode, seatId + 1, seatId + 1)
            end

            if player then
                local gameStatus = self.model.gameInfo.gameStatus
                if player.isSelf then                   
                    if player.cardsCount > 0 then
                        seat:setHandCardValue(player.cards)
                        seat:setHandCardNum(player.cardsCount)
                        seat:showHandCardFrontAll()
                        seat:showAllHandCardsElement()
                        seat:showHandCards()
                        seat:showCardTypeIf()
                    else
                        seat:hideHandCards()
                    end
                else
                    if player.cardsCount > 0 then
                        self.dealCardManager:showDealedCard(player, player.cardsCount)
                    end
                end
            end

            seat:updateState()
        else
            seat:removeFromParent()
        end
    end
end

function SeatManager:rotateSeatToOrdinal()
    if self.dealCardRotateShowDelayId_ then
        self.schedulerPool:clear(self.dealCardRotateShowDelayId_)
        self.dealCardRotateShowDelayId_ = nil
    end

    local seat = self.seats_[2]
    local positionId = seat:getPositionId()
    if positionId ~= 3 then
        local step = positionId - 3
        self:rotateSeatByStep_(step, true)
    end
    if self.selfArrowDelayId_ then
        self.schedulerPool:clear(self.selfArrowDelayId_)
        self.selfArrowDelayId_ = nil
    end
end

function SeatManager:rotateSelfSeatToCenter(selfSeatId, animation)
    if self.dealCardRotateShowDelayId_ then
        self.schedulerPool:clear(self.dealCardRotateShowDelayId_)
        self.dealCardRotateShowDelayId_ = nil
    end

    local selfSeat = self.seats_[selfSeatId]
    local selfPositionId = selfSeat:getPositionId()
    if selfPositionId ~= 5 then
        local step = selfPositionId - 5
        self:rotateSeatByStep_(step, animation)
    end
    if animation then
        self.selfArrowDelayId_ = self.schedulerPool:delayCall(function() 
            self.selfArrowDelayId_ = nil
            local p = cc.p(SeatPosition[5].x, SeatPosition[5].y + 140)
            local pt = cc.p(p.x, p.y - 25)
            local arrow = display.newSprite("#room_self_seat_arrow.png")
            arrow:setPosition(p)
            arrow:addTo(self.scene.nodes.animNode)
            transition.execute(arrow, cc.Repeat:create(
                transition.sequence({
                    cc.MoveTo:create(0, p),
                    cc.MoveTo:create(0.5, pt),
                    cc.MoveTo:create(0.2, p),
                }), 4), 
                {onComplete=function() 
                    arrow:removeFromParent()
                end})
        end, 0.5)
    end
end

function SeatManager:rotateSeatByStep_(step, animation)
    if step > 4 then
        step = step - 9
    elseif step < -4 then
        step = step + 9
    end
    self.dealCardManager:reset()

    local setDealedCardDisplay = function()
        --显示手牌
        for i = 0, 9 do
            local player = self.model.playerList[i]
            
            if player and not player.isSelf and player.isPlay == 1 then
                self.dealCardManager:showDealedCard(player, player.cardsCount)
            end
        end
    end

    --转动座位
    local capacity = math.abs(step)
    for seatId = 0, 8 do
        local seat = self.seats_[seatId]
        local seatCurPos = seat:getPositionId()
        if seat then
            local seatPa = {}
            seatPa[#seatPa + 1] = cc.p(seat:getPositionX(), seat:getPositionY())

            for i = 1, capacity do
                local idx
                if step > 0 then
                    --逆时针转
                    if seatCurPos - i >= 1 then
                        idx = seatCurPos - i
                    else
                        idx = seatCurPos - i + 9
                    end
                else
                    --顺时针转
                    if seatCurPos + i <= 9 then
                        idx = seatCurPos + i
                    else
                        idx = seatCurPos + i - 9
                    end
                end
                
                seatPa[#seatPa + 1] = SeatPosition[idx]
                if i == capacity then
                    seat:setPositionId(idx)
                    if not seat:getParent() or not animation then
                        seat:setPosition(SeatPosition[idx])
                    end
                end
            end
            if animation then
                if seat:getParent() then
                    seat:runAction(cc.CatmullRomTo:create(0.5, seatPa))
                end
            end
        end
    end

    if animation then
        --隐藏手牌
        self.dealCardRotateShowDelayId_ = self.schedulerPool:delayCall(function()
            self.dealCardRotateShowDelayId_ = nil
            setDealedCardDisplay()
        end, 0.6)
    else
        setDealedCardDisplay()
    end

    --移动dealer位置
    self.animManager:rotateDealer(step)

    --转动灯光
    local lampPositionId = self.lampManager:getPositionId()
    lampPositionId = lampPositionId - step
    if lampPositionId > 9 then
        lampPositionId = lampPositionId - 9
    elseif lampPositionId < 1 then
        lampPositionId = lampPositionId + 9
    end
    self.lampManager:turnTo(lampPositionId, true)

    -- 转动筹码
    self.chipManager:moveChipStack()
end

function SeatManager:updateAllSeatState()
    for i = 0, 9 do
        local seat = self.seats_[i]
        seat:setSeatData(self.model.playerList[i])
        seat:updateState()
    end
end

function SeatManager:updateSeatState(seatId)
    local seat = self.seats_[seatId]
    local seatData = self.model.playerList[seatId]
    seat:setSeatData(seatData)
    seat:updateState()
end

function SeatManager:playSitDownAnimation(seatId)
    local seat = self.seats_[seatId]
    if seat then
        seat:playSitDownAnimation()
    end
end

function SeatManager:fadeSeat(seatId)
    local seat = self.seats_[seatId]
    if seat then
        seat:fade()
    end
end

function SeatManager:playStandUpAnimation(seatId, onCompleteCallback)
    local seat = self.seats_[seatId]
    if seat then
        seat:playStandUpAnimation(onCompleteCallback)
    end
end

function SeatManager:updateHeadImage(seatId, imageUrl)
    local seat = self.seats_[seatId]
    if seat then
        if imageUrl then
            seat:updateHeadImage(imageUrl)
        end
    end
end

function SeatManager:updateGiftUrl(seatId, giftId)
    local seat = self.seats_[seatId]
    if seat and giftId then
        seat:updateGiftUrl(giftId)
    end
end

function SeatManager:playSeatWinAnimation(seatId)
    local seat = self.seats_[seatId]
    if seat then
        seat:playWinAnimation()
    end
end

function SeatManager:stopCounter()
    for i = 0, 9 do
        local counter = self.seats_[i]:getChildByTag(SEAT_PROGRESS_TIMER_TAG)
        if counter then
            counter:removeFromParent()
            if USE_COUNTER_POOL then
                self.counterPool_:recycle(counter)
            end
        end
    end
    if self.counterTimeoutId_ then
        self.schedulerPool:clear(self.counterTimeoutId_)
        self.counterTimeoutId_ = nil
    end
    if self.dealerTapTableTimeoutId_ then
        self.schedulerPool:clear(self.dealerTapTableTimeoutId_)
        self.dealerTapTableTimeoutId_ = nil
    end
    self.counterSeatId_ = nil
end

function SeatManager:stopCounterOnSeat(seatId)
    local counter = self.seats_[seatId]:getChildByTag(SEAT_PROGRESS_TIMER_TAG)
    if counter then
        counter:removeFromParent()
        if USE_COUNTER_POOL then
            self.counterPool_:recycle(counter)
        end

        if self.counterTimeoutId_ then
            self.schedulerPool:clear(self.counterTimeoutId_)
            self.counterTimeoutId_ = nil
        end
        if self.dealerTapTableTimeoutId_ then
            self.schedulerPool:clear(self.dealerTapTableTimeoutId_)
            self.dealerTapTableTimeoutId_ = nil
        end
        self.counterSeatId_ = nil
    end
end

function SeatManager:startCounter(seatId) 
    -- dump(seatId,"seatid")
    -- dump(self.isSystemDealer_,"self.isSystemDealer_")
    if seatId == 9 and self.isSystemDealer_ == true then return end
    local gameInfo = self.model.gameInfo
    self:stopCounter()
    local seat = self.seats_[seatId]
    local seatData = seat:getSeatData()
    if seat and seatData then
        self.counterSeatId_ = seatId
        if USE_COUNTER_POOL then
            self.counterPool_:retrive():addTo(seat, 1, SEAT_PROGRESS_TIMER_TAG)
        else
            if gameInfo.gameStatus == consts.SVR_GAME_STATUS.BET_ROUND then
                self.seatTimerBetExpire_ = gameInfo.userAnteTime
            elseif gameInfo.gameStatus == consts.SVR_GAME_STATUS.GET_POKER then
                self.seatTimerBetExpire_ = gameInfo.extraCardTime
            end            
            SeatProgressTimer.new(self.seatTimerBetExpire_):addTo(seat, 1, SEAT_PROGRESS_TIMER_TAG)
        end
        if seatData.isSelf then
            self.counterTimeoutId_ = self.schedulerPool:delayCall(function() 
                seat:shakeAllHandCards()
            end, self.seatTimerBetExpire_ * 0.75)
        end

        -- 荷官敲桌子
        self.dealerTapTableTimeoutId_ = self.schedulerPool:delayCall(function() 
            self.dealerManager:tapTable()
        end, self.seatTimerBetExpire_ * 0.5)
    end
end

function SeatManager:onSeatClicked_(evt)
    local seat = self.seats_[evt.seatId]
    if seat:isEmpty() then

        if seat:getPositionId() == 10 then

            local isCashRoom
            local myMoney
            if self.ctx.model.roomInfo.rmType == consts.ROOM_TYPE_EX.GRAB_CASH then
                myMoney = nk.userData['match.point']
                isCashRoom = 1
            else
                myMoney = nk.userData["aUser.money"]
                isCashRoom = 0
            end

            local door = self.ctx.model:getGrabDealerNeedCoin()
            --local roomExchangeMoney = self.ctx.model:getExchangeMoney()
            local betMoney = self.ctx.model:getCurBetMoney()

            if myMoney-betMoney - door <0 then
                if isCashRoom == 0 then
                    nk.TopTipManager:showTopTip(T("金币不足"))
                else
                    nk.TopTipManager:showTopTip(T("您的现金币不足"))
                     nk.ui.Dialog.new({
                        messageText = bm.LangUtil.getText("GRAB_DEALER", "GRAB_ROOM_NOT_MONEY"), 
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
           -- local myAnte = nk.userData['aUser.anteMoney'] or 0
            if isCashRoom == 1 then
                local maxMoney = myMoney-betMoney
                nk.server:userGrabDealer(maxMoney)
                return
            else
                 local maxMoney = myMoney-betMoney
                nk.server:userGrabDealer(maxMoney)
                return
            end
            GrabDealerBuyInPopup.new({
                    isCash = isCashRoom,
                    minBuyIn = door,
                    maxBuyIn = myMoney-betMoney,
                    isAutoBuyin = false,
                    callback = function(buyinChips, isAutoBuyin1)
                        nk.server:userGrabDealer(buyinChips)
                    end
            }):showPanel()

            return 
        end
        local isCashRoom
        local myMoney
        if self.ctx.model.roomInfo.rmType == consts.ROOM_TYPE_EX.GRAB_CASH then
            myMoney = nk.userData['match.point']
            isCashRoom = 1
        else
            myMoney = nk.userData["aUser.money"]
            isCashRoom = 0
        end

        if myMoney < self.model.roomInfo.enterLimit then

            if isCashRoom == 1 then

                 nk.ui.Dialog.new({
                        messageText = bm.LangUtil.getText("GRAB_DEALER", "GRAB_ROOM_NOT_MONEY"), 
                        hasCloseButton = true,
                        callback = function (type)
                            if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                                --nk.TopTipManager:showTopTip("前往支付")
                                StorePopup.new(2):showPanel()
                            end
                        end
                    }):show()
                return
            end

            local roomData = nk.getRoomDataByLevel(self.model.roomInfo.roomType) 
        
            local roomDataFilter = {}

            roomDataFilter.blind = self.model.roomInfo.blind
            roomDataFilter.minBuyIn = self.model.roomInfo.enterLimit
            roomDataFilter.maxBuyIn = 0
            roomDataFilter.roomType = 3--roomData.roomGroup
            roomDataFilter.enterLimit = self.model.roomInfo.enterLimit
            PayGuidePopMgr.new(roomDataFilter):show(true)

        else

            if isCashRoom == 1 then
                self:onBuyin_(evt.seatId, nk.userData['match.point'], isAutoBuyin1)
                return
            else
                self:onBuyin_(evt.seatId, nk.userData['aUser.money'], isAutoBuyin1)
                return
            end

            BuyInPopup.new({
                    isCash = isCashRoom,
                    minBuyIn = self.model.roomInfo.minBuyIn,
                    maxBuyIn = self.model.roomInfo.maxBuyIn,
                    isAutoBuyin = nk.userDefault:getBoolForKey(nk.cookieKeys.AUTO_BUY_IN, true),
                    callback = function(buyinChips, isAutoBuyin1)
                        self:onBuyin_(evt.seatId, buyinChips, isAutoBuyin1)
                    end
            }):showPanel()
        end

    else if seat:getSeatData().isSelf then
            local tableAllUid, toUidArr = self.model:getTableAllUid()
            local tableNum = self.model:getNumInSeat()
            local tableMessage = {tableAllUid = tableAllUid,toUidArr = toUidArr,tableNum = tableNum, minMoney = self.model.roomInfo.enterLimit}
            if self.ctx.model.roomInfo.rmType == consts.ROOM_TYPE_EX.GRAB_CASH then
                tableMessage.isCash = 1
            end
            UserInfoPopup.new():show(true, tableMessage,nil,self.model:isSelfInGame())
        else
            UserInfoOtherDialog.new(self.ctx):show(seat:getSeatData())
        end
    end
end

function SeatManager:onBuyin_(seatId, buyinChips, isAutoBuyin)
    nk.server:seatDown(seatId, buyinChips, isAutoBuyin)    
end


function SeatManager:showHandCard()
    for i = 0, 9 do
        local seat = self.seats_[i]
        local seatData = seat:getSeatData()       
        if seatData and seatData.isOutCard == 1 then            
            local handCards = seatData.cards           
            if not seatData.isSelf then
                self.dealCardManager:moveDealedCardToSeat(seatData, function()
                    print("seat " .. seat.seatId_ .. " showHandCard")
                    if seat:getSeatData() == seatData then
                        seat:setHandCardNum(seatData.cardsCount)
                        seat:setHandCardValue(handCards)
                        seat:showHandCardBackAll()
                        seat:showAllHandCardsElement()
                        seat:showHandCards()
                        seat:flipAllHandCards()
                        self.schedulerPool:delayCall(function() 
                            if seat:getSeatData() == seatData then
                                seat:showCardTypeIf()
                            end
                        end, 0.8)
                    elseif seat:getSeatData() == nil then
                        print("seat " .. seat.seatId_ .. " player changed from " .. seatData.uid .. " to nil")
                    else
                        print("seat " .. seat.seatId_ .. " player changed from " .. seatData.uid .. " to " .. seat:getSeatData().uid)
                    end
                end)
            else     
                seat:setHandCardNum(seatData.cardsCount)
                seat:setHandCardValue(handCards)
                seat:showAllHandCardsElement()
                seat:showHandCardFrontAll()
                seat:showHandCards()
                seat:showCardTypeIf()
            end            
        end
    end
end

function SeatManager:showHandCardByOther(seatId)   
    local seat = self.seats_[seatId]
    local seatData = seat:getSeatData()
    if not seatData then return end
    if seatData and seatData.isOutCard == 1 then
        if not seatData.isSelf then
            self.dealCardManager:moveDealedCardToSeat(seatData, function()
                seat:setHandCardValue(seatData.cards)
                seat:showHandCardBackAll()
                seat:showAllHandCardsElement()
                seat:showHandCards()
                seat:flipAllHandCards()
                self.schedulerPool:delayCall(function() 
                    if seat:getSeatData() == seatData then
                        seat:showCardTypeIf()
                    end
                end, 0.8)      
            end)
        end
    end
end

function SeatManager:prepareDealCards()
    local selfSeatId = self.model:selfSeatId()
    for i = 0, 9 do
        local seat = self.seats_[i]
        seat:setSeatData(self.model.playerList[i])
        seat:setHandCardNum(2)
        if i == selfSeatId then
            seat:setHandCardValue(seat:getSeatData().cards)
            seat:showHandCardBackAll()
            seat:hideAllHandCardsElement()
            seat:showHandCards()
        else
            seat:showHandCardBackAll()
            seat:hideHandCards()
        end
    end
end

function SeatManager:onAddExp(evt)
    local selfSeatId = self.model:selfSeatId()
    if selfSeatId ~= -1 and evt and evt.exp and evt.exp ~= 0 then
        local seat = self.seats_[selfSeatId]
        if seat then
            seat:playExpChangeAnimation(evt.exp)
        end
    end
end
function SeatManager:onUpdateAnte(evt)
    local selfSeatId = self.model:selfSeatId()
    local data = evt.data
    if selfSeatId ~= -1 and evt and data.chip and data.chip ~= 0 then
        local seat = self.seats_[selfSeatId]
        if seat then
            seat:updateAnte(checkint(data.chip))
            nk.userData['aUser.anteMoney'] = checkint(nk.userData['aUser.anteMoney'])+checkint(data.chip)
        end
    end
end
--播放座位加经验的动画，只播放自己的
function SeatManager:playExpChangeAnimation()
    if self.model:isSelfInSeat() then
        local selfSeatId = self.model:selfSeatId()
        local playerSelf = self.model:selfSeatData()
        if playerSelf and playerSelf.isPlayBeforeGameOver == 1 then
            if playerSelf.getExp > 0 then
                local seat = self.seats_[selfSeatId]
                if seat then
                    seat:playExpChangeAnimation(playerSelf.getExp)
                end
            end
        end
    end
end

--刷新庄家位置(补币)
function SeatManager:addDealerHandCoin(totalmoney)
    local seat = self.seats_[9]
    local seatData = seat:getSeatData()
    if seatData then
        seatData.anteMoney = totalmoney
        seat:setSeatData(seatData)
        seat:updateState()
        if self.model:selfSeatId() == 9 then
            nk.userData['aUser.anteMoney'] = seatData.anteMoney
        end
    end
end
--设置庄家位置是否显示正常玩家
--该位置有可能是系统庄家
function SeatManager:setDealerSeat(isshow)
    local seat = self.seats_[9]
    if isshow then
        self.isSystemDealer_ = false
        seat:setDealerStatus(true)
    else
        seat:setDealerStatus(false)
        self.isSystemDealer_ = true
    end
end
function SeatManager:reset()
    for i = 0, 9 do
        local seat = self.seats_[i]
        seat:reset()
    end
    self:stopCounter()
end

return SeatManager