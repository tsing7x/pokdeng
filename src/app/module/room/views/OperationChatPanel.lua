--
-- Author: TsingZhang@boyaa.com
-- Date: 2016-01-04 12:35:10
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- Description: OperationChatPanel.lua By tsing.
--

local ChatMsgPanel = import(".ChatMsgPanel")  -- ????
local ExpressionPanel = import(".ExpressionPanel")
local SuonaUsePopup = import("app.module.suona.SuonaUsePopup")

local OperationChatPanel = class("OperationChatPanel", function()
	-- body
	return display.newNode()
end)

function OperationChatPanel:ctor(ctx)
	-- body
	local chatW = math.round(display.width * 0.3)
    -- local padding = math.round((display.width * 0.05 - 16) / 4)

    display.newScale9Sprite("#room_chat_btn_group_background.png", chatW * 0.5, 38, cc.size(chatW, 72)):addTo(self)
    -- display.newSprite("#room_chat_btn_group_split.png", 80, 36):addTo(self.chatNode_)

    local chatMsgInputBtn = cc.ui.UIPushButton.new("#transparent.png", {scale9=true})
        :setButtonSize(chatW - 86, 72)
        :setButtonLabel("normal", display.newScale9Sprite("#room_chat_btn_group_input_up.png", 0, 0, cc.size(chatW - 70 - 6, 72 - 12)))
        :setButtonLabel("pressed", display.newScale9Sprite("#room_chat_btn_group_input_down.png", 0, 0, cc.size(chatW - 70 - 6, 72 - 12)))
        :onButtonClicked(function()
                nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
                --if not self.chatPanel_ then
                    self.chatPanel_ = ChatMsgPanel.new(ctx)
                --    self.chatPanel_:retain()
                --end
                self.chatPanel_:showPanel()
            end)
        :pos(16 + (chatW - 86 - 6) * 0.5, 38)
        :addTo(self)

    local suonaBgSize = {
        width = 58,
        height = 58
    }

    local suonaIcBg = display.newScale9Sprite("#bg_chatMsgSuona_dent.png", - (chatW - 86 - 16) / 2 + suonaBgSize.width / 2 - 11,
        0, cc.size(suonaBgSize.width, suonaBgSize.height))
        :addTo(chatMsgInputBtn)

    local suonaUseIcon = display.newSprite("#suona_icon.png")
        :pos(suonaBgSize.width / 2, suonaBgSize.height / 2)
        :addTo(suonaIcBg)

    local suonaUseBtn = cc.ui.UIPushButton.new("#transparent.png", {scale9 = true})
        :setButtonSize(suonaBgSize.width, suonaBgSize.height)
        :onButtonClicked(function()
            -- body
            SuonaUsePopup.new():show()
        end)
        :pos(suonaBgSize.width / 2, suonaBgSize.height / 2)
        :addTo(suonaIcBg)

    cc.ui.UIPushButton.new("#transparent.png", {scale9=true})
        :setButtonSize(86, 72)
        :setButtonLabel("normal", display.newSprite("#room_chat_btn_expression_down_icon.png"))
        :setButtonLabel("pressed", display.newSprite("#room_chat_btn_expression_up_icon.png"))
        :onButtonClicked(function()
                nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
                --if not self.expressionPanel_ then
                    self.expressionPanel_ = ExpressionPanel.new(ctx)
                --    self.expressionPanel_:retain()
                --end
                self.expressionPanel_:showPanel()
            end)
        :pos(86 / 2 + (chatW - 86 - 6) + 16, 40)
        :addTo(self)

    self.latestChatMsg_ = display.newTTFLabel({size=20,
            color=cc.c3b(106, 106, 106), 
            dimensions = cc.size(chatW - 76 - 58 - 16, 60),
            align=ui.TEXT_ALIGN_LEFT,
            text=""})

    self.latestChatMsg_:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER_LEFT])
    self.latestChatMsg_:pos(58 + 16, 38)
        :addTo(self)
end

function OperationChatPanel:updateChatInfo(chatStr)
	-- body
	self.latestChatMsg_:setString(chatStr)
end

return OperationChatPanel