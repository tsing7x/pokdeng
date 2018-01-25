-- Author: thinkeras3@163.com
-- Date: 2015-08-11 17:31:50
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- 个人种子信息框
local Panel = import("app.pokerUI.Panel")
local SeedInfoDialog = class("SeedInfoDialog", Panel)

function SeedInfoDialog:ctor()
     cc.Director:getInstance():getTextureCache():removeUnusedTextures()
     self:setNodeEventEnabled(true)
     self:setTouchSwallowEnabled(false)
	 SeedInfoDialog.super.ctor(self, {370,270})
     self:addCloseBtn()
end

function SeedInfoDialog:show(seedType,data)
	self:showPanel_()
     local pictrue;
     if seedType == 1 then
          pictrue= display.newSprite("#cor_ingot.png")
          display.newTTFLabel({text = bm.LangUtil.getText("DORNUCOPIA","GETED_REWARD",data.money), color = cc.c3b(0xC7, 0xE5, 0xFF), size = 20, align = ui.TEXT_ALIGN_CENTER})
          :addTo(self)
          display.newTTFLabel({text = bm.LangUtil.getText("DORNUCOPIA","NEED_TIME",data.ripeTime), color = cc.c3b(0xC7, 0xE5, 0xFF), size = 20, align = ui.TEXT_ALIGN_CENTER})
          :addTo(self)
          :pos(0,-40)
     elseif seedType==2 then
          pictrue= display.newSprite("#cor_silver.png")
          display.newTTFLabel({text = bm.LangUtil.getText("DORNUCOPIA","GETED_REWARD",data.money), color = cc.c3b(0xC7, 0xE5, 0xFF), size = 20, align = ui.TEXT_ALIGN_CENTER})
          :addTo(self)
          display.newTTFLabel({text = bm.LangUtil.getText("DORNUCOPIA","NEED_TIME",data.ripeTime), color = cc.c3b(0xC7, 0xE5, 0xFF), size = 20, align = ui.TEXT_ALIGN_CENTER})
          :addTo(self)
          :pos(0,-40)
     else
          pictrue= display.newSprite("#cor_water.png")
          self.speedInfo_txt_ = display.newTTFLabel({text = bm.LangUtil.getText("DORNUCOPIA","ADDSPEEDTIME"), color = cc.c3b(0xC7, 0xE5, 0xFF), size = 20, align = ui.TEXT_ALIGN_CENTER})
          :addTo(self)
     end
     pictrue:addTo(self)
     pictrue:pos(0,60)
end

return SeedInfoDialog