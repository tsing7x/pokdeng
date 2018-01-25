--
-- Author: johnny@boomegg.com
-- Date: 2014-08-23 20:56:37
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

local InviteTabBar = class("InviteTabBar", function ()
    return display.newNode()
end)

InviteTabBar.TAB_BAR_HEIGHT = 52


local whiteColor = cc.c3b(0xff, 0xff, 0xff)
local selectedColor = cc.c3b(0xff, 0xff, 0xff)
local unselectedColor = cc.c3b(0x99, 0xb8, 0xfb)
local buttonLabelOffset = 20

function InviteTabBar:ctor(args)
    self.bgWidth_ = args.popupWidth --* (args.scale or 0.85)
    self.iconTexture_ = args.iconTexture

    local yOffset_ = args.yOffset or -5
    local container = display.newNode():addTo(self):pos(0, yOffset_)

    -- 背景1
    -- display.newScale9Sprite("#popup_tab_bar_bg.png", 0, 0, cc.size(self.bgWidth_, InviteTabBar.TAB_BAR_HEIGHT))
    --     :addTo(container)

    -- 背景2
    display.newScale9Sprite("#recall_unselected_bg.png", 0, 0, cc.size(self.bgWidth_ - 4 * 2, InviteTabBar.TAB_BAR_HEIGHT - 2 * 2))
        :addTo(container)

    -- 重复背景
    --display.newTilesSprite("repeat/popup_tab_bar_repeat_tex.png", cc.rect(0, 0, self.bgWidth_ - 4, InviteTabBar.TAB_BAR_HEIGHT - 4))
    --    :pos(-(self.bgWidth_ - 4) * 0.5, -(InviteTabBar.TAB_BAR_HEIGHT - 4) * 0.5)
    --    :addTo(self)

    -- 选中背景
    self.selectedBg_ = display.newScale9Sprite("#recall_tab_select_left.png")
        :pos(-self.bgWidth_ * 0.25 + 2, 1)
        :size(self.bgWidth_ * 0.5 - 2 * 2, 44)
        :addTo(container)

    self.selectedBgRight_ = display.newScale9Sprite("#recall_tab_select_right.png")
        :pos(self.bgWidth_ * 0.25 + 2, 0)
        :size(self.bgWidth_ * 0.5 - 2 * 2, 44)
        :addTo(container)

    -- 重复背景
    --self.selectedRepeatBg_ = display.newTilesSprite("repeat/popup_tab_bar_selected_repeat_tex.png", cc.rect(0, 0, self.bgWidth_ * 0.5 - 4, InviteTabBar.TAB_BAR_HEIGHT - 4))
    --    :pos(-(self.bgWidth_ * 0.5 - 4), -(InviteTabBar.TAB_BAR_HEIGHT - 4) * 0.5)
    --    :addTo(self)

    -- 字按钮
    selectedColor = args.selectedColor or selectedColor
    self.subBtns_ = {}
    self.btnIcons_ = {}
    self.btnIconsBg_ = {}
    self.btnText_ = args.btnText
    for i = 1, #args.btnText do
        if args.iconTexture then
            self.btnIcons_[i] = display.newSprite(args.iconTexture[i][1]):pos(args.iconOffsetX, 0)
            --self.btnIconsBg_[i] = display.newSprite("#popup_tab_bar_icon_selected.png"):pos(args.iconOffsetX, 0)
        end
        self.subBtns_[i] = cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png"}, {scale9 = true})
            :setButtonSize(self.bgWidth_ / #args.btnText, InviteTabBar.TAB_BAR_HEIGHT)
            :setButtonLabel("normal", display.newTTFLabel({text = self.btnText_[i], color = selectedColor, size = 28, align = ui.TEXT_ALIGN_CENTER}))
            :pos(self.bgWidth_ * -0.5 + (i - 0.5) * (self.bgWidth_ / #args.btnText), 1)
            :addTo(container)
            :onButtonClicked(buttontHandler(self, self.onBtnClick_))
        if args.iconTexture then
            buttonLabelOffset = args.buttonLabelOffset or self.btnIcons_[i]:getContentSize().width
            self.subBtns_[i]:setButtonLabelOffset(buttonLabelOffset, 0)
            :add(self.btnIcons_[i])
            --:add(self.btnIconsBg_[i])
        end
        if args.iconTexture then
            self.btnIcons_[i]:setPositionX(-0.5 * self.subBtns_[i]:getButtonLabel("normal"):getContentSize().width - args.iconOffsetX)
           -- self.btnIconsBg_[i]:setPositionX(-0.5 * self.subBtns_[i]:getButtonLabel("normal"):getContentSize().width - args.iconOffsetX)
        end
        if i > 1 then
            --分割线
            --display.newSprite("#popup_tab_bar_divider.png"):addTo(container):setPositionX(self.bgWidth_ * -0.5 + (i - 1) * (self.bgWidth_ / #args.btnText))
        end
    end

    self.selectedTab_ = 1
    self:gotoTab(self.selectedTab_)
end

function InviteTabBar:onBtnClick_(event)
    local btnId = table.keyof(self.subBtns_, event.target) + 0
    if btnId ~= self.selectedTab_ then
        self:gotoTab(btnId)
    end
end

function InviteTabBar:gotoTab(btnId)
    local padding = 0
    for i, v in ipairs(self.subBtns_) do
        local btn = self.subBtns_[i]
        local icon = self.btnIcons_[i]
        local iconBg = self.btnIconsBg_[i]
        local lb = btn:getButtonLabel()
        if i == btnId then
            lb:setTextColor(selectedColor)
            if icon then
                icon:setSpriteFrame(display.newSpriteFrame(string.gsub(self.iconTexture_[i][1], "#", "")))
            end
            if iconBg then
               -- iconBg:setSpriteFrame(display.newSpriteFrame("popup_tab_bar_icon_selected.png"))
            end
            if i == 1 then
                self.selectedBg_:show()
                self.selectedBgRight_:hide()
            --     self.selectedBg_:setSpriteFrame(display.newSpriteFrame("popup_tab_bar_left_selected_bg.png"))
            --     self.selectedBg_:setContentSize(self.bgWidth_ / #self.subBtns_ - 2 * 2, 56)
            --     self.selectedBg_:pos(self.bgWidth_ * - 0.5 + (btnId - 0.5) * self.bgWidth_ / #self.subBtns_ + 2, 1)
             elseif i == #self.subBtns_ then
                self.selectedBg_:hide()
                self.selectedBgRight_:show()
                -- self.selectedBg_:setSpriteFrame(display.newSpriteFrame("popup_tab_bar_right_selected_bg.png"))
                -- self.selectedBg_:setContentSize(self.bgWidth_ / #self.subBtns_ - 2 * 2, 56)
                 self.selectedBgRight_:pos(self.bgWidth_ * - 0.5 + (btnId - 0.5) * self.bgWidth_ / #self.subBtns_ - 2, 1)
            else
                -- self.selectedBg_:setSpriteFrame(display.newSpriteFrame("popup_tab_bar_middle_selected_bg.png"))
                -- self.selectedBg_:setContentSize(self.bgWidth_ / #self.subBtns_, 56)
                -- self.selectedBg_:pos(self.bgWidth_ * - 0.5 + (btnId - 0.5) * self.bgWidth_ / #self.subBtns_, 1)
            end
        else
            lb:setTextColor(unselectedColor)
            if icon then
                icon:setSpriteFrame(display.newSpriteFrame(string.gsub(self.iconTexture_[i][2], "#", "")))
            end
            if iconBg then
               -- iconBg:setSpriteFrame(display.newSpriteFrame("popup_tab_bar_icon_unselected.png"))
            end
        end
    end
    -- self.selectedRepeatBg_:setPositionX((btnId - 2) * self.bgWidth_ * 0.5 + 4)

    self.selectedTab_ = btnId
    if self.callback_ then
        self.callback_(self.selectedTab_)
    end
end

function InviteTabBar:onTabChange(callback)
    assert(type(callback) == "function", "callback should be a function")
    self.callback_ = callback
    if self.callback_ then
        self.callback_(self.selectedTab_)
    end
    return self
end

return InviteTabBar