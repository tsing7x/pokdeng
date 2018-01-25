--
-- Author: LeoLuo
-- Date: 2015-05-09 09:59:20
--
local PROTOCOL = import(".HALL_SERVER_PROTOCOL")
local ServerBase = import(".ServerBase")
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
local HallServer = class("HallServer", ServerBase)

function HallServer:ctor()
    HallServer.super.ctor(self, "HallServer", PROTOCOL)
    -- self:setOption("tcp-nodelay",true)
    self.isLogin_ = false
    self.func_ = {
        [PROTOCOL.SVR_DOUBLE_LOGIN] = {handler(self, HallServer.SVR_DOUBLE_LOGIN), nk.eventNames.SVR_DOUBLE_LOGIN},
        [PROTOCOL.SVR_LOGIN_OK] = {handler(self, HallServer.SVR_LOGIN_OK), nk.eventNames.SVR_LOGIN_OK},
        [PROTOCOL.SVR_ONLINE] = {handler(self, HallServer.SVR_ONLINE), nk.eventNames.SVR_ONLINE},
        [PROTOCOL.SVR_GET_ROOM_OK] = {handler(self, HallServer.SVR_GET_ROOM_OK), nk.eventNames.SVR_GET_ROOM_OK},
        [PROTOCOL.SVR_LOGIN_ROOM_OK] = {handler(self, HallServer.SVR_LOGIN_ROOM_OK), nk.eventNames.SVR_LOGIN_ROOM_OK},
        [PROTOCOL.SVR_LOGIN_ROOM_FAIL] = {handler(self, HallServer.SVR_LOGIN_ROOM_FAIL), nk.eventNames.SVR_LOGIN_ROOM_FAIL},
        [PROTOCOL.SVR_LOGOUT_ROOM_OK] = {handler(self, HallServer.SVR_LOGOUT_ROOM_OK), nk.eventNames.SVR_LOGOUT_ROOM_OK},
        [PROTOCOL.SVR_SEAT_DOWN] = {handler(self, HallServer.SVR_SEAT_DOWN), nk.eventNames.SVR_SEAT_DOWN},
        [PROTOCOL.SVR_STAND_UP] = {handler(self, HallServer.SVR_STAND_UP), nk.eventNames.SVR_STAND_UP},
        [PROTOCOL.SVR_OTHER_CARD] = {handler(self, HallServer.SVR_OTHER_CARD), nk.eventNames.SVR_OTHER_CARD},
        [PROTOCOL.SVR_SET_BET] = {handler(self, HallServer.SVR_SET_BET), nk.eventNames.SVR_SET_BET},
        [PROTOCOL.SVR_MSG] = {handler(self, HallServer.SVR_MSG), nk.eventNames.SVR_MSG},
        [PROTOCOL.SVR_DEAL] = {handler(self, HallServer.SVR_DEAL), nk.eventNames.SVR_DEAL},
        [PROTOCOL.SVR_LOGIN_ROOM] = {handler(self, HallServer.SVR_LOGIN_ROOM), nk.eventNames.SVR_LOGIN_ROOM},
        [PROTOCOL.SVR_LOGOUT_ROOM] = {handler(self, HallServer.SVR_LOGOUT_ROOM), nk.eventNames.SVR_LOGOUT_ROOM},
        [PROTOCOL.SVR_SELF_SEAT_DOWN_OK] = {handler(self, HallServer.SVR_SELF_SEAT_DOWN_OK), nk.eventNames.SVR_SELF_SEAT_DOWN_OK},
        [PROTOCOL.SVR_OTHER_STAND_UP] = {handler(self, HallServer.SVR_OTHER_STAND_UP), nk.eventNames.SVR_OTHER_STAND_UP},
        [PROTOCOL.SVR_OTHER_OFFLINE] = {handler(self, HallServer.SVR_OTHER_OFFLINE), nk.eventNames.SVR_OTHER_OFFLINE},
        [PROTOCOL.SVR_GAME_START] = {handler(self, HallServer.SVR_GAME_START), nk.eventNames.SVR_GAME_START},
        [PROTOCOL.SVR_GAME_OVER] = {handler(self, HallServer.SVR_GAME_OVER), nk.eventNames.SVR_GAME_OVER},
        [PROTOCOL.SVR_BET] = {handler(self, HallServer.SVR_BET), nk.eventNames.SVR_BET},
        [PROTOCOL.SVR_CAN_OTHER_CARD] = {handler(self, HallServer.SVR_CAN_OTHER_CARD), nk.eventNames.SVR_CAN_OTHER_CARD},
        [PROTOCOL.SVR_OTHER_OTHER_CARD] = {handler(self, HallServer.SVR_OTHER_OTHER_CARD), nk.eventNames.SVR_OTHER_OTHER_CARD},
        [PROTOCOL.SVR_SHOW_CARD] = {handler(self, HallServer.SVR_SHOW_CARD), nk.eventNames.SVR_SHOW_CARD},
        [PROTOCOL.SVR_CARD_NUM] = {handler(self, HallServer.SVR_CARD_NUM), nk.eventNames.SVR_CARD_NUM},
        [PROTOCOL.SVR_ROOM_BROADCAST] = {handler(self, HallServer.SVR_ROOM_BROADCAST), nk.eventNames.SVR_ROOM_BROADCAST},
        [PROTOCOL.SVR_COMMON_BROADCAST] = {handler(self, HallServer.SVR_COMMON_BROADCAST), nk.eventNames.SVR_COMMON_BROADCAST},
        [PROTOCOL.SVR_GET_PERSONAL_ROOM_LIST] = {handler(self, HallServer.SVR_GET_PERSONAL_ROOM_LIST), nk.eventNames.SVR_GET_PERSONAL_ROOM_LIST},
        [PROTOCOL.SVR_CREATE_PERSONAL_ROOM] = {handler(self,HallServer.SVR_CREATE_PERSONAL_ROOM),nk.eventNames.SVR_CREATE_PERSONAL_ROOM},
        [PROTOCOL.SVR_LOGIN_PERSONAL_ROOM] = {handler(self,HallServer.SVR_LOGIN_PERSONAL_ROOM),nk.eventNames.SVR_LOGIN_PERSONAL_ROOM},
        [PROTOCOL.SVR_SEARCH_PERSONAL_ROOM] = {handler(self,HallServer.SVR_SEARCH_PERSONAL_ROOM),nk.eventNames.SVR_SEARCH_PERSONAL_ROOM},
        [PROTOCOL.SVR_CHECK_JION_MATCH] = {handler(self,HallServer.SVR_CHECK_JION_MATCH),nk.eventNames.SVR_CHECK_JION_MATCH},
        [PROTOCOL.SVR_LOGIN_MATCH_ROOM_OK] = {handler(self,HallServer.SVR_LOGIN_MATCH_ROOM_OK),nk.eventNames.SVR_LOGIN_MATCH_ROOM_OK},
        [PROTOCOL.SVR_MATCH_BROAD_RANK]     = {handler(self,HallServer.SVR_MATCH_BROAD_RANK),nk.eventNames.SVR_MATCH_BROAD_RANK},
        [PROTOCOL.SVR_LOGIN_MATCH_ROOM_FAIL]     = {handler(self,HallServer.SVR_LOGIN_MATCH_ROOM_FAIL),nk.eventNames.SVR_LOGIN_MATCH_ROOM_FAIL},
        [PROTOCOL.SVR_LOGIN_OK_NEW] = {handler(self,HallServer.SVR_LOGIN_OK_NEW),nk.eventNames.SVR_LOGIN_OK_NEW},
        [PROTOCOL.SVR_LOGIN_OK_RE_CONECT] = {handler(self,HallServer.SVR_LOGIN_OK_RE_CONECT),nk.eventNames.SVR_LOGIN_OK_RE_CONECT},
        [PROTOCOL.SVR_MATCH_SET_BET]     = {handler(self,HallServer.SVR_MATCH_SET_BET),nk.eventNames.SVR_MATCH_SET_BET},
        [PROTOCOL.SVR_MATCH_QUIT]     = {handler(self,HallServer.SVR_MATCH_QUIT),nk.eventNames.SVR_MATCH_QUIT},
        [PROTOCOL.SVR_MATCH_THIRD_CARD]     = {handler(self,HallServer.SVR_MATCH_THIRD_CARD),nk.eventNames.SVR_MATCH_THIRD_CARD},
        [PROTOCOL.SVR_MATCH_DEAL]     = {handler(self,HallServer.SVR_MATCH_DEAL),nk.eventNames.SVR_MATCH_DEAL},
        [PROTOCOL.SVR_MATCH_SEAT_DOWN]     = {handler(self,HallServer.SVR_MATCH_SEAT_DOWN),nk.eventNames.SVR_MATCH_SEAT_DOWN},
        [PROTOCOL.SVR_MATCH_GAME_START]     = {handler(self,HallServer.SVR_MATCH_GAME_START),nk.eventNames.SVR_MATCH_GAME_START},
        [PROTOCOL.SVR_MATCH_PRE_CALL]     = {handler(self,HallServer.SVR_MATCH_PRE_CALL),nk.eventNames.SVR_MATCH_PRE_CALL},
        [PROTOCOL.SVR_MATCH_CARD_NUM]     = {handler(self,HallServer.SVR_MATCH_CARD_NUM),nk.eventNames.SVR_MATCH_CARD_NUM},
        [PROTOCOL.SVR_MATCH_TURN_BET]     = {handler(self,HallServer.SVR_MATCH_TURN_BET),nk.eventNames.SVR_MATCH_TURN_BET},
        [PROTOCOL.SVR_MATCH_BET]     = {handler(self,HallServer.SVR_MATCH_BET),nk.eventNames.SVR_MATCH_BET},
        [PROTOCOL.SVR_MATCH_CAN_THIRD_CARD]     = {handler(self,HallServer.SVR_MATCH_CAN_THIRD_CARD),nk.eventNames.SVR_MATCH_CAN_THIRD_CARD},
        [PROTOCOL.SVR_MATCH_OTHER_THIRD_CARD]     = {handler(self,HallServer.SVR_MATCH_OTHER_THIRD_CARD),nk.eventNames.SVR_MATCH_OTHER_THIRD_CARD},
        [PROTOCOL.SVR_MATCH_SHOW_CARD]     = {handler(self,HallServer.SVR_MATCH_SHOW_CARD),nk.eventNames.SVR_MATCH_SHOW_CARD},
        [PROTOCOL.SVR_MATCH_BROAD_QUIT]     = {handler(self,HallServer.SVR_MATCH_BROAD_QUIT),nk.eventNames.SVR_MATCH_BROAD_QUIT},
        [PROTOCOL.SVR_MATCH_POT]     = {handler(self,HallServer.SVR_MATCH_POT),nk.eventNames.SVR_MATCH_POT},
        [PROTOCOL.SVR_MATCH_KNOCK_OUT]     = {handler(self,HallServer.SVR_MATCH_KNOCK_OUT),nk.eventNames.SVR_MATCH_KNOCK_OUT},
        [PROTOCOL.SVR_MATCH_GAME_OVER]     = {handler(self,HallServer.SVR_MATCH_GAME_OVER),nk.eventNames.SVR_MATCH_GAME_OVER},
        [PROTOCOL.SVR_MATCH_COUNT_DOWN]     = {handler(self,HallServer.SVR_MATCH_COUNT_DOWN),nk.eventNames.SVR_MATCH_COUNT_DOWN},
        [PROTOCOL.SVR_MATCH_AI]              = {handler(self,HallServer.SVR_MATCH_AI),nk.eventNames.SVR_MATCH_AI},
        [PROTOCOL.SVR_MATCH_CACEL_AI_RESULT]      = {handler(self,HallServer.SVR_MATCH_CACEL_AI_RESULT),nk.eventNames.SVR_MATCH_CACEL_AI_RESULT},
        [PROTOCOL.SVR_MATCH_LEFT_NUM_FORCE_EXIT_GAME] = {handler(self,HallServer.SVR_MATCH_LEFT_NUM_FORCE_EXIT_GAME),nk.eventNames.SVR_MATCH_LEFT_NUM_FORCE_EXIT_GAME},
        [PROTOCOL.SVR_MATCH_FORCE_EXIT_GAME_RESULT] = {handler(self,HallServer.SVR_MATCH_FORCE_EXIT_GAME_RESULT),nk.eventNames.SVR_MATCH_FORCE_EXIT_GAME_RESULT},
		[PROTOCOL.SVR_SUONA_BROADCAST] = {handler(self, HallServer.SVR_SUONA_BROADCAST_RECV), nk.eventNames.SVR_SUONA_BROADCAST_RECV},
        [PROTOCOL.SVR_GET_GRAB_DEALER_ROOM_OK]  = {handler(self,HallServer.SVR_GET_GRAB_DEALER_ROOM_OK),nk.eventNames.SVR_GET_GRAB_DEALER_ROOM_OK},
        [PROTOCOL.SVR_LOGIN_GRAB_ROOM_OK]   = {handler(self,HallServer.SVR_LOGIN_GRAB_ROOM_OK),nk.eventNames.SVR_LOGIN_GRAB_ROOM_OK},
        [PROTOCOL.SVR_LOGIN_GRAB_DELAER_ROOM_FAIL] = {handler(self,HallServer.SVR_LOGIN_GRAB_DELAER_ROOM_FAIL),nk.eventNames.SVR_LOGIN_GRAB_DELAER_ROOM_FAIL},
        [PROTOCOL.SVR_GRAB_ROOM_GAME_START] = {handler(self, HallServer.SVR_GRAB_ROOM_GAME_START), nk.eventNames.SVR_GRAB_ROOM_GAME_START},
        [PROTOCOL.SVR_REQUEST_GRAB_DEALER_RESULT] = {handler(self,HallServer.SVR_REQUEST_GRAB_DEALER_RESULT),nk.eventNames.SVR_REQUEST_GRAB_DEALER_RESULT},
        [PROTOCOL.SVR_BROADCAST_RE_GRAB_DEALER_USER] = {handler(self,HallServer.SVR_BROADCAST_RE_GRAB_DEALER_USER),nk.eventNames.SVR_BROADCAST_RE_GRAB_DEALER_USER},
        [PROTOCOL.SVR_BROADCAST_GRAB_PLAYER] = {handler(self,HallServer.SVR_BROADCAST_GRAB_PLAYER),nk.eventNames.SVR_BROADCAST_GRAB_PLAYER},
        [PROTOCOL.SVR_BROADCAST_CAN_GRAB_DEALER] = {handler(self,HallServer.SVR_BROADCAST_CAN_GRAB_DEALER),nk.eventNames.SVR_BROADCAST_CAN_GRAB_DEALER},
        [PROTOCOL.SVR_EXIT_DELAER_FAIL] = {handler(self,HallServer.SVR_EXIT_DELAER_FAIL),nk.eventNames.SVR_EXIT_DELAER_FAIL},
        [PROTOCOL.SVR_WARRING_DEALER_ADD_COIN] = {handler(self,HallServer.SVR_WARRING_DEALER_ADD_COIN),nk.eventNames.SVR_WARRING_DEALER_ADD_COIN},
        [PROTOCOL.SVR_PLAYER_ADD_COIN_RESULT] = {handler(self,HallServer.SVR_PLAYER_ADD_COIN_RESULT),nk.eventNames.SVR_PLAYER_ADD_COIN_RESULT},
        [PROTOCOL.SVR_GRAB_ROOM_LIST_RESULT] = {handler(self,HallServer.SVR_GRAB_ROOM_LIST_RESULT),nk.eventNames.SVR_GRAB_ROOM_LIST_RESULT},
        [PROTOCOL.SVR_DEALER_SITDOWN_FAIL] = {handler(self,HallServer.SVR_DEALER_SITDOWN_FAIL),nk.eventNames.SVR_DEALER_SITDOWN_FAIL},
        [PROTOCOL.SVR_JOIN_MATCH_WAIT] = {handler(self,HallServer.SVR_JOIN_MATCH_WAIT),nk.eventNames.SVR_JOIN_MATCH_WAIT},
        [PROTOCOL.SVR_PUSH_MATCH_ROOM] = {handler(self,HallServer.SVR_PUSH_MATCH_ROOM),nk.eventNames.SVR_PUSH_MATCH_ROOM},
        [PROTOCOL.SVR_PUSH_CHANGE_MATCH_ROOM] = {handler(self,HallServer.SVR_PUSH_CHANGE_MATCH_ROOM),nk.eventNames.SVR_PUSH_CHANGE_MATCH_ROOM},
        [PROTOCOL.SVR_WAIT_MATCH_GAME] = {handler(self,HallServer.SVR_WAIT_MATCH_GAME),nk.eventNames.SVR_WAIT_MATCH_GAME},
        [PROTOCOL.SVR_TIME_MATCH_RANK] = {handler(self,HallServer.SVR_TIME_MATCH_RANK),nk.eventNames.SVR_TIME_MATCH_RANK},
        [PROTOCOL.SVR_TIME_MATCH_OFF] = {handler(self,HallServer.SVR_TIME_MATCH_OFF),nk.eventNames.SVR_TIME_MATCH_OFF},
        [PROTOCOL.SVR_GET_DEALER_ROOM_OK]  = {handler(self,HallServer.SVR_GET_DEALER_ROOM_OK),nk.eventNames.SVR_GET_DEALER_ROOM_OK},
        [PROTOCOL.SVR_LOGIN_NEW_ROOM_OK] = {handler(self,HallServer.SVR_LOGIN_NEW_ROOM_OK),nk.eventNames.SVR_LOGIN_NEW_ROOM_OK},
        [PROTOCOL.SVR_BROAD_DEALER_STAND] = {handler(self,HallServer.SVR_BROAD_DEALER_STAND),nk.eventNames.SVR_BROAD_DEALER_STAND},
        [PROTOCOL.SVR_OFF_LINE_RESULT] = {handler(self,HallServer.SVR_OFF_LINE_RESULT),nk.eventNames.SVR_OFF_LINE_RESULT}
    }
end

function HallServer:onReconnnecting()

    if nk and nk.CommonTipManager then
        nk.CommonTipManager:playReconnectingAnim(true,bm.LangUtil.getText("COMMON","ERROR_NETWORK_RECONNECT","\n"))
    end

end

-- 登录
function HallServer:login()   
    if self.loginTimeoutHandle_ then
        scheduler.unscheduleGlobal(self.loginTimeoutHandle_)
        self.loginTimeoutHandle_ = nil
    end
    self.loginTimeoutHandle_ = scheduler.performWithDelayGlobal(function()       
        self.loginTimeoutHandle_ = nil
        self:onFail_(consts.SVR_ERROR.ERROR_LOGIN_TIME_OUT)
        self:disconnect()
    end, 5)

    local uid = nk.userData.uid   
    local userInfo = nk.getUserInfo()
    local pack = self:createPacketBuilder(PROTOCOL.CLI_LOGIN)
        :setParameter("uid", uid)
        :setParameter("userInfo", json.encode(userInfo))       
        :build()
    self:send(pack)
end

function HallServer:isLogin()
    return self.isLogin_
end

function HallServer:onProcessPacket(pack)
    print("HallServer:onProcessPacket")
    self:callFunc(pack)
    if nk and nk.CommonTipManager then
        nk.CommonTipManager:playReconnectingAnim(false)
    end
end

function HallServer:callFunc(pack)
    if self.func_[pack.cmd] and self.func_[pack.cmd][1] then
        self.func_[pack.cmd][1](pack)
        if self.func_[pack.cmd][2] then
            bm.EventCenter:dispatchEvent({name=self.func_[pack.cmd][2], data=pack})
        end
    end
end

function HallServer:SVR_DOUBLE_LOGIN(pack)
    if self.loginTimeoutHandle_ then
        scheduler.unscheduleGlobal(self.loginTimeoutHandle_)
        self.loginTimeoutHandle_ = nil
    end    
    self:disconnect()
end

function HallServer:SVR_LOGIN_OK(pack)

    if self.loginTimeoutHandle_ then
        scheduler.unscheduleGlobal(self.loginTimeoutHandle_)
        self.loginTimeoutHandle_ = nil
    end
    --nk.TopTipManager:showTopTip(T("服务器登录成功"))
    self:scheduleHeartBeat(PROTOCOL.CLISVR_HEART_BEAT, 10, 3)
    self.isLogin_ = true
end

function HallServer:SVR_ONLINE(pack)

end

function HallServer:SVR_GET_ROOM_OK(pack)
    if pack.tid > 0 then
        self:loginRoom(pack.tid)
    else
        --获取房间id失败    
        bm.EventCenter:dispatchEvent({name=nk.eventNames.SVR_LOGIN_ROOM_FAIL, data = {errno = 9}})
    end
end

function HallServer:SVR_LOGIN_ROOM_OK(pack)

end

function HallServer:SVR_LOGIN_ROOM_FAIL(pack)
    dump(pack.errno,"errorNum")
end

function HallServer:SVR_LOGOUT_ROOM_OK(pack)
    --退出房间同步钱数
    -- nk.userData['aUser.money'] = pack.money
    -- dump(pack, "HallServer:SVR_LOGOUT_ROOM_OK.pack :=================")
    self.getUserinfoRequestId_ = nk.http.getMemberInfo(nk.userData["aUser.mid"], function(retData)
        nk.http.cancel(self.getUserinfoRequestId_)
        nk.userData["aUser.money"] = retData.aUser.money or nk.userData["aUser.money"] or 0
        nk.userData["aUser.gift"] = retData.aUser.gift or nk.userData["aUser.gift"] or 0
        nk.userData['match.point'] = retData.match.point
        nk.userData['match.highPoint'] = retData.match.highPoint
    end, function(errorData)
        nk.http.cancel(self.getUserinfoRequestId_)
    end)
end

function HallServer:SVR_SEAT_DOWN(pack)
end

function HallServer:SVR_STAND_UP(pack)
end

function HallServer:SVR_OTHER_CARD(pack)
end

function HallServer:SVR_SET_BET(pack)
end

function HallServer:SVR_MSG(pack)
end

function HallServer:SVR_DEAL(pack)
end

function HallServer:SVR_LOGIN_ROOM(pack)    
end

function HallServer:SVR_LOGOUT_ROOM(pack)    
end

function HallServer:SVR_SELF_SEAT_DOWN_OK(pack)    
end

function HallServer:SVR_OTHER_STAND_UP(pack)  
    dump(pack,"SVR_OTHER_STAND_UP 0x6004")  
end

function HallServer:SVR_OTHER_OFFLINE(pack)    
end

function HallServer:SVR_GAME_START(pack)    
end

function HallServer:SVR_GAME_OVER(pack)    
end

function HallServer:SVR_BET(pack)    
end

function HallServer:SVR_CAN_OTHER_CARD(pack)    
end

function HallServer:SVR_OTHER_OTHER_CARD(pack)    
end

function HallServer:SVR_SHOW_CARD(pack)    
end

function HallServer:SVR_CARD_NUM(pack)    
end

function HallServer:SVR_ROOM_BROADCAST(pack)
   
end


function HallServer:SVR_COMMON_BROADCAST(pack)
    if pack then
        local mtype = pack.mtype
        if mtype == 1 then
            --支付成功广播加钱
            if pack.info then
                local pInfo = json.decode(pack.info)
                local money = pInfo.money
                local addMoney = pInfo.addMoney
                if nk and nk.userData then
                    nk.userData["aUser.money"] = money
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("STORE", "DELIVERY_SUCC_MSG"))
                end

                if nk.userData.best then
                    nk.userData.best.paylog = 1 
                    nk.userData.best.ispay = 1    
                end

            end
        elseif mtype == 2 then
            --私人房邀请广播
            -- if pack.info then
            --     local inviteData = json.decode(pack.info)
            --     local inviteName_ = inviteData.name;
            --     local tid = inviteData.tid;
            --     local content_ = bm.LangUtil.getText("HALL","PERSONAL_ROOM_INVITE_CONTENT",inviteName_);
            --     local buttonLabel_ = bm.LangUtil.getText("HALL","PERSONAL_ROOM_TOP_TIPS")[1];
            --     nk.TopTipExManager:showTopTip({text =content_ ,buttonLabel = buttonLabel_,callback = 
            --     function()  
            --         nk.server:loginPersonalRoom(nil,tid)
            --     end})
            -- else
                
            -- end
        elseif mtype == 3 then
            --购买比赛门票
            --{pnid:xx,count:xx,name:xx}
            if pack.info then
                local pInfo = json.decode(pack.info)
                if pInfo and pInfo.pnid and pack.count and pack.name then
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("STORE", "DELIVERY_SUCC_MSG"))
                end

                if nk.userData.best then
                    nk.userData.best.paylog = 1 
                end
            end

        elseif mtype == 4 then
            --比赛场邀请
            -- if pack.info then
            --     local pInfo = json.decode(pack.info)
            --     if pInfo and pInfo.id then
                   
            --     end
            -- end

        elseif mtype == 5 then
            --设置是否禁言,msta == 2:禁言
            if pack.info then
                local pInfo = json.decode(pack.info)
                if pInfo and pInfo.msta then
                    local silenced = checkint(pInfo.msta)
                    nk.userData.silenced = (silenced == 2) and 1 or 0
                end
            end
            
        elseif mtype == 6 then
            --现金币购买成功
            if pack.info then
                local pInfo = json.decode(pack.info)
                if pInfo and pInfo.point and pack.addpoint then
                    nk.userData["match.point"] = checkint(pInfo.point)
                     if nk.userData.match then
                        nk.userData.match.point = checkint(pInfo.point)
                    end
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("STORE", "DELIVERY_SUCC_MSG"))

                    if nk.userData.best then
                        --标记为付费用户
                        nk.userData.best.paylog = 1 
                    end

                end

                
            end

        end
    end
    -- dump(pack,"SVR_COMMON_BROADCAST===================");
end

function HallServer:SVR_GET_PERSONAL_ROOM_LIST(pack)


end

function HallServer:SVR_CREATE_PERSONAL_ROOM(pack)
   
end

function HallServer:SVR_LOGIN_PERSONAL_ROOM(pack)
    local ret = pack.ret
    local tid = pack.tid

    --0成功 1房间不存在 2玩家已在某个房间 3房间已满 4密码错误
    if ret == 0 then
        nk.server:loginRoom(tid)
    elseif ret == 1 then

        nk.TopTipManager:showTopTip(bm.LangUtil.getText("HALL", "PERSONAL_NOROOM"))
    elseif ret == 2 then


    elseif ret == 3 then



    elseif ret == 4 then 
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("HALL", "PERSONAL_ENTER_PSW_ERR"))

    end
end


function HallServer:SVR_SEARCH_PERSONAL_ROOM(pack)
    
end


function HallServer:SVR_CHECK_JION_MATCH(pack)
    -- dump(pack,"SVR_CHECK_JION_MATCH")
    if not pack then
        return
    end

    local matchid = pack.matchid
    local tid = pack.tid
    if (matchid and matchid > 0) and (tid and tid > 0) then
        local uid = nk.userData.uid   
        local strinfo = json.encode(nk.getUserInfo())
        -- nk.server:pause()
        -- self:loadMatchRoomTexture_()
        self:loginMatchRoom(uid,matchid,tid,(strinfo or ""))
        
    end

end


function HallServer:SVR_LOGIN_MATCH_ROOM_OK(pack)
    dump(pack,"HallServer:SVR_LOGIN_MATCH_ROOM_OK(7052).pack :===============")
end
function HallServer:SVR_MATCH_BROAD_RANK(pack)
    
end
function HallServer:SVR_TIME_MATCH_RANK(pack)
end
function HallServer:SVR_LOGIN_MATCH_ROOM_FAIL(pack)
end
function HallServer:SVR_TIME_MATCH_OFF(pack)
    nk.TopTipManager:showTopTip(T("比赛人数不足,已经取消:"))
end

function HallServer:SVR_LOGIN_OK_NEW(pack)
    dump(pack,"HallServer:SVR_LOGIN_OK_NEW 202")
    if self.loginTimeoutHandle_ then
        scheduler.unscheduleGlobal(self.loginTimeoutHandle_)
        self.loginTimeoutHandle_ = nil
    end
    --nk.TopTipManager:showTopTip(T("服务器登录成功"))
    self:scheduleHeartBeat(PROTOCOL.CLISVR_HEART_BEAT, 10, 3)
    self.isLogin_ = true

end
function HallServer:SVR_LOGIN_OK_RE_CONECT(pack)
    dump(pack,"HallServer:SVR_LOGIN_OK_RE_CONECT(204).pack :===============")
    if self.loginTimeoutHandle_ then
        scheduler.unscheduleGlobal(self.loginTimeoutHandle_)
        self.loginTimeoutHandle_ = nil
    end
    --nk.TopTipManager:showTopTip(T("服务器登录成功"))
    self:scheduleHeartBeat(PROTOCOL.CLISVR_HEART_BEAT, 10, 3)
    self.isLogin_ = true
end
function HallServer:SVR_MATCH_SET_BET(pack)
    
end

function HallServer:SVR_MATCH_QUIT(pack)
    -- body
end

function HallServer:SVR_MATCH_THIRD_CARD(pack)
    -- body
end


function HallServer:SVR_MATCH_DEAL(pack)
    
end

function HallServer:SVR_MATCH_SEAT_DOWN(pack)

end


function HallServer:SVR_MATCH_GAME_START(pack)
 
end

function HallServer:SVR_MATCH_PRE_CALL(pack)
    
end

function HallServer:SVR_MATCH_CARD_NUM(pack)
    
end

function HallServer:SVR_MATCH_TURN_BET(pack)
   
end


function HallServer:SVR_MATCH_BET(pack)
    
end

function HallServer:SVR_MATCH_CAN_THIRD_CARD(pack)
 
end

function HallServer:SVR_MATCH_OTHER_THIRD_CARD(pack)

end

function HallServer:SVR_MATCH_SHOW_CARD(pack)
    
end

function HallServer:SVR_MATCH_BROAD_QUIT(pack)
    
end

function HallServer:SVR_MATCH_POT(pack)
    
end

function HallServer:SVR_MATCH_KNOCK_OUT(pack)
    
end

function HallServer:SVR_MATCH_GAME_OVER(pack)
    
end

function HallServer:SVR_MATCH_COUNT_DOWN(pack)
    
end
function HallServer:SVR_MATCH_AI(pack)

end
function HallServer:SVR_MATCH_CACEL_AI_RESULT(pack)
    
end
function HallServer:SVR_MATCH_LEFT_NUM_FORCE_EXIT_GAME(pack)

end
function HallServer:SVR_MATCH_FORCE_EXIT_GAME_RESULT(pack)

end

function HallServer:SVR_SUONA_BROADCAST_RECV(pack)
    -- body
    -- dump(pack, "suonaPackInfo :================")
end

function HallServer:SVR_GET_GRAB_DEALER_ROOM_OK(pack)
    --nk.TopTipManager:showTopTip("0x0211..tid="..pack.tid)
    dump(pack, "HallServer:SVR_GET_GRAB_DEALER_ROOM_OK(211).pack :================")
    if pack.tid > 0 then
        self:loginGrabDealerRoom(pack.tid)
    else
        --获取房间id失败    
        bm.EventCenter:dispatchEvent({name=nk.eventNames.SVR_LOGIN_ROOM_FAIL, data = {errno = 9}})
    end
end

function HallServer:SVR_GET_DEALER_ROOM_OK(pack)
    dump(pack.tid, "SERVER 212 命令收到登录房间tid :==================")
     if pack.tid > 0 then
        self:loginGrabDealerRoom(pack.tid)
    else
        --获取房间id失败    
        bm.EventCenter:dispatchEvent({name=nk.eventNames.SVR_LOGIN_ROOM_FAIL, data = {errno = 9}})
    end
end

function HallServer:SVR_LOGIN_GRAB_DELAER_ROOM_FAIL(pack)
    dump(pack, "HallServer:SVR_LOGIN_GRAB_DELAER_ROOM_FAIL(1053).pack :==================")

    self:getGrabDealerRoomAndLogin(nil, - 1)
end

function HallServer:SVR_LOGIN_GRAB_ROOM_OK( pack )
    -- body
    dump(pack,"HallServer:SVR_LOGIN_GRAB_ROOM_OK(1075).pack :==================")
end

function HallServer:SVR_LOGIN_NEW_ROOM_OK(pack)
    dump(pack, "HallServer:SVR_LOGIN_NEW_ROOM_OK(1078).pack :=================")
end

function HallServer:SVR_BROAD_DEALER_STAND(pack)
    --nk.TopTipManager:showTopTip(T("您已连续当庄50局,休息一会给别人一个机会吧"))
    nk.TopTipManager:showTopTip(T("คุณเป็นเจ้าต่อเนื่อง 50 ตาแล้ว กรุณาให้ผู้เล่นอื่นๆลองเป็นเจ้านะ"))
end

function HallServer:SVR_OFF_LINE_RESULT(pack)
   -- bm.DataProxy:setData(nk.dataKeys.OFF_LINE_RESULT_TIP, pack)

   self.offLineHandle_ = scheduler.performWithDelayGlobal(function()       
        self.offLineHandle_ = nil
            if pack.iscash == 1 then
                if pack.totalMoney > 0 then
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM","OFF_LINE_TIPS_3",pack.totalMoney))
                else
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM","OFF_LINE_TIPS_4",pack.totalMoney))
                end
            else
                if pack.totalMoney > 0 then
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM","OFF_LINE_TIPS_1",pack.totalMoney))
                else
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM","OFF_LINE_TIPS_2",pack.totalMoney))
                end
            end

    end, 7)


    
end
function HallServer:SVR_GRAB_ROOM_GAME_START(pack)

end
function HallServer:SVR_REQUEST_GRAB_DEALER_RESULT(pack)

end
function HallServer:SVR_BROADCAST_RE_GRAB_DEALER_USER(pack)

end
function HallServer:SVR_BROADCAST_GRAB_PLAYER(pack)

end
function HallServer:SVR_BROADCAST_CAN_GRAB_DEALER(pack)

end
function HallServer:SVR_EXIT_DELAER_FAIL(pack)
    dump("HallServer:SVR_EXIT_DELAER_FAIL.pack :==============")
end
function HallServer:SVR_WARRING_DEALER_ADD_COIN(pack)

end
function HallServer:SVR_PLAYER_ADD_COIN_RESULT(pack)
    dump(pack,"SVR 1060")
end
function HallServer:SVR_GRAB_ROOM_LIST_RESULT(pack)
     dump(pack,"SVR_GRAB_ROOM_LIST_RESULT===========")
end
function HallServer:SVR_DEALER_SITDOWN_FAIL(pack)
    
end
function HallServer:SVR_JOIN_MATCH_WAIT(pack)
    dump(pack,"SVR_JOIN_MATCH_WAIT 0x0218")
end
function HallServer:SVR_PUSH_MATCH_ROOM(pack)
    dump(pack,"SVR_PUSH_MATCH_ROOM 0x0219")
end
function HallServer:SVR_PUSH_CHANGE_MATCH_ROOM(pack)
    --比赛合桌
    nk.TopTipManager:showTopTip("กำลังรวมโต๊ะ")
   -- dump(pack,"SVR_PUSH_CHANGE_MATCH_ROOM 0x7829")
end
function HallServer:SVR_WAIT_MATCH_GAME(pack)
    --dump(pack,"SVR_WAIT_MATCH_GAME 0x7830")
    --比赛暂停，等待合桌
    nk.TopTipManager:showTopTip("การแข่งขอหยุดชั่วคราว รอรวมโต๊ะ")
end
-- 获取在线
function HallServer:getOnline(levelIds)  
    local pack = self:createPacketBuilder(PROTOCOL.CLI_GET_ONLINE)
        :setParameter("levels", levelIds)       
        :build()
    self:send(pack) 
end

-- 登录桌子
function HallServer:getRoomAndLogin(level, tid)
    dump(level,"指定登录场次:")
    self.isPlayNow_ = false
    local targetid,type
    if tid > 0 then  -- 指定登录哪一桌
        targetid = tid
        type = 1
    else             -- 随机登陆
        targetid = 0
        type = 0
    end
    local pack = self:createPacketBuilder(PROTOCOL.CLI_GET_ROOM)
        :setParameter("level", level)
        :setParameter("type", type)
        :setParameter("targetid", targetid)
        :build()
    self:send(pack)
end

-- 换桌子
function HallServer:changeRoomAndLogin(level, tid)
    local pack = self:createPacketBuilder(PROTOCOL.CLI_CHANGE_ROOM)
        :setParameter("level", level)
        :setParameter("tid", tid)        
        :build()
    self:send(pack)
end
-- 快速开始
function HallServer:quickPlay()
    local level = nk.getRoomLevelByMoney2(nk.userData["aUser.money"])
    self:getRoomAndLogin(level, 0)
    self.isPlayNow_ = true
end

function HallServer:isPlayNow()
    return self.isPlayNow_
end

function HallServer:loginRoom(tid)
    dump(tid,"tid=======")
    local pack = self:createPacketBuilder(PROTOCOL.CLI_LOGIN_ROOM)
        :setParameter("tid", tid)       
        :setParameter("uid", nk.userData.uid)
        :setParameter("mtkey", nk.userData.sesskey)
        :setParameter("strinfo", json.encode(nk.getUserInfo()))
        :setParameter("extrainfo", "")
        :build()
    self:send(pack) 
end

function HallServer:logoutRoom()
    local pack = self:createPacketBuilder(PROTOCOL.CLI_LOGOUT_ROOM):build()
    self:send(pack) 
end

function HallServer:seatDown(seatId, bet, autoBuyin)
    if autoBuyin then
        autoBuyin = 1
    else
        autoBuyin = 0
    end
    local pack = self:createPacketBuilder(PROTOCOL.CLI_SEAT_DOWN)
        :setParameter("seatId", seatId)
        :setParameter("ante", bet)
        :setParameter("autoBuyin", autoBuyin)
        :build()
    self:send(pack)   
end

function HallServer:reqOtherCard(type)
    local pack = self:createPacketBuilder(PROTOCOL.CLI_OTHER_CARD)
        :setParameter("type", type)      
        :build()
    self:send(pack)   
end

function HallServer:setBet(bet)
    local pack = self:createPacketBuilder(PROTOCOL.CLI_SET_BET)
        :setParameter("ante", bet)      
        :build()
    self:send(pack)   
end

function HallServer:sendMsg(type, msg)
    local pack = self:createPacketBuilder(PROTOCOL.CLI_SEND_MSG)
        :setParameter("type", type)    
        :setParameter("strChat", msg)  
        :build()
    self:send(pack)   
end

function HallServer:standUp()
    local pack = self:createPacketBuilder(PROTOCOL.CLI_STAND_UP)      
        :build()
    self:send(pack)   
end

function HallServer:onAfterConnected()   
    self:login()
    if nk and nk.CommonTipManager then
        nk.CommonTipManager:playReconnectingAnim(false)
    end
end

function HallServer:onAfterConnectFailure()
    self:onFail_(consts.SVR_ERROR.ERROR_CONNECT_FAILURE)
    if nk and nk.CommonTipManager then
        nk.CommonTipManager:playReconnectingAnim(false)
    end
end

function HallServer:onClosed(evt)
    self.isLogin_ = false
    HallServer.super.onClosed(self, evt)
    if nk and nk.CommonTipManager then
        nk.CommonTipManager:playReconnectingAnim(false)
    end
end

function HallServer:onClose(evt)
    self:unscheduleHeartBeat()
    if nk and nk.CommonTipManager then
        nk.CommonTipManager:playReconnectingAnim(false)
    end
end

function HallServer:buildHeartBeatPack()
    return self:createPacketBuilder(PROTOCOL.CLISVR_HEART_BEAT):build()
end

function HallServer:onHeartBeatTimeout(timeoutCount)
     bm.DataProxy:setData(nk.dataKeys.SIGNAL_STRENGTH, 0)
    if timeoutCount >= 3 then
        self:onFail_(consts.SVR_ERROR.ERROR_HEART_TIME_OUT)
        self:disconnect()
    end
end

function HallServer:onHeartBeatReceived(delaySeconds)
     local signalStrength
    if delaySeconds < 0.4 then
        signalStrength = 4
    elseif delaySeconds < 0.8 then
        signalStrength = 3
    elseif delaySeconds < 1.2 then
        signalStrength = 2
    else
        signalStrength = 1
    end
    -- self.heartBeatCount_ = self.heartBeatCount_ + 1
    -- self.heartBeatDelay_ = self.heartBeatDelay_ + delaySeconds
    bm.DataProxy:setData(nk.dataKeys.SIGNAL_STRENGTH, signalStrength)
    if nk and nk.CommonTipManager then
        nk.CommonTipManager:playReconnectingAnim(false)
    end
end

function HallServer:onFail_(errorCode)   
    bm.EventCenter:dispatchEvent({name=nk.eventNames.SVR_ERROR, data=errorCode})
end

function HallServer:syncUserMoney(allMoney)
    nk.userData.money = allMoney
    if nk.userData.money > nk.userData.maxmoney then
        nk.userData.maxmoney = nk.userData.money
    end
end

function HallServer:sendRoomBroadCast_(content)
    local pack = self:createPacketBuilder(PROTOCOL.CLI_SEND_ROOM_BROADCAST)
        :setParameter("info", content)
        :build()
    self:send(pack)
end

function HallServer:sendRoomChat(msg)
    local info = {}
    info.mtype = 1
    info.msg = msg
    info.name = nk.userData["aUser.name"]
    self:sendRoomBroadCast_(json.encode(info))
end

function HallServer:sendRoomGift(giftId,tuids)
    local info =  {}
    info.mtype = 3
    info.giftId = giftId
    info.tuids = tuids
    self:sendRoomBroadCast_(json.encode(info))
end

function HallServer:updateRoomGift(giftId,uid)
    local info = {}
    info.mtype = 4
    info.giftId = giftId
    info.uid = uid
    self:sendRoomBroadCast_(json.encode(info))
end

function HallServer:sendExpression(fType, faceId)
    local info = {}
    info.mtype = 5
    info.fType = fType -- 1: 常规, 2: A类, 3: B类
    info.faceId = faceId
    self:sendRoomBroadCast_(json.encode(info))
end

--发送互动表情
function HallServer:sendProp(pid,toSeatIds,pnid)
    local info = {}
    info.mtype = 6
    info.pid = pid --客户端道具标示
    info.pnid = pnid --PHP的道具ID
    info.toSeatIds = toSeatIds
    self:sendRoomBroadCast_(json.encode(info))
end


--发送荷官小费
function HallServer:sendDealerChip(fee,num)
    local info = {}
    info.mtype = 7
    info.fee = fee
    info.num = num
    self:sendRoomBroadCast_(json.encode(info))
end


--添加好友
function HallServer:sendAddFriend(tseatId)
    local info = {};
    info.mtype = 8
    info.tseatId = tseatId
    self:sendRoomBroadCast_(json.encode(info))
end

--房间内赠送筹码
function HallServer:sendCoinForRoomPlayer(geterId,chips)
    local info = {}
    info.mtype = 9
    info.geterId=geterId
    info.chips = chips
    self:sendRoomBroadCast_(json.encode(info))
end

--请求获取私人房列表
function HallServer:getPersonalRoomList(level,page,num)
    level = level or consts.ROOM_TYPE.PERSONAL_NORMAL
    page = page or 1
    num = num or 50

    local pack = self:createPacketBuilder(PROTOCOL.CLI_GET_PERSONAL_ROOM_LIST)
        :setParameter("level", level)
        :setParameter("page", page)
        :setParameter("num", num)
        :build()
    self:send(pack)
end

--请求创建私人房
function HallServer:createPersonalRoom(level,baseChip,roomName,pwd)
    level = level or consts.ROOM_TYPE.PERSONAL_NORMAL
    baseChip = baseChip or 100
    roomName = roomName or ""
    pwd = pwd or ""

    local pack = self:createPacketBuilder(PROTOCOL.CLI_CREATE_PERSONAL_ROOM)
        :setParameter("level", level)
        :setParameter("baseChip", baseChip)
        :setParameter("roomName", roomName)
        :setParameter("pwd", pwd)
        :build()
    self:send(pack)
end

function HallServer:loginPersonalRoom(level,tableID,pwd)
    level = level or consts.ROOM_TYPE.PERSONAL_NORMAL  
    tableID = tableID or 0
    pwd = pwd or ""
    local pack = self:createPacketBuilder(PROTOCOL.CLI_LOGIN_PERSONAL_ROOM)
        :setParameter("level", level)
        :setParameter("tableID", tableID)
        :setParameter("pwd", pwd)
        :build()
    self:send(pack)
end

function HallServer:searchPersonalRoom(level,tableID)
    level = level or consts.ROOM_TYPE.PERSONAL_NORMAL
    roomID = roomID or 0
    local pack = self:createPacketBuilder(PROTOCOL.CLI_SEARCH_PERSONAL_ROOM)
        :setParameter("level", level)
        :setParameter("tableID", tableID)
        :build()
    self:send(pack)
end



-----------------------比赛场-----------------------

function HallServer:checkJoinMatch(matchid)
    dump(matchid,"checkJoinMatch")
     local pack = self:createPacketBuilder(PROTOCOL.CLI_CHECK_JION_MATCH)
          :setParameter("matchid",matchid)
          :build()
    self:send(pack)
end

--用户请求进入定时赛
function HallServer:joinMatchWait(matchid)
    local pack = self:createPacketBuilder(PROTOCOL.CLI_JOIN_ROOM_WAIT)
    :setParameter("matchid",matchid)
    :build()
    self:send(pack)
end

function HallServer:loginMatchRoom(uid,matchid,tid,strinfo)
    local pack = self:createPacketBuilder(PROTOCOL.CLI_LOGIN_MATCH_ROOM)
          :setParameter("tid",tid)
          :setParameter("uid",uid)
          :setParameter("matchid",matchid)
          :setParameter("strinfo",strinfo)
          :build()
    self:send(pack)
end


function HallServer:matchQuit()
    local pack = self:createPacketBuilder(PROTOCOL.CLI_MATCH_QUIT)
          :build()
    self:send(pack)
end


function HallServer:matchThirdCard(mtype)
    local pack = self:createPacketBuilder(PROTOCOL.CLI_MATCH_THIRD_CARD)
          :setParameter("type",mtype)
          :build()
    self:send(pack)
end


function HallServer:matchSetBet(betState,anteNum)

    dump(betState,"matchSetBet:betState")
    dump(anteNum,"matchSetBet:anteNum")
    local pack = self:createPacketBuilder(PROTOCOL.CLI_MATCH_SET_BET)
        :setParameter("betState", betState)
        :setParameter("anteNum", anteNum)       
        :build()
    self:send(pack)   
end


function HallServer:matchReqThirdCard(type)
    local pack = self:createPacketBuilder(PROTOCOL.CLI_MATCH_THIRD_CARD)
        :setParameter("type", type)      
        :build()
    self:send(pack)
end
function HallServer:matchCancelAI()
    local pack = self:createPacketBuilder(PROTOCOL.CLI_MATCH_CANCEL_AI)
            :build()
    self:send(pack)
end

function HallServer:matchExitGetLeftTime()
     local pack = self:createPacketBuilder(PROTOCOL.CLI_MATCH_GET_LEFT_GAME_EXIT)
            :build()
    self:send(pack)
end

function HallServer:matchForceExitGame()
     local pack = self:createPacketBuilder(PROTOCOL.CLI_MATCH_PORCE_EXIT_GAME)
            :build()
    self:send(pack)
end


-----------------------比赛场-----------------------

------------------------上庄场--------------------------
--请求房间列表
function HallServer:requestGrabRoomList(cash,page,num,isnew)
    local currentPage = page or 1
    local pageNum = num or 20
    local isCash = cash or 2
    isnew = isnew or 1 --默认是新版本

    local pack = self:createPacketBuilder(PROTOCOL.CLI_REQUEST_GRAB_ROOM_LIST_NEW)
        :setParameter("page", currentPage)
        :setParameter("num", pageNum)
        :setParameter("cash",isCash)
        :setParameter("isnew",isnew)
        :build()
    self:send(pack)
end


-- 请求抢庄场桌子
function HallServer:getGrabDealerRoomAndLogin(level, tid)

    local level = level or 301
    self.isPlayNow_ = false

    local targetid, type
    if tid > 0 then  -- 指定登录哪一桌
        targetid = tid
        type = 1
    else             -- 随机登陆
        targetid = 0
        type = 0
    end

    local pack = self:createPacketBuilder(PROTOCOL.CLI_GET_ROOM)
        :setParameter("level", level)
        :setParameter("type", type)
        :setParameter("targetid", targetid)
        :build()
    self:send(pack)
end
---登录抢庄房间请求
function HallServer:loginGrabDealerRoom(tid)   
    dump(tid,  "客户端发送登录:tid===============") 
    local pack = self:createPacketBuilder(PROTOCOL.CLI_LOGIN_GRAB_DEALER_ROOM)
            :setParameter("tid", tid)       
            :setParameter("uid", nk.userData.uid)
            :setParameter("mtkey", nk.userData.sesskey)
            :setParameter("strinfo", json.encode(nk.getUserInfo()))
            :setParameter("extrainfo", "")
            :build()
    self:send(pack)
end
--请求上庄
function HallServer:userGrabDealer(handmoney)
    local pack = self:createPacketBuilder(PROTOCOL.CLI_REQUEST_GRAB_DEALER)
        :setParameter("handCoin", handmoney)
        :build()
    self:send(pack)
end
--庄家补币申请
function HallServer:addDealerHandCoin(addMoney)
    local pack = self:createPacketBuilder(PROTOCOL.CLI_DEALER_ADD_COIN)
        :setParameter("addCoin", addMoney)
        :build()
    self:send(pack)
end
------------------------上庄场--------------------------
return HallServer