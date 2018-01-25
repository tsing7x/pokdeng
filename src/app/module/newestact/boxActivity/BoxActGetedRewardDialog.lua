local Panel = import("app.pokerUI.Panel")
local config = import(".BoxActConfig")
local BoxActGetedRewardDialog = class("BoxActGetedRewardDialog", Panel)
local WIDTH = 585
local HEIGHT = 243
function BoxActGetedRewardDialog:ctor()
	self.background_ = display.newScale9Sprite("#actBox_tipBg1.png", 0, 0, cc.size(WIDTH,HEIGHT))
	:addTo(self)
	self.background_:setTouchEnabled(true)
    self.background_:setTouchSwallowEnabled(true)

	display.newScale9Sprite("#actBox_tipBg2.png", 0, 0, cc.size(WIDTH-10,HEIGHT-10))
	:addTo(self)

	
end

function BoxActGetedRewardDialog:show(gid)
	self.gid_ = checkint(gid)
    self:showPanel_()
    return self
end

function BoxActGetedRewardDialog:onCleanup()
	self:stopAction(self.action_)
end

function BoxActGetedRewardDialog:onShowed()
	if not self.gid_ then self.gid_ =1 end
	self.openBoxStatus = display.newSprite(config.gidforPic[self.gid_+1])
	:addTo(self)
	:pos(0,30)


	display.newTTFLabel(
	{text = config.gidforDesc[self.gid_+1], 
	color = cc.c3b(0xFF, 0xFF, 0xFF),
	size = 24,
	align = ui.TEXT_ALIGN_CENTER,
	dimensions = cc.size(WIDTH - 32, 0)})
	:addTo(self)
	:pos(0,-60)

	
	self.light_ = display.newSprite("#actBox_light.png")
	:addTo(self)
	:pos(0,30)

	local tempRotation = 0
	local runTime = 0
	self.action_ = self:schedule(function ()
		self.light_:setRotation(tempRotation)
		tempRotation = tempRotation+20
		runTime = runTime+1;
		if runTime == 15 then
			self:stopAction(self.action_)
         	self:onClose()
		end
		if tempRotation == 360 then tempRotation = 0 end
	end,0.1)

	

	-- self.closeBtn_ = cc.ui.UIPushButton.new({normal = "#panel_black_close_btn_up.png", pressed="#panel_black_close_btn_down.png"})
 --    :pos(WIDTH/2 -5, HEIGHT/2-10)
 --    :onButtonClicked(function()
 --        nk.SoundManager:playSound(nk.SoundManager.CLOSE_BUTTON)
 --        self:stopAction(self.action_)
 --        self:onClose()
 --    	end)
 --    :addTo(self)
end

return BoxActGetedRewardDialog