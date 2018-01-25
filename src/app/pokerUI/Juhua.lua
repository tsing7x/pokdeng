--
-- Author: tony
-- Date: 2014-08-15 10:34:21
--
local Juhua = class("Juhua", function()
        return display.newNode()
    end)

-- Modify By Tsing --
-- 兼容之前的使用方法，若需要添加整个屏幕的触摸事件屏蔽 eg:Juhua.new(nil, true) -- 
function Juhua:ctor(filename, isSwallTouch)

	if isSwallTouch then
		--todo
		self._touchModel = display.newScale9Sprite("#modal_texture.png", 0, 0, cc.size(display.width, display.height))
            :addTo(self)

   		self._touchModel:setTouchEnabled(true)
   		self._touchModel:setTouchSwallowEnabled(true)
	end

	self._loadingBar = display.newSprite(filename or "#juhua.png")
		:addTo(self)

    self:setNodeEventEnabled(true)
end

function Juhua:onEnter()
    self._loadingBar:runAction(cc.RepeatForever:create(cc.RotateBy:create(100, 36000)))
end

function Juhua:onExit()
    self:stopAllActions()
end

return Juhua
