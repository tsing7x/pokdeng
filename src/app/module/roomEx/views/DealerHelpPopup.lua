local DealerHelpPopup = class("DealerHelpPopup", nk.ui.Panel)

local WIDTH = 725
local HEIGHT = 445

function DealerHelpPopup:ctor()
	self:setNodeEventEnabled(true)
	self:setTouchEnabled(true)
    self:setTouchSwallowEnabled(true)

	self._background = display.newScale9Sprite("#perRoom_bgPanel.png", 0,0,
		cc.size(WIDTH, HEIGHT))
		:addTo(self)

	

	local titleWidth = 52
	local titleBlock = display.newScale9Sprite("#perRoom_blockTitle.png", 0, 0,
		cc.size(WIDTH-10, titleWidth))

	titleBlock:pos(0, HEIGHT/2 - titleWidth/2)
		:addTo(self)

	local tipsBlock = display.newScale9Sprite("#perRoom_blockIn.png", 0, 0,
		cc.size(WIDTH-25, HEIGHT-80))
		:addTo(self)
		:pos(0,-20)

	self.closeBtn_ = cc.ui.UIPushButton.new({normal = "#panel_close_btn_up.png", pressed="#panel_close_btn_down.png"})
            :pos(WIDTH * 0.5 - 20, HEIGHT * 0.5 - 25)
            :onButtonClicked(function() 
                    self:onClose()
                    nk.SoundManager:playSound(nk.SoundManager.CLOSE_BUTTON)
                end)
            :addTo(self, 99)



   	local title = display.newTTFLabel({text =T("上庄场玩法介绍"),size = 36 , color = cc.c3b(227, 232, 246), align = ui.TEXT_ALIGN_CENTER})
		:pos(0,HEIGHT/2-28)
		:addTo(self)



	local txtArr = {
		T("1.基于普通玩法，额外增加一个庄家位供玩家上庄"),
		T("2.上庄需要比在座其他人携带更多的资产，且无携带上限"),
		T("3.抢庄或上庄后，第四轮起其他玩家才可再次竞争庄位，共两轮抢庄时间，第六轮开局前更换新的庄家，前五轮统称为【庄家保护期】"),
		T("4.若第四、五轮均无人上庄，后续每轮均可选择上庄，上庄后的下一轮更新庄家，进入【庄家保护期】 "),
		T("5.庄家在携带资产足够的情况下，【庄家保护期】内不可退出房间")
	}

	local str = ""

	for i=1,#txtArr do
		str = str..txtArr[i].."\n"
	end
	--
	local contentTxt = display.newTTFLabel({text =str,size = 22 , color = cc.c3b(227, 232, 246), dimensions = cc.size(WIDTH-35, HEIGHT-80),align = ui.TEXT_ALIGN_LEFT})
		:pos(-(WIDTH-25)/2 + 5,(HEIGHT-80)/2-30 )
		:align(display.TOP_LEFT)
		:addTo(self)
end

function DealerHelpPopup:show()
	-- body
	self:showPanel_()
end

function DealerHelpPopup:onShowed()
	-- body
	
end

return DealerHelpPopup