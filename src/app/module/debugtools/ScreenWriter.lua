

local ScreenWriter = class("ScreenWriter") 
local Z_ORDER = 2000

function ScreenWriter:ctor()
	self:init()
end


function ScreenWriter:init()
	self.container_ = display.newNode()
    self.container_:retain()
    self.container_:setNodeEventEnabled(true)
    self.container_.onCleanup = handler(self, function (obj)
        -- 移除模态
        if obj.infoLabel_ then
            obj.infoLabel_:removeFromParent()
            obj.infoLabel_ = nil
        end   
    end)

end



function ScreenWriter:showPrinter()

	-- if self.isAvailable_ then
	-- 	return
	-- end

	self.isAvailable_ = true

	if not self.container_:getParent() then
        self.container_:addTo(nk.runningScene, Z_ORDER)
    end

    if not self.infoLabel_ then
		self.infoLabel_ = display.newTTFLabel({
		                    text = "",
		                    font = "Arial.ttf",
		                    size = 20,
		                    x = display.cx + 10,
		                    y = display.cy,
		                    color=cc.c3b(0xff,0x00,0x00),
		                    align = ui.TEXT_ALIGN_LEFT,
		                    dimensions = cc.size(display.width-3,display.height)
		                }):addTo(self.container_)

    end
end

function ScreenWriter:write(infoStr)
	if not self.isAvailable_ then
		return
	end

	if self.infoLabel_ then
		self.infoLabel_:setString(infoStr)
	end
end


function ScreenWriter:clearPrinter()
	if self.infoLabel_ then
		self.infoLabel_:setString("")
	end
end


function ScreenWriter:hidePrinter()
	self.isAvailable_ = false
	if not self.container_:getParent() then
        self.container_:removeFromParent()
    end
end


return ScreenWriter


