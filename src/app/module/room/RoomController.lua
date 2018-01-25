--
-- 房间控制器
-- Author: tony
-- Date: 2014-07-08 11:43:07
--

local RoomModel = import(".model.RoomModel")
local SeatManager = import(".SeatManager")
local DealerManager = import(".DealerManager")
local DealCardManager = import(".DealCardManager")
local LampManager = import(".LampManager")
local ChipManager = import(".ChipManager")
local AnimManager = import(".AnimManager")
local OperationManager = import(".OperationManager")
local BetChipView = import(".views.BetChipView")
local UserCrash = import("app.module.room.userCrash.UserCrash")
local StorePopup = import("app.module.newstore.StorePopup")
local UpgradePopup = import("app.module.upgrade.UpgradePopup")
local PayGuide = import("app.module.room.purchGuide.PayGuide")
local AnimationDownNum = import("app.module.common.views.AnimationDownNum")

local RoomController = class("RoomController")
local logger = bm.Logger.new("RoomController")

RoomController.EVT_PACKET_RECEIVED = nk.server.EVT_PACKET_RECEIVED

local PACKET_PROC_FRAME_INTERVAL = 2

function RoomController:ctor(scene)
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()

    local ctx = {}
    ctx.roomController = self
    ctx.scene = scene
    ctx.model = RoomModel.new(ctx)
    ctx.controllerEventProxy = cc.EventProxy.new(self, scene)
    ctx.schedulerPool = bm.SchedulerPool.new()
    ctx.sceneSchedulerPool = bm.SchedulerPool.new()
    ctx.gameSchedulerPool = bm.SchedulerPool.new()

    ctx.seatManager = SeatManager.new()
    ctx.dealerManager = DealerManager.new()
    ctx.dealCardManager = DealCardManager.new()
    ctx.lampManager = LampManager.new()
    ctx.chipManager = ChipManager.new()
    ctx.animManager = AnimManager.new()
    ctx.oprManager = OperationManager.new()

    ctx.export = function(target)
        if target ~= ctx.model then
            target.ctx = ctx
            for k, v in pairs(ctx) do
                if k ~= "export" and v ~= target then
                    target[k] = v
                end
            end
        else
            rawset(target, "ctx", ctx)
            for k, v in pairs(ctx) do
                if k ~= "export" and v ~= target then
                    rawset(target, k, v)
                end
            end
        end
        return target
    end

    ctx.export(self)
    ctx.export(ctx.seatManager)
    ctx.export(ctx.dealerManager)
    ctx.export(ctx.dealCardManager)
    ctx.export(ctx.lampManager)
    ctx.export(ctx.chipManager)
    ctx.export(ctx.animManager)
    ctx.export(ctx.oprManager)
    ctx.export(ctx.model)

    cc.EventProxy.new(nk.server, scene)
        :addEventListener(nk.server.EVT_PACKET_RECEIVED, handler(self, self.onPacketReceived_))
        :addEventListener(nk.server.EVT_CONNECTED, handler(self, self.onConnected_))

    local P = nk.server.PROTOCOL
    self.func_ = {
        [P.SVR_DOUBLE_LOGIN] = handler(self, RoomController.SVR_DOUBLE_LOGIN),
        [P.SVR_LOGIN_OK] = handler(self, RoomController.SVR_LOGIN_OK),
        [P.SVR_LOGIN_ROOM_OK] = handler(self, RoomController.SVR_LOGIN_ROOM_OK),
        [P.SVR_LOGIN_ROOM_FAIL] = handler(self, RoomController.SVR_LOGIN_ROOM_FAIL),
        [P.SVR_LOGOUT_ROOM_OK] = handler(self, RoomController.SVR_LOGOUT_ROOM_OK),
        [P.SVR_SEAT_DOWN] = handler(self, RoomController.SVR_SEAT_DOWN),
        [P.SVR_STAND_UP] = handler(self, RoomController.SVR_STAND_UP), 
        [P.SVR_OTHER_CARD] = handler(self, RoomController.SVR_OTHER_CARD), 
        [P.SVR_SET_BET] = handler(self, RoomController.SVR_SET_BET), 
        [P.SVR_MSG] = handler(self, RoomController.SVR_MSG),
        [P.SVR_DEAL] = handler(self, RoomController.SVR_DEAL),
        [P.SVR_LOGIN_ROOM] = handler(self, RoomController.SVR_LOGIN_ROOM),
        [P.SVR_LOGOUT_ROOM] = handler(self, RoomController.SVR_LOGOUT_ROOM),
        [P.SVR_SELF_SEAT_DOWN_OK] = handler(self, RoomController.SVR_SELF_SEAT_DOWN_OK), 
        [P.SVR_OTHER_STAND_UP] = handler(self, RoomController.SVR_OTHER_STAND_UP),
        [P.SVR_OTHER_OFFLINE] = handler(self, RoomController.SVR_OTHER_OFFLINE),
        [P.SVR_GAME_START] = handler(self, RoomController.SVR_GAME_START),
        [P.SVR_GAME_OVER] = handler(self, RoomController.SVR_GAME_OVER),
        [P.SVR_BET] = handler(self, RoomController.SVR_BET),
        [P.SVR_CAN_OTHER_CARD] = handler(self, RoomController.SVR_CAN_OTHER_CARD),
        [P.SVR_OTHER_OTHER_CARD] = handler(self, RoomController.SVR_OTHER_OTHER_CARD),
        [P.SVR_SHOW_CARD] = handler(self, RoomController.SVR_SHOW_CARD),
        [P.SVR_CARD_NUM] = handler(self, RoomController.SVR_CARD_NUM),
        [P.SVR_ROOM_BROADCAST] = handler(self,RoomController.SVR_ROOM_BROADCAST),
        [P.SVR_SEARCH_PERSONAL_ROOM] = handler(self,RoomController.SVR_SEARCH_PERSONAL_ROOM),
        [P.SVR_COMMON_BROADCAST] = handler(self,RoomController.SVR_COMMON_BROADCAST),

        [P.SVR_SUONA_BROADCAST] = handler(self, RoomController.SVR_SUONA_BROADCAST_RECV),  -- 房间内小喇叭广播
        [P.SVR_PUSH_MATCH_ROOM] = handler(self, RoomController.SVR_PUSH_MATCH_ROOM)
    }

    self.loginRoomFailListenerId_ = bm.EventCenter:addEventListener(nk.eventNames.LOGIN_ROOM_FAIL, handler(self, self.onLoginRoomFail_))
    self.roomConnProblemListenerId_ = bm.EventCenter:addEventListener(nk.eventNames.ROOM_CONN_PROBLEM, handler(self, self.onLoginRoomFail_))
    self.serverStopListenerId_ = bm.EventCenter:addEventListener(nk.eventNames.SERVER_STOPPED, handler(self, self.onServerStop_))
    self.serverFailListenerId_ = bm.EventCenter:addEventListener(nk.eventNames.SVR_ERROR, handler(self, self.onServerFail_))
    self.packetCache_ = {}
    self.frameNo_ = 1

    ctx.sceneSchedulerPool:loopCall(handler(self, self.onEnterFrame_), 1 / 30)
    ctx.sceneSchedulerPool:loopCall(function()
        cc.Director:getInstance():getTextureCache():removeUnusedTextures()
        return not self.isDisposed_
    end, 60)
end

function RoomController:dispose()
    self.isDisposed_ = true
    self.seatManager:dispose()
    self.dealerManager:dispose()
    self.dealCardManager:dispose()
    self.lampManager:dispose()
    self.chipManager:dispose()
    self.animManager:dispose()
    self.oprManager:dispose()

    self.schedulerPool:clearAll()
    self.sceneSchedulerPool:clearAll()
    self.gameSchedulerPool:clearAll()

    self:unbindDataObservers_()

    bm.EventCenter:removeEventListener(self.loginRoomFailListenerId_)
    bm.EventCenter:removeEventListener(self.roomConnProblemListenerId_)
    bm.EventCenter:removeEventListener(self.serverStopListenerId_)

    bm.DataProxy:setData(nk.dataKeys.ROOM_INFO, nil)
end

function RoomController:createNodes()
    self.seatManager:createNodes()
    self.dealerManager:createNodes()
    self.dealCardManager:createNodes()
    self.lampManager:createNodes()
    self.chipManager:createNodes()
    self.animManager:createNodes()
    self.oprManager:createNodes()

    self.oprManager:hideOperationButtons(false)

    nk.server:resume()

    self:bindDataObservers_()
end

function RoomController:onLoginRoomFail_(evt)
    if self.roomLoading_ then
        self.roomLoading_:removeFromParent()
        self.roomLoading_ = nil
    end
    if not evt or not evt.silent then
        nk.ui.Dialog.new({
            hasCloseButton = false,
            messageText = bm.LangUtil.getText("ROOM", "NET_WORK_PROBLEM_DIALOG_MSG"), 
            callback = function (type)
                if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                    self.roomLoading_ = nk.ui.RoomLoading.new(bm.LangUtil.getText("ROOM", "RECONNECT_MSG"))
                        :pos(display.cx, display.cy)
                        :addTo(self.scene, 100)                   
                    nk.server:quickPlay()
                elseif type == nk.ui.Dialog.FIRST_BTN_CLICK or type == nk.ui.Dialog.CLOSE_BTN_CLICK then
                    display.addSpriteFrames("hall_texture.plist", "hall_texture.png", handler(self.scene, self.scene.onLoadedHallTexture_))
                    self.roomLoading_ = nk.ui.RoomLoading.new(bm.LangUtil.getText("ROOM", "OUT_MSG"))
                        :pos(display.cx, display.cy)
                        :addTo(self.scene, 100)
                end
            end
        }):show()
    end
end

function RoomController:onServerFail_(evt)    
    --连接失败
    if evt.data == consts.SVR_ERROR.ERROR_CONNECT_FAILURE then       
        self:showErrorByDialog_(bm.LangUtil.getText("COMMON", "ERROR_CONNECT_FAILURE"))
    --心跳包超时
    elseif evt.data == consts.SVR_ERROR.ERROR_HEART_TIME_OUT then       
        self:showErrorByDialog_(bm.LangUtil.getText("COMMON", "ERROR_HEART_TIME_OUT"))
    --登录超时
    elseif evt.data == consts.SVR_ERROR.ERROR_LOGIN_TIME_OUT then       
        self:showErrorByDialog_(bm.LangUtil.getText("COMMON", "ERROR_LOGIN_TIME_OUT"))   
    end
end

function RoomController:showErrorByDialog_(msg)
    if self.errorDlg_ then
        return
    end

    msg = bm.LangUtil.getText("COMMON","ERROR_NETWORK_FAILURE") or msg
    self.errorDlg_ = nk.ui.Dialog.new({
        messageText = msg, 
        secondBtnText = bm.LangUtil.getText("COMMON", "RETRY_PLEASE"), 
        titleText = bm.LangUtil.getText("COMMON", "ERROR_NOTICE"),
        closeWhenTouchModel = false,
        hasFirstButton = false,
        hasCloseButton = false,
        callback = function (type)
            if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                local ip,port = string.match(nk.userData.hallip[1], "([%d%.]+):(%d+)")   
                
                if nk and nk.CommonTipManager then
                    nk.CommonTipManager:playReconnectingAnim(true,bm.LangUtil.getText("COMMON","ERROR_NETWORK_RECONNECT","\n"))
                end
                nk.server:connect(ip, port, false) 
            end
            self.errorDlg_ = nil
        end,
    }):show()
end



function RoomController:onServerStop_(evt)
    if self.roomLoading_ then
        self.roomLoading_:removeFromParent()
        self.roomLoading_ = nil
    end
    nk.ui.Dialog.new({
        messageText = bm.LangUtil.getText("ROOM", "SERVER_STOPPED_MSG"), 
        secondBtnText = bm.LangUtil.getText("COMMON", "LOGOUT"), 
        closeWhenTouchModel = false,
        hasFirstButton = false,
        hasCloseButton = false,
        callback = function (type)
            if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                display.addSpriteFrames("hall_texture.plist", "hall_texture.png", handler(self.scene, self.scene.onLoadedHallTextureLogout_))
                self.roomLoading_ = nk.ui.RoomLoading.new(bm.LangUtil.getText("ROOM", "OUT_MSG"))
                    :pos(display.cx, display.cy)
                    :addTo(self.scene, 100)
            end
        end,
    }):show()
end

function RoomController:onConnected_(evt)
    self.packetCache_ = {}
end

function RoomController:onEnterFrame_(dt)
    if #self.packetCache_ > 0 then
        if #self.packetCache_ == 1 then
            self.frameNo_ = 1
            local pack = table.remove(self.packetCache_, 1)
            self:processPacket_(pack)
        else
            --先检查并干掉累计的超过一局的包
            local removeFromIdx = 0
            local removeEndIdx = 0
            for i, v in ipairs(self.packetCache_) do
                if v.cmd == nk.server.PROTOCOL.SVR_GAME_OVER then
                    if removeFromIdx == 0 then
                        removeFromIdx = i + 1 --这里从结束包的下一个开始干掉
                    else
                        removeEndIdx = i --到最后一个结束包
                    end
                end
            end
            if removeFromIdx ~= 0 and removeEndIdx ~= 0 then
                print("!=!=!=! THROW AWAY PACKET FROM " .. removeFromIdx .. " to " .. removeEndIdx)
                --干掉超过一局的包，但是要保留坐下站起包，以保证座位数据正确
                local keepPackets = {}
                for i = removeFromIdx, removeEndIdx do
                    local pack = table.remove(self.packetCache_, removeFromIdx)
                    if pack.cmd == nk.server.PROTOCOL.SVR_SIT_DOWN or pack.cmd == nk.server.PROTOCOL.SVR_STAND_UP then
                        keepPackets[#keepPackets + 1] = pack
                        pack.fastForward = true
                    end
                end
                if #keepPackets > 0 then
                    table.insertto(self.packetCache_, keepPackets, removeFromIdx)
                end
            end
            self.frameNo_ = self.frameNo_ + 1
            if self.frameNo_ > PACKET_PROC_FRAME_INTERVAL then
                self.frameNo_ = 1
                local pack = table.remove(self.packetCache_, 1)
                self:processPacket_(pack)
            end
        end
    end
    return true
end

function RoomController:onPacketReceived_(evt)
    print("RoomController:onPacketReceived_")
    table.insert(self.packetCache_, evt.packet)
end

function RoomController:SVR_DOUBLE_LOGIN(pack)
    -- nk.PopupManager:removeAllPopup()
    
    nk.ui.Dialog.new({
        messageText = T("您的账户在别处登录"), 
        secondBtnText = T("确定"),
        closeWhenTouchModel = false,
        hasFirstButton = false,
        hasCloseButton = false,
        callback = function (type)
            if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                self.scene:doBackToLogin()
            end
        end,
    }):show()
end

function RoomController:SVR_LOGIN_OK(pack)
    local data = pack
    if data.tid > 0 then
        -- 重连房间
        self.tid__ = data.tid
        nk.server:loginRoom(self.tid__)
    else
        self.scene:doBackToHall()
    end
end

function RoomController:SVR_LOGIN_ROOM_OK(pack)   
    dump(pack,"SVR_LOGIN_ROOM_OK")
    local ctx = self.ctx
    local model = self.model

    if self.roomLoading_ then
        self.roomLoading_:removeFromParent()
        self.roomLoading_ = nil
    end

    self:reset()

    --登录成功
    model:initWithLoginSuccessPack(pack)

    self.scene:removeLoading()

    --显示房间信息
    self.scene:setRoomInfoText(model.roomInfo)
    --老虎机盲注
    self.scene:setSlotBlind(model.roomInfo)

    --初始化座位及玩家
    ctx.seatManager:initSeats(model.seatsInfo, model.playerList)

    --设置庄家指示
    ctx.animManager:moveDealerTo(ctx.seatManager:getSeatPositionId(model.gameInfo.dealerSeatId), false)
    

    --初始隐藏灯光
    if model.gameInfo.curDealSeatId ~= -1 then
        ctx.lampManager:show()
        ctx.lampManager:turnTo(ctx.seatManager:getSeatPositionId(model.gameInfo.curDealSeatId), false)

        --座位开始计时器动画
        ctx.seatManager:startCounter(model.gameInfo.curDealSeatId)
    else
        ctx.lampManager:hide()
        ctx.seatManager:stopCounter()
    end

    --(要在庄家指示和灯光之后转动，否则可能位置不正确)
    if model:isSelfInSeat() then
        ctx.seatManager:rotateSelfSeatToCenter(model:selfSeatId(), false)
    end

    --如果玩家坐下并且不在本轮游戏，则提示等待下轮游戏
    if model:isSelfInSeat() and not model:isSelfInGame() then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "WAIT_NEXT_ROUND"))
    end

    --设置快速操作下注倍率
    local quickRateGroup
    local roomData = nk.getRoomDataByLevel(model.roomInfo.roomType)
    if roomData and roomData.quickRateGroup then
        quickRateGroup = roomData.quickRateGroup
    end
    ctx.oprManager:setQuickRate(quickRateGroup)


    --重置操作栏自动操作状态
    ctx.oprManager:resetAutoOperationStatus()
    --更新操作栏状态
    ctx.oprManager:updateOperationStatus()

    -- 设置登录筹码堆
    ctx.chipManager:setLoginChipStacks()

    self.gameSchedulerPool:clearAll()

    self:updateChangeRoomButtonMode()

    --自动坐下
    self:applyAutoSitDown()

    -- 上报广告平台  玩牌
    if nk.AdSdk then 
        nk.AdSdk:reportPlay()
    end
    if model.roomInfo then
        --私人房特例
        if model.roomInfo.roomType == 31 and (model.gameInfo.gameStatus == consts.SVR_GAME_STATUS.READY_TO_START) then
            nk.TopTipManager:showTopTip( bm.LangUtil.getText("ROOM", "WAIT_FOR_GAME"))
        end
    end
end

function RoomController:SVR_LOGIN_ROOM_FAIL(pack)
    dump(pack,"SVR_LOGIN_ROOM_FAIL")
end

function RoomController:SVR_LOGOUT_ROOM_OK(pack)

end

function RoomController:SVR_SEAT_DOWN(pack)
    local ctx = self.ctx
    local model = self.model
    --坐下
    local seatId, isAutoBuyin = model:processSitDown(pack)
    if isAutoBuyin then
        local seatView_ = ctx.seatManager:getSeatView(seatId)
        seatView_:playAutoBuyinAnimation(pack.anteMoney)
        return
    end
    if model:selfSeatId() == seatId then
        --更新全部座位状态，没人的座位会隐藏
        ctx.seatManager:updateAllSeatState()
        --把自己的座位转到中间去
        ctx.seatManager:rotateSelfSeatToCenter(seatId, true)
       
    else        
        --更新座位信息
        ctx.seatManager:updateSeatState(seatId)       
    end

    ctx.seatManager:playSitDownAnimation(seatId)
    self:updateChangeRoomButtonMode()

    bm.EventCenter:dispatchEvent({name=nk.eventNames.UPDATE_SEAT_INVITE_VIEW, data={ctx = self.ctx,seatId = seatId}})
end

function RoomController:SVR_SET_BET(pack)
end

function RoomController:SVR_MSG(pack)
end

function RoomController:SVR_DEAL(pack)
    local ctx = self.ctx
    local model = self.model
    model:processDeal(pack)   
    ctx.seatManager:prepareDealCards()   
    ctx.dealCardManager:dealCards()    
end

function RoomController:SVR_LOGIN_ROOM(pack)

end

function RoomController:SVR_LOGOUT_ROOM(pack)    
end

function RoomController:SVR_SELF_SEAT_DOWN_OK(pack)   
    if pack.ret ~= 0 then
        --坐下失败
        local errorCode = pack.ret
        local Q = consts.SVR_SIT_DOWN_FAIL_CODE
        local M = bm.LangUtil.getText("ROOM", "SIT_DOWN_FAIL_MSG")
        local msg = nil
        printf("SVR_SIT_DOWN_FAIL ==> %x", errorCode)
        if errorCode == Q.CHIPS_ERROR then
            msg = M["CHIPS_ERROR"]
        elseif errorCode == Q.SEAT_NOT_EMPTY then
            msg = M["SEAT_NOT_EMPTY"]
            local findEmptySeat = nk.OnOff:check("findEmptySeat");
            if(findEmptySeat and self.checkIngEmptySeat) then
                self:applyAutoSitDown();
                return
            end
        else           
            msg = M["OTHER"].."[".. errorCode.."]"
        end
        if msg then
            nk.TopTipManager:showTopTip(msg)
        end
    end  
end

function RoomController:SVR_STAND_UP(pack)
    if pack.ret ~= 0 then
        return
    end
    local ctx = self.ctx
    local model = self.model
    local seatId = model:processStandUp(pack)
    local positionId = ctx.seatManager:getSeatPositionId(seatId) 
    --更新全部座位状态，没人的座位会显示
    ctx.seatManager:updateAllSeatState()
    --把转动过的座位还原
    ctx.seatManager:rotateSeatToOrdinal()
    --动画隐藏操作栏
    ctx.oprManager:hideOperationButtons(true)
    
    ctx.seatManager:playStandUpAnimation(seatId, function() 
        ctx.seatManager:updateSeatState(seatId)
    end)

    --干掉已经发的手牌
    self.dealCardManager:hideDealedCard(positionId)

      --如果当前座位正在计时，强制停止
    ctx.seatManager:stopCounterOnSeat(seatId)

    self:updateChangeRoomButtonMode() 
    ctx.chipManager:clearChip(seatId)   

    self:processBankrupt(1,true) 
    self:processBestMaxMoney()  
    bm.EventCenter:dispatchEvent({name=nk.eventNames.UPDATE_SEAT_INVITE_VIEW, data={ctx = self.ctx,standUpSeatId = seatId}})
end

function RoomController:SVR_OTHER_STAND_UP(pack)
    local ctx = self.ctx
    local model = self.model

    --站起
    local selfSeatId = model:selfSeatId()
    local seatId = model:processStandUp(pack)
    local positionId = ctx.seatManager:getSeatPositionId(seatId)   
    --ctx.seatManager:updateSeatState(seatId)
    
    --播放站起动画    
    ctx.seatManager:playStandUpAnimation(seatId, function() 
        ctx.seatManager:updateSeatState(seatId)
    end)
    
    --干掉已经发的手牌
    self.dealCardManager:hideDealedCard(positionId)
    
    --如果当前座位正在计时，强制停止
    ctx.seatManager:stopCounterOnSeat(seatId)

    self:updateChangeRoomButtonMode()
    
    ctx.chipManager:clearChip(seatId)

    bm.EventCenter:dispatchEvent({name=nk.eventNames.UPDATE_SEAT_INVITE_VIEW, data={ctx = self.ctx,standUpSeatId = seatId}})
end

function RoomController:SVR_OTHER_OFFLINE(pack)    
end

function RoomController:SVR_GAME_START(pack)
    local ctx = self.ctx
    local model = self.model

    if not self.hasReset_ then
        self:reset()
    end
    self.hasReset_ = false

    --牌局开始
    model:processGameStart(pack)

    --移动庄家指示
    ctx.animManager:moveDealerTo(ctx.seatManager:getSeatPositionId(model.gameInfo.dealerSeatId), true)

    self.gameStartDelay_ = 2 + model:getNumInRound() * 3 * 0.1

    --重置操作栏自动操作状态
    ctx.oprManager:resetAutoOperationStatus()    
    

    --更新操作栏状态
    ctx.oprManager:updateOperationStatus()

    --更新座位状态
    ctx.seatManager:updateAllSeatState()

    self:updateChangeRoomButtonMode()

    --如果自己在桌位上
    if model:isSelfInSeat() then
        --不是庄家,显示倒计时
        if not model:isSelfDealer() then   
            nk.SoundManager:playSound(nk.SoundManager.NOTICE)
            if nk.userDefault:getBoolForKey(nk.cookieKeys.SHOCK, false) then
                nk.Native:vibrate(500)
            end
            ctx.seatManager:startCounter(model:selfSeatId())
        else
            --庄家显示进度条
            ctx.oprManager:startLoading()
        end
    else
        ctx.oprManager:startLoading()
    end
end

function RoomController:turnTo_(seatId)
    local ctx = self.ctx
    local model = self.model
    if model:selfSeatId() == seatId then
        nk.SoundManager:playSound(nk.SoundManager.NOTICE)
        if nk.userDefault:getBoolForKey(nk.cookieKeys.SHOCK, false) then
            nk.Native:vibrate(500)
        end
    end
    --打光切换
    ctx.lampManager:show()
    ctx.lampManager:turnTo(self.seatManager:getSeatPositionId(seatId), true)
    --座位开始计时器动画
    self.gameSchedulerPool:delayCall(function()
        ctx.seatManager:startCounter(seatId)
        --更新操作栏状态
        ctx.oprManager:updateOperationStatus()
    end, 0.5)
end

--下注
function RoomController:SVR_BET(pack)
    local ctx = self.ctx
    local model = self.model
    --下注成功
    local seatId = model:processBetSuccess(pack)

    --更新座位信息
    ctx.seatManager:updateSeatState(seatId)

    local player = model.playerList[seatId]
    local isSelf = model:isSelf(player.uid)
    if player then
        --如果当前座位正在计时，强制停止
        ctx.seatManager:stopCounterOnSeat(seatId)
        ctx.chipManager:betChip(player)       
        nk.SoundManager:playSound(nk.SoundManager.CALL)
        
        -- all in
        if player.anteMoney == 0 then
            nk.SoundManager:playSound(nk.SoundManager.RAISE)
        end
    end
    if isSelf then
        ctx.oprManager:updateOperationStatus()
    end
end

function RoomController:SVR_CAN_OTHER_CARD(pack)
    local model = self.model
    local ctx = self.ctx
    local seatId = model:processTurnToGetPoker(pack)
    self:turnTo_(seatId)
end

function RoomController:SVR_OTHER_OTHER_CARD(pack)
    local model = self.model
    local ctx = self.ctx
    --发第三张牌
    local seatId = model:processGetPoker(pack)
    if model:selfSeatId() ~= seatId and pack.type == 1 then
        ctx.dealCardManager:dealCardToPlayer(seatId)
    end
    ctx.seatManager:stopCounterOnSeat(seatId)
    ctx.seatManager:updateSeatState(seatId)
end

function RoomController:SVR_OTHER_CARD(pack)
    local ctx = self.ctx
    local model = self.model
    model:processGetPokerBySelf(pack)
    ctx.dealCardManager:dealCardToPlayer(self.model:selfSeatId())
end

-- 亮牌
function RoomController:SVR_SHOW_CARD(pack)
    local model = self.model
    model:processShowHand(pack)
    --这里只标注需要亮牌,亮牌动画在发牌动画结束之后
end

-- 广播发牌 
function RoomController:SVR_CARD_NUM(pack)
    local ctx = self.ctx
    local model = self.model
    if model:isSelfDealer() or not model:isSelfInSeat() then  
        ctx.oprManager:stopLoading()
    end
    model:processPot(pack)
    ctx.lampManager:hide()
    if not model:isSelfInSeat() then
        ctx.seatManager:prepareDealCards()   
        ctx.dealCardManager:dealCards()   
    end
end



function RoomController:SVR_SEARCH_PERSONAL_ROOM(pack)
    self.scene:onSearchPersonalRoom(pack)
end


--发送房间内广播
function RoomController:SVR_ROOM_BROADCAST(pack)
    -- dump(pack, "RoomController:SVR_ROOM_BROADCAST :==========")
    if (not pack) or (not pack.info) then
        return
    end
    local info = json.decode(pack.info)
    if not info then
        return
    end

    local uid = tonumber(pack.uid)
    local mtype = info.mtype
    local model = self.model
    if mtype == 1 then
        --聊天消息

        --聊天记录
        local chatHistory = bm.DataProxy:getData(nk.dataKeys.ROOM_CHAT_HISTORY)
        if not chatHistory then
            chatHistory = {}
        end

        local msg = bm.LangUtil.getText("ROOM", "CHAT_FORMAT", info.name, info.msg)
        chatHistory[#chatHistory + 1] = {messageContent = msg, time = bm.getTime(), mtype = 2}
        bm.DataProxy:setData(nk.dataKeys.ROOM_CHAT_HISTORY, chatHistory)

        local seatId = model:getSeatIdByUid(uid)
        self.animManager:showChatMsg(seatId,info.msg)
        --更新最近聊天文字
        self.oprManager:setLatestChatMsg(info.msg)
    elseif mtype == 2 then
    --     --用户换头像
    --     local seatId, uid, url = param1, param2, param3
    --     if seatId ~= -1 then
    --         self.seatManager:updateHeadImage(seatId, url)
    --     end
    elseif mtype == 3 then
    --     -- 赠送礼物
            local giftId = info.giftId
            local fromUid = uid
            local fromSeatId = model:getSeatIdByUid(fromUid)
            local toUidArr = info.tuids
            local toSeatIdArr = {}

            for _,v in pairs(toUidArr)do
                local tsid = model:getSeatIdByUid(v)
                if tsid ~= -1 then
                    table.insert(toSeatIdArr,tsid)
                end
            end

            if fromSeatId ~= -1 and #toSeatIdArr > 0 then
                self.animManager:playSendGiftAnimation(giftId, fromUid, toUidArr)
            elseif #toSeatIdArr > 0 then
                for _, seatId in ipairs(toSeatIdArr) do
                    if seatId ~= -1 then
                        self.seatManager:updateGiftUrl(seatId, giftId)
                    end
                end
            end
    elseif mtype == 4 then
        --设置礼物
        local giftId = info.giftId
        local uid = info.uid
        local seatId = model:getSeatIdByUid(uid)
        if seatId ~= -1 then
            self.seatManager:updateGiftUrl(seatId, giftId)
        end
    elseif mtype == 5 then
        --发送表情
        local seatId = model:getSeatIdByUid(uid)
        local faceId = info.faceId
        local fType = info.fType
        local isSelf = (uid == nk.userData.uid) and true or false
        local minusChips = 0 --是否需要扣费 test
        if seatId then
            self.animManager:playExpression(seatId, faceId)
            if isSelf and minusChips > 0 then
                --是自己并且有扣钱，播放扣钱动画
                self.animManager:playChipsChangeAnimation(seatId, - minusChips)
            end
        end
    elseif mtype == 6 then
        --互动道具
        local fromSeatId = model:getSeatIdByUid(uid)
        local toSeatIds = info.toSeatIds
        local selfUid = nk.userData.uid
        local fromPlayer = model.playerList[fromSeatId]
        local pnid = info.pnid
        local pid = info.pid

        for _,v in pairs(toSeatIds) do
            local toPlayer = model.playerList[v]
            if selfUid ~= uid and toPlayer and fromPlayer then
                --自己发送的互动道具动画已经提前播过了
                self.animManager:playHddjAnimation(fromSeatId, v, pid)
            end
        end
    elseif mtype == 7 then
        --给荷官赠送筹码
        local fee = info.fee
        local num = info.num
        local uid = uid
        local fromSeatId = model:getSeatIdByUid(uid)
        local toSeatId = 9 
        local player = self.model.playerList[fromSeatId]
        if player then
            self.animManager:playSendChipAnimation(fromSeatId, toSeatId, fee)
            self.sceneSchedulerPool:delayCall(function() 
                    self.ctx.dealerManager:kissPlayer()
                    bm.EventCenter:dispatchEvent({name = nk.eventNames.SEND_DEALER_CHIP_BUBBLE_VIEW, nick=player.userInfo.name})
                end, 2)
            local sendNumber_ =    cc.UserDefault:getInstance():getIntegerForKey(nk.cookieKeys.RECORD_SEND_DEALER_CHIP_TIME .. nk.userData.uid, 5)
                sendNumber_ = sendNumber_  - 1
                cc.UserDefault:getInstance():setIntegerForKey(nk.cookieKeys.RECORD_SEND_DEALER_CHIP_TIME .. nk.userData.uid, sendNumber_)
            if sendNumber_ <= 0 then
                self.sceneSchedulerPool:delayCall(function() 
                        self.animManager:playHddjAnimation(toSeatId, fromSeatId,math.random(3,4))
                    end, 4)
                cc.UserDefault:getInstance():setIntegerForKey(nk.cookieKeys.RECORD_SEND_DEALER_CHIP_TIME .. nk.userData.uid, 5)
            end
        end

    elseif mtype == 8 then

     local fromSeatId = model:getSeatIdByUid(uid)
     local toSeatId = info.tseatId

     dump("fromSeatId:" .. fromSeatId .. " toSeatId:" .. toSeatId)
         --用户加牌友
        self.animManager:playAddFriendAnimation(fromSeatId,toSeatId)
    elseif mtype == 9 then
        local uid = uid
        local fromSeatId = model:getSeatIdByUid(uid)
        self.animManager:playSendChipAnimation(fromSeatId, info.geterId, info.chips);
        nk.userData["aUser.money"] = nk.userData["aUser.money"]-checkint(info.chips);
    end
end

function RoomController:SVR_COMMON_BROADCAST(pack)
    local mtype = pack.mtype
    local info = pack.info
    if mtype == 2 then
        local inviteData = json.decode(pack.info)
        local inviteName_ = inviteData.name;
        local tid = inviteData.tid;
        local content_ = bm.LangUtil.getText("HALL","PERSONAL_ROOM_INVITE_CONTENT",inviteName_);
        nk.TopTipManager:showTopTip(content_)
        nk.userData["inviteRoomData"] = {tid = tid, time = os.time(),inviteName = inviteName_}
        -- dump(inviteName_,"ddddd")
        -- dump(tid,"tidddd")
    elseif mtype == 4 then
        --比赛场邀请广播

        --达到条件弹比赛场推荐
        if pack.info then
            local pInfo = json.decode(pack.info)
            if pInfo and pInfo.msg and pInfo.msg ~= "" then
                local buttonLabel_ = bm.LangUtil.getText("MATCH","JOIN_MATCH") or bm.LangUtil.getText("COMMON", "CONFIRM")
                    local button = cc.ui.UIPushButton.new({normal = "#common_dark_blue_btn_up.png", pressed = "#common_dark_blue_btn_down.png", disabled = "#common_btn_disabled.png"}, {scale9 = true})
                        :setButtonSize(140, 52)
                        :setButtonLabel("normal", display.newTTFLabel({text = buttonLabel_ , color = styles.FONT_COLOR.LIGHT_TEXT, size = 20, align = ui.TEXT_ALIGN_CENTER}))
                        :onButtonClicked(buttontHandler(self,
                        function() 
                            if self.ctx.model:isSelfInGame() and self.ctx.model:hasCardActive() then
                                nk.ui.Dialog.new({
                                    messageText = bm.LangUtil.getText("ROOM", "EXIT_IN_GAME_MSG"), 
                                    hasCloseButton = false,
                                    callback = function (type)
                                        if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                                            nk.server:logoutRoom()
                                            --HallController.CHOOSE_MATCH_NOR_VIEW = 7
                                            bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW,7)
                                            self.scene:doBackToHall()
                                        end
                                    end
                                }):show()
                            else              
                                nk.server:logoutRoom()
                                bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW,7)
                                self.scene:doBackToHall()
                            end
                        end))
                    nk.TopTipExManager:showTopTip({text = pInfo.msg or bm.LangUtil.getText("MATCH","RECOMMEND_PUSH_TIP"),button = button,messageType = 1001,stayTime = 15})
            end
        end            
    elseif mtype == 5 then
        local infoData = json.decode(pack.info)
        local msgData = infoData.msg
        local toRoomId = infoData.roomId
        local cfg = infoData.cfg

        local isShow = 0
        if cfg.type == "money" then
            if nk.userData["aUser.money"]>= checkint(cfg.num) then
                isShow = 1
            end
        elseif cfg.type == "point" then
            if nk.userData["match.point"]>= checkint(cfg.num) then
                isShow = 1
            end
        end
        if isShow == 0 then return end
       -- nk.TopTipManager:showTopTip("fuck dandan ")

       local toGrabFun = function()
            nk.server:logoutRoom()
            self.scene:doBackToHall()
            self.gameSchedulerPool:delayCall(function()
                nk.server:getGrabDealerRoomAndLogin(consts.ROOM_GAME_LEVEL.GRAB_ROOM_LEVEL,toRoomId)
            end, 1.2)
      end

       self.exButton_ = cc.ui.UIPushButton.new({normal = "#common_btn_aqua.png", pressed = "#common_btn_aqua.png", disabled = "#common_btn_disabled.png"},
            {scale9 = true})
        :setButtonSize(120, 48)
        :setButtonLabel("normal", display.newTTFLabel({text = "Go>>>", size = 20, color = styles.FONT_COLOR.LIGHT_TEXT,
            align = ui.TEXT_ALIGN_CENTER}))
        :onButtonClicked(
            function()
                nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)

                if self.ctx.model:isSelfInGame() and self.ctx.model:hasCardActive() then
                    nk.ui.Dialog.new({
                    messageText = bm.LangUtil.getText("ROOM", "EXIT_IN_GAME_MSG"), 
                    hasCloseButton = false,
                    callback = function (type)
                        if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                           toGrabFun()
                        end
                    end
                    }):show()
                else
                    toGrabFun()
                end

            end
        )

        nk.TopTipExManager:showTopTip({text = msgData, messageType = 1001, button = self.exButton_})

        nk.TopTipExManager:setLblColor_(styles.FONT_COLOR.LIGHT_TEXT)
    end
end


function RoomController:SVR_PUSH_MATCH_ROOM(pack)
    local leftTime = pack.leftTime
    if leftTime<=2 then  return end
    local tipDialog = nk.ui.Dialog.new({
            messageText = T("距离比赛开始还剩: ").."\n\n\n",--bm.LangUtil.getText("ROOM", "STAND_UP_IN_GAME_MSG"), 
            hasCloseButton = false,
           -- firstBtnText = T(""),
            secondBtnText = T("立即参赛"),
            callback = function (type)
                if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                    bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW,2)
                    bm.DataProxy:setData(nk.dataKeys.TO_MATCH_DATA, pack)

                    nk.server:logoutRoom()
                    self.scene:doBackToHall()
                end
            end,
        }):show()

      self.animationDownNum_ = AnimationDownNum.new({
        parent=tipDialog,
        time=leftTime-2, 
        scale=0.5, 
        refreshCallback=function(retVal)
            
        end,
        callback=function()
           tipDialog:hidePanel_()
        end})
end

function RoomController:SVR_SUONA_BROADCAST_RECV(pack)
    -- body
    -- dump(pack, "RoomController.SVR_SUONA_BROADCAST_RECV :=================")

    if pack and pack.msg_info then
        --todo
        local chatData = json.decode(pack.msg_info)

        local msgType = chatData.type

        -- dump(chatData, "chatData :=================")
        if msgType == 2 then
            --todo
            local contentMsg = chatData.content
            local jumpIndex = chatData.location
            local textColorHex = chatData.color

            local textColorRGB = nil
            if textColorHex and string.len(textColorHex) > 0 then
                --todo
                local colorR = "0x" .. string.sub(textColorHex, 1, 2)
                local colorG = "0x" .. string.sub(textColorHex, 3, 4)
                local colorB = "0x" .. string.sub(textColorHex, 5, 6)

                textColorRGB = cc.c3b(colorR, colorG, colorB)
            end

            if jumpIndex == "0" then
                --todo
                nk.TopTipExManager:showTopTip({text = contentMsg, messageType = 1001})
                nk.TopTipExManager:setLblColor_(textColorRGB)
            else
                self.broadcastJumpAction_ = jumpIndex

                self.exButton_ = cc.ui.UIPushButton.new({normal = "#common_btn_aqua.png", pressed = "#common_btn_aqua.png", disabled = "#common_btn_disabled.png"},
                    {scale9 = true})
                    :setButtonSize(120, 48)
                    :setButtonLabel("normal", display.newTTFLabel({text = "Go>>>", size = 20, color = styles.FONT_COLOR.LIGHT_TEXT,
                        align = ui.TEXT_ALIGN_CENTER}))
                    :onButtonClicked(buttontHandler(self, self.onBoroadCastMsgJump_))

                nk.TopTipExManager:showTopTip({text = contentMsg, messageType = 1001, button = self.exButton_})

                nk.TopTipExManager:setLblColor_(textColorRGB)
            end
        elseif msgType == 1 or not msgType then
            --todo
            local chatFromName = chatData.name
            local chatMsg = chatData.content
            local chatInfoMsg = "[" .. chatFromName .. "]" .. bm.LangUtil.getText("SUONA", "SAY") .. chatMsg

            nk.TopTipManager:showTopTip({text = chatInfoMsg, messageType = 1000})
        end
    end
end

function RoomController:SVR_GAME_OVER(pack)
    local ctx = self.ctx
    local model = self.model
    self.gameSchedulerPool:clearAll()
    local isSelfPlayed = model:processGameOver(pack)
    --隐藏灯光
    ctx.lampManager:hide()
    --禁用操作按钮
    ctx.oprManager:blockOperationButtons()
    --座位停止计时器
    ctx.seatManager:stopCounter()
    --亮牌
    self.seatManager:showHandCard()

    -- 延迟处理
    local resetDelayTime = 6
    local chipDelayTime = 0
    local dealer = model:dealerSeatData()
    if dealer and checkint(dealer.trunMoney) < 0  then
        ctx.chipManager:betChip(dealer)
        chipDelayTime = 0.8
    else
        chipDelayTime = 0
    end

    self.schedulerPool:delayCall(function ()
        ctx.chipManager:gatherPot()        
    end, chipDelayTime)

    -- 分奖池动画 ,播放Winner动画
    self.schedulerPool:delayCall(function ()
        ctx.chipManager:splitPots()        
    end, chipDelayTime + 1)

    self.schedulerPool:delayCall(function ()
        --座位经验值变化动画
        ctx.seatManager:playExpChangeAnimation()   
    end, chipDelayTime + 3)


    local isBankrup = self:processBankrupt(0,false);
    if not isBankrup and (self.model:isSelfInSeat())then
        self:processUpgrade(chipDelayTime+4)
    end

    -- 刷新游戏状态
    self.schedulerPool:delayCall(handler(self, self.reset), resetDelayTime)

    if self.isOverStandUp and self.isOverStandUp == true then
        if self.ctx.model:isSelfInSeat() then
            nk.server:standUp()
        end
    end
    self.isOverStandUp = false


    
    local cardRecordInfo = model:processCardRecord(pack)
   
    if cardRecordInfo then
        local datas = {}
        local d
        for _,v in pairs(cardRecordInfo) do
             d = {}
            d.name = v.name
            d.cards = clone(v.cards)

            if v.isDealer then
                datas[2] = d
            else
                if v.uid == nk.userData["aUser.mid"] then
                    datas[1] = d
                end
            end
        end

        self.schedulerPool:delayCall(function (schedulerPool,cardRecords)
            bm.DataProxy:setData(nk.dataKeys.ROOM_CARD_RECORD, cardRecords)
    end, resetDelayTime - 1,cardRecordInfo)


        
    end

    --该局自己是否参与过
    if isSelfPlayed then
        self:processMatchRecommendPush()
    end
end


function RoomController:processMatchRecommendPush()
    local matchPushInfo = nk.userDefault:getStringForKey(nk.cookieKeys.MATCH_RECOMMEND_PUSH)
    if matchPushInfo == "" then
        nk.userDefault:setStringForKey(nk.cookieKeys.MATCH_RECOMMEND_PUSH,  ( 1 .. "," .. os.date("%Y%m%d")) )
    else
        local matchTb = string.split(matchPushInfo,",")
        local playCount = checkint(matchTb[1])
        local date = matchTb[2]
        local targetCount = 10
        if date ~= os.date("%Y%m%d") then
            nk.userDefault:setStringForKey(nk.cookieKeys.MATCH_RECOMMEND_PUSH,  ( 1 .. "," .. os.date("%Y%m%d")) )
        else
            if playCount < targetCount then
                playCount = playCount + 1
                nk.userDefault:setStringForKey(nk.cookieKeys.MATCH_RECOMMEND_PUSH,  ( playCount .. "," .. os.date("%Y%m%d")) )
                if playCount == targetCount then
                    --达到条件弹比赛场推荐
                    local buttonLabel_ = bm.LangUtil.getText("MATCH","JOIN_MATCH") or bm.LangUtil.getText("COMMON", "CONFIRM")
                    --如果玩家现金币超过10个，则发送现金币场的推送
                    if nk.userData["match.point"]>= 10 then
                        buttonLabel_ =  bm.LangUtil.getText("COMMON", "CONFIRM")
                    end  
                    local button = cc.ui.UIPushButton.new({normal = "#common_dark_blue_btn_up.png", pressed = "#common_dark_blue_btn_down.png", disabled = "#common_btn_disabled.png"}, {scale9 = true})
                        :setButtonSize(140, 52)
                        :setButtonLabel("normal", display.newTTFLabel({text = buttonLabel_ , color = styles.FONT_COLOR.LIGHT_TEXT, size = 20, align = ui.TEXT_ALIGN_CENTER}))
                        :onButtonClicked(buttontHandler(self,
                        function() 
                            if self.ctx.model:isSelfInGame() and self.ctx.model:hasCardActive() then
                                nk.ui.Dialog.new({
                                    messageText = bm.LangUtil.getText("ROOM", "EXIT_IN_GAME_MSG"), 
                                    hasCloseButton = false,
                                    callback = function (type)
                                        if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                                            nk.server:logoutRoom()
                                            --HallController.CHOOSE_MATCH_NOR_VIEW = 7
                                            if nk.userData["match.point"]>= 10 then
                                                bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW,3)
                                            else
                                                bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW,7)
                                            end
                                            self.scene:doBackToHall()
                                        end
                                    end
                                }):show()
                            else              
                                nk.server:logoutRoom()
                                if nk.userData["match.point"]>= 10 then
                                    --出房间需要到选现金币房间列表，由于chooseRoomView有对tab
                                    --控制，所以设置一个字段。
                                    nk.userData.TAB_SETING = 3
                                    bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW,3)
                                else
                                    bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW,7)
                                end
                                self.scene:doBackToHall()
                            end
                        end))
                   
                    if nk.userData["match.point"]>= 10 then
                        nk.userData.TAB_SETING = 3
                        nk.TopTipExManager:showTopTip({text = bm.LangUtil.getText("GRAB_DEALER","GRAB_ROOM_PUSH_TIP"),button = button,messageType = 1001})
                    else 
                        nk.TopTipExManager:showTopTip({text = bm.LangUtil.getText("MATCH","RECOMMEND_PUSH_TIP"),button = button,messageType = 1001})
                    end
                end
            end
        end

    end
   
    
end


function RoomController:processUpgrade(delay)
    local oldExp = checkint(nk.userData["aUser.exp"])
    local selfSeatData = self.model:selfSeatData()
    local getExp = selfSeatData.getExp or 0
    local nowExp = oldExp + getExp

    if nowExp ~= oldExp then
        nk.userData["aUser.exp"] = nowExp
    end

    local isLevelConfigLoaded = nk.Level:isConfigLoaded()
    if not isLevelConfigLoaded then
        return
    end
    
    if nowExp > oldExp then
        --非破产才弹升级动画
        self.schedulerPool:delayCall(function ()
        --升级动画
         --计算是否可升级
        local exp = checkint(nk.userData["aUser.exp"])
        local level = nk.userData["aUser.mlevel"]          
        local maxLevel = nk.Level:getLevelByExp(exp);
        local dsLevel = maxLevel- level
        if (maxLevel > level) and (dsLevel >= 1) then
            nk.userData.nextRwdLevel = level + 1
        else
            nk.userData.nextRwdLevel = 0
        end
        if nk.userData.nextRwdLevel and nk.userData.nextRwdLevel ~= 0 then
            display.addSpriteFrames("upgrade_texture.plist", "upgrade_texture.png", function()
                UpgradePopup.new(nk.userData.nextRwdLevel):show()
            end)
        end

     end, delay)

    end   
end

function RoomController:processBestMaxMoney()
    if nk.userData.best and nk.userData.best.maxmoney then
        if nk.userData["aUser.money"] > nk.userData.best.maxmoney then
            local info = {maxmoney = nk.userData["aUser.money"]}
            nk.http.updateMemberBest(info)
            nk.userData.best["maxmoney"] = nk.userData["aUser.money"]
        end
    end
end


function RoomController:processBankrupt(delay,showView)
    local isBankrup = false

    if nk.userData["aUser.money"] >= self.model.roomInfo.minBuyIn then
        --todo
        if nk.userData.bankruptcyGrant and nk.userData["aUser.money"] < nk.userData.bankruptcyGrant.maxBmoney then
            if nk.userData.bankruptcyGrant.bankruptcyTimes < nk.userData.bankruptcyGrant.num then
                isBankrup = true
            end
        end
        
        return isBankrup
    end

    local roomData = nk.getRoomDataByLevel(self.model.roomInfo.roomType)

    -- dump(roomData, "roomData :===============")
    if nk.userData.bankruptcyGrant and nk.userData["aUser.money"] < nk.userData.bankruptcyGrant.maxBmoney then
        if nk.userData["aUser.bankMoney"] >= nk.userData.bankruptcyGrant.maxsafebox then
            --保险箱的钱大于设定值，引导保险箱取钱
            local userCrash = UserCrash.new(0,0,0,0,true,true)
            userCrash:show()

        else
            --保险箱的钱小于设定值，给破产引导和奖励
            if nk.userData.bankruptcyGrant.bankruptcyTimes < nk.userData.bankruptcyGrant.num then
                isBankrup = true

                if showView then
                    local isShowPay = nk.OnOff:check("payGuide")
                    local isPay = nk.userData.best and nk.userData.best.paylog == 1 or false
                    -- local isAlmChargeFavPay = nk.userData.bagPayList and nk.userData.bagPayList.almRechgFav == 1 or false 

                    local showBankruptScene = 3

                    if delay and delay > 0 then
                        --todo
                        self.schedulerPool:delayCall(function()
                                -- body

                            if nk.userData.bankruptcyGrant.bankruptcyTimes == 0 then

                                local params = {}

                                params.isOpenThrPartyPay = isThirdPayOpen
                                params.isFirstCharge = isFirstCharge
                                params.sceneType = showBankruptScene
                                params.payListType = payBillType

                                PayGuide.new(params):show(0, nil, true)

                            else
                                if nk.userData.bankruptcyGrant then
                                    --todo
                                    local rewardTime = nk.userData.bankruptcyGrant.bankruptcyTimes + 1
                                    local bankruptcyTimes = nk.userData.bankruptcyGrant.bankruptcyTimes
                                    local rewardMoney = nk.userData.bankruptcyGrant.money[rewardTime] or 0
                                    local limitDay = nk.userData.bankruptcyGrant.day or 1
                                    local limitTimes = nk.userData.bankruptcyGrant.num or 0
                                    local userCrash = UserCrash.new(bankruptcyTimes,rewardMoney,limitDay,limitTimes)
                                    userCrash:show()
                                end
                            end

                        end, delay)
                    else

                        if nk.userData.bankruptcyGrant.bankruptcyTimes == 0 then
                            --todo
                            local isThirdPayOpen = isShowPay
                            local isFirstCharge = not isPay

                            -- 这里要取到当前要进的房间类型信息 --
                            local payBillType = nil
                            if roomData then
                                --todo
                                payBillType = roomData.roomGroup
                            end

                            local params = {}

                            params.isOpenThrPartyPay = isThirdPayOpen
                            params.isFirstCharge = isFirstCharge
                            params.sceneType = showBankruptScene
                            params.payListType = payBillType

                            PayGuide.new(params):show(0, nil, true)
                        else
                            if nk.userData.bankruptcyGrant then
                                --todo
                                local rewardTime = nk.userData.bankruptcyGrant.bankruptcyTimes + 1
                                local bankruptcyTimes = nk.userData.bankruptcyGrant.bankruptcyTimes
                                local rewardMoney = nk.userData.bankruptcyGrant.money[rewardTime] or 0
                                local limitDay = nk.userData.bankruptcyGrant.day or 1
                                local limitTimes = nk.userData.bankruptcyGrant.num or 0
                                local userCrash = UserCrash.new(bankruptcyTimes,rewardMoney,limitDay,limitTimes)
                                userCrash:show()
                            end
                        end

                    end
                    
                    if self.model and self.model.roomInfo then

                        -- dump(self.model.roomInfo, "======================")
                        --破产上报
                        local roomFiled = bm.LangUtil.getText("HALL", "ROOM_LEVEL_TEXT")[math.floor((self.model.roomInfo.roomType - 101) / 6) + 1]
                        nk.http.reportBankrupt(self.model.roomInfo.blind,roomFiled)
                    end
                    --]]
                end
            else

                if nk.userData.bankruptcyGrant then
                                --todo
                    local rewardTime = nk.userData.bankruptcyGrant.bankruptcyTimes + 1
                    local bankruptcyTimes = nk.userData.bankruptcyGrant.bankruptcyTimes
                    local rewardMoney = nk.userData.bankruptcyGrant.money[rewardTime] or 0
                    local limitDay = nk.userData.bankruptcyGrant.day or 1
                    local limitTimes = nk.userData.bankruptcyGrant.num or 0
                    local userCrash = UserCrash.new(bankruptcyTimes,rewardMoney,limitDay,limitTimes)
                    userCrash:show()
                end
            end
        end
    else
        --todo
        if nk.userData["aUser.money"] < self.model.roomInfo.minBuyIn then
            --todo
            if showView then
                local isShowPay = nk.OnOff:check("payGuide")
                local isPay = nk.userData.best and nk.userData.best.paylog == 1 or false
                -- local isAlmChargeFavPay = nk.userData.bagPayList and nk.userData.bagPayList.almRechgFav == 1 or false

                local chipNotEnoughScene = 2

                if delay and delay > 0 then
                    --todo
                    self.schedulerPool:delayCall(function()
                            -- body
                        local isThirdPayOpen = isShowPay
                        local isFirstCharge = not isPay
                        local payBillType = nil

                        if roomData then
                            --todo
                            payBillType = roomData.roomGroup
                        end
                        
                        local roomInfo = self.model.roomInfo

                        local params = {}

                        params.isOpenThrPartyPay = isThirdPayOpen
                        params.isFirstCharge = isFirstCharge
                        params.sceneType = chipNotEnoughScene

                        -- 取得当前房间的类型 1：初级场， 2：普通场， 3：高级场
                        params.payListType = payBillType

                        if not roomInfo or (roomInfo.roomType ~= consts.ROOM_TYPE.PERSONAL_NORMAL) then
                            PayGuide.new(params):show(1, self.scene.onChangeRoomClick_, true)
                        elseif roomInfo.roomType == consts.ROOM_TYPE.PERSONAL_NORMAL then
                            --todo
                            PayGuide.new(params):show(nil, - 1, true)
                        else
                            PayGuide.new(params):show(nil, nil, true)
                        end

                    end, delay)
                else

                    local isThirdPayOpen = isShowPay
                    local isFirstCharge = not isPay
                    local payBillType = nil
                    
                    if roomData then
                        --todo
                        payBillType = roomData.roomGroup
                    end

                    local roomInfo = self.model.roomInfo

                    local params = {}

                    params.isOpenThrPartyPay = isThirdPayOpen
                    params.isFirstCharge = isFirstCharge
                    params.sceneType = chipNotEnoughScene

                    -- 取得当前房间的类型 1：初级场， 2：普通场， 3：高级场
                    params.payListType = payBillType

                    if not roomInfo or (roomInfo.roomType ~= consts.ROOM_TYPE.PERSONAL_NORMAL) then
                        PayGuide.new(params):show(1, self.scene.onChangeRoomClick_, true)
                        
                    elseif roomInfo.roomType == consts.ROOM_TYPE.PERSONAL_NORMAL then
                        --todo
                        PayGuide.new(params):show(nil, - 1, true)
                    else
                        PayGuide.new(params):show(nil, nil, true)
                    end
                end
            end
        end
    end

    return isBankrup
end



function RoomController:processPacket_(pack)
    if self.func_[pack.cmd] then
        self.func_[pack.cmd](pack)
    end   
end

function RoomController:applyAutoSitDown()
    if not self.model:isSelfInGame() then
        local emptySeatId = self.seatManager:getEmptySeatId()
        if emptySeatId then
            local isAutoSit = nk.userDefault:getBoolForKey(nk.cookieKeys.AUTO_SIT, true)
            if isAutoSit or nk.server:isPlayNow() then
                self.checkIngEmptySeat = true;
                local userData = nk.userData
                if userData['aUser.money'] >= self.model.roomInfo.minBuyIn then
                    logger:debug("auto sit down", emptySeatId)
                    local isAutoBuyin = nk.userDefault:getBoolForKey(nk.cookieKeys.AUTO_BUY_IN, true)
                    nk.server:seatDown(emptySeatId, math.min(userData['aUser.money'], self.model.roomInfo.defaultBuyIn), isAutoBuyin)                  
                else
                    --这里可能scene还未切换完成，等待1S再弹对话框
                    if userData['aUser.money'] < userData.bankruptcyGrant.maxBmoney then
                        self.sceneSchedulerPool:delayCall(function()
                            nk.ui.Dialog.new({
                                messageText = bm.LangUtil.getText("COMMON", "NOT_ENOUGH_MONEY_TO_PLAY_NOW_MSG", nk.userData.bankruptcyGrant.maxBmoney), 
                                hasCloseButton = false,
                                callback = function (type)
                                    if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                                        StorePopup.new():showPanel()
                                    end
                                end
                            }):show()
                        end, 1)
                    else
                        self.sceneSchedulerPool:delayCall(function()
                            nk.ui.Dialog.new({
                                hasCloseButton = false,
                                messageText = bm.LangUtil.getText("ROOM", "SIT_DOWN_NOT_ENOUGH_MONEY"), 
                                firstBtnText = bm.LangUtil.getText("ROOM", "AUTO_CHANGE_ROOM"),
                                secondBtnText = bm.LangUtil.getText("ROOM", "CHARGE_CHIPS"), 
                                callback = function (type)
                                    if type == nk.ui.Dialog.FIRST_BTN_CLICK then
                                        self.scene:onChangeRoomClick_()
                                    elseif type == nk.ui.Dialog.SECOND_BTN_CLICK then
                                        StorePopup.new():showPanel()
                                    end
                                end
                            }):show()
                        end, 1)
                    end
                end
            end
        else
            logger:debug("can't auto sit down, no emtpy seat")
            self.checkIngEmptySeat = false;
            local M = bm.LangUtil.getText("ROOM", "SIT_DOWN_FAIL_MSG")
            msg = M["SEAT_NOT_EMPTY"]
            nk.TopTipManager:showTopTip(msg)
        end
    end
end

function RoomController:updateChangeRoomButtonMode()
    if self.model:isSelfInSeat() then
        self.scene:setChangeRoomButtonMode(2)
    else
        self.scene:setChangeRoomButtonMode(1)
    end
end

function RoomController:onBoroadCastMsgJump_()
    -- body
    local HallController = import("app.module.hall.HallController")

    local doJumpActionByTag = {
        ["matchlist"] = function()
            -- body
            if self.model:isSelfInGame() and self.model:hasCardActive() then
                --todo
                nk.ui.Dialog.new({
                    messageText = bm.LangUtil.getText("ROOM", "EXIT_IN_GAME_MSG"), 
                    hasCloseButton = false,
                    callback = function (type)
                        if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                            bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.CHOOSE_MATCH_NOR_VIEW)  -- 跳转比赛选场
                            
                            if self.scene and self.scene.doBackToHall then
                                --todo
                                nk.server:logoutRoom()
                                self.scene:doBackToHall()
                            end
                            
                        end
                    end
                }):show()
            else
                bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.CHOOSE_MATCH_NOR_VIEW)  -- 跳转比赛选场
                
                if self.scene and self.scene.doBackToHall then
                    --todo
                    nk.server:logoutRoom()
                    self.scene:doBackToHall()
                end
            end
        end,

        ["shoplist"] = function()
            -- body

            if self.scene then
                if self.scene.onShopClick_ then
                    --todo
                    self.scene:onShopClick_(1)
                end
            end
        end,

        ["invitefriends"] = function()
            -- body

            if self.scene and self.scene.onInviteBtnClick_ then
                --todo
                self.scene:onInviteBtnClick_()
            end
        end,

        ["activitycenter"] = function()
            -- body

            if self.model:isSelfInGame() and self.model:hasCardActive() then
                --todo
                nk.ui.Dialog.new({
                    messageText = bm.LangUtil.getText("ROOM", "EXIT_IN_GAME_MSG"), 
                    hasCloseButton = false,
                    callback = function (type)
                        if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                            bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.MAIN_HALL_VIEW)  -- 设置跳转到大厅

                            if self.scene and self.scene.doBackToHall then
                                --todo
                                nk.server:logoutRoom()
                                self.scene:doBackToHall(nil, "activitycenter")
                            end
                            -- local runningScene = nk.runningScene
                            -- runningScene.controller_.view_:onMoreChipClick()
                        end
                    end
                }):show()
            else
                bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.MAIN_HALL_VIEW)  -- 设置跳转到大厅

                if self.scene and self.scene.doBackToHall then
                    --todo
                    nk.server:logoutRoom()
                    self.scene:doBackToHall(nil, "activitycenter")
                end
                -- local runningScene = nk.runningScene
                -- runningScene.controller_.view_:onMoreChipClick()
            end
        end,

        ["freechips"] = function()
            -- body

            if self.model:isSelfInGame() and self.model:hasCardActive() then
                --todo
                nk.ui.Dialog.new({
                    messageText = bm.LangUtil.getText("ROOM", "EXIT_IN_GAME_MSG"), 
                    hasCloseButton = false,
                    callback = function (type)
                        if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                            bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.MAIN_HALL_VIEW)

                            if self.scene and self.scene.doBackToHall then
                                --todo
                                nk.server:logoutRoom()
                                self.scene:doBackToHall(nil, "freechips")
                            end
                            -- local runningScene = nk.runningScene
                            -- runningScene.controller_.view_:_onSignInBtnCallBack()
                        end
                    end
                }):show()
            else
                bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.MAIN_HALL_VIEW)

                if self.scene and self.scene.doBackToHall then
                    --todo
                    nk.server:logoutRoom()
                    self.scene:doBackToHall(nil, "freechips")
                end

                -- local runningScene = nk.runningScene
                -- runningScene.controller_.view_:_onSignInBtnCallBack()
            end
        end,

        ["openrank"] = function()
            -- body
            local RankingPopup = import("app.module.ranking.RankingPopup")
            RankingPopup.new():show()
        end,

        ["openfriends"] = function()
            -- body
            local FriendPopup = import("app.module.friend.FriendPopup")
            FriendPopup.new():show()
        end,

        ["openpersondata"] = function()
            -- body
            local UserInfoPopup = import("app.module.userInfo.UserInfoPopup")
            if self.model:isSelfInGame() then
                UserInfoPopup.new():show(true, nil, handler(self.scene, self.scene.onChangeRoomClick_),self.model:isSelfInGame())
            else
                UserInfoPopup.new():show(false, nil, handler(self.scene, self.scene.onChangeRoomClick_))
            end

            -- local UserInfoPopup = import("app.module.userInfo.UserInfoPopup")
            -- UserInfoPopup.new():show()
        end,

        ["gograbdealer"] = function()
            -- body

            if self.model:isSelfInGame() and self.model:hasCardActive() then
                --todo
                nk.ui.Dialog.new({
                    messageText = bm.LangUtil.getText("ROOM", "EXIT_IN_GAME_MSG"), 
                    hasCloseButton = false,
                    callback = function (type)
                        if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                            bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.CHOOSE_NOR_VIEW)
                            nk.userData.DEFAULT_TAB = 1

                            if self.scene and self.scene.doBackToHall then
                                --todo
                                nk.server:logoutRoom()
                                self.scene:doBackToHall()
                            end
                            
                        end
                    end
                }):show()
            else
                bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.CHOOSE_NOR_VIEW)
                nk.userData.DEFAULT_TAB = 1

                if self.scene and self.scene.doBackToHall then
                    --todo
                    nk.server:logoutRoom()
                    self.scene:doBackToHall()
                end
            end
        end,

        ["gochsnorroom"] = function()
            -- body
            if self.model:isSelfInGame() and self.model:hasCardActive() then
                --todo
                nk.ui.Dialog.new({
                    messageText = bm.LangUtil.getText("ROOM", "EXIT_IN_GAME_MSG"), 
                    hasCloseButton = false,
                    callback = function (type)
                        if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                            -- nk.userData.DEFAULT_TAB = 1
                            bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.CHOOSE_NOR_VIEW)
                            nk.userData.DEFAULT_TAB = 1

                            if self.scene and self.scene.doBackToHall then
                                --todo
                                nk.server:logoutRoom()
                                self.scene:doBackToHall(nil, "gochsnorroom")
                            end

                            -- local runningScene = nk.runningScene
                            -- runningScene.controller_.view_.topTabBar_:gotoTab(1, true)
                        end
                    end
                }):show()
            else
                -- nk.userData.DEFAULT_TAB = 1
                bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.CHOOSE_NOR_VIEW)
                nk.userData.DEFAULT_TAB = 1

                if self.scene and self.scene.doBackToHall then
                    --todo
                    nk.server:logoutRoom()
                    self.scene:doBackToHall(nil, "gochsnorroom")
                end

                -- local runningScene = nk.runningScene
                -- runningScene.controller_.view_.topTabBar_:gotoTab(1, true)
            end
        end,

        ["fillawrdaddr"] = function()
            -- body
            if self.model:isSelfInGame() and self.model:hasCardActive() then
                --todo
                nk.ui.Dialog.new({
                    messageText = bm.LangUtil.getText("ROOM", "EXIT_IN_GAME_MSG"), 
                    hasCloseButton = false,
                    callback = function (type)
                        if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                            bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.MAIN_HALL_VIEW)

                            if self.scene and self.scene.doBackToHall then
                                --todo
                                nk.server:logoutRoom()
                                self.scene:doBackToHall(nil, "fillawrdaddr")
                            end
                            
                            -- local isPopFillAdress = true
                            -- local runningScene = nk.runningScene
                            -- runningScene.controller_.view_:onScoreMarketBtnClicked(isPopFillAdress)
                        end
                    end
                }):show()
            else
                bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.MAIN_HALL_VIEW)

                if self.scene and self.scene.doBackToHall then
                    --todo
                    nk.server:logoutRoom()
                    self.scene:doBackToHall(nil, "fillawrdaddr")
                end

                -- local isPopFillAdress = true
                -- local runningScene = nk.runningScene
                -- runningScene.controller_.view_:onScoreMarketBtnClicked(isPopFillAdress)
            end
        end

        -- ["matchlastpage"] = function()
        --     -- body
        --     if self.model:isSelfInGame() and self.model:hasCardActive() then
        --         --todo
        --         nk.ui.Dialog.new({
        --             messageText = bm.LangUtil.getText("ROOM", "EXIT_IN_GAME_MSG"), 
        --             hasCloseButton = false,
        --             callback = function (type)
        --                 if type == nk.ui.Dialog.SECOND_BTN_CLICK then
        --                     bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.CHOOSE_MATCH_NOR_VIEW)  -- 跳转比赛选场
                            
        --                     nk.server:logoutRoom()
        --                     self.scene:doBackToHall()

        --                     local runningScene = nk.runningScene
        --                     runningScene.controller_.view_.matchList_:gotoPage()
        --                 end
        --             end
        --         }):show()
        --     else
        --         bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.CHOOSE_MATCH_NOR_VIEW)  -- 跳转比赛选场
                
        --         nk.server:logoutRoom()
        --         self.scene:doBackToHall()

        --         local runningScene = nk.runningScene
        --         runningScene.controller_.view_matchList_:gotoPage()
        --     end
        -- end
    }

    if self.exButton_ then
        --todo
        self.exButton_:setButtonEnabled(false)
    end
    
    if self.broadcastJumpAction_ and doJumpActionByTag[self.broadcastJumpAction_] then
        --todo
        doJumpActionByTag[self.broadcastJumpAction_]()
    else
        dump("wrong actionType!")
    end   
end

function RoomController:reset()
    self.hasReset_ = true
    if self.model:isChangeDealer() then
        self.animManager:moveDealerTo(10, true)
    end
    
    self.model:reset()
    self.dealCardManager:reset()
    self.chipManager:reset()
    self.seatManager:reset()

    self.lampManager:hide()

    self.schedulerPool:clearAll()
    self.gameSchedulerPool:clearAll()
end


function RoomController:checkMoneyChange(money)

    --检测破产,记录历史钱数
    if not self.roomGlobalMoney_ then
        -- dump(money,"RoomCheckMoneyChange首次赋值,money:")
        self.roomGlobalMoney_ = money
    else
        -- dump(nk.userData.bankruptcyGrant,"checkMoneyChange.bankruptcyGrant")
        -- dump(self.roomGlobalMoney_,"checkMoneyChange.roomGlobalMoney_")
        -- dump(money,"checkMoneyChange.money")
        if nk.userData.bankruptcyGrant and (self.roomGlobalMoney_ > nk.userData.bankruptcyGrant.maxBmoney and money < nk.userData.bankruptcyGrant.maxBmoney) then
            -- dump("money:" .. money .. " oldMoney:" .. self.roomGlobalMoney_,"RoomCheckMoneyChange破产上报,money:")
            self.roomGlobalMoney_ = money

            if self.model and self.model.roomInfo then
                local roomFiled = bm.LangUtil.getText("HALL", "ROOM_LEVEL_TEXT")[math.floor((self.model.roomInfo.roomType - 101) / 6) + 1]
                --符合破产条件上报
                local otherStr = bm.LangUtil.getText("COMMON", "OTHER")
                nk.http.reportBankrupt(self.model.roomInfo.blind,roomFiled or otherStr or "")
            end
        elseif nk.userData.bankruptcyGrant and (money > nk.userData.bankruptcyGrant.maxBmoney) then
            self.roomGlobalMoney_ = money
            -- dump(money,"RoomCheckMoneyChange非破产,money:")
        end
        
    end
end


function RoomController:bindDataObservers_()
    self.maxDiscountObserver_ = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "__user_discount", function(discount)
        self.scene:setStoreDiscount(discount)
    end)
end

function RoomController:unbindDataObservers_()
    bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "__user_discount", self.maxDiscountObserver_)
end
function RoomController:setOverStandUp()
    self.isOverStandUp = true;--本局结束后站起
end

return RoomController