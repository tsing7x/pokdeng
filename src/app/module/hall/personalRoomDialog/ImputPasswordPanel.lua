local ImputPasswordPanel = class("ImputPasswordPanel", function() return display.newNode() end)

function ImputPasswordPanel:ctor(parentNode)
	self.parentNode_ = parentNode

    self:setNodeEventEnabled(true)
    -- display.addSpriteFrames("personalRoop_th.plist", "personalRoop_th.png")

	self:createNode_()
end

function ImputPasswordPanel:createNode_()
	local BG_Y = -65

	self.background_ = display.newScale9Sprite("#per_pw_bg.png", 0, 0, cc.size(628, 202)):addTo(self)
    self.background_:setTouchEnabled(true)
    self.background_:setTouchSwallowEnabled(true)
    self.background_:pos(0,BG_Y)

	local firstNumber = {1 ,2 , 3 , 4 ,5}
	local labelPosX = -140
	local labelPosY = 320
	for i=1,5 do
        self.firstRowButton = cc.ui.UIPushButton.new({normal = "#per_ps_item_up.png", pressed = "#per_ps_item_select.png"},{scale9 = true})
        	:setButtonSize(85, 85)
            :pos(labelPosX - 110 + ( (i-1) * (82 + 16)+5) , labelPosY - 335)
            :setButtonLabel(display.newTTFLabel({text = firstNumber[i], color = styles.FONT_COLOR.GOLDEN_TEXT, size = 46, align = ui.TEXT_ALIGN_CENTER}))
            :setButtonLabelString(firstNumber[i])
            :onButtonClicked(buttontHandler(self, self.modifyInputLabel))
            :addTo(self)
    end

    cc.ui.UIPushButton.new({normal = "#per_ps_item_up.png", pressed = "#per_ps_item_select.png"},{scale9 = true})
        	:setButtonSize(85, 85)
            :pos(labelPosX - 110 + ( (6-1) * (82 + 16)+5) , labelPosY - 335)
            :setButtonLabel(display.newTTFLabel({text = "X", color = styles.FONT_COLOR.GOLDEN_TEXT, size = 46, align = ui.TEXT_ALIGN_CENTER}))
            :setButtonLabelString("X")
            :onButtonClicked(buttontHandler(self, self.onDelete_))
            :addTo(self)

    local secondNumber = {6 ,7, 8 , 9 ,0}
    for i=1,5 do
        local btn = cc.ui.UIPushButton.new({normal = "#per_ps_item_up.png", pressed = "#per_ps_item_select.png"},{scale9 = true})
            :pos(labelPosX - 110 + ( (i-1) * (82 + 16)+5) , labelPosY - 434)
            :setButtonSize(85, 85)
            :setButtonLabel(display.newTTFLabel({text = secondNumber[i], color = styles.FONT_COLOR.GOLDEN_TEXT, size = 46, align = ui.TEXT_ALIGN_CENTER}))
            :onButtonClicked(buttontHandler(self, self.modifyInputLabel))
            :addTo(self)
    end

    cc.ui.UIPushButton.new({normal = "#per_ps_item_up.png", pressed = "#per_ps_item_select.png"},{scale9 = true})
        	:setButtonSize(85, 85)
            :pos(labelPosX - 110 + ( (6-1) * (82 + 16)+5) , labelPosY - 434)
            :setButtonLabel(display.newTTFLabel({text = "OK", color = styles.FONT_COLOR.GOLDEN_TEXT, size = 46, align = ui.TEXT_ALIGN_CENTER}))
            :setButtonLabelString("OK")
            :onButtonClicked(buttontHandler(self, self.onOk_))
            :addTo(self)

end

function ImputPasswordPanel:modifyInputLabel(evt)
	local label = evt.target:getButtonLabel()
	self.parentNode_:changeBaseChip_(label)
end

function ImputPasswordPanel:onOk_()
	self.parentNode_:onOk_()
end

function ImputPasswordPanel:onDelete_()
	self.parentNode_:onDelete_()
end

function ImputPasswordPanel:onEnter()
    -- body
end

function ImputPasswordPanel:onExit()
    -- body
    -- display.removeSpriteFramesWithFile("personalRoop_th.plist", "personalRoop_th.png")
end

function ImputPasswordPanel:onCleanup()
    self:onCleanupOut()
end


function ImputPasswordPanel:onCleanupOut( ... )
    -- body
end

return ImputPasswordPanel