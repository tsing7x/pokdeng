-- Author: thinkeras3@163.com
-- Date: 2015-09-08 19:00:39
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
--上面黄字：#fbcf28  字号26
--下面白字：#ffffff  字号22
local Panel = import("app.pokerUI.Panel")
local config = import(".BoxActConfig")
local BoxActTenOpenBoxDialog = class("BoxActTenOpenBoxDialog", Panel)

local WIDTH = 585
local HEIGHT = 268

local ITEM_WIDTH = 277
local ITEM_HEIGHT = 39

local ITEM_GAP = 2

local PANDDING = 7.25

function BoxActTenOpenBoxDialog:ctor(data)
	self.background_ = display.newScale9Sprite("#actBox_tipBg1.png", 0, 0, cc.size(WIDTH,HEIGHT))
	:addTo(self)
	self.background_:setTouchEnabled(true)
    self.background_:setTouchSwallowEnabled(true)

    display.newScale9Sprite("#actBox_title_bg.png", 0, 0, cc.size(WIDTH-10,HEIGHT-10))
  :addTo(self)

	display.newTTFLabel({text = bm.LangUtil.getText("BOXACT","TEN_REWARD"), color = cc.c3b(0x6c, 0x28, 0x03), size = 26, align = ui.TEXT_ALIGN_CENTER})
	:addTo(self)
	:pos(0,105)

	self.txt_tab = {}
	for i=1,5 do
		display.newScale9Sprite("#actBox_itemBg.png", 0, 0, cc.size(ITEM_WIDTH,ITEM_HEIGHT))
		:addTo(self)
		:pos(-WIDTH/4 + PANDDING,HEIGHT/4 - 10 - (i-1)*ITEM_HEIGHT)

		local name = config.gidforName[checkint(data[i])+1]
		local txt_ = display.newTTFLabel({text = name, color = cc.c3b(0xff, 0xff, 0xff), size = 22, align = ui.TEXT_ALIGN_CENTER})
		:addTo(self)
		:pos(-WIDTH/4 + PANDDING,HEIGHT/4 - 10 - (i-1)*ITEM_HEIGHT)
		table.insert(self.txt_tab,txt_)
	end

	for i=1,5 do
		display.newScale9Sprite("#actBox_itemBg.png", 0, 0, cc.size(ITEM_WIDTH,ITEM_HEIGHT))
		:addTo(self)
		:pos(WIDTH/4 - PANDDING,HEIGHT/4 - 10 -(i-1)*ITEM_HEIGHT)
		local name = config.gidforName[checkint(data[i+5])+1]
		local txt_ = display.newTTFLabel({text = name, color = cc.c3b(0xff, 0xff, 0xff), size = 22, align = ui.TEXT_ALIGN_CENTER})
		:addTo(self)
		:pos(WIDTH/4 - PANDDING,HEIGHT/4 - 10 -(i-1)*ITEM_HEIGHT)
		table.insert(self.txt_tab,txt_)
	end

	


	self.closeBtn_ = cc.ui.UIPushButton.new({normal = "#panel_black_close_btn_up.png", pressed="#panel_black_close_btn_down.png"})
    :pos(WIDTH/2 -5, HEIGHT/2-10)
    :onButtonClicked(function()
        nk.SoundManager:playSound(nk.SoundManager.CLOSE_BUTTON)
        self:onClose()
    	end)
    :addTo(self)
end
function BoxActTenOpenBoxDialog:show()
    self:showPanel_()
    return self
end
return BoxActTenOpenBoxDialog