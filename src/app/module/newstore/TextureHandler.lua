--
-- Author: TsingZhang@boyaa.com
-- Date: 2015-11-10 16:12:07
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- Description: TextureHangler for StorePopup && GiftStorePopup.
--

local TextureHandler = {}

function TextureHandler.loadTexture(resType)
	-- body
	TextureHandler.viewType_ = resType

	if resType and resType == 2 then
		--todo
		display.addSpriteFrames("gift_store.plist", "gift_store.png")
	else
		display.addSpriteFrames("store.plist", "store.png")
	end
end

function TextureHandler.removeTexture()
	-- body
	if TextureHandler.viewType_ and TextureHandler.viewType_ == 2 then
		--todo
		display.removeSpriteFramesWithFile("gift_store.plist", "gift_store.png")
	else
		display.removeSpriteFramesWithFile("store.plist", "store.png")
	end

	nk.schedulerPool:delayCall(function()
	    cc.Director:getInstance():getTextureCache():removeUnusedTextures()
	end, 0.1)
end

return TextureHandler