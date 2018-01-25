local pa = pa or {}

function pa.loadTexture()
	-- body

	display.addSpriteFrames("promot.plist", "promot.png")
end

function pa.removeTexture()
	-- body
	display.removeSpriteFramesWithFile("promot.plist", "promot.png")

	nk.schedulerPool:delayCall(function()
	    cc.Director:getInstance():getTextureCache():removeUnusedTextures()
	end, 0.1)
end

return pa