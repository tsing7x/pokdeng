
--
-- Author: VanfoHuang
-- Date: 2015-09-10 
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--


local LIST_ITEM_WIDTH = display.width-130
local LIST_ITEM_HEIGHT = 80

local LIST_BG_WIDTH = display.width-130
local LIST_BG_HEIGHT = 70
local LIST_ITEM_SPACE_Y = LIST_ITEM_HEIGHT - LIST_BG_HEIGHT
local POSY =  LIST_BG_HEIGHT * 0.5 + LIST_ITEM_SPACE_Y * 0.5
local LEFT_GAP = 20
local ChoosePersonalRoomItem = class("ChoosePersonalRoomItem", bm.ui.ListItem)


function ChoosePersonalRoomItem:ctor()
	self:setNodeEventEnabled(true)
    ChoosePersonalRoomItem.super.ctor(self, LIST_ITEM_WIDTH, LIST_ITEM_HEIGHT)
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
	local itemBg = display.newScale9Sprite("#perItemBg.png",0,0,cc.size(LIST_BG_WIDTH,LIST_BG_HEIGHT))
	:pos(LIST_ITEM_WIDTH*0.5,LIST_ITEM_HEIGHT*0.5 + LIST_ITEM_SPACE_Y*0.5)
	:addTo(self)



end


function ChoosePersonalRoomItem:createContent_()
	
    local totalLen = LIST_ITEM_WIDTH-20
    local itemLen = totalLen/7

	self.roomIdText = display.newTTFLabel({text = "", color = cc.c3b(0x29, 0x93, 0x2E), size = 24, align = ui.TEXT_ALIGN_CENTER})
        :align(display.LEFT_CENTER, 5, POSY)
        :addTo(self)
        --:pos(-totalLen/2,POSY)

   self.roomNameText = display.newTTFLabel({text = "", color = cc.c3b(0xcc, 0xac, 0x45), size = 24, align = ui.TEXT_ALIGN_CENTER})
    :align(display.LEFT_CENTER, 115, POSY)
    :addTo(self)
    :pos(5+itemLen - LEFT_GAP,POSY)

    self.roomBetText = display.newTTFLabel({text = "", color = cc.c3b(0xff, 0xd2, 0x00), size = 24, align = ui.TEXT_ALIGN_CENTER})
    :align(display.LEFT_CENTER, 220, POSY)
    :addTo(self)
    :pos(5+2*itemLen- LEFT_GAP,POSY)
    --:pos(-totalLen/2+2*itemLen,POSY)

    self.entryLimitText = display.newTTFLabel({text = "", color = cc.c3b(0xff, 0xd2, 0x00), size = 24, align = ui.TEXT_ALIGN_CENTER})
    :align(display.LEFT_CENTER, 330, POSY)
    :addTo(self)
    :pos(5+3*itemLen- LEFT_GAP,POSY)
    --:pos(-totalLen/2+3*itemLen,POSY)

    self.serviceFeeText = 
    display.newTTFLabel({text = "", color = cc.c3b(0xff, 0xd2, 0x00), size = 24, align = ui.TEXT_ALIGN_CENTER})
    :align(display.CENTER, 445, POSY)
    :addTo(self)
    :pos(5+4*itemLen- LEFT_GAP-20,POSY)
    --:pos(-totalLen/2+4*itemLen,POSY)

    self.locker = display.newSprite("#perLocker.png")
    :align(display.LEFT_CENTER, 527, POSY)
    :addTo(self)
    :pos(5+5*itemLen - 60- LEFT_GAP,POSY)
    --:pos(-totalLen/2+5*itemLen,POSY)

    self.playerNumProgBar_ = nk.ui.ProgressBar.new(
        "#perSliderBg.png", 
        "#perSliderFg.png", 
        {
            bgWidth = 125, 
            bgHeight = 35, 
            fillWidth = 35, 
            fillHeight = 35
        }
    )
    :align(display.LEFT_CENTER, 585, POSY)
    :addTo(self)
    :pos(5+5*itemLen-10,POSY)
    --:pos(-totalLen/2+6*itemLen,POSY)
    :setValue(0.8)

    self.playerNumText = display.newTTFLabel({text = "", color = cc.c3b(0xff, 0xff, 0xff), size = 24, align = ui.TEXT_ALIGN_CENTER,dimensions = cc.size(125,35)})
    :align(display.LEFT_CENTER, 580, POSY)
    :addTo(self)
    :pos(5+5*itemLen-15,POSY)

    local joinBtnBg = display.newScale9Sprite("#perGreenBtn.png",0,0,cc.size(115,48))
    :align(display.LEFT_CENTER, 725, POSY)
    :addTo(self)
    :pos(5+6*itemLen+4,POSY)

    self.joinBtn = cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#rounded_rect_10.png"}, {scale9 = true})
        :setButtonSize(123, 50)
        :align(display.LEFT_CENTER, 723, POSY)
        :pos(5+6*itemLen,POSY)
        :setButtonLabel(display.newTTFLabel({text=bm.LangUtil.getText("HALL", "PERSONAL_ROOM_ENTER"), size=24, color=cc.c3b(0xff, 0xff, 0xff), align=ui.TEXT_ALIGN_CENTER}))
        :addTo(self)
        :onButtonClicked(buttontHandler(self, self.onJoinBtnClicked))


end


function ChoosePersonalRoomItem:onJoinBtnClicked()
     self:dispatchEvent({name="ITEM_EVENT", data = self.data_})

end



function ChoosePersonalRoomItem:onDataSet(dataChanged, data)
    self.dataChanged_ = self.dataChanged_ or dataChanged
    self.data_ = data
end



function ChoosePersonalRoomItem:setData_(data)
    -- data = {}
    -- data.isAnim = true
    if type(data) == "table" and data.isAnim and not self.hasAnim then
        self.hasAnim = true
        -- transition.fadeIn(self, {time = 2})

        -- dump("ChoosePersonalRoomItem=================================")
    end



    self.roomIdText:setString(data.tableID or "")
    local baseChip_ = bm.formatBigNumber(data.baseChip)
    self.roomBetText:setString(baseChip_ or "")
    

    local name = nk.Native:getFixedWidthText("", 24, data.roomName or "", (LIST_ITEM_WIDTH-20)/8 - 10)
    self.roomNameText:setString(name)

    local minAnte_ = bm.formatBigNumber(data.minAnte)
    self.entryLimitText:setString(minAnte_ or "")
    
    local free_ = bm.formatBigNumber(data.fee)

    self.serviceFeeText:setString(free_ or "")
    self.playerNumProgBar_:setValue(data.userCount/9 or 0)
    self.playerNumText:setString(data.userCount .. "/9" or "0/9")
    if data.hasPwd == 1 then
        self.locker:show()
    else
        self.locker:hide()

    end
    

end





function ChoosePersonalRoomItem:lazyCreateContent()
	if not self.created_ then
        self.created_ = true
        self:createContent_()
    end


    if self.dataChanged_ then
        self.dataChanged_ = false
        self:setData_(self.data_)
    end

end

return ChoosePersonalRoomItem
