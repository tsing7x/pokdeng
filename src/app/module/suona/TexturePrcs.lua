--
-- Author: TsingZhang@boyaa.com
-- Date: 2015-12-03 18:09:00
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- Description: TextureProcesser In SuonaUsePopup By tsing.
--

local TextureProcess = {}

function TextureProcess.loadTexture()
	-- body
	display.addSpriteFrames("suona.plist", "suona.png")
end


function TextureProcess.removeTexture()
	-- body
	display.removeSpriteFramesWithFile("suona.plist", "suona.png")

	nk.schedulerPool:delayCall(function()
	    cc.Director:getInstance():getTextureCache():removeUnusedTextures()
	end, 0.1)
end

return TextureProcess