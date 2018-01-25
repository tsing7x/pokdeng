--
-- Author: TsingZhang@boyaa.com
-- Date: 2015-11-10 16:12:07
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- Description: TextureHangler for UserInfo.
--

local TextureHandler = {}

function TextureHandler.loadTexture()
	-- body
	display.addSpriteFrames("user_info.plist", "user_info.png")
end

function TextureHandler.removeTexture()
	-- body
	display.removeSpriteFramesWithFile("user_info.plist", "user_info.png")

	nk.schedulerPool:delayCall(function()
	    cc.Director:getInstance():getTextureCache():removeUnusedTextures()
	end, 0.1)
end

return TextureHandler