

local Panel = import("app.pokerUI.Panel")
local BoxActNotEnoughMoneyTip = class("BoxActNotEnoughMoneyTip", Panel)

local WIDTH = 585
local HEIGHT = 243
function BoxActNotEnoughMoneyTip:ctor(popup)
	self.popup_ = popup
	self.background_ = display.newScale9Sprite("#actBox_tipBg1.png", 0, 0, cc.size(WIDTH,HEIGHT))
	:addTo(self)
	self.background_:setTouchEnabled(true)
    self.background_:setTouchSwallowEnabled(true)

	display.newScale9Sprite("#actBox_tipBg2.png", 0, 0, cc.size(WIDTH-10,HEIGHT-10))
	:addTo(self)

	display.newSprite("#actBox_face.png")
	:addTo(self)
	:pos(0,60)

	cc.ui.UIPushButton.new({normal = "#actBox_playBt.png", pressed="#actBox_playBt.png"})
	:addTo(self)
	:pos(-110,-80)
	:onButtonClicked(handler(self, self.playGameClick_))

	cc.ui.UIPushButton.new({normal = "#actBox_rechangeBt.png", pressed="#actBox_rechangeBt.png"})
	:addTo(self)
	:pos(110,-80)
	:onButtonClicked(handler(self, self.rechangeClick_))

	display.newTTFLabel(
	{text = bm.LangUtil.getText("BOXACT","NOT_ENOUGH_MONEY"), 
	color = cc.c3b(0xFF, 0xFF, 0xFF),
	size = 24,
	align = ui.TEXT_ALIGN_CENTER,
	dimensions = cc.size(WIDTH - 32, 0)})
	:addTo(self)

	self.closeBtn_ = cc.ui.UIPushButton.new({normal = "#panel_black_close_btn_up.png", pressed="#panel_black_close_btn_down.png"})
    :pos(WIDTH/2 -5, HEIGHT/2-10)
    :onButtonClicked(function()
        nk.SoundManager:playSound(nk.SoundManager.CLOSE_BUTTON)
        self:onClose()
    	end)
    :addTo(self)
end
function BoxActNotEnoughMoneyTip:show()
    self:showPanel_()
    return self
end
function BoxActNotEnoughMoneyTip:rechangeClick_()
	self:onClose()
	self.popup_:goShop_()
end

function BoxActNotEnoughMoneyTip:playGameClick_()
	self:onClose()
	self.popup_:goPlay_()
end
return BoxActNotEnoughMoneyTip