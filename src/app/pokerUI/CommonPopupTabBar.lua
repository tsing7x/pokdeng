--
-- Author: johnny@boomegg.com
-- Date: 2014-08-23 20:56:37
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

local CommonPopupTabBar = class("CommonPopupTabBar", function ()
    return display.newNode()
end)

CommonPopupTabBar.TAB_BAR_HEIGHT = 64

local whiteColor = cc.c3b(0xff, 0xff, 0xff)
local selectedColor = cc.c3b(0x27, 0x90, 0xd5)
local unselectedColor = cc.c3b(0xca, 0xca, 0xca)

function CommonPopupTabBar:ctor(args)
    self.bgWidth_ = args.popupWidth * (args.scale or 0.85)
    self.iconTexture_ = args.iconTexture

    local yOffset_ = args.yOffset or -5
    local container = display.newNode():addTo(self):pos(0, yOffset_)

    -- 背景1
    self.tabBarBg_ = display.newScale9Sprite("#popup_tab_bar_bg.png", 0, 0, cc.size(self.bgWidth_, CommonPopupTabBar.TAB_BAR_HEIGHT))
        :addTo(container)

    -- 背景2
    self.tabBarBgUnsel_ = display.newScale9Sprite("#popup_tab_bar_unselected_bg.png", 0, 0, cc.size(self.bgWidth_ - 4 * 2, CommonPopupTabBar.TAB_BAR_HEIGHT - 2 * 2))
        :addTo(container)

    -- 重复背景
    --display.newTilesSprite("repeat/popup_tab_bar_repeat_tex.png", cc.rect(0, 0, self.bgWidth_ - 4, CommonPopupTabBar.TAB_BAR_HEIGHT - 4))
    --    :pos(-(self.bgWidth_ - 4) * 0.5, -(CommonPopupTabBar.TAB_BAR_HEIGHT - 4) * 0.5)
    --    :addTo(self)

    -- 选中背景
    self.selectedBg_ = display.newScale9Sprite("#popup_tab_bar_left_selected_bg.png")
        :pos(-self.bgWidth_ * 0.25 + 2, 1)
        :size(self.bgWidth_ * 0.5 - 2 * 2, CommonPopupTabBar.TAB_BAR_HEIGHT - 4 * 2)
        :addTo(container)

    -- 重复背景
    --self.selectedRepeatBg_ = display.newTilesSprite("repeat/popup_tab_bar_selected_repeat_tex.png", cc.rect(0, 0, self.bgWidth_ * 0.5 - 4,
        -- CommonPopupTabBar.TAB_BAR_HEIGHT - 4))
    --    :pos(-(self.bgWidth_ * 0.5 - 4), -(CommonPopupTabBar.TAB_BAR_HEIGHT - 4) * 0.5)
    --    :addTo(self)

    -- 字按钮
    self.subBtns_ = {}
    self.btnIcons_ = {}
    self.btnIconsBg_ = {}
    self.divLines_ = {}
    self.btnText_ = args.btnText
    for i = 1, #args.btnText do
        if args.iconTexture then
            self.btnIcons_[i] = display.newSprite(args.iconTexture[i][1]):pos(args.iconOffsetX, 0)
            self.btnIconsBg_[i] = display.newSprite("#popup_tab_bar_icon_selected.png"):pos(args.iconOffsetX, 0)
        end
        self.subBtns_[i] = cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png"}, {scale9 = true})
            :setButtonSize(self.bgWidth_ / #args.btnText, CommonPopupTabBar.TAB_BAR_HEIGHT)
            :setButtonLabel("normal", display.newTTFLabel({text = self.btnText_[i], color = selectedColor, size = 28, align = ui.TEXT_ALIGN_CENTER}))
            :pos(self.bgWidth_ * -0.5 + (i - 0.5) * (self.bgWidth_ / #args.btnText), 1)
            :addTo(container)
            :onButtonClicked(buttontHandler(self, self.onBtnClick_))

        if args.iconTexture then
            self.subBtns_[i]:setButtonLabelOffset(self.btnIcons_[i]:getContentSize().width, 0)
                :add(self.btnIcons_[i])

            self.subBtns_[i]:add(self.btnIconsBg_[i])
            self.btnIconsBg_[i]:setPositionX(-0.5 * self.subBtns_[i]:getButtonLabel("normal"):getContentSize().width - args.iconOffsetX)

            self.btnIcons_[i]:setPositionX(-0.5 * self.subBtns_[i]:getButtonLabel("normal"):getContentSize().width - args.iconOffsetX)
        end

        if i > 1 then
            --分割线
            self.divLines_[i - 1] = display.newSprite("#popup_tab_bar_divider.png")
                :addTo(container)
            self.divLines_[i - 1]:setPositionX(self.bgWidth_ * -0.5 + (i - 1) * (self.bgWidth_ / #args.btnText))
        end
    end

    self.selectedTab_ = 1
    self:gotoTab(self.selectedTab_)
end

function CommonPopupTabBar:onBtnClick_(event)
    local btnId = table.keyof(self.subBtns_, event.target) + 0
    if btnId ~= self.selectedTab_ then
        self:gotoTab(btnId)
    end
end

function CommonPopupTabBar:gotoTab(btnId)
    -- local padding = 0
    for i, v in ipairs(self.subBtns_) do
        local btn = self.subBtns_[i]
        local icon = self.btnIcons_[i]
        local iconBg = self.btnIconsBg_[i]
        local lb = btn:getButtonLabel()
        if i == btnId then

            if self.tabFrontColor_ then
                --todo
                lb:setTextColor(self.tabFrontColor_[1])
            else
                lb:setTextColor(selectedColor)
            end
            
            if icon then
                icon:setSpriteFrame(display.newSpriteFrame(string.gsub(self.iconTexture_[i][1], "#", "")))
            end

            if iconBg then

                if self.iconCircleTexture_ then
                    --todo
                    iconBg:setSpriteFrame(display.newSpriteFrame(self.iconCircleTexture_[1]))
                else
                    iconBg:setSpriteFrame(display.newSpriteFrame("popup_tab_bar_icon_selected.png"))
                end
                
            end

            if i == 1 then
                self.selectedBg_:setSpriteFrame(display.newSpriteFrame("popup_tab_bar_left_selected_bg.png"))
                self.selectedBg_:setContentSize(self.bgWidth_ / #self.subBtns_ - 2 * 2, (self.tabBarHeight_ or CommonPopupTabBar.TAB_BAR_HEIGHT) - 4 * 2)
                self.selectedBg_:pos(self.bgWidth_ * - 0.5 + (btnId - 0.5) * self.bgWidth_ / #self.subBtns_ + 2, 1)
            elseif i == #self.subBtns_ then
                self.selectedBg_:setSpriteFrame(display.newSpriteFrame("popup_tab_bar_right_selected_bg.png"))
                self.selectedBg_:setContentSize(self.bgWidth_ / #self.subBtns_ - 2 * 2, (self.tabBarHeight_ or CommonPopupTabBar.TAB_BAR_HEIGHT) - 4 * 2)
                self.selectedBg_:pos(self.bgWidth_ * - 0.5 + (btnId - 0.5) * self.bgWidth_ / #self.subBtns_ - 2, 1)
            else
                self.selectedBg_:setSpriteFrame(display.newSpriteFrame("popup_tab_bar_middle_selected_bg.png"))
                self.selectedBg_:setContentSize(self.bgWidth_ / #self.subBtns_, (self.tabBarHeight_ or CommonPopupTabBar.TAB_BAR_HEIGHT) - 4 * 2)
                self.selectedBg_:pos(self.bgWidth_ * - 0.5 + (btnId - 0.5) * self.bgWidth_ / #self.subBtns_, 1)
            end
        else
            if self.tabFrontColor_ then
                --todo
                lb:setTextColor(self.tabFrontColor_[2])
            else
                lb:setTextColor(unselectedColor)
            end
            
            if icon then
                icon:setSpriteFrame(display.newSpriteFrame(string.gsub(self.iconTexture_[i][2], "#", "")))
            end
            if iconBg then

                if self.iconCircleTexture_ then
                    --todo
                    iconBg:setSpriteFrame(display.newSpriteFrame(self.iconCircleTexture_[2]))
                else
                    iconBg:setSpriteFrame(display.newSpriteFrame("popup_tab_bar_icon_unselected.png"))
                end
            end
        end
    end
    -- self.selectedRepeatBg_:setPositionX((btnId - 2) * self.bgWidth_ * 0.5 + 4)

    self.selectedTab_ = btnId
    if self.callback_ then
        self.callback_(self.selectedTab_)
    end
end

function CommonPopupTabBar:onTabChange(callback)
    assert(type(callback) == "function", "callback should be a function")
    self.callback_ = callback
    if self.callback_ then
        self.callback_(self.selectedTab_)
    end
    return self
end

-- Exposed Interface --
--[[ @param args.[table] 
    args.tabBarHeight:number, 控件高度;
    args.tabFrontSize:number, 控件字体大小;
    args.noIconCircle:bool, 是否带背景圈;
    args.buttonLabelOffSet:table, buttonLabel的相对偏移修正量,
        {x = **, y = **} @x: x方向上的buttonLabel偏移修正量, @y: y方向上的buttonLabel偏移修正量;
    args.iconCircleTexture:table, 背景圈图地址,
        {"******.png", "******.png"} @table[1]: 背景圈图地址[被选中], @table[2]: 背景圈图地址[普通状态];
    args.tabFrontColor:table, buttonLabel字体颜色,
        {cc.c3b(**, **, **), cc.c3b(**, **, **)} @table[1]: 字体颜色[被选中], @table[2]: 字体颜色[普通];
    etc, 待补充完善.
]]
function CommonPopupTabBar:setTabBarExtraParam(args)
    -- body
    -- self.bgWidth_ = args.bgWidth
    self.tabBarHeight_ = args.tabBarHeight or CommonPopupTabBar.TAB_BAR_HEIGHT
    local tabFrontSize = args.tabFrontSize
    local isNoIconCircle = args.noIconCircle  -- args.noIconCircle == true 时,设置 args.iconCircleTexture 将无效
    local buttonLabelOffset = args.buttonLabelOffset

    self.iconCircleTexture_ = args.iconCircleTexture or {"popup_tab_bar_icon_selected.png", "popup_tab_bar_icon_unselected.png"}
    self.tabFrontColor_ = args.tabFrontColor or {selectedColor, unselectedColor}

    if args.tabBarHeight then
        --todo
        self.tabBarBg_:size(self.bgWidth_, args.tabBarHeight)
        self.tabBarBgUnsel_:size(self.bgWidth_ - 4 * 2, args.tabBarHeight - 2 * 2)
        self.selectedBg_:setContentSize(self.bgWidth_ / #self.subBtns_ - 2 * 2, args.tabBarHeight - 4 * 2)  -- 默认1选中调节
        
        for i = 1, #self.subBtns_ do
            self.subBtns_[i]:setButtonSize(self.bgWidth_ / #self.btnText_, args.tabBarHeight)
        end

        for i = 1, #self.divLines_ do
            self.divLines_[i]:setScaleY(args.tabBarHeight / CommonPopupTabBar.TAB_BAR_HEIGHT)
        end
    end

    if tabFrontSize then
        --todo
        for i = 1, #self.subBtns_ do
            local btnLabel = self.subBtns_[i]:getButtonLabel()
            btnLabel:setSystemFontSize(tabFrontSize)
        end
    end

    if buttonLabelOffset then
        --todo
        for i = 1, #self.subBtns_ do
            self.subBtns_[i]:setButtonLabelOffset(self.btnIcons_[i]:getContentSize().width + buttonLabelOffset.x, buttonLabelOffset.y)
        end
    end

    if isNoIconCircle then
        --todo
        for i = 1, #self.btnIconsBg_ do
            self.btnIconsBg_[i]:removeFromParent()
            self.btnIconsBg_[i] = nil
        end
    end

    if args.iconCircleTexture then
        --todo
        for i = 1, #self.btnIconsBg_ do
            self.btnIconsBg_[i]:setSpriteFrame(display.newSpriteFrame(args.iconCircleTexture[1]))
        end
    end

    if args.tabFrontColor then
        --todo
        for i = 1, #self.subBtns_ do
            local btnLbl = self.subBtns_[i]:getButtonLabel()
            btnLbl:setTextColor(args.tabFrontColor[1])
        end
    end

    return self
end

return CommonPopupTabBar