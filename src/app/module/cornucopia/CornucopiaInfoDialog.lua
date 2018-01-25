-- Author: thinkeras3@163.com
-- Date: 2015-08-11 14:31:50
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- 聚宝盆说明框
local Panel = import("app.pokerUI.Panel")
local CornucopiaInfoDialog = class("CornucopiaInfoDialog", Panel)

function CornucopiaInfoDialog:ctor()
     cc.Director:getInstance():getTextureCache():removeUnusedTextures()
     self:setNodeEventEnabled(true)
     self:setTouchSwallowEnabled(false)
	 CornucopiaInfoDialog.super.ctor(self, {600,512})
     self:addCloseBtn()
     local str = ""
     local strTab = bm.LangUtil.getText("DORNUCOPIA","INFOMATION")
     for i=1,8 do 
     	str = str..strTab[i].." \n ";
     	if i == 1 then str = str..' \n '; end
     end
     self.content_txt_ = display.newTTFLabel({text = str, color = cc.c3b(0xC7, 0xE5, 0xFF), size = 20, dimensions=cc.size(490, 480),align = ui.TEXT_ALIGN_LEFT})
     :addTo(self)
end

function CornucopiaInfoDialog:show(data)
	self:showPanel_()
     if data then
          self.content_txt_:setString(json.encode(data))
     end
end

return CornucopiaInfoDialog