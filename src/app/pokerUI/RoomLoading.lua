--
-- Author: johnny@boomegg.com
-- Date: 2014-08-12 20:58:45
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

local RoomLoading = class("RoomLoading", function()
    return display.newNode()
end)

function RoomLoading:ctor(tip)
    self:setTouchEnabled(true)

    -- 透明触摸层
    local transparentSkin = display.newSprite("#common_transparent_skin.png")
        :addTo(self)
    transparentSkin:setScaleX(display.width / 4)
    transparentSkin:setScaleY(display.height / 4)

    -- 背景
    local bg = display.newSprite("#full_screen_tip_bg.png")
        :addTo(self)
    bg:setScaleX((display.width) / bg:getContentSize().width)

    -- 筹码动画
    local frames = display.newFrames("loading_chip_%d.png", 1, 12)
    local animation = display.newAnimation(frames, 1 / 12)
    local animSprite = display.newSprite(animation[1])
        :pos(0, 44)
        :addTo(self)
    animSprite:playAnimationForever(animation, 0)

    -- 文字
    display.newTTFLabel({text = tip, color = styles.FONT_COLOR.LIGHT_TEXT, size = 28, align = ui.TEXT_ALIGN_CENTER})
        :pos(0, -50)
        :addTo(self)
end

return RoomLoading