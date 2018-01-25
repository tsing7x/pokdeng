--
-- Author: tony
-- Date: 2014-07-08 14:23:34
--

local SeatStateMachine = import(".SeatStateMachine")
local HandPoker = import(".HandPoker")
local logger = bm.Logger.new("RoomModel")
local RoomModel = {}

function RoomModel.new()
    local instance = {}
    local datapool = {}
    local function getData(table, key)
        return RoomModel[key] or datapool[key]
    end
    local function setData(table, key, value)
        datapool[key] = value
    end
    local function clearData(self)
        local newdatapool = {}
        for k, v in pairs(datapool) do
            if type(v) == "function" then
                newdatapool[k] = v
            end
        end
        datapool = newdatapool
        return self
    end
    instance.clearData = clearData
    local mtable = {__index = getData, __newindex = setData}
    setmetatable(instance, mtable)
    instance:ctor()
    return instance
end

function RoomModel:ctor()
    self.isInitialized = false
    self.isSelfInGame_ = false  
    self.selfSeatId_ = -1    
    self.roomType_ = 0
end

-- 是否是自己
function RoomModel:isSelf(uid)
    return nk.userData.uid == uid
end

-- 是否正在游戏（游戏开始至游戏刷新，弃牌置为false）
function RoomModel:isSelfInGame()
    return self.isSelfInGame_
end

-- 本人是否在座
function RoomModel:isSelfInSeat()
    return self.selfSeatId_ >= 0 and self.selfSeatId_ <= 8
end

-- 本人是否有可参与牌局的牌
function RoomModel:hasCardActive()
    return self.hasCardActive_
end

-- 本人是否为庄家
function RoomModel:isSelfDealer()
    return self.selfSeatId_ == self.gameInfo.dealerSeatId
end


-- 获取自己的座位id
function RoomModel:selfSeatId()
    return self.selfSeatId_
end

-- 获取自己
function RoomModel:selfSeatData()
    return self.playerList[self.selfSeatId_]
end

-- 获取庄家
function RoomModel:dealerSeatData()
    return self.playerList[self.gameInfo.dealerSeatId]
end

-- 获取当前房间类型
function RoomModel:roomType()
    return self.roomType_
end

-- 获取当前在桌人数
function RoomModel:getNumInSeat()
    local num = 0
    for i = 0, 8 do
        if self.playerList[i] then
            num = num + 1
        end
    end

    return num
end
-- 获取牌桌所有用户的UID 
function RoomModel:getTableAllUid()
    local tableAllUid = ""
    local userUid = ""
    local toUidArr = {}
    for seatId = 0, 8 do
        local player = self.playerList[seatId]
        if player and player.uid then
            userUid = userUid..","..player.uid
            table.insert(toUidArr, player.uid)
        end
        tableAllUid = string.sub(userUid,2)
    end
    return tableAllUid,toUidArr
end

function RoomModel:getSeatIdByUid(uid)
    for seatId = 0, 8 do
        local player = self.playerList[seatId]
        if player and player.uid == uid then
            return seatId
        end
    end
    return -1
end


-- 获取本轮参与玩家人数
function RoomModel:getNumInRound()
    local num = 0
    for i = 0, 8 do
        if self.playerList[i] and self.playerList[i].isPlay == 1 then
            num = num + 1
        end
    end
    return num
end

function RoomModel:getNewCardType(cardType, pointCount)
    return CardType.new(cardType, pointCount)
end


function RoomModel:initWithLoginSuccessPack(pack)
    self.clearData()
    self.isInitialized = true
    self.isSelfInGame_ = false  -- 是否在游戏中
    self.hasCardActive_ = false
    self.selfSeatId_ = -1
    self.roomType_ = 0

    --座位配置
    local seatsInfo = {}
    self.seatsInfo = seatsInfo
    seatsInfo.seatNum = pack.maxSeatCnt
    for i=1, pack.maxSeatCnt do
        local seatId = i - 1
        local seatInfo = {}
        seatInfo.seatId = seatId
        seatsInfo[seatId] = seatInfo
    end
    
    --房间信息
    local roomInfo = {}
    self.roomInfo = roomInfo
    roomInfo.minBuyIn = pack.minAnte
    roomInfo.maxBuyIn = pack.maxAnte
    roomInfo.roomType = pack.tableLevel
    roomInfo.blind = pack.baseAnte
    roomInfo.playerNum = pack.maxSeatCnt
    roomInfo.defaultBuyIn = pack.defaultAnte
    roomInfo.tid     = pack.tableId
    
    if roomInfo.roomType == consts.ROOM_TYPE.PERSONAL_NORMAL then
        roomInfo.gameType = consts.ROOM_TYPE.PERSONAL_NORMAL
    else
        roomInfo.gameType = consts.ROOM_TYPE.NORMAL
    end

    --房间level, 房间类型
    self.roomType_ = roomInfo.roomType


    --游戏信息
    local gameInfo = {}
    self.gameInfo = gameInfo
    
    --桌子当前状态 0牌局已结束 1下注中 2等待用户获取第3张牌
    gameInfo.gameStatus = pack.tableStatus

    if gameInfo.gameStatus == consts.SVR_GAME_STATUS.GET_POKER then
        gameInfo.curDealSeatId = pack.curDealSeatId
    else
        gameInfo.curDealSeatId = -1
    end
    gameInfo.dealerSeatId = pack.dealerSeatId
    gameInfo.userAnteTime = pack.userAnteTime
    gameInfo.extraCardTime = pack.extraCardTime
    gameInfo.totalAnte = pack.totalAnte

    -- self.isSelfInGame_ = false  --是否在游戏中  

    --在玩玩家信息
    local playerList = {}
    self.playerList = playerList
    for i, player in ipairs(pack.playerList) do
        player.userInfo = json.decode(player.userInfo)
        if not player.userInfo then
           player.userInfo = nk.getUserInfo(true) 
        end
        playerList[player.seatId] = player
        
        player.isSelf = self:isSelf(player.uid)        
        if player.isSelf then
            self.selfSeatId_ = player.seatId
            self.isSelfInGame_ = (player.isPlay == 1)   

            self.hasCardActive_ = (gameInfo.gameStatus ~= 0 and gameInfo.gameStatus ~= 1 )                   
        end        
        if player.isOutCard == 1 then
            if player.card1 ~= 0 then
                player.cards = {player.card1, player.card2}
                if player.card3 ~= 0 then
                    player.cards[3] = player.card3
                end
                player.card1 = nil
                player.card2 = nil
                player.card3 = nil
            end
            if player.cards then
                local handPoker = HandPoker.new()
                handPoker:setCards(player.cards)
                player.handPoker = handPoker
                player.cardsCount = #player.cards
            else
                player.cardsCount = 0 
            end
        end
        player.isDealer =  (player.seatId == self.gameInfo.dealerSeatId)
        player.statemachine = SeatStateMachine.new(player, player.seatId == gameInfo.curDealSeatId, gameInfo.gameStatus)
    end   
end

function RoomModel:processGameStart(pack)
    -- 设置gameInfo
    self.gameInfo.gameStatus = consts.SVR_GAME_STATUS.BET_ROUND
    self.gameInfo.dealerSeatId = pack.dealerSeatId
    for i = 0, 8 do
        local player = self.playerList[i]
        if player then
            player.isPlay = 1
            player.isDealer =  ( i ==  self.gameInfo.dealerSeatId )        
            player.statemachine:doEvent(SeatStateMachine.GAME_START)
            if player.isDealer then                
                player.statemachine:doEvent(SeatStateMachine.SET_DEALER)
            end
            player.isOutCard = 0
            player.nCurAnte = 0
            player.cards = nil
            player.cardsCount = 0
            player.handPoker = nil
            player.trunMoney = 0
            player.getExp = 0
            player.isPlayBeforeGameOver = 0
            if player.isSelf then
                self.isSelfInGame_ = true  
            end
        end
    end

    for _,row in ipairs(pack.anteMoneyList) do
        local player = self.playerList[row.seatId]
        player.anteMoney = row.anteMoney
        if player.isSelf then
            nk.userData['aUser.anteMoney'] = player.anteMoney
        end
    end    
end

function RoomModel:isChangeDealer()
    if self.gameInfo == nil or self.gameInfo.dealerSeatId == nil then
        return true
    end
    local oldDealer = self.gameInfo.dealerSeatId
    local maxMoney = 0
    local dealerSeatId = 0
    for i=0,8 do
        local player = self.playerList[i]
        if player then
            if player.anteMoney > maxMoney then
                dealerSeatId = player.seatId
                maxMoney = player.anteMoney
            end
        end
    end    
    return oldDealer ~= dealerSeatId
end

function RoomModel:processBetSuccess(pack)
    local player = self.playerList[pack.seatId]  
    player.nCurAnte = pack.nCurAnte -- 总下注
    player.anteMoney = player.anteMoney - player.nCurAnte
    if player.anteMoney == 0 then
        player.statemachine:doEvent(SeatStateMachine.ALL_IN, player.anteMoney)
    else
        player.statemachine:doEvent(SeatStateMachine.CALL)
    end
    if player.anteMoney < 0 then
        printError("anteMoney is "..player.anteMoney)
    end
    return pack.seatId
end

function RoomModel:processPot(pack)
    self.gameInfo.totalAnte = pack.totalAnte  
end

--发牌
function RoomModel:processDeal(pack)
    local player = self:selfSeatData()
    player.cards = pack.cards
    player.cardsCount = #pack.cards
    local handPoker = HandPoker.new()
    handPoker:setCards(player.cards)
    player.handPoker = handPoker
    player.isOutCard = 0
    self.hasCardActive_ = true
end

--亮牌
function RoomModel:processShowHand(pack)
    local player = self.playerList[pack.seatId] 
    player.cards = pack.cards
    player.isOutCard = 1
    player.cardsCount = #pack.cards
    local handPoker = HandPoker.new()
    handPoker:setCards(player.cards)
    player.handPoker = handPoker
    player.statemachine:doEvent(SeatStateMachine.SHOW_POKER)
end

function RoomModel:processTurnToGetPoker(pack)
    self.gameInfo.gameStatus = consts.SVR_GAME_STATUS.GET_POKER
    local player = self.playerList[pack.seatId] 
    player.statemachine:doEvent(SeatStateMachine.TURN_TO)
    return pack.seatId
end

function RoomModel:processGetPoker(pack)
    local player = self.playerList[pack.seatId] 
    player.statemachine:doEvent(SeatStateMachine.GET_POKER)
    if pack.type == 1 then
        player.cardsCount = 3
    else
        player.cardsCount = 2
    end
    return pack.seatId
end

function RoomModel:processGetPokerBySelf(pack)
    local player = self:selfSeatData()     
    player.cardsCount = 3
    player.handPoker:addCard(pack.card)
    player.cards[3] = pack.card
    player.isOutCard = 0
end

function RoomModel:processSitDown(pack)
    local player = pack
    local prePlayer = self.playerList[player.seatId]
    local isAutoBuyin = false
    if prePlayer then
        if prePlayer.uid == player.uid then
            isAutoBuyin = true
        end
    end

    player.userInfo = json.decode(player.userInfo)
    if not player.userInfo then
       player.userInfo = nk.getUserInfo(true) 
    end

    player.isPlay = 0
    player.isDealer = (player.seatId == self.gameInfo.dealerSeatId)   
    player.statemachine = SeatStateMachine.new(player, false, self.gameInfo.gameStatus)
    self.playerList[player.seatId] = player
    player.isSelf = self:isSelf(player.uid)
    -- 判断是否是自己
    if player.isSelf then
        self.selfSeatId_ = player.seatId
        --nk.userData['aUser.money'] = pack.money - pack.anteMoney
        nk.userData['aUser.money'] = pack.money
        nk.userData['aUser.anteMoney'] = pack.anteMoney
        player.userInfo.mavatar = nk.userData['aUser.micon']
        player.userInfo.giftId = nk.userData['aUser.gift']

        -- bm.DataProxy:setData(nk.dataKeys.SIT_OR_STAND, {inSeat = self:isSelfInSeat(),seatId = player.seatId,ctx = self.ctx})
       
        nk.http.getUserProps(2,function(pdata)
            if pdata then
                for _,v in pairs(pdata) do
                    if tonumber(v.pnid) == 2001 then
                        nk.userData.hddjNum = checkint(v.pcnter)
                        break
                    end
                end
            end
            
        end,function()
            
        end)

        --[[
        bm.HttpService.POST({mod="user", act="getUserFun"}, function(ret)
            local num = tonumber(ret)
            if num then
                nk.userData.hddjNum = num
            end
        end)
        --]]
    end
    return player.seatId, isAutoBuyin
end

function RoomModel:processStandUp(pack)
    local player = self.playerList[pack.seatId]
    if player and player.isSelf then              
        self.isSelfInGame_ = false
        self.hasCardActive_ = false
        self.selfSeatId_ = -1

        -- bm.DataProxy:setData(nk.dataKeys.SIT_OR_STAND, {inSeat = self:isSelfInSeat(),seatId = player.seatId,ctx = self.ctx})
        nk.userData["aUser.money"] = pack.money
    end
    player = nil
    self.playerList[pack.seatId] = nil
    return pack.seatId
end

function RoomModel:processGameOver(pack)
    self.gameInfo.gameStatus = consts.SVR_GAME_STATUS.READY_TO_START
    local isSelfPlayed = false
    for _,row in ipairs(pack.playerList) do
       local player = self.playerList[row.seatId]
       if player then
            player.anteMoney = row.anteMoney
            -- 如果闲家金币变化为0则退还筹码
            if row.trunMoney == 0 and not player.isDealer then
                player.trunMoney = player.nCurAnte
            else                
                player.trunMoney = row.trunMoney
                if not player.isDealer then
                    player.trunMoney = row.trunMoney + player.nCurAnte
                end
            end
            player.cards = row.cards
            local handPoker = HandPoker.new()
            handPoker:setCards(player.cards)
            player.handPoker = handPoker
            player.cardsCount = #player.cards
            player.isOutCard = 1
            player.getExp = row.getExp            

            if player.isSelf then
                self:processBestCard(player.cards)
                --row.trunMoney :玩家变化的钱
                self:processMaxWinMoney(row.trunMoney)
                nk.userData['aUser.anteMoney'] = row.anteMoney
                
                -- 上报游戏结束
                bm.EventCenter:dispatchEvent({name = nk.DailyTasksEventHandler.REPORT_GAME_OVER, 
                    data = {
                        roomInfo = self.roomInfo,
                        selfWin = (row.trunMoney > 0) and true or false,
                        inSeat = self:isSelfInSeat(),
                        seatId = player.seatId,
                        ctx = self.ctx
                    }})
            
               isSelfPlayed = true
            end


       end
    end

    local dealer = self:dealerSeatData()
    if dealer and checkint(dealer.trunMoney) < 0 then 
        dealer.nCurAnte = - dealer.trunMoney
    end

    for i = 0, 8 do
        local player = self.playerList[i]
        if player then
            player.isPlayBeforeGameOver = player.isPlay
            player.isPlay = 0            
            player.statemachine:doEvent(SeatStateMachine.GAME_OVER)
        end
    end
    self.isSelfInGame_ = false
    self.hasCardActive_ = false

    return isSelfPlayed
end

function RoomModel:processCardRecord(pack)
    local recordInfos = {}
    if pack and pack.playerList then
        local player
        for _,v in pairs(pack.playerList) do
            player = {}

            player.uid = v.uid
            player.seatId = v.seatId
            if self.playerList and self.playerList[v.seatId]then
                local tp = self.playerList[v.seatId]
                player.name = tp.userInfo.name or v.uid or ""
                player.isDealer = tp.isDealer or false
                player.mavatar = tp.userInfo.mavatar or ""
            end
            player.trunMoney = v.trunMoney
            player.anteMoney = v.anteMoney
            player.getExp = v.getExp
            player.cards = v.cards
            table.insert(recordInfos,player)
            --以下逻辑连胜为统计
              --nk.userData["aUser.card_five_multiple_"]=1;
              --nk.userData["aUser.conWinNum_"] = 5;
            if checkint(player.uid) == nk.userData["aUser.mid"] then
                if player.trunMoney >0 then
                    if not self.conWin then
                        self.conWin =  1
                    else
                        self.conWin = self.conWin +1
                        if self.conWin == 3 then
                           
                            if device.platform == "android" or device.platform == "ios" then
                                cc.analytics:doCommand{command = "event",
                                args = {eventId = "conWin_3"}}
                            end
                      
                        end

                        if self.conWin == 5 then
                            nk.userData["aUser.conWinNum_"] = 5;
                            
                            if device.platform == "android" or device.platform == "ios" then
                                cc.analytics:doCommand{command = "event",
                                args = {eventId = "conWin5"}}
                            end
                       
                        end
                    end
                else
                    self.conWin = 0
                end 
            end

        end

    end

    return recordInfos

end



function RoomModel:processMaxWinMoney(winMoney)
    if nk.userData.best and nk.userData.best.maxwmoney then
        if winMoney > nk.userData.best.maxwmoney then
            local info = {}
            info.maxwmoney = winMoney
            nk.http.updateMemberBest(info)
            nk.userData.best["maxwmoney"] = info.maxwmoney

        end
    end
end



--更新最大手牌
function RoomModel:processBestCard(nowCards)

    local needReportMaxCard = false
    local maxwcard = ""
    if nk.userData.best then
        if (nk.userData.best.maxwcard == nil) or (nk.userData.best.maxwcard == "") then
            for _,v in ipairs(nowCards) do
                maxwcard = maxwcard .. string.format("%X",v)
            end
        else
            local vals = string.sub(nk.userData.best.maxwcard, 1, 6)
            local len = math.floor(string.len(vals)/2)

            local cards = {}
            for i=1,len do
                cards[i] = string.sub(vals,2*i - 1,2*i)
            end

            -- local cards = {
            --     string.sub(vals, 1, 2), 
            --     string.sub(vals, 3, 4), 
            --     string.sub(vals, 5, 6)
            -- }

            local pokerCards = {}
            for i = 1, len do
                pokerCards[i] = (tonumber(string.sub(cards[i], 1, 1), 16) * 16 + tonumber(string.sub(cards[i], 2, 2), 16))
            end
                
            local lastMaxCard = HandPoker.new()
            lastMaxCard:setCards(pokerCards)

            local handPoker = HandPoker.new()
            handPoker:setCards(nowCards)

            if handPoker:compare(lastMaxCard) > 0 then
                local max = ""
                for _,v in pairs(nowCards) do
                    maxwcard = maxwcard .. string.format("%X",v)
                end
            end
        end

        if maxwcard ~= "" then
            nk.http.updateMemberBest({maxwcard = maxwcard})
            nk.userData.best["maxwcard"] = maxwcard
        end
    end

    
end

--当前桌子上的总筹码（奖池+座位已下注筹码)
function RoomModel:totalChipsInTable()

    local total = 0
    -- local pots = self.gameInfo.pots
    -- if pots then
    --     for _,v in pairs(pots) do
    --         total = total + v.potChips
    --     end
    -- end
    -- for i = 0, 8 do
    --     local player = self.playerList[i]
    --     if player and player.betChips then
    --         total = total + tonumber(player.betChips)
    --     end
    -- end
    return total
end


function RoomModel:processSendChipSuccess(pack)
    local fromPlayer = self.playerList[pack.fromSeatId]
        local toPlayer = self.playerList[pack.toSeatId]
        local chips = pack.chips
        if fromPlayer then
            fromPlayer.seatChips = fromPlayer.seatChips - chips
        end
        if toPlayer then
            toPlayer.seatChips = toPlayer.seatChips + chips
        end
end

function RoomModel:processSendExpression(pack)
    local player = self.playerList[pack.seatId]
    local expressionId = pack.expressionId
    if player then
        if pack.minusChips > 0 and player.seatChips >= pack.minusChips then
            player.seatChips = player.seatChips - pack.minusChips
            return pack.seatId, expressionId, player.isSelf, pack.minusChips
        else
            return pack.seatId, expressionId, player.isSelf, 0
        end
    end
    return nil, nil, nil
end

function RoomModel:processRoomBroadcast(pack)
    local content = json.decode(pack.content)
    local mtype = content.type
    if mtype == 1 then
        local chatHistory = bm.DataProxy:getData(nk.dataKeys.ROOM_CHAT_HISTORY)
        if not chatHistory then
            chatHistory = {}
        end
        local msg = bm.LangUtil.getText("ROOM", "CHAT_FORMAT", content.name, content.msg)
        chatHistory[#chatHistory + 1] = {messageContent = msg, time = bm.getTime(), mtype = 2}
        bm.DataProxy:setData(nk.dataKeys.ROOM_CHAT_HISTORY, chatHistory)
        local seatId = -1
        for i = 0, 8 do
            local player = self.playerList[i]
            if player and player.uid == content.uid then
                seatId = i
                break
            end
        end
        return mtype, content, seatId, msg
    elseif mtype == 2 then
        --换头像
        local uid = pack.param
        local seatId = self:getSeatIdByUid(uid)
        local url = content.url
        logger:debugf("receive head image update packet-> %s, %s, %s", uid, seatId, url)
        if seatId ~= -1 then
            local player = self.playerList[seatId]
            logger:debugf("modify seat %s img -> %s", seatId, url)
            player.img = url
        end
        return mtype, content, seatId, uid, url
    elseif mtype == 3 then
        -- 赠送礼物
        local fromUid = pack.param
        local fromSeatId = self:getSeatIdByUid(fromUid)
        local giftId = content.giftId
        local toUidArr = content.toUidArr
        local toSeatIdArr = {}
        if toUidArr and #toUidArr > 0 then
            for _, toUid in ipairs(toUidArr) do
                local toSeatId = self:getSeatIdByUid(toUid)
                if toSeatId ~= -1 then
                    self.playerList[toSeatId].giftId = giftId
                    table.insert(toSeatIdArr, toSeatId)
                end
            end
        end
        return mtype, content, giftId, fromSeatId, toSeatIdArr, fromUid, toUidArr
    elseif mtype == 4 then
        -- 设置礼物
        local uidToSet = pack.param
        local giftId = content.giftId
        local seatIdToSet = self:getSeatIdByUid(uidToSet)
        if seatIdToSet ~= -1 then
            self.playerList[seatIdToSet].giftId = giftId
        end
        return mtype, content, seatIdToSet, giftId
    end
    return mtype, content, pack.param
end

function RoomModel:reset()  
    self.isSelfInGame_ = false
    self.hasCardActive_ = false
end

return RoomModel