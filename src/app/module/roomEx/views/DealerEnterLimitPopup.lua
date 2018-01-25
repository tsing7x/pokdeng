local DealerEnterLimitPopup = class("DealerEnterLimitPopup", nk.ui.Panel)

local WIDTH = 598
local HEIGHT = 350

local StorePopup = import("app.module.newstore.StorePopup")
function DealerEnterLimitPopup:ctor(param)
	self:setNodeEventEnabled(true)
	self:setTouchEnabled(true)
    self:setTouchSwallowEnabled(true)
    self.param_ = param

	self._background = display.newScale9Sprite("#perRoom_bgPanel.png", 0,0,
		cc.size(WIDTH, HEIGHT))
		:addTo(self)

	

	local titleWidth = 52
	local titleBlock = display.newScale9Sprite("#perRoom_blockTitle.png", 0, 0,
		cc.size(WIDTH-10, titleWidth))

	titleBlock:pos(0, HEIGHT/2 - titleWidth/2)
		:addTo(self)

	local tipsBlock = display.newScale9Sprite("#perRoom_blockIn.png", 0, 0,
		cc.size(570,210))
		:addTo(self)
		:pos(0,0)

	self.closeBtn_ = cc.ui.UIPushButton.new({normal = "#panel_close_btn_up.png", pressed="#panel_close_btn_down.png"})
            :pos(WIDTH * 0.5 - 20, HEIGHT * 0.5 - 25)
            :onButtonClicked(function() 
                    self:onClose()
                    nk.SoundManager:playSound(nk.SoundManager.CLOSE_BUTTON)
                end)
            :addTo(self, 99)



   	local title = display.newTTFLabel({text =T("进入失败,您的现金币不足"),size = 36 , color = cc.c3b(0x54, 0x99, 0xc7), align = ui.TEXT_ALIGN_CENTER})
		:pos(0,HEIGHT/2-28)
		:addTo(self)



	local txtArr = {
		T("1.参与比赛，可赢取部分现金币"),
		T("2.在上庄玩法的现金币场可快速赢取海量现金币"),
		T("3.累计现金币可在兑换商城中兑换超多实物奖励")
	}

	local str = ""

	for i=1,#txtArr do
		str = str..txtArr[i].."\n"
	end
	--
	local contentTxt = display.newTTFLabel({text =str,size = 22 , color = cc.c3b(0x6c,0x8a,0x9e), dimensions = cc.size(WIDTH-35, HEIGHT-80),align = ui.TEXT_ALIGN_LEFT})
		:pos(-(570)/2 + 5,(210)/2+50 )
		:align(display.TOP_LEFT)
		:addTo(self)

	self.matchBtn = cc.ui.UIPushButton.new({normal = "#common_green_btn_up.png", pressed = "#common_green_btn_down.png"}, {scale9 = true})
        :addTo(self)
        :setButtonSize(211, 52)
        :onButtonClicked(buttontHandler(self, self.onButtonClick_))
        :setButtonLabel("normal", display.newTTFLabel({text = T("充值进入"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 30, align = ui.TEXT_ALIGN_CENTER}))
        :setButtonLabel("pressed", display.newTTFLabel({text = T("充值进入"), color = styles.FONT_COLOR.GREY_TEXT, size = 30, align = ui.TEXT_ALIGN_CENTER}))
        :pos(0,-HEIGHT/2+35)

    cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#rounded_rect_10.png"}, {scale9 = true})
    :setButtonSize(120, 30)
    :pos(220,-HEIGHT/2+35)
    :onButtonClicked(buttontHandler(self, self.enterGame))
    :setButtonLabel("normal", display.newTTFLabel({text = T("进入旁观>>"), color = cc.c3b(0xf0,0xff,0x00), size = 20, align = ui.TEXT_ALIGN_CENTER}))
    :addTo(self)
end
function DealerEnterLimitPopup:onButtonClick_(evt)
	self:hidePanel_()
	--self.param_.enterMatch()
	StorePopup.new(2):showPanel()

end
function DealerEnterLimitPopup:enterGame(evt)
	self:hidePanel_()
	self.param_.enterGame()
end
function DealerEnterLimitPopup:show()
	-- body
	self:showPanel_()
end

function DealerEnterLimitPopup:onShowed()
	-- body
	
end

return DealerEnterLimitPopup