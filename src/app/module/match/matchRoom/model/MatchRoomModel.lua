--
-- Author: tony
-- Date: 2014-07-08 14:23:34
--

local SeatStateMachine = import(".MatchSeatStateMachine")
local HandPoker = import(".MatchHandPoker")
local logger = bm.Logger.new("MatchRoomModel")
local MatchRoomModel = {}

function MatchRoomModel.new()
    local instance = {}
    local datapool = {}
    local function getData(table, key)
        return MatchRoomModel[key] or datapool[key]
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

function MatchRoomModel:ctor()
    self.isInitialized = false
    self.isSelfInGame_ = false
    self.isSelfInMatch_ = false  
    self.selfSeatId_ = -1    
    self.roomType_ = 0
end

-- 是否是自己
function MatchRoomModel:isSelf(uid)
    return nk.userData.uid == uid
end

-- 是否正在游戏（游戏开始至游戏刷新，弃牌置为false）
function MatchRoomModel:isSelfInGame()
    return self.isSelfInGame_
end
--是否在比赛中(淘汰或比赛结束设置为false)
function MatchRoomModel:isSelfInMatch()
    return self.isSelfInMatch_
end

-- 是否被淘汰
function MatchRoomModel:isSelfKnockOut()
    return self.isSelfKnockOut_
end

--本人是否要过牌了
function MatchRoomModel:isSelfGetPoker( ... )
    return self.isSelfGetPoker_
end




-- 本人是否在座
function MatchRoomModel:isSelfInSeat()
    return self.selfSeatId_ >= 0 and self.selfSeatId_ <= 8
end

-- 本人是否为庄家
function MatchRoomModel:isSelfDealer()
    return self.selfSeatId_ == self.gameInfo.dealerSeatId
end




-- 获取自己的座位id
function MatchRoomModel:selfSeatId()
    return self.selfSeatId_
end

-- 获取自己
function MatchRoomModel:selfSeatData()
    return self.playerList[self.selfSeatId_]
end

-- 获取庄家
function MatchRoomModel:dealerSeatData()
    return self.playerList[self.gameInfo.dealerSeatId]
end

-- 获取当前房间类型
function MatchRoomModel:roomType()
    return self.roomType_
end

-- 获取当前在桌人数
function MatchRoomModel:getNumInSeat()
    local num = 0
    for i = 0, 8 do
        if self.playerList[i] then
            num = num + 1
        end
    end

    return num
end
-- 获取牌桌所有用户的UID 
function MatchRoomModel:getTableAllUid()
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

function MatchRoomModel:getSeatIdByUid(uid)
    for seatId = 0, 8 do
        local player = self.playerList[seatId]
        if player and player.uid == uid then
            return seatId
        end
    end
    return -1
end


-- 获取本轮参与玩家人数
function MatchRoomModel:getNumInRound()
    local num = 0
    for i = 0, 8 do
        if self.playerList[i] and self.playerList[i].isPlay == 1 then
            num = num + 1
        end
    end
    return num
end

function MatchRoomModel:getNewCardType(cardType, pointCount)
    return CardType.new(cardType, pointCount)
end


function MatchRoomModel:initWithLoginSuccessPack(pack)
    dump(pack,"MatchRoomModel:initWithLoginSuccessPack")
    self.clearData()
    self.isInitialized = true
    self.isSelfInGame_ = false
    self.isSelfGetPoker_ = false
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
    roomInfo.matchType  = pack.matchType
    roomInfo.matchId = pack.matchId
    roomInfo.gameType = consts.ROOM_TYPE.MATCH
   


    --房间level, 房间类型
    self.roomType_ = roomInfo.roomType


    --游戏信息
    local gameInfo = {}
    self.gameInfo = gameInfo

    gameInfo.blind = pack.baseAnte
    
    --桌子当前状态 0牌局已结束 1下注中 2等待用户获取第3张牌
    gameInfo.gameStatus = pack.tableStatus

    if (gameInfo.gameStatus ~= consts.SVR_MATCH_GAME_STATUS.READY_TO_START) and (gameInfo.gameStatus ~= consts.SVR_MATCH_GAME_STATUS.WAIT_GAME_OVER) and (gameInfo.gameStatus ~= consts.SVR_MATCH_GAME_STATUS.APPLY) then
        gameInfo.activeSeatId = pack.activeSeatId
    else
        gameInfo.activeSeatId = -1
    end
    gameInfo.dealerSeatId = -1
    gameInfo.userAnteTime = pack.userAnteTime
    gameInfo.extraCardTime = pack.extraCardTime
    gameInfo.totalAnte = pack.totalAnte
    gameInfo.speakerSeatId = (gameInfo.gameStatus == consts.SVR_MATCH_GAME_STATUS.APPLY) and 10 or pack.speakerSeatId 

    dump(gameInfo.speakerSeatId,"speakerSeatId")


    dump(gameInfo.userAnteTime,"gameInfo.userAnteTime")
    dump(gameInfo.extraCardTime,"gameInfo.extraCardTime")


    self.gameInfo.pots = pack.potList


    -- if gameInfo.activeSeatId ~= -1 then
    --     gameInfo.callChips = pack.callChips
    --     gameInfo.minRaiseChips = roomInfo.blind--pack.minRaiseChips
    --     gameInfo.maxRaiseChips = pack.maxRaiseChips
    -- else
    --     gameInfo.callChips = 0
    --     gameInfo.minRaiseChips = 0
    --     gameInfo.maxRaiseChips = 0
    -- end

    self.isSelfInGame_ = false  --是否在游戏中  

    --在玩玩家信息
    local playerList = {}
    self.playerList = playerList
    
    if #pack.playerList == 1 then
        pack.playerList[1].betState = consts.SVR_BET_STATE.WAITTING_BET
    end

    for i, player in ipairs(pack.playerList) do
        player.userInfo = json.decode(player.userInfo)
        if not player.userInfo then
           player.userInfo = nk.getUserInfo(true) 
        end
        playerList[player.seatId] = player
        
        player.isSelf = self:isSelf(player.uid)   
        player.betChips = player.curBet or 0  
        player.betNeedChips = pack.maxBetPoints - player.totalBet 
        player.callChips = player.betNeedChips
        player.seatChips = player.seatChips


        if gameStatus == consts.SVR_MATCH_GAME_STATUS.READY_TO_START then
            player.betState = consts.SVR_BET_STATE.WAITTING_START
        elseif gameStatus == consts.SVR_MATCH_GAME_STATUS.PRE_CALL then
            player.betState = consts.SVR_BET_STATE.PRE_CALL
        elseif gameStatus == consts.SVR_MATCH_GAME_STATUS.WAIT_GAME_OVER then
            -- player.betState = consts.SVR_BET_STATE.WAITTING_START
        elseif gameStatus == consts.SVR_MATCH_GAME_STATUS.APPLY then
            player.betState = consts.SVR_BET_STATE.WAITTING_START
        end


        dump(player.betState,"initLoginBetState")

        dump(player.isSelf,"player.isSelf")  
        if player.isSelf then
            self.selfSeatId_ = player.seatId
            self.isSelfInGame_ = (player.seatId ~= -1) 
            self.isSelfInMatch_ = (player.seatId ~= -1) 

            if pack.cards then
                local handPoker = HandPoker.new()
                player.cards = pack.cards
                handPoker:setCards(player.cards)
                player.handPoker = handPoker
                player.cardsCount = #player.cards
            else
                player.cardsCount = 0 
            end

            if gameInfo.gameStatus == consts.SVR_MATCH_GAME_STATUS.GET_POKER then
                if (gameInfo.activeSeatId >= 0 and gameInfo.activeSeatId <= 8) and (pack.speakerSeatId >= 0 and pack.speakerSeatId <= 8) then
                    if player.seatId ~= gameInfo.activeSeatId then
                        if(pack.speakerSeatId < gameInfo.activeSeatId) then
                            if(bm.rangeInDefined(player.seatId,pack.speakerSeatId,gameInfo.activeSeatId)) then
                                self.isSelfGetPoker_ = true
                            end

                        elseif (pack.speakerSeatId > gameInfo.activeSeatId) then
                            if(not bm.rangeInDefined(player.seatId,pack.activeSeatId,gameInfo.speakerSeatId)) then
                                self.isSelfGetPoker_ = true
                            end

                        end

                    end
                end
            end                     
        end  

        if player.cards then
            local handPoker = HandPoker.new()
            -- player.cards = pack.cards
            handPoker:setCards(player.cards)
            player.handPoker = handPoker
            player.cardsCount = #player.cards
        end

        if player.betState == consts.SVR_BET_STATE.FOLD then
            player.isOutCard = 0
        end





        --[[ 
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
        --]]  
        -- player.isDealer =  (player.seatId == self.gameInfo.dealerSeatId)
        player.isSpeaker = (player.seatId == self.gameInfo.speakerSeatId)
        player.statemachine = SeatStateMachine.new(player, player.seatId == gameInfo.activeSeatId, gameInfo.gameStatus)
    end   
end


function MatchRoomModel:processChangeMatchRoom(pack)
    dump(pack,"MatchRoomModel:processChangeMatchRoom")
    self.clearData()
    self.isInitialized = true
    self.isSelfInGame_ = false
    self.isSelfGetPoker_ = false
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
    -- roomInfo.minBuyIn = pack.minAnte
    -- roomInfo.maxBuyIn = pack.maxAnte
    --roomInfo.roomType = pack.tableLevel
    roomInfo.blind = pack.baseAnte
    roomInfo.playerNum = pack.maxSeatCnt
   -- roomInfo.defaultBuyIn = pack.defaultAnte
    roomInfo.tid     = pack.tableId
    roomInfo.matchType  = pack.matchType
    roomInfo.matchId = pack.matchId
    roomInfo.gameType = consts.ROOM_TYPE.MATCH
   


    --房间level, 房间类型
    self.roomType_ = roomInfo.roomType


    --游戏信息
    local gameInfo = {}
    self.gameInfo = gameInfo

    gameInfo.blind = pack.baseAnte
    
    --桌子当前状态 0牌局已结束 1下注中 2等待用户获取第3张牌
    gameInfo.gameStatus = pack.tableStatus

    -- if (gameInfo.gameStatus ~= consts.SVR_MATCH_GAME_STATUS.READY_TO_START) and (gameInfo.gameStatus ~= consts.SVR_MATCH_GAME_STATUS.WAIT_GAME_OVER) and (gameInfo.gameStatus ~= consts.SVR_MATCH_GAME_STATUS.APPLY) then
    --     gameInfo.activeSeatId = pack.activeSeatId
    -- else
    --     gameInfo.activeSeatId = -1
    -- end
    gameInfo.activeSeatId = -1
    gameInfo.dealerSeatId = -1
    gameInfo.userAnteTime = pack.userAnteTime
    gameInfo.extraCardTime = pack.extraCardTime
    gameInfo.totalAnte =0--pack.totalAnte
    gameInfo.speakerSeatId = (gameInfo.gameStatus == consts.SVR_MATCH_GAME_STATUS.APPLY) and 10 or pack.speakerSeatId 

    dump(gameInfo.speakerSeatId,"speakerSeatId")


    dump(gameInfo.userAnteTime,"gameInfo.userAnteTime")
    dump(gameInfo.extraCardTime,"gameInfo.extraCardTime")


    self.gameInfo.pots = {}--pack.potList


    -- if gameInfo.activeSeatId ~= -1 then
    --     gameInfo.callChips = pack.callChips
    --     gameInfo.minRaiseChips = roomInfo.blind--pack.minRaiseChips
    --     gameInfo.maxRaiseChips = pack.maxRaiseChips
    -- else
    --     gameInfo.callChips = 0
    --     gameInfo.minRaiseChips = 0
    --     gameInfo.maxRaiseChips = 0
    -- end

    self.isSelfInGame_ = false  --是否在游戏中  

    --在玩玩家信息
    local playerList = {}
    self.playerList = playerList
    
    if #pack.playerList == 1 then
        pack.playerList[1].betState = consts.SVR_BET_STATE.WAITTING_BET
    end

    for i, player in ipairs(pack.playerList) do
        player.userInfo = json.decode(player.userInfo)
        if not player.userInfo then
           player.userInfo = nk.getUserInfo(true) 
        end
        playerList[player.seatId] = player
        
        player.curBet = 0
        player.totalBet = 0
        player.isSelf = self:isSelf(player.uid)   
        player.betChips = player.curBet or 0  
        player.betNeedChips = 0--pack.maxBetPoints - 0 --player.totalBet 
        player.callChips = player.betNeedChips
        player.seatChips = player.seatChips


        if gameStatus == consts.SVR_MATCH_GAME_STATUS.READY_TO_START then
            player.betState = consts.SVR_BET_STATE.WAITTING_START
        elseif gameStatus == consts.SVR_MATCH_GAME_STATUS.PRE_CALL then
            player.betState = consts.SVR_BET_STATE.PRE_CALL
        elseif gameStatus == consts.SVR_MATCH_GAME_STATUS.WAIT_GAME_OVER then
            -- player.betState = consts.SVR_BET_STATE.WAITTING_START
        elseif gameStatus == consts.SVR_MATCH_GAME_STATUS.APPLY then
            player.betState = consts.SVR_BET_STATE.WAITTING_START
        end


        dump(player.betState,"initLoginBetState")

        dump(player.isSelf,"player.isSelf")  
        if player.isSelf then
            self.selfSeatId_ = player.seatId
            self.isSelfInGame_ = (player.seatId ~= -1) 
            self.isSelfInMatch_ = (player.seatId ~= -1) 

            if pack.cards then
                local handPoker = HandPoker.new()
                player.cards = pack.cards
                handPoker:setCards(player.cards)
                player.handPoker = handPoker
                player.cardsCount = #player.cards
            else
                player.cardsCount = 0 
            end

            if gameInfo.gameStatus == consts.SVR_MATCH_GAME_STATUS.GET_POKER then
                if (gameInfo.activeSeatId >= 0 and gameInfo.activeSeatId <= 8) and (pack.speakerSeatId >= 0 and pack.speakerSeatId <= 8) then
                    if player.seatId ~= gameInfo.activeSeatId then
                        if(pack.speakerSeatId < gameInfo.activeSeatId) then
                            if(bm.rangeInDefined(player.seatId,pack.speakerSeatId,gameInfo.activeSeatId)) then
                                self.isSelfGetPoker_ = true
                            end

                        elseif (pack.speakerSeatId > gameInfo.activeSeatId) then
                            if(not bm.rangeInDefined(player.seatId,pack.activeSeatId,gameInfo.speakerSeatId)) then
                                self.isSelfGetPoker_ = true
                            end

                        end

                    end
                end
            end                     
        end  

        if player.cards then
            local handPoker = HandPoker.new()
            -- player.cards = pack.cards
            handPoker:setCards(player.cards)
            player.handPoker = handPoker
            player.cardsCount = #player.cards
        end

        if player.betState == consts.SVR_BET_STATE.FOLD then
            player.isOutCard = 0
        end





        --[[ 
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
        --]]  
        -- player.isDealer =  (player.seatId == self.gameInfo.dealerSeatId)
        player.isSpeaker = (player.seatId == self.gameInfo.speakerSeatId)
        player.statemachine = SeatStateMachine.new(player, player.seatId == gameInfo.activeSeatId, gameInfo.gameStatus)
    end   
end

function MatchRoomModel:processGameStart(pack)
    -- 设置gameInfo
    self.gameInfo.gameStatus = consts.SVR_MATCH_GAME_STATUS.PRE_CALL
    self.gameInfo.dealerSeatId = -1
    self.gameInfo.callChips = 0
    self.gameInfo.blind = pack.baseAnte
    self.gameInfo.pots = {}
    self.gameInfo.hasRaise = false
    self.gameInfo.bettingSeatId = -1
    self.gameInfo.speakerSeatId = pack.speakerSeatId

    dump(pack.baseAnte,"processGameStart:baseAnte")
    dump(self.gameInfo.blind,"processGameStart:blind")
    


    for i = 0, 8 do
        local player = self.playerList[i]
        if player then
            player.isPlay = 1
            -- player.isDealer =  ( i ==  self.gameInfo.dealerSeatId )        
            -- if player.isDealer then                
            --     player.statemachine:doEvent(SeatStateMachine.SET_DEALER)
            -- end

            player.isSpeaker = (i == self.gameInfo.speakerSeatId)
            if player.isSpeaker then

            end

            player.inGame = true
            player.inRound = true
            player.statemachine:doEvent(SeatStateMachine.GAME_START)

            if player.isSelf then
                self.isSelfInGame_ = true
                self.isSelfInMatch_ = true
                self.isSelfInRound_ = true
                self.isSelfGetPoker_ = false
                -- player.handCards = self.gameInfo.handCards
                -- player.cardType = self.gameInfo.cardType
            else
                -- player.handCards = {0, 0, 0}
                -- player.cardType = nil
            end


            player.betChips = 0 -- 已下注总额
            -- player.seatChips = player.seatChips

            player.isOutCard = 0
            player.nCurAnte = 0
            player.cards = nil
            player.cardsCount = 0
            player.handPoker = nil
            player.trunMoney = 0
            player.getExp = 0
            player.isPlayBeforeGameOver = 0
            -- if player.isSelf then
            --     self.isSelfInGame_ = true  
            -- end
        end
    end



    do return end
    self.gameInfo.dealerSeatId = pack.dealerSeatId
    for i = 0, 8 do
        local player = self.playerList[i]
        if player then
            player.isPlay = 1
            -- player.isDealer =  ( i ==  self.gameInfo.dealerSeatId )        
            player.statemachine:doEvent(SeatStateMachine.GAME_START)
            -- if player.isDealer then                
            --     player.statemachine:doEvent(SeatStateMachine.SET_DEALER)
            -- end
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

    -- for _,row in ipairs(pack.anteMoneyList) do
    --     local player = self.playerList[row.seatId]
    --     player.anteMoney = row.anteMoney
    --     if player.isSelf then
    --         nk.userData['aUser.anteMoney'] = player.anteMoney
    --     end
    -- end    
end

function MatchRoomModel:isChangeDealer()
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




function MatchRoomModel:isChangeSpeaker()
    if self.gameInfo == nil or self.gameInfo.speakerSeatId == nil then
        return true
    end
    local oldSpeaker = self.gameInfo.speakerSeatId
    local maxMoney = 0
    local speakerSeatId = 0
    for i=0,8 do
        local player = self.playerList[i]
        if player then
            -- if player.anteMoney > maxMoney then
            --     dealerSeatId = player.seatId
            --     maxMoney = player.anteMoney
            -- end
        end
    end    
    return oldDealer ~= dealerSeatId
end

function MatchRoomModel:processBetSuccess(pack)
     -- {name = "seatId", type = T.INT},
     --    {name = "betType",type = T.INT},-- (1看牌 2跟注 3加注 4弃牌, 加注)
     --    {name = "betPoint", type = T.INT},--下注额
     --    {name = "leftPoints",type = T.INT},--剩余积分
     --    {name = "totalBet",type = T.INT},--该玩家总下注额
     --    {name = "maxBetPoints",type = T.INT} --桌上
     -- dump(player,"processBetSuccess")

    local betState = pack.betState 
    local seatId = pack.seatId
    local player = self.playerList[pack.seatId]
    player.betState = pack.betState
    player.betNeedChips = pack.betPoint -- 当前实际下注
    player.betChips = player.betChips + pack.betPoint -- 总下注
    -- player.seatChips = player.seatChips - player.betNeedChips
    player.seatChips = pack.seatChips


    dump(seatId,"processBetSuccess:seatId")


    -- 前注
    if betState == consts.SVR_BET_STATE.PRE_CALL or betState == consts.SVR_BET_STATE.RAISE then
        if pack.seatChips <= 0 then
           betState = consts.SVR_BET_STATE.ALL_IN
        end
    end
        -- 下完前注自己没钱了，算自己all in
        -- if player.isSelf and player.betChips == 0 then
        --     self.isSelfAllIn_ = true
        --     player.statemachine:doEvent(SeatStateMachine.ALL_IN, player.betNeedChips)
        -- end
    -- 看牌
    if betState == consts.SVR_BET_STATE.CHECK then
        player.statemachine:doEvent(SeatStateMachine.CHECK)
    -- 弃牌
    elseif betState == consts.SVR_BET_STATE.FOLD then
        player.inGame = false
        player.isPlay = 0

        -- 自己弃牌
        if player.isSelf then
            self.isSelfInGame_ = false
        end
        player.statemachine:doEvent(SeatStateMachine.FOLD)
    -- 跟注
    elseif betState == consts.SVR_BET_STATE.CALL then
        if player.isSelf then
            self.gameInfo.hasRaise = false
        end
        player.statemachine:doEvent(SeatStateMachine.CALL, player.betNeedChips)
    -- 加注
    elseif betState == consts.SVR_BET_STATE.RAISE then
        if player.isSelf then
            self.gameInfo.hasRaise = false
        else
            self.gameInfo.hasRaise = true
        end
        player.statemachine:doEvent(SeatStateMachine.RAISE, player.betNeedChips)
    -- all in
    elseif betState == consts.SVR_BET_STATE.ALL_IN then
        -- 自己all in，需播放加注的声音
        if player.isSelf then
            self.isSelfAllIn_ = true
            self.gameInfo.hasRaise = false
        else
            if self:selfSeatData() and player.betChips > self:selfSeatData().betChips then
                self.gameInfo.hasRaise = true
            end
        end
        player.statemachine:doEvent(SeatStateMachine.ALL_IN, player.betNeedChips)
    end


    -- local player = self.playerList[pack.seatId]  
    -- if player.seatChips == 0 then
    --     player.statemachine:doEvent(SeatStateMachine.ALL_IN, player.seatChips)
    -- else
    --     player.statemachine:doEvent(SeatStateMachine.CALL)
    -- end
    -- if player.anteMoney < 0 then
    --     printError("anteMoney is "..player.anteMoney)
    -- end
    return pack.seatId
end



function MatchRoomModel:processPreCallSuccess(pack)


    local preCallArr = pack.preCallArr

    if preCallArr then
        for _,v in pairs(preCallArr) do
            local player = self.playerList[v.seatId]  
            player.nCurAnte = v.nCurAnte -- 需要下注的
            player.seatChips = v.seatChips
            player.betNeedChips = v.nCurAnte - player.betChips -- 当前实际下注
            player.betChips = v.nCurAnte -- 总下注
            player.betState = consts.SVR_BET_STATE.PRE_CALL
            player.statemachine:doEvent(SeatStateMachine.TURN_TO)

            if player.seatChips == 0 then
                --如果all in 直接显示 all in 
                player.statemachine:doEvent(SeatStateMachine.ALL_IN, player.seatChips)
            else
                --如果非all in  显示名字
                player.statemachine:doEvent(SeatStateMachine.PRE_CALL)
                -- player.statemachine:doEvent(SeatStateMachine.CALL)
            end

            if (not self.gameInfo.callChips) or (self.gameInfo.callChips ~= v.nCurAnte) then
                self.gameInfo.callChips = v.nCurAnte
            end

            if player.seatChips < 0 then
                printError("antPoints is "..player.seatChips)
            end
        end
    end
    return preCallArr
end


function MatchRoomModel:processTurnToBet(pack)
    local seatId = pack.seatId
    local player = self.playerList[pack.seatId]

    -- local betState = pack.betState 
    -- local seatId = pack.seatId
    -- local player = self.playerList[pack.seatId]
    -- player.betState = pack.betState
    player.betNeedChips = pack.callChips -- 当前实际下注
    -- player.betChips = player.betChips + pack.betPoint -- 总下注
    -- player.seatChips = player.seatChips - player.betNeedChips
    -- player.seatChips = pack.leftPoints
    self.gameInfo.gameStatus = pack.tableStatus



    self.gameInfo.bettingSeatId = pack.seatId

    self.gameInfo.callChips = pack.callChips

    if self:isSelfInSeat() and self:isSelfInGame() then
        local selfPlayer = self.playerList[self.selfSeatId_]

        --如果需要下注的值大于剩余的值，跟注只能all in
        if pack.callChips > selfPlayer.seatChips then
            self.gameInfo.callChips = selfPlayer.seatChips
        end

        if pack.callChips < selfPlayer.seatChips then
             if pack.callChips + self.gameInfo.blind < selfPlayer.seatChips then
                self.gameInfo.minRaiseChips = pack.callChips + self.gameInfo.blind
            else
                self.gameInfo.minRaiseChips = pack.callChips
            end
            -- self.gameInfo.maxRaiseChips = selfPlayer.seatChips
        else
            self.gameInfo.minRaiseChips = selfPlayer.seatChips
            -- self.gameInfo.maxRaiseChips = selfPlayer.seatChips
        end

        self.gameInfo.maxRaiseChips = selfPlayer.seatChips

        dump(pack.callChips,"callChips")
        dump(self.gameInfo.minRaiseChips,"minRaiseChips")
        dump(self.gameInfo.maxRaiseChips,"maxRaiseChips")
        dump(self.roomInfo.blind ,"blind")
        dump(selfPlayer.seatChips,"seatChips")

    end

    dump(seatId,"processTurnToBet:seatId")
    player.statemachine:doEvent(SeatStateMachine.TURN_TO)

    return seatId
end

function MatchRoomModel:processPot(pack)
    -- self.gameInfo.totalAnte = pack.totalAnte  
    self.gameInfo.pots = pack.potList
    self.gameInfo.hasRaise = false
    for i = 0, 8 do
        local player = self.playerList[i]
        if player then
            if player.isSelf and self.isSelfInGame_ then
    --             self.selfTotalBet_ = self.selfTotalBet_ + player.betChips
            end
            player.betChips = 0
        end
    end

end

--发牌
function MatchRoomModel:processDeal(pack)
    self.gameInfo.gameStatus = consts.SVR_MATCH_GAME_STATUS.BET_ROUND_1

    local player = self:selfSeatData()
    player.cards = pack.cards
    player.cardsCount = #pack.cards
    local handPoker = HandPoker.new()
    handPoker:setCards(player.cards)
    player.handPoker = handPoker
    player.isOutCard = 0
end

--广播用户发前两张牌
function MatchRoomModel:processMatchCardNum(pack)
    dump(pack,"processMatchCardNum")
    do return end
    local cardlist = pack.cardlist
    if cardlist then
        for _,v in pairs(cardlist) do
            local player = self.playerList[v.seatId]
            local cards = {0,v.card}
            player.cards = cards
            player.cardsCount = #cards
            -- local handPoker = HandPoker.new()
            -- handPoker:setCards(player.cards)
            -- player.handPoker = handPoker
            player.isOutCard = 0
        end
    end
   
end

--亮牌
function MatchRoomModel:processShowHand(pack)
    
    -- player.cards = pack.cards
    -- player.isOutCard = 1
    -- player.cardsCount = #pack.cards
    -- local handPoker = HandPoker.new()
    -- handPoker:setCards(player.cards)
    -- player.handPoker = handPoker

    self.gameInfo.gameStatus = consts.SVR_MATCH_GAME_STATUS.READY_TO_START

    local playerList = pack.playerList
    local player = self.playerList[pack.seatId] 
    if playerList then
        for _,v in pairs(playerList) do
            player = self.playerList[v.seatId] 
            if player then
                player.isPlay = 0
                player.inGame = false
                player.inRound = false
                player.cards = v.cards
                player.seatChips = v.seatChips
                player.turnPoints = v.turnPoints --该局输赢的钱
                player.cardsCount = #player.cards
                if player.cardsCount <= 0 then
                    player.isOutCard = 0
                else
                    player.isOutCard = 1
                end
                local handPoker = HandPoker.new()
                handPoker:setCards(player.cards)
                player.handPoker = handPoker
                player.statemachine:doEvent(SeatStateMachine.GAME_OVER)
            end
        end
    end


    self.gameInfo.splitPots = {}
    local isSelfWin = false
    for i, v in ipairs(pack.potsList) do
        local pot = {}
        self.gameInfo.splitPots[#self.gameInfo.splitPots + 1] = pot
        pot.potIdx = v.potIdx
        pot.points = v.points

        local playerList = {}
        pot.playerList = playerList
        for i,vv in ipairs(v.playerList) do
            local player = {}
            pot.playerList[#pot.playerList + 1] = player
            player.uid = vv.uid
            player.seatId = vv.seatId
            player.winPoints = vv.winPoints
        end

        --[[
        pot.cardType = CardType.new(v.cardType, v.cardPoint)
        pot.handCards = {v.handCard1, v.handCard2, v.handCard3}
        if i == 1 then
            --第一个奖池扣取台费
            pot.fee = pack.fee
            pot.isReallyWin = true
        elseif i == #pack.potsList then
            if not pack.lastPotIsNotWinChips or pack.lastPotIsNotWinChips == -1 then
                pot.isReallyWin = true
            else
                pot.isReallyWin = false
            end
        end
        local player = self.playerList[v.seatId]
        if player then
            if not player.handCards then
                player.handCards = {0, 0, 0}
            end
            player.handCards[1] = v.handCard1 ~= 0 and v.handCard1 or player.handCards[1]
            player.handCards[2] = v.handCard2 ~= 0 and v.handCard2 or player.handCards[2]
            player.handCards[3] = v.handCard3 ~= 0 and v.handCard3 or player.handCards[3]
            if not player.cardType or not player.cardType:getLabel() then
                player.cardType = pot.cardType
            end
        end

        if v.seatId == self.selfSeatId_ then
            isSelfWin = true
        end
        --]]
    end






   
    
end

function MatchRoomModel:processTurnToGetPoker(pack)
    self.gameInfo.gameStatus = consts.SVR_MATCH_GAME_STATUS.GET_POKER
    local player = self.playerList[pack.seatId] 

    -- dump(pack.seatId,"getpoker:seatId11")
    -- dump(player.seatId,"getpoker:seatId22") 

    self.gameInfo.bettingSeatId = pack.seatId

    player.statemachine:doEvent(SeatStateMachine.GETING)
    return pack.seatId
end

function MatchRoomModel:processGetPoker(pack)
    local player = self.playerList[pack.seatId] 
    player.statemachine:doEvent(SeatStateMachine.WAIT_GET,pack.type)
    if pack.type == 1 then
        player.cardsCount = 3
    else
        player.cardsCount = 2
    end

    if player.isSelf then
        self.isSelfGetPoker_ = true
    end
    return pack.seatId
end

function MatchRoomModel:processGetPokerBySelf(pack)
    -- dump(pack,"processGetPokerBySelf111")
   
    -- self.gameInfo.gameStatus = consts.SVR_MATCH_GAME_STATUS.BET_ROUND_2
    local player = self:selfSeatData()  
    -- dump(player,"processGetPokerBySelf222")    
    player.cardsCount = 3
    player.handPoker:addCard(pack.card)
    player.cards[3] = pack.card
    player.isOutCard = 0
end

function MatchRoomModel:processSitDown(pack)
    local player = pack
    local prePlayer = self.playerList[player.seatId]
    -- local isAutoBuyin = false
    -- if prePlayer then
    --     if prePlayer.uid == player.uid then
    --         isAutoBuyin = true
    --     end
    -- end

    player.userInfo = json.decode(player.userInfo)
    if not player.userInfo then
       player.userInfo = nk.getUserInfo(true) 
    end

    -- player.isPlay = 0
    -- player.isDealer = (player.seatId == self.gameInfo.dealerSeatId)   
    player.statemachine = SeatStateMachine.new(player, false, self.gameInfo.gameStatus)
    self.playerList[player.seatId] = player
    player.isSelf = self:isSelf(player.uid)
    -- 判断是否是自己
    if player.isSelf then
        self.selfSeatId_ = player.seatId
        --nk.userData['aUser.money'] = pack.money - pack.anteMoney
        -- nk.userData['aUser.money'] = pack.money
        -- nk.userData['aUser.anteMoney'] = pack.anteMoney
        nk.userData['aUser.antPoints'] = pack.antPoints
        player.userInfo.mavatar = nk.userData['aUser.micon']
        player.userInfo.giftId = nk.userData['aUser.gift']
        bm.DataProxy:setData(nk.dataKeys.SIT_OR_STAND, {inSeat = self:isSelfInSeat(),seatId = player.seatId,ctx = self.ctx})
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

function MatchRoomModel:processStandUp(pack)
    local player = self.playerList[pack.seatId]
    if player and player.isSelf then              
        self.isSelfInGame_ = false
        self.selfSeatId_ = -1
        bm.DataProxy:setData(nk.dataKeys.SIT_OR_STAND, {inSeat = self:isSelfInSeat(),seatId = player.seatId,ctx = self.ctx})
        
        -- 设置金钱
        nk.userData["aUser.money"] = pack.money
    end
    player = nil
    self.playerList[pack.seatId] = nil
    return pack.seatId
end


function MatchRoomModel:processKnockOut(pack)

    --广播用户淘汰
    local player = self.playerList[pack.seatId]
    if player and player.isSelf then              
        self.isSelfInGame_ = false
        self.isSelfInMatch_ = false
        self.selfSeatId_ = -1
        self.isSelfKnockOut_ = true
        self.isSelfGetPoker_ = false
    end
    player = nil
    self.playerList[pack.seatId] = nil
    return pack.seatId,pack.rank

end


function MatchRoomModel:processBroadQuit(pack)
    dump(pack,"processBroadQuit")
    local seatId = pack.seatId
    self.playerList[pack.seatId] = nil
    return seatId
end

function MatchRoomModel:processQuitResult(pack)
    dump(pack,"processQuitResult")
end

function MatchRoomModel:processMatchGameOver(pack)
    self.isSelfInMatch_ = false

    self.gameInfo.matchRanklist = pack.ranklist

    return self.gameInfo.matchRanklist

end



function MatchRoomModel:processCardRecord(pack)
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



function MatchRoomModel:processMaxWinMoney(winMoney)
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
function MatchRoomModel:processBestCard(nowCards)

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


function MatchRoomModel:processSendChipSuccess(pack)
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

function MatchRoomModel:processSendExpression(pack)
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


function MatchRoomModel:processCountDown(pack)
    self.gameInfo.countDown = pack.countDown or 0
    dump(self.gameInfo.countDown,"processCountDown")
end

function MatchRoomModel:processRoomBroadcast(pack)
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


function MatchRoomModel:selfCallNeedChips()
    local seatData = self:selfSeatData()
    if seatData  then
        return seatData.betNeedChips
    end
    return 0
end


--当前桌子上的总筹码（奖池+座位已下注筹码)
function MatchRoomModel:totalChipsInTable()

    local total = 0
    local pots = self.gameInfo.pots
    if pots then
        for _,v in pairs(pots) do
            total = total + v.potChips
        end
    end
    for i = 0, 8 do
        local player = self.playerList[i]
        if player and player.betChips then
            total = total + tonumber(player.betChips)
        end
    end
    return total
end

function MatchRoomModel:currentMaxBetChips()
    local max = 0
    for i = 0, 8 do
        local player = self.playerList[i]
        if player and player.isPlay == 1 and player.betChips and player.betChips > max then
            max = player.betChips
        end
    end
    return max
end





function MatchRoomModel:reset()  
    self.isSelfInGame_ = false
end

return MatchRoomModel