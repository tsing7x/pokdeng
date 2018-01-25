--
-- Author: TsingZhang@boyaa.com
-- Date: 2015-11-04 17:45:35
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- Description: TextureHandler Signature Complement.
--

local TextureHandler = {}

function TextureHandler.loadTexture()
	-- body
	display.addSpriteFrames("sign_in.plist", "sign_in.png")
end

function TextureHandler.removeTexture()
	-- body
	display.removeSpriteFramesWithFile("sign_in.plist", "sign_in.png")

	nk.schedulerPool:delayCall(function()
	    cc.Director:getInstance():getTextureCache():removeUnusedTextures()
	end, 0.1)
end

return TextureHandler