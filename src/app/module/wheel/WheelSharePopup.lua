--
-- Author: viking@boomegg.com
-- Date: 2014-10-31 15:00:13
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

local WheelSharePopup = class("WheelSharePopup", function()
    return display.newNode()
end)

WheelSharePopup.WIDTH = 604 --520
WheelSharePopup.HEIGHT = 300 --256

-- local textColor = cc.c3b(0x1b, 0x1f, 0x28)
-- local shareColor = cc.c3b(0x49, 0x68, 0x06)
-- local textSize = 22
-- local bigSize = 32

function WheelSharePopup:ctor(item, parentNode)
    -- dump(item,"WheelSharePopup:ctor")
    self.item_ = item
    self.parentNode_ = parentNode
    self:setupView()
end

function WheelSharePopup:setupView()
    --背景
    -- if nk.config.SONGKRAN_THEME_ENABLED then
    --     display.newSprite("#songkran_wheel_bg_small.png"):addTo(self):setTouchEnabled(true)
    -- else
    --     display.newSprite("#wheel_share_popup_bg.png"):addTo(self):setTouchEnabled(true)
    -- end

    self.background_ = display.newScale9Sprite("#wheel_bgBlue.png", 0, 0, cc.size(WheelSharePopup.WIDTH, WheelSharePopup.HEIGHT))
        :addTo(self)
    self.background_:setTouchEnabled(true)

    local closeBtnSize = {
        width = 54,
        height = 52
    }

    local closeBtnPosAdjust = {
        x = 15,
        y = 20
    }

    local closeBtn = cc.ui.UIPushButton.new("#wheel_btnClose.png")
        :onButtonClicked(function()
            -- body
            nk.SoundManager:playSound(nk.SoundManager.CLOSE_BUTTON)
            self:onCloseBtnListener_()
        end)
        :pos(WheelSharePopup.WIDTH - closeBtnSize.width + closeBtnPosAdjust.x,
            WheelSharePopup.HEIGHT - closeBtnSize.height + closeBtnPosAdjust.y)
        :addTo(self.background_)

    local rewardIconMagrinTop = 65
    local url = self.item_.url or "wheel_share_popup_fg.png"
    local rewardIcon = display.newSprite("#" .. url)
    rewardIcon:pos(WheelSharePopup.WIDTH / 2, WheelSharePopup.HEIGHT - rewardIconMagrinTop - rewardIcon:getContentSize().height / 2)
        :addTo(self.background_)
    rewardIcon:scale(1.2)

    local descBottomLabelParam = {
        frontSize = 25,
        color = cc.c3b(0x8d, 0x8c, 0x8c)
    }

    local descBottomLabelPaddingBottom = 120
    local descBottomLabel = display.newTTFLabel({text = bm.LangUtil.formatString(bm.LangUtil.getText("WHEEL", "REWARD")[2], self.item_.desc), size = descBottomLabelParam.frontSize,
        color = descBottomLabelParam.color, algin = ui.TEXT_ALIGN_CENTER})
    descBottomLabel:pos(WheelSharePopup.WIDTH / 2, descBottomLabelPaddingBottom + descBottomLabel:getContentSize().height / 2)
        :addTo(self.background_)

    local shareBtnSize = {
        width = 225,
        height = 65
    }

    local shareBtnLabelParam = {
        frontSize = 36,
        color = cc.c3b(193, 145, 50)
    }

    local shareBtnMagrinBottom = 35
    self.shareBtn = cc.ui.UIPushButton.new("#wheel_btnShare.png", {scale9 = true})
        :setButtonSize(shareBtnSize.width, shareBtnSize.height)
        :setButtonLabel(display.newTTFLabel({text = bm.LangUtil.getText("WHEEL", "SHARE"), size = shareBtnLabelParam.frontSize,
            color = shareBtnLabelParam.color, align = ui.TEXT_ALIGN_CENTER}))
        :onButtonClicked(buttontHandler(self, self.onShareBtnListener_))
        :pos(WheelSharePopup.WIDTH / 2, shareBtnMagrinBottom + shareBtnSize.height / 2)
        :addTo(self.background_)

    -- --关闭按钮
    -- local closeBtnWidth = 60
    -- local closeBtnHeight = 60
    -- local closeBtnMarginTop = 0
    -- local closeBtnMarginRight = 0
    -- cc.ui.UIPushButton.new({normal = "#wheel_close_btn_up.png", pressed = "#wheel_close_btn_down.png"})
    --     :addTo(self)
    --     :pos((WheelSharePopup.WIDTH - closeBtnWidth)/2 - closeBtnMarginRight, (WheelSharePopup.HEIGHT - closeBtnHeight)/2 - closeBtnMarginTop)
    --     :onButtonClicked(function()
    --             nk.SoundManager:playSound(nk.SoundManager.CLOSE_BUTTON)
    --             self:onCloseBtnListener_()
    --         end)

    -- --中奖文字
    -- local rewards = bm.LangUtil.getText("WHEEL", "REWARD")
    -- local labelMarginLeft = 36
    -- local label1MarginTop = 40
    -- local rewardLabel1 = display.newTTFLabel({
    --          text = rewards[1],
    --          size = textSize,
    --          color = textColor,
    --          align = ui.TEXT_ALIGN_CENTER
    --     })
    --     :addTo(self)
    -- local rewardLabel1Size = rewardLabel1:getContentSize()
    -- rewardLabel1:pos(labelMarginLeft, WheelSharePopup.HEIGHT/2 - rewardLabel1Size.height/2 - label1MarginTop)

    -- local label2MarginTop = 2
    -- local rewardLabel2 = display.newTTFLabel({
    --          text = bm.LangUtil.formatString(rewards[2], self.item_.desc),
    --          size = textSize,
    --          color = textColor,
    --          align = ui.TEXT_ALIGN_CENTER
    --     })
    --     :addTo(self)
    -- local rewardLabel2Size = rewardLabel2:getContentSize()
    -- rewardLabel2:pos(labelMarginLeft, rewardLabel1:getPositionY() - rewardLabel1Size.height/2 - rewardLabel2Size.height/2 - label2MarginTop)

    -- --奖品图片
    -- local url = self.item_.url
    -- local picMarginTop = 70
    -- if  url == "wheel_reward_7.png" or url == "wheel_reward_8.png" then
    --     picMarginTop = 80
    -- end
    -- local picFrame_ = "#" .. url
    -- local picMarginLeft = 100
    -- local picSprite = display.newSprite(picFrame_)
    --     :addTo(self)
    --     :scale(1.2)
    -- local picSize = picSprite:getContentSize()
    -- picSprite:pos(-WheelSharePopup.WIDTH/2 + picSize.width/2 + picMarginLeft, WheelSharePopup.HEIGHT/2 - picSize.height/2 - picMarginTop+30)

    -- --背景饰品
    -- if nk.config.CHRISTMAS_THEME_ENABLED then
    --     local bgDecoration1Top = 60
    --     local bgDecoration1Left = 20
    --     local bgDecoration1Width = 38
    --     local bgDecoration1Height = 38
    --     display.newSprite("#wheel_bg_decoration3.png")
    --         :pos(-WheelSharePopup.WIDTH/2 + bgDecoration1Width/2 + bgDecoration1Left, WheelSharePopup.HEIGHT/2 - bgDecoration1Height/2 - bgDecoration1Top)
    --         :addTo(self)

    --     local bgDecoration2Bottom = 100
    --     local bgDecoration2Right = 160
    --     local bgDecoration2Width = 38
    --     local bgDecoration2Height = 38
    --     display.newSprite("#wheel_bg_decoration3.png")
    --         :pos(WheelSharePopup.WIDTH/2 - bgDecoration2Width/2 - bgDecoration2Right, -WheelSharePopup.HEIGHT/2 + bgDecoration2Height/2 + bgDecoration2Bottom)
    --         :addTo(self)

    --     local bgDecoration3Bottom = 70
    --     local bgDecoration3Right = 70
    --     local bgDecoration3Width = 45
    --     local bgDecoration3Height = 82
    --     display.newSprite("#wheel_bg_decoration2.png")
    --         :pos(WheelSharePopup.WIDTH/2 - bgDecoration3Width/2 - bgDecoration3Right, -WheelSharePopup.HEIGHT/2 + bgDecoration3Height/2 + bgDecoration3Bottom)
    --         :addTo(self)


    --     --前景饰品
    --     local fgDecoration1Left = 10
    --     local fgDecoration1Bottom = 4
    --     local fgDecoration1Width = 220
    --     local fgDecoration1Height = 111
    --     display.newSprite("#wheel_share_popup_fg.png")
    --         :pos(-WheelSharePopup.WIDTH/2 + fgDecoration1Width/2 + fgDecoration1Left, -WheelSharePopup.HEIGHT/2 + fgDecoration1Height/2 + fgDecoration1Bottom)
    --         :addTo(self)

    --     local fgDecoration2Left = 32
    --     local fgDecoration2Bottom = 3
    --     local fgDecoration2Width = 62
    --     local fgDecoration2Height = 62
    --     display.newSprite("#wheel_fg_decoration1.png")
    --         :pos(-WheelSharePopup.WIDTH/2 + fgDecoration2Width/2 + fgDecoration2Left, -WheelSharePopup.HEIGHT/2 + fgDecoration2Height/2 + fgDecoration2Bottom)
    --         :addTo(self)

    --     local fgDecoration3Left = 210
    --     local fgDecoration3Bottom = 16
    --     local fgDecoration3Width = 103
    --     local fgDecoration3Height = 103
    --     display.newSprite("#wheel_fg_decoration4.png")
    --         :pos(-WheelSharePopup.WIDTH/2 + fgDecoration3Width/2 + fgDecoration3Left, -WheelSharePopup.HEIGHT/2 + fgDecoration3Height/2 + fgDecoration3Bottom)
    --         :addTo(self)

    --     local fgDecoration4Left = 160
    --     local fgDecoration4Bottom = -18
    --     local fgDecoration4Width = 103
    --     local fgDecoration4Height = 103
    --     local fgDecoration4Scale = 0.7
    --     display.newSprite("#wheel_fg_decoration5.png")
    --         :pos(-WheelSharePopup.WIDTH/2 + fgDecoration4Width/2 + fgDecoration4Left, -WheelSharePopup.HEIGHT/2 + fgDecoration4Height/2 + fgDecoration4Bottom)
    --         :addTo(self)
    --         :scale(fgDecoration4Scale)
    -- end

    -- display.newTTFLabel({
    --          text = bm.LangUtil.getText("WHEEL", "SHARE_BOTTOM_TIP2")[2],
    --          size = 18,
    --          color = cc.c3b(0xff, 0xff, 0xff),
    --          align = ui.RIGHT_BOTTOM,
    --          valign = ui.TEXT_VALIGN_CENTER,
    --          dimensions = cc.size(450, 0)
    --     })
    --     :addTo(self)
    --     :pos(30,-115)

    -- if nk.config.SONGKRAN_THEME_ENABLED then
    --     local giftLeft = 120
    --     local giftTop = 70
    --     display.newSprite("#songkran_wheel_gift.png")
    --         :pos(-WheelSharePopup.WIDTH/2 + giftLeft, -WheelSharePopup.HEIGHT/2 + giftTop+20)
    --         :addTo(self)
    -- end

    -- if nk.config.SONGKRAN_THEME_ENABLED then
    --     --分享按钮
    --     local shareBtnRight = 28
    --     local shareBtnBottom = 12
    --     local shareBtnWidth = 194
    --     local shareBtnHeight = 58
    --     local shareBtnTextOx = 0
    --     local shareBtnTextOy = 5
    --     self.shareBtn = cc.ui.UIPushButton.new({normal = "#songkran_wheel_btn_small_normal.png", pressed = "#songkran_wheel_btn_small_pressed.png"})
    --         :setButtonLabel(display.newTTFLabel({
    --              text = bm.LangUtil.getText("WHEEL", "SHARE").." + 1",
    --              size = 28,
    --              color = shareColor,
    --              align = ui.TEXT_ALIGN_CENTER
    --         }))
    --         :setButtonLabelOffset(shareBtnTextOx, shareBtnTextOy)
    --         :addTo(self)
    --         :pos(WheelSharePopup.WIDTH/2 - shareBtnWidth/2 - shareBtnRight, -WheelSharePopup.HEIGHT/2 + shareBtnHeight/2 + shareBtnBottom+20)
    --         :onButtonClicked(buttontHandler(self, self.onShareBtnListener_))
    -- else
    --     --分享按钮
    --     local shareBtnRight = 28
    --     local shareBtnBottom = 12
    --     local shareBtnWidth = 194
    --     local shareBtnHeight = 58
    --     local shareBtnTextOx = 0
    --     local shareBtnTextOy = 5
    --     self.shareBtn = cc.ui.UIPushButton.new({normal = "#wheel_share_popup_btn_up.png", pressed = "#wheel_share_popup_btn_down.png"})
    --         :setButtonLabel(display.newTTFLabel({
    --              text = bm.LangUtil.getText("WHEEL", "SHARE"),
    --              size = bigSize,
    --              color = shareColor,
    --              align = ui.TEXT_ALIGN_CENTER
    --         }))
    --         :setButtonLabelOffset(shareBtnTextOx, shareBtnTextOy)
    --         :addTo(self)
    --         :pos(WheelSharePopup.WIDTH/2 - shareBtnWidth/2 - shareBtnRight, -WheelSharePopup.HEIGHT/2 + shareBtnHeight/2 + shareBtnBottom+20)
    --         :onButtonClicked(buttontHandler(self, self.onShareBtnListener_))
    -- end
end

function WheelSharePopup:onCloseBtnListener_()
    self:hide()
end

function WheelSharePopup:onShareBtnListener_()
    print("WheelSharePopup:onShareBtnListener_")
    self.shareBtn:setButtonEnabled(false)
    -- local feedData = clone(bm.LangUtil.getText("FEED", "WHEEL_ACT"))
    --  --feedData.name = bm.LangUtil.formatString(feedData.name, self.item_.desc)
    --  nk.Facebook:shareFeed(feedData, function(success, result)
    --      print("FEED.WHEEL_REWARD result handler -> ", success, result)
    --      if not success then
    --          self.shareBtn:setButtonEnabled(true)
    --          nk.TopTipManager:showTopTip(bm.LangUtil.getText("FEED", "SHARE_FAILED"))
    --      else
    --          self.parentNode_.controller_:shareToGetChance()
    --          nk.TopTipManager:showTopTip(bm.LangUtil.getText("FEED", "SHARE_SUCCESS"))
    --      end
    --  end)
     nk.sendFeed:wheel_act_(
        function()
          self.parentNode_.controller_:shareToGetChance()
          self:hide()
        end,
        function()
           self.shareBtn:setButtonEnabled(true)
           self:hide()
        end)
end

function WheelSharePopup:show()
    nk.PopupManager:addPopup(self)
    return self
end

function WheelSharePopup:onShowed()
end

function WheelSharePopup:hide()
    nk.PopupManager:removePopup(self)
    return self
end

return WheelSharePopup
