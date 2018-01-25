--
-- Author: tony
-- Date: 2014-07-10 15:04:44
--
local MatchSeatStateMachine = class("MatchSeatStateMachine")
local logger = bm.Logger.new("MatchSeatStateMachine")

MatchSeatStateMachine.SIT_DOWN = "tra_sitdown"
MatchSeatStateMachine.STAND_UP = "tra_standup"
MatchSeatStateMachine.GAME_START = "tra_gamestart"
MatchSeatStateMachine.GAME_OVER = "tra_gameover"
MatchSeatStateMachine.TURN_TO = "tra_turnto"
MatchSeatStateMachine.FOLD = "tra_fold"
MatchSeatStateMachine.CHECK = "tra_check"
MatchSeatStateMachine.CALL = "tra_call"
MatchSeatStateMachine.RAISE = "tra_raise"
MatchSeatStateMachine.ALL_IN = "tra_allin"

MatchSeatStateMachine.WAIT_GET = "tra_waitget"
MatchSeatStateMachine.GETING = "tra_getting"
MatchSeatStateMachine.SHOW_CARD = "tra_showcard"
MatchSeatStateMachine.PRE_CALL = "tra_precall"



MatchSeatStateMachine.STATE_EMPTY        = "st_empty"        --空座
MatchSeatStateMachine.STATE_WAIT_START    = "st_waitstart"    --等待开始
MatchSeatStateMachine.STATE_WAIT_BETTING    = "st_waitbetting"    --等待下注
MatchSeatStateMachine.STATE_ALL_IN         = "st_allin"        --AllIn
MatchSeatStateMachine.STATE_FOLD         = "st_fold"            --弃牌
MatchSeatStateMachine.STATE_BETTING         = "st_betting"        --下注中
-- MatchSeatStateMachine.PRE_CALL             = "st_precall"        -- 前注
MatchSeatStateMachine.STATE_WAIT_GET    = "st_waitget"    --等待要牌
MatchSeatStateMachine.STATE_GETTING    = "st_getting"    --正在要牌
MatchSeatStateMachine.STATE_PRE_CALL = "st_precall"   --前注

-- function MatchSeatStateMachine:ctor(seatData, isBetting, gameStatus)
function MatchSeatStateMachine:ctor(seatData, isTurnTo, gameStatus)
    seatData.userInfo.name = string.trim(seatData.userInfo.name)
    self.stateDefault_ = nk.Native:getFixedWidthText(ui.DEFAULT_TTF_FONT, 24, seatData.userInfo.name, 100)
    self.statetext_ = self.stateDefault_
    self.seatId_ = seatData.seatId

    local initialState = "st_empty"
    local betState = seatData.betState


    --------------------------------------------------
    if gameStatus == consts.SVR_MATCH_GAME_STATUS.READY_TO_START then
        initialState = "st_waitstart"
        -- dump("st_waitstart","MatchSeatStateMachine")
    elseif gameStatus == consts.SVR_MATCH_GAME_STATUS.PRE_CALL then
        initialState = "st_precall"
         -- dump("st_precall","MatchSeatStateMachine")
    elseif gameStatus == consts.SVR_MATCH_GAME_STATUS.BET_ROUND_1 then
        if isTurnTo then
             initialState = "st_betting"
        else
            initialState = "st_waitbetting"
        end

        -- dump(initialState,"MatchSeatStateMachine:round1")
    elseif gameStatus == consts.SVR_MATCH_GAME_STATUS.GET_POKER then 
        initialState = "st_waitstart"
        if isTurnTo then
             initialState = "st_getting"
        else
            initialState = "st_waitget"
        end
        -- dump(initialState,"MatchSeatStateMachine:round_get")
    elseif gameStatus == consts.SVR_MATCH_GAME_STATUS.BET_ROUND_2 then
        if isTurnTo then
             initialState = "st_betting"
        else
            initialState = "st_waitbetting"
        end
        -- dump(initialState,"MatchSeatStateMachine:round2")
    elseif gameStatus == consts.SVR_MATCH_GAME_STATUS.WAIT_GAME_OVER then
        initialState = "st_waitstart"
        -- dump(initialState,"MatchSeatStateMachine:WAIT_GAME_OVER")
    elseif gameStatus == consts.SVR_MATCH_GAME_STATUS.APPLY then
        initialState = "st_waitstart"
        -- dump(initialState,"MatchSeatStateMachine:APPLY")
    end

    if betState == consts.SVR_BET_STATE.FOLD then
        initialState = "st_fold"
        self.statetext_ = bm.LangUtil.getText("ROOM", "FOLD")
    elseif betState == consts.SVR_BET_STATE.ALL_IN then
        initialState = "st_allin"
        self.statetext_ = bm.LangUtil.getText("ROOM", "ALL_IN")
    elseif betState == consts.SVR_BET_STATE.CALL then
        initialState = "st_waitbetting"
        self.statetext_ = bm.LangUtil.getText("ROOM", "CALL")
    elseif betState == consts.SVR_BET_STATE.SMALL_BLIND then
        initialState = "st_waitbetting"
        self.statetext_ = bm.LangUtil.getText("ROOM", "SMALL_BLIND")
    elseif betState == consts.SVR_BET_STATE.BIG_BLIND then
        initialState = "st_waitbetting"
        self.statetext_ = bm.LangUtil.getText("ROOM", "BIG_BLIND")
    elseif betState == consts.SVR_BET_STATE.CHECK then
        initialState = "st_waitbetting"
        self.statetext_ = bm.LangUtil.getText("ROOM", "CHECK")
    elseif betState == consts.SVR_BET_STATE.RAISE then
        initialState = "st_waitbetting"
        self.statetext_ = bm.LangUtil.getText("ROOM", "RAISE_NUM", bm.formatBigNumber(seatData.betChips))
    end



    dump(initialState,"MatchSeatStateMachine:ctor")



    --------------------------------------------------

    --[[
    if gameStatus == consts.SVR_GAME_STATUS.CAN_NOT_START then
        --重连登录，人还不够开始
        initialState = "st_waitstart"
    elseif gameStatus == consts.SVR_GAME_STATUS.READY_TO_START then
        --重连登录，马上要开始下一轮
        initialState = "st_waitstart"
    elseif isBetting then
        initialState = "st_betting"
    elseif betState == consts.SVR_BET_STATE.WAITTING_START then
        initialState = "st_waitstart"
    elseif betState == consts.SVR_BET_STATE.WAITTING_BET then
        initialState = "st_waitbetting"
    elseif betState == consts.SVR_BET_STATE.FOLD then
        initialState = "st_fold"
        self.statetext_ = bm.LangUtil.getText("ROOM", "FOLD")
    elseif betState == consts.SVR_BET_STATE.ALL_IN then
        initialState = "st_allin"
        self.statetext_ = bm.LangUtil.getText("ROOM", "ALL_IN")
    elseif betState == consts.SVR_BET_STATE.CALL then
        initialState = "st_waitbetting"
        self.statetext_ = bm.LangUtil.getText("ROOM", "CALL")
    elseif betState == consts.SVR_BET_STATE.SMALL_BLIND then
        initialState = "st_waitbetting"
        self.statetext_ = bm.LangUtil.getText("ROOM", "SMALL_BLIND")
    elseif betState == consts.SVR_BET_STATE.BIG_BLIND then
        initialState = "st_waitbetting"
        self.statetext_ = bm.LangUtil.getText("ROOM", "BIG_BLIND")
    elseif betState == consts.SVR_BET_STATE.CHECK then
        initialState = "st_waitbetting"
        self.statetext_ = bm.LangUtil.getText("ROOM", "CHECK")
    elseif betState == consts.SVR_BET_STATE.RAISE then
        initialState = "st_waitbetting"
        self.statetext_ = bm.LangUtil.getText("ROOM", "RAISE_NUM", bm.formatBigNumber(seatData.betChips))
    elseif betState == consts.SVR_BET_STATE.PRE_CALL then
        initialState = "st_waitbetting"
    end
    --]]


    self.statemachine_ = {}
    cc.GameObject.extend(self.statemachine_)
        :addComponent("components.behavior.StateMachine")
        :exportMethods()
    self.statemachine_:setupState({
        initial = initialState,
        events = {
            {name="tra_sitdown", from="st_empty", to="st_waitstart"},
            {name="tra_standup", from="*", to="st_empty"},

            -- 加上后面这几个是因为重连登录的时候没有结束包 "st_allin", "st_fold", "st_waitbetting"
            -- 注释和代码不一致, 不确定这里是否有bug (david Apr 20)
            -- {name="tra_gamestart", from={"st_waitstart", }, to="st_waitbetting"},
            {name="tra_gamestart", from={"st_waitstart"}, to="st_precall"},
            {name ="tra_precall",from = "st_betting",to = "st_waitbetting"},

            {name="tra_gameover", from={
                "st_allin", "st_fold",
                "st_waitbetting", -- 站起导致结束
                "st_betting", "st_waitstart","st_getting","st_waitget","st_waitover","st_precall"
            }, to="st_waitstart"},

            {name = "tra_waitget",from = {"st_getting"},to = "st_waitget"},
            {name = "tra_getting",from = {"st_waitbetting","st_allin","st_waitget"},to = "st_getting"},
            {name="tra_turnto", from={"st_waitbetting","st_getting","st_precall","st_waitget"}, to="st_betting"},
            {name="tra_fold", from={"st_betting","st_getting"}, to="st_fold"},
            {name="tra_check", from="st_betting", to="st_waitbetting"},
            {name="tra_call", from="st_betting", to="st_waitbetting"},
            {name="tra_raise", from="st_betting", to="st_waitbetting"},
            {name="tra_allin", from="st_betting", to="st_allin"},
            {name="tra_showcard", from={"st_waitbetting","st_waitget","st_getting"}, to="st_waitover"},
            {name="reset", from="*", to="st_empty"},
        },
        callbacks = {
            onchangestate = handler(self, self.onChangeState_)
        }
    })
end

function MatchSeatStateMachine:getStateText()
    return self.statetext_
end

function MatchSeatStateMachine:setStateText(txt)
    self.statetext_ = txt
end

function MatchSeatStateMachine:getState()
    return self.statemachine_:getState()
end

function MatchSeatStateMachine:doEvent(name, ...)
    if self.statemachine_:canDoEvent(name) then
        self.statemachine_:doEvent(name, ...)
    else
        logger:errorf("%s Can't do event %s on state %s", self.seatId_, name, self.statemachine_:getState())
        self.statemachine_:doEventForce(name, ...)
    end
end

function MatchSeatStateMachine:onChangeState_(evt)
    logger:debugf("%s do event %s from %s to %s", self.seatId_, evt.name, evt.from, evt.to)
    local st = evt.to
    local tra = evt.name
    local arg = ""
    if evt.args and evt.args[1] then
        arg = evt.args[1]
    end
    -- if checknumber(arg) > 0 then
    --     arg = bm.formatBigNumber(tonumber(arg))
    -- end

    if st == MatchSeatStateMachine.STATE_EMPTY then
        self.statetext_ = ""
    elseif st == MatchSeatStateMachine.STATE_FOLD then
        self.statetext_ = bm.LangUtil.getText("ROOM", "FOLD")
    elseif st == MatchSeatStateMachine.STATE_ALL_IN then
        self.statetext_ = bm.LangUtil.getText("ROOM", "ALL_IN")
    elseif st == MatchSeatStateMachine.STATE_BETTING or st == MatchSeatStateMachine.STATE_WAIT_BETTING then
        if checknumber(arg) > 0 then
            arg = bm.formatBigNumber(tonumber(arg))
        end

        if tra == MatchSeatStateMachine.CHECK then
            self.statetext_ = bm.LangUtil.getText("ROOM", "CHECK")
        elseif tra == MatchSeatStateMachine.CALL then
            self.statetext_ = bm.LangUtil.getText("ROOM", "CALL_NUM", arg)
        elseif tra == MatchSeatStateMachine.RAISE then
            self.statetext_ = bm.LangUtil.getText("ROOM", "RAISE_NUM", arg)
        else
            self.statetext_ = self.stateDefault_
        end
    elseif st == MatchSeatStateMachine.STATE_WAIT_GET then
        if arg == 0 then
            self.statetext_ = bm.LangUtil.getText("ROOM", "NOT_GET_POKER")
        elseif arg == 1 then
            self.statetext_ = bm.LangUtil.getText("ROOM", "GET_POKER")
        else
            self.statetext_ = self.stateDefault_
        end
    end
end

return MatchSeatStateMachine
