-- Author: thinkeras3@163.com
-- Date: 2015-08-11 17:31:50
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- 游客登录FB帐号框
local Panel = import("app.pokerUI.Panel")
local LoginFbDialog = class("LoginFbDialog", Panel)
local DEFAULT_WIDTH = 580
local DEFAULT_HEIGHT = 400
local TOP_HEIGHT = 68
local PADDING = 32
local BTN_HEIGHT = 72
function LoginFbDialog:ctor(parent)
    self.parent_ = parent
     cc.Director:getInstance():getTextureCache():removeUnusedTextures()
     self:setNodeEventEnabled(true)
     self:setTouchSwallowEnabled(false)
	 LoginFbDialog.super.ctor(self, {580,400})
     self:addCloseBtn()
     display.newScale9Sprite("#cor_words_bg.png", 0, 0, cc.size(self.width_ - PADDING * 0.5, self.height_ - PADDING * 0.25 - TOP_HEIGHT))
     :addTo(self)
     :pos(0,-30)

     display.newTTFLabel({
            text = bm.LangUtil.getText("DORNUCOPIA","LOGINFB_TITLE"),
            color = styles.FONT_COLOR.LIGHT_TEXT,
            size = 26,
            align = ui.TEXT_ALIGN_CENTER,
        })
        :pos(0, self.height_ * 0.5 - TOP_HEIGHT * 0.5)
       	:addTo(self)

    self.secondBtn_ = cc.ui.UIPushButton.new({normal = "#common_green_btn_up.png", pressed = "#common_green_btn_down.png"}, {scale9 = true})
        :addTo(self)
        :onButtonClicked(buttontHandler(self, self.onButtonClick_))--
        :setButtonLabel("normal", display.newTTFLabel({text = bm.LangUtil.getText("DORNUCOPIA","QUICK_LOGIN"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 30, align = ui.TEXT_ALIGN_CENTER}))
        :setButtonLabel("pressed", display.newTTFLabel({text = bm.LangUtil.getText("DORNUCOPIA","QUICK_LOGIN"), color = styles.FONT_COLOR.GREY_TEXT, size = 30, align = ui.TEXT_ALIGN_CENTER}))

    local buttonWidth = 280
    self.secondBtn_:setButtonSize(buttonWidth, BTN_HEIGHT):pos(0, -DEFAULT_HEIGHT * 0.5 + PADDING + BTN_HEIGHT * 0.5)

    display.newTTFLabel({
            text = bm.LangUtil.getText("DORNUCOPIA","PLEASE_LOGIN_TIP","\n"),
            color = styles.FONT_COLOR.LIGHT_TEXT,
            size = 22,
            align = ui.TEXT_ALIGN_CENTER,
        })
       	:addTo(self)
       	:pos(0,20)

       	display.newTTFLabel({
            text = bm.LangUtil.getText("DORNUCOPIA","LOGIN_TIPS"),
            color = styles.FONT_COLOR.LIGHT_TEXT,
            size = 22,
            align = ui.TEXT_ALIGN_CENTER,
        })
       	:addTo(self)
       	:pos(0,-175)
end
function LoginFbDialog:show()
	self:showPanel_()
end
function LoginFbDialog:onButtonClick_()
    if self.parent_ then
        self.parent_:onClose()
    end
    self:onClose()
    bm.EventCenter:dispatchEvent(nk.eventNames.HALL_LOGOUT_SUCC)
	
end
return LoginFbDialog