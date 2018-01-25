--
-- Author: viking@boomegg.com
-- Date: 2014-08-22 16:50:03
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--
local UpdatePopup = import(".UpdatePopup")
local SettingView = class("SettingView", function ()
    return display.newNode()
end)

local AboutPopup = import("app.module.about.AboutPopup")

local labelTitleSize = 26
local labelContentSize = 26
local labelTitleColor = cc.c3b(0x27, 0x90, 0xd5)
local labelContentColor = cc.c3b(0xca, 0xca, 0xca)

local contentWidth = 728
local contentHeight = 62

function SettingView:ctor(mainView)
    self.mainView_ = mainView
    self:setupView()

    self:addNodeEventListener(cc.NODE_EVENT, function(event)
            if event.name == "exit" then
                    self:exit()
            end
       end)
end

function SettingView:exit()
    print("setting exit")
    cc.UserDefault:getInstance():setBoolForKey(nk.cookieKeys.SHOCK, self.isVibrate_)
    cc.UserDefault:getInstance():setBoolForKey(nk.cookieKeys.AUTO_SIT, self.isAutoSit_)
    cc.UserDefault:getInstance():setBoolForKey(nk.cookieKeys.AUTO_BUY_IN, self.isAutoBuyin_)
    cc.UserDefault:getInstance():flush()
end

function SettingView:setupView()
    local size_ = self.mainView_.background_:getContentSize()

    local titlePadding = self.mainView_.TAB_HEIGHT
    local contentPadding = 12
    local contentMarginTop = 12
    local bottomMargin = 12
    local heightSum = 0
    local leftOriginX = titlePadding
    local topOriginY = size_.height/2 - (self.mainView_.TAB_HEIGHT + self.mainView_.PADDING)

    --ScrollView
    local scrollContent = display.newNode() 
    local container = display.newNode():addTo(scrollContent)

    local w, h = contentWidth, size_.height - bottomMargin - self.mainView_.TAB_HEIGHT - contentMarginTop
    local bound = cc.rect(-0.5*w, -0.5*h, w, h)
    -- print(size_.width, size_.height)
    -- print(bound.origin.x, bound.origin.y, bound.size.width, bound.size.height)

    heightSum = heightSum  + titlePadding
    topOriginY = topOriginY - titlePadding

    local nickNameContent = display.newScale9Sprite("#panel_overlay.png", 
                contentWidth/2, topOriginY - contentHeight/2, cc.size(contentWidth, contentHeight))
        nickNameContent:addTo(container)

    --昵称
    local nickNameTitle = display.newTTFLabel({
            text = bm.LangUtil.getText("SETTING", "NICK"),
            size = labelContentSize,
            color = labelContentColor,
            align = ui.TEXT_ALIGN_CENTER
        })
        nickNameTitle:setAnchorPoint(cc.p(0, 0.5))
        nickNameTitle:addTo(nickNameContent)
        nickNameTitle:pos(contentPadding, contentHeight/2)

    --昵称名字
    local nickNamePadding = 20
    local nickName = display.newTTFLabel({
            text = nk.userData["aUser.name"], 
            size = labelContentSize, 
            color = labelTitleColor, 
            align = ui.TEXT_ALIGN_CENTER
        })
        nickName:addTo(nickNameContent)
        nickName:setAnchorPoint(cc.p(0, 0.5))
        nickName:pos(contentPadding + nickNameTitle:getContentSize().width + nickNamePadding, contentHeight/2)

    --登出按钮
    if not self.mainView_.isInRoom then
        local logOutBtn = cc.ui.UIPushButton.new({normal = "#common_red_btn_up.png", pressed = "#common_red_btn_down.png"}, {scale9 = true})
            :setButtonSize(166, 52)
            :setButtonLabel(display.newTTFLabel({
                text = bm.LangUtil.getText("SETTING", "LOGOUT"), 
                size = labelTitleSize, 
                color = cc.c3b(0xc7, 0xe5, 0xff), 
                align = ui.TEXT_ALIGN_LEFT}))
            :addTo(nickNameContent)
            :pos(contentWidth - 166/2 - 8, contentHeight/2)
            :onButtonClicked(buttontHandler(self, self.logOut_))
    end

    heightSum = heightSum + contentHeight + contentMarginTop
    topOriginY = topOriginY - contentHeight - contentMarginTop

    --声音和震动
    local soundVibrateContent = display.newScale9Sprite("#panel_overlay.png", 
            contentWidth/2, topOriginY - contentHeight, cc.size(contentWidth, contentHeight * 2))
        soundVibrateContent:addTo(container)

    local dividerWidth = 692
    local dividerHeight = 2
    --万恶的分割线
    display.newScale9Sprite("#pop_up_split_line.png", contentWidth/2, contentHeight)
        :addTo(soundVibrateContent)
        :size(dividerWidth, dividerHeight)

    --声音
    local sound = display.newTTFLabel({
        text = bm.LangUtil.getText("SETTING", "SOUND"),
        size = labelContentSize,
        color = labelContentColor,
        align = ui.TEXT_ALIGN_CENTER
        })
        sound:addTo(soundVibrateContent)
        sound:setAnchorPoint(cc.p(0, 0.5))
        sound:pos(contentPadding, contentHeight + contentHeight/2)

    --声音调节
    self.soundSliderScale_ = 0.9
    local soundSliderScale = self.soundSliderScale_
    self.soundWidth_ = 520
    local soundWidth = self.soundWidth_ / soundSliderScale
    local soundHeight = 12 /soundSliderScale
    local fgSoundHeight = 10 / soundSliderScale
    local soundPosX = contentWidth - 593

    local soundProgressBg = display.newScale9Sprite("#common_progress_bg.png")
        :align(display.LEFT_CENTER, soundPosX + 2, contentHeight * 3/2)
        :size(soundWidth - 4, soundHeight)
        :addTo(soundVibrateContent)
        :scale(soundSliderScale)

    self.soundProgressFg = display.newScale9Sprite("#common_progress_fg.png")
        :align(display.LEFT_CENTER, soundPosX + 4, contentHeight * 3/2)
        :size(0, fgSoundHeight)
        :addTo(soundVibrateContent)    
        :scale(soundSliderScale)
        :hide()

    local soundSlider = cc.ui.UISlider.new(display.LEFT_TO_RIGHT, {bar = "#transparent.png", button = "#setting_seekbar_thumb.png"}, {scale9 = true})
        :onSliderValueChanged(handler(self, self.soundValueChangeListener))
        :setSliderSize(soundWidth, soundHeight)
        :align(display.LEFT_BOTTOM, soundPosX, contentHeight * 3/2)
        :addTo(soundVibrateContent)
        :onSliderRelease(handler(self, self.soundValueUpdate_))
        :scale(soundSliderScale)
        soundSlider:setAnchorPoint(cc.p(0, 0.5))
        local volume = cc.UserDefault:getInstance():getIntegerForKey(nk.cookieKeys.VOLUME, 100)
        soundSlider:setSliderValue(volume)

    local soundScale = 0.9
    local xPosPadding = sound:getPositionX() + sound:getContentSize().width + 30

    --静音按钮
    local soundMinIcon = cc.ui.UIPushButton.new({normal = "#setting_sound_min_icon.png", pressed = "#setting_sound_min_icon_pressed.png"})
        :pos(xPosPadding, contentHeight * 3/2)
        :addTo(soundVibrateContent)
        :onButtonClicked(function(evt)
            soundSlider:setSliderValue(0)
            self:soundValueUpdate_()
        end)
        :scale(soundScale)

    --最大音量按钮
    local soundMaxIcon = cc.ui.UIPushButton.new({normal = "#setting_sound_max_icon.png", pressed = "#setting_sound_max_icon_pressed.png"})
        :pos(contentWidth - 39, contentHeight * 3/2)
        :addTo(soundVibrateContent)
        :onButtonClicked(function ()
            soundSlider:setSliderValue(100)
            self:soundValueUpdate_()
        end)
        :scale(soundScale)

    --震动
    local vibrate = display.newTTFLabel({
        text = bm.LangUtil.getText("SETTING", "VIBRATE"),
        size = labelContentSize,
        color = labelContentColor,
        align = ui.TEXT_ALIGN_CENTER
        })
        vibrate:addTo(soundVibrateContent)
        vibrate:setAnchorPoint(cc.p(0, 0.5))
        vibrate:pos(contentPadding, contentHeight/2)

    local switchPadding = 165
    local switchScale = 0.9
    --震动开关
    -- local vibMaskSwitchSprite = display.newSprite("setting/setting_checkbox_mask.png")
    -- local vibOnSwitchSprite = display.newSprite("setting/setting_checkbox_on.png")
    -- local vibOffSwitchSprite = display.newSprite("setting/setting_checkbox_off.png")
    -- local vibThumbSwitchSprite = display.newSprite("setting/setting_checkbox_thumb.png")
    -- self.vibrateSwitch = CCControlSwitch:create(vibMaskSwitchSprite, vibOnSwitchSprite, vibOffSwitchSprite, vibThumbSwitchSprite)
    --     self.vibrateSwitch:addTo(soundVibrateContent)
    --     self.vibrateSwitch:pos(contentWidth - switchPadding, contentHeight/2)
    --     self.vibrateSwitch:setAnchorPoint(cc.p(0, 0.5))
    local isShock = cc.UserDefault:getInstance():getBoolForKey(nk.cookieKeys.SHOCK, false)
    -- self.vibrateSwitch:setOn(isShock)
    -- self.vibrateSwitch:addHandleOfControlEvent(handler(self, self.vibrateChangeListener), CCControlEventValueChanged)

    self.vibrateSwitch = cc.ui.UICheckBoxButton.new({
            on = "#setting_checkbox_on.png",
            off = "#setting_checkbox_off.png"
        })
        :onButtonStateChanged(handler(self, self.vibrateChangeListener))
        :align(display.LEFT_CENTER, contentWidth - switchPadding, contentHeight/2)
        :addTo(soundVibrateContent)
        :setButtonSelected(isShock)
        :scale(switchScale)

    heightSum = heightSum  + contentHeight * 2 + contentMarginTop
    topOriginY = topOriginY - contentHeight * 2 - contentMarginTop

    --自动坐下以及自动买入
    local autoOptItemCount = 2
    local autoOptHeight = autoOptItemCount * contentHeight
    local autoOptContent = display.newScale9Sprite("#panel_overlay.png", 
            contentWidth/2, topOriginY - autoOptHeight/2, cc.size(contentWidth, autoOptHeight))
        autoOptContent:addTo(container)

    --万恶的分割线
    display.newScale9Sprite("#pop_up_split_line.png", contentWidth/2, (autoOptItemCount-1) * contentHeight)
        :addTo(autoOptContent)
        :size(dividerWidth, dividerHeight)

    --自动坐下
    local autoSit = display.newTTFLabel({
        text = bm.LangUtil.getText("SETTING", "AUTO_SIT"),
        size = labelContentSize,
        color = labelContentColor,
        align = ui.TEXT_ALIGN_CENTER
        })
        autoSit:addTo(autoOptContent)
        autoSit:setAnchorPoint(cc.p(0, 0.5))
        autoSit:pos(contentPadding, contentHeight * (autoOptItemCount-1) + contentHeight/2)

    --自动坐下开关
    -- local sitMaskSwitchSprite = display.newSprite("setting/setting_checkbox_mask.png")
    -- local sitOnSwitchSprite = display.newSprite("setting/setting_checkbox_on.png")
    -- local sitOffSwitchSprite = display.newSprite("setting/setting_checkbox_off.png")
    -- local sitThumbSwitchSprite = display.newSprite("setting/setting_checkbox_thumb.png")
    -- self.autoSitSwitch = CCControlSwitch:create(sitMaskSwitchSprite, sitOnSwitchSprite, sitOffSwitchSprite, sitThumbSwitchSprite)
    --     self.autoSitSwitch:addTo(autoOptContent)
    --     self.autoSitSwitch:pos(contentWidth - switchPadding, contentHeight * (autoOptItemCount-1) + contentHeight/2)
    --     self.autoSitSwitch:setAnchorPoint(cc.p(0, 0.5))
    --     self.autoSitSwitch:addHandleOfControlEvent(handler(self, self.autoSitChangeListener), CCControlEventValueChanged)
    local isAutoSit = cc.UserDefault:getInstance():getBoolForKey(nk.cookieKeys.AUTO_SIT, true)
    -- self.autoSitSwitch:setOn(isAutoSit)

    self.autoSitSwitch = cc.ui.UICheckBoxButton.new({
            on = "#setting_checkbox_on.png",
            off = "#setting_checkbox_off.png"
        })
        :onButtonStateChanged(handler(self, self.autoSitChangeListener))
        :align(display.LEFT_CENTER, contentWidth - switchPadding, contentHeight * (autoOptItemCount-1) + contentHeight/2)
        :addTo(autoOptContent)
        :setButtonSelected(isAutoSit)
        :scale(switchScale)

    --自动买入
    local autoBuyin = display.newTTFLabel({
        text = bm.LangUtil.getText("SETTING", "AUTO_BUYIN"),
        size = labelContentSize,
        color = labelContentColor,
        align = ui.TEXT_ALIGN_CENTER
        })
        autoBuyin:addTo(autoOptContent)
        autoBuyin:setAnchorPoint(cc.p(0, 0.5))
        autoBuyin:pos(contentPadding, contentHeight * (autoOptItemCount-2) + contentHeight/2)

    --自动买入开关
    -- local buyMaskSwitchSprite = display.newSprite("setting/setting_checkbox_mask.png")
    -- local buyOnSwitchSprite = display.newSprite("setting/setting_checkbox_on.png")
    -- local buyOffSwitchSprite = display.newSprite("setting/setting_checkbox_off.png")
    -- local buyThumbSwitchSprite = display.newSprite("setting/setting_checkbox_thumb.png")
    -- self.autobuySwitch = CCControlSwitch:create(buyMaskSwitchSprite, buyOnSwitchSprite, buyOffSwitchSprite, buyThumbSwitchSprite)
    --     self.autobuySwitch:addTo(autoOptContent)
    --     self.autobuySwitch:pos(contentWidth - switchPadding, contentHeight * (autoOptItemCount-2) + contentHeight/2)
    --     self.autobuySwitch:setAnchorPoint(cc.p(0, 0.5))
    --     self.autobuySwitch:addHandleOfControlEvent(handler(self, self.autoBuyinChangeListener), CCControlEventValueChanged)
    local isBuyin = cc.UserDefault:getInstance():getBoolForKey(nk.cookieKeys.AUTO_BUY_IN, true)
    -- self.autobuySwitch:setOn(isBuyin)

    self.autobuySwitch = cc.ui.UICheckBoxButton.new({
            on = "#setting_checkbox_on.png",
            off = "#setting_checkbox_off.png"
        })
        :onButtonStateChanged(handler(self, self.autoBuyinChangeListener))
        :align(display.LEFT_CENTER, contentWidth - switchPadding, contentHeight * (autoOptItemCount-2) + contentHeight/2)
        :addTo(autoOptContent)
        :setButtonSelected(isBuyin)
        :scale(switchScale)

    heightSum = heightSum  + contentHeight * 2 + contentMarginTop
    topOriginY = topOriginY - contentHeight * 2 - contentMarginTop

    --其他内容
    local otherItemCount = 4
    local otherHeight = otherItemCount * contentHeight
    local otherContent = display.newScale9Sprite("#panel_overlay.png", contentWidth/2, topOriginY - otherHeight/2, cc.size(contentWidth, otherHeight))
        otherContent:addTo(container)    

    --万恶的分割线
    display.newScale9Sprite("#pop_up_split_line.png", contentWidth/2, (otherItemCount-1) * contentHeight)
        :addTo(otherContent)
        :size(dividerWidth, dividerHeight)

    display.newScale9Sprite("#pop_up_split_line.png", contentWidth/2, (otherItemCount-2) * contentHeight)
        :addTo(otherContent)
        :size(dividerWidth, dividerHeight)    

    display.newScale9Sprite("#pop_up_split_line.png", contentWidth/2, (otherItemCount-3) * contentHeight)
        :addTo(otherContent)
        :size(dividerWidth, dividerHeight)

    --到应用商城去评分
    local appStoreGradeBtn = cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#setting_content_up_pressed.png"}, {scale9 = true})
        :setButtonSize(contentWidth, contentHeight)
        :addTo(otherContent)
        :pos(0, contentHeight * (otherItemCount-1) + contentHeight/2)
        appStoreGradeBtn:setTouchSwallowEnabled(false)
        appStoreGradeBtn:setAnchorPoint(cc.p(0, 0.5))

    --评分文字
    local appStoreLabel = display.newTTFLabel({
        text = bm.LangUtil.getText("SETTING", "APP_STORE_GRADE"),
        size = labelContentSize,
        color = labelContentColor,
        align = ui.TEXT_ALIGN_CENTER
        })
        appStoreLabel:addTo(otherContent)
        appStoreLabel:setAnchorPoint(cc.p(0, 0.5))
        appStoreLabel:pos(contentPadding, contentHeight * (otherItemCount-1) + contentHeight/2)

    local arrowPadding = 45
    --评分箭头
    local appStoreArrow = display.newSprite("#setting_arrow_right.png")
        appStoreArrow:addTo(otherContent)
        appStoreArrow:pos(contentWidth - arrowPadding, contentHeight * (otherItemCount-1) + contentHeight/2)
        appStoreArrow:setAnchorPoint(cc.p(0, 0.5))

    local appStoreArrowPress = display.newSprite("#setting_arrow_right_pressed.png"):addTo(appStoreArrow):align(display.LEFT_BOTTOM, 0, 0):hide()
    self:buttonTouchHandler(appStoreGradeBtn, buttontHandler(self, self.appStoreOnClick), appStoreArrowPress)

    --检测更新
    local checkVersionBtn = cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#setting_content_middle_pressed.png"}, {scale9 = true})
        :setButtonSize(contentWidth, contentHeight)
        :addTo(otherContent)
        :pos(0, contentHeight * (otherItemCount-2) + contentHeight/2)
        checkVersionBtn:setTouchSwallowEnabled(false)
        checkVersionBtn:setAnchorPoint(cc.p(0, 0.5))

    --更新文字
    local checkVersionLabel = display.newTTFLabel({
        text = bm.LangUtil.getText("SETTING", "CHECK_VERSION"),
        size = labelContentSize,
        color = labelContentColor,
        align = ui.TEXT_ALIGN_CENTER
        })
        checkVersionLabel:addTo(otherContent)
        checkVersionLabel:setAnchorPoint(cc.p(0, 0.5))
        checkVersionLabel:pos(contentPadding, contentHeight * (otherItemCount-2) + contentHeight/2)

    --更新箭头
    local checkVersionArrow = display.newSprite("#setting_arrow_right.png")
        checkVersionArrow:addTo(otherContent)
        checkVersionArrow:pos(contentWidth - arrowPadding, contentHeight * (otherItemCount-2) + contentHeight/2)
        checkVersionArrow:setAnchorPoint(cc.p(0, 0.5))

    local checkVersionArrowPress = display.newSprite("#setting_arrow_right_pressed.png"):addTo(checkVersionArrow):align(display.LEFT_BOTTOM, 0, 0):hide()
    self:buttonTouchHandler(checkVersionBtn, buttontHandler(self, self.checkVersionOnClick), checkVersionArrowPress)

    --当前版本号
    local currentVersionPadding = 15
    local currentVersion = nk.Native:getAppVersion()
    local currentVersionLabel = display.newTTFLabel({
        text = bm.LangUtil.getText("SETTING", "CURRENT_VERSION", BM_UPDATE and BM_UPDATE.VERSION or currentVersion),
        size = labelContentSize,
        color = labelContentColor,
        align = ui.TEXT_ALIGN_CENTER
        })
        currentVersionLabel:addTo(otherContent)
        currentVersionLabel:setAnchorPoint(cc.p(0, 0.5))
        currentVersionPadding = currentVersionPadding + currentVersionLabel:getContentSize().width + arrowPadding
        currentVersionLabel:pos(contentWidth - currentVersionPadding, contentHeight * (otherItemCount-2) + contentHeight/2)    

    --官方粉丝页
    local fansBtn = cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#setting_content_middle_pressed.png"}, {scale9 = true})
        :setButtonSize(contentWidth, contentHeight)
        :addTo(otherContent)
        :pos(0, contentHeight * (otherItemCount-3) + contentHeight/2)
        fansBtn:setTouchSwallowEnabled(false)
        fansBtn:setAnchorPoint(cc.p(0, 0.5))

    --官方粉丝也文字
    local fansLabel = display.newTTFLabel({
        text = bm.LangUtil.getText("SETTING", "FANS"),
        size = labelContentSize,
        color = labelContentColor,
        align = ui.TEXT_ALIGN_CENTER
        })
        fansLabel:addTo(otherContent)
        fansLabel:setAnchorPoint(cc.p(0, 0.5))
        fansLabel:pos(contentPadding, contentHeight * (otherItemCount-3) + contentHeight/2)

    --官方粉丝页箭头
    local fansArrow = display.newSprite("#setting_arrow_right.png")
        fansArrow:addTo(otherContent)
        fansArrow:pos(contentWidth - arrowPadding, contentHeight * (otherItemCount-3) + contentHeight/2)
        fansArrow:setAnchorPoint(cc.p(0, 0.5))    

    local fansArrowPress = display.newSprite("#setting_arrow_right_pressed.png"):addTo(fansArrow):align(display.LEFT_BOTTOM, 0, 0):hide()
    self:buttonTouchHandler(fansBtn, buttontHandler(self, self.fansOnClick), fansArrowPress)

    --关于
    local aboutBtn = cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#setting_content_down_pressed.png"}, {scale9 = true})
        :setButtonSize(contentWidth, contentHeight)
        :addTo(otherContent)
        :pos(0, contentHeight * (otherItemCount-4) + contentHeight/2)
        aboutBtn:setTouchSwallowEnabled(false)
        aboutBtn:setAnchorPoint(cc.p(0, 0.5))

    --关于文字
    local aboutLabel = display.newTTFLabel({
        text = bm.LangUtil.getText("SETTING", "ABOUT"),
        size = labelContentSize,
        color = labelContentColor,
        align = ui.TEXT_ALIGN_CENTER
        })
        aboutLabel:addTo(otherContent)
        aboutLabel:setAnchorPoint(cc.p(0, 0.5))
        aboutLabel:pos(contentPadding, contentHeight * (otherItemCount-4) + contentHeight/2)

    --关于箭头
    local aboutArrow = display.newSprite("#setting_arrow_right.png")
        aboutArrow:addTo(otherContent)
        aboutArrow:pos(contentWidth - arrowPadding, contentHeight * (otherItemCount-4) + contentHeight/2)
        aboutArrow:setAnchorPoint(cc.p(0, 0.5))    

    local aboutArrowPress = display.newSprite("#setting_arrow_right_pressed.png"):addTo(aboutArrow):align(display.LEFT_BOTTOM, 0, 0):hide()
    self:buttonTouchHandler(aboutBtn, buttontHandler(self, self.aboutOnClick), aboutArrowPress)

    heightSum = heightSum  + contentHeight * otherItemCount + contentMarginTop + 23

    container:pos(-contentWidth/2, heightSum/2 - contentHeight * otherItemCount/2 - 26)
    self.scrollView_ = bm.ui.ScrollView.new({viewRect = bound, scrollContent = scrollContent, direction = bm.ui.ScrollView.DIRECTION_VERTICAL})
        :addTo(self):pos(0, -(size_.height/2 - bottomMargin - h/2))
end

function SettingView:buttonTouchHandler(button, clickCallback, arrowIcon)
    button:onButtonPressed(function(evt)
        self.btnPressedY_ = evt.y
        self.btnClickCanceled_ = false
        arrowIcon:show()
    end)
    button:onButtonRelease(function(evt)
        if math.abs(evt.y - self.btnPressedY_) > 10 then
            self.btnClickCanceled_ = true
        end
        arrowIcon:hide()
    end)
    button:onButtonClicked(function(evt)
        if not self.btnClickCanceled_ and self:getParent():getParent():getCascadeBoundingBox():containsPoint(cc.p(evt.x, evt.y)) then
            clickCallback()
        end
    end)    
end

function SettingView:logOut_()
    print("logout")
    self.mainView_:onClose()
    -- 派发登出成功事件
    bm.EventCenter:dispatchEvent(nk.eventNames.HALL_LOGOUT_SUCC)
end

function SettingView:vibrateChangeListener(event)
    if self.canSound then
        nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
    end
    
    -- if self.vibrateSwitch:isOn() then
    if event.target:isButtonSelected() then
        print("vibrate change listener value: on")
        -- cc.UserDefault:getInstance():setBoolForKey(nk.cookieKeys.SHOCK, true)
        self.isVibrate_ = true
        if self.canSound then
            nk.Native:vibrate(500)
        end
    else
        print("vibrate change listener value: off")
        -- cc.UserDefault:getInstance():setBoolForKey(nk.cookieKeys.SHOCK, false)
        self.isVibrate_ = false
    end

    -- cc.UserDefault:getInstance():flush()
end    

function SettingView:autoSitChangeListener(event)
    if self.canSound then
        nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
    end
    
    -- if self.autoSitSwitch:isOn() then
    if event.target:isButtonSelected() then
        print("autoSit change listener value: on")
        -- cc.UserDefault:getInstance():setBoolForKey(nk.cookieKeys.AUTO_SIT, true)
        self.isAutoSit_ = true
    else
        print("autoSit change listener value: off")
        -- cc.UserDefault:getInstance():setBoolForKey(nk.cookieKeys.AUTO_SIT, false)
        self.isAutoSit_ = false
    end

    -- cc.UserDefault:getInstance():flush()
end

function SettingView:autoBuyinChangeListener(event)
    if self.canSound then
        nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
    end
    
    -- if self.autobuySwitch:isOn() then
    if event.target:isButtonSelected() then
        print("autoBuyin change listener value: on")
        -- cc.UserDefault:getInstance():setBoolForKey(nk.cookieKeys.AUTO_BUY_IN, true)
        self.isAutoBuyin_ = true
    else
        print("autoBuyin change listener value: off")
        -- cc.UserDefault:getInstance():setBoolForKey(nk.cookieKeys.AUTO_BUY_IN, false)
        self.isAutoBuyin_ = false
    end

    -- cc.UserDefault:getInstance():flush()
end

function SettingView:soundValueChangeListener(event)
    --print("sound slider:"..string.format("value = %0.2f", event.value))
    if event.value == 0 then
        self.soundProgressFg:hide()
    else
        self.soundProgressFg:show()
        self.soundProgressFg:size((self.soundWidth_ - 8)/self.soundSliderScale_ * event.value/100, 10)
    end

    self.soundValue = event.value

    self.prevValue_ = self.curValue_
    self.curValue_ = self.soundValue
    local curTime = bm.getTime()
    local prevTime = self.lastRaiseSliderGearTickPlayTime_ or 0
    if self.prevValue_ ~= self.curValue_  and curTime - prevTime > 0.05 then
        self.lastRaiseSliderGearTickPlayTime_ = curTime
        if self.canSound then
            nk.SoundManager:playSound(nk.SoundManager.GEAR_TICK)
        end
    end
end

function SettingView:soundValueUpdate_()
    if self.soundValue then
        cc.UserDefault:getInstance():setIntegerForKey(nk.cookieKeys.VOLUME, self.soundValue)
        cc.UserDefault:getInstance():flush()
        nk.SoundManager:updateVolume()
        nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
    end
end

function SettingView:appStoreOnClick()
    print("app store on click.")
    device.openURL(BM_UPDATE.COMMENT_URL or "")
end

function SettingView:checkVersionOnClick()
    local params = 
    {
        device = (device.platform == "windows" and "android" or device.platform), 
        pay = (device.platform == "windows" and "android" or device.platform), 
        noticeVersion = "noticeVersion",
        osVersion = BM_UPDATE and BM_UPDATE.VERSION or nk.Native:getAppVersion(),
        version = BM_UPDATE and BM_UPDATE.VERSION or nk.Native:getAppVersion(),
        sid = appconfig.ROOT_CGI_SID,
    }
    
    if IS_DEMO then
        params.demo = 1
    end

    nk.http.post_url(appconfig.VERSION_CHECK_URL,params,
        function (data)
            if data then
                local retData = json.decode(data)
                self:checkUpdate(retData.curVersion, retData.verTitle, retData.verMessage, retData.updateUrl)
            end
        end, 
        function ()
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "BAD_NETWORK"))  
        end)

    --[[
    bm.HttpService.POST_URL(appconfig.VERSION_CHECK_URL, 
        {
            device = (device.platform == "windows" and nk.TestUtil.simuDevice or device.platform), 
            pay = (device.platform == "windows" and nk.TestUtil.simuDevice or device.platform), 
            osVersion = BM_UPDATE.VERSION, 
            version = BM_UPDATE.VERSION, 
            noticeVersion = "noticeVersion"
        }, 
        function (data)
            if data then
                local retData = json.decode(data)
                self:checkUpdate(retData.curVersion, retData.verTitle, retData.verMessage, retData.updateUrl)
            end
        end, 
        function ()
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "BAD_NETWORK"))  
        end
    )
--]]
end

function SettingView:checkUpdate(curVersion, verTitle, verMessage, updateUrl)
    local latestVersionNum = bm.getVersionNum(curVersion)
    local installVersionNum = bm.getVersionNum(BM_UPDATE.VERSION)
    print("latestVersionNum:"..latestVersionNum)
    print("installVersionNum:"..installVersionNum)

    if latestVersionNum <= installVersionNum then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("UPDATE", "HAD_UPDATED"))
    else
        UpdatePopup.new(verTitle, verMessage, updateUrl):show()
    end
end

function SettingView:aboutOnClick()
    AboutPopup.new():show()
end

function SettingView:fansOnClick()
    print("setting fans on click")
    device.openURL(bm.LangUtil.getText("ABOUT", "FANS_OPEN"))
end

function SettingView:onShowed()
    self.scrollView_:setScrollContentTouchRect()
    self.canSound = true
end

return SettingView