local config = import(".Config")
-- local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")

local bcakgroundPanelMagrinRight = 5
local backgroundPanelMagrinTop = 8
local animationTime = 0.3

local WinLoseShow = class("WinLoseShow", function()
	-- body
	return display.newNode()
end)

function WinLoseShow:ctor()
	-- body
	self._background = display.newScale9Sprite("#panel_bg.png", display.size.width - config.WinLoseShowParam.WIDTH / 2,
	display.size.height - config.WinLoseShowParam.HEIGHT / 2 - backgroundPanelMagrinTop, cc.size(config.WinLoseShowParam.WIDTH, config.WinLoseShowParam.HEIGHT))
	:addTo(self)

	self._background:setTouchEnabled(true)
	self._background:setTouchSwallowEnabled(true)

	self:initViews()
end

function WinLoseShow:initViews()
	-- body
	local pokerCardMagrinEach = 5
	local pokerCardMagrinBottom = 5
	
	local fakeWinLoseDataList = config.makeFakeWinLoseData()

	for i = 1,2 do
		local listItem = require("app.module.gameReview.WinLoseDetail").new(fakeWinLoseDataList[i])
		listItem:pos(listItem:getContentSize().width * (i - 1) + pokerCardMagrinEach * (i - 1), pokerCardMagrinBottom)

		listItem:addTo(self._background)
	end
end

function WinLoseShow:show()
	-- body
	-- nk.PopupManager:addPopup(self, true, true, true, false)
	self:onShowPopup()
	return self
end

function WinLoseShow:onShowPopup()
	-- body

	local showTime = 3
	self:stopAllActions()

	transition.moveTo(self, {time = animationTime, x = display.size.width - config.WinLoseShowParam.WIDTH  / 2 - bcakgroundPanelMagrinRight, easing = "OUT", onComplete = function()
		-- body
		if self.onShowed then
			--todo
			self:onShowed()
		end
	end})

	-- print("aaaaaaaaaaaaaaab")
	bm.SchedulerPool.new():delayCall(handler(self, self.onRemovePopup), showTime + animationTime)
end

function WinLoseShow:onRemovePopup(onRemoveCallBack)
	-- body
	-- nk.PopupManager:removePopup(self)
	self:stopAllActions()
	-- print("aaaaaaaaaaaaa")
    transition.moveTo(self, {time = animationTime, x = display.size.width + config.WinLoseShowParam.WIDTH / 2, easing="OUT", onComplete=function() 
        onRemoveCallBack()

    end})
end

return WinLoseShow