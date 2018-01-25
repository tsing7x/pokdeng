--
-- Author: Tom
-- Date: 2014-11-06 16:04:59
--
local WIDTH = 640 
local HEIGHT = 380 
local TOP_HEIGHT = 68
local ModifyBankPassWordPopup = class("ModifyBankPassWordPopup", nk.ui.Panel)
local PADDING = 32

function ModifyBankPassWordPopup:ctor()
    ModifyBankPassWordPopup.super.ctor(self,{WIDTH,HEIGHT})

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
    display.newTTFLabel({text = bm.LangUtil.getText("BANK","BANK_SET_PASSWORD_TOP_TITLE"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 30, align = ui.TEXT_ALIGN_CENTER})
        :pos(0, self.height_ * 0.5 - TOP_HEIGHT * 0.5)
        :addTo(self)

    self:addCloseBtn()

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
    self.editInputPassword_:setPlaceHolder(bm.LangUtil.getText("BANK", "BANK_INPUT_TEXT_DEFAULT_LABEL"))
    self.editInputPassword_:setReturnType( cc.KEYBOARD_RETURNTYPE_GO)
    self.editInputPassword_:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
    self.editInputPassword_:addTo(self)



    self.editConfirmInputPassword_ = cc.ui.UIInput.new({
        size = cc.size(WIDTH - 160, 62),
        align=ui.TEXT_ALIGN_CENTER - 30,
        image="#common_input_bg.png",
        imagePressed="#common_input_bg_down.png",
        x = 0,
        y = -20,
        listener = handler(self, self.onConfirmInputPassWordCodeEdit_)
    })
    self.editConfirmInputPassword_:setFontName(ui.DEFAULT_TTF_FONT)
    self.editConfirmInputPassword_:setFontSize(24)
    self.editConfirmInputPassword_:setFontColor(cc.c3b(0x92, 0x8d, 0x8d))
    self.editConfirmInputPassword_:setPlaceholderFontName(ui.DEFAULT_TTF_FONT)
    self.editConfirmInputPassword_:setPlaceholderFontSize(24)
    self.editConfirmInputPassword_:setPlaceholderFontColor(cc.c3b(0x92, 0x8d, 0x8d))
    self.editConfirmInputPassword_:setPlaceHolder(bm.LangUtil.getText("BANK","BANK_CONFIRM_INPUT_TEXT_DEFAULT_LABEL"))
    self.editConfirmInputPassword_:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self.editConfirmInputPassword_:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
    self.editConfirmInputPassword_:addTo(self)

    -- 确认输入密码
    self.confirmButton_ = cc.ui.UIPushButton.new({normal = "#common_green_btn_up.png", pressed = "#common_green_btn_down.png"}, {scale9 = true})
        :setButtonSize(200, 62)
        :setButtonLabel(display.newTTFLabel({text=bm.LangUtil.getText("COMMON", "CONFIRM"), size=24, color=cc.c3b(0xb2, 0xdc, 0xff), align=ui.TEXT_ALIGN_CENTER}))
        :onButtonClicked(handler(self, self.confirmPassWordClick_))
        :pos(0, BOTTOM + 63)
        :addTo(self)
end

function ModifyBankPassWordPopup:onInputPassWordCodeEdit_(event)
    if event == "began" then
        -- 开始输入
    elseif event == "changed" then
        -- 输入框内容发生变化是
        self.inputCodeEdit_ = self.editInputPassword_:getText()
        print(self.codeEdit_)
    elseif event == "ended" then
        
    elseif event == "return" then
        -- 从输入框返回
    end
end

function ModifyBankPassWordPopup:onConfirmInputPassWordCodeEdit_(event)
    if event == "began" then
        -- 开始输入
    elseif event == "changed" then
        -- 输入框内容发生变化是
        self.confirmCodeEdit_ = self.editConfirmInputPassword_:getText()
        -- print("55555555555555555555555555555",self.confirmCodeEdit_)
    elseif event == "ended" then
         
    elseif event == "return" then
        -- 从输入框返回
    end
    
end

function ModifyBankPassWordPopup:confirmPassWordClick_()
    if (self.confirmCodeEdit_ == nil or self.inputCodeEdit_ == nil) then
        return 
    end
    local userLevelFact = nk.Level:getLevelByExp(nk.userData["aUser.exp"])

    if userLevelFact >= 5 then
        --self.confirmRequestId_ = bm.HttpService.POST({mod="bank", act="setPwd", token = crypto.md5(nk.userData.uid..nk.userData.mtkey..os.time().."*&%$#@123++web-ipoker)(abc#@!<>;:to"), time =os.time(), password1 = crypto.md5(crypto.md5(string.trim(self.inputCodeEdit_))) , password2 = crypto.md5(crypto.md5(string.trim(self.confirmCodeEdit_)))},
        self.confirmRequestId_ = nk.http.bankSetPassword(string.trim(self.inputCodeEdit_),string.trim(self.confirmCodeEdit_),
        function(data) 
            self.confirmRequestId_ = nil
            local callData = data
            self:hide()
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("BANK", "BANK_SET_PASSWORD_SUCCESS_TOP_TIP"))
            nk.userData["aUser.bankLock"] = 1 
            bm.EventCenter:dispatchEvent({name = nk.eventNames.SHOW_EXIST_PASSWORD_ICON})
        end, function(errorData)
            -- dump(errorData, "nk.http.bankSetPassword.errData :=======================")
            self.confirmRequestId_ = nil
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("BANK", "BANK_SET_PASSWORD_FAIL_TOP_TIP"))
        end)
    else
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("BANK", "BANK_LEVELS_DID_NOT_REACH"))
    end
end

function ModifyBankPassWordPopup:show(callback)
    self.onCloseCallBack_ = callback
    self:showPanel_()
end

function ModifyBankPassWordPopup:hide()
    self:hidePanel_()
end

function ModifyBankPassWordPopup:onRemovePopup(removeFuc)
    -- body
    if self.onCloseCallBack_ then
        --todo
        self.onCloseCallBack_()
    end

    removeFuc()
end

return ModifyBankPassWordPopup