--
-- Author: viking@boomegg.com
-- Date: 2014-10-29 14:52:20
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

local WheelSliceView = class("WheelSliceView", function()
    return display.newNode()
end)

WheelSliceView.YELLOW = 0
WheelSliceView.PURPLE = 1

WheelSliceView.WIDTH = 149
WheelSliceView.HEIGHT = 194

-- local textColor = display.COLOR_BLACK
-- cc.c3b(0xff, 0xfe, 0xec)

local textSize = 18

function WheelSliceView:ctor(color)
    self:setNodeEventEnabled(true)
    if color ==  WheelSliceView.YELLOW then
        self.colorFrame_ = "#wheel_rotate_yellow_slice.png"
    else
        self.colorFrame_ = "#wheel_rotate_purple_slice.png"
    end

    self:setupView(color)
end

function WheelSliceView:setupView(colorType)
    --颜色背景
    self.bg = display.newSprite(self.colorFrame_):addTo(self)
    self.bg:setAnchorPoint(cc.p(0.5, 0))
    -- self.bg:rotation(180)

    --文字描述
    local descLabelTop = 40
    local textColor = nil
    
    if colorType == WheelSliceView.YELLOW then
        --todo
        textColor = display.COLOR_BLACK
    else
        textColor = cc.c3b(193, 145, 50)
    end

    self.descLabel = display.newTTFLabel({
             text = "",
             size = textSize, 
             color = textColor,
             align = ui.TEXT_ALIGN_CENTER
        })
        :addTo(self.bg)
    local descLabelSize = self.descLabel:getContentSize()
    self.descLabel:pos(WheelSliceView.WIDTH/2, WheelSliceView.HEIGHT - descLabelTop - descLabelSize.height/2)

    --图片
end

function WheelSliceView:setDescText(text)
    self.descLabel:setString(text)
end

function WheelSliceView:setImageUrl(url)
    local fileName = "#" .. url
    local iconMarginBottom = 20
    self.icon = display.newSprite(fileName)
        :addTo(self.bg)
    self.icon:pos(WheelSliceView.WIDTH/2, WheelSliceView.HEIGHT/2 + iconMarginBottom)
    self.icon:scale(.8)
end

function WheelSliceView:onCleanup()
    
end

return WheelSliceView