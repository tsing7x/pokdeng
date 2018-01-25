local pg = pg or {}
	
function pg.loadTexture()
	-- body
	display.addSpriteFrames("pay_guide.plist", "pay_guide.png")
end

function pg.removeTexture()
	-- body
	display.removeSpriteFramesWithFile("pay_guide.plist", "pay_guide.png")

	nk.schedulerPool:delayCall(function()
        cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    end, 0.1)
end

return pg