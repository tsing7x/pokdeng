--
-- Author: tony
-- Date: 2014-07-17 15:20:01
--
local OperationButton = import(".views.OperationButton")
local OperationButtonGroup = import(".views.OperationButtonGroup")
local RaiseSlider = import(".views.RaiseSlider")
local SeatStateMachine = import("app.module.room.model.SeatStateMachine")

local RoomImageButton = import(".views.RoomImageButton")
-- local ChatMsgPanel = import(".views.ChatMsgPanel")
-- local ExpressionPanel = import(".views.ExpressionPanel")

local OperationChatPanel = import(".views.OperationChatPanel")
local RoomTipsView = import(".views.RoomTipsView")
local ExtOperationView = import(".views.ExtOperationView")
-- local SuonaUsePopup = import("app.module.suona.SuonaUsePopup")

local OperationManager = class("OperationManager")

local LB_BASE_BET = T("最低下注")
local LB_BET = T("下注")
local LB_GET_POKER = T("要牌")
local LB_NOT_GET_POKER = T("不要牌")
local LB_AUTO_GET_POKER = T("自动要牌")
local LB_AUTO_NOT_GET_POKER = T("自动不要牌")
local LB_ALL_IN = T("全下")

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



function OperationManager:ctor()
    self.schedulerPool_ = bm.SchedulerPool.new()
end

function OperationManager:createNodes()
    --聊天按钮
    self.chatNode_ = display.newNode():pos(8, 6):addTo(self.scene.nodes.oprNode, 2, 2)
    self.chatNode_:setAnchorPoint(cc.p(0, 0))
    local chatW = math.round(display.width * 0.3)
    local padding = math.round((display.width * 0.05 - 16) / 4)
    local oprBtnW = math.round((display.width - 16 - chatW - 4 * padding) / 4)

    self.chatAndExprPanel_ = OperationChatPanel.new(self.ctx)
        :addTo(self.chatNode_)

    -- display.newScale9Sprite("#room_chat_btn_group_background.png", chatW * 0.5, 38, cc.size(chatW, 72)):addTo(self.chatNode_)
    -- -- display.newSprite("#room_chat_btn_group_split.png", 80, 36):addTo(self.chatNode_)

    -- local chatMsgInputBtn = cc.ui.UIPushButton.new("#transparent.png", {scale9=true})
    --     :setButtonSize(chatW - 86 - 16, 72)
    --     :setButtonLabel("normal", display.newScale9Sprite("#room_chat_btn_group_input_up.png", 0, 0, cc.size(chatW - 70, 72 - 12)))
    --     :setButtonLabel("pressed", display.newScale9Sprite("#room_chat_btn_group_input_down.png", 0, 0, cc.size(chatW - 70, 72 - 12)))
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

    -- local suonaIcBg = display.newScale9Sprite("#bg_chatMsgSuona_dent.png", - (chatW - 86 - 16) / 2 + suonaBgSize.width / 2 - 14,
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
    --     :setButtonLabel("normal", display.newSprite("#room_chat_btn_expression_down_icon.png"))  -- ??setButtonLabel @param arg#2 is Sprite??
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
    --     :pos(65 + (chatW - 86 - 12) * 0.5, 38)
    --     :addTo(self.chatNode_)

    self.raiseSlider_ = RaiseSlider.new()
        :onButtonClicked(buttontHandler(self, self.onRaiseSliderButtonClicked_))
        :pos(display.right - 110, 275 + 80 + 2)
        :addTo(self.scene.nodes.popupNode, 3, 3)
        :hide()

    RoomTipsView.WIDTH = display.width * 0.7 - 16 - padding
    self.tipsView_ = RoomTipsView.new():pos(display.right - 8 - RoomTipsView.WIDTH * 0.5, display.bottom + 44):addTo(self.scene.nodes.oprNode, 4, 4)
    self.tipsView_:hide()

    ExtOperationView.WIDTH = display.width * 0.7 - 16 - padding
    self.extOptView_ = ExtOperationView.new(self.seatManager):pos(display.right - 8 - ExtOperationView.WIDTH * 0.5, display.bottom + 44):addTo(self.scene.nodes.oprNode, 4, 4)
        :setShowHandcardCallback(handler(self, self.showHandcardCallback_))

    self.oprNode_ = display.newNode():pos(display.right - 8, display.bottom + 44):addTo(self.scene.nodes.oprNode, 5, 5)
    self.checkGroup_ = OperationButtonGroup.new()
    OperationButton.BUTTON_WIDTH = oprBtnW
    self.oprBtn1_ = OperationButton.new():setLabel(LB_BASE_BET):pos(- oprBtnW * 1.5 - padding, 0):addTo(self.oprNode_)
    self.oprBtn2_ = OperationButton.new():setLabel(LB_BET):pos(-oprBtnW * 0.5, 0):addTo(self.oprNode_)

    local leftPx = -(display.width - 8) + 8
    self.oprBtn3_ = OperationButton.new():setLabel(50):pos(leftPx + oprBtnW * 0.5, 0):addTo(self.oprNode_)
    self.oprBtn4_ = OperationButton.new():setLabel(100):pos(leftPx + oprBtnW * 1.5 + padding , 0):addTo(self.oprNode_)
    self.oprBtn5_ = OperationButton.new():setLabel(LB_ALL_IN):pos(leftPx + oprBtnW * 2.5 +  2 * padding, 0):addTo(self.oprNode_)
    
    self.checkGroup_:add(1, self.oprBtn1_)
    self.checkGroup_:add(2, self.oprBtn2_)    
    self.scene:addEventListener(self.scene.EVT_BACKGROUND_CLICK, handler(self, self.onBackgroundClicked))

    self.maxWidth_ = display.width - chatW - 450
    self.barBackground_ = display.newScale9Sprite("#room_buyin_slider_bar_bg.png", display.width / 2, display.bottom + 50, cc.size(self.maxWidth_, 12)):addTo(self.scene.nodes.oprNode)
    self.barBackground_:hide()

    self.trackBar_ = display.newScale9Sprite("#room_raise_blue_track_bg.png")
    self.trackBar_:setAnchorPoint(cc.p(0.5, 1))
    self.trackBar_:rotation(-90)
    self.trackBar_:pos(display.width / 2 + self.barBackground_:getContentSize().width * -0.5, self.barBackground_:getPositionY())
    self.trackBar_:addTo(self.scene.nodes.oprNode)
    :hide()

    self.waitLabel_ = display.newTTFLabel({text = T("等待闲家下注"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 24, align = ui.TEXT_ALIGN_CENTER})
            :pos(display.width / 2, display.bottom + 24)
            :addTo(self.scene.nodes.oprNode)
    self.waitLabel_:hide()
    self.bet_ = 0
end

function OperationManager:setLatestChatMsg(msg)
    -- self.latestChatMsg_:setString(msg)
    if self.chatAndExprPanel_ then
        --todo
        self.chatAndExprPanel_:updateChatInfo(msg)
    end
end

function OperationManager:startLoading()
    self.trackBar_:show()
    self.barBackground_:show()
    self.waitLabel_:show()

    self.runTime_ = 0
    if self.startLoadingId_ then
        self.schedulerPool_:clear(self.startLoadingId_)
        self.startLoadingId_ = nil
    end
    self.startLoadingId_ = self.schedulerPool_:loopCall(function()
        self.runTime_ = self.runTime_ + 1/30         
        local width = self.runTime_ * self.maxWidth_ / (self.model.gameInfo.userAnteTime - 1)
        if self.maxWidth_ - width > 20 then
            if self.trackBar_ then
                self.trackBar_:setContentSize(cc.size(12, self.maxWidth_ - width))
            end 
            return true
        else
            if self.barBackground_ then
                self.barBackground_:hide()
            end
            if self.trackBar_ then
                self.trackBar_:hide()
            end
            if self.waitLabel_ then
                self.waitLabel_:hide()
            end
            return false
        end
    end, 1 / 30)

    self.oprNode_:hide()
end

function OperationManager:stopLoading()
    self.schedulerPool_:clear(self.startLoadingId_)
    self.startLoadingId_ = nil
    self.trackBar_:hide()
    self.barBackground_:hide()
    self.waitLabel_:hide()

    self:updateOperationStatus()
end

function OperationManager:dispose()
    -- if self.chatPanel_ then
    --     --self.chatPanel_:release()
    -- end
    -- if self.expressionPanel_ then
    --     --expressionPanel_:release()
    -- end

    if self.startLoadingId_ then
        self.schedulerPool_:clear(self.startLoadingId_)
        self.startLoadingId_ = nil
    end
    
    if self.showOptSchedulerId then
        self.schedulerPool_:clear(self.showOptSchedulerId)
        self.showOptSchedulerId = nil
    end
    
end

function OperationManager:showOperationButtons(animation)
    self.oprNode_:stopAllActions()
    self.extOptView_:hide()
    if animation then
        self.oprNode_:show():moveTo(0.5, display.right - 8, display.bottom + 44)
        transition.moveTo(self.tipsView_, {y = -80, time=0.5, onComplete=function() self.tipsView_:hide():stop() end})
    else
        self.oprNode_:show():pos(display.right - 8, display.bottom + 44)
        self.tipsView_:hide()
        self.tipsView_:setPositionY(-80)
        self.tipsView_:stop()
    end
end

function OperationManager:hideOperationButtons(animation)
    self.oprNode_:stopAllActions()
    self.extOptView_:hide()
    if animation then
        self.tipsView_:show():play():moveTo(0.5, display.right - 8 - RoomTipsView.WIDTH * 0.5, display.bottom + 44)
        transition.moveTo(self.oprNode_, {y=-80, time=0.5, onComplete=function() self.oprNode_:hide() end})
    else
        self.oprNode_:hide():setPositionY(-80)
        self.tipsView_:show()
        self.tipsView_:play()
        self.tipsView_:setPositionY(display.bottom + 44)
    end
    self.tipsView_:hide()
    
    self.trackBar_:hide()
    self.barBackground_:hide()
    self.waitLabel_:hide()
end

function OperationManager:showExtOperationView(animation)
    self.oprNode_:hide()
    self.tipsView_:hide()
    self.extOptView_:show()
    if self.showOptSchedulerId then
        self.schedulerPool_:clear(self.showOptSchedulerId)
        self.showOptSchedulerId = nil
    end
    self.showOptSchedulerId = self.schedulerPool_:delayCall(function()
        self.extOptView_:hide()
        self.oprNode_:show()
    end, 3)
end

function OperationManager:showHandcardCallback_()
    self.schedulerPool_:clear(self.showOptSchedulerId)
    self.showOptSchedulerId = nil
    self.extOptView_:hide()
    self.oprNode_:show()
    self:blockOperationButtons()
end

function OperationManager:blockOperationButtons()
    self:disabledStatus_()
end

function OperationManager:resetAutoOperationStatus()
    self.checkGroup_:onChecked(nil):uncheck()
    self.autoAction_ = nil
end

function OperationManager:updateOperationStatus()
    self.schedulerPool_:clear(self.showOptSchedulerId)
    self.showOptSchedulerId = nil
    self.extOptView_:hide()
    self.oprNode_:show()
    local selfSeatId = self.model:selfSeatId()
    local gameStatus = self.model.gameInfo.gameStatus
    dump(gameStatus, "gameStatus")  

    if not self.model:isSelfInSeat() or not self.model:isSelfInGame()  then
        self:disabledStatus_()
    else
        local selfPlayer = self.model:selfSeatData()
        local playerState = selfPlayer.statemachine:getState() 
        dump(playerState, "playerState")       
        if playerState == SeatStateMachine.STATE_BETTING then            
            --下注
            self:selfCanRaiseStatus_(self.model.roomInfo.blind, selfPlayer.anteMoney)
        elseif playerState == SeatStateMachine.STATE_WAIT_GET or playerState == SeatStateMachine.STATE_ALL_IN then
            self:willGetPokerStatus_()
        elseif playerState == SeatStateMachine.STATE_GETTING then
            if self:applyAutoOperation_() then
                self:disabledStatus_()
            else
                if selfPlayer.handPoker and selfPlayer.handPoker:needPoker() then
                    self:getPokerForceStatus_()
                else
                    self:getPokerStatus_()
                end
            end
        else
            self:disabledStatus_()
        end
    end
    self.raiseSlider_:hidePanel()
end

function OperationManager:setSliderStatus(minRaiseChips, maxRaiseChips)
    local selfSeatData = self.model:selfSeatData()
    self.raiseSlider_:setValueRange(minRaiseChips, maxRaiseChips)
end

--无法操作的状态
function OperationManager:disabledStatus_()
    self.chatNode_:show()
    self:hideOperationButtons(false)
    self.raiseSlider_:hidePanel()
end

function OperationManager:getQuickCallValue_(minBet)
    if self.bet_ == 0 then
        self.bet_ = minBet
    end

    if self.bet_ == minBet then
        self._quickBetLeftValue = math.ceil(self.bet_ * ((self.quickRateTb_ and self.quickRateTb_[1] and self.quickRateTb_[1][1]) or 2))
        self._quickBetMidValue = math.ceil(self.bet_ * ((self.quickRateTb_ and self.quickRateTb_[1] and self.quickRateTb_[1][2]) or 5))
        self._quickBetRightValue = math.ceil(self.bet_ * ((self.quickRateTb_ and self.quickRateTb_[1] and self.quickRateTb_[1][3]) or 10))
    elseif self.bet_ <= minBet * 2 then
        self._quickBetLeftValue = math.ceil(minBet * ((self.quickRateTb_ and self.quickRateTb_[2] and self.quickRateTb_[2][1]) or 1))
        self._quickBetMidValue = math.ceil(self.bet_ * ((self.quickRateTb_ and self.quickRateTb_[2] and self.quickRateTb_[2][2]) or 2))
        self._quickBetRightValue = math.ceil(self.bet_ * ((self.quickRateTb_ and self.quickRateTb_[2] and self.quickRateTb_[2][3]) or 5))
    else
        self._quickBetLeftValue = math.ceil(minBet * ((self.quickRateTb_ and self.quickRateTb_[3] and self.quickRateTb_[3][1]) or 1))
        self._quickBetMidValue = math.ceil(self.bet_ * ((self.quickRateTb_ and self.quickRateTb_[3] and self.quickRateTb_[3][2]) or 0.5))
        self._quickBetRightValue = math.ceil(self.bet_ * ((self.quickRateTb_ and self.quickRateTb_[3] and self.quickRateTb_[3][3]) or 2))
    end
    return {self._quickBetLeftValue, self._quickBetMidValue, self._quickBetRightValue}
end

--下注
function OperationManager:selfCanRaiseStatus_(minRaiseChips, maxRaiseChips)
    self:showOperationButtons(false)
    self.chatNode_:hide()
    self.oprBtn1_:setLabel(LB_BASE_BET):setEnabled(true):setCheckMode(false):onTouch(handler(self, self.callMiniClickHandler))
    self.oprBtn2_:setLabel(LB_BET):setEnabled(true):setCheckMode(false):onTouch(handler(self, self.raiseRangeClickHandler))
    self:setSliderStatus(minRaiseChips, maxRaiseChips)

    local quickCallValue = self:getQuickCallValue_(minRaiseChips)
    self.quickCallValue_ = quickCallValue
    self.oprBtn3_:show():setLabel(quickCallValue[1]):setEnabled(true):onTouch(handler(self, self.quickCall1Handler))
    if quickCallValue[1] >= maxRaiseChips then
        self.oprBtn3_:setEnabled(false)
    end
    self.oprBtn4_:show():setLabel(quickCallValue[2]):setEnabled(true):onTouch(handler(self, self.quickCall2Handler))
    if quickCallValue[2] >= maxRaiseChips then
        self.oprBtn4_:setEnabled(false)
    end
    self.oprBtn5_:show():setLabel(quickCallValue[3]):setEnabled(true):onTouch(handler(self, self.quickCall3Handler))
    
    if quickCallValue[3] >= maxRaiseChips then
        quickCallValue[3] = maxRaiseChips
        self.oprBtn5_:setLabel(LB_ALL_IN)
    end    
end

--要牌
function OperationManager:getPokerStatus_()
    self:showOperationButtons(false)
    self.chatNode_:show()
    self.oprBtn1_:setLabel(LB_GET_POKER):setEnabled(true):setCheckMode(false):onTouch(handler(self, self.getPokerClickHandler))
    self.oprBtn2_:setLabel(LB_NOT_GET_POKER):setEnabled(true):setCheckMode(false):onTouch(handler(self, self.notGetPokerClickHandler))
    self.raiseSlider_:hidePanel()

    self.oprBtn3_:hide()
    self.oprBtn4_:hide()
    self.oprBtn5_:hide()
end

function OperationManager:getPokerForceStatus_()
    self:showOperationButtons(false)
    self.chatNode_:show()
    self.oprBtn1_:setLabel(LB_GET_POKER):setEnabled(true):setCheckMode(false):onTouch(handler(self, self.getPokerClickHandler))
    self.oprBtn2_:setLabel(LB_NOT_GET_POKER):setEnabled(false):setCheckMode(false):onTouch(handler(self, self.notGetPokerClickHandler))
    self.raiseSlider_:hidePanel()

    self.oprBtn3_:hide()
    self.oprBtn4_:hide()
    self.oprBtn5_:hide()
end

-- 将要要牌
function OperationManager:willGetPokerStatus_()
    self:showOperationButtons(false)
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
    self.oprBtn4_:hide()
    self.oprBtn5_:hide()
end

function OperationManager:quickCall1Handler(evt)
    if evt == bm.TouchHelper.CLICK then
        self:setBet_(self.quickCallValue_[1])
        self:disabledStatus_()
    end
end

function OperationManager:quickCall2Handler(evt)
    if evt == bm.TouchHelper.CLICK then
        self:setBet_(self.quickCallValue_[2])
        self:disabledStatus_()
    end
end

function OperationManager:quickCall3Handler(evt)
    if evt == bm.TouchHelper.CLICK then
        self:setBet_(self.quickCallValue_[3])
        self:disabledStatus_()
    end
end

function OperationManager:getPokerClickHandler(evt)
    if evt == bm.TouchHelper.CLICK then
        nk.server:reqOtherCard(1)
        self:disabledStatus_()
    end
end

function OperationManager:notGetPokerClickHandler(evt)
    if evt == bm.TouchHelper.CLICK then
        nk.server:reqOtherCard(0)
        self:disabledStatus_()
    end
end

--最小下注
function OperationManager:callMiniClickHandler(evt)
    if evt == bm.TouchHelper.CLICK then
        self:setBet_(self.model.roomInfo.blind)
        self:disabledStatus_()
    end
end

-- 下注
function OperationManager:setBet_(bet)
    self.bet_ = bet
    nk.server:setBet(bet)
end

function OperationManager:raiseRangeClickHandler(evt)
    if evt == bm.TouchHelper.CLICK then
        if self.raiseSlider_:isVisible() then
            self:setBet_(self.raiseSlider_:getValue())
            self:disabledStatus_()
        else
            self.raiseSlider_:showPanel()
        end
    end
end

-- 勾选了自动看牌跟注等，在这里自动发包
function OperationManager:applyAutoOperation_()
    local autoAction = self.autoAction_
    local appliedAction = true
    if autoAction == "GET_POKER" then
        nk.server:reqOtherCard(1)
    elseif autoAction == "NOT_GET_POKER" then
        nk.server:reqOtherCard(0)
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

function OperationManager:onRaiseSliderButtonClicked_(tag)
    local totalChipsInTable = self.model:totalChipsInTable()
    if tag == 1 then
        self:setBet_(totalChipsInTable)
    elseif tag == 2 then
        self:setBet_(totalChipsInTable * 0.75)
    elseif tag == 3 then
        self:setBet_(totalChipsInTable * 0.5)
    elseif tag == 4 then
        self:setBet_(self.model:currentMaxBetChips() * 3)
    elseif tag == 5 then
        self:setBet_(self.raiseSlider_:getValue())
    end
    self.raiseSlider_:hidePanel()
    self:disabledStatus_()
end

function OperationManager:onBackgroundClicked()
    self.raiseSlider_:hidePanel()
end

function OperationManager:setQuickRate(quickRateTb)
    self.quickRateTb_ = quickRateTb
end

return OperationManager