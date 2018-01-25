--
-- Author: viking@boomegg.com
-- Date: 2014-12-01 10:37:48
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--
local HelpPopup = class("HelpPopup", function()
    return display.newNode()
end)

local HelpPopupItem = import(".HelpPopupItem")

HelpPopup.WIDTH = 612
HelpPopup.HEIGHT = 402

local configTable = {
    {{"A", "A", "A"}, "100"}, {{"B", "B", "B"}, "50"},
    {{"C", "C", "C"}, "20"},  {{"D", "D", "D"}, "10"},
    {{"E", "E", "E"}, "8"},   {{"F", "F", "F"}, "7"},
    {{"G", "G", "G"}, "6"},      {{"H", "H", "H"}, "5"},
    {{"I", "I", "I"}, "4"},   {{"J", "J", "J"}, "3"},
    {{"A", "A", "X"}, "9"},   {{"B", "B", "X"}, "8"},
    {{"C", "C", "X"}, "7"},   {{"X", "A", "A"}, "6"},
    {{"X", "B", "B"}, "5"},   {{"X", "C", "C"}, "4"},
    {{"A", "X", "A"}, "5"},   {{"B", "X", "B"}, "4"},
    {{"C", "X", "C"}, "3"},   {{"Y", "Y", "X"}, "2"},
    {{"X", "Y", "Y"}, "2"},   {{"Y", "X", "Y"}, "2"}
}

function HelpPopup:ctor(blind)
    self.blind_ = blind
    self:setupView()
end

function HelpPopup:setupView()
    --背景
    display.newSprite("#slot_help_bg.png"):addTo(self):setTouchEnabled(true)

    --标题
    local titleWidth = 212
    local titleHeight = 33
    local titleMarginTop = 5
    local posY = HelpPopup.HEIGHT/2
    display.newSprite("#slot_help_title.png"):addTo(self):pos(0, posY - titleHeight/2 - titleMarginTop)

    --奖励计算描述
    local tips1Width = 222
    local tips1Height = 19
    local tips1MarginTop = 5
    local tips2Width = 172
    local tips2Height = 23
    local tips2MarginTop = 5
    posY = posY - titleHeight - titleMarginTop
    display.newSprite("#slot_help_tips1.png"):addTo(self):pos(0, posY - tips1Height/2 - tips1MarginTop)
    posY = posY - tips1Height - tips1MarginTop
    display.newSprite("#slot_help_tips2.png"):addTo(self):pos(0, posY - tips2Height/2 - tips2MarginTop)

    local blind = bm.formatBigNumber(self.blind_) .. " * "

    --大条目
    posY = posY - tips2Height - tips2MarginTop
    local helpBigItemPadding = 16
    local helpBigItemMarginTop = 4
    HelpPopupItem.new(configTable[1][1], blind .. configTable[1][2], true):addTo(self)
        :pos(-HelpPopupItem.BIG_WIDTH/2 - helpBigItemPadding, posY - HelpPopupItem.BIG_HEIGHT/2 - helpBigItemMarginTop)
    HelpPopupItem.new(configTable[2][1], blind .. configTable[2][2], true):addTo(self)
        :pos(HelpPopupItem.BIG_WIDTH/2 + helpBigItemPadding, posY - HelpPopupItem.BIG_HEIGHT/2 - helpBigItemMarginTop)

    --小条目
    posY = posY - HelpPopupItem.BIG_HEIGHT - helpBigItemMarginTop
    local helpSmallItemPadding = 16
    local helpSmallItemMarginTop = 4
    for i = 3, 18, 3 do
        HelpPopupItem.new(configTable[i][1], blind .. configTable[i][2]):addTo(self)
            :pos(-HelpPopupItem.SMALL_WIDTH * 2/2 - helpSmallItemPadding, posY - HelpPopupItem.SMALL_HEIGHT/2 - helpSmallItemMarginTop)
        HelpPopupItem.new(configTable[i + 1][1], blind .. configTable[i + 1][2]):addTo(self)
            :pos(0, posY - HelpPopupItem.SMALL_HEIGHT/2 - helpSmallItemMarginTop)
        HelpPopupItem.new(configTable[i + 2][1], blind .. configTable[i + 2][2]):addTo(self)
            :pos(HelpPopupItem.SMALL_WIDTH * 2/2 + helpSmallItemPadding, posY - HelpPopupItem.SMALL_HEIGHT/2 - helpSmallItemMarginTop)    
        posY = posY - HelpPopupItem.SMALL_HEIGHT - helpSmallItemMarginTop
    end
    HelpPopupItem.new(configTable[21][1], blind .. configTable[21][2]):addTo(self)
        :pos(-HelpPopupItem.SMALL_WIDTH * 2/2 - helpSmallItemPadding, posY - HelpPopupItem.SMALL_HEIGHT/2 - helpSmallItemMarginTop)
    HelpPopupItem.new(configTable[22][1], blind .. configTable[22][2]):addTo(self)
        :pos(0, posY - HelpPopupItem.SMALL_HEIGHT/2 - helpSmallItemMarginTop)

    --关闭按钮
    local closeBtnWidth = 58
    local closeBtnHeight = 59
    local closeBtnPadding = 5
    cc.ui.UIPushButton.new({normal = "#panel_black_close_btn_up.png", pressed = "#panel_black_close_btn_down.png"})
        :onButtonClicked(buttontHandler(self, self.onCloseBtnListener_))
        :addTo(self)
        :pos(HelpPopup.WIDTH/2, HelpPopup.HEIGHT/2)
end

function HelpPopup:onCloseBtnListener_()
    self:hide()
end

function HelpPopup:show()
    nk.PopupManager:addPopup(self)
end

function HelpPopup:hide()
    nk.PopupManager:removePopup(self)
end

return HelpPopup