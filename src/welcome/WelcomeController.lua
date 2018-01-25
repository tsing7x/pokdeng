--
-- Author: VanfoHuang
-- Date: 2016-07-04 10:00:00
--

local WelcomeScene = require("welcome.WelcomeScene")
local WelcomeController = class("WelcomeController")

function WelcomeController:ctor()
    -- ios 功能在IOS6,7下有BUG，因此暂时不用
    --device.platform == "ios"
	if (device.platform == "android") and ccexp and ccexp.VideoPlayer then 
        self:showWelcomePage()
    else
        self:enterGame()
    end
end

function WelcomeController:showWelcomePage()
	self.scene_ = WelcomeScene.new(self)
    display.replaceScene(self.scene_)
    self.scene_:showWelcomePage()
end

function WelcomeController:enterGame()
	require("update.UpdateController").new()
end

return WelcomeController