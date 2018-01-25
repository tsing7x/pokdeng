--
-- Author: johnny@boomegg.com
-- Date: 2014-08-05 16:24:49
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

-- local DisplayUtil = import("app.util.DisplayUtil")

local LoginGameView = class("LoginGameView", function ()
    return display.newNode()
end)

local LoginFeedBack = import("app.module.hall.LoginFeedBack")
local DebugPopup = import("app.module.debugtools.DebugPopup")

local logger = bm.Logger.new("LoginGameView")

local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")

local DOTS_NUM         = 30
local LOGO_RADIUS      = 94
local LOGIN_BTN_WIDTH  = 338
local LOGIN_BTN_HEIGHT = 92
local LOGIN_BTN_GAP    = 20
local PANEL_WIDTH      = LOGIN_BTN_WIDTH + LOGIN_BTN_GAP * 2
local PANEL_HEIGHT     = LOGIN_BTN_HEIGHT * 2 + LOGIN_BTN_GAP * 3

local LOGO_POS_X = display.cx - 260
local LOGO_POS_Y = 176

function LoginGameView:ctor(controller)
    self:setNodeEventEnabled(true)
    self.controller_ = controller
    self.controller_:setDisplayView(self)

    --[[
        左侧漂浮的扑克牌
    ]]
    self.pokerBatchNode_ = display.newBatchNode("update_texture.png")
        :pos(-display.cx - 300, 0)
        :addTo(self)
    local animTime = 32
    local poker1 = display.newSprite("#float_poker_1.png")
        :pos(260, 122)
        :addTo(self.pokerBatchNode_)
    poker1:runAction(cc.RepeatForever:create(transition.sequence({
        cc.MoveTo:create(animTime, cc.p(-40, 122)), 
        cc.MoveTo:create(animTime, cc.p(260, 122))
    })))
    local poker2 = display.newSprite("#float_poker_2.png")
        :pos(140, -20)
        :addTo(self.pokerBatchNode_)
    poker2:runAction(cc.RepeatForever:create(transition.sequence({
        cc.MoveTo:create(animTime * 0.8, cc.p(292, -20)), 
        cc.MoveTo:create(animTime * 0.8, cc.p(-60, -20))
    })))
    local poker3 = display.newSprite("#float_poker_3.png")
        :pos(124, -132)
        :addTo(self.pokerBatchNode_)
    poker3:runAction(cc.RepeatForever:create(transition.sequence({
        cc.MoveTo:create(animTime * 0.7, cc.p(-76, -132)), 
        cc.MoveTo:create(animTime * 0.7, cc.p(284, -132))
    })))
    local poker4 = display.newSprite("#float_poker_4.png")
        :pos(64, -220)
        :addTo(self.pokerBatchNode_)
    poker4:runAction(cc.RepeatForever:create(transition.sequence({
        cc.MoveTo:create(animTime * 0.8, cc.p(244, -220)), 
        cc.MoveTo:create(animTime * 0.8, cc.p(-64, -220))
    })))
    local poker5 = display.newSprite("#float_poker_5.png")
        :pos(100, 64)
        :addTo(self.pokerBatchNode_)
    poker5:runAction(cc.RepeatForever:create(transition.sequence({
        cc.MoveTo:create(animTime * 1.2, cc.p(256, 64)), 
        cc.MoveTo:create(animTime * 1.2, cc.p(-76, 64))
    })))

    --[[
        游戏logo
    ]]
    self.tableNode_ = display.newNode()
        :addTo(self)

    local gameTable = display.newSprite("#login_game_table.png")
        :scale(self.controller_:getBgScale())
        :addTo(self.tableNode_)
    local tableWidth = gameTable:getContentSize().width
    if display.width * 0.75 > tableWidth then
        self.visibleTableWidth_ = tableWidth
        gameTable:align(display.LEFT_CENTER, display.cx - tableWidth, 0)
    else
        self.visibleTableWidth_ = display.width * 0.75
        gameTable:align(display.LEFT_CENTER, -display.cx * 0.5, 0)
    end
    self.tableNode_:pos(self.visibleTableWidth_, 0)

    self.logoBatchNode_ = display.newBatchNode("update_texture.png")
        :addTo(self.tableNode_)
    -- 圆点
    self.dots_ = {}
    for i = 1, DOTS_NUM do
        self.dots_[i] = display.newSprite("#login_rotary_dot.png")
        :pos(
                LOGO_POS_X + math.sin((i - 1) * math.pi / 15) * LOGO_RADIUS, 
                LOGO_POS_Y + math.cos((i - 1) * math.pi / 15) * LOGO_RADIUS
            )
        :opacity(0)
        :addTo(self.logoBatchNode_)
    end
    
    local logPosAdjust = {
        x = 0,
        y = - 14
    }
    -- 游戏logo
    display.newSprite("#game_logo.png")
        :pos(LOGO_POS_X + logPosAdjust.x, LOGO_POS_Y - logPosAdjust.y)
        :addTo(self.logoBatchNode_)

    -- 按钮栏背景
    self.btnNode_ = display.newNode()
        :addTo(self.tableNode_)
    local panelPosY =  LOGO_POS_Y - 264 * nk.heightScale
    display.newScale9Sprite("#login_btn_panel_bg.png", 0, 0, cc.size(PANEL_WIDTH, PANEL_HEIGHT))
        :pos(LOGO_POS_X, panelPosY)
        :addTo(self.btnNode_)
    display.newTilesSprite("repeat/login_btn_panel_repeat_tex.png", cc.rect(0, 0, PANEL_WIDTH - 8, PANEL_HEIGHT - 8))
        :align(display.CENTER, LOGO_POS_X, panelPosY)
        :addTo(self.btnNode_)

    if DEBUG >= 5 then
        cc.ui.UIPushButton.new({normal = "#float_poker_2.png", pressed = "#float_poker_2.png"}, {scale9 = true})
            :pos(display.cx - 40,display.cy - 40 )
            :addTo(self)
            :onButtonClicked(buttontHandler(self, self.onPhpSelector_))

        cc.ui.UIPushButton.new({normal = "#float_poker_1.png", pressed = "#float_poker_1.png"}, {scale9 = true})
            :pos(display.cx - 90,display.cy - 40 )
            :addTo(self)
            :onButtonClicked(buttontHandler(self, self.createNewAccount_))
    end

    -- FB登录按钮
    local btnCenterPosY = panelPosY + LOGIN_BTN_HEIGHT * 0.5 + LOGIN_BTN_GAP * 0.5
    display.newScale9Sprite("#login_btn_blue_bg.png", LOGO_POS_X, btnCenterPosY, cc.size(340, 94)):addTo(self.btnNode_)

    display.newSprite("#login_btn_fb_icon.png")
        :pos(LOGO_POS_X - LOGIN_BTN_WIDTH * 0.5 + 48, btnCenterPosY)
        :addTo(self.btnNode_)
    display.newTTFLabel({text = bm.LangUtil.getText("LOGIN", "FB_LOGIN"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 28, align = ui.TEXT_ALIGN_CENTER})
        :pos(LOGO_POS_X + 24, btnCenterPosY)
        :addTo(self.btnNode_)

    self.facebookBonusBackground_ = display.newSprite("#login_btn_fb_reward_icon.png")
            :pos(LOGIN_BTN_WIDTH * 0.5 - 22, 34)
            :hide()
    self.facebookBonusTextPlus_ = display.newTTFLabel({text = "+", color = styles.FONT_COLOR.GOLDEN_TEXT, size = 18, align = ui.TEXT_ALIGN_CENTER})
            :pos(LOGIN_BTN_WIDTH * 0.5 - 22, 48)
            :hide()
    self.facebookBonusText_ = display.newTTFLabel({text = "5000", color = styles.FONT_COLOR.GOLDEN_TEXT, size = 18, align = ui.TEXT_ALIGN_CENTER})
            :pos(LOGIN_BTN_WIDTH * 0.5 - 22, 32)
            :hide()

    cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#rounded_rect_10.png"}, {scale9 = true})
        :setButtonSize(LOGIN_BTN_WIDTH, LOGIN_BTN_HEIGHT)
        :pos(LOGO_POS_X, panelPosY + LOGIN_BTN_HEIGHT * 0.5 + LOGIN_BTN_GAP * 0.5 + 1)
        :addTo(self.btnNode_)
        :onButtonClicked(buttontHandler(self, self.onFacebookBtnClick_))
        :add(self.facebookBonusBackground_)
        :add(self.facebookBonusTextPlus_)
        :add(self.facebookBonusText_)

    -- 游客登录按钮
    btnCenterPosY = panelPosY - LOGIN_BTN_HEIGHT * 0.5 - LOGIN_BTN_GAP * 0.5
    display.newScale9Sprite("#login_btn_green_bg.png", LOGO_POS_X, btnCenterPosY, cc.size(340, 94)):addTo(self.btnNode_)
    display.newSprite("#login_btn_guest_icon.png")
        :pos(LOGO_POS_X - LOGIN_BTN_WIDTH * 0.5 + 48, btnCenterPosY)
        :addTo(self.btnNode_)
    display.newTTFLabel({text = bm.LangUtil.getText("LOGIN", "GU_LOGIN"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 28, align = ui.TEXT_ALIGN_CENTER})
        :pos(LOGO_POS_X + 24, btnCenterPosY)
        :addTo(self.btnNode_)
    cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#rounded_rect_10.png"}, {scale9 = true})
        :setButtonSize(LOGIN_BTN_WIDTH, LOGIN_BTN_HEIGHT)
        :pos(LOGO_POS_X, panelPosY - LOGIN_BTN_HEIGHT * 0.5 - LOGIN_BTN_GAP * 0.5 + 1)
        :addTo(self.btnNode_)
        :onButtonClicked(buttontHandler(self, self.onGuestBtnClick_))

    -- copyright
    -- color = cc.c3b(0x00, 0x6d, 0x32),
    self.copyrightLabel_ = display.newTTFLabel({
        text = bm.LangUtil.getText("ABOUT", "COPY_RIGHT") .. " V" .. BM_UPDATE.VERSION, 
        color = cc.c3b(0x6d, 0x6d, 0x6d), 
        size = 18, 
        align = ui.TEXT_ALIGN_CENTER
    })
        :align(display.RIGHT_BOTTOM, display.cx - 4, -(display.cy - 4))
        :addTo(self)

    --登陆前反
    self.loginFeedBackButton_ = cc.ui.UIPushButton.new({normal = "#login-feedback-up-icon.png",pressed = "#login-feedback-down-icon.png"})
        :pos(display.c_left + 45, display.c_bottom + 45)
        :onButtonClicked(buttontHandler(self, self.loginFeedBackHandler_))
        :addTo(self)

    local clearCacheBtnSize = {
        width = 80,
        height = 80
    }

    self.clearLoginCacheBtn_ = cc.ui.UIPushButton.new("#transparent.png", {scale9 = true})
        :setButtonSize(clearCacheBtnSize.width, clearCacheBtnSize.height)
        :onButtonClicked(buttontHandler(self, self.onClearBtnCallBack_))
        :pos(- display.cx + clearCacheBtnSize.width / 2, display.cy - clearCacheBtnSize.height / 2)
        :addTo(self)

    self.clearLoginCacheBtn_:setButtonEnabled(false)

    local bonus = BM_UPDATE.FACEBOOK_BONUS
    if bonus and bonus > 0 then
        self.facebookBonusBackground_:show()
        self.facebookBonusTextPlus_:show()
        self.facebookBonusText_:show():setString(bm.formatBigNumber(bonus))
    else
        self.facebookBonusBackground_:hide()
        self.facebookBonusTextPlus_:hide()
        self.facebookBonusText_:hide()
    end

    self:playDotsAnimInNormal_()


    -- self:addGrayFilter()

end

function LoginGameView:onEnter()
    local g = global_statistics_for_umeng
    g.umeng_view = g.Views.login
end

function LoginGameView:onExit()
    local g = global_statistics_for_umeng
    g.umeng_view = g.Views.other
end

function LoginGameView:playShowAnim()
    local animTime = self.controller_:getAnimTime()

    transition.fadeIn(self.copyrightLabel_, {time = animTime})
    transition.moveTo(self.pokerBatchNode_, {time = animTime, x = -display.cx})
    transition.moveTo(self.tableNode_, {time = animTime, x = 0})
    
end

function LoginGameView:setShowState()
    local animTime = self.controller_:getAnimTime()
    self.copyrightLabel_:show()
    self.pokerBatchNode_:setPositionX(-display.cx)
    transition.moveTo(self.tableNode_, {time = animTime, x = 0})
end

function LoginGameView:playHideAnim()
    local animTime = self.controller_:getAnimTime()

    transition.fadeOut(self.copyrightLabel_, {time = animTime})
    transition.moveTo(self.pokerBatchNode_, {time = animTime, x = -display.cx - 300})
    transition.moveTo(self.tableNode_, {
        time = animTime, 
        x = self.visibleTableWidth_, 
        onComplete = handler(self, function (obj)
            obj:removeFromParent()
        end)
    })
end

function LoginGameView:onFacebookBtnClick_()
    -- FB登录
    self.controller_:loginWithFacebook()
end

function LoginGameView:onGuestBtnClick_()
    -- 游客登录
    self.controller_:loginWithGuest()
end

function LoginGameView:playLoginAnim()
    self.clearLoginCacheBtn_:setButtonEnabled(true)

    self:playDotsAnimInLogin_()
    local animTime = self.controller_:getAnimTime()
    self.logoBatchNode_:stopAllActions()
    self.btnNode_:stopAllActions()
    if self.loadingLabel_ then
        self.loadingLabel_:removeFromParent()
        self.loadingLabel_ = nil
    end
    transition.moveTo(self.logoBatchNode_, {
        time = animTime, 
        y = -LOGO_POS_Y, 
    })
    transition.moveTo(self.btnNode_, {
        time = animTime, 
        x = display.cx + PANEL_WIDTH * 0.5, 
        onComplete = handler(self, function (obj)
            obj.loadingLabel_ = display.newTTFLabel({text = bm.LangUtil.getText("LOGIN", "LOGINING_MSG"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 28, align = ui.TEXT_ALIGN_CENTER})
                :pos(LOGO_POS_X, LOGO_POS_Y - 264 * nk.heightScale - 40)
                :addTo(obj.tableNode_)
        end)
    })
end

function LoginGameView:playLoginFailAnim()
    self.clearLoginCacheBtn_:setButtonEnabled(true)

    self:playDotsAnimInNormal_()
    local animTime = self.controller_:getAnimTime()
    self.logoBatchNode_:stopAllActions()
    self.btnNode_:stopAllActions()
    transition.moveTo(self.logoBatchNode_, {
        time = animTime, 
        y = 0, 
    })
    transition.moveTo(self.btnNode_, {
        time = animTime, 
        x = 0, 
    })
    if self.loadingLabel_ then
        self.loadingLabel_:removeFromParent()
        self.loadingLabel_ = nil 
    end
end

function LoginGameView:playDotsAnimInLogin_()
    self:stopDotsAnim_()
    self.firstDotId_ = 1
    self.dotsSchedulerHandle_ = scheduler.scheduleGlobal(handler(self, function (obj)
        obj.dots_[obj.firstDotId_]:runAction(transition.sequence({
                cc.FadeTo:create(0.3, 255), 
                cc.FadeTo:create(0.3, 32),
            })
        )
        local secondDotId = obj.firstDotId_ + DOTS_NUM * 0.5
        if secondDotId > DOTS_NUM then
            secondDotId = secondDotId - DOTS_NUM
        end
        obj.dots_[secondDotId]:runAction(transition.sequence({
                cc.FadeTo:create(0.3, 255), 
                cc.FadeTo:create(0.3, 32), 
            })
        )
        obj.firstDotId_ = obj.firstDotId_ + 1
        if obj.firstDotId_ > DOTS_NUM then
            obj.firstDotId_ = 1
        end
    end), 0.05)
end

function LoginGameView:playDotsAnimInNormal_()
    self:stopDotsAnim_()
    for _, dot in ipairs(self.dots_) do
        dot:runAction(cc.RepeatForever:create(cc.Sequence:create(
                    cc.FadeTo:create(1, 128), 
                    cc.FadeTo:create(1, 0)
                )
            )
        )
    end
end

function LoginGameView:stopDotsAnim_()
    for _, dot in ipairs(self.dots_) do
        dot:opacity(0)
        dot:stopAllActions()
    end
    if self.dotsSchedulerHandle_ then
        scheduler.unscheduleGlobal(self.dotsSchedulerHandle_)
        self.dotsSchedulerHandle_ = nil
    end
end

function LoginGameView:loginFeedBackHandler_()
    LoginFeedBack.new():show()
end

function LoginGameView:onPhpSelector_()
    DebugPopup.new():show()
end

function LoginGameView:createNewAccount_()
    -- 游客登录
    self.controller_:loginWithNewGuestByDebug()
end

function LoginGameView:onClearBtnCallBack_()
    -- body
    nk.ui.Dialog.new({messageText = bm.LangUtil.getText("LOGIN", "CLEAR_CACHE_TIP"), 
        callback = function (type)
            if type == nk.ui.Dialog.SECOND_BTN_CLICK then

                if self.controller_ and self.controller_.cancelLoginAndClearCache then
                    --todo
                    self.controller_:cancelLoginAndClearCache()
                end
            end
        end}):show()
end

function LoginGameView:onCleanup()
    if self.dotsSchedulerHandle_ then
        scheduler.unscheduleGlobal(self.dotsSchedulerHandle_)
        self.dotsSchedulerHandle_ = nil
    end
end

-- function LoginGameView:addGrayFilter()
--     DisplayUtil.setGray(self)
-- end

-- function LoginGameView:removeGrayFilter()
--     DisplayUtil.removeShader(self)
-- end

return LoginGameView
