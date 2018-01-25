--
-- Author: johnny@boomegg.com
-- Date: 2014-08-23 20:56:37
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

local MatchPopupTabBar = class("MatchPopupTabBar", function ()
    return display.newNode()
end)

MatchPopupTabBar.TAB_BAR_HEIGHT = 41

local whiteColor = cc.c3b(0xff, 0xff, 0xff)
local selectedColor = cc.c3b(0x27, 0x90, 0xd5)
local unselectedColor = cc.c3b(0xca, 0xca, 0xca)

function MatchPopupTabBar:ctor(args)
    self.bgWidth_ = args.popupWidth -20
    self.iconTexture_ = args.iconTexture

    local yOffset_ = args.yOffset or -5
    local container = display.newNode():addTo(self):pos(0, yOffset_)

    self.extraParam_ = args.extraParam

    local bgSizeHeight = nil
    local tabFrontSize = nil

    if self.extraParam_ then
        --todo
        if self.extraParam_.tabBarHeight then
            --todo
            bgSizeHeight = self.extraParam_.tabBarHeight
        end
        
        if self.extraParam_.tabFrontSize then
            --todo
            tabFrontSize = self.extraParam_.tabFrontSize
        end
    end

    -- 背景1
    display.newScale9Sprite("#popup_tab_bar_bg.png", 0, 0, cc.size(self.bgWidth_, bgSizeHeight or MatchPopupTabBar.TAB_BAR_HEIGHT))
        :addTo(container)

    -- 背景2
    display.newScale9Sprite("#popup_tab_bar_unselected_bg.png", 0, 0, cc.size(self.bgWidth_ - 4 * 2, (bgSizeHeight or MatchPopupTabBar.TAB_BAR_HEIGHT) - 2 * 2))
        :addTo(container)

    -- 重复背景
    --display.newTilesSprite("repeat/popup_tab_bar_repeat_tex.png", cc.rect(0, 0, self.bgWidth_ - 4, MatchPopupTabBar.TAB_BAR_HEIGHT - 4))
    --    :pos(-(self.bgWidth_ - 4) * 0.5, -(MatchPopupTabBar.TAB_BAR_HEIGHT - 4) * 0.5)
    --    :addTo(self)

    -- 选中背景
    self.selectedBg_ = display.newScale9Sprite("#popup_tab_bar_left_selected_bg.png")
        :pos(-self.bgWidth_ * 0.25 + 2, 1)
        :size(self.bgWidth_ * 0.5 - 2 * 2, (bgSizeHeight or MatchPopupTabBar.TAB_BAR_HEIGHT) - 4 * 2)
        :addTo(container)

    -- 重复背景
    --self.selectedRepeatBg_ = display.newTilesSprite("repeat/popup_tab_bar_selected_repeat_tex.png", cc.rect(0, 0, self.bgWidth_ * 0.5 - 4, MatchPopupTabBar.TAB_BAR_HEIGHT - 4))
    --    :pos(-(self.bgWidth_ * 0.5 - 4), -(MatchPopupTabBar.TAB_BAR_HEIGHT - 4) * 0.5)
    --    :addTo(self)

    -- 字按钮
    self.subBtns_ = {}
    self.btnIcons_ = {}
    self.btnIconsBg_ = {}
    self.btnText_ = args.btnText
    for i = 1, #args.btnText do
        if args.iconTexture then
            self.btnIcons_[i] = display.newSprite("#common_transparent_skin"):pos(args.iconOffsetX, 0)

            if args.extraParam and args.extraParam.iconCircleTexture then
                --todo
                self.btnIconsBg_[i] = display.newSprite(args.extraParam.iconCircleTexture[1]):pos(args.iconOffsetX, 0)
            else
                self.btnIconsBg_[i] = display.newSprite("#popup_tab_bar_icon_selected.png"):pos(args.iconOffsetX, 0)
            end
        end
        self.subBtns_[i] = cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png"}, {scale9 = true})
            :setButtonSize(self.bgWidth_ / #args.btnText, bgSizeHeight or MatchPopupTabBar.TAB_BAR_HEIGHT)
            :setButtonLabel("normal", display.newTTFLabel({text = self.btnText_[i], color = selectedColor, size = tabFrontSize or 28, align = ui.TEXT_ALIGN_CENTER}))
            :pos(self.bgWidth_ * -0.5 + (i - 0.5) * (self.bgWidth_ / #args.btnText), 1)
            :addTo(container)
            :onButtonClicked(buttontHandler(self, self.onBtnClick_))
        if args.iconTexture then
            self.subBtns_[i]:setButtonLabelOffset(self.btnIcons_[i]:getContentSize().width, 0)
            :add(self.btnIcons_[i])
            :add(self.btnIconsBg_[i])
        end
        if args.iconTexture then
            self.btnIcons_[i]:setPositionX(-0.5 * self.subBtns_[i]:getButtonLabel("normal"):getContentSize().width - args.iconOffsetX)
            self.btnIconsBg_[i]:setPositionX(-0.5 * self.subBtns_[i]:getButtonLabel("normal"):getContentSize().width - args.iconOffsetX)
        end

        if i > 1 then
            --分割线
            local dividerLine = display.newSprite("#popup_tab_bar_divider.png")
                :addTo(container)
            dividerLine:setPositionX(self.bgWidth_ * -0.5 + (i - 1) * (self.bgWidth_ / #args.btnText))

            dividerLine:setScaleY((bgSizeHeight or MatchPopupTabBar.TAB_BAR_HEIGHT) / MatchPopupTabBar.TAB_BAR_HEIGHT)
            dividerLine:scale(0.7)
        end
    end

    self.selectedTab_ = 1
    self:gotoTab(self.selectedTab_)
end

function MatchPopupTabBar:onBtnClick_(event)
    local btnId = table.keyof(self.subBtns_, event.target) + 0
    if btnId ~= self.selectedTab_ then
        self:gotoTab(btnId)
    end
end

function MatchPopupTabBar:gotoTab(btnId)
    local padding = 0
    for i, v in ipairs(self.subBtns_) do
        local btn = self.subBtns_[i]
        local icon = self.btnIcons_[i]
        local iconBg = self.btnIconsBg_[i]
        local lb = btn:getButtonLabel()
        if i == btnId then

            if self.extraParam_ and self.extraParam_.tabFrontColor then
                --todo
                lb:setTextColor(self.extraParam_.tabFrontColor[1])
            else
                lb:setTextColor(selectedColor)
            end
            
            if icon then
                icon:setSpriteFrame(display.newSpriteFrame(string.gsub(self.iconTexture_[i][1], "#", "")))
            end
            if iconBg then

                if self.extraParam_ and self.extraParam_.iconCircleTexture then
                    --todo
                    iconBg:setSpriteFrame(display.newSpriteFrame(string.gsub(self.extraParam_.iconCircleTexture[1], "#", "")))
                else
                    iconBg:setSpriteFrame(display.newSpriteFrame("popup_tab_bar_icon_selected.png"))
                end
                
            end

            local btnSizeHeight = nil

            if self.extraParam_ and self.extraParam_.tabBarHeight then
                --todo
                btnSizeHeight = self.extraParam_.tabBarHeight
            end

            if i == 1 then
                self.selectedBg_:setSpriteFrame(display.newSpriteFrame("popup_tab_bar_left_selected_bg.png"))
                self.selectedBg_:setContentSize(self.bgWidth_ / #self.subBtns_ - 2 * 2, (btnSizeHeight or MatchPopupTabBar.TAB_BAR_HEIGHT) - 4 * 2)
                self.selectedBg_:pos(self.bgWidth_ * - 0.5 + (btnId - 0.5) * self.bgWidth_ / #self.subBtns_ + 2, 1)
            elseif i == #self.subBtns_ then
                self.selectedBg_:setSpriteFrame(display.newSpriteFrame("popup_tab_bar_right_selected_bg.png"))
                self.selectedBg_:setContentSize(self.bgWidth_ / #self.subBtns_ - 2 * 2, (btnSizeHeight or MatchPopupTabBar.TAB_BAR_HEIGHT) - 4 * 2)
                self.selectedBg_:pos(self.bgWidth_ * - 0.5 + (btnId - 0.5) * self.bgWidth_ / #self.subBtns_ - 2, 1)
            else
                self.selectedBg_:setSpriteFrame(display.newSpriteFrame("popup_tab_bar_middle_selected_bg.png"))
                self.selectedBg_:setContentSize(self.bgWidth_ / #self.subBtns_, (btnSizeHeight or MatchPopupTabBar.TAB_BAR_HEIGHT) - 4 * 2)
                self.selectedBg_:pos(self.bgWidth_ * - 0.5 + (btnId - 0.5) * self.bgWidth_ / #self.subBtns_, 1)
            end
        else
            -- 预留，待后续使用
            -- if self.extraParam_ and self.extraParam_.tabFrontColor then
            --     lb:setTextColor(self.extraParam_.tabFrontColor[2])
            -- else
            --     lb:setTextColor(unselectedColor)
            -- end
                lb:setTextColor(unselectedColor)
            
            if icon then
                icon:setSpriteFrame(display.newSpriteFrame(string.gsub(self.iconTexture_[i][2], "#", "")))
            end
            if iconBg then

                -- 暂且保留，不做处理。
                -- if self.extraParam_ and self.extraParam_.iconCircleTexture and string.len(self.extraParam_.iconCircleTexture[2]) > 0 then
                --     --todo
                --     iconBg:setSpriteFrame(display.newSpriteFrame(string.gsub(self.extraParam_.iconCircleTexture[2], "#", "")))
                    
                -- else
                --     iconBg:setSpriteFrame(display.newSpriteFrame("popup_tab_bar_icon_unselected.png"))
                -- end

                iconBg:setSpriteFrame(display.newSpriteFrame("popup_tab_bar_icon_unselected.png"))
            end
        end
    end
    -- self.selectedRepeatBg_:setPositionX((btnId - 2) * self.bgWidth_ * 0.5 + 4)

    self.selectedTab_ = btnId
    if self.callback_ then
        self.callback_(self.selectedTab_)
    end
end

function MatchPopupTabBar:onTabChange(callback)
    assert(type(callback) == "function", "callback should be a function")
    self.callback_ = callback
    if self.callback_ then
        self.callback_(self.selectedTab_)
    end
    return self
end

return MatchPopupTabBar