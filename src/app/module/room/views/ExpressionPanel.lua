--
-- Author: tony
-- Date: 2014-08-16 18:05:06
--

local ExpressionPanel = class("ExpressionPanel", function() return display.newNode() end)
local ExpressionConfig = import(".ExpressionConfig").new()

ExpressionPanel.WIDTH = 512
ExpressionPanel.HEIGHT  = 480

function ExpressionPanel:ctor(ctx, defaultPageIdx)
    self.ctx = ctx
    local enteredExprTimes = nk.userDefault:getIntegerForKey(nk.cookieKeys.ENTEREDEXPER_TIMES_TODAY, 0)

    local lastStayPage = nil
    if enteredExprTimes > 0 then
        --todo
        lastStayPage = nk.userDefault:getIntegerForKey(nk.cookieKeys.LAST_USED_EXPRE, 1)
    else
        lastStayPage = 3
    end

    nk.userDefault:setIntegerForKey(nk.cookieKeys.ENTEREDEXPER_TIMES_TODAY, enteredExprTimes + 1)
    -- local lastStayPage = nk.userDefault:getIntegerForKey(nk.cookieKeys.LAST_USED_EXPRE, 1)

    self.defaultPageIdx_ = defaultPageIdx or lastStayPage

    display.addSpriteFrames("room_expression_popup.plist", "room_expression_popup.png")

    display.addSpriteFrames("payExpr_catgy1.plist", "payExpr_catgy1.png")
    display.addSpriteFrames("payExpr_catgy2.plist", "payExpr_catgy2.png")

    self.background_ = display.newScale9Sprite("#room_chat_panel_background.png", 0, 0, cc.size(ExpressionPanel.WIDTH, ExpressionPanel.HEIGHT))
    self.background_:addTo(self)
    self.background_:setTouchEnabled(true)
    self.background_:setTouchSwallowEnabled(true)
    self:pos(-ExpressionPanel.WIDTH * 0.5, ExpressionPanel.HEIGHT * 0.5 + 80 + 8)
    self:createUI_()
end

function ExpressionPanel:createUI_()
    -- 创建分页tab

    local tabBtnGruopMagrins = {
        top = 0,
        leftRight = 10
    }

    local tabBarPanelParam = {
        sizeHeight = 48,
        tabFrontSize = 22
    }

    self:drawExprViews()

    local tipsBottomLabelParam = {
        frontSize = 18,
        color = cc.c3b(98, 113, 132)
    }

    local tipsBottomMagrinBot = 8
    self.tipsBottom_ = display.newTTFLabel({text = "labe String", size = tipsBottomLabelParam.frontSize,
        color = tipsBottomLabelParam.color, align = ui.TEXT_ALIGN_CENTER})
    self.tipsBottom_:pos(0, - ExpressionPanel.HEIGHT / 2 + tipsBottomMagrinBot + self.tipsBottom_:getContentSize().height / 2)
        :addTo(self)

    self.tabBarBtnGroup_ = nk.ui.CommonPopupTabBar.new({popupWidth = ExpressionPanel.WIDTH - tabBtnGruopMagrins.leftRight * 2, scale = 1,
        btnText = bm.LangUtil.getText("ROOM", "EXPRE_TABTEXT")})
        :setTabBarExtraParam({tabBarHeight = tabBarPanelParam.sizeHeight, tabFrontSize = tabBarPanelParam.tabFrontSize})
        :onTabChange(handler(self, self.onExprTabChanged))
        :pos(0, ExpressionPanel.HEIGHT / 2 - tabBtnGruopMagrins.top - tabBarPanelParam.sizeHeight / 2)
        :addTo(self)

    self.tabBarBtnGroup_:gotoTab(self.defaultPageIdx_)
end

function ExpressionPanel:drawExprViewByIdx(idx)
    -- body
    local exprListPosYAdjust = 25
    local exprListPosYShift = 80
    local row, col = 1, 1

    local renderViewByIndex = {
        [1] = function()
            -- body
            local rect = cc.rect(-ExpressionPanel.WIDTH * 0.5 + 6, -ExpressionPanel.HEIGHT* 0.5 + 6 + exprListPosYShift / 2, ExpressionPanel.WIDTH - 12, ExpressionPanel.HEIGHT - 12 - exprListPosYShift)
            local page = display.newNode()

            local expNum = 27
            local contentWidth = 500
            local contentHeight = ((expNum / 5 - (expNum / 5) % 1) + (expNum % 5 == 0 and 0 or 1)) * 100
            local contentLeft =  -0.5 * contentWidth
            local contentTop = 0.5 * contentHeight
            for i = 1, expNum do
                local id = i
                local btn = cc.ui.UIPushButton.new({normal="#expression_transparent.png", pressed="#expression-btn-down.png"}, {scale9=true})
                btn:setTouchSwallowEnabled(false)
                btn:onButtonPressed(function(evt) 
                    self.btnPressedY_ = evt.y
                    self.btnClickCanceled_ = false
                    btn:setButtonSize(120, 120)
                end)
                btn:onButtonRelease(function(evt) 
                    btn:setButtonSize(100, 100)
                    if math.abs(evt.y - self.btnPressedY_) > 10 then
                        self.btnClickCanceled_ = true
                    end
                end)
                btn:onButtonClicked(function(evt)
                    if not self.btnClickCanceled_ and self:getParent():getCascadeBoundingBox():containsPoint(cc.p(evt.x, evt.y)) then
                        nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
                        self:onExpressionPaidClicked(idx, id)
                    end
                end)
                btn:setButtonSize(100, 100)
                btn:setAnchorPoint(cc.p(0.5, 0.5))
                btn:pos(contentLeft + 50 + (col - 1) * 100, contentTop - 50 - (row - 1) * 100)
                btn:addTo(page)

                local expConfig = ExpressionConfig:getConfig(id)
                local sprite = display.newSprite("#expression-" .. id .. ".png", contentLeft + 50 + (col - 1) * 100 + expConfig.adjustX * 0.7, contentTop - 50 - (row - 1) * 100 + expConfig.adjustY * 0.7):addTo(page)
                sprite:setScale(0.7)

                col = col + 1
                if col > 5 then
                    row = row + 1
                    col = 1
                end
            end

            self.expressionNorList_ = bm.ui.ScrollView.new({viewRect=rect, scrollContent=page, direction=bm.ui.ScrollView.DIRECTION_VERTICAL})
                :pos(0, - exprListPosYShift / 2 + exprListPosYAdjust)
            return self.expressionNorList_
        end,

        [2] = function()
            -- body
            -- 表情 狐狸
            local rect = cc.rect(-ExpressionPanel.WIDTH * 0.5 + 6, -ExpressionPanel.HEIGHT* 0.5 + 6 + exprListPosYShift / 2, ExpressionPanel.WIDTH - 12, ExpressionPanel.HEIGHT - 12 - exprListPosYShift)
            local page = display.newNode()

            local expNum = 11
            local contentWidth = 500
            local contentHeight = ((expNum / 5 - (expNum / 5) % 1) + (expNum % 5 == 0 and 0 or 1)) * 100
            local contentLeft =  -0.5 * contentWidth
            local contentTop = 0.5 * contentHeight
            for i = 1, expNum do
                local id = i + 27 -- 表情Id 递增,从28开始
                local btn = cc.ui.UIPushButton.new({normal="#expression_transparent.png", pressed="#expression-btn-down.png"}, {scale9=true})
                btn:setTouchSwallowEnabled(false)
                btn:onButtonPressed(function(evt) 
                    self.btnCatAPressedY_ = evt.y
                    self.btnCatAClickCanceled_ = false
                    btn:setButtonSize(120, 120)
                end)
                btn:onButtonRelease(function(evt) 
                    btn:setButtonSize(100, 100)
                    if math.abs(evt.y - self.btnCatAPressedY_) > 10 then
                        self.btnCatAClickCanceled_ = true
                    end
                end)
                btn:onButtonClicked(function(evt)
                    if not self.btnCatAClickCanceled_ and self:getParent():getCascadeBoundingBox():containsPoint(cc.p(evt.x, evt.y)) then
                        nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
                        self:onExpressionPaidClicked(idx, id)  -- 需调整fId为2 args #1,下同
                    end
                end)
                btn:setButtonSize(100, 100)
                btn:setAnchorPoint(cc.p(0.5, 0.5))
                btn:pos(contentLeft + 50 + (col - 1) * 100, contentTop - 50 - (row - 1) * 100)
                btn:addTo(page)

                local expConfig = ExpressionConfig:getConfig(id)
                local sprite = display.newSprite("#expr_catgy1_" .. id - 27 .. ".png", contentLeft + 50 + (col - 1) * 100 + expConfig.adjustX * 0.7, contentTop - 50 - (row - 1) * 100 + expConfig.adjustY * 0.7):addTo(page)
                sprite:setScale(0.7)

                col = col + 1
                if col > 5 then
                    row = row + 1
                    col = 1
                end
            end

            self.expressionCatAList_ = bm.ui.ScrollView.new({viewRect=rect, scrollContent=page, direction=bm.ui.ScrollView.DIRECTION_VERTICAL})
                :pos(0, - exprListPosYShift / 2 + exprListPosYAdjust)
            return self.expressionCatAList_

            -- local label = display.newTTFLabel({text = "222222222222", size = 25, align = ui.TEXT_ALIGN_CENTER})

            -- return label
        end,

        [3] = function()
            -- body

            -- 表情 兔子
            local rect = cc.rect(-ExpressionPanel.WIDTH * 0.5 + 6, -ExpressionPanel.HEIGHT* 0.5 + 6 + exprListPosYShift / 2, ExpressionPanel.WIDTH - 12, ExpressionPanel.HEIGHT - 12 - exprListPosYShift)
            local page = display.newNode()

            local expNum = 19
            local contentWidth = 500
            local contentHeight = ((expNum / 5 - (expNum / 5) % 1) + (expNum % 5 == 0 and 0 or 1)) * 100
            local contentLeft =  -0.5 * contentWidth
            local contentTop = 0.5 * contentHeight
            for i = 1, expNum do
                local id = i + 27 + 11 -- 表情Id 递增,从39开始
                local btn = cc.ui.UIPushButton.new({normal="#expression_transparent.png", pressed="#expression-btn-down.png"}, {scale9=true})
                btn:setTouchSwallowEnabled(false)
                btn:onButtonPressed(function(evt) 
                    self.btnCatBPressedY_ = evt.y
                    self.btnCatBClickCanceled_ = false
                    btn:setButtonSize(120, 120)
                end)
                btn:onButtonRelease(function(evt) 
                    btn:setButtonSize(100, 100)
                    if math.abs(evt.y - self.btnCatBPressedY_) > 10 then
                        self.btnCatBClickCanceled_ = true
                    end
                end)
                btn:onButtonClicked(function(evt)
                    if not self.btnCatBClickCanceled_ and self:getParent():getCascadeBoundingBox():containsPoint(cc.p(evt.x, evt.y)) then
                        nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
                        self:onExpressionPaidClicked(idx, id)  -- 需调整fId为3
                    end
                end)
                btn:setButtonSize(100, 100)
                btn:setAnchorPoint(cc.p(0.5, 0.5))
                btn:pos(contentLeft + 50 + (col - 1) * 100, contentTop - 50 - (row - 1) * 100)
                btn:addTo(page)

                local expConfig = ExpressionConfig:getConfig(id)
                local sprite = display.newSprite("#expr_catgy2_" .. id - 27 - 11 .. ".png", contentLeft + 50 + (col - 1) * 100 + expConfig.adjustX * 0.7, contentTop - 50 - (row - 1) * 100 + expConfig.adjustY * 0.7):addTo(page)
                sprite:setScale(0.7)

                col = col + 1
                if col > 5 then
                    row = row + 1
                    col = 1
                end
            end

            self.expressionCatBList_ = bm.ui.ScrollView.new({viewRect=rect, scrollContent=page, direction=bm.ui.ScrollView.DIRECTION_VERTICAL})
                :pos(0, - exprListPosYShift / 2 + exprListPosYAdjust)
            return self.expressionCatBList_

            -- local label = display.newTTFLabel({text = "333333333333333", size = 25, align = ui.TEXT_ALIGN_CENTER})

            -- return label
        end
    }

    return renderViewByIndex[idx]()
end

function ExpressionPanel:drawExprViews()
    -- body
    self.exprListViews_ = self.exprListViews_ or {}
    local pageNum = 3

    for i = 1, pageNum do

        self.exprListViews_[i] = self:drawExprViewByIdx(i)
        self.exprListViews_[i]:addTo(self)

        self.exprListViews_[i]:hide()
    end

    -- self.tabBarBtnGroup_:gotoTab(self.defaultPageIdx_)
end

function ExpressionPanel:onExprTabChanged(selectedIdx)
    -- body
    local bottomTipsStr = nil

    local exprUseCost = nil
    local getBottomStrByRoomType = {
        [consts.ROOM_TYPE.NORMAL] = function()
            -- body
            local roomBets = self.ctx.model.roomInfo.blind
            local roomLevel = self.ctx.model.roomType_

            local roomData = nk.getRoomDataByLevel(roomLevel)
            local feeDiscount = roomData.exprDiscount or 0

            exprUseCost = roomBets * feeDiscount


            return bm.LangUtil.getText("ROOM", "EXPRE_PAID_USE_TIP", exprUseCost)
        end,

        [consts.ROOM_TYPE.PERSONAL_NORMAL] = function()
            -- body
            exprUseCost = self.ctx.model.roomInfo.blind

            return bm.LangUtil.getText("ROOM", "EXPRE_PAID_USE_TIP", exprUseCost)
        end,

        [consts.ROOM_TYPE.MATCH] = function()
            -- body
            local matchType = self.ctx.model.roomInfo.matchType

            local matchData
            matchData  = nk.MatchConfigEx:getMatchDataById(matchType)

            -- dump(matchData, "matchData :=============")
            exprUseCost = matchData.exprCost or 0

            return bm.LangUtil.getText("ROOM", "EXPRE_PAID_USE_TIP", exprUseCost)
        end,

        [consts.ROOM_TYPE.GRAB] = function()
            -- body
            exprUseCost = - 1
            local blind = self.ctx.model.roomInfo.blind
            local grablistConfig = bm.DataProxy:getData(nk.dataKeys.GRAB_ROOM_LIST)

            if grablistConfig then
                if self.ctx.model.roomInfo.rmType == consts.ROOM_TYPE_EX.GRAB_CASH then
                    if grablistConfig.point and grablistConfig.point[tostring(blind)] then
                        local grabData = grablistConfig.point[tostring(blind)]
                        --dealertip:荷官小费
                        --sendInRoom:赠送筹码
                        --facial:表情收费
                        exprUseCost = tonumber(grabData.facial)
                    end
                else
                    if grablistConfig.money and grablistConfig.money[tostring(blind)] then
                        local grabData = grablistConfig.money[tostring(blind)]
                        --dealertip:荷官小费
                        --sendInRoom:赠送筹码
                        --facial:表情收费
                        exprUseCost = tonumber(grabData.facial)
                    end
                end
                
            end

            if exprUseCost == - 1 then
                return ""
            end
            
            return bm.LangUtil.getText("ROOM", "EXPRE_PAID_USE_TIP", exprUseCost)
        end,
        [consts.ROOM_TYPE.NORMAL_GRAB] = function()
                local roomBets = self.ctx.model.roomInfo.blind
                local roomLevel = self.ctx.model.roomType_

                local roomData = nk.getRoomDataByLevel(roomLevel)
                local feeDiscount = roomData.exprDiscount or 0

                exprUseCost = roomBets * feeDiscount


                return bm.LangUtil.getText("ROOM", "EXPRE_PAID_USE_TIP", exprUseCost)
        end
    }

    if selectedIdx == 1 then
        --todo
        bottomTipsStr = bm.LangUtil.getText("ROOM", "EXPRE_FREE_USE_TIP")
    else
        -- local roomBets = self.ctx.model.roomInfo.blind
        -- local roomLevel = self.ctx.model.roomType_

        -- local roomData = nk.getRoomDataByLevel(roomLevel)
        -- local feeDiscount = roomData.exprDiscount

        -- local exprUseCost = roomBets * feeDiscount


        -- bottomTipsStr = bm.LangUtil.getText("ROOM", "EXPRE_PAID_USE_TIP", exprUseCost)
        -- "单次使用费" .. exprUseCost .. "筹码"

        bottomTipsStr = getBottomStrByRoomType[self.ctx.model.roomInfo.gameType]()
    end

    if bottomTipsStr then
        --todo
        self.tipsBottom_:setString(bottomTipsStr)
    end
    
    nk.userDefault:setIntegerForKey(nk.cookieKeys.LAST_USED_EXPRE, selectedIdx)
    if not self.selectedIdx_ then
        --todo
        self.selectedIdx_ = selectedIdx
        self.exprListViews_[self.selectedIdx_]:show()
    end

    if self.selectedIdx_ ~= selectedIdx then
        --todo
        self.exprListViews_[self.selectedIdx_]:hide()
        self.exprListViews_[selectedIdx]:show()

        self.selectedIdx_ = selectedIdx
    end
end

function ExpressionPanel:onExpressionClicked(id)
    if self.ctx.model:isSelfInSeat() then
        -- nk.socket.RoomSocket:sendExpression(1, id)
        nk.server:sendExpression(1,id)

        self:hidePanel()
    else
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "SEND_EXPRESSION_MUST_BE_IN_SEAT"))
    end
end

-- @param category: 付费表情类型, 1:A类表情, 2:B类表情  eId: 表情Id  -- 这个表情分类需要调整一下 √,常规: 1, A类付费表情: 2, B类付费表情:3
function ExpressionPanel:onExpressionPaidClicked(category, eId)
    -- body

    if self.ctx.model:isSelfInSeat() then
        --todo
        -- 请求Http 等待返回结果

        -- 根据场次类型获取底注和类型参数(注：不一定是房间底注！,在比赛场中，是matchId)
        -- 返回参数：@param #2 1：普通场, 2:私人场, 3:比赛场, 4:上庄场筹码 5:上庄场现金
        local getRoomBetsAndRoomTypeByType = {
            [consts.ROOM_TYPE.NORMAL] = function()
                -- body
                return self.ctx.model.roomInfo.blind, 1
            end,

            [consts.ROOM_TYPE.PERSONAL_NORMAL] = function()
                -- body
                return self.ctx.model.roomInfo.blind, 2
            end,

            [consts.ROOM_TYPE.NORMAL_GRAB] = function()
                return self.ctx.model.roomInfo.blind, 1
            end,

            [consts.ROOM_TYPE.MATCH] = function()
                -- body
                local matchType = self.ctx.model.roomInfo.matchType

                return matchType, 3
            end,

            [consts.ROOM_TYPE.GRAB] = function()
               
                if self.ctx.model.roomInfo.rmType == consts.ROOM_TYPE_EX.GRAB_CASH then
                    return self.ctx.model.roomInfo.blind, 5
                else
                    return self.ctx.model.roomInfo.blind, 4
                end
 
            end
        }

        local param = {}  -- 参数表需要传递三个参数 新加字段@param: roomType 1,普通场; 2,私人场; 3,比赛场; 4,上庄场
        param.roomBets, param.roomType = getRoomBetsAndRoomTypeByType[self.ctx.model.roomInfo.gameType]()
        param.QExprId = category

        -- dump(param, "QExprUseParam :===============")
        nk.http.usePaymentExpr(param, function(data)
            -- body
             --dump(data, "usePaymentExpr.data :==============")
            -- 更新筹码携带，并发送server房间内广播
            nk.userData["aUser.money"] = data.leftmoney or nk.userData["aUser.money"] or 0
            local useMoney =  checkint(data.usemoney)
            bm.EventCenter:dispatchEvent({name = nk.eventNames.UPDATE_SEAT_ANTE_CHIP, data = {chip = -useMoney}})
            if category and eId then
                --todo
                nk.server:sendExpression(category, eId)
            end

            if self and self.hidePanel then
                --todo
                self:hidePanel()
            end
            
        end,

        function(errData)
            -- body
           -- dump(errData, "usePaymentExpr.errData :===================")
            
            if self and self.hidePanel then
                --todo
                self:hidePanel()
            end

            if errData and errData.errorCode then
                local ecode = checkint(errData.errorCode)
                if ecode==-3 then
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "EXPRE_USED_NOT_MONEY"))
                else
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "EXPRE_USED_FIALD_TIP"))
                end
            else
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "EXPRE_USED_FIALD_TIP"))
            end
        end
        )
    else
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "SEND_EXPRESSION_MUST_BE_IN_SEAT"))
    end
end

function ExpressionPanel:showPanel()
    nk.PopupManager:addPopup(self, true, false, true, false)
end

function ExpressionPanel:onShowPopup()
    self:stopAllActions()
    transition.moveTo(self, {time=0.3, x=ExpressionPanel.WIDTH * 0.5 + 8, easing="OUT", onComplete=function()
        -- local cbox = self:getCascadeBoundingBox()
        -- cbox:setRect(cbox.x, cbox.y, ExpressionPanel.WIDTH, ExpressionPanel.HEIGHT)
        -- self:setCascadeBoundingBox(cbox)
        if self.onShow then
            self:onShow()
        end
    end})
end

function ExpressionPanel:onShow()
    self.expressionNorList_:setScrollContentTouchRect()
    self.expressionNorList_:update()

    self.expressionCatAList_:setScrollContentTouchRect()
    self.expressionCatAList_:update()

    self.expressionCatBList_:setScrollContentTouchRect()
    self.expressionCatBList_:update()
end

function ExpressionPanel:hidePanel()
    nk.PopupManager:removePopup(self)
end

function ExpressionPanel:onRemovePopup(removeFunc)
    self:stopAllActions()
    transition.moveTo(self, {time=0.3, x=-ExpressionPanel.WIDTH * 0.5, easing="OUT", onComplete=function() 
        removeFunc()
        display.removeSpriteFramesWithFile("room_expression_popup.plist", "room_expression_popup.png")

        display.removeSpriteFramesWithFile("payExpr_catgy1.plist", "payExpr_catgy1.png")
        display.removeSpriteFramesWithFile("payExpr_catgy2.plist", "payExpr_catgy2.png")
    end})
end

return ExpressionPanel