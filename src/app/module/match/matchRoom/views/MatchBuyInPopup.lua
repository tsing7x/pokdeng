--
-- Author: tony
-- Date: 2014-08-24 17:58:50
--
local StorePopup = import("app.module.newstore.StorePopup")
local MatchBuyInPopup = class("MatchBuyInPopup", nk.ui.Panel)

local WIDTH = 680
local HEIGHT = 420
local TOP = HEIGHT * 0.5
local BOTTOM = HEIGHT * -0.5
local LEFT = -0.5 * WIDTH
local RIGHT = 0.5 * WIDTH

function MatchBuyInPopup:ctor(param)
    MatchBuyInPopup.super.ctor(self, {WIDTH, HEIGHT})

    self.schedulerPool_ = bm.SchedulerPool.new()
    self:setNodeEventEnabled(true)
    self.param_ = param
    self.min_ = param.minBuyIn
    self.max_ = param.maxBuyIn
    self.range_ = self.max_ - self.min_
    self.step_ = math.ceil(self.range_ / 10)
    self.myMoneyPercent_ = ((nk.userData and nk.userData['aUser.money'] or 0) - self.min_) / self.range_
    self.middlePercent_ = (self.max_ * 0.5 - self.min_) / self.range_

    self.bottomBackground_ = display.newScale9Sprite("#panel_overlay.png", 0, -46, cc.size(WIDTH - 8, HEIGHT - 100)):addTo(self)
    self.balanceBackground_ = display.newScale9Sprite("#popup_sub_tab_bar_bg.png", 0, TOP - 68, cc.size(408, 35)):addTo(self)
    self.barBackground_ = display.newScale9Sprite("#room_buyin_slider_bar_bg.png", 0, -24, cc.size(WIDTH - 200, 12)):addTo(self)
    self.curValueBg_ = display.newScale9Sprite("#common_input_bg.png", 0, 52, cc.size(280, 36)):addTo(self)

    self.batch_ = display.newBatchNode("room_texture.png"):addTo(self)

    --标题
    self.title_ = display.newTTFLabel({size=24, text=bm.LangUtil.getText("ROOM", "BUY_IN_TITLE"), color=cc.c3b(0xD3, 0xEA, 0xFF)}):pos(0, TOP - 28):addTo(self)

    self.balanceTitle_ = display.newTTFLabel({size=20, text=bm.LangUtil.getText("ROOM", "BUY_IN_BALANCE_TITLE"), color=cc.c3b(0xD3, 0xEA, 0xFF), align=ui.TEXT_ALIGN_RIGHT})
    self.balanceTitle_:setAnchorPoint(cc.p(1, 0.5))
    self.balanceTitle_:pos(-4, self.balanceBackground_:getPositionY())
    self.balanceTitle_:addTo(self)

    self.balanceValue_ = display.newTTFLabel({text="0", size=20, color=cc.c3b(0xFF, 0xD0, 0x1A), align=ui.TEXT_ALIGN_LEFT})
    self.balanceValue_:setAnchorPoint(cc.p(0, 0.5))
    self.balanceValue_:pos(4, self.balanceBackground_:getPositionY())
    self.balanceValue_:addTo(self)

    self.buyChipIcon_ = display.newSprite("#buyin_icon_add.png", 204 - 28, self.balanceBackground_:getPositionY()):addTo(self.batch_)

    self.titleMin_ = display.newTTFLabel({text=bm.LangUtil.getText("ROOM", "BUY_IN_MIN"),size=20, color=cc.c3b(0xD3, 0xEA, 0xFF), align=ui.TEXT_ALIGN_LEFT})
    self.titleMin_:setAnchorPoint(cc.p(0, 0.5))
    self.titleMin_:pos(LEFT + 32, 18)
    self.titleMin_:addTo(self)

    self.titleMax_ = display.newTTFLabel({text=bm.LangUtil.getText("ROOM", "BUY_IN_MAX"),size=20, color=cc.c3b(0xD3, 0xEA, 0xFF), align=ui.TEXT_ALIGN_RIGHT})
    self.titleMax_:setAnchorPoint(cc.p(1, 0.5))
    self.titleMax_:pos(RIGHT - 32, 18)
    self.titleMax_:addTo(self)

    self.numMin_ = display.newTTFLabel({text="$" .. bm.formatNumberWithSplit(param.minBuyIn),size=20, color=cc.c3b(0xD3, 0xEA, 0xFF), align=ui.TEXT_ALIGN_LEFT})
    self.numMin_:setAnchorPoint(cc.p(0, 0.5))
    self.numMin_:pos(LEFT + 32, 44)
    self.numMin_:addTo(self)

    self.numMax_ = display.newTTFLabel({text="$" .. bm.formatNumberWithSplit(param.maxBuyIn),size=20, color=cc.c3b(0xD3, 0xEA, 0xFF), align=ui.TEXT_ALIGN_RIGHT})
    self.numMax_:setAnchorPoint(cc.p(1, 0.5))
    self.numMax_:pos(RIGHT - 32, 44)
    self.numMax_:addTo(self)


    self.curValueLabel_ = display.newTTFLabel({size=20, color=cc.c3b(0xFF, 0xCF, 0x1A), align=ui.TEXT_ALIGN_CENTER}):addTo(self):pos(0, self.curValueBg_:getPositionY())

    self.subBtn_ = cc.ui.UIPushButton.new({normal="#room_buyin_sub_up_bg.png", pressed="#room_buyin_sub_down_bg.png", disabled="#room_buyin_sub_down_bg.png"}, {scale9=true})
        :onButtonClicked(function()
                nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
                self.curValue_ = self.curValue_ - self.step_
                if self.curValue_ < self.min_ then
                    self.curValue_ = self.min_
                elseif self.curValue_ > self.max_ then
                    self.curValue_ = self.max_
                end
                self:onSliderPercentValueChanged_(math.min(self.myMoneyPercent_, (self.curValue_ - self.min_) / self.range_), false, false)
            end)
        :setButtonSize(47, 46)
        :pos(LEFT + 54, self.barBackground_:getPositionY() + 1)
        :addTo(self)

    self.addBtn_ = cc.ui.UIPushButton.new({normal="#room_buyin_add_up_bg.png", pressed="#room_buyin_add_down_bg.png", disabled="#room_buyin_add_down_bg.png"}, {scale9=true})
        :onButtonClicked(function() 
                nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
                self.curValue_ = self.curValue_ + self.step_
                if self.curValue_ < self.min_ then
                    self.curValue_ = self.min_
                elseif self.curValue_ > self.max_ then
                    self.curValue_ = self.max_
                end
                self:onSliderPercentValueChanged_(math.min(self.myMoneyPercent_, (self.curValue_ - self.min_) / self.range_), false, false)
            end)
        :setButtonSize(47, 46)
        :pos(RIGHT - 54, self.barBackground_:getPositionY() + 1)
        :addTo(self)

    self.trackBar_ = display.newScale9Sprite("#room_raise_blue_track_bg.png")
    self.trackBar_:setAnchorPoint(cc.p(0.5, 1))
    self.trackBar_:rotation(-90)
    self.trackBar_:pos(self.barBackground_:getContentSize().width * -0.5, self.barBackground_:getPositionY())
    self.trackBar_:addTo(self)

    self.thumbSlideLen_ = self.barBackground_:getContentSize().width + 4 - 176 * 0.8
    self.thumbLeft_ = self.thumbSlideLen_ * -0.5
    self.thumbRight_ = self.thumbSlideLen_ * 0.5
    self.thumb_ = display.newSprite("#common_slider_thumb.png"):addTo(self)
    self.thumb_:setScale(0.8)
    self.thumb_:pos(0, self.barBackground_:getPositionY())
    self.thumb_:setTouchEnabled(true)
    self.thumb_:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.onThumbTouch_))

    self.autoBuyInChkboxBg_ = display.newSprite("#room_buyin_checkbox_bg.png", 0, -90):addTo(self)
    self.autoBuyInChkboxIcon_ = display.newSprite("#room_buyin_checkbox_icon.png"):addTo(self)
    self.autoBuyInChkboxPressed_ = display.newScale9Sprite("#common_button_pressed_cover.png", 0, 0, cc.size(20, 20)):addTo(self):hide()
    self.autoBuyInChkboxLabel_ = display.newTTFLabel({size=18, color=cc.c3b(0xD3, 0xEA, 0xFF), text=bm.LangUtil.getText("ROOM", "BUY_IN_AUTO")}):addTo(self)

    self.isAutoBuyin_ = param.isAutoBuyin
    self.autoBuyInChkboxIcon_:setVisible(self.isAutoBuyin_)
    local sizeck = self.autoBuyInChkboxBg_:getContentSize()
    local sizelb = self.autoBuyInChkboxLabel_:getContentSize()
    local chkboxW = sizeck.width + 8 + sizelb.width
    local chkboxH = math.max(sizeck.height, sizelb.height) + 16
    self.autoBuyInChkboxBg_:setPositionX(chkboxW * -0.5 + sizeck.width * 0.5)
    self.autoBuyInChkboxIcon_:pos(self.autoBuyInChkboxBg_:getPositionX(), self.autoBuyInChkboxBg_:getPositionY())
    self.autoBuyInChkboxPressed_:pos(self.autoBuyInChkboxBg_:getPositionX(), self.autoBuyInChkboxBg_:getPositionY())
    self.autoBuyInChkboxLabel_:pos(sizeck.width * 0.5 + 4, self.autoBuyInChkboxBg_:getPositionY())
    cc.ui.UIPushButton.new("#transparent.png", {scale9=true}):setButtonSize(chkboxW + 16, chkboxH)
        :onButtonPressed(function()
                self.autoBuyInChkboxPressed_:show()
            end)
        :onButtonRelease(function()
                self.autoBuyInChkboxPressed_:hide()
            end)
        :onButtonClicked(function()
                nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
                self.isAutoBuyin_ = not self.isAutoBuyin_
                nk.userDefault:setBoolForKey(nk.cookieKeys.AUTO_BUY_IN, self.isAutoBuyin_)
                nk.userDefault:flush()
                self.autoBuyInChkboxIcon_:setVisible(self.isAutoBuyin_)
            end)
        :pos(0, self.autoBuyInChkboxBg_:getPositionY())
        :addTo(self)

    self.buyInBtn_ = cc.ui.UIPushButton.new({normal="#common_green_btn_up.png", pressed="#common_green_btn_down.png", disabled="#common_btn_disabled.png"}, {scale9=true})
        :setButtonLabel(display.newTTFLabel({size=24, text=bm.LangUtil.getText("ROOM", "BUY_IN_BTN_LABEL"), color=cc.c3b(0xcb, 0xe6, 0xff)}))
        :setButtonSize(200, 64)
        :onButtonClicked(function() 
                nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
                self.param_.callback(self.curValue_, self.isAutoBuyin_)
                self:hidePanel()
            end)
        :pos(0, -156)
        :addTo(self)

    
    print("self.myMoneyPercent_", self.myMoneyPercent_)
    self:onSliderPercentValueChanged_(math.min(self.middlePercent_, self.myMoneyPercent_), true, false)

    self.buyBtn_ = cc.ui.UIPushButton.new({normal="#transparent.png", pressed="#common_button_pressed_cover.png"}, {scale9=true})
        :pos(self.balanceBackground_:getPositionX(), self.balanceBackground_:getPositionY())
        :setButtonSize(self.balanceBackground_:getContentSize().width - 2, self.balanceBackground_:getContentSize().height - 2)
        :onButtonClicked(function()
                nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
                self:hidePanel()
                StorePopup.new():showPanel()
            end)
        :addTo(self)

    self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.onEnterFrame_))
end

function MatchBuyInPopup:onThumbTouch_(evt)
    local name, x, y, prevX, prevY = evt.name, evt.x, evt.y, evt.prevX, evt.prevY
    local isTouchInSprite = self.thumb_:getCascadeBoundingBox():containsPoint(cc.p(x, y))
    if name == "began" then
        if isTouchInSprite then
            self.isThumbTouching_ = true
            self.thumbTouchBeginX_ = x
            self.thumbBeginX_ = self.thumb_:getPositionX()
            self:unscheduleUpdate()
            return true
        else
            return false
        end
    elseif not self.isThumbTouching_ then
        return false
    elseif name == "moved" then
        local movedX = x - self.thumbTouchBeginX_
        local toX = self.thumbBeginX_ + movedX
        if toX >= self.thumbRight_ then
            toX = self.thumbRight_
        elseif toX <= self.thumbLeft_ then
            toX = self.thumbLeft_
        end
        local val = (toX - self.thumbLeft_) / self.thumbSlideLen_
        self:onSliderPercentValueChanged_(val, false, true)
    elseif name == "ended"  or name == "cancelled" then
        self.isThumbTouching_ = false
        self.posPercent_ = (self.thumb_:getPositionX() - self.thumbLeft_) / self.thumbSlideLen_
        if self.posPercent_ > self.myMoneyPercent_ then
            self:scheduleUpdate()
            self.animIsShow_ = false
            self.animCount_ = 2 * 2
            self.schedulerPool_:clearAll()
            self.schedulerPool_:loopCall(function()
                print(self.animIsShow_, self.animCount_)
                self.buyChipIcon_:setOpacity(self.animIsShow_ and 255 or 0.3 * 255)
                self.balanceValue_:setOpacity(self.animIsShow_ and 255 or 0.3 * 255)
                self.animIsShow_ = not self.animIsShow_
                self.animCount_ = self.animCount_ - 1
                if self.animCount_ == 0 then
                    self.buyChipIcon_:setOpacity(255)
                    self.balanceValue_:setOpacity(255)
                    return false
                end
                return true
            end, 0.1)
        end
    end
    return true
end

function MatchBuyInPopup:onEnterFrame_()
    if self.posPercent_ <= self.myMoneyPercent_ then
        self.posPercent_ = self.myMoneyPercent_
        self:unscheduleUpdate()
    else
        self.posPercent_ = self.posPercent_ - math.max((self.posPercent_ - self.myMoneyPercent_) * 0.06, 2 / self.thumbSlideLen_)
        if self.posPercent_ <= self.myMoneyPercent_ then
            self.posPercent_ = self.myMoneyPercent_
            self:unscheduleUpdate()
        end
    end
    self:onSliderPercentValueChanged_(self.posPercent_, true, false)
end

function MatchBuyInPopup:onSliderPercentValueChanged_(newVal, forceUpdate, needSound)
    if self.percentValue_ ~= newVal or forceUpdate then
        local curTime = bm.getTime()
        local prevTime = self.lastRaiseSliderGearTickPlayTime_ or 0

        local moneyVal = math.round(self.min_ + self.range_ * newVal)
        if moneyVal > (nk.userData and nk.userData['aUser.money'] or 0) then
            self.curValueLabel_:setTextColor(cc.c3b(0xFF, 0x83, 0x0B))
        else
            self.curValueLabel_:setTextColor(cc.c3b(0xFF, 0xCF, 0x1A))
        end
        self.curValueLabel_:setString("$" .. bm.formatNumberWithSplit(moneyVal))
        self.thumb_:setPositionX(self.thumbLeft_ + self.thumbSlideLen_ * newVal)

        newVal = math.max(0, math.min(self.myMoneyPercent_, newVal, 1))

        self.prevValue_ = self.curValue_
        self.curValue_ = math.round(self.min_ + self.range_ * newVal)
        if needSound and self.prevValue_ ~= self.curValue_  and curTime - prevTime > 0.05 then
            self.lastRaiseSliderGearTickPlayTime_ = curTime
            nk.SoundManager:playSound(nk.SoundManager.GEAR_TICK)
        end
        self.percentValue_ = newVal
        self.trackBar_:setContentSize(cc.size(12, newVal * self.thumbSlideLen_ + 176 * 0.5))
        self.subBtn_:setButtonEnabled(newVal > 0)
        self.addBtn_:setButtonEnabled(newVal < math.min(self.myMoneyPercent_, 1))
    end
end

function MatchBuyInPopup:showPanel()
    self:showPanel_(true, true, true, true)
end

function MatchBuyInPopup:hidePanel()
    self:hidePanel_()
end

function MatchBuyInPopup:onEnter()
    if not self.moneyChangeObserverId_ then
        self.moneyChangeObserverId_ = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "aUser.money", handler(self, self.onMoneyChanged_))
    end
end

function MatchBuyInPopup:onExit()
    if self.moneyChangeObserverId_ then
        bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "aUser.money", self.moneyChangeObserverId_)
        self.moneyChangeObserverId_ = nil
    end
    self.buyChipIcon_:setOpacity(255)
    self.balanceValue_:setOpacity(255)
    self.schedulerPool_:clearAll()
end

function MatchBuyInPopup:onMoneyChanged_(money)
    self.balanceValue_:setString(bm.formatBigNumber(money or 0))
    self.myMoneyPercent_ = math.max(0, ((money or 0) - self.min_) / self.range_)
end

return MatchBuyInPopup