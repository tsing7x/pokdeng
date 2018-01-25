-- Author: thinkeras3@163.com
-- Date: 2015-12-09 11:31:50
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- 强制退赛提示(开赛后)
local Panel = import("app.pokerUI.Panel")
local MatchForceExitTipPopup = class("MatchForceExitTipPopup", Panel)
local DEFAULT_WIDTH = 600
local DEFAULT_HEIGHT = 353
local TOP_HEIGHT = 59
local PADDING = 32
local BTN_HEIGHT = 72

-- local TXT_WIDTH = 558

-- local TXT_HEIGHT = 268

local CONTENT_BG_WIDHT = 572
local CONTENT_BG_HEIGHT = 210
function MatchForceExitTipPopup:ctor(leftNum)
    cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    display.addSpriteFrames("match.plist", "match.png")
	--self.callback = callback
    --self.leftTime_ = tonumber(22)
    self.leftNum_ = leftNum
	 self:setNodeEventEnabled(true)
     self:setTouchSwallowEnabled(false)
	 MatchForceExitTipPopup.super.ctor(self, {DEFAULT_WIDTH,DEFAULT_HEIGHT})

    display.newScale9Sprite("#match_exit_top.png",0,0,cc.size(DEFAULT_WIDTH,TOP_HEIGHT))
    :addTo(self)
    :pos(0,DEFAULT_HEIGHT/2 - TOP_HEIGHT/2)

    display.newScale9Sprite("#match_exit_content_bg.png",0,0,cc.size(CONTENT_BG_WIDHT,CONTENT_BG_HEIGHT))
    :addTo(self)
    


     self:addCloseBtn()

     self.textArr_ = bm.LangUtil.getText("MATCH","FORCE_EXIT_GAME_TIPS") 
    self.text2_ = bm.LangUtil.getText("MATCH","PLAY_GAME_LEFT_NUM",self.leftNum_) 

    self.buttonTxt_ = bm.LangUtil.getText("MATCH","FORCE_EXIT_BUTTON") 
        
    

     self.content_ = ""
     local strArr = self.textArr_--
     for i=1,#strArr do
     	self.content_= self.content_..strArr[i].."\n"
     end


     self.contentTxt_ = display.newTTFLabel({text = ""..self.content_, color = styles.FONT_COLOR.LIGHT_TEXT, size = 20, dimensions = cc.size(CONTENT_BG_WIDHT-10, CONTENT_BG_HEIGHT-40),align = ui.TEXT_ALIGN_LEFT})
         :align(display.TOP_LEFT,-(CONTENT_BG_WIDHT-10)/2,(CONTENT_BG_HEIGHT-20)/2+10)---
         :addTo(self)

    self.tipsTxt_ = display.newTTFLabel({text = ""..self.text2_, color = cc.c3b(0xff,0x00,0x00), size = 20, dimensions = cc.size(CONTENT_BG_WIDHT-10, 25),align = ui.TEXT_ALIGN_LEFT})
         :align(display.TOP_LEFT,-(CONTENT_BG_WIDHT-10)/2,(CONTENT_BG_HEIGHT-20)/2+10 - (CONTENT_BG_HEIGHT-40))---
         :addTo(self)

        -- local time =  os.date("%M:%S", self.leftTime_);
        -- local str = bm.LangUtil.formatString(self.content_,time)
        -- self.contentTxt_:setString(str)

    
    self.exitBtnNormalLabel_ = display.newTTFLabel({text = self.buttonTxt_[1], color = styles.FONT_COLOR.LIGHT_TEXT, size = 20, align = ui.TEXT_ALIGN_CENTER})
    self.exiteBtn_ = cc.ui.UIPushButton.new({normal = "#common_dark_blue_btn_up.png", pressed = "#common_dark_blue_btn_down.png", disabled = "#common_btn_disabled.png"}, {scale9 = true})
        :setButtonSize(120, 42)
        :setButtonLabel("normal", self.exitBtnNormalLabel_)
        :pos(-DEFAULT_WIDTH/2 + 160, -DEFAULT_HEIGHT/2 + 30)
        :addTo(self)
        :onButtonClicked(buttontHandler(self, self.onExitBtn))
    self.exiteBtn_:setTouchSwallowEnabled(false)


    self.continueBtnNormalLabel_ = display.newTTFLabel({text = self.buttonTxt_[2], color = styles.FONT_COLOR.LIGHT_TEXT, size = 20, align = ui.TEXT_ALIGN_CENTER})
    self.continueBtn_ = cc.ui.UIPushButton.new({normal = "#common_green_btn_up.png", pressed = "#common_green_btn_down.png", disabled = "#common_btn_disabled.png"}, {scale9 = true})
        :setButtonSize(120, 42)
        :setButtonLabel("normal", self.continueBtnNormalLabel_)
        :pos(DEFAULT_WIDTH/2 - 160, -DEFAULT_HEIGHT/2 + 30)
        :addTo(self)
        :onButtonClicked(buttontHandler(self, self.onContinueBtn))
    self.continueBtn_:setTouchSwallowEnabled(false)

    if self.leftNum_== 0 then
         self.tipsTxt_:hide()
         self.exiteBtn_:show()
         self.continueBtn_:pos(DEFAULT_WIDTH/2 - 160, -DEFAULT_HEIGHT/2 + 30)

    else
         self.tipsTxt_:show()
         self.exiteBtn_:hide()
         self.continueBtn_:pos(0, -DEFAULT_HEIGHT/2 + 30)
    end
    -- self:stopAction(self.action_)
    -- self.action_ = self:schedule(function ()
    --                 self.leftTime_ = self.leftTime_ - 1 
    --                 local needTime = os.date("%M:%S", self.leftTime_);
    --                 local str = bm.LangUtil.formatString(self.content_,needTime)
    --                 self.contentTxt_:setString(str)

    --                 if self.leftTime_<= 0 then
    --                     self:stopAction(self.action_)
    --                     self:onExitBtn()
    --                 end
    --             end,1)
end
function MatchForceExitTipPopup:onExitBtn()
	-- if self.callback  then 
	-- 	self.callback()
	-- end
     nk.server:matchForceExitGame()
	self:onClose()
end
function MatchForceExitTipPopup:onContinueBtn()
	self:onClose()
end
function MatchForceExitTipPopup:onCleanup()
    self:stopAction(self.action_)
    display.removeSpriteFramesWithFile("match.plist", "match.png")
end
function MatchForceExitTipPopup:show()
	self:showPanel_()
end
return MatchForceExitTipPopup