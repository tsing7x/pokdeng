
local SeatProgressTimerEx = class("SeatProgressTimerEx",function()
	return display.newNode()
end)


function SeatProgressTimerEx:ctor(second)
	 self:setNodeEventEnabled(true)
	 self.second_ = second
    self.progressTimer_ = cc.progressTimer:create(cc.Sprite:create("test/circle_bg.png"))
    self.progressTimer_:setType(kcc.progressTimerTypeRadial)
    -- self.progressTimer_:setPosition(cc.pMake(100, s.height / 2))
	self:addChild(self.progressTimer_)	
	self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.onEnterFrame))
end

function SeatProgressTimerEx:onEnter()
	local fromto = cc.progressFromTo:create(self.second_, 100,0)
	self.progressTimer_:runAction(cc.RepeatForever:create(fromto))
	-- self.progressTimer_:setReverseProgress(true)
	self.progressTimer_:setReverseDirection(true)
	self:scheduleUpdate()
end



function SeatProgressTimerEx:onEnterFrame(evt, isFastForward)
	self:setColor()

end



function SeatProgressTimerEx:setPercentage(percentage)
	if self.progressTimer_ then
		self.progressTimer_:setPercentage(setPercentage)
	end
end


function SeatProgressTimerEx:onExit()
	self:unscheduleUpdate()
end



function SeatProgressTimerEx:dispose()
	self:unscheduleUpdate()
end


function SeatProgressTimerEx:setColor()
	if self.progressTimer_ then
		local per = self.progressTimer_:getPercentage()
		if per > 50 then
			self.progressTimer_:setColor(cc.c3b(0x00, 0xff, 0x00))

		elseif per<= 50 and per >25 then
			self.progressTimer_:setColor(cc.c3b(0xff, 0xff, 0x00))
		else
			self.progressTimer_:setColor(cc.c3b(0xff, 0x00, 0x00))
		end
	end
end



return SeatProgressTimerEx



