--
-- Author: viking@boomegg.com
-- Date: 2014-11-25 11:29:53
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--
local BetChip = class("BetChip", function()
    return display.newNode()
end)

BetChip.WIDTH = 54
BetChip.HEIGHT = 54

function BetChip:ctor(params)
    local normalTexture_ = params.normal
    local glowTexture_ = params.glow
    local text_ = params.text or ""
    self.callback_ = params.callback

    --触摸区域
    local touchNode_ = display.newScale9Sprite("#transparent.png"):size(BetChip.WIDTH, BetChip.HEIGHT):addTo(self)
    bm.TouchHelper.new(touchNode_, handler(self, self.onClickListener_))

    --未被选择
    local normalMarginTop = - 5
    local normalChipPosXFix = 3
    self.normalChips_ = display.newSprite(normalTexture_):addTo(self):pos(normalChipPosXFix, normalMarginTop)

    --选择状态
    local glowMarginTop = -2
    self.glowChips_ = display.newSprite(glowTexture_):addTo(self):hide():pos(0, glowMarginTop)

    --下注数
    self.betLabel_ = display.newTTFLabel({
             text = text_,
             size = 18, 
             color = cc.c3b(0xff, 0xff, 0xff),
             align = ui.TEXT_ALIGN_CENTER
        })
        :addTo(self)
end

function BetChip:setBetLabel(bet)
    self.bet_ = bet
    self.betLabel_:setString(bm.formatBigNumber(bet))
end

function BetChip:getBet()
    return self.bet_ or 0
end

function BetChip:setGlow(isGlow)
    self.normalChips_:setVisible(not isGlow)
    self.glowChips_:setVisible(isGlow)
end

function BetChip:onClickListener_(target, evt)
    if evt == bm.TouchHelper.TOUCH_BEGIN then
        
    elseif evt == bm.TouchHelper.TOUCH_END then
        
    elseif evt == bm.TouchHelper.CLICK then
        print("BetChip:onClickListener_")
        nk.SoundManager:playSound(nk.SoundManager.SLOT_BET)
        self.callback_(self)
    end
end

return BetChip