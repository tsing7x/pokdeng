--
-- Author: tony
-- Date: 2014-07-17 15:20:01
--
local OperationButton = import(".views.MatchOperationButton")
local OperationButtonGroup = import(".views.MatchOperationButtonGroup")
local RaiseSlider = import(".views.MatchRaiseSlider")
local SeatStateMachine = import("app.module.match.matchRoom.model.MatchSeatStateMachine")
local RoomImageButton = import(".views.MatchRoomImageButton")
-- local ChatMsgPanel = import(".views.MatchChatMsgPanel")

-- local ExpressionPanel = import(".views.MatchExpressionPanel")
-- local ExpressionPanel = import("app.module.room.views.ExpressionPanel")

local OperationChatPanel = import("app.module.room.views.OperationChatPanel")
local RoomTipsView = import(".views.MatchRoomTipsView")
local ExtOperationView = import(".views.MatchExtOperationView")
-- local SuonaUsePopup = import("app.module.suona.SuonaUsePopup")

local MatchOperationManager = class("MatchOperationManager")

local LB_FOLD = bm.LangUtil.getText("ROOM", "FOLD")
local LB_CHECK = bm.LangUtil.getText("ROOM", "CHECK")
local LB_CALL = bm.LangUtil.getText("ROOM", "CALL")
local LB_RAISE = bm.LangUtil.getText("ROOM", "RAISE")
local LB_RAISE_NUM = bm.LangUtil.getText("ROOM", "RAISE_NUM", "%%s")
local LB_AUTO_CHECK = bm.LangUtil.getText("ROOM", "AUTO_CHECK")
local LB_AUTO_CHECK_OR_FOLD = bm.LangUtil.getText("ROOM", "AUTO_CHECK_OR_FOLD")
local LB_AUTO_CALL = bm.LangUtil.getText("ROOM", "CALL_NUM", "%%s")
local LB_AUTO_FOLD = bm.LangUtil.getText("ROOM", "AUTO_FOLD")
local LB_AUTO_CALL_ANY = bm.LangUtil.getText("ROOM", "AUTO_CALL_ANY")

local LB_GET_POKER = bm.LangUtil.getText("ROOM", "GET_POKER")
local LB_NOT_GET_POKER = bm.LangUtil.getText("ROOM", "NOT_GET_POKER")
local LB_AUTO_GET_POKER = bm.LangUtil.getText("ROOM", "AUTO_GET_POKER")
local LB_AUTO_NOT_GET_POKER = bm.LangUtil.getText("ROOM", "AUTO_NOT_GET_POKER")


function MatchOperationManager:ctor()
    self.schedulerPool_ = bm.SchedulerPool.new()
end

function MatchOperationManager:createNodes()
    --聊天按钮
    self.chatNode_ = display.newNode():pos(8, 6):addTo(self.scene.nodes.oprNode, 2, 2)
    self.chatNode_:setAnchorPoint(cc.p(0, 0))
    local chatW = math.round(display.width * 0.3)
    local padding = math.round((display.width * 0.05 - 16) / 4)
    local oprBtnW = math.round((display.width - 16 - chatW - 4 * padding) / 3)

    self.chatAndExprPanel_ = OperationChatPanel.new(self.ctx)
        :addTo(self.chatNode_)
    -- display.newScale9Sprite("#room_chat_btn_group_background.png", chatW * 0.5, 38, cc.size(chatW, 72)):addTo(self.chatNode_)
    -- -- display.newSprite("#room_chat_btn_group_split.png", 80, 36):addTo(self.chatNode_)

    -- local chatMsgInputBtn = cc.ui.UIPushButton.new("#transparent.png", {scale9=true})
    --     :setButtonSize(chatW - 86, 72)
    --     :setButtonLabel("normal", display.newScale9Sprite("#room_chat_btn_group_input_up.png", 0, 0, cc.size(chatW - 70 - 6, 72 - 12)))
    --     :setButtonLabel("pressed", display.newScale9Sprite("#room_chat_btn_group_input_down.png", 0, 0, cc.size(chatW - 70 - 6, 72 - 12)))
    --     :onButtonClicked(function()
    --             nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
    --             --if not self.chatPanel_ then
    --                 self.chatPanel_ = ChatMsgPanel.new(self.ctx)
    --             --    self.chatPanel_:retain()
    --             --end
    --             self.chatPanel_:showPanel()
    --         end)
    --     :pos(16 + (chatW - 86 - 6) * 0.5, 38)
    --     :addTo(self.chatNode_)

    -- local suonaBgSize = {
    --     width = 58,
    --     height = 58
    -- }

    -- local suonaIcBg = display.newScale9Sprite("#bg_chatMsgSuona_dent.png", - (chatW - 86 - 16) / 2 + suonaBgSize.width / 2 - 11,
    --     0, cc.size(suonaBgSize.width, suonaBgSize.height))
    --     :addTo(chatMsgInputBtn)

    -- local suonaUseIcon = display.newSprite("#suona_icon.png")
    --     :pos(suonaBgSize.width / 2, suonaBgSize.height / 2)
    --     :addTo(suonaIcBg)

    -- local suonaUseBtn = cc.ui.UIPushButton.new("#transparent.png", {scale9 = true})
    --     :setButtonSize(suonaBgSize.width, suonaBgSize.height)
    --     :onButtonClicked(function()
    --         -- body
    --         SuonaUsePopup.new():show()
    --     end)
    --     :pos(suonaBgSize.width / 2, suonaBgSize.height / 2)
    --     :addTo(suonaIcBg)

    -- cc.ui.UIPushButton.new("#transparent.png", {scale9=true})
    --     :setButtonSize(86, 72)
    --     :setButtonLabel("normal", display.newSprite("#room_chat_btn_expression_down_icon.png"))
    --     :setButtonLabel("pressed", display.newSprite("#room_chat_btn_expression_up_icon.png"))
    --     :onButtonClicked(function()
    --             nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
    --             --if not self.expressionPanel_ then
    --                 self.expressionPanel_ = ExpressionPanel.new(self.ctx)
    --             --    self.expressionPanel_:retain()
    --             --end
    --             self.expressionPanel_:showPanel()
    --         end)
    --     :pos(180 + (chatW - 86 - 6) * 0.5, 40)
    --     :addTo(self.chatNode_)

    -- self.latestChatMsg_ = display.newTTFLabel({size=20,
    --         color=cc.c3b(106, 106, 106), 
    --         dimensions = cc.size(chatW - 86 - 16 - 8, 72),
    --         align=ui.TEXT_ALIGN_LEFT,
    --         text=""})
    --     :pos(68 + (chatW - 86 - 12) * 0.5, 38)
    --     :addTo(self.chatNode_)

    self.raiseSlider_ = RaiseSlider.new()
        :onButtonClicked(buttontHandler(self, self.onRaiseSliderButtonClicked_))
        :pos(display.right - 110, 275 + 80 + 2)
        :addTo(self.scene.nodes.popupNode, 3, 3)
        :hide()

    RoomTipsView.WIDTH = display.width * 0.7 - 16 - padding
    self.tipsView_ = RoomTipsView.new():pos(display.right - 8 - RoomTipsView.WIDTH * 0.5, display.bottom + 44):addTo(self.scene.nodes.oprNode, 4, 4)

    ExtOperationView.WIDTH = display.width * 0.7 - 16 - padding
    self.extOptView_ = ExtOperationView.new(self.seatManager):pos(display.right - 8 - ExtOperationView.WIDTH * 0.5, display.bottom + 44):addTo(self.scene.nodes.oprNode, 4, 4)
        :setShowHandcardCallback(handler(self, self.showHandcardCallback_))

    self.oprNode_ = display.newNode():pos(display.right - 8, display.bottom + 44):addTo(self.scene.nodes.oprNode, 5, 5)
    self.checkGroup_ = OperationButtonGroup.new()
    OperationButton.BUTTON_WIDTH = oprBtnW
    self.oprBtn1_ = OperationButton.new():setLabel(LB_CHECK):pos(- oprBtnW * 2.5 - 2 * padding, 0):addTo(self.oprNode_)
    self.oprBtn2_ = OperationButton.new():setLabel(LB_CALL):pos(- oprBtnW * 1.5 - padding, 0):addTo(self.oprNode_)
    self.oprBtn3_ = OperationButton.new():setLabel(LB_RAISE):pos(-oprBtnW * 0.5, 0):addTo(self.oprNode_)

    self.checkGroup_:add(1, self.oprBtn1_)
    self.checkGroup_:add(2, self.oprBtn2_)
    self.checkGroup_:add(3, self.oprBtn3_)
    self.scene:addEventListener(self.scene.EVT_BACKGROUND_CLICK, handler(self, self.onBackgroundClicked))
end

function MatchOperationManager:setLatestChatMsg(msg)

    if self.chatAndExprPanel_ then
        --todo
        self.chatAndExprPanel_:updateChatInfo(msg)
    end
    -- self.latestChatMsg_:setString(msg)
end

function MatchOperationManager:dispose()
    -- if self.chatPanel_ then
    --     --self.chatPanel_:release()
    -- end
    -- if self.expressionPanel_ then
    --     --expressionPanel_:release()
    -- end
    if showOptSchedulerId then
        self.schedulerPool_:clear(self.showOptSchedulerId)
        self.showOptSchedulerId = nil
    end

    
end

function MatchOperationManager:showOperationButtons(animation)
    self.oprNode_:stopAllActions()
    self.extOptView_:hide()
    if animation then
        self.oprNode_:show():moveTo(0.5, display.right - 8, display.bottom + 44)
        transition.moveTo(self.tipsView_, {y = -80, time=0.5, onComplete=function() self.tipsView_:hide():stop() end})
    else
        self.oprNode_:show():pos(display.right - 8, display.bottom + 44)
        self.tipsView_:hide():setPositionY(-80):stop()
    end
end

function MatchOperationManager:hideOperationButtons(animation)
    self.oprNode_:stopAllActions()
    self.extOptView_:hide()
    if animation then
        self.tipsView_:show():play():moveTo(0.5, display.right - 8 - RoomTipsView.WIDTH * 0.5, display.bottom + 44)
        transition.moveTo(self.oprNode_, {y=-80, time=0.5, onComplete=function() self.oprNode_:hide() end})
    else
        self.oprNode_:hide():setPositionY(-80)
        self.tipsView_:show():play():setPositionY(display.bottom + 44)
    end
end

function MatchOperationManager:showExtOperationView(animation)
    self.oprNode_:hide()
    self.tipsView_:hide()
    self.extOptView_:show()
    if showOptSchedulerId then
        self.schedulerPool_:clear(self.showOptSchedulerId)
        self.showOptSchedulerId = nil
    end
    self.showOptSchedulerId = self.schedulerPool_:delayCall(function()
        self.extOptView_:hide()
        self.oprNode_:show()
    end, 3)
end

function MatchOperationManager:showHandcardCallback_()
    self.schedulerPool_:clear(self.showOptSchedulerId)
    self.showOptSchedulerId = nil
    self.extOptView_:hide()
    self.oprNode_:show()
    self:blockOperationButtons()
end

function MatchOperationManager:blockOperationButtons()
    self:disabledStatus_()
end

function MatchOperationManager:resetAutoOperationStatus()
    self.checkGroup_:onChecked(nil):uncheck()
    self.autoAction_ = nil
end


--要牌
function MatchOperationManager:getPokerStatus_()
    -- self:showOperationButtons(false)
    self.chatNode_:show()
    self.oprBtn1_:setLabel(LB_GET_POKER):setEnabled(true):setCheckMode(false):onTouch(handler(self, self.getPokerClickHandler))
    self.oprBtn2_:setLabel(LB_NOT_GET_POKER):setEnabled(true):setCheckMode(false):onTouch(handler(self, self.notGetPokerClickHandler))
    self.raiseSlider_:hidePanel()

    self.oprBtn3_:hide()
    -- self.oprBtn4_:hide()
    -- self.oprBtn5_:hide()
end

function MatchOperationManager:getPokerForceStatus_()
    -- self:showOperationButtons(false)
    self.chatNode_:show()
    self.oprBtn1_:setLabel(LB_GET_POKER):setEnabled(true):setCheckMode(false):onTouch(handler(self, self.getPokerClickHandler))
    self.oprBtn2_:setLabel(LB_NOT_GET_POKER):setEnabled(false):setCheckMode(false):onTouch(handler(self, self.notGetPokerClickHandler))
    self.raiseSlider_:hidePanel()

    self.oprBtn3_:hide()
    -- self.oprBtn4_:hide()
    -- self.oprBtn5_:hide()
end



function MatchOperationManager:getPokerClickHandler(evt)
    if evt == bm.TouchHelper.CLICK then
        nk.server:matchReqThirdCard(1)
        self:disabledStatus_()
    end
end

function MatchOperationManager:notGetPokerClickHandler(evt)
    if evt == bm.TouchHelper.CLICK then
        nk.server:matchReqThirdCard(0)
        self:disabledStatus_()
    end
end


-- 将要要牌
function MatchOperationManager:willGetPokerStatus_()
    -- self:showOperationButtons(false)
    self.chatNode_:show()
    self.oprBtn1_:setLabel(LB_AUTO_GET_POKER):setEnabled(true):setCheckMode(true):onTouch(nil)
    self.oprBtn2_:setLabel(LB_AUTO_NOT_GET_POKER):setEnabled(true):setCheckMode(true):onTouch(nil)
    self.raiseSlider_:hidePanel()
    self.checkGroup_:onChecked(function(id) 
        if id == 1 then
            self.autoAction_ = "GET_POKER"
        elseif id == 2 then
            self.autoAction_ = "NOT_GET_POKER"       
        else
            self.autoAction_ = nil
        end
    end)
    self.oprBtn3_:hide()
    -- self.oprBtn4_:hide()
    -- self.oprBtn5_:hide()
end



function MatchOperationManager:updateOperationStatus()
    local callChips = self.model.gameInfo.callChips
    local minRaiseChips = self.model.gameInfo.minRaiseChips or 0
    local maxRaiseChips = self.model.gameInfo.maxRaiseChips or 0
    local bettingSeatId = self.model.gameInfo.bettingSeatId or -1
    local selfSeatId = self.model:selfSeatId()
    local gameStatus = self.model.gameInfo.gameStatus
    printf("updateOperationStatus==> %s=%s", "gameStatus", gameStatus)
    printf("updateOperationStatus==> %s=%s", "callChips", callChips)
    printf("updateOperationStatus==> %s=%s", "minRaiseChips", minRaiseChips)
    printf("updateOperationStatus==> %s=%s", "maxRaiseChips", maxRaiseChips)
    printf("updateOperationStatus==> %s=%s", "bettingSeatId", bettingSeatId)
    printf("updateOperationStatus==> %s=%s", "isSelfInSeat", self.model:isSelfInSeat())
    printf("updateOperationStatus==> %s=%s", "isSelfInGame", self.model:isSelfInGame())

    self.schedulerPool_:clear(self.showOptSchedulerId)
    self.showOptSchedulerId = nil
    self.extOptView_:hide()
    self.oprNode_:show()
    if not self.model:isSelfInSeat() or not self.model:isSelfInGame() or bettingSeatId == -1 then
        --自己不在座 或 自己不在游戏 或 没在下注
        self:disabledStatus_()
    else
        if gameStatus == consts.SVR_MATCH_GAME_STATUS.GET_POKER then
            if selfSeatId == bettingSeatId then
                if self:applyAutoOperation_() then
                    self:disabledStatus_()
                else
                    local selfPlayer = self.model:selfSeatData()
                    -- if selfPlayer.handPoker and selfPlayer.handPoker:needPoker() then
                        -- self:getPokerForceStatus_()
                    -- else
                        self:getPokerStatus_()
                    -- end
                end


            else
                local isSelfGetPoker = self.model:isSelfGetPoker()
                if isSelfGetPoker then
                    self:disabledStatus_()
                else
                    self:willGetPokerStatus_()
                end

            end



        else
         
            self.oprBtn1_:show()
            self.oprBtn2_:show()
            self.oprBtn3_:show()
            local seatChips = self.model:selfSeatData().seatChips
            printf("updateOperationStatus==> %s=%s", "seatChips", seatChips)
            if selfSeatId == bettingSeatId then
                --轮到自己操作
                if self:applyAutoOperation_() then
                    --自动操作已经触发，则直接禁用操作栏
                    printf("updateOperationStatus==> %s=%s", "applyAutoOperation_", true)
                    self:disabledStatus_()
                else
                    printf("updateOperationStatus==> %s=%s", "applyAutoOperation_", false)
                    if callChips > 0 then
                        --需要下注
                        if seatChips > callChips then
                            --有钱足够加注
                            if minRaiseChips == maxRaiseChips then
                                --没有加注空间
                                if callChips == minRaiseChips then
                                    --加注和跟注值是一样的，当做不能加注处理
                                    self:selfCannotRaiseStatus_()
                                else
                                    self:selfCanRaiseFixedStatus_(minRaiseChips)
                                end
                            else
                                --有加注空间
                                self:selfCanRaiseStatus_(minRaiseChips, maxRaiseChips)
                            end
                        else
                            --自己没钱加注
                            self:selfCannotRaiseStatus_()
                        end
                    else
                        --不需要下注
                        if minRaiseChips == maxRaiseChips then
                            --没有加注空间
                            self:selfNoBetCanRaiseFixedStatus_(minRaiseChips)
                        else
                            --有加注空间
                            self:selfNoBetCanRaiseStatus_(minRaiseChips, maxRaiseChips)
                        end
                    end
                end
            else
                --轮到别人操作
                if seatChips > 0 then
                    --自己没有all in
                    if self.model.gameInfo.hasRaise then
                        --有加注
                        self:otherBetStatus_(math.min(self.model:currentMaxBetChips() - self.model:selfSeatData().betChips, self.model:selfSeatData().seatChips))
                    elseif self.model.gameInfo.bettingSeatId ~= -1 and self.model:selfSeatData() then
                        --没有加注
                        self:otherNoBetStatus_(self.model.playerList[self.model.gameInfo.bettingSeatId].betChips - self.model:selfSeatData().betChips)
                    end
                else
                    --自己已经all in
                    self:disabledStatus_()
                end
            end


        end
    end
    self.raiseSlider_:hidePanel()
end

function MatchOperationManager:setSliderStatus(minRaiseChips, maxRaiseChips)
    local selfSeatData = self.model:selfSeatData()
    local totalChipsInTable = self.model:totalChipsInTable()
    local currentMaxBetChips = self.model:currentMaxBetChips()
    print("totalChipsInTable -----> " .. totalChipsInTable)
    print("currentMaxBetChips ----> " .. currentMaxBetChips)
    self.raiseSlider_:setButtonStatus(
        totalChipsInTable >= minRaiseChips and totalChipsInTable <= maxRaiseChips,                 --全部奖池按钮
        totalChipsInTable * 0.75 >= minRaiseChips and totalChipsInTable * 0.75 <= maxRaiseChips,--3/4奖池按钮
        totalChipsInTable * 0.5 >= minRaiseChips and totalChipsInTable * 0.5 <= maxRaiseChips,    --1/2奖池按钮
        currentMaxBetChips * 3 >= minRaiseChips and currentMaxBetChips * 3 <= maxRaiseChips,    --3倍反加按钮
        maxRaiseChips == selfSeatData.seatChips                                                    --最大加注是否allin
    )
    self.maxBet_ = maxRaiseChips
    self.raiseSlider_:setValueRange(minRaiseChips, maxRaiseChips)
end

--无法操作的状态
function MatchOperationManager:disabledStatus_()
    self.oprBtn1_:setLabel(LB_CHECK):setEnabled(false):setCheckMode(false)
    self.oprBtn2_:setLabel(LB_FOLD):setEnabled(false):setCheckMode(false)
    self.oprBtn3_:setLabel(LB_RAISE):setEnabled(false):setCheckMode(false)
    self.raiseSlider_:hidePanel()
end

--轮到自己，可以加注状态
function MatchOperationManager:selfCanRaiseStatus_(minRaiseChips, maxRaiseChips)
    self.oprBtn1_:setLabel(LB_CALL):setEnabled(true):setCheckMode(false):onTouch(handler(self, self.callClickHandler))
    self.oprBtn2_:setLabel(LB_FOLD):setEnabled(true):setCheckMode(false):onTouch(handler(self, self.foldClickHandler))
    self.oprBtn3_:setLabel(LB_RAISE):setEnabled(true):setCheckMode(false):onTouch(handler(self, self.raiseRangeClickHandler))
    self:setSliderStatus(minRaiseChips, maxRaiseChips)
end

--轮到自己，只能加固定注状态
function MatchOperationManager:selfCanRaiseFixedStatus_(raiseChips)
    self.raiseFixedChips_ = raiseChips
    self.oprBtn1_:setLabel(LB_CALL):setEnabled(true):setCheckMode(false):onTouch(handler(self, self.callClickHandler))
    self.oprBtn2_:setLabel(LB_FOLD):setEnabled(true):setCheckMode(false):onTouch(handler(self, self.foldClickHandler))
    self.oprBtn3_:setLabel(string.format(LB_RAISE_NUM, raiseChips)):setEnabled(false):setCheckMode(false):onTouch(handler(self, self.raiseFixedClickHandler))
end

--轮到自己，不能加注状态
function MatchOperationManager:selfCannotRaiseStatus_()
    self.oprBtn1_:setLabel(LB_CALL):setEnabled(true):setCheckMode(false):onTouch(handler(self, self.callClickHandler))
    self.oprBtn2_:setLabel(LB_FOLD):setEnabled(true):setCheckMode(false):onTouch(handler(self, self.foldClickHandler))
    self.oprBtn3_:setLabel(LB_RAISE):setEnabled(false):setCheckMode(false)
end

--轮到自己，桌面没有加注，可以选择加注
function MatchOperationManager:selfNoBetCanRaiseStatus_(minRaiseChips, maxRaiseChips)
    self.oprBtn1_:setLabel(LB_CHECK):setEnabled(true):setCheckMode(false):onTouch(handler(self, self.checkClickHandler))
    self.oprBtn2_:setLabel(LB_FOLD):setEnabled(true):setCheckMode(false):onTouch(handler(self, self.foldClickHandler))
    self.oprBtn3_:setLabel(LB_RAISE):setEnabled(true):setCheckMode(false):onTouch(handler(self, self.raiseRangeClickHandler))
    self:setSliderStatus(minRaiseChips, maxRaiseChips)
end

--轮到自己，桌面没有加注，只能加固定的住
function MatchOperationManager:selfNoBetCanRaiseFixedStatus_(raiseChips)
    self.raiseFixedChips_ = raiseChips
    self.oprBtn1_:setLabel(LB_CHECK):setEnabled(true):setCheckMode(false):onTouch(handler(self, self.checkClickHandler))
    self.oprBtn2_:setLabel(LB_FOLD):setEnabled(true):setCheckMode(false):onTouch(handler(self, self.foldClickHandler))
    self.oprBtn3_:setLabel(string.format(LB_RAISE_NUM, raiseChips)):setEnabled(true):setCheckMode(false):onTouch(handler(self, self.raiseFixedClickHandler))
end

--没轮到自己操作，且没有加注（自动看牌、看或弃、跟任何注）
function MatchOperationManager:otherNoBetStatus_()
    self.checkGroup_:onChecked(function(id) 
        if id == 1 then
            self.autoAction_ = "CHECK";
        elseif id == 2 then
            self.autoAction_ = "CHECK_OR_FOLD"
        elseif id == 3 then
            self.autoAction_ = "CALL_ANY"
        else
            self.autoAction_ = nil
        end
    end)
    local checkedId = self.checkGroup_:getCheckedId()
    if self.oprBtn2_:getLabel() ~= LB_AUTO_CHECK_OR_FOLD and not (self.oprBtn3_:getLabel() == LB_AUTO_CALL_ANY and checkedId == 3)  then
        self.checkGroup_:uncheck()
    end
    self.oprBtn1_:setLabel(LB_AUTO_CHECK):setEnabled(true):setCheckMode(true):onTouch(nil)
    self.oprBtn2_:setLabel(LB_AUTO_CHECK_OR_FOLD):setEnabled(true):setCheckMode(true):onTouch(nil)
    self.oprBtn3_:setLabel(LB_AUTO_CALL_ANY):setEnabled(true):setCheckMode(true):onTouch(nil)
end

--没轮到自己操作，有加注(跟XX注, 自动弃牌，跟任何注)
function MatchOperationManager:otherBetStatus_(autoCallChips)
    self.autoCallChips_ = autoCallChips
    self.checkGroup_:onChecked(function(id) 
        if id == 1 then
            self.autoAction_ = "CALL";
        elseif id == 2 then
            self.autoAction_ = "FOLD"
        elseif id == 3 then
            self.autoAction_ = "CALL_ANY"
        else
            self.autoAction_ = nil
        end
    end)
    local checkedId = self.checkGroup_:getCheckedId()
    local lb = string.format(LB_AUTO_CALL, autoCallChips)
    if self.oprBtn2_:getLabel() ~= LB_AUTO_FOLD and not (self.oprBtn3_:getLabel() == LB_AUTO_CALL_ANY and checkedId == 3) 
        or checkedId == 1 and lb ~= self.oprBtn1_:getLabel() then
        self.checkGroup_:uncheck()
    end
    self.oprBtn1_:setLabel(lb):setEnabled(true):setCheckMode(true):onTouch(nil)
    self.oprBtn2_:setLabel(LB_AUTO_FOLD):setEnabled(true):setCheckMode(true):onTouch(nil)
    self.oprBtn3_:setLabel(LB_AUTO_CALL_ANY):setEnabled(true):setCheckMode(true):onTouch(nil)
end


function MatchOperationManager:checkClickHandler(evt)
    if evt == bm.TouchHelper.CLICK then
        self:reportPlayData_("CHECK")
        -- nk.socket.RoomSocket:sendBet(consts.CLI_BET_TYPE.CHECK, 0)
        nk.server:matchSetBet(consts.CLI_BET_TYPE.CHECK, 0)
        self:disabledStatus_()
    end
end

function MatchOperationManager:foldClickHandler(evt)
    if evt == bm.TouchHelper.CLICK then
        self:reportPlayData_("FOLD")
        -- nk.socket.RoomSocket:sendBet(consts.CLI_BET_TYPE.FOLD, 0)
        nk.server:matchSetBet(consts.CLI_BET_TYPE.FOLD, 0)
        self:disabledStatus_()
    end
end

function MatchOperationManager:callClickHandler(evt)
    if evt == bm.TouchHelper.CLICK then
        self:reportPlayData_("CALL")
        nk.server:matchSetBet(consts.CLI_BET_TYPE.CALL, self.model.gameInfo.callChips)
        -- nk.socket.RoomSocket:sendBet(consts.CLI_BET_TYPE.CALL, self.model.gameInfo.callChips)
        self:disabledStatus_()
    end
end

function MatchOperationManager:raiseFixedClickHandler(evt)
    if evt == bm.TouchHelper.CLICK then
        self:reportPlayData_("CALL_FIXED")
        nk.server:matchSetBet(consts.CLI_BET_TYPE.RAISE, self.raiseFixedChips_)
        -- nk.socket.RoomSocket:sendBet(consts.CLI_BET_TYPE.CALL, self.raiseFixedChips_)
        self:disabledStatus_()
    end
end

function MatchOperationManager:raiseRangeClickHandler(evt)
    if evt == bm.TouchHelper.CLICK then
        if self.raiseSlider_:isVisible() then
            if self.raiseSlider_:getSliderPercentValue() == 1 then
                self:reportPlayData_("ALL_IN")
            else
                self:reportPlayData_("CALL_RAISE")
            end
            -- nk.socket.RoomSocket:sendBet(consts.CLI_BET_TYPE.CALL, self.raiseSlider_:getValue())
            nk.server:matchSetBet(consts.CLI_BET_TYPE.RAISE, self.raiseSlider_:getValue())
            self:disabledStatus_()
        else
            self.raiseSlider_:showPanel()
        end
    end
end

-- 勾选了自动看牌跟注等，在这里自动发包
function MatchOperationManager:applyAutoOperation_()
    local autoAction = self.autoAction_
    local appliedAction = true
    if autoAction == "CHECK" then
        if self.model.gameInfo.callChips == 0 then
            self:reportPlayData_("CHECK")
            -- nk.socket.RoomSocket:sendBet(consts.CLI_BET_TYPE.CHECK, 0)
            nk.server:matchSetBet(consts.CLI_BET_TYPE.CHECK, 0)
        else
            appliedAction = false
        end
    elseif autoAction == "CHECK_OR_FOLD" then
        if self.model.gameInfo.callChips > 0 then
            self:reportPlayData_("FOLD")
            -- nk.socket.RoomSocket:sendBet(consts.CLI_BET_TYPE.FOLD, 0)
            nk.server:matchSetBet(consts.CLI_BET_TYPE.FOLD, 0)
        else
            self:reportPlayData_("CHECK")
            -- nk.socket.RoomSocket:sendBet(consts.CLI_BET_TYPE.CHECK, 0)
            nk.server:matchSetBet(consts.CLI_BET_TYPE.CHECK, 0)
        end
    elseif autoAction == "CALL_ANY" then
        if self.model.gameInfo.callChips > 0 then
            self:reportPlayData_("CALL")
            -- nk.socket.RoomSocket:sendBet(consts.CLI_BET_TYPE.CALL, self.model.gameInfo.callChips)
            nk.server:matchSetBet(consts.CLI_BET_TYPE.CALL, self.model.gameInfo.callChips)
        else
            appliedAction = false
        end
    elseif autoAction == "CALL" then
        if self.autoCallChips_ == self.model.gameInfo.callChips then
            self:reportPlayData_("CALL")
            -- nk.socket.RoomSocket:sendBet(consts.CLI_BET_TYPE.CALL, self.model.gameInfo.callChips)
            nk.server:matchSetBet(consts.CLI_BET_TYPE.CALL, self.model.gameInfo.callChips)
        else
            appliedAction = false
        end
    elseif autoAction == "FOLD" then
        self:reportPlayData_("FOLD")
        -- nk.socket.RoomSocket:sendBet(consts.CLI_BET_TYPE.FOLD, 0)
        nk.server:matchSetBet(consts.CLI_BET_TYPE.FOLD, 0)
    elseif autoAction == "GET_POKER" then
        self:reportPlayData_("GET_POKER")
        nk.server:matchReqThirdCard(1)

    elseif autoAction == "NOT_GET_POKER" then
        self:reportPlayData_("NOT_GET_POKER")
        nk.server:matchReqThirdCard(0)

    else
        appliedAction = false
    end

    self.checkGroup_:onChecked(nil):uncheck()
    self.autoAction_ = nil

    if appliedAction then
        self:disabledStatus_()
    end

    return appliedAction
end

function MatchOperationManager:onRaiseSliderButtonClicked_(tag)
    local totalChipsInTable = self.model:totalChipsInTable()
    if tag == 1 then
        self:reportPlayData_("CALL_RAISE")
        -- nk.socket.RoomSocket:sendBet(consts.CLI_BET_TYPE.CALL, totalChipsInTable)
        --nk.server:matchSetBet(consts.CLI_BET_TYPE.RAISE, totalChipsInTable)
        nk.server:matchSetBet(consts.CLI_BET_TYPE.RAISE,self.maxBet_ or totalChipsInTable)
    elseif tag == 2 then
        self:reportPlayData_("CALL_RAISE")
        -- nk.socket.RoomSocket:sendBet(consts.CLI_BET_TYPE.CALL, totalChipsInTable * 0.75)
        nk.server:matchSetBet(consts.CLI_BET_TYPE.RAISE, totalChipsInTable* 0.75)
    elseif tag == 3 then
        self:reportPlayData_("CALL_RAISE")
        -- nk.socket.RoomSocket:sendBet(consts.CLI_BET_TYPE.CALL, totalChipsInTable * 0.5)
        nk.server:matchSetBet(consts.CLI_BET_TYPE.RAISE, totalChipsInTable* 0.5)
    elseif tag == 4 then
        self:reportPlayData_("CALL_RAISE")
        -- nk.socket.RoomSocket:sendBet(consts.CLI_BET_TYPE.CALL, self.model:currentMaxBetChips() * 3)
        nk.server:matchSetBet(consts.CLI_BET_TYPE.RAISE, self.model:currentMaxBetChips() * 3)
    elseif tag == 5 then
        self:reportPlayData_("ALL_IN")
        -- nk.socket.RoomSocket:sendBet(consts.CLI_BET_TYPE.CALL, self.raiseSlider_:getValue())
        nk.server:matchSetBet(consts.CLI_BET_TYPE.RAISE, self.raiseSlider_:getValue())
    end
    self.raiseSlider_:hidePanel()
    self:disabledStatus_()
end

function MatchOperationManager:reportPlayData_(dataLabel)
    if device.platform == "android" or device.platform == "ios" then
        cc.analytics:doCommand{command = "event",
            args = {eventId = "play_count_" .. dataLabel} , label = "play_count " .. dataLabel}
    end
end

function MatchOperationManager:onBackgroundClicked()
    self.raiseSlider_:hidePanel()
end


function MatchOperationManager:startLoading()
    -- self.trackBar_:show()
    -- self.barBackground_:show()
    -- self.waitLabel_:show()

    -- self.runTime_ = 0
    -- self.startLoadingId_ = self.schedulerPool_:loopCall(function()
    --     self.runTime_ = self.runTime_ + 1/30         
    --     local width = self.runTime_ * self.maxWidth_ / (self.model.gameInfo.userAnteTime - 1)
    --     if self.maxWidth_ - width > 20 then
    --         self.trackBar_:setContentSize(cc.size(12, self.maxWidth_ - width))
    --         return true
    --     else
    --         self.barBackground_:hide()
    --         self.trackBar_:hide()
    --         self.waitLabel_:hide()
    --         return false
    --     end
    -- end, 1 / 30)

    -- self.oprNode_:hide()
end

function MatchOperationManager:stopLoading()
    -- self.schedulerPool_:clear(self.startLoadingId_)
    -- self.trackBar_:hide()
    -- self.barBackground_:hide()
    -- self.waitLabel_:hide()

    -- self:updateOperationStatus()
end


return MatchOperationManager