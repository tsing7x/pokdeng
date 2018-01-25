--
-- 房间控制器
-- Author: tony
-- Date: 2014-07-08 11:43:07
--

local RoomModel = import(".model.MatchRoomModel")
local SeatManager = import(".MatchSeatManager")
local DealerManager = import(".MatchDealerManager")
local DealCardManager = import(".MatchDealCardManager")
local LampManager = import(".MatchLampManager")
local ChipManager = import(".MatchChipManager")
local AnimManager = import(".MatchAnimManager")
local OperationManager = import(".MatchOperationManager")
local BetChipView = import(".views.MatchBetChipView")
-- local UserCrash = import("app.module.match.matchRoom.userCrash.UserCrash")
local StorePopup = import("app.module.newstore.StorePopup")
local UpgradePopup = import("app.module.upgrade.UpgradePopup")
local MatchGameResultPopup = import("app.module.match.views.MatchGameResultPopup")
local MatchTimeGameResultPopup = import("app.module.match.views.MatchTimeGameResultPopup")
local MatchForceExitTipPopup  = import("app.module.match.views.MatchForceExitTipPopup")

local MatchRoomController = class("MatchRoomController")
local logger = bm.Logger.new("MatchRoomController")

MatchRoomController.EVT_PACKET_RECEIVED = nk.server.EVT_PACKET_RECEIVED

local PACKET_PROC_FRAME_INTERVAL = 2

function MatchRoomController:ctor(scene)
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
        [P.SVR_DOUBLE_LOGIN] = handler(self, MatchRoomController.SVR_DOUBLE_LOGIN),
        [P.SVR_MSG] = handler(self, MatchRoomController.SVR_MSG),
        [P.SVR_OTHER_OFFLINE] = handler(self, MatchRoomController.SVR_OTHER_OFFLINE),

        [P.SVR_ROOM_BROADCAST] = handler(self,MatchRoomController.SVR_ROOM_BROADCAST),
        -- [P.SVR_COMMON_BROADCAST] = handler(self,MatchRoomController.SVR_COMMON_BROADCAST),

        [P.SVR_LOGIN_MATCH_ROOM_OK] = handler(self,MatchRoomController.SVR_LOGIN_MATCH_ROOM_OK),
        [P.SVR_LOGIN_MATCH_ROOM_FAIL] = handler(self,MatchRoomController.SVR_LOGIN_MATCH_ROOM_FAIL),
        [P.SVR_MATCH_SEAT_DOWN] = handler(self,MatchRoomController.SVR_MATCH_SEAT_DOWN),
        [P.SVR_MATCH_GAME_START] = handler(self,MatchRoomController.SVR_MATCH_GAME_START),
        [P.SVR_MATCH_PRE_CALL] = handler(self,MatchRoomController.SVR_MATCH_PRE_CALL),
        [P.SVR_MATCH_POT] = handler(self,MatchRoomController.SVR_MATCH_POT),
        [P.SVR_MATCH_BET] = handler(self,MatchRoomController.SVR_MATCH_BET),
        [P.SVR_MATCH_CARD_NUM] = handler(self,MatchRoomController.SVR_MATCH_CARD_NUM),
        [P.SVR_MATCH_DEAL] = handler(self,MatchRoomController.SVR_MATCH_DEAL),
        [P.SVR_MATCH_TURN_BET] = handler(self,MatchRoomController.SVR_MATCH_TURN_BET),
        [P.SVR_MATCH_CAN_THIRD_CARD] = handler(self,MatchRoomController.SVR_MATCH_CAN_THIRD_CARD),
        [P.SVR_MATCH_OTHER_THIRD_CARD] = handler(self,MatchRoomController.SVR_MATCH_OTHER_THIRD_CARD),
        [P.SVR_MATCH_SHOW_CARD] = handler(self,MatchRoomController.SVR_MATCH_SHOW_CARD),
        [P.SVR_MATCH_GAME_OVER] = handler(self,MatchRoomController.SVR_MATCH_GAME_OVER),
        [P.SVR_MATCH_THIRD_CARD] = handler(self,MatchRoomController.SVR_MATCH_THIRD_CARD),
        [P.SVR_MATCH_COUNT_DOWN] = handler(self,MatchRoomController.SVR_MATCH_COUNT_DOWN),
        [P.SVR_MATCH_KNOCK_OUT] = handler(self,MatchRoomController.SVR_MATCH_KNOCK_OUT),
        [P.SVR_MATCH_QUIT] = handler(self,MatchRoomController.SVR_MATCH_QUIT),
        [P.SVR_MATCH_BROAD_QUIT] = handler(self,MatchRoomController.SVR_MATCH_BROAD_QUIT),
        [P.SVR_LOGIN_OK_NEW] = handler(self,MatchRoomController.SVR_LOGIN_OK_NEW),
        [P.SVR_MATCH_BROAD_RANK] = handler(self,MatchRoomController.SVR_MATCH_BROAD_RANK),
        [P.SVR_MATCH_AI] = handler(self,MatchRoomController.SVR_MATCH_AI),
        [P.SVR_MATCH_CACEL_AI_RESULT] = handler(self,MatchRoomController.SVR_MATCH_CACEL_AI_RESULT),
        [P.SVR_MATCH_LEFT_NUM_FORCE_EXIT_GAME] = handler(self,MatchRoomController.SVR_MATCH_LEFT_NUM_FORCE_EXIT_GAME),
        [P.SVR_MATCH_FORCE_EXIT_GAME_RESULT] = handler(self,MatchRoomController.SVR_MATCH_FORCE_EXIT_GAME_RESULT),

        [P.SVR_SUONA_BROADCAST] = handler(self, MatchRoomController.SVR_SUONA_BROADCAST_RECV),
        [P.SVR_PUSH_CHANGE_MATCH_ROOM] = handler(self,MatchRoomController.SVR_PUSH_CHANGE_MATCH_ROOM),
        [P.SVR_TIME_MATCH_RANK] = handler(self,MatchRoomController.SVR_TIME_MATCH_RANK),
        [P.SVR_PUSH_MATCH_ROOM] = handler(self, MatchRoomController.SVR_PUSH_MATCH_ROOM),
        [P.SVR_TIME_MATCH_OFF] = handler(self, MatchRoomController.SVR_TIME_MATCH_OFF),
        [P.SVR_WAIT_MATCH_GAME] = handler(self,MatchRoomController.SVR_WAIT_MATCH_GAME)
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

function MatchRoomController:dispose()
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
    bm.EventCenter:removeEventListener(self.serverFailListenerId_)

    bm.DataProxy:setData(nk.dataKeys.ROOM_INFO, nil)
end

function MatchRoomController:createNodes()
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

function MatchRoomController:onLoginRoomFail_(evt)
    do return end
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


function MatchRoomController:onServerFail_(evt)    
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

function MatchRoomController:showErrorByDialog_(msg)
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


function MatchRoomController:onServerStop_(evt)
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

function MatchRoomController:onConnected_(evt)
    self.packetCache_ = {}
end

function MatchRoomController:onEnterFrame_(dt)
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
                    if pack.cmd == nk.server.PROTOCOL.SVR_MATCH_KNOCK_OUT or pack.cmd == nk.server.PROTOCOL.SVR_MATCH_SEAT_DOWN then
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

function MatchRoomController:onPacketReceived_(evt)
    dump(string.format("cmd:%x",evt.packet.cmd),"MatchRoomController:onPacketReceived_")
    table.insert(self.packetCache_, evt.packet)
end

function MatchRoomController:SVR_DOUBLE_LOGIN(pack)
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




function MatchRoomController:SVR_MATCH_GAME_START(pack)
    local ctx = self.ctx
    local model = self.model

    if not self.hasReset_ then
        self:reset()
    end
    self.hasReset_ = false
    self.isPreCall_ = false

    --牌局开始
    model:processGameStart(pack)

    --移动庄家指示
    -- ctx.animManager:moveDealerTo(ctx.seatManager:getSeatPositionId(model.gameInfo.dealerSeatId), true)


    --移动说话人指示
    ctx.animManager:moveSpeakerTo(ctx.seatManager:getSeatPositionId(model.gameInfo.speakerSeatId), true)

    self.gameStartDelay_ =  2 + model:getNumInRound() * 3 * 0.1

    --重置操作栏自动操作状态
    ctx.oprManager:resetAutoOperationStatus()    
    

    --更新操作栏状态
    ctx.oprManager:updateOperationStatus()

    --更新座位状态
    ctx.seatManager:updateAllSeatState()

    self:updateChangeRoomButtonMode()

    
    self:setMatchInviteButtonDelayVisible()
end


function MatchRoomController:isPreCall()
    return self.isPreCall_
end


function MatchRoomController:SVR_MATCH_GAME_OVER(pack)
    local model = self.model
    local ctx = self.ctx
    local ranklist = model:processMatchGameOver(pack)
    local matchId = self.model.roomInfo.matchId

    if ranklist and matchId then
        for _,v in pairs(ranklist) do 
            if (not self.model:isSelfKnockOut()) and self.model:isSelf(v.uid) then
                --http请求领奖
                self:requestMatchReward(matchId,v.uid,v.rank)
                break
            end
        end

    end

    self.sceneSchedulerPool:delayCall(function() 
            nk.server:matchQuit()

            if self.backHallAction_ then
                --todo
                self.scene:doBackToHall(nil, self.backHallAction_)
            else
                self.scene:doBackToHall()
            end
            
        end, 45)
end

function MatchRoomController:requestMatchReward(matchid,uid,rank)
    local retryLimit = 6
    local reqMatchRewardFunc
    local params = {}
    params.matchid = matchid
    params.uid =uid
    params.rank = rank
   
    reqMatchRewardFunc = function()
        nk.http.matchGetReward(params,function(data)
            --领奖成功
            local matchType = self.model.roomInfo.matchType
            local callbackFunc = function(ttype)
                if ttype ==  1 then

                elseif ttype ==  2 then

                elseif ttype ==  3 then
                    nk.server:matchQuit()
                    if self and self.scene then
                        self.scene:doBackToHall()
                    end
                end
            end
            --
            if matchType> 100 then
                MatchTimeGameResultPopup.new(params.rank, matchType, data, callbackFunc):show()
            else
                MatchGameResultPopup.new(params.rank, matchType, data, callbackFunc):show()
            end
            if data and data.money then
                nk.userData["aUser.money"] = tonumber(data.money)
            end
            if data and data.exchangecard then
                nk.userData["match.ticket"] = tonumber(data.exchangecard)
            end
            end, function(errData) 
                --重试6次
                retryLimit = retryLimit - 1
                if retryLimit > 0 then
                    self.schedulerPool:delayCall(function()
                        reqMatchRewardFunc()
                    end, 2)
                else
                    nk.TopTipManager:showTopTip("领奖失败"..errData.errorCode)
                end
            end)
    end
    reqMatchRewardFunc()
end


function MatchRoomController:SVR_MATCH_SHOW_CARD(pack)
    local model = self.model
    local ctx = self.ctx
    model:processShowHand(pack)

    self.gameSchedulerPool:clearAll()
    -- model:processGameOver(pack)

    --隐藏灯光
    ctx.lampManager:hide()

    --禁用操作按钮
    ctx.oprManager:blockOperationButtons()
    --座位停止计时器
    ctx.seatManager:stopCounter()

    -- 延迟处理
    local splitPotsDelayTime = 0
    local resetDelayTime = 0
    -- if model:roomType() == consts.ROOM_TYPE.PRO and model.gameInfo.allAllIn then
    --     splitPotsDelayTime = BetChipView.MOVE_FROM_SEAT_DURATION + BetChipView.MOVE_TO_POT_DURATION + 0.6 + 2
    --     resetDelayTime = #model.gameInfo.splitPots * 3 + splitPotsDelayTime
    --     self.schedulerPool:delayCall(function() 
    --         self.seatManager:showHandCard()
    --     end, 2)
    -- else
        -- splitPotsDelayTime = BetChipView.MOVE_FROM_SEAT_DURATION + BetChipView.MOVE_TO_POT_DURATION + 0.6
        splitPotsDelayTime = 0.5
        resetDelayTime = #model.gameInfo.splitPots * 3 + splitPotsDelayTime
        -- if model:canShowHandcard() then
            -- if model:canShowHandcardButton() then
                -- ctx.oprManager:showExtOperationView()
            -- end
        -- elseif self.model.gameInfo.dealed3rdCard then
            self.seatManager:showHandCard()
        -- end
    -- end
    -- 分奖池动画
    self.schedulerPool:delayCall(function ()
        ctx.chipManager:splitPots(model.gameInfo.splitPots)
        --座位经验值变化动画
        -- ctx.seatManager:playExpChangeAnimation()

        -- dump("showcard000")
    end, splitPotsDelayTime)
    -- 刷新游戏状态
    self.schedulerPool:delayCall(handler(self, self.reset), resetDelayTime)

end


function MatchRoomController:SVR_MATCH_OTHER_THIRD_CARD(pack)
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

function MatchRoomController:SVR_MATCH_THIRD_CARD(pack)
    local ctx = self.ctx
    local model = self.model
    model:processGetPokerBySelf(pack)
    ctx.dealCardManager:dealCardToPlayer(self.model:selfSeatId())
end


function MatchRoomController:SVR_MATCH_COUNT_DOWN(pack)
    local ctx = self.ctx
    local model = self.model
    model:processCountDown(pack)
    self.scene:playAnimCountDown(self.model.gameInfo.countDown)

end

function MatchRoomController:SVR_MATCH_AI(pack)
    self.scene:setAIState(true)
end
function MatchRoomController:SVR_MATCH_CACEL_AI_RESULT(pack)
    if pack and pack.errno == 0 then
        self.scene:setAIState(false)
    end
end
function MatchRoomController:SVR_MATCH_LEFT_NUM_FORCE_EXIT_GAME(pack)
    MatchForceExitTipPopup.new(pack.leftNum):show()
end
function MatchRoomController:SVR_MATCH_FORCE_EXIT_GAME_RESULT(pack)
    if pack and pack.errno == 0 then   
       -- bm.DataProxy:setData(nk.dataKeys.EXIT_MATCH_ACTION, 1)

        local ctx = self.ctx
        local model = self.model
        local selfSeatId = model:selfSeatId()
        ctx.seatManager:playStandUpAnimation(selfSeatId, function() 
                ctx.seatManager:updateSeatState(selfSeatId)
        end)

        -- if self.scene and self.scene.doBackToHall then
        --     --todo
        --     if self.backHallAction_ then
        --         --todo
        --         self.scene:doBackToHall(self.backHallAction_)
        --     else
        --         self.scene:doBackToHall()
        --     end
        -- end
         
    else
        nk.TopTipManager:showTopTip(T("退赛失败，请继续比赛"))
    end
end

function MatchRoomController:SVR_SUONA_BROADCAST_RECV(pack)
    -- body
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
function MatchRoomController:SVR_PUSH_CHANGE_MATCH_ROOM(pack)
    local ctx = self.ctx
    local model = self.model

    if self.roomLoading_ then
        self.roomLoading_:removeFromParent()
        self.roomLoading_ = nil
    end

    self:reset()

    --登录成功
    model:processChangeMatchRoom(pack)

    self.scene:removeLoading()


    --显示房间信息
    self.scene:setRoomInfoText(model.roomInfo)
    --老虎机盲注
    -- self.scene:setSlotBlind(model.roomInfo)

    --初始化座位及玩家
    ctx.seatManager:initSeats(model.seatsInfo, model.playerList)

    --设置庄家指示
    -- ctx.animManager:moveDealerTo(ctx.seatManager:getSeatPositionId(model.gameInfo.dealerSeatId), false)
    ctx.animManager:moveDealerTo(ctx.seatManager:getSeatPositionId(10), false)

    --移动说话人指示
    ctx.animManager:moveSpeakerTo(ctx.seatManager:getSeatPositionId(model.gameInfo.speakerSeatId), false)


    

    --初始隐藏灯光
    if model.gameInfo.curDealSeatId ~= -1 then
        ctx.lampManager:show()
        ctx.lampManager:turnTo(ctx.seatManager:getSeatPositionId(model.gameInfo.curDealSeatId), false)

        --座位开始计时器动画
        -- ctx.seatManager:startCounter(model.gameInfo.curDealSeatId)
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

    --动画显示操作栏
    if model:isSelfInSeat() then
        ctx.oprManager:showOperationButtons(true)
    else
        ctx.oprManager:hideOperationButtons(true)
    end
        

    -- 设置登录筹码堆
    ctx.chipManager:setLoginChipStacks()

    self.gameSchedulerPool:clearAll()

    self:updateChangeRoomButtonMode()

   

    self:setWaitTips()

    -- if pack.isAI == 1 then
    --     self.scene:setAIState(true)
    -- else
    --     self.scene:setAIState(false)
    -- end

    --清除上一轮的排行榜信息
    local data = bm.DataProxy:getData(nk.dataKeys.MATCH_RANK)
    if data and data.rankList then
        data.rankList = {}
        bm.DataProxy:setData(nk.dataKeys.MATCH_RANK, data)
    end

    --self:setMatchInviteButtonDelayVisible()
end
function MatchRoomController:SVR_MATCH_KNOCK_OUT(pack)
    local ctx = self.ctx
    local model = self.model

    local selfSeatId = model:selfSeatId()
    local seatId,rank = model:processKnockOut(pack)
    local positionId = ctx.seatManager:getSeatPositionId(seatId) 

    local anim = true
    --------------------------------------------
    --如果自己被淘汰，更新座位显示和操作区状态
    if selfSeatId == seatId then
       
        -- ctx.seatManager:setForceHideSeat(seatId,true)

        --更新全部座位状态，没人的座位会显示
        ctx.seatManager:updateAllSeatState()
        --把转动过的座位还原
        ctx.seatManager:rotateSeatToOrdinal()
        --动画隐藏操作栏
        ctx.oprManager:hideOperationButtons(anim)

        local matchId = self.model.roomInfo.matchId
        
        self:requestMatchReward(matchId,nk.userData["aUser.mid"],rank)
       -- bm.DataProxy:setData(nk.dataKeys.EXIT_MATCH_ACTION,0)
    else
        if not anim then
            ctx.seatManager:updateSeatState(seatId)
        end
    end
    --------------------------------------------
    
    if anim then
        ctx.seatManager:playStandUpAnimation(seatId, function() 
            ctx.seatManager:updateSeatState(seatId)
        end)

    end
    

    --干掉已经发的手牌
    self.dealCardManager:hideDealedCard(positionId)

      --如果当前座位正在计时，强制停止
    ctx.seatManager:stopCounterOnSeat(seatId)

    self:updateChangeRoomButtonMode() 
    ctx.chipManager:clearChip(seatId)   

end


function MatchRoomController:SVR_MATCH_QUIT(pack)
    local ctx  = self.ctx
    local model = self.model
    if pack.errno and pack.errno == 0 then
        --回应退出成功
    end
end



function MatchRoomController:SVR_MATCH_BROAD_QUIT(pack)
    local ctx = self.ctx
    local model = self.model
    local seatId = model:processBroadQuit(pack)
    self:setWaitTips()
    --播放站起动画    
    ctx.seatManager:playStandUpAnimation(seatId, function() 
        ctx.seatManager:updateSeatState(seatId)
    end)
end


function MatchRoomController:SVR_PUSH_MATCH_ROOM(pack)
    
end

function MatchRoomController:SVR_TIME_MATCH_OFF(pack)
    if self.model.roomInfo.matchId == pack.matchid then
        self.scene:doBackToHall()
    end
end
function MatchRoomController:SVR_WAIT_MATCH_GAME(pack)
     local matchType = self.model.roomInfo.matchType
    if matchType > 100 then
        self.scene:setRoomTipText(T("等待合桌"))
    end
end
function MatchRoomController:SVR_MATCH_BROAD_RANK(pack)
    -- dump(pack,"MatchRoomController:SVR_MATCH_BROAD_RANK")
    bm.DataProxy:setData(nk.dataKeys.MATCH_RANK, pack)
    self.scene:setMatchRoomIndicator(pack)

end
function MatchRoomController:SVR_TIME_MATCH_RANK(pack)
    self.scene:setTimeMatchIndicator(pack)
    bm.DataProxy:setData(nk.dataKeys.MATCH_DETAIL,pack)
end

function MatchRoomController:SVR_LOGIN_OK_NEW(pack)

    local runningScene = display.getRunningScene()
    if (not runningScene) or (runningScene.name == nil) or (runningScene.name ~= "MatchRoomScene") then
        return
    end

    dump(pack,"MatchRoomController:SVR_LOGIN_OK_NEW")

    local data = pack
     if data.tid > 0 then
        --matchid > 0 在比赛场
        if data.matchid and data.matchid > 0 then
            self.matchId_ = data.matchid
            nk.server:checkJoinMatch(self.matchId_)
        else
            -- 重连房间
            -- self.tid__ = data.tid
             -- nk.server:loginRoom(self.tid__)
        end  
    else
        --如果已经结束或者被淘汰重连，理应退出大厅
        self.scene:doBackToHall()
    end
end



function MatchRoomController:SVR_MATCH_CAN_THIRD_CARD(pack)
    local model = self.model
    local ctx = self.ctx
    local seatId = model:processTurnToGetPoker(pack)

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


    -- self:turnTo_(seatId)
     --更新座位信息
    -- ctx.seatManager:updateSeatState(seatId)

    -- local ctx = self.ctx
    -- local model = self.model
    -- if model:selfSeatId() == seatId then
    --     nk.SoundManager:playSound(nk.SoundManager.NOTICE)
    --     if nk.userDefault:getBoolForKey(nk.cookieKeys.SHOCK, false) then
    --         nk.Native:vibrate(500)
    --     end
    -- end
    -- --打光切换
    -- ctx.lampManager:show()
    -- ctx.lampManager:turnTo(self.seatManager:getSeatPositionId(seatId), true)
    -- --座位开始计时器动画
    -- self.gameSchedulerPool:delayCall(function()
    --     ctx.seatManager:startCounter(seatId)
    --     --更新操作栏状态
    --     ctx.oprManager:updateOperationStatus()
    -- end, 0.5)
end



function MatchRoomController:SVR_MATCH_TURN_BET(pack)
    --轮到某个玩家下注
    local ctx = self.ctx
    local model = self.model
    local seatId = model:processTurnToBet(pack)
  
    --更新座位信息
    ctx.seatManager:updateSeatState(seatId)

    local turnToDelay = 0
    if self.isPreCall_ then
        turnToDelay = self.gameStartDelay_ or 3
    end
    local roundCount = self.model.gameInfo.roundCount
    if self.turnToDelayId_ then
        self.gameSchedulerPool:clear(self.turnToDelayId_)
        self.turnToDelayId_ = nil
    end
    local turnToFunc = function()
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
                -- dump("SVR_MATCH_TURN_BET")
            ctx.oprManager:updateOperationStatus()
            end, 0.5)
        end
    if turnToDelay > 0 then
        self.turnToDelayId_ = self.gameSchedulerPool:delayCall(turnToFunc, turnToDelay)
    else
        turnToFunc()
    end
end


function MatchRoomController:SVR_MATCH_DEAL(pack)
     local ctx = self.ctx
    local model = self.model
    model:processDeal(pack)   
    ctx.seatManager:prepareDealCards()   
    ctx.dealCardManager:dealCards()  
end


function MatchRoomController:SVR_MATCH_CARD_NUM(pack)
    local ctx = self.ctx
    local model = self.model
    if model:isSelfDealer() or not model:isSelfInSeat() then  
        ctx.oprManager:stopLoading()
    end
    model:processMatchCardNum(pack)
    ctx.lampManager:hide()
    if not model:isSelfInSeat() then
        ctx.seatManager:prepareDealCards()   
        ctx.dealCardManager:dealCards()   
    end
   
end

function MatchRoomController:SVR_MATCH_BET(pack)

    -- {"cmd":30726,"betPoint":571,"seatId":0,"leftPoints":9329,"betType":3,"totalBet":671,"maxBetPoints":671}
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
        local betState = player.betState
        -- dump(betState,"SVR_MATCH_BET:betState")
        -- 前注标志
        if betState == consts.SVR_BET_STATE.PRE_CALL then
            self.isPreCall_ = true
        else
            self.isPreCall_ = false
        end

        -- 前注
        if betState == consts.SVR_BET_STATE.PRE_CALL then
            nk.SoundManager:playSound(nk.SoundManager.CALL)
        -- 看牌
        elseif betState == consts.SVR_BET_STATE.CHECK then
            nk.SoundManager:playSound(nk.SoundManager.CHECK)
        -- 弃牌
        elseif betState == consts.SVR_BET_STATE.FOLD then
            nk.SoundManager:playSound(nk.SoundManager.FOLD)

            ctx.dealCardManager:foldCard(player)
            ctx.seatManager:fadeHandCard(seatId)
            -- dump(player.seatId,"FOLD_card")
            ctx.seatManager:fadeSeat(seatId)
        -- 跟注
        elseif betState == consts.SVR_BET_STATE.CALL then
            nk.SoundManager:playSound(nk.SoundManager.CALL)
        -- 加注
        elseif betState == consts.SVR_BET_STATE.RAISE then
            nk.SoundManager:playSound(nk.SoundManager.RAISE)
        -- all in
        elseif betState == consts.SVR_BET_STATE.ALL_IN then
            nk.SoundManager:playSound(nk.SoundManager.RAISE)
        end
    end
        

end



function MatchRoomController:SVR_MATCH_POT(pack)
   
    local ctx = self.ctx
    local model = self.model
    model:processPot(pack)
    local potList = pack.potList
    -- dump(potList,"SVR_MATCH_POT:potList")
    -- 收奖池动画
    ctx.chipManager:gatherPot()

    --禁用操作栏
    ctx.oprManager:blockOperationButtons()
        

end


function MatchRoomController:SVR_MATCH_PRE_CALL(pack)
    local ctx = self.ctx
    local model = self.model
    self.isPreCall_ = true

    local preCallArr = model:processPreCallSuccess(pack)
    if not preCallArr then
        return
    end

    for _,v in pairs(preCallArr) do
        --更新座位信息
        ctx.seatManager:updateSeatState(v.seatId)

        local player = model.playerList[v.seatId]
        local isSelf = model:isSelf(player.uid)
        if player then
            --如果当前座位正在计时，强制停止
            ctx.seatManager:stopCounterOnSeat(v.seatId)
            ctx.chipManager:betChip(player)       
            nk.SoundManager:playSound(nk.SoundManager.CALL)
            
            -- all in
            if player.antPoints == 0 then
                nk.SoundManager:playSound(nk.SoundManager.RAISE)
            end
        end
        if isSelf then
            ctx.oprManager:updateOperationStatus()
        end
    end

    self.isPreCall_ = false

     --定时赛没有比赛开始倒计时协议，为修改牌桌信息状态。
    local matchType = self.model.roomInfo.matchType
    if matchType > 100 then
        self.scene:setRoomTipText("")
        --self.scene:setRoomInfoText(T("定时赛"))
        self.scene:setRoomInfoText(model.roomInfo)
    end

end


function MatchRoomController:SVR_MATCH_SEAT_DOWN(pack)
    local ctx = self.ctx
    local model = self.model
    --坐下
    local seatId, isAutoBuyin = model:processSitDown(pack)
    if isAutoBuyin then
        local seatView_ = ctx.seatManager:getSeatView(seatId)
        seatView_:playAutoBuyinAnimation(pack.anteMoney)
        return
    end
    local anim = not pack.fastForward or true

    if model:selfSeatId() == seatId then
        --更新全部座位状态，没人的座位会隐藏
        ctx.seatManager:updateAllSeatState()
        --把自己的座位转到中间去
        ctx.seatManager:rotateSelfSeatToCenter(seatId, anim)
        --动画显示操作栏
        ctx.oprManager:showOperationButtons(anim)
       
    else        
        --更新座位信息
        ctx.seatManager:updateSeatState(seatId)       
    end

    if anim then
        ctx.seatManager:playSitDownAnimation(seatId)
    end

    self:setWaitTips()

    self:updateChangeRoomButtonMode()

    bm.EventCenter:dispatchEvent({name=nk.eventNames.UPDATE_SEAT_INVITE_VIEW, data={ctx = self.ctx,seatId = seatId}})
end



function MatchRoomController:SVR_LOGIN_MATCH_ROOM_FAIL(pack)
    dump(pack,"MatchRoomController:SVR_LOGIN_MATCH_ROOM_FAIL")
     if self.roomLoading_ then
        self.roomLoading_:removeFromParent()
        self.roomLoading_ = nil
    end
    -- if not evt or not evt.silent then
    --     nk.ui.Dialog.new({
    --         hasCloseButton = false,
    --         messageText = bm.LangUtil.getText("ROOM", "NET_WORK_PROBLEM_DIALOG_MSG"), 
    --         callback = function (type)
    --             if type == nk.ui.Dialog.SECOND_BTN_CLICK then
    --                 self.roomLoading_ = nk.ui.RoomLoading.new(bm.LangUtil.getText("ROOM", "RECONNECT_MSG"))
    --                     :pos(display.cx, display.cy)
    --                     :addTo(self.scene, 100)                   
    --                 nk.server:quickPlay()
    --             elseif type == nk.ui.Dialog.FIRST_BTN_CLICK or type == nk.ui.Dialog.CLOSE_BTN_CLICK then
                    display.addSpriteFrames("hall_texture.plist", "hall_texture.png", handler(self.scene, self.scene.onLoadedHallTexture_))
                    self.roomLoading_ = nk.ui.RoomLoading.new(bm.LangUtil.getText("ROOM", "OUT_MSG"))
                        :pos(display.cx, display.cy)
                        :addTo(self.scene, 100)
            --     end
            -- end
        -- }):show()
    -- end
    
end


function MatchRoomController:SVR_LOGIN_MATCH_ROOM_OK(pack)
    -- dump(pack,"MatchRoomController:SVR_LOGIN_MATCH_ROOM_OK")
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
    -- self.scene:setSlotBlind(model.roomInfo)

    --初始化座位及玩家
    ctx.seatManager:initSeats(model.seatsInfo, model.playerList)

    --设置庄家指示
    -- ctx.animManager:moveDealerTo(ctx.seatManager:getSeatPositionId(model.gameInfo.dealerSeatId), false)
    ctx.animManager:moveDealerTo(ctx.seatManager:getSeatPositionId(10), false)

    --移动说话人指示
    ctx.animManager:moveSpeakerTo(ctx.seatManager:getSeatPositionId(model.gameInfo.speakerSeatId), false)


    

    --初始隐藏灯光
    if model.gameInfo.curDealSeatId ~= -1 then
        ctx.lampManager:show()
        ctx.lampManager:turnTo(ctx.seatManager:getSeatPositionId(model.gameInfo.curDealSeatId), false)

        --座位开始计时器动画
        -- ctx.seatManager:startCounter(model.gameInfo.curDealSeatId)
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

    --动画显示操作栏
    if model:isSelfInSeat() then
        ctx.oprManager:showOperationButtons(true)
    else
        ctx.oprManager:hideOperationButtons(true)
    end
        

    -- 设置登录筹码堆
    ctx.chipManager:setLoginChipStacks()

    self.gameSchedulerPool:clearAll()

    self:updateChangeRoomButtonMode()

    --自动坐下
    -- self:applyAutoSitDown()

    -- 上报广告平台  玩牌
    -- if nk.AdSdk then 
        -- nk.AdSdk:reportPlay()
    -- end

    self:setWaitTips()

    if pack.isAI == 1 then
        self.scene:setAIState(true)
    else
        self.scene:setAIState(false)
    end

    --清除上一轮的排行榜信息
    local data = bm.DataProxy:getData(nk.dataKeys.MATCH_RANK)
    if data and data.rankList then
        data.rankList = {}
        bm.DataProxy:setData(nk.dataKeys.MATCH_RANK, data)
    end
    local matchType = self.model.roomInfo.matchType
    if matchType < 100 then
        self:setMatchInviteButtonDelayVisible()
    end
    bm.DataProxy:setData(nk.dataKeys.MATCH_DETAIL,{})
end


function MatchRoomController:setWaitTips()
    local ctx = self.ctx
    local model = self.model
    if model and model.roomInfo then
        --私人房特例
        if (model.gameInfo.gameStatus == consts.SVR_MATCH_GAME_STATUS.APPLY) then
            local numInSeat = model:getNumInSeat()
            local maxInSeat = model.roomInfo.playerNum
            local numStr = string.format("(%s)",(numInSeat .. "/" .. maxInSeat))

            self.scene:setRoomTipText(bm.LangUtil.getText("MATCH", "WAIT_FOR_GAME") .. numStr)
        end
    end
end





function MatchRoomController:SVR_MSG(pack)
end

function MatchRoomController:SVR_OTHER_OFFLINE(pack)    
end


--发送房间内广播
function MatchRoomController:SVR_ROOM_BROADCAST(pack)
    -- dump(pack,"MatchRoomController:SVR_ROOM_BROADCAST==========发送房间内广播")
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
        local toSeatId = 9 
        local player = self.model.playerList[fromSeatId]
        if player then
            self.animManager:playSendChipAnimation(fromSeatId, toSeatId, fee)
            self.sceneSchedulerPool:delayCall(function() 
                    self.ctx.dealerManager:kissPlayer()
                    bm.EventCenter:dispatchEvent({name = nk.eventNames.SEND_DEALER_CHIP_BUBBLE_VIEW, nick=player.userInfo.name,type = 1})
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

function MatchRoomController:SVR_COMMON_BROADCAST(pack)
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




function MatchRoomController:processUpgrade(delay)
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



function MatchRoomController:processPacket_(pack)
    if self.func_[pack.cmd] then
        self.func_[pack.cmd](pack)
    end   
end

function MatchRoomController:applyAutoSitDown()
    if not self.model:isSelfInGame() then
        local emptySeatId = self.seatManager:getEmptySeatId()
        if emptySeatId then
            local isAutoSit = nk.userDefault:getBoolForKey(nk.cookieKeys.AUTO_SIT, true)
            if isAutoSit or nk.server:isPlayNow() then
                local userData = nk.userData
                if userData['aUser.money'] >= self.model.roomInfo.minBuyIn then
                    logger:debug("auto sit down", emptySeatId)
                    local isAutoBuyin = nk.userDefault:getBoolForKey(nk.cookieKeys.AUTO_BUY_IN, true)
                    do return end
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
                                        self.scene:playNowChangeRoom()
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
        end
    end
end

function MatchRoomController:updateChangeRoomButtonMode()
    if self.model:isSelfInSeat() then
        self.scene:setChangeRoomButtonMode(2)
    else
        self.scene:setChangeRoomButtonMode(1)
    end
end


function MatchRoomController:setMatchInviteButtonDelayVisible()
    if self.ctx.model.gameInfo.gameStatus == consts.SVR_MATCH_GAME_STATUS.APPLY then
        if self.matchInviteSchedulerId_ then
            self.sceneSchedulerPool:clear(self.matchInviteSchedulerId_)
            self.matchInviteSchedulerId_ = nil
        end
        if self.model:isSelfInSeat() then
            self.matchInviteSchedulerId_ = self.sceneSchedulerPool:delayCall(function()
                if self.matchInviteSchedulerId_ then
                    self.sceneSchedulerPool:clear(self.matchInviteSchedulerId_)
                    self.matchInviteSchedulerId_ = nil
                end 
                self.scene:setMatchInviteButtonVisible(true)
            end,15)
        end
    else
        if self.matchInviteSchedulerId_ then
            self.sceneSchedulerPool:clear(self.matchInviteSchedulerId_)
            self.matchInviteSchedulerId_ = nil
        end 
    end

    
end

function MatchRoomController:onBoroadCastMsgJump_()
    -- body
    local HallController = import("app.module.hall.HallController")

    local doJumpActionByTag = {
        ["matchlist"] = function()
            -- body

            if self.model:isSelfInMatch() then
                --todo
                if self.model.gameInfo.gameStatus == consts.SVR_MATCH_GAME_STATUS.APPLY then
                    --todo

                    local requestBackToHall = function()
                        nk.http.matchOut(function(data)

                            if data and data.money then
                                nk.userData["aUser.money"] = tonumber(data.money)
                            end

                            if self.scene and self.scene.doBackToHall then
                                --todo
                                self.scene:doBackToHall()
                            end
                        end, function(errorCode)
                            nk.TopTipManager:showTopTip(T("退赛失败,请继续比赛"))
                        end)
                    end

                    nk.http.getMatchExitLeftTime(self.model.roomInfo.matchType, function(data)
                        
                        bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.CHOOSE_MATCH_NOR_VIEW)
                        if tonumber(data.remainTime) > 0 then
                            local MatchExitTipPopup = import("app.module.match.views.MatchExitTipPopup")
                            MatchExitTipPopup.new(requestBackToHall, data.remainTime):show()
                        else
                            requestBackToHall()
                        end

                    end,function(errordata)
                        bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.CHOOSE_MATCH_NOR_VIEW)
                        requestBackToHall()
                    end)

                else
                    bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.CHOOSE_MATCH_NOR_VIEW)

                    nk.server:matchExitGetLeftTime()
                end

            else
                bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.CHOOSE_MATCH_NOR_VIEW)

                if self.model:isSelfKnockOut() then
                    --如果被淘汰出局，需要调用退赛协议
                    nk.server:matchQuit()
                end
                
                if self.scene and self.scene.doBackToHall then
                    --todo
                    self.scene:doBackToHall()
                end
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
                        self.scene:onChargeFavClick_()
                    end
                else

                    local rechargeFavAccess = nk.userData.bagPayList and nk.userData.bagPayList.access == 1 or false
                    if nk.OnOff:check("rechargeFavGray") and isShowPay and isPay and rechargeFavAccess then
                        --todo
                        if self.scene.onAlmRechargeFavClick_ then
                            --todo
                            self.scene.onAlmRechargeFavClick_()
                        end
                    else
                        if self.scene.onShopClick_ then
                            --todo
                            self.scene:onShopClick_()
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
            if self.model:isSelfInMatch() then
                --todo
                if self.model.gameInfo.gameStatus == consts.SVR_MATCH_GAME_STATUS.APPLY then
                    --todo

                    local requestBackToHall = function()
                        nk.http.matchOut(function(data)

                            if data and data.money then
                                nk.userData["aUser.money"] = tonumber(data.money)
                            end

                            if self.scene and self.scene.doBackToHall then
                                --todo
                                self.scene:doBackToHall(nil, self.backHallAction_)
                            end
                        end, function(errorCode)
                            nk.TopTipManager:showTopTip(T("退赛失败,请继续比赛"))
                        end)
                    end

                    nk.http.getMatchExitLeftTime(self.model.roomInfo.matchType, function(data)
                        
                        -- bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.CHOOSE_MATCH_NOR_VIEW)
                        bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.MAIN_HALL_VIEW)
                        if tonumber(data.remainTime) > 0 then
                            local MatchExitTipPopup = import("app.module.match.views.MatchExitTipPopup")
                            MatchExitTipPopup.new(requestBackToHall, data.remainTime):show()
                        else
                            requestBackToHall()
                        end
                    end, function(errordata)
                        -- bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.CHOOSE_MATCH_NOR_VIEW)
                        bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.MAIN_HALL_VIEW)
                        requestBackToHall()
                    end)

                else
                    -- bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.CHOOSE_MATCH_NOR_VIEW)
                    bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.MAIN_HALL_VIEW)

                    nk.server:matchExitGetLeftTime()
                end

            else
                -- bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.CHOOSE_MATCH_NOR_VIEW)
                bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.MAIN_HALL_VIEW)

                if self.model:isSelfKnockOut() then
                    --如果被淘汰出局，需要调用退赛协议
                    nk.server:matchQuit()
                end
                
                if self.scene and self.scene.doBackToHall then
                    --todo
                    self.scene:doBackToHall(nil, self.backHallAction_)
                end
            end
        end,

        ["freechips"] = function()
            -- body
            self.backHallAction_ = "freechips"
            if self.model:isSelfInMatch() then
                --todo
                if self.model.gameInfo.gameStatus == consts.SVR_MATCH_GAME_STATUS.APPLY then
                    --todo

                    local requestBackToHall = function()
                        nk.http.matchOut(function(data)

                            if data and data.money then
                                nk.userData["aUser.money"] = tonumber(data.money)
                            end

                            if self.scene and self.scene.doBackToHall then
                                --todo
                                self.scene:doBackToHall(nil, self.backHallAction_)
                            end
                        end, function(errorCode)
                            nk.TopTipManager:showTopTip(T("退赛失败,请继续比赛"))
                        end)
                    end

                    nk.http.getMatchExitLeftTime(self.model.roomInfo.matchType, function(data)
                        
                        -- bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.CHOOSE_MATCH_NOR_VIEW)
                        bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.MAIN_HALL_VIEW)
                        if tonumber(data.remainTime) > 0 then
                            local MatchExitTipPopup = import("app.module.match.views.MatchExitTipPopup")
                            MatchExitTipPopup.new(requestBackToHall, data.remainTime):show()
                        else
                            requestBackToHall()
                        end
                    end,
                        function(errordata)
                            -- bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.CHOOSE_MATCH_NOR_VIEW)
                            bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.MAIN_HALL_VIEW)
                            requestBackToHall()
                    end)

                else
                    -- bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.CHOOSE_MATCH_NOR_VIEW)
                    bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.MAIN_HALL_VIEW)

                    nk.server:matchExitGetLeftTime()
                end

            else
                -- bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.CHOOSE_MATCH_NOR_VIEW)
                bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.MAIN_HALL_VIEW)

                if self.model:isSelfKnockOut() then
                    --如果被淘汰出局，需要调用退赛协议
                    nk.server:matchQuit()
                end
                
                if self.scene and self.scene.doBackToHall then
                    --todo
                    self.scene:doBackToHall(nil, self.backHallAction_)
                end
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
                UserInfoPopup.new():show(true, nil, handler(self.scene, self.scene.onChangeRoomClick_))
            else
                UserInfoPopup.new():show(false, nil, handler(self.scene, self.scene.onChangeRoomClick_))
            end

            -- local UserInfoPopup = import("app.module.userInfo.UserInfoPopup")
            -- UserInfoPopup.new():show()
        end,

        ["gograbdealer"] = function()
            -- body
            -- self.backHallAction_ = "freechips"
            if self.model:isSelfInMatch() then
                --todo
                if self.model.gameInfo.gameStatus == consts.SVR_MATCH_GAME_STATUS.APPLY then
                    --todo

                    local requestBackToHall = function()
                        nk.http.matchOut(function(data)

                            if data and data.money then
                                nk.userData["aUser.money"] = tonumber(data.money)
                            end

                            if self.scene and self.scene.doBackToHall then
                                --todo
                                self.scene:doBackToHall()
                            end
                        end, function(errorCode)
                            nk.TopTipManager:showTopTip(T("退赛失败,请继续比赛"))
                        end)
                    end

                    nk.http.getMatchExitLeftTime(self.model.roomInfo.matchType, function(data)
                        
                        -- bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.CHOOSE_MATCH_NOR_VIEW)
                        bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.CHOOSE_NOR_VIEW)
                        nk.userData.DEFAULT_TAB = 2

                        if tonumber(data.remainTime) > 0 then
                            local MatchExitTipPopup = import("app.module.match.views.MatchExitTipPopup")
                            MatchExitTipPopup.new(requestBackToHall, data.remainTime):show()
                        else
                            requestBackToHall()
                        end
                    end,
                        function(errordata)
                            -- bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.CHOOSE_MATCH_NOR_VIEW)
                            bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.CHOOSE_NOR_VIEW)
                            nk.userData.DEFAULT_TAB = 2

                            requestBackToHall()
                    end)

                else
                    -- bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.CHOOSE_MATCH_NOR_VIEW)
                    bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.CHOOSE_NOR_VIEW)
                    nk.userData.DEFAULT_TAB = 2

                    nk.server:matchExitGetLeftTime()
                end

            else
                -- bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.CHOOSE_MATCH_NOR_VIEW)
                bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.CHOOSE_NOR_VIEW)
                nk.userData.DEFAULT_TAB = 2

                if self.model:isSelfKnockOut() then
                    --如果被淘汰出局，需要调用退赛协议
                    nk.server:matchQuit()
                end
                
                if self.scene and self.scene.doBackToHall then
                    --todo
                    self.scene:doBackToHall()
                end
            end
        end,

        ["gochsnorroom"] = function()
            -- body
            self.backHallAction_ = "gochsnorroom"
            if self.model:isSelfInMatch() then
                --todo
                if self.model.gameInfo.gameStatus == consts.SVR_MATCH_GAME_STATUS.APPLY then
                    --todo

                    local requestBackToHall = function()
                        nk.http.matchOut(function(data)

                            if data and data.money then
                                nk.userData["aUser.money"] = tonumber(data.money)
                            end

                            if self.scene and self.scene.doBackToHall then
                                --todo
                                self.scene:doBackToHall(nil, self.backHallAction_)
                            end
                        end, function(errorCode)
                            nk.TopTipManager:showTopTip(T("退赛失败,请继续比赛"))
                        end)
                    end

                    nk.http.getMatchExitLeftTime(self.model.roomInfo.matchType, function(data)
                        
                        -- bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.CHOOSE_MATCH_NOR_VIEW)
                        bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.CHOOSE_NOR_VIEW)
                        nk.userData.DEFAULT_TAB = 1

                        if tonumber(data.remainTime) > 0 then
                            local MatchExitTipPopup = import("app.module.match.views.MatchExitTipPopup")
                            MatchExitTipPopup.new(requestBackToHall, data.remainTime):show()
                        else
                            requestBackToHall()
                        end
                    end,
                        function(errordata)
                            -- bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.CHOOSE_MATCH_NOR_VIEW)
                            bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.CHOOSE_NOR_VIEW)
                            nk.userData.DEFAULT_TAB = 1

                            requestBackToHall()
                    end)

                else
                    -- bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.CHOOSE_MATCH_NOR_VIEW)
                    bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.CHOOSE_NOR_VIEW)
                    nk.userData.DEFAULT_TAB = 1

                    nk.server:matchExitGetLeftTime()
                end

            else
                -- bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.CHOOSE_MATCH_NOR_VIEW)
                bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.CHOOSE_NOR_VIEW)
                nk.userData.DEFAULT_TAB = 1

                if self.model:isSelfKnockOut() then
                    --如果被淘汰出局，需要调用退赛协议
                    nk.server:matchQuit()
                end
                
                if self.scene and self.scene.doBackToHall then
                    --todo
                    self.scene:doBackToHall(nil, self.backHallAction_)
                end
            end
        end,

        ["fillawrdaddr"] = function()
            -- body
            self.backHallAction_ = "fillawrdaddr"
            if self.model:isSelfInMatch() then
                --todo
                if self.model.gameInfo.gameStatus == consts.SVR_MATCH_GAME_STATUS.APPLY then
                    --todo

                    local requestBackToHall = function()
                        nk.http.matchOut(function(data)

                            if data and data.money then
                                nk.userData["aUser.money"] = tonumber(data.money)
                            end

                            if self.scene and self.scene.doBackToHall then
                                --todo
                                self.scene:doBackToHall(nil, self.backHallAction_)
                            end
                        end, function(errorCode)
                            nk.TopTipManager:showTopTip(T("退赛失败,请继续比赛"))
                        end)
                    end

                    nk.http.getMatchExitLeftTime(self.model.roomInfo.matchType, function(data)
                        
                        -- bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.CHOOSE_MATCH_NOR_VIEW)
                        bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.MAIN_HALL_VIEW)
                        if tonumber(data.remainTime) > 0 then
                            local MatchExitTipPopup = import("app.module.match.views.MatchExitTipPopup")
                            MatchExitTipPopup.new(requestBackToHall, data.remainTime):show()
                        else
                            requestBackToHall()
                        end
                    end,
                        function(errordata)
                            -- bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.CHOOSE_MATCH_NOR_VIEW)
                            bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.MAIN_HALL_VIEW)
                            requestBackToHall()
                    end)

                else
                    -- bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.CHOOSE_MATCH_NOR_VIEW)
                    bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.MAIN_HALL_VIEW)

                    nk.server:matchExitGetLeftTime()
                end

            else
                -- bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.CHOOSE_MATCH_NOR_VIEW)
                bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.MAIN_HALL_VIEW)

                if self.model:isSelfKnockOut() then
                    --如果被淘汰出局，需要调用退赛协议
                    nk.server:matchQuit()
                end
                
                if self.scene and self.scene.doBackToHall then
                    --todo
                    self.scene:doBackToHall(nil, self.backHallAction_)
                end
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

function MatchRoomController:reset()
    self.hasReset_ = true
    -- if self.model:isChangeDealer() then
    --     self.animManager:moveDealerTo(10, true)
    -- end

    self.animManager:moveSpeakerTo(10,true)
    
    self.model:reset()
    self.dealCardManager:reset()
    self.chipManager:reset()
    self.seatManager:reset()

    self.lampManager:hide()

    self.schedulerPool:clearAll()
    self.gameSchedulerPool:clearAll()
end


function MatchRoomController:checkMoneyChange(money)

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


function MatchRoomController:bindDataObservers_()
    self.maxDiscountObserver_ = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "__user_discount", function(discount)
        self.scene:setStoreDiscount(discount)
    end)

   
end

function MatchRoomController:unbindDataObservers_()
    bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "__user_discount", self.maxDiscountObserver_)
end
function MatchRoomController:setOverStandUp()
    self.isOverStandUp = true;--本局结束后站起
end

return MatchRoomController