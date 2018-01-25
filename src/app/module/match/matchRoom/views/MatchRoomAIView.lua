--
-- Author: thinkeras3@163.com
-- Date: 2015-11-26 15:14:54
-- Copyright: Copyright (c) 2014, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- 房间玩牌AI(托管)视图

local MatchRoomAIView = class("MatchRoomAIView", function ()
    return display.newNode()
end)

local LINE_WIDTH = 165

local BUTTON_WIDHT = 304
local BUTTON_HEIGHT = 92

function MatchRoomAIView:ctor()
	-- body
	self:setTouchEnabled(true)
    self:setTouchSwallowEnabled(true)
	self:createNode_()
end
function MatchRoomAIView:createNode_()

	display.newScale9Sprite("ai_line.png",0, 0, cc.size(display.width,LINE_WIDTH))
	:addTo(self)
	:pos(display.width/2, display.bottom+LINE_WIDTH/2)



	display.newScale9Sprite("ai_cancel_btn.png",0, 0, cc.size(BUTTON_WIDHT,BUTTON_HEIGHT))
	:addTo(self)
	:pos(display.width/2 - 50, display.bottom+LINE_WIDTH/2)

	display.newSprite("ai_cancel_btn_title.png")
	:addTo(self)
	:align(display.CENTER)
	:pos(display.width/2 - 50, display.bottom+LINE_WIDTH/2 + 5)

	display.newSprite("#poker_girl.png")
	:addTo(self)
	:align(display.CENTER)
	:pos(display.right- 200, display.bottom+150)

	cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#rounded_rect_10.png"}, {scale9 = true})
        :setButtonSize(BUTTON_WIDHT, BUTTON_HEIGHT)
        :onButtonClicked(buttontHandler(self, self.cancelAiBtn))
        :addTo(self)
        :pos(display.width/2 - 50, display.bottom+LINE_WIDTH/2)
end

function MatchRoomAIView:cancelAiBtn()
	nk.server:matchCancelAI()
end
function MatchRoomAIView:onCleanup()

end

return MatchRoomAIView