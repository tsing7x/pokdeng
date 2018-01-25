local BoxItem = class("BoxItem", function() return display.newNode() end)
local config = import(".BoxActConfig")
local TOTAL_ROCK_TIME = 6
local LIGHT_RUN_TIME = 10
function BoxItem:ctor(mainView)
	self.mainView_ = mainView
	self:createNode_()
end

function BoxItem:createNode_()	
	
	-- display.newSprite("#actBox_boxBg.png")
 --    :addTo(self)

    self:setDefStutes_()
    
    self.writeBtn_ = cc.ui.UIPushButton.new("#actBox_blackBg.png",{scale9 = true})
    :addTo(self)
    :setButtonSize(117,149)
	:onButtonClicked(buttontHandler(self, self.onClickWriteBtn_))

	self.hummer_ = display.newSprite("#actBox_hammer.png")
    :addTo(self)
    :pos(70,70)
    self.hummer_:setAnchorPoint(1,0)
    self.hummer_:setVisible(false)

  --   local rotation = 0
  --   self.action_ = self:schedule(function ()
		-- if rotation == 10 then 
		-- 	rotation=-10
		-- else
		-- 	rotation = 10
		-- end
		-- self.hummer_:setRotation(rotation)
		-- end,.2)

    
end
function BoxItem:setDefStutes_()
	self.normalBox_ = display.newSprite("#actBox_notOpen.png")
    :addTo(self)
    :pos(0,15)
    self.running_ = false

    if self.light_ then
    	self.light_:setRotation(0)
    	self.light_:removeFromParent()
    end
	if self.openBoxStatus then
		self.openBoxStatus:removeFromParent()
	end
	self.openBoxStatus = nil
	self.light_ = nil;
	self:stopAction(self.action_)
end
--摇动宝箱
-- function BoxItem:rockBox(gid)
-- 	self.gid = gid
-- 	self.running_ = true
-- 	local rocktime = 0
-- 	local rotation = 10;
-- 	self.action_ = self:schedule(function ()
-- 		if rotation == 10 then 
-- 			rotation=-10
-- 		else
-- 			rotation = 10
-- 		end
-- 		self.normalBox_:setRotation(rotation)
-- 		rocktime = rocktime+1;
-- 		if rocktime == TOTAL_ROCK_TIME then
-- 			self:stopAction(self.action_)
-- 			self.normalBox_:setRotation(0)
-- 			self.normalBox_:removeFromParent()
-- 			self.normalBox_ = nil;
-- 			self.mainView_:upDateResult()
-- 			self.openBoxStatus = display.newSprite(config.gidforPic[checkint(self.gid+1)])
-- 			:addTo(self)
-- 			:pos(0,15)

-- 			self.light_ = display.newSprite("#actBox_light.png")
-- 			:addTo(self)
-- 			:pos(0,10)

-- 			local tempRotation = 0
-- 			local lightTime = 0;
-- 			self.action_ = self:schedule(function ()
-- 				self.light_:setRotation(tempRotation)
-- 				tempRotation = tempRotation+20
-- 				if tempRotation == 360 then tempRotation = 0 end
-- 				lightTime = lightTime+1
-- 				if lightTime == LIGHT_RUN_TIME then
-- 					self.mainView_:openOtherBox()
-- 				end
-- 			end,
-- 			0.1)
-- 		end
-- 	end,0.2)

-- end

function BoxItem:rockBox(gid)
	self.gid = gid
	self.running_ = true
	local rocktime = 0
	local rotation = 10;
	self.hummer_:setRotation(0)
	self.hummer_:setVisible(true)
	self.action_ = self:schedule(function ()
		if rotation == 10 then 
			rotation=-10
		else
			rotation = 10
		end
		self.hummer_:setRotation(rotation)
		rocktime = rocktime+1;
		if rocktime == TOTAL_ROCK_TIME then
			self.hummer_:setVisible(false)
			self:stopAction(self.action_)
			self.normalBox_:setRotation(0)
			self.normalBox_:removeFromParent()
			self.normalBox_ = nil;
			self.mainView_:upDateResult()
			self.openBoxStatus = display.newSprite(config.gidforPic[checkint(self.gid+1)])
			:addTo(self)
			:pos(0,15)

			self.light_ = display.newSprite("#actBox_light.png")
			:addTo(self)
			:pos(0,10)

			local tempRotation = 0
			local lightTime = 0;
			self.action_ = self:schedule(function ()
				self.light_:setRotation(tempRotation)
				tempRotation = tempRotation+20
				if tempRotation == 360 then tempRotation = 0 end
				lightTime = lightTime+1
				if lightTime == LIGHT_RUN_TIME then
					self.mainView_:openOtherBox()
				end
			end,
			0.1)
		end
	end,0.2)

end
function BoxItem:openBox(gid)
	self.openBoxStatus = display.newSprite(config.gidforPic[checkint(gid+1)])
	:addTo(self)
	:pos(0,15)
	self.normalBox_:setRotation(0)
	self.normalBox_:removeFromParent()
	self.normalBox_ = nil;
end

function BoxItem:onlyRock()
	self.running_ = true
	self.hummer_:setVisible(true)
	local rocktime = 0
	local rotation = 10;
	self.action_ = self:schedule(function ()
		if rotation == 10 then 
			rotation=-10
		else
			rotation = 10
		end
		self.hummer_:setRotation(rotation)
		rocktime = rocktime+1;
		if rocktime == TOTAL_ROCK_TIME then
			self:stopAction(self.action_)
			self.normalBox_:setRotation(0)
			self.running_ = false
			self.hummer_:setVisible(false)
		end
	end,0.2
	)
end

function BoxItem:onClickWriteBtn_()
	if self.running_ == true then return end
	--self:rockBox(3)
	self.mainView_:toOpenBox(self.boxid_)
end

function BoxItem:setBoxId(value)
	self.boxid_ = value
end

function BoxItem:getBoxId()
	return self.boxid_
end

function BoxItem:onCleanup()
	self:stopAction(self.action_)
end

return BoxItem