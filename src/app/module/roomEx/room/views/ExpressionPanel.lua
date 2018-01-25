--
-- Author: tony
-- Date: 2014-08-16 18:05:06
--

local ExpressionPanel = class("ExpressionPanel", function() return display.newNode() end)
local ExpressionConfig = import(".ExpressionConfig").new()

ExpressionPanel.WIDTH = 512
ExpressionPanel.HEIGHT  = 480

function ExpressionPanel:ctor(ctx)
    self.ctx = ctx
    display.addSpriteFrames("room_expression_popup.plist", "room_expression_popup.png")
    self.background_ = display.newScale9Sprite("#room_chat_panel_background.png", 0, 0, cc.size(ExpressionPanel.WIDTH, ExpressionPanel.HEIGHT))
    self.background_:addTo(self)
    self:setTouchEnabled(true)
    self:setTouchSwallowEnabled(true)
    self:pos(-ExpressionPanel.WIDTH * 0.5, ExpressionPanel.HEIGHT * 0.5 + 80 + 8)
    self:createUI_()
end

function ExpressionPanel:showPanel()
    nk.PopupManager:addPopup(self, true, false, true, false)
end

function ExpressionPanel:hidePanel()
    nk.PopupManager:removePopup(self)
end

function ExpressionPanel:onRemovePopup(removeFunc)
    self:stopAllActions()
    transition.moveTo(self, {time=0.3, x=-ExpressionPanel.WIDTH * 0.5, easing="OUT", onComplete=function() 
        removeFunc()
        display.removeSpriteFramesWithFile("room_expression_popup.plist", "room_expression_popup.png")
    end})
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
    self.expressionList_:setScrollContentTouchRect()
    self.expressionList_:update()
end

function ExpressionPanel:createUI_()
    local rect = cc.rect(-ExpressionPanel.WIDTH * 0.5 + 6, -ExpressionPanel.HEIGHT* 0.5 + 6, ExpressionPanel.WIDTH - 12, ExpressionPanel.HEIGHT - 12)
    local page = display.newNode()
    local row, col = 1, 1
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
                self:onExpressionClicked(id)
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
    self.expressionList_ = bm.ui.ScrollView.new({viewRect=rect, scrollContent=page, direction=bm.ui.ScrollView.DIRECTION_VERTICAL})
    self.expressionList_:addTo(self)
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

return ExpressionPanel