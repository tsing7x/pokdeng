--
-- Author: tony
-- Date: 2014-07-10 15:04:44
--
local GrabSeatStateMachine = class("GrabSeatStateMachine")
local logger = bm.Logger.new("GrabSeatStateMachine")

GrabSeatStateMachine.SIT_DOWN = "tra_sitdown"
GrabSeatStateMachine.STAND_UP = "tra_standup"
GrabSeatStateMachine.GAME_START = "tra_gamestart"
GrabSeatStateMachine.GAME_OVER = "tra_gameover"
GrabSeatStateMachine.TURN_TO = "tra_turnto"
GrabSeatStateMachine.GET_POKER = "tra_getpoker" --要牌
GrabSeatStateMachine.CALL = "tra_call"   --下注
GrabSeatStateMachine.ALL_IN = "tra_allin" --all in
GrabSeatStateMachine.SET_DEALER = "tra_setdealer" --指定庄家
GrabSeatStateMachine.SHOW_POKER = "tra_showpoker" --亮牌

GrabSeatStateMachine.STATE_EMPTY        = "st_empty"        --空座
GrabSeatStateMachine.STATE_WAIT_START    = "st_waitstart"    --等待开始
GrabSeatStateMachine.STATE_WAIT_OVER        = "st_waitover" --等待结算
GrabSeatStateMachine.STATE_WAIT_GET    = "st_waitget"    --等待要牌
GrabSeatStateMachine.STATE_GETTING    = "st_getting"    --正在要牌
GrabSeatStateMachine.STATE_ALL_IN         = "st_allin_waitget"        --AllIn
GrabSeatStateMachine.STATE_BETTING         = "st_betting"        --下注中

function GrabSeatStateMachine:ctor(seatData, isturnto, gameStatus)
    seatData.userInfo.name = string.trim(seatData.userInfo.name)
    self.stateDefault_ = nk.Native:getFixedWidthText(ui.DEFAULT_TTF_FONT, 24, seatData.userInfo.name, 100)
    self.statetext_ = self.stateDefault_
    self.seatId_ = seatData.seatId
    local initialState = "st_empty"
    if gameStatus == consts.SVR_GAME_STATUS.READY_TO_START then
        initialState = "st_waitstart"
    elseif gameStatus == 4 then
        initialState = "st_waitstart"
    elseif gameStatus == consts.SVR_GAME_STATUS.BET_ROUND then
        if seatData.isPlay == 1 then
            if seatData.nCurAnte > 0 or seatData.isDealer then
                if seatData.anteMoney == 0 then
                    initialState = "st_allin_waitget"
                else                    
                    initialState = "st_waitget"
                end
            else
                initialState = "st_betting"
            end
        else
            initialState = "st_waitstart"
        end
    elseif gameStatus == consts.SVR_GAME_STATUS.GET_POKER then
        initialState = "st_waitstart"        
        if seatData.isPlay == 1 then
            if seatData.isOutCard == 0 then
                if isturnto then
                    initialState = "st_getting"
                else
                    initialState = "st_waitget"
                end
            else
                --如果是自己能拿第三张牌
               if seatData.isSelf and seatData.HandPoker:canGetCard() then
                    if isturnto then
                        initialState = "st_getting"
                    else
                        initialState = "st_waitget"
                    end
               end             
            end            
        end
    elseif gameStatus == consts.SVR_GAME_STATUS.WAIT_GAME_OVER then
        initialState  = "st_waitstart"
    end    

    dump("initialState :"..initialState.."  seatId:"..self.seatId_.." gameStatus:"..gameStatus)
    self.statemachine_ = {}
    cc.GameObject.extend(self.statemachine_)
        :addComponent("components.behavior.StateMachine")
        :exportMethods()
    self.statemachine_:setupState({
        initial = initialState,
        events = {
            {name="tra_sitdown", from="st_empty", to="st_waitstart"},
            {name="tra_standup", from="*", to="st_empty"},           
            {name="tra_gamestart", from={"st_waitstart"}, to="st_betting"},
            {name="tra_gameover", from={
                "st_allin",
                "st_betting", -- 站起导致结束
                "st_waitstart",
                "st_waitget",
                "st_allin_waitget",
                "st_getting",
                "st_waitover"
            }, to="st_waitstart"},
            {name="tra_showpoker", from={"st_allin_waitget","st_waitget"}, to="st_waitover"},
            {name="tra_setdealer", from="st_betting", to="st_waitget"},
            {name="tra_turnto", from={"st_allin_waitget","st_waitget"}, to="st_getting"}, 
            {name="tra_getpoker", from="st_getting", to="st_waitover"},
            {name="tra_call", from="st_betting", to="st_waitget"},
            {name="tra_allin", from="st_betting", to="st_allin_waitget"},
            {name="reset", from="*", to="st_empty"}
        },
        callbacks = {
            onchangestate = handler(self, self.onChangeState_)
        }
    })
end

function GrabSeatStateMachine:getStateText()
    return self.statetext_
end

function GrabSeatStateMachine:setStateText(txt)
    self.statetext_ = txt
end

function GrabSeatStateMachine:getState()
    return self.statemachine_:getState()
end

function GrabSeatStateMachine:doEvent(name, ...)
    if self.statemachine_:canDoEvent(name) then
        self.statemachine_:doEvent(name, ...)
    else
        logger:errorf("%s Can't do event %s on state %s", self.seatId_, name, self.statemachine_:getState())
        self.statemachine_:doEventForce(name, ...)
    end
end

function GrabSeatStateMachine:onChangeState_(evt)
    logger:debugf("%s do event %s from %s to %s", self.seatId_, evt.name, evt.from, evt.to)
    -- local P = nk.socket.RoomSocket.PROTOCOL
    -- local st = evt.to
    -- local tra = evt.name
    -- local arg = ""
    -- if evt.args and evt.args[1] then
    --     arg = evt.args[1]
    -- end
    -- if checknumber(arg) > 0 then
    --     arg = bm.formatBigNumber(tonumber(arg))
    -- end

    -- if st == GrabSeatStateMachine.STATE_EMPTY then
    --     self.statetext_ = ""
    -- elseif st == GrabSeatStateMachine.STATE_FOLD then
    --     self.statetext_ = bm.LangUtil.getText("ROOM", "FOLD")
    -- elseif st == GrabSeatStateMachine.STATE_ALL_IN then
    --     self.statetext_ = bm.LangUtil.getText("ROOM", "ALL_IN")
    -- elseif st == GrabSeatStateMachine.STATE_BETTING or st == GrabSeatStateMachine.STATE_WAIT_BETTING then
    --     if tra == GrabSeatStateMachine.CHECK then
    --         self.statetext_ = bm.LangUtil.getText("ROOM", "CHECK")
    --     elseif tra == GrabSeatStateMachine.CALL then
    --         self.statetext_ = bm.LangUtil.getText("ROOM", "CALL_NUM", arg)
    --     elseif tra == GrabSeatStateMachine.RAISE then
    --         self.statetext_ = bm.LangUtil.getText("ROOM", "RAISE_NUM", arg)
    --     else
    --         self.statetext_ = self.stateDefault_
    --     end
    -- end
end

return GrabSeatStateMachine
