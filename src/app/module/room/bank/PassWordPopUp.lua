--
-- Author: Tom
-- Date: 2014-11-07 16:06:44
--
local WIDTH = 640 
local HEIGHT = 380 
local TOP_HEIGHT = 68
local PassWordPopUp = class("PassWordPopUp", nk.ui.Panel)
local SettingAndHelpPopup = import("app.module.settingAndhelp.SettingAndHelpPopup")
local PADDING = 32

function PassWordPopUp:ctor()
    PassWordPopUp.super.ctor(self,{WIDTH,HEIGHT})
    self:addCloseBtn()

    local TOP = self.height_*0.5
    local BOTTOM = -self.height_*0.5
    local LEFT = -self.width_*0.5
    local RIGHT = self.width_*0.5
    local TOP_HEIGHT = 64

    -- overlay
    display.newScale9Sprite("#panel_overlay.png", 0, 0, cc.size(self.width_ - PADDING * 0.5, self.height_ - PADDING * 0.25 - TOP_HEIGHT))
        :pos(0, -30)
        :addTo(self)
    
    -- 添加标签
    display.newTTFLabel({text = bm.LangUtil.getText("BANK","BANK_POPUP_TOP_TITIE"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 30, align = ui.TEXT_ALIGN_CENTER})
        :pos(0, self.height_ * 0.5 - TOP_HEIGHT * 0.5)
        :addTo(self)


    self.editInputPassword_ = cc.ui.UIInput.new({
        size = cc.size(WIDTH - 160, 52),
        align=ui.TEXT_ALIGN_CENTER - 30,
        image="#common_input_bg.png",
        imagePressed="#common_input_bg_down.png",
        x = 0,
        y = 65,
        listener = handler(self, self.onInputPassWordCodeEdit_)
    })
    self.editInputPassword_:setFontName(ui.DEFAULT_TTF_FONT)
    self.editInputPassword_:setFontSize(24)
    self.editInputPassword_:setFontColor(cc.c3b(0x92, 0x8d, 0x8d))
    self.editInputPassword_:setPlaceholderFontName(ui.DEFAULT_TTF_FONT)
    self.editInputPassword_:setPlaceholderFontSize(24)
    self.editInputPassword_:setPlaceholderFontColor(cc.c3b(0x92, 0x8d, 0x8d))
    self.editInputPassword_:setPlaceHolder(bm.LangUtil.getText("BANK","BANK_INPUT_TEXT_DEFAULT_LABEL"))
    self.editInputPassword_:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self.editInputPassword_:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
    self.editInputPassword_:addTo(self)

    -- 密码正确的时候图标
    self.correctPassWordIcon = display.newSprite("#common-password-correct-icon.png")
        :pos(self.editInputPassword_:getPositionX()+ self.editInputPassword_:getContentSize().width * 0.5 + 30, 65)
        :addTo(self)
        :hide()

    -- 密码错误的时候图标
    self.errorPassWordIcon = display.newSprite("#common-password-error-icon.png")
        :pos(self.editInputPassword_:getPositionX()+ self.editInputPassword_:getContentSize().width * 0.5 + 30, 65)
        :addTo(self)
        :hide()


    -- 忘记密码
    self.forgetButton_ = cc.ui.UIPushButton.new({normal = "#common_dark_blue_btn_up.png", pressed = "#common_dark_blue_btn_down.png"}, {scale9 = true})
        :setButtonSize(200, 62)
        :setButtonLabel(display.newTTFLabel({text=bm.LangUtil.getText("BANK", "BANK_FORGET_PASSWORD_BUTTON_LABEL"), size=24, color=cc.c3b(0xb2, 0xdc, 0xff), align=ui.TEXT_ALIGN_CENTER}))
        :onButtonClicked(handler(self, self.forgetPassWordClick_))
        :pos(LEFT + 160, BOTTOM + 63)
        :addTo(self)


    -- 确认输入密码
    self.confirmButton_ = cc.ui.UIPushButton.new({normal = "#common_green_btn_up.png", pressed = "#common_green_btn_down.png"}, {scale9 = true})
        :setButtonSize(200, 62)
        :setButtonLabel(display.newTTFLabel({text=bm.LangUtil.getText("COMMON", "CONFIRM"), size=24, color=cc.c3b(0xb2, 0xdc, 0xff), align=ui.TEXT_ALIGN_CENTER}))
        :onButtonClicked(handler(self, self.confirmPassWordClick_))
        :pos(RIGHT - 160, BOTTOM + 63)
        :addTo(self)

    --忘记密码提示
    self.forgetPrompt = display.newTTFLabel({text = bm.LangUtil.getText("BANK","BANK_FORGET_PASSWORD_FEEDBACK"), color = cc.c3b(0xC7, 0xE5, 0xFF), size = 24,dimensions = cc.size(WIDTH - 190, 200), align = ui.TEXT_ALIGN_LEFT})
        :pos(0, BOTTOM + 163)
        :addTo(self)

end


function PassWordPopUp:onInputPassWordCodeEdit_(event)
    if event == "began" then
        -- 开始输入
    elseif event == "changed" then
        -- 输入框内容发生变化是
        self.inputCodeEdit_ = self.editInputPassword_:getText()
        print("uuuuuuuuuuuuuuuuuuuuuuu",self.inputCodeEdit_)
    elseif event == "ended" then
        
    elseif event == "return" then
        -- 从输入框返回
    end
end

function PassWordPopUp:confirmPassWordClick_()
    if self.inputCodeEdit_ == nil then
        return 
    end
    --self.confirmPasswordRequestId_ = bm.HttpService.POST({mod="bank", act="bankCheckpsw", token = crypto.md5(nk.userData.uid..nk.userData.mtkey..os.time().."*&%$#@123++web-ipoker)(abc#@!<>;:to"), time =os.time(), password = crypto.md5(crypto.md5(string.trim(self.inputCodeEdit_)))},
      self.confirmPasswordRequestId_ = nk.http.bankOpenLock(string.trim(self.inputCodeEdit_),    
        function(data) 
            self.confirmPasswordRequestId_ = nil
            local callData = data
            bm.EventCenter:dispatchEvent({name = nk.eventNames.OPEN_BANK_POPUP_VIEW})
            self.correctPassWordIcon:show()
            self:hide()
        end, function(errorData)
            self.confirmPasswordRequestId_ = nil
            if errorData then
                if checkint(errorData.errorCode) == -1 then
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("BANK", "BANK_INPUT_PASSWORD_ERROR"))
                    self.errorPassWordIcon:show()
                else
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "BAD_NETWORK")..errorData.errorCode)
                end
            else
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
            end
        end)
end

function PassWordPopUp:forgetPassWordClick_()
    SettingAndHelpPopup.new(false ,true ,1):show()
end

function PassWordPopUp:show()
    self:showPanel_()
end

function PassWordPopUp:hide()
    self:hidePanel_()
end


return PassWordPopUp