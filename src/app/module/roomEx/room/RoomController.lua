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
local OperationManager = import(".OperationManagerDelegation")
local BetChipView = import(".views.BetChipView")
local UserCrash = import("app.module.room.userCrash.UserCrash")
local StorePopup = import("app.module.newstore.StorePopup")
local UpgradePopup = import("app.module.upgrade.UpgradePopup")
local PayGuide = import("app.module.room.purchGuide.PayGuide")
local FirChargePayGuidePopup = import("app.module.newstore.firChrgGuide.FirChrgPayGuidePopup")
local AgnChargePayGuidePopup = import("app.module.newstore.agnChrgGuide.AgnChrgPayGuidePopup")
local AnimationDownNum = import("app.module.common.views.AnimationDownNum")

local RoomController = class("RoomController")
local logger = bm.Logger.new("RoomController")

RoomController.EVT_PACKET_RECEIVED = nk.server.EVT_PACKET_RECEIVED

local PACKET_PROC_FRAME_INTERVAL = 2

function RoomController:ctor(scene)
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()

    local ctx = {}
    ctx.RoomController = self
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
        [P.SVR_LOGIN_GRAB_ROOM_OK] = handler(self, RoomController.SVR_LOGIN_ROOM_OK),
        [P.SVR_GRAB_ROOM_GAME_START] = handler(self,RoomController.SVR_GRAB_ROOM_GAME_START),
        [P.SVR_REQUEST_GRAB_DEALER_RESULT] = handler(self,RoomController.SVR_REQUEST_GRAB_DEALER_RESULT),
        [P.SVR_BROADCAST_RE_GRAB_DEALER_USER] = handler(self,RoomController.SVR_BROADCAST_RE_GRAB_DEALER_USER),
        [P.SVR_BROADCAST_GRAB_PLAYER]   = handler(self,RoomController.SVR_BROADCAST_GRAB_PLAYER),
        [P.SVR_BROADCAST_CAN_GRAB_DEALER] = handler(self,RoomController.SVR_BROADCAST_CAN_GRAB_DEALER),
        [P.SVR_EXIT_DELAER_FAIL] = handler(self,RoomController.SVR_EXIT_DELAER_FAIL),
        [P.SVR_WARRING_DEALER_ADD_COIN] = handler(self,RoomController.SVR_WARRING_DEALER_ADD_COIN),
        [P.SVR_PLAYER_ADD_COIN_RESULT] = handler(self,RoomController.SVR_PLAYER_ADD_COIN_RESULT),
        [P.SVR_DEALER_SITDOWN_FAIL] = handler(self,RoomController.SVR_DEALER_SITDOWN_FAIL),
        [P.SVR_SUONA_BROADCAST] = handler(self, RoomController.SVR_SUONA_BROADCAST_RECV),  -- 房间内小喇叭广播
        [P.SVR_PUSH_MATCH_ROOM] = handler(self, RoomController.SVR_PUSH_MATCH_ROOM),
        [P.SVR_LOGIN_NEW_ROOM_OK] = handler(self, RoomController.SVR_LOGIN_ROOM_OK),
        [P.SVR_LOGIN_OK_RE_CONECT] = handler(self,RoomController.SVR_LOGIN_OK_RE_CONECT)
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
    -- local data = pack
    -- if data.tid > 0 then
    --     -- 重连房间
    --     self.tid__ = data.tid
    --     nk.server:loginRoom(self.tid__)
    -- else
    --     self.scene:doBackToHall()
    -- end
end
function RoomController:SVR_LOGIN_OK_RE_CONECT(pack)
    -- body
    if pack.tid <= 0 then
        self.scene:doBackToHall()
        return
    end
    nk.server:loginGrabDealerRoom(pack.tid)
end
function RoomController:SVR_LOGIN_ROOM_OK(pack)   
    -- dump(pack,"RoomController:SVR_LOGIN_ROOM_OK :=====================")
    local ctx = self.ctx
    local model = self.model

    if self.roomLoading_ then
        self.roomLoading_:removeFromParent()
        self.roomLoading_ = nil
    end

    self:reset()

    --登录成功
    model:initWithLoginSuccessPack(pack)

    local roomData = nk.getRoomDataByLevel(self.model.roomInfo.roomType)

    ctx.oprManager:init(roomData.isAllIn)
    self.scene:isOffSlot(roomData.isAllIn)

    self.scene:removeLoading()

    --显示房间信息
    self.scene:setRoomInfoText(model.roomInfo)
    --老虎机盲注
    self.scene:setSlotBlind(model.roomInfo)
    local showGrabBtn = true
     for i = 0, 9 do
        local player = model.playerList[i]
        if player and player.seatId == 9 and player.uid >1 then
            showGrabBtn = false
        end
    end
    if showGrabBtn == true then
        self.scene:showGrabDealerBtn({errno = 0})
        self.dealerManager:showDealer()
        self.seatManager:setDealerSeat(false)
    else
        self.scene:showGrabDealerBtn({errno = 1})
        self.dealerManager:hideDealer()
        self.seatManager:setDealerSeat(true)
    end
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

    --设置抢庄倒计时
    self.scene:setGrabLeftTime(pack.grabDealerLeftTime)
    --进场，只要庄家位上无人，即可抢庄
    --相反，如果庄家位置有人，且自己是庄家，则显示补币按钮
    -- uid=1为系统庄家
    
    
    if model:isSelfInSeat() and model:selfSeatId() == 9 then
        self.scene:showDealerAddCoinBtn(true)
    end

    if self.model.roomInfo.rmType == consts.ROOM_TYPE_EX.GRAB_CASH then
        local tablePlayerNum = model:getNumInSeat()
        if tablePlayerNum <=5 then
            --self.scene:setMatchInviteButtonVisible(true)
        end
    end
end

function RoomController:SVR_LOGIN_ROOM_FAIL(pack)
    dump(pack,"SVR_LOGIN_ROOM_FAIL")
end

function RoomController:SVR_LOGOUT_ROOM_OK(pack)
    --self.scene:doBackToHall()

    -- dump("RoomController:SVR_LOGOUT_ROOM_OK.pack :==================")
    if self.scene and self.scene.logoutRoomOk then
        --todo
        self.scene:logoutRoomOk(self.backHallAction_)
    end
end

function RoomController:SVR_SEAT_DOWN(pack)
    -- dump(pack,"SVR_SEAT_DOWN")
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
    end
    if model:selfSeatId() == seatId and seatId ~= 9 then
        --把自己的座位转到中间去
        ctx.seatManager:rotateSelfSeatToCenter(seatId, true)
       
    else        
        --更新座位信息
        ctx.seatManager:updateSeatState(seatId)       
    end

    if seatId == 9 then -- 强制更新
        ctx.seatManager:updateSeatState(seatId)
        self.scene:setGrabLeftTime(0)
        self.scene:setGrabAdvanceStop()
        

        local player = model.playerList[9]
        if checkint(player.uid) ~= 1 then
            self.seatManager:setDealerSeat(true)
            self.dealerManager:hideDealer()
            self.scene:showGrabDealerBtn({errno = 1})--关闭抢庄按钮
        else
            self.seatManager:setDealerSeat(false)
            self.dealerManager:showDealer()
            self.scene:showGrabDealerBtn({errno = 0})--开启抢庄按钮
        end
    end
    --自己是庄家，开启庄家位补币按钮
    if model:selfSeatId() == seatId and seatId == 9 then
        self.scene:showDealerAddCoinBtn(true)
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
    -- dump(pack, "RoomController.SVR_DEAL :=====================")
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
            local findEmptySeat = nk.OnOff:check("findEmptySeat")
            if(findEmptySeat and self.checkIngEmptySeat) then
                self:applyAutoSitDown()
                return
            end
        elseif errorCode == Q.CHIPS_LIMIT then
            msg = "จำนวนชิปของคุณเยอะเกินไป กรุณาไปห้องเดิมพันสูงกว่านี้ "--M["CHIPS_LIMIT"]
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
        nk.TopTipManager:showTopTip(T("站起失败,您处于庄家5局保护期内，请继续游戏"))
        return
    end
    dump(pack,"SVR_STAND_UP")
    local ctx = self.ctx
    local model = self.model
    local seatId,isIgnore = model:processStandUp(pack,false)
    -- if isIgnore then
    --     return
    -- end
    local positionId = ctx.seatManager:getSeatPositionId(seatId) 
    --更新全部座位状态，没人的座位会显示
    ctx.seatManager:updateAllSeatState()
    --把转动过的座位还原
    if seatId ~= 9 then
        ctx.seatManager:rotateSeatToOrdinal()
    end 
    --动画隐藏操作栏
    ctx.oprManager:hideOperationButtons(true)
    
    --如果当前座位正在计时，强制停止
    ctx.seatManager:stopCounterOnSeat(seatId)

    self:updateChangeRoomButtonMode() 
    ctx.chipManager:clearChip(seatId) 

    self.scene:showDealerAddCoinBtn(false)
    if isIgnore then
        return
    end  

    self:processBankrupt(1,true) 
    self:processBestMaxMoney()
    --庄家位站起，开启抢庄
    if seatId == 9 then
        self.scene:showGrabDealerBtn({errno = 0})

        self.seatManager:setDealerSeat(false)
        self.dealerManager:showDealer()
    end  

    
    ctx.seatManager:playStandUpAnimation(seatId, function() 
        ctx.seatManager:updateSeatState(seatId)
    end)

    --干掉已经发的手牌
    self.dealCardManager:hideDealedCard(positionId)
    bm.EventCenter:dispatchEvent({name=nk.eventNames.UPDATE_SEAT_INVITE_VIEW, data={ctx = self.ctx,standUpSeatId = seatId}})
end

function RoomController:SVR_OTHER_STAND_UP(pack)
    local ctx = self.ctx
    local model = self.model

    --站起
    local selfSeatId = model:selfSeatId()
    local seatId,isIgnore = model:processStandUp(pack,true)
    if isIgnore then
        return
    end
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

    --庄家位站起，开启抢庄
    if seatId == 9 then
        self.scene:showGrabDealerBtn({errno = 0})
        self.scene:showDealerAddCoinBtn(false)
    end
    

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
function RoomController:SVR_BROADCAST_RE_GRAB_DEALER_USER(pack)
    self.scene:setGrabLeftTime(tonumber(pack.lefttime))
end
function RoomController:SVR_BROADCAST_GRAB_PLAYER(pack)
    local model = self.model
    model:processGrabAdvance(pack)
    self.scene:setGrabPlayerData(pack)
end
function RoomController:SVR_BROADCAST_CAN_GRAB_DEALER(pack)
    local ctx = self.ctx
    local model = self.model
    --庄家位不参与抢庄
    if pack.errno==0 and model:selfSeatId() == 9 then
        return
    end 
    self.scene:showGrabDealerBtn(pack)
end
function RoomController:SVR_EXIT_DELAER_FAIL(pack)
    -- dump(pack, "RoomController:SVR_EXIT_DELAER_FAIL.pack :=================")
    nk.TopTipManager:showTopTip(T("玩牌至少五局"))
end
function RoomController:SVR_WARRING_DEALER_ADD_COIN(pack)
    local ctx = self.ctx
    local model = self.model
    local addCoin = model:processSvrAddvanceDealer(pack)
    local str = T("您金币太少，需要补充金币!需要金币:")..addCoin
    nk.TopTipManager:showTopTip(str)
end
function RoomController:SVR_PLAYER_ADD_COIN_RESULT(pack)
    if pack.errno == 0 then
        --nk.TopTipManager:showTopTip(T("庄家补币成功"))
        local ctx = self.ctx
        local model = self.model
        model:processDealerAddCoin(pack)
        ctx.seatManager:addDealerHandCoin(tonumber(pack.dealerHandCoin))
        self.scene:dealerAddCoin(pack)
    else
         nk.TopTipManager:showTopTip(T("补币失败"))
    end
end
function RoomController:SVR_DEALER_SITDOWN_FAIL(pack)
    nk.TopTipManager:showTopTip(T("上庄失败"))
end
function RoomController:SVR_GRAB_ROOM_GAME_START(pack)
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
--server回复抢庄结果
function RoomController:SVR_REQUEST_GRAB_DEALER_RESULT(pack)
    if tonumber(pack.errno) == 0 then 
        nk.TopTipManager:showTopTip(T("抢庄请求成功"))
    else
        local errorString = T("未知错误")..pack.errno
        if pack.errno == 300 then
            errorString = T("上庄失败，已被其他人优先上庄")
        elseif pack.errno == 301 then
            errorString = T("携带金币不足")
        elseif pack.errno == 302 then
            errorString = T("携带金币不足")
        elseif pack.errno == 303 then
            errorString = T("携带值不在你的当前资产范围")
        elseif pack.errno == 304 then
            errorString = T("您已经请求上庄")
        elseif pack.errno == 305 then
            errorString = T("您就是庄家")
        end
        nk.TopTipManager:showTopTip(errorString)
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
        model:deal2CardsToAllTablePlayer()
        ctx.seatManager:prepareDealCards()   
        ctx.dealCardManager:dealCards()   
    end
end



function RoomController:SVR_SEARCH_PERSONAL_ROOM(pack)
    self.scene:onSearchPersonalRoom(pack)
end


--发送房间内广播
function RoomController:SVR_ROOM_BROADCAST(pack)
    -- dump(pack,"RoomController:SVR_ROOM_BROADCAST==========发送房间内广播")
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
        local minusChips = 0 --是否需要扣费 test/ 询问扣费动画.
        if seatId then
            self.animManager:playExpression(seatId, faceId)
            if isSelf and minusChips > 0 then
                --是自己并且有扣钱，播放扣钱动画
                self.animManager:playChipsChangeAnimation(seatId, -minusChips)
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
        local toSeatId = 11 
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


function RoomController:SVR_PUSH_MATCH_ROOM(pack)
    -- body
    local leftTime = pack.leftTime
    if leftTime<=2 then  return end
    local tipDialog = nk.ui.Dialog.new({
            messageText = T("距离比赛开始还剩: ").."\n\n\n",--bm.LangUtil.getText("ROOM", "STAND_UP_IN_GAME_MSG"), 
            hasCloseButton = false,
            secondBtnText = T("立即参赛"),
            callback = function (type)
                if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                    bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, 2)
                    bm.DataProxy:setData(nk.dataKeys.TO_MATCH_DATA, pack)

                    nk.server:logoutRoom()
                    -- self.scene:doBackToHall()
                end
            end,
        }):show()

      self.animationDownNum_ = AnimationDownNum.new({parent = tipDialog, time = leftTime - 2, 
        scale = 0.5, refreshCallback = function(retVal)
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

function RoomController:SVR_COMMON_BROADCAST(pack)
    local mtype = pack.mtype
    if mtype == 2 then
        local inviteData = json.decode(pack.info)
        local inviteName_ = inviteData.name;
        local tid = inviteData.tid;
        local content_ = bm.LangUtil.getText("HALL","PERSONAL_ROOM_INVITE_CONTENT",inviteName_);
        nk.TopTipManager:showTopTip(content_)
        nk.userData["inviteRoomData"] = {tid = tid, time = os.time(),inviteName = inviteName_}
        -- dump(inviteName_,"ddddd")
        -- dump(tid,"tidddd")
    end
end

function RoomController:SVR_GAME_OVER(pack)
    local ctx = self.ctx
    local model = self.model
    self.gameSchedulerPool:clearAll()
    model:processGameOver(pack)
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


    --local isBankrup = self:processBankrupt(0,false);
    if not isBankrup and (self.model:isSelfInSeat())then
        self:processUpgrade(chipDelayTime+4)
    end

    self:processNextLevelRoom()

    -- 刷新游戏状态
    self.schedulerPool:delayCall(handler(self, self.reset), resetDelayTime)

    if self.isOverStandUp and self.isOverStandUp == true then
        if self.ctx.model:isSelfInSeat() then
            nk.server:standUp()
        end
    end
    self.isOverStandUp = false

    self.scene:updataGrabAdvance()
    
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
end

function RoomController:processNextLevelRoom()
    
    local selfSeatData = self.model:selfSeatData()
    local roomData = nk.getRoomDataByLevel(self.model.roomInfo.roomType)
    if (not roomData) or (not selfSeatData) then
        return
    end

    local trunMoney = checkint(selfSeatData.trunMoney) 
    local nextMoney = checkint(roomData.roomGroupNext)
    if  (trunMoney > 0) and (nextMoney > 0) and (nk.userData["aUser.money"] > nextMoney) then
        --每天每个场次只提示一次
        local jsonStr = nk.userDefault:getStringForKey(nk.cookieKeys.DALIY_ROOM_GO_TIP)
        local jsonObj = json.decode(jsonStr)
        if not jsonObj then
            jsonObj = {}
        end

        local date =jsonObj.date or os.date("%Y%m%d")
        local tagTb = jsonObj.tagTb or {}
        local roomType = self.model.roomInfo.roomType

        if date ~= os.date("%Y%m%d") then
            date = os.date("%Y%m%d")
            tagTb = {}
        end

        --如果已经记录，则表明发过升场提示
        if tagTb[("r_" .. roomType)] then
            return
        end

        tagTb[("r_" .. roomType)] = 1
        jsonObj.date = date
        jsonObj.tagTb = tagTb
        local saveStr = json.encode(jsonObj)
        if not saveStr then
            return
        end
        nk.userDefault:setStringForKey(nk.cookieKeys.DALIY_ROOM_GO_TIP, saveStr) 
    
        local desRoomLev,desRoomData = nk.getGuideChipRoomLevelByMoney(nk.userData["aUser.money"])
        if desRoomLev and desRoomData and  desRoomData[2] then
            local baseChip = desRoomData[2]
            bm.EventCenter:dispatchEvent({name = nk.eventNames.SEND_DEALER_CHIP_BUBBLE_VIEW, text = bm.LangUtil.getText("HALL", "GUIDE_ROOM_TIP",baseChip),type = 2})
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

    --现金币场独立检测
    if self.model.roomInfo.rmType == consts.ROOM_TYPE_EX.GRAB_CASH then
        if nk.userData["match.point"] < self.model.roomInfo.minBuyIn then
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

    local isBankrup = false

    if nk.userData["aUser.money"] >= self.model.roomInfo.enterLimit then
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
            --dump("entering--------------","")
            local userCrash = UserCrash.new(0,0,0,0,true,true)
            userCrash:show()

        else
            if nk.userData.bankruptcyGrant.bankruptcyTimes < nk.userData.bankruptcyGrant.num then
                isBankrup = true

                if showView then
                    local isShowPay = nk.OnOff:check("payGuide")
                    local isPay = nk.userData.best.paylog == 1 or false
                    -- local isAlmChargeFavPay = nk.userData.bagPayList and nk.userData.bagPayList.almRechgFav == 1 or false

                    local showBankruptScene = 3

                    if delay and delay > 0 then
                        --todo
                        self.schedulerPool:delayCall(function()
                                -- body

                            if nk.userData.bankruptcyGrant.bankruptcyTimes == 0 then
                                --todo
                                local isThirdPayOpen = isShowPay
                                local isFirstCharge = not isPay

                                if nk.OnOff:check("firstchargeFavGray") and isThirdPayOpen and isFirstCharge then
                                    --todo
                                   FirChargePayGuidePopup.new(0):showPanel(0, nil, true)
                                else

                                    local rechargeFavAccess = nk.userData.bagPayList and nk.userData.bagPayList.access == 1 or false
                                    if nk.OnOff:check("rechargeFavGray") and isThirdPayOpen and isPay and rechargeFavAccess then
                                        --todo
                                        AgnChargePayGuidePopup.new():showPanel(0, nil, true)
                                    else
                                        -- 这里要取到当前要进的房间类型信息 --
                                        local payBillType = nil
                                        if roomData then
                                            --todo
                                            payBillType = roomData.roomGroup
                                        end

                                        -- end --
                                        local params = {}

                                        params.isOpenThrPartyPay = isThirdPayOpen
                                        params.isFirstCharge = isFirstCharge
                                        params.sceneType = showBankruptScene
                                        params.payListType = payBillType

                                        PayGuide.new(params):show(0, nil, true)
                                    end
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

                        end, delay)
                    else

                        if nk.userData.bankruptcyGrant.bankruptcyTimes == 0 then
                            --todo
                            local isThirdPayOpen = isShowPay
                            local isFirstCharge = not isPay

                            if nk.OnOff:check("firstchargeFavGray") and isThirdPayOpen and isFirstCharge then
                                --todo
                               FirChargePayGuidePopup.new(0):showPanel(0, nil, true)
                            else

                                local rechargeFavAccess = nk.userData.bagPayList and nk.userData.bagPayList.access == 1 or false
                                if nk.OnOff:check("rechargeFavGray") and isThirdPayOpen and isPay and rechargeFavAccess then
                                    --todo
                                    AgnChargePayGuidePopup.new():showPanel(0, nil, true)
                                else
                                    -- 这里要取到当前要进的房间类型信息 --
                                    local payBillType = nil
                                    if roomData then
                                        --todo
                                        payBillType = roomData.roomGroup
                                    end
                                    -- end --
                                    local params = {}

                                    params.isOpenThrPartyPay = isThirdPayOpen
                                    params.isFirstCharge = isFirstCharge
                                    params.sceneType = showBankruptScene
                                    params.payListType = payBillType

                                    PayGuide.new(params):show(0, nil, true)
                                end
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
                    
                    if self.model and self.model.roomInfo then

                        -- dump(self.model.roomInfo, "======================")
                        --破产上报
                        local roomFiled = bm.LangUtil.getText("HALL", "ROOM_LEVEL_TEXT")[math.floor((self.model.roomInfo.roomType - 101) / 6) + 1]
                        nk.http.reportBankrupt(self.model.roomInfo.blind,roomFiled)
                    end
                    --]]
                end
            else

                 if nk.userData["aUser.bankMoney"] >= nk.userData.bankruptcyGrant.maxsafebox then
                    --保险箱的钱大于设定值，引导保险箱取钱
                    local userCrash = UserCrash.new(0,0,0,0,true,true)
                    userCrash:show()

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
        end

    else
        --todo
        if nk.userData["aUser.money"] < self.model.roomInfo.enterLimit then
            --todo
            if showView then
                local isShowPay = nk.OnOff:check("payGuide")
                local isPay = nk.userData.best.paylog == 1 or false
                -- local isAlmChargeFavPay = nk.userData.bagPayList and nk.userData.bagPayList.almRechgFav == 1 or false

                local chipNotEnoughScene = 2

                if delay and delay > 0 then
                    --todo
                    self.schedulerPool:delayCall(function()
                        -- body
                        local isThirdPayOpen = isShowPay
                        local isFirstCharge = not isPay

                        if nk.OnOff:check("firstchargeFavGray") and isThirdPayOpen and isFirstCharge then
                            --todo
                           FirChargePayGuidePopup.new(2):showPanel(1, self.scene.onChangeRoomClick_, true)
                        else
                            local rechargeFavAccess = nk.userData.bagPayList and nk.userData.bagPayList.access == 1 or false
                            if nk.OnOff:check("rechargeFavGray") and isThirdPayOpen and isPay and rechargeFavAccess then
                                --todo
                                AgnChargePayGuidePopup.new():showPanel(chipNotEnoughScene, self.scene.onChangeRoomClick_, true)
                            else
                                local payBillType = nil

                                if roomData then
                                    --todo
                                    payBillType = roomData.roomGroup
                                end

                                local params = {}

                                params.isOpenThrPartyPay = isThirdPayOpen
                                params.isFirstCharge = isFirstCharge
                                params.sceneType = chipNotEnoughScene

                                -- 取得当前房间的类型 1：初级场， 2：普通场， 3：高级场
                                params.payListType = payBillType

                                PayGuide.new(params):show(1, self.scene.onChangeRoomClick_, true)
                            end
                        end

                        -- PayGuide.new(not isPay, chipNotEnoughScene):show(1)
                    end, delay)
                else

                    local isThirdPayOpen = isShowPay
                    local isFirstCharge = not isPay

                    if nk.OnOff:check("firstchargeFavGray") and isThirdPayOpen and isFirstCharge then
                        --todo
                       FirChargePayGuidePopup.new(2):showPanel(1, self.scene.onChangeRoomClick_, true)
                    else
                        local rechargeFavAccess = nk.userData.bagPayList and nk.userData.bagPayList.access == 1 or false
                        if nk.OnOff:check("rechargeFavGray") and isThirdPayOpen and isPay and rechargeFavAccess then
                            --todo
                            AgnChargePayGuidePopup.new():showPanel(chipNotEnoughScene, self.scene.onChangeRoomClick_, true)
                        else
                            local payBillType = nil

                            if roomData then
                                --todo
                                payBillType = roomData.roomGroup
                            end
                            
                            local params = {}

                            params.isOpenThrPartyPay = isThirdPayOpen
                            params.isFirstCharge = isFirstCharge
                            params.sceneType = chipNotEnoughScene

                            -- 取得当前房间的类型 1：初级场， 2：普通场， 3：高级场
                            params.payListType = payBillType

                            PayGuide.new(params):show(1, self.scene.onChangeRoomClick_, true)
                        end
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
    if not self.model:isSelfInSeat() then
        local emptySeatId = self.seatManager:getEmptySeatId()
        local myMoney = nk.userData['aUser.money']
        local isCash = 0
        if self.model.roomInfo.rmType == consts.ROOM_TYPE_EX.GRAB_CASH then
            myMoney = nk.userData['match.point']
            isCash = 1
        end
        if emptySeatId then
            local isAutoSit = nk.userDefault:getBoolForKey(nk.cookieKeys.AUTO_SIT, true)
            if isAutoSit or nk.server:isPlayNow() then
                self.checkIngEmptySeat = true;
                local userData = nk.userData
                if myMoney >= self.model.roomInfo.enterLimit then
                    logger:debug("auto sit down", emptySeatId)
                    local isAutoBuyin = nk.userDefault:getBoolForKey(nk.cookieKeys.AUTO_BUY_IN, true)
                    if isCash == 1 then
                        nk.server:seatDown(emptySeatId,myMoney, isAutoBuyin) 
                    else
                        nk.server:seatDown(emptySeatId, myMoney, isAutoBuyin)
                       -- nk.server:seatDown(emptySeatId, math.min(myMoney, self.model.roomInfo.defaultBuyIn), isAutoBuyin)                  
                    end
                else
                    --这里可能scene还未切换完成，等待1S再弹对话框
                    local message = bm.LangUtil.getText("COMMON", "NOT_ENOUGH_MONEY_TO_PLAY_NOW_MSG", self.model.roomInfo.enterLimit)
                    if isCash == 1 then
                        message =bm.LangUtil.getText("COMMON", "NOT_ENOUGH_CASH_TO_PLAY_NOW_MSG", self.model.roomInfo.enterLimit)
                    end
                    if myMoney < userData.bankruptcyGrant.maxBmoney then
                        self.sceneSchedulerPool:delayCall(function()
                            nk.ui.Dialog.new({
                                messageText = message, 
                                hasCloseButton = false,
                                callback = function (type)
                                    if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                                        if isCash == 1 then
                                            StorePopup.new(2):showPanel()
                                        end
                                    end
                                end
                            }):show()
                        end, 1)
                    else
                        self.sceneSchedulerPool:delayCall(function()
                            nk.ui.Dialog.new({
                                hasCloseButton = true,
                                hasFirstButton = false,
                                messageText = bm.LangUtil.getText("ROOM", "SIT_DOWN_NOT_ENOUGH_MONEY"), 
                                --firstBtnText = bm.LangUtil.getText("ROOM", "AUTO_CHANGE_ROOM"),
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
                nk.ui.Dialog.new({
                    messageText = bm.LangUtil.getText("ROOM", "EXIT_IN_GAME_MSG"), 
                    hasCloseButton = false,
                    callback = function (type)
                        if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                            bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.CHOOSE_MATCH_NOR_VIEW)
                            nk.server:logoutRoom()
                           -- self:doBackToHall()
                        end
                    end
                }):show()
            else
                bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.CHOOSE_MATCH_NOR_VIEW)             
                nk.server:logoutRoom()
               -- self:doBackToHall()
            end
        end,

        ["shoplist"] = function()
            -- body

            if self.scene then
                --todo
                local isShowPay = nk.OnOff:check("payGuide")
                local isPay = nk.userData.best and nk.userData.best.paylog == 1 or false
                -- local isAlmChargeFavPay = nk.userData.bagPayList and nk.userData.bagPayList.almRechgFav == 1 or false

                if isShowPay and not isPay then
                    --todo

                    if self.scene.onChargeFavClick_ then
                        --todo
                        self.scene:onChargeFavClick_(1)
                    end
                else
                    local rechargeFavAccess = nk.userData.bagPayList and nk.userData.bagPayList.access == 1 or false
                    if nk.OnOff:check("rechargeFavGray") and isShowPay and isPay and rechargeFavAccess then
                        --todo
                        if self.scene.onAlmRechargeFavClick_ then
                            --todo
                            self.scene:onAlmRechargeFavClick_()
                        end
                    else
                        if self.scene.onShopClick_ then
                            --todo
                            self.scene:onShopClick_(1)
                        end
                    end
                    
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
            self.backHallAction_ = "activitycenter"
            if self.model:isSelfInGame() and self.model:hasCardActive() then
                nk.ui.Dialog.new({
                    messageText = bm.LangUtil.getText("ROOM", "EXIT_IN_GAME_MSG"), 
                    hasCloseButton = false,
                    callback = function (type)
                        if type == nk.ui.Dialog.SECOND_BTN_CLICK then

                            bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.MAIN_HALL_VIEW)
                            nk.server:logoutRoom()
                           -- self:doBackToHall()
                        end
                    end
                }):show()
            else
                bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.MAIN_HALL_VIEW)             
                nk.server:logoutRoom()
               -- self:doBackToHall()
            end
        end,

        ["freechips"] = function()
            -- body
            self.backHallAction_ = "freechips"
            if self.model:isSelfInGame() and self.model:hasCardActive() then
                nk.ui.Dialog.new({
                    messageText = bm.LangUtil.getText("ROOM", "EXIT_IN_GAME_MSG"), 
                    hasCloseButton = false,
                    callback = function (type)
                        if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                            
                            bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.MAIN_HALL_VIEW)
                            nk.server:logoutRoom()
                           -- self:doBackToHall()
                        end
                    end
                }):show()
            else
                bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.MAIN_HALL_VIEW)             
                nk.server:logoutRoom()
               -- self:doBackToHall()
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
            -- self.backHallAction_ = "freechips"
            if self.model:isSelfInGame() and self.model:hasCardActive() then
                nk.ui.Dialog.new({
                    messageText = bm.LangUtil.getText("ROOM", "EXIT_IN_GAME_MSG"), 
                    hasCloseButton = false,
                    callback = function (type)
                        if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                            
                            bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.CHOOSE_NOR_VIEW)
                            nk.userData.DEFAULT_TAB = 2

                            nk.server:logoutRoom()
                           -- self:doBackToHall()
                        end
                    end
                }):show()
            else
                bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.CHOOSE_NOR_VIEW)
                nk.userData.DEFAULT_TAB = 2

                nk.server:logoutRoom()
               -- self:doBackToHall()
            end
        end,

        ["gochsnorroom"] = function()
            -- body
            self.backHallAction_ = "gochsnorroom"
            if self.model:isSelfInGame() and self.model:hasCardActive() then
                nk.ui.Dialog.new({
                    messageText = bm.LangUtil.getText("ROOM", "EXIT_IN_GAME_MSG"), 
                    hasCloseButton = false,
                    callback = function (type)
                        if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                            
                            bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.CHOOSE_NOR_VIEW)
                            nk.userData.DEFAULT_TAB = 1

                            nk.server:logoutRoom()
                           -- self:doBackToHall()
                        end
                    end
                }):show()
            else
                bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.CHOOSE_NOR_VIEW)
                nk.userData.DEFAULT_TAB = 1

                nk.server:logoutRoom()
               -- self:doBackToHall()
            end
        end,

        ["fillawrdaddr"] = function()
            -- body
            self.backHallAction_ = "fillawrdaddr"
            if self.model:isSelfInGame() and self.model:hasCardActive() then
                nk.ui.Dialog.new({
                    messageText = bm.LangUtil.getText("ROOM", "EXIT_IN_GAME_MSG"), 
                    hasCloseButton = false,
                    callback = function (type)
                        if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                            
                            bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.MAIN_HALL_VIEW)
                            nk.server:logoutRoom()
                           -- self:doBackToHall()
                        end
                    end
                }):show()
            else
                bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.MAIN_HALL_VIEW)             
                nk.server:logoutRoom()
               -- self:doBackToHall()
            end
        end
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