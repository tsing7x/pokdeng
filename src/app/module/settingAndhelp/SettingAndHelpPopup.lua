--
-- Author: viking@boomegg.com
-- Date: 2014-08-21 17:35:59
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

local Panel = import("app.pokerUI.Panel")
local SettingAndHelpPopup = class("SettingAndHelpPopup", Panel)

local SettingView = import(".setting.SettingView")
local HelpView = import(".help.HelpView")

SettingAndHelpPopup.TAB_SETTING = 1
SettingAndHelpPopup.TAB_HELP    = 2

SettingAndHelpPopup.CLOSEBTN_PADDING = 10
SettingAndHelpPopup.TAB_HEIGHT = nk.ui.CommonPopupTabBar.TAB_BAR_HEIGHT
SettingAndHelpPopup.PADDING = 11

function SettingAndHelpPopup:ctor(isInRoom, isHelp, helpSubTab)
    SettingAndHelpPopup.super.ctor(self, SettingAndHelpPopup.SIZE_NORMAL)

    self.isInRoom = isInRoom
    --TODO TEST
    -- isHelp = true
    -- helpSubTab = 1

    if isHelp then
        self.CURRENT_TAB = SettingAndHelpPopup.TAB_HELP
        if helpSubTab then
            self.helpSubTab_ = helpSubTab
        end
    else
        self.CURRENT_TAB = SettingAndHelpPopup.TAB_SETTING
    end

    self:setupView()
end

function SettingAndHelpPopup:setupView()
    local size = self.background_:getContentSize()

    local touchCover = display.newScale9Sprite("#transparent.png", 0, self.height_ * 0.5 - 38, cc.size(self.width_, 76)):addTo(self, 9)
    touchCover:setTouchEnabled(true)
    touchCover:setTouchSwallowEnabled(true)

    --TAB title
    self.tabLayout = nk.ui.CommonPopupTabBar.new(
        {
            popupWidth = self.width_, 
            iconOffsetX = 10, 
            iconTexture = {
                {"#setting_icon_selected.png", "#setting_icon_unselected.png"}, 
                {"#help_icon_selected.png", "#help_icon_unselected.png"}
            }, 
            btnText = {bm.LangUtil.getText("SETTING", "TITLE"), bm.LangUtil.getText("HELP", "TITLE")}
        }
    )
        :pos(0, self.height_ * 0.5 - nk.ui.CommonPopupTabBar.TAB_BAR_HEIGHT * 0.5)
        :addTo(self, 10) 

    if self.CURRENT_TAB == SettingAndHelpPopup.TAB_HELP then
        -- self.settingContent = SettingView.new(self):addTo(self):hide()
        self.helpContent = HelpView.new(self, self.helpSubTab_):addTo(self):show()
    else
        self.settingContent = SettingView.new(self):addTo(self):show()
        -- self.helpContent = HelpView.new(self, self.helpSubTab_):addTo(self):hide()
    end

    self:addCloseBtn()

    self.tabLayout:gotoTab(self.CURRENT_TAB)
end

function SettingAndHelpPopup:show()
    self:showPanel_(true, true, true)
    return self
end

function SettingAndHelpPopup:notifyContent(currentTab)
    self.CURRENT_TAB = currentTab
    if self.CURRENT_TAB == SettingAndHelpPopup.TAB_HELP then
        if self.settingContent then self.settingContent:hide() end
        if not self.helpContent then
        self.helpContent = HelpView.new(self, self.helpSubTab_):addTo(self)
        self.helpContent:onShowed()
        end
        self.helpContent:show()
        print("show help")
    else
        if self.helpContent then self.helpContent:hide() end
        if not self.settingContent then
        self.settingContent = SettingView.new(self):addTo(self)
        self.settingContent:onShowed()
        end
        self.settingContent:show()
        print("show setting")
    end
end

function SettingAndHelpPopup:onShowed()
    self.tabLayout:onTabChange(handler(self, self.notifyContent))
    if self.settingContent then self.settingContent:onShowed() end
    if self.helpContent then self.helpContent:onShowed() end
    print("showed SettingAndHelpPopup")
end

return SettingAndHelpPopup