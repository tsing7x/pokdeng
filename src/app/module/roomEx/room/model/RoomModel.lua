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
    return self.selfSeatId_ >= 0 and self.selfSeatId_ <= 9
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
-- 获取庄家需要补币的额度
function RoomModel:getDealerAddCoinNum()
    return self.dealerAddCoinNum_ or 0
end
--获取首先发牌的玩家座位号
function RoomModel:getFirstDealCardSeatId()
    return self.firstDealCardSeatId_ or 0
end
--获取是否存在庄家
function RoomModel:getHaveDealer()
    return self.haveDealer_ or 0
end
--获取抢庄最小门槛值
function RoomModel:getGrabDealerNeedCoin()
    return self.grabNeedCoin_ or 0
end
--获取房间内金币变化值
--(玩家抢庄、补币，需要一个自己的最大金币，nk.userdata["aUser.money"]
--在玩家退出房间才会刷新，所以此值不能作为自己的最大抢庄值和补币值
--需要加上在牌局中赢的钱和减去输的钱)
function RoomModel:getExchangeMoney()
    return self.exchangeMoney_ or 0
end
function RoomModel:getCurBetMoney()
    return self.betMoeny_ or 0
end
-- 获取当前在桌人数
function RoomModel:getNumInSeat()
    local num = 0
    for i = 0, 9 do
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
    for seatId = 0, 9 do
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
    for seatId = 0, 9 do
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
    for i = 0, 9 do
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
    bm.DataProxy:setData(nk.dataKeys.ROOM_INFO_TYPE,1)
    self.clearData()
    self.isInitialized = true
    self.isSelfInGame_ = false
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
    roomInfo.gameType = consts.ROOM_TYPE.NORMAL_GRAB
    roomInfo.highBet = pack.highBet
    roomInfo.betPro = pack.betPro
    roomInfo.miniBet = pack.miniBet
    roomInfo.enterLimit = pack.enterLimit

    --房间level, 房间类型
    self.roomType_ = roomInfo.roomType


    --游戏信息
    local gameInfo = {}
    self.gameInfo = gameInfo
    
    --桌子当前状态 0牌局已结束 1下注中 2等待用户获取第3张牌
    gameInfo.gameStatus = pack.tableStatus
    if gameInfo.gameStatus ~= 2 then
        self.firstDealCardSeatId_ = pack.curDealSeatId
    end
    -- local str = "id="..nk.userData["aUser.mid"].." 的游戏状态"..pack.tableStatus
    -- dump(str,"游戏状态")

    if gameInfo.gameStatus == consts.SVR_GAME_STATUS.GET_POKER then
        gameInfo.curDealSeatId = pack.curDealSeatId
    else
        gameInfo.curDealSeatId = -1
    end
    gameInfo.dealerSeatId = pack.dealerSeatId
    gameInfo.userAnteTime = pack.userAnteTime
    gameInfo.extraCardTime = pack.extraCardTime
    gameInfo.totalAnte = pack.totalAnte

    gameInfo.grabDoor = pack.grabDoor --上庄门槛
    self.grabNeedCoin_ = gameInfo.grabDoor

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
        if player.seatId == 9 and player.uid ~= 1 then
            self.haveDealer_ = 1 --进入房间，存在庄家
            if player.anteMoney > self.grabNeedCoin_ then
                self.grabNeedCoin_ = player.anteMoney + 1
            end
        end
        
        player.isSelf = self:isSelf(player.uid)        
        if player.isSelf then
            self.selfSeatId_ = player.seatId
            self.isSelfInGame_ = (player.isPlay == 1) 
            nk.userData['aUser.anteMoney'] = player.anteMoney    

            self.hasCardActive_ = (gameInfo.gameStatus ~= 0 and gameInfo.gameStatus ~= 1)            
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
                local HandPoker = HandPoker.new()
                HandPoker:setCards(player.cards)
                player.HandPoker = HandPoker
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
    self.firstDealCardSeatId_ = pack.firstSeatId
    for i = 0, 9 do
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
            player.HandPoker = nil
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
            if self.roomInfo.rmType == consts.ROOM_TYPE_EX.GRAB_CASH then
                nk.userData["match.point"] = row.money
            else
                nk.userData['aUser.money'] = row.money
            end
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
    for i=0,9 do
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
    if player.isSelf then
        self.betMoeny_ = pack.nCurAnte
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
    dump(pack.cards, "mycardddd".. nk.userData["aUser.mid"])
    player.cardsCount = #pack.cards
    local HandPoker = HandPoker.new()
    HandPoker:setCards(player.cards)
    player.HandPoker = HandPoker
    player.isOutCard = 0
    self.hasCardActive_ = true
end

function RoomModel:deal2CardsToAllTablePlayer()
    -- body
    for i = 0, 9 do
        local player = self.playerList[i]

        if player then
            --todo
            player.cardsCount = 2
        end
    end
end

--亮牌
function RoomModel:processShowHand(pack)
    local player = self.playerList[pack.seatId] 
    player.cards = pack.cards
    player.isOutCard = 1
    player.cardsCount = #pack.cards
    local HandPoker = HandPoker.new()
    HandPoker:setCards(player.cards)
    player.HandPoker = HandPoker
    player.statemachine:doEvent(SeatStateMachine.SHOW_POKER)
end

function RoomModel:processTurnToGetPoker(pack)
    self.gameInfo.gameStatus = consts.SVR_GAME_STATUS.GET_POKER
    local player = self.playerList[pack.seatId] 
    if player then
        player.statemachine:doEvent(SeatStateMachine.TURN_TO)
    end
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
    player.HandPoker:addCard(pack.card)
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

    --dump(self.playerList,"self.playerList",10)
    if player.seatId == 9 and player.uid ~= 1 then
        self.haveDealer_ = 1
        self.grabNeedCoin_ = player.anteMoney +1
    end
   -- dump(self.playerList,"玩家列表")
    -- 判断是否是自己
    if player.isSelf then
        self.selfSeatId_ = player.seatId
        --nk.userData['aUser.money'] = pack.money - pack.anteMoney
        
        nk.userData['aUser.anteMoney'] = pack.anteMoney
        player.userInfo.mavatar = nk.userData['aUser.micon']
        player.userInfo.giftId = nk.userData['aUser.gift']
        bm.DataProxy:setData(nk.dataKeys.SIT_OR_STAND, {inSeat = self:isSelfInSeat(),seatId = player.seatId,ctx = self.ctx})

        --现金币场 不更新金币
        if self.roomInfo.rmType == consts.ROOM_TYPE_EX.GRAB_CASH then
            nk.userData['match.point'] = pack.money
        else
            nk.userData['aUser.money'] = pack.money
        end
        --更新互动道具数量

        --获取道具数量
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

function RoomModel:processStandUp(pack,isOther)
    local player = self.playerList[pack.seatId]
    if pack.seatId == 9 then
        self.haveDealer_ = 0
        self.grabNeedCoin_ = self.gameInfo.grabDoor
    end

    if not isOther then              
        self.isSelfInGame_ = false
        self.hasCardActive_ = false
        self.selfSeatId_ = -1
        bm.DataProxy:setData(nk.dataKeys.SIT_OR_STAND, {inSeat = self:isSelfInSeat(),seatId = player.seatId,ctx = self.ctx})   
        -- 设置金钱
        --现金币场 不更新金币
        if self.roomInfo.rmType == consts.ROOM_TYPE_EX.GRAB_CASH then
            nk.userData['match.point'] = pack.money
        else
            nk.userData['aUser.money'] = pack.money
        end
        nk.userData['aUser.anteMoney'] = 0
    end

    local isIgnore = false
    if isOther and player.isSelf then
        isIgnore = true
        return pack.seatId,isIgnore
    end
    
    if isOther then
        local otherUid = pack.uid
        if otherUid ~= player.uid then
            isIgnore = true
            return pack.seatId,isIgnore
        end
    end

    if not isOther and not player.isSelf then
        isIgnore = true
        return pack.seatId,isIgnore
    end 

    -- if player and player.isSelf then              
    --     self.isSelfInGame_ = false
    --     self.selfSeatId_ = -1
    --     bm.DataProxy:setData(nk.dataKeys.SIT_OR_STAND, {inSeat = self:isSelfInSeat(),seatId = player.seatId,ctx = self.ctx})
        
    --     -- 设置金钱
    --     nk.userData["aUser.money"] = pack.money
    -- end
    player = nil
    self.playerList[pack.seatId] = nil
    
    --dump(self.playerList,"processStandUp===",10)
    return pack.seatId,isIgnore
end

function RoomModel:processGameOver(pack)
    self.gameInfo.gameStatus = consts.SVR_GAME_STATUS.READY_TO_START
    --dump(pack.playerList,"pack.playerListfuckdandan")
    self.turn_money_ = 0
    for _,row in ipairs(pack.playerList) do
       local player = self.playerList[row.seatId]
       if player then
            player.anteMoney = row.anteMoney
            player.userInfo.money = player.anteMoney

            dump(row.seatId,"seatID")
            dump(row.trunMoney,"筹码变化值")

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
            local HandPoker = HandPoker.new()
            HandPoker:setCards(player.cards)
            player.HandPoker = HandPoker
            player.cardsCount = #player.cards
            player.isOutCard = 1
            player.getExp = row.getExp            

            if player.isSelf then
                self:processBestCard(player.cards)
                --row.trunMoney :玩家变化的钱
                self:processMaxWinMoney(row.trunMoney)
                nk.userData['aUser.anteMoney'] = checkint(row.anteMoney)
                nk.userData["aUser.money"] = checkint(row.anteMoney)
                
                self.exchangeMoney_ = self:getExchangeMoney() + row.trunMoney; 
                self.betMoeny_ = 0
                self.turn_money_ = row.trunMoney

                --玩家赢取多少钱，发小喇叭
                
                if self.roomInfo.rmType == consts.ROOM_TYPE_EX.GRAB_CASH then
                    local cash_need_win = bm.DataProxy:getData(nk.dataKeys.CASH_WIN_SEND_NUM)
                    if checkint(row.trunMoney)>= checkint(cash_need_win) then
                        local realMoney = checkint(row.trunMoney) - checkint(checkint(row.trunMoney)* .05)
                        nk.http.sendWinPoint(self.roomInfo.tid,realMoney,function()end,function()end)
                    end
                end
                -- nk.TopTipManager:showTopTip(""..checkint(checkint(row.trunMoney)* .05))
                -- 上报游戏结束
                bm.EventCenter:dispatchEvent({name = nk.DailyTasksEventHandler.REPORT_GAME_OVER, 
                    data = {
                        roomInfo = self.roomInfo,
                        selfWin = (row.trunMoney > 0) and true or false,
                        inSeat = self:isSelfInSeat(),
                        seatId = player.seatId,
                        ctx = self.ctx
                    }})
            
               
            end


       end
    end

    local selfData = self:selfSeatData()
    if selfData and selfData.cards then
        local recordData = bm.DataProxy:getData(nk.dataKeys.NEW_CARD_RECORD)
        if recordData == nil then
            recordData = {}
        end
        local tempData = {}
        table.insert(tempData,clone(selfData.cards))
        local dealerSeat = self:dealerSeatData()
        table.insert(tempData,clone(dealerSeat.cards))
        table.insert(tempData,self.turn_money_)
        table.insert(tempData,self:isSelfDealer())
        table.insert(recordData,1,tempData)

        local finalResult = {}
        if #recordData > 10 then
            for i=1,10 do
                local temp = recordData[i]
                table.insert(finalResult,clone(temp))
            end
        else
            finalResult = recordData
        end

        bm.DataProxy:setData(nk.dataKeys.NEW_CARD_RECORD,finalResult)


        local selfCardData = {}
        table.insert(selfCardData,clone(selfData.cards))
        table.insert(selfCardData,self.turn_money_)

        bm.DataProxy:setData(nk.dataKeys.PRE_GAME_CARDS,selfCardData)
    end

    local dealer = self:dealerSeatData()
    if dealer and checkint(dealer.trunMoney) < 0 then 
        dealer.nCurAnte = - dealer.trunMoney
    end

    -- self.grabNeedCoin_ = dealer.anteMoney + 1
    -- if dealer.anteMoney < self.gameInfo.grabDoor then
    --     self.grabNeedCoin_ = self.gameInfo.grabDoor
    -- end

    for i = 0, 9 do
        local player = self.playerList[i]
        if player then
            player.isPlayBeforeGameOver = player.isPlay
            player.isPlay = 0            
            player.statemachine:doEvent(SeatStateMachine.GAME_OVER)

            if player.seatId == 9 and player.uid ~= 1 then
                self.haveDealer_ = 1 
                self.grabNeedCoin_ = player.anteMoney + 1
                if self.grabNeedCoin_ < self.grabNeedCoin_ then
                    self.grabNeedCoin_ = self.gameInfo.grabDoor
                end
            end
        end
    end
    self.isSelfInGame_ = false
    self.hasCardActive_ = false
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

            local HandPoker = HandPoker.new()
            HandPoker:setCards(nowCards)

            if HandPoker:compare(lastMaxCard) > 0 then
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
function RoomModel:processSvrAddvanceDealer(pack)
    self.dealerAddCoinNum_ = pack.addCoin
    return self.dealerAddCoinNum_
end
function RoomModel:processGrabAdvance(pack)
    self.grabNeedCoin_ = pack.handCoin + 1
    if pack.handCoin < self.gameInfo.grabDoor then
        self.grabNeedCoin_ = self.gameInfo.grabDoor
    end
end
function RoomModel:processDealerAddCoin(pack)
    self.grabNeedCoin_ = pack.dealerHandCoin + 1
    if pack.dealerHandCoin < self.gameInfo.grabDoor then
        self.grabNeedCoin_ = self.gameInfo.grabDoor
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
function RoomModel:reset()  
    self.isSelfInGame_ = false
    self.betMoeny_ = 0
    self.hasCardActive_ = false
end

return RoomModel