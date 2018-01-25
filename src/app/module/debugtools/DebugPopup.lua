--
-- Author: Jonah0608@gmail.com
-- Date: 2015-05-11 10:24:48
--
-- 用于debug 选项配置   DEBUG >= 5时 点击登录界面右上角点出现
-- Note:目前主要用于后端服务器选择和语言切换，如果需要其他功能，请重构它

local WIDTH = 720
local HEIGHT = 480
local TOP = HEIGHT*0.5
local BOTTOM = -HEIGHT*0.5
local LEFT = -WIDTH*0.5
local RIGHT = WIDTH*0.5
local TOP_HEIGHT = 64

local PHPServerUrl = import("app.PHPServerUrl")
local DebugPopup = class("DebugPopup", nk.ui.Panel)

DebugPopup.RADIO_BUTTON_IMAGES = {
    off = "#common_blue_btn_up.png",
    off_pressed = "#common_blue_btn_down.png",
    off_disabled = "#common_btn_disabled.png",
    on = "#common_red_btn_up.png",
    on_pressed = "#common_red_btn_down.png",
    on_disabled = "#common_btn_disabled.png",
}


function DebugPopup:ctor()
    DebugPopup.super.ctor(self,{WIDTH,HEIGHT})
    self:setNodeEventEnabled(true)
    self.title_ = display.newTTFLabel({text="调试选项", size=30, color=cc.c3b(0xd7, 0xf6, 0xff), align=ui.TEXT_ALIGN_CENTER})
        :pos(0, TOP - 35)
        :addTo(self)
    self:addLangConfig()
    self:addPhpServerUrlConfig()
    self:addCloseBtn()

    cc.ui.UIPushButton.new({normal= "#common_green_btn_up.png", pressed = "#common_green_btn_down.png"},{scale9 = true})
        :setButtonSize(140, 50)
        :setButtonLabel(display.newTTFLabel({text="重新载入", size=24, color=cc.c3b(0xff, 0xff, 0xff), align=ui.TEXT_ALIGN_CENTER}))
        :onButtonClicked(handler(self, self.onClickReload_))
        :pos(0, BOTTOM + 80)
        :addTo(self)
end

function DebugPopup:addLangConfig()
    cc.ui.UILabel.new({text = "语言选择", size=24, color = cc.c3b(0xd7, 0xf6, 0xff)})
        :align(display.CENTER_TOP,LEFT + 100, TOP - 80)
        :addTo(self)
    local group = cc.ui.UICheckBoxButtonGroup.new(display.TOP_TO_BOTTOM)
        :addButton(cc.ui.UICheckBoxButton.new(DebugPopup.RADIO_BUTTON_IMAGES)
            :setButtonLabel(cc.ui.UILabel.new({text = "中文", color = display.COLOR_WHITE}))
            :setButtonLabelOffset(30, 0)
            :align(display.LEFT_CENTER))
        :addButton(cc.ui.UICheckBoxButton.new(DebugPopup.RADIO_BUTTON_IMAGES)
            :setButtonLabel(cc.ui.UILabel.new({text = "泰语", color = display.COLOR_WHITE}))
            :setButtonLabelOffset(30, 0)
            :align(display.LEFT_CENTER))       
        :setButtonsLayoutMargin(10, 10, 10, 10)
        :onButtonSelectChanged(function(event)
            print("Option %d selected, Option %d unselected", event.selected, event.last)
            self:switchLang_(self:langIndexToStr_(event.selected))
        end)
        :align(display.LEFT_TOP,LEFT + 50, TOP - 250)
        :addTo(self)
    group:getButtonAtIndex(self:langStrToIndex_(appconfig.LANG))
        :setButtonSelected(true)
end

function DebugPopup:addPhpServerUrlConfig()
    cc.ui.UILabel.new({text = "服务器选择", size=24, color = cc.c3b(0xd7, 0xf6, 0xff)})
        :align(display.CENTER_TOP,LEFT + 300, TOP - 80)
        :addTo(self)
    local group = cc.ui.UICheckBoxButtonGroup.new(display.TOP_TO_BOTTOM)
        :setButtonsLayoutMargin(10, 10, 10, 10)
        :onButtonSelectChanged(function(event)
            self:switchPhpServer_(PHPServerUrl[event.selected].url, event.selected)
        end)
        :align(display.LEFT_TOP,LEFT + 250, TOP - 250)
        :addTo(self)
    for i = 1,#PHPServerUrl do
        group:addButton(cc.ui.UICheckBoxButton.new(DebugPopup.RADIO_BUTTON_IMAGES)
            :setButtonLabel(cc.ui.UILabel.new({text = PHPServerUrl[i].name, color = display.COLOR_WHITE}))
            :setButtonLabelOffset(30, 0)
            :align(display.LEFT_CENTER))
    end
    local btn = group:getButtonAtIndex(self:getUrlIndex_(appconfig.VERSION_CHECK_URL))
    if btn then
        btn:setButtonSelected(true)
    end
end

function DebugPopup:switchPhpServer_(url, selected)
    self.firstUrl_ = url
    self.selected_ = selected
end

function DebugPopup:switchLang_(lang)
    self.lang_ = lang
end

function DebugPopup:langIndexToStr_(index)
    if index == 1 then
        return "zh_CN"
    elseif index == 2 then
        return "th_TH"  
    end

end

function DebugPopup:langStrToIndex_(str)
    if str == "zh_CN" then
        return 1
    elseif str == "th_TH" then
        return 2   
    end
end

function DebugPopup:getUrlIndex_(url)
    for i = 1,#PHPServerUrl do
        if PHPServerUrl[i].url == url then
            return i
        end
    end
end

function DebugPopup:onClickReload_()
    package.loaded["config"] = nil
    package.loaded["appconfig"] = nil
    package.loaded["appentry"] = nil
    package.loaded["app.NineKeApp"] = nil
    package.loaded["boyaa.init"] = nil
    package.loaded["boyaa.lang.LangUtil"] = nil
    package.loaded["app.init"] = nil
    package.loaded[appconfig.LANG_FILE_NAME] = nil    
    require("config")
    appconfig = require("appconfig")
    appconfig.VERSION_CHECK_URL = self.firstUrl_
    appconfig.LANG = self.lang_
    IS_DEMO = self.selected_ ~= 4 and self.selected_ ~= 2
    require("update.UpdateController").new()
end

function DebugPopup:show()
    self:showPanel_()
end

function DebugPopup:hide()
    self:hidePanel_()
end

return DebugPopup
