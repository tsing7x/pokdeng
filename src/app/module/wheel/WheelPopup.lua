--
-- Author: viking@boomegg.com
-- Date: 2014-10-28 11:11:39
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

local WheelPopup = class("WheelPopup", function()
    return display.newNode()
end)

local WheelController = import(".WheelController")
local WheelView = import(".WheelView")
local WheelSharePopup = import(".WheelSharePopup")

WheelPopup.WIDTH  = 786
WheelPopup.HEIGHT = 478

-- local whileColor = cc.c3b(0xff, 0xff, 0xff)
-- local numberColor = cc.c3b(0xfb, 0xa6, 0x4c)
-- local playBtnColor = cc.c3b(0x49, 0x68, 0x06)
-- local sliceColor = cc.c3b(0xff, 0xfa, 0xa6)
-- local shareColor = cc.c3b(0x49, 0x68, 0x06)
-- local leftNumColor = cc.c3b(0x00, 0x69, 0x9c)
-- local largeSize = 36
-- local bigSize = 32
-- local middleSize = 24
-- local smallSize = 18

function WheelPopup:ctor()
    self:setNodeEventEnabled(true)
    self.controller_ = WheelController.new(self)
    self:setupView()
end

function WheelPopup:setupView()

    --大背景
    -- if nk.config.SONGKRAN_THEME_ENABLED then
    --     display.newSprite("#songkran_wheel_bg.png"):addTo(self):setTouchEnabled(true)
    -- else
    --     display.newSprite("#wheel_bg.png"):addTo(self):setTouchEnabled(true)
    -- end

    self.background_ = display.newScale9Sprite("#wheel_bgBlue.png", 0, 0, 
        cc.size(WheelPopup.WIDTH, WheelPopup.HEIGHT))
        :addTo(self)
    self.background_:setTouchEnabled(true)
    -- self.background_:setTouchSwallowEnabled(true)
    -- Title Area --
    local bgTitlePosYAdjust = 32
    local bgTitle = display.newSprite("#wheel_bgDent_Title.png")
        :pos(WheelPopup.WIDTH / 2, WheelPopup.HEIGHT - bgTitlePosYAdjust)
        :addTo(self.background_)

    local titleWordMagrinTop = - 15
    local titleWord = display.newSprite("#wheel_bgTitleWord.png")
    titleWord:pos(WheelPopup.WIDTH / 2, WheelPopup.HEIGHT - titleWord:getContentSize().height / 2 - titleWordMagrinTop)
        :addTo(self.background_)

    -- CloseBtn
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
            nk.SoundManager:playSound(nk.SoundManager.CLOSE_BUTTON)
            self:onCloseBtnListener_()
        end)
        :pos(WheelPopup.WIDTH - closeBtnSize.width + closeBtnPosAdjust.x, 
            WheelPopup.HEIGHT - closeBtnSize.height + closeBtnPosAdjust.y)
        :addTo(self.background_)

    local playTimesLabelParam = {
        frontSize = 32,
        color = display.COLOR_WHITE
    }

    local playTimesLabelPosAdjust = {
        x = 50,
        y = 8
    }
    self.playTimesRem = display.newTTFLabel({text = "0", size = playTimesLabelParam.frontSize, color = playTimesLabelParam.color,
        align = ui.TEXT_ALIGN_CENTER})
        :pos(WheelPopup.WIDTH / 2 + playTimesLabelPosAdjust.x, titleWord:getPositionY() - playTimesLabelPosAdjust.y)
        :addTo(self.background_)

    -- local closeBtnMarginTop = 60
    -- local closeBtnMarginRight = 0
    -- local closeBtnWidth = 60
    -- local closeBtnHeight = 60
    -- cc.ui.UIPushButton.new({normal = "#wheel_close_btn_up.png", pressed = "#wheel_close_btn_down.png"})
    --     :addTo(self)
    --     :pos((WheelPopup.WIDTH - closeBtnWidth)/2 - closeBtnMarginRight, (WheelPopup.HEIGHT - closeBtnHeight)/2 - closeBtnMarginTop)
    --     :onButtonClicked(function()
    --             nk.SoundManager:playSound(nk.SoundManager.CLOSE_BUTTON)
    --             self:onCloseBtnListener_()
    --         end)

    -- infoPanel Area --
    local bgDentSize = {
        width = 758,
        height = 320
    }
    local bgDentPosYShift = 35
    local bgDent = display.newScale9Sprite("#wheel_bgDent.png", WheelPopup.WIDTH / 2,
        WheelPopup.HEIGHT / 2 - bgDentPosYShift, cc.size(bgDentSize.width, bgDentSize.height))
        :addTo(self.background_)

    -- local bgDentSize = bgDent:getContentSize()

    --平板背景
    -- local planeMarginLeft = -4
    -- local planeMarginBottom = -30
    -- local planeWidth = WheelPopup.WIDTH + 10
    -- local planeHeight = 120
    -- local planeBgPosX = -WheelPopup.WIDTH/2 + planeWidth/2 + planeMarginLeft
    -- local planeBgPosY = -WheelPopup.HEIGHT/2 + planeHeight/2 - planeMarginBottom

    -- -- display.newScale9Sprite("#wheel_plane_bg.png")
    -- --     :addTo(self)
    -- --     :size(planeWidth, planeHeight)
    -- --     :pos(planeBgPosX, planeBgPosY)

    local bgInfoPanelSize = {
        width = 370,
        height = 308
    }

    local bginfoPanelPosShift = {
        x = 6,
        y = 6
    }
    local bgInfoPanel = display.newScale9Sprite("#wheel_bgBlue.png", bgDentSize.width - bgInfoPanelSize.width / 2 - bginfoPanelPosShift.x,
        bgDentSize.height - bgInfoPanelSize.height / 2 - bginfoPanelPosShift.y, cc.size(bgInfoPanelSize.width, bgInfoPanelSize.height))
        :addTo(bgDent)

    local titleColor = cc.c3b(0xe1,0xc8,0x02)
    local descColor  = cc.c3b(0x8d, 0x8c, 0x8c)
    -- local DESC_TXT = {
    --     T("每日转盘说明: "),
    --     T("1、每日最多可抽取3次"),
    --     T("2、首次转盘可直接抽取"),
    --     T("3、后续转盘每3分钟抽取1次"),
    --     "",
    --     T("当前状态:")
    -- }
    local DESC_TXT = bm.LangUtil.getText("WHEEL","DESC_LIST")
    display.newTTFLabel({text = DESC_TXT[1], size = 22,
        color = titleColor, align = ui.TEXT_ALIGN_LEFT})
        :align(display.LEFT_CENTER, 30, bgInfoPanelSize.height - 30*1)
        :addTo(bgInfoPanel)
    for i=2,5 do
        display.newTTFLabel({text = DESC_TXT[i], size = 22,
        color = descColor, align = ui.TEXT_ALIGN_LEFT})
        :align(display.LEFT_CENTER, 30, bgInfoPanelSize.height - 30*i)
        :addTo(bgInfoPanel)

    end
    display.newTTFLabel({text = DESC_TXT[6], size = 22,
        color = titleColor, align = ui.TEXT_ALIGN_LEFT})
        :align(display.LEFT_CENTER, 30, bgInfoPanelSize.height - 30*6)
        :addTo(bgInfoPanel)

    self.status_ = display.newTTFLabel({text = "", size = 36,
        color = descColor, align = ui.TEXT_ALIGN_CENTER,dimensions = cc.size(bgInfoPanelSize.width,0)})
        :align(display.CENTER, bgInfoPanelSize.width/2, bgInfoPanelSize.height - 30*8)
        :addTo(bgInfoPanel)

    -- PlayInfoTips
    -- local playInfoTips = {
    --     bm.LangUtil.getText("WHEEL", "DESC1"),
    --     {bm.LangUtil.getText("WHEEL", "DESC2_PRE"), bm.LangUtil.getText("WHEEL", "DESC2_POST")},
    --     bm.LangUtil.getText("WHEEL", "DESC3"),
    --     bm.LangUtil.getText("WHEEL", "DESC4")
    -- }

    -- local playInfoDescLabelParam = {
    --     nor = {
    --         frontSize = 22,
    --         color = cc.c3b(0x8d, 0x8c, 0x8c)
    --     },

    --     hilight = {
    --         frontSize = 35,
    --         color = {
    --             word = cc.c3b(0x8d, 0x8c, 0x8c),
    --             number = display.COLOR_WHITE
    --         }
    --     }
    -- }

    -- local infoTipsDescMagrins = {
    --     firstTop = 45,
    --     eachLine = 12
    -- }

    -- local playInfoTipsDesc1 = display.newTTFLabel({text = playInfoTips[1], size = playInfoDescLabelParam.nor.frontSize,
    --     color = playInfoDescLabelParam.nor.color, align = ui.TEXT_ALIGN_CENTER})
    -- playInfoTipsDesc1:pos(bgInfoPanelSize.width / 2, bgInfoPanelSize.height - infoTipsDescMagrins.firstTop - playInfoTipsDesc1:getContentSize().height / 2)
    --     :addTo(bgInfoPanel)

    -- local tips2DescWidth = 0

    -- local tips2DescMagrins = {
    --     firstLeft = 25,
    --     wordGap = 12
    -- }

    -- local playInfoTipsDesc2Pre = display.newTTFLabel({text = playInfoTips[2][1], size = playInfoDescLabelParam.hilight.frontSize,
    --     color = playInfoDescLabelParam.hilight.color.word, align = ui.TEXT_ALIGN_CENTER})
    -- -- playInfoTipsDesc2Pre:pos(tips2DescMagrins.firstLeft + playInfoTipsDesc2Pre:getContentSize().width / 2,
    -- --     playInfoTipsDesc1:getPositionY() - playInfoTipsDesc1:getContentSize().height / 2 - infoTipsDescMagrins.eachLine - playInfoTipsDesc2Pre:getContentSize().height / 2)
    --     :addTo(bgInfoPanel)

    -- local playInfoTipsDesc2Val = display.newTTFLabel({text = "100%", size = playInfoDescLabelParam.hilight.frontSize,
    --     color = playInfoDescLabelParam.hilight.color.number, align = ui.TEXT_ALIGN_CENTER})
    -- -- playInfoTipsDesc2Val:pos(playInfoTipsDesc2Pre:getPositionX() + playInfoTipsDesc2Pre:getContentSize().width / 2 + tips2DescMagrins.wordGap + playInfoTipsDesc2Val:getContentSize().width / 2,
    -- --     playInfoTipsDesc2Pre:getPositionY())
    --     :addTo(bgInfoPanel)

    -- local playInfoTipsDesc2Post = display.newTTFLabel({text = playInfoTips[2][2], size = playInfoDescLabelParam.hilight.frontSize,
    --     color = playInfoDescLabelParam.hilight.color.word, align = ui.TEXT_ALIGN_CENTER})
    -- -- playInfoTipsDesc2Post:pos(playInfoTipsDesc2Val:getPositionX() + playInfoTipsDesc2Val:getContentSize().width / 2 + tips2DescMagrins.wordGap + playInfoTipsDesc2Post:getContentSize().width / 2,
    -- --     playInfoTipsDesc2Pre:getPositionY())
    --     :addTo(bgInfoPanel)

    -- local tipsDesc2PreSize, tipsDesc2ValSize, tipsDesc2PostWidth = playInfoTipsDesc2Pre:getContentSize(), playInfoTipsDesc2Val:getContentSize(), playInfoTipsDesc2Post:getContentSize()
    -- tips2DescWidth = tipsDesc2PreSize.width + tipsDesc2ValSize.width + tipsDesc2PostWidth.width + tips2DescMagrins.wordGap * 2

    -- playInfoTipsDesc2Pre:pos(bgInfoPanelSize.width / 2 - (tips2DescWidth / 2 - tipsDesc2PreSize.width / 2),
    --     playInfoTipsDesc1:getPositionY() - playInfoTipsDesc1:getContentSize().height / 2 - infoTipsDescMagrins.eachLine - tipsDesc2PreSize.height / 2)
    -- playInfoTipsDesc2Val:pos(playInfoTipsDesc2Pre:getPositionX() + tipsDesc2PreSize.width / 2 + tips2DescMagrins.wordGap + tipsDesc2ValSize.width / 2,
    --     playInfoTipsDesc2Pre:getPositionY())
    -- playInfoTipsDesc2Post:pos(playInfoTipsDesc2Val:getPositionX() + tipsDesc2ValSize.width / 2 + tips2DescMagrins.wordGap + tipsDesc2PostWidth.width / 2,
    --     playInfoTipsDesc2Pre:getPositionY())

    -- local playInfoTipsDesc3 = display.newTTFLabel({text = playInfoTips[3], size = playInfoDescLabelParam.nor.frontSize,
    --     color = playInfoDescLabelParam.nor.color, align = ui.TEXT_ALIGN_CENTER})
    -- playInfoTipsDesc3:pos(bgInfoPanelSize.width / 2, 
    --     playInfoTipsDesc2Pre:getPositionY() - tipsDesc2PreSize.height / 2 - infoTipsDescMagrins.eachLine - playInfoTipsDesc3:getContentSize().height / 2)
    --     :addTo(bgInfoPanel)

    -- local playInfoTipsDesc4 = display.newTTFLabel({text = playInfoTips[4], size = playInfoDescLabelParam.nor.frontSize,
    --     color = playInfoDescLabelParam.nor.color, align = ui.TEXT_ALIGN_CENTER})
    -- playInfoTipsDesc4:pos(bgInfoPanelSize.width / 2,
    --     playInfoTipsDesc3:getPositionY() - playInfoTipsDesc3:getContentSize().height / 2 - infoTipsDescMagrins.eachLine - playInfoTipsDesc4:getContentSize().height / 2)
    --     :addTo(bgInfoPanel)

    -- ShareBtn
    -- local shareBtnSize = {
    --     width = 225,
    --     height = 66
    -- }

    -- local btnLabelOffset = {
    --     x = 0,
    --     y = 4
    -- }

    -- local shareBtnMagrinBottom = 30

    -- local btnLabelParam = {
    --     frontSize = 36,
    --     color = cc.c3b(193, 145, 50)
    -- }

    -- self.shareBtn = cc.ui.UIPushButton.new("#wheel_btnShare.png", {scale9 = true})
    --     :setButtonSize(shareBtnSize.width, shareBtnSize.height)
    --     :setButtonLabel(display.newTTFLabel({text = bm.LangUtil.getText("WHEEL", "SHARE"), size = btnLabelParam.frontSize, color = btnLabelParam.color, align = ui.TEXT_ALIGN_CENTER}))
    --     :setButtonLabelOffset(btnLabelOffset.x, btnLabelOffset.y)
    --     :onButtonClicked(buttontHandler(self, self.onShareBtnListener_))
    --     :pos(bgInfoPanelSize.width / 2, shareBtnMagrinBottom + shareBtnSize.height / 2)
    --     :addTo(bgInfoPanel)

    -- PlayStage Area --
    local soleBlockPosAdjust = {
        x = 40,
        y = 22
    }

    local soleBlockBg = display.newSprite("#wheel_decStageTray.png")
    soleBlockBg:pos(soleBlockBg:getContentSize().width / 2 - soleBlockPosAdjust.x, soleBlockPosAdjust.y)
        :addTo(bgDent)

    local rotaryBgPosYShift = 95
    local rotaryTabBg = display.newSprite("#wheel_bgRotary.png")

    local rotaryBgSize = rotaryTabBg:getContentSize()
    rotaryTabBg:pos(rotaryBgSize.width / 2, bgInfoPanelSize.height / 2 + rotaryBgPosYShift)
        :addTo(self.background_)

    -- Rotary Plate
    local wheelViewSize = {
        width = 360,
        height = 360
    }

    self.wheelView_ = WheelView.new(wheelViewSize.width, wheelViewSize.height)
        :addTo(rotaryTabBg)
        :pos(rotaryBgSize.width / 2, rotaryBgSize.height / 2)

    local lotteryIndex = display.newSprite("#wheel_decPlayIndex.png")
        :pos(rotaryBgSize.width / 2, rotaryBgSize.height / 2)
        :addTo(rotaryTabBg)

    display.newSprite("#wheel_canotPlay.png")
    :addTo(rotaryTabBg)
    :pos(rotaryBgSize.width / 2, rotaryBgSize.height / 2)


    self.playBtn_ = cc.ui.UIPushButton.new("#wheel_btnPlay.png")
        :onButtonClicked(handler(self, self.onPlayBtnListener_))
        :pos(rotaryBgSize.width / 2, rotaryBgSize.height / 2)
        :addTo(rotaryTabBg)

    self.playBtn_:setButtonEnabled(false)
    self.playBtn_:setVisible(false)

    local playDecBottomPosAdjust = {
        x = 30,
        y = 4
    }
    local playStageDecBottom = display.newSprite("#wheel_decPalyStageBot.png")
    playStageDecBottom:pos(playStageDecBottom:getContentSize().width / 2 - playDecBottomPosAdjust.x,
        playStageDecBottom:getContentSize().height / 2 + playDecBottomPosAdjust.y)
        :addTo(self.background_)

    local bottomTipsLabelParam = {
        frontSize = 22,
        color = cc.c3b(0x8d, 0x8c, 0x8c)
    }

    local tipsBottomMagrinBottom = 20
    local tipsBottom = display.newTTFLabel({text = bm.LangUtil.getText("WHEEL", "SHARE_BOTTOM_TIP2")[1], size = bottomTipsLabelParam.frontSize, 
        color = bottomTipsLabelParam.color, align = ui.TEXT_ALIGN_CENTER})
        :pos(playStageDecBottom:getContentSize().width / 2, tipsBottomMagrinBottom)
        :addTo(playStageDecBottom)
    -- --转盘背景
    -- local rotateBgMarginLeft = 36
    -- local rotateBgMarginTop = 24
    -- local rotateBgWidth = 392
    -- local rotateBgHeight = 400
    -- display.newSprite("#wheel_rotate_bg.png")
    --     :addTo(self)
    --     :pos(-WheelPopup.WIDTH/2 + rotateBgWidth/2 + rotateBgMarginLeft, WheelPopup.HEIGHT/2 - rotateBgHeight/2 - rotateBgMarginTop)

    -- --转盘
    -- local wheelViewMarginLeft = 36 + 16
    -- local wheelViewMarginTop = 24 + 16
    -- local wheelViewWidth = 360
    -- local wheelViewHeight = 360
    -- self.wheelView_ = WheelView.new(wheelViewWidth, wheelViewHeight)
    --     :addTo(self)
    --     :pos(-WheelPopup.WIDTH/2 + wheelViewWidth/2 + wheelViewMarginLeft, WheelPopup.HEIGHT/2 - wheelViewHeight/2 - wheelViewMarginTop)

    -- --开始抽奖按钮
    -- local playBtnMarginLeft = 36 + 132
    -- local playBtnMarginTop = 24 + 110
    -- local playBtnWidth = 130
    -- local playBtnHeight = 152
    -- local playBtnLabelX = 0
    -- local playBtnLabelY = -12
    -- self.playBtn_ = cc.ui.UIPushButton.new({normal = "#wheel_rotate_index_up.png", pressed = "#wheel_rotate_index_down.png", disabled = "#wheel_rotate_index_disabled.png"})
    --     :addTo(self)
    --     :pos(-WheelPopup.WIDTH/2 + playBtnWidth/2 + playBtnMarginLeft, WheelPopup.HEIGHT/2 - playBtnHeight/2 - playBtnMarginTop)
    --     :onButtonClicked(handler(self, self.onPlayBtnListener_))
    --     :onButtonRelease(function()

    --     end)
    --     :setButtonLabel(display.newTTFLabel({
    --              text = bm.LangUtil.getText("WHEEL", "PLAY"),
    --              size = middleSize,
    --              color = playBtnColor,
    --              align = ui.TEXT_ALIGN_CENTER
    --         }))
    --     :setButtonLabelOffset(playBtnLabelX, playBtnLabelY)
    -- self.playBtn_:setButtonEnabled(false)

    -- --背景饰品
    -- if nk.config.CHRISTMAS_THEME_ENABLED then
    --     local bgDecoration1Bottom = 162
    --     local bgDecoration1Left = 22
    --     local bgDecoration1Width = 42
    --     local bgDecoration1Height = 46
    --     local bgDecoration1Scale = 0.7
    --     display.newSprite("#wheel_bg_decoration1.png")
    --         :addTo(self)
    --         :pos(-WheelPopup.WIDTH/2 + bgDecoration1Width/2 + bgDecoration1Left, -WheelPopup.HEIGHT/2 + bgDecoration1Height/2 + bgDecoration1Bottom)
    --         :scale(bgDecoration1Scale)

    --     local bgDecoration2Top = 95
    --     local bgDecoration2Left = 125
    --     local bgDecoration2Width = 42
    --     local bgDecoration2Height = 46
    --     local bgDecoration2Scale = 0.7
    --     display.newSprite("#wheel_bg_decoration1.png")
    --         :addTo(self)
    --         :pos(bgDecoration2Width/2 + bgDecoration2Left, WheelPopup.HEIGHT/2 - bgDecoration2Height/2 - bgDecoration2Top)
    --         :scale(bgDecoration2Scale)

    --     local bgDecoration3Bottom = 220
    --     local bgDecoration3Left = 30
    --     local bgDecoration3Width = 42
    --     local bgDecoration3Height = 46
    --     local bgDecoration3Scale = 1
    --     display.newSprite("#wheel_bg_decoration1.png")
    --         :addTo(self)
    --         :pos(bgDecoration3Width/2 + bgDecoration3Left, -WheelPopup.HEIGHT/2 + bgDecoration3Height/2 + bgDecoration3Bottom)
    --         :scale(bgDecoration3Scale)

    --     local bgDecoration4Bottom = 160
    --     local bgDecoration4Right = 20
    --     local bgDecoration4Width = 45
    --     local bgDecoration4Height = 82
    --     local bgDecoration4Scale = 1
    --     display.newSprite("#wheel_bg_decoration2.png")
    --         :addTo(self)
    --         :pos(WheelPopup.WIDTH/2 - bgDecoration4Width/2 - bgDecoration4Right, -WheelPopup.HEIGHT/2 + bgDecoration4Height/2 + bgDecoration4Bottom)
    --         :scale(bgDecoration4Scale)


    --     --前景饰品左边
    --     local fgDecoration1Left = 36
    --     local fgDecoration1Top = 22
    --     local fgDecoration1Width = 62
    --     local fgDecoration1Height = 62
    --     display.newSprite("#wheel_fg_decoration1.png")
    --         :addTo(self)
    --         :pos(-WheelPopup.WIDTH/2 + fgDecoration1Width/2 + fgDecoration1Left, planeBgPosY + fgDecoration1Height/2 + fgDecoration1Top)

    --     local fgDecoration2Left = 22
    --     local fgDecoration2Top = 25
    --     local fgDecoration2Width = 52
    --     local fgDecoration2Height = 62
    --     display.newSprite("#wheel_fg_decoration2.png")
    --         :addTo(self)
    --         :pos(-WheelPopup.WIDTH/2 + fgDecoration1Width + fgDecoration2Width/2 + fgDecoration2Left, planeBgPosY + fgDecoration2Height/2 + fgDecoration2Top)

    --     --前景饰品右边
    --     local fgDecoration3Left = -65
    --     local fgDecoration3Top = 28
    --     local fgDecoration3Width = 62
    --     local fgDecoration3Height = 62
    --     display.newSprite("#wheel_fg_decoration3.png")
    --         :addTo(self)
    --         :pos(fgDecoration3Width/2 + fgDecoration3Left, planeBgPosY + fgDecoration3Height/2 + fgDecoration3Top)

    --     local fgDecoration4Left = -75
    --     local fgDecoration4Top = 36
    --     local fgDecoration4Width = 103
    --     local fgDecoration4Height = 103
    --     display.newSprite("#wheel_fg_decoration4.png")
    --         :addTo(self)
    --         :pos(fgDecoration3Width + fgDecoration4Width/2 + fgDecoration4Left, planeBgPosY + fgDecoration4Height/2 + fgDecoration4Top)

    --     local fgDecoration5Left = -45
    --     local fgDecoration5Top = 28
    --     local fgDecoration5Width = 86
    --     local fgDecoration5Height = 84
    --     display.newSprite("#wheel_fg_decoration5.png")
    --         :addTo(self)
    --         :pos(fgDecoration4Width + fgDecoration5Width/2 + fgDecoration5Left, planeBgPosY + fgDecoration5Height/2 + fgDecoration5Top)
    -- end

    -- --分享按钮
    -- if nk.config.SONGKRAN_THEME_ENABLED then
    --     local shareBtnRight = 100
    --     local shareBtnTop = 15
    --     local shareBtnWidth = 170
    --     local shareBtnHeight = 56
    --     local shareBtnTextOx = 0
    --     local shareBtnTextOy = 8
    --     self.shareBtn = cc.ui.UIPushButton.new({normal = "#songkran_wheel_btn_big_normal.png", pressed = "#songkran_wheel_btn_big_pressed.png"})
    --         :setButtonLabel(display.newTTFLabel({
    --              text = bm.LangUtil.getText("WHEEL", "SHARE"),
    --              size = 28,
    --              color = shareColor,
    --              align = ui.TEXT_ALIGN_CENTER
    --         }))
    --         :setButtonLabelOffset(shareBtnTextOx, shareBtnTextOy)
    --         :addTo(self)
    --         :pos(WheelPopup.WIDTH/2 - shareBtnWidth/2 - shareBtnRight, planeBgPosY + shareBtnHeight/2 + shareBtnTop)
    --         :onButtonClicked(buttontHandler(self, self.onShareBtnListener_))
    -- else
    --     local shareBtnRight = 28
    --     local shareBtnTop = 10
    --     local shareBtnWidth = 300
    --     local shareBtnHeight = 74
    --     local shareBtnTextOx = 0
    --     local shareBtnTextOy = 8
    --     self.shareBtn = cc.ui.UIPushButton.new({normal = "#wheel_plane_share_btn_up.png", pressed = "#wheel_plane_share_btn_down.png"})
    --         :setButtonLabel(display.newTTFLabel({
    --              text = bm.LangUtil.getText("WHEEL", "SHARE"),
    --              size = 28,
    --              color = shareColor,
    --              align = ui.TEXT_ALIGN_CENTER
    --         }))
    --         :setButtonLabelOffset(shareBtnTextOx, shareBtnTextOy)
    --         :addTo(self)
    --         :pos(WheelPopup.WIDTH/2 - shareBtnWidth/2 - shareBtnRight, planeBgPosY + shareBtnHeight/2 + shareBtnTop)
    --         :onButtonClicked(buttontHandler(self, self.onShareBtnListener_))
    -- end

    -- --剩余抽奖次数
    -- local playCountLabelRight = 36
    -- local playCountLabelTop = 135
    -- local playCountLabelWidth = 330
    -- local playCountLabelHeight = 73
    -- local playCountPosX = WheelPopup.WIDTH/2 - playCountLabelWidth/2 - playCountLabelRight
    -- local playCountPosY = WheelPopup.HEIGHT/2 - playCountLabelHeight/2 - playCountLabelTop

    -- --抽奖次数背景
    -- local playCountBg = display.newScale9Sprite("#transparent.png")
    --     :addTo(self)
    --     :size(playCountLabelWidth, playCountLabelHeight)
    --     :pos(playCountPosX, playCountPosY)

    -- playCountPosY = playCountPosY - playCountLabelHeight/2

    -- self.playCountLabelContainer_ = display.newNode():addTo(playCountBg)
    -- local playCountLabelContainer = self.playCountLabelContainer_

    -- local playCountLabel1MarginLeft = 0
    -- local playCountLabel1 = display.newTTFLabel({
    --          text = bm.LangUtil.getText("WHEEL", "REMAIN_COUNT"),
    --          size = bigSize,
    --          color = leftNumColor,
    --          align = ui.TEXT_ALIGN_CENTER
    --     })
    --     :addTo(playCountLabelContainer)
    -- local playCountLabel1Size = playCountLabel1:getContentSize()
    -- playCountLabel1:setAnchorPoint(cc.p(0, 0))
    -- playCountLabel1:pos(playCountLabel1MarginLeft, (playCountLabelHeight - playCountLabel1Size.height)/2)

    -- --抽奖剩余次数
    -- local playCountLabelMarginLeft = 2
    -- self.playCountLabel = display.newTTFLabel({
    --          text = "..",
    --          size = bigSize,
    --          color = numberColor,
    --          align = ui.TEXT_ALIGN_CENTER
    --     })
    --     :addTo(playCountLabelContainer)
    -- local playCountLabelSize = self.playCountLabel:getContentSize()
    -- self.playCountLabel:setAnchorPoint(cc.p(0, 0))
    -- self.playCountLabel:pos(playCountLabel1:getPositionX() + playCountLabel1Size.width + playCountLabelMarginLeft, (playCountLabelHeight - playCountLabelSize.height)/2)

    -- local playCountLabel2MarginLeft = 2
    -- local playCountLabel2 = display.newTTFLabel({
    --          text = bm.LangUtil.getText("WHEEL", "TIME"),
    --          size = bigSize,
    --          color = leftNumColor,
    --          align = ui.TEXT_ALIGN_CENTER
    --     })
    --     :addTo(playCountLabelContainer)
    -- local playCountLabel2Size = playCountLabel2:getContentSize()
    -- playCountLabel2:setAnchorPoint(cc.p(0, 0))
    -- playCountLabel2:pos(self.playCountLabel:getPositionX() + playCountLabelSize.width + playCountLabel2MarginLeft, (playCountLabelHeight - playCountLabel2Size.height)/2)

    -- local playCountLabelLength = playCountLabel1MarginLeft + playCountLabel1Size.width +
    --     playCountLabelMarginLeft + playCountLabelSize.width + playCountLabel2MarginLeft + playCountLabel2Size.width
    -- playCountLabelContainer:setPositionX((playCountLabelWidth - playCountLabelLength)/2)

    -- --文字描述
    -- --描述1
    -- local descLabel1Top = 8
    -- local descLabel1 = display.newTTFLabel({
    --          text = bm.LangUtil.getText("WHEEL", "DESC1"),
    --          size = smallSize,
    --          color = whileColor,
    --          align = ui.TEXT_ALIGN_CENTER,
    --          valign = ui.TEXT_VALIGN_CENTER,
    --          dimensions = cc.size(playCountLabelWidth, 0)
    --     })
    --     :addTo(self)
    -- local descLabelSize1 = descLabel1:getContentSize()
    -- playCountPosY = playCountPosY - descLabelSize1.height/2 - descLabel1Top
    -- descLabel1:pos(playCountPosX, playCountPosY)

    -- --描述2
    -- local descLabel2Top = 16
    -- local descLabel2Container = display.newNode()
    --     :addTo(self)
    --     :size(playCountLabelWidth, 0)
    --     :pos(playCountPosX, playCountPosY - descLabel2Top)

    -- local descLabel2Labels = display.newNode():addTo(descLabel2Container)
    -- local descLabel2preLeft = 0
    -- local descLabel2pre = display.newTTFLabel({
    --          text = bm.LangUtil.getText("WHEEL", "DESC2_PRE"),
    --          size = largeSize,
    --          color = whileColor,
    --          align = ui.TEXT_ALIGN_CENTER
    --     })
    --     :addTo(descLabel2Labels)
    -- descLabel2pre:setAnchorPoint(cc.p(0, 0.5))
    -- local descLabel2preSize = descLabel2pre:getContentSize()
    -- descLabel2pre:pos(descLabel2preLeft, descLabel2preSize.height/2)

    -- local descLabel2Left = 2
    -- local descLabel2 = display.newTTFLabel({
    --          text = "100%",
    --          size = largeSize,
    --          color = numberColor,
    --          align = ui.TEXT_ALIGN_CENTER
    --     })
    --     :addTo(descLabel2Labels)
    -- descLabel2:setAnchorPoint(cc.p(0, 0.5))
    -- local descLabel2Size = descLabel2:getContentSize()
    -- descLabel2:pos(descLabel2pre:getPositionX() + descLabel2preSize.width + descLabel2Left, descLabel2Size.height/2)

    -- local descLabel2postLeft = 2
    -- local descLabel2post = display.newTTFLabel({
    --          text = bm.LangUtil.getText("WHEEL", "DESC2_POST"),
    --          size = largeSize,
    --          color = whileColor,
    --          align = ui.TEXT_ALIGN_CENTER
    --     })
    --     :addTo(descLabel2Labels)
    -- descLabel2post:setAnchorPoint(cc.p(0, 0.5))
    -- local descLabel2postSize = descLabel2post:getContentSize()
    -- descLabel2post:pos(descLabel2:getPositionX() + descLabel2Size.width + descLabel2postLeft, descLabel2postSize.height/2)

    -- local descLabel2Length = descLabel2preLeft + descLabel2preSize.width + descLabel2Left + descLabel2Size.width +
    --     descLabel2postLeft + descLabel2postSize.width
    -- descLabel2Labels:pos(-descLabel2Length/2 + (playCountLabelWidth - descLabel2Length)/2, -descLabel2postSize.height)
    -- playCountPosY = playCountPosY - descLabel2Top - descLabel2postSize.height

    -- --描述3
    -- local descLabel3Top = 10
    -- local descLabel3 = display.newTTFLabel({
    --          text = bm.LangUtil.getText("WHEEL", "DESC3"),
    --          size = smallSize,
    --          color = whileColor,
    --          align = ui.TEXT_ALIGN_CENTER,
    --          valign = ui.TEXT_VALIGN_CENTER,
    --          dimensions = cc.size(playCountLabelWidth, 0)
    --     })
    --     :addTo(self)
    -- local descLabelSize3 = descLabel3:getContentSize()
    -- playCountPosY = playCountPosY - descLabelSize3.height/2 - descLabel3Top
    -- descLabel3:pos(playCountPosX, playCountPosY)

    -- --描述4
    -- local descLabel4Top = 18
    -- local descLabel4 = display.newTTFLabel({
    --          text = bm.LangUtil.getText("WHEEL", "DESC4"),
    --          size = smallSize,
    --          color = whileColor,
    --          align = ui.TEXT_ALIGN_CENTER,
    --          valign = ui.TEXT_VALIGN_CENTER,
    --          dimensions = cc.size(playCountLabelWidth, 0)
    --     })
    --     :addTo(self)
    -- local descLabelSize4 = descLabel4:getContentSize()
    -- playCountPosY = playCountPosY - descLabelSize4.height/2 - descLabel4Top
    -- descLabel4:pos(playCountPosX, playCountPosY)

    -- display.newTTFLabel({
    --          text = bm.LangUtil.getText("WHEEL", "SHARE_BOTTOM_TIP2")[1],
    --          size = smallSize,
    --          color = whileColor,
    --          align = ui.RIGHT_BOTTOM,
    --          valign = ui.TEXT_VALIGN_CENTER,
    --          dimensions = cc.size(670, 0)
    --     })
    --     :addTo(self)
    --     :pos(90,-190)

    self:getConfig()
end

function WheelPopup:setLoading(isLoading)
    if isLoading then
        if not self.juhua_ then
            self.juhua_ = nk.ui.Juhua.new():scale(0.5)
            local size = self.juhua_:getContentSize()
            -- self.juhua_:pos(self.playCountLabel:getPositionX() + size.width/4 - 5, self.playCountLabel:getPositionY() + size.height/4)
            self.juhua_:pos(WheelPopup.WIDTH / 2, WheelPopup.HEIGHT / 2)
                :addTo(self.background_)
        end
    else
        if self.juhua_ then
            self.juhua_:removeFromParent()
            self.juhua_ = nil
        end
    end
end

function WheelPopup:getPlayTimes()
    self.playBtn_:setButtonEnabled(false)
    self.playBtn_:setVisible(false)
    self:setLoading(true)
    self.controller_:getPlayTimes(function(isSucc, data)
        if isSucc then
            self:setLoading(false)
            self.playTimes_ = data.num
            self.playTimesRem:setString(data.num)
            -- if data > 0 then
            --     self.playBtn_:setButtonEnabled(true)
            -- end

            --抽奖次数已用完
            if data.num == 0 then
                self.playBtn_:setButtonEnabled(false)
                self.playBtn_:setVisible(false)
                self.status_:setString(bm.LangUtil.getText("WHEEL","STATUS2"))
            end
            self:stopAction(self.action_)
            --抽奖次数还有，但需要等待
            if data.num>0 and data.diffToNextPan > 0 then
                self.playBtn_:setButtonEnabled(false)
                self.playBtn_:setVisible(false)
                self.diffToNextPan_ = data.diffToNextPan

                self.action_ = self:schedule(function ()
                  if checkint(self.diffToNextPan_) == 0 then
                    self:stopAction(self.action_)
                    self:getPlayTimes()
                    return
                  end
                  self.diffToNextPan_ = checkint(self.diffToNextPan_)-1;
                  local str = os.date("%M:%S", self.diffToNextPan_);
                  self.status_:setString(str)
                end,1
              )
            end
            --抽奖次数还有，无需等待
            if data.num>0 and data.diffToNextPan==0 then
                self.playBtn_:setButtonEnabled(true)
                self.playBtn_:setVisible(true)
                self.status_:setString(bm.LangUtil.getText("WHEEL","STATUS1"))
            end
        else
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
        end
    end)
end

function WheelPopup:getConfig()
    self.controller_:getConfig(function(isSucc, data)
        if isSucc then
            self.wheelView_:setItemData(data)
        else
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
        end
    end)
end

function WheelPopup:playNow()
    self.rewardData_ = nil
    self.controller_:playNow(function(isSucc, data)
        if isSucc then
            self.rewardData_ = data
            self.playTimes_ = self.playTimes_ - 1
            if self.playTimes_ < 0 then
                self.playTimes_ = 0
            end
            
            self.playTimesRem:setString(self.playTimes_)
            self.wheelView_:setDestDegreeById(data.id)
            self.wheelView_:startRotation(function()
                -- if self.playTimes_ > 0 then
                --     self.playBtn_:setButtonEnabled(true)
                -- end

                local item = self.wheelView_:findItemById(data.id)
                self:performWithDelay(function()
                    nk.SoundManager:playSound(nk.SoundManager.WHEEL_WIN)
                    WheelSharePopup.new(item, self):show() 
                    self:getPlayTimes()
                end, 0.5)

                nk.SoundManager:playSound(nk.SoundManager.WHEEL_END)
                if self.rewardData_ then
                    if self.rewardData_.money then
                        local addMoney = self.rewardData_.money.addMoney
                        local money = self.rewardData_.money.money
                        nk.userData["aUser.money"] = money
                    end
                    self.rewardData_ = nil
                end
            end)
        else
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
            if self.playTimes_ > 0 then
                self.playBtn_:setButtonEnabled(true)
                self.playBtn_:setVisible(true)
            end
        end
    end)
end

function WheelPopup:onCloseBtnListener_()
    self:hide()
end

function WheelPopup:onShareBtnListener_()
    self.shareBtn:setButtonEnabled(false)
    -- local feedData = clone(bm.LangUtil.getText("FEED", "WHEEL_ACT"))
    --  nk.Facebook:shareFeed(feedData, function(success, result)
    --      print("FEED.WHEEL_ACT result handler -> ", success, result)
    --      if not success then
    --          self.shareBtn:setButtonEnabled(true)
    --          nk.TopTipManager:showTopTip(bm.LangUtil.getText("FEED", "SHARE_FAILED"))
    --      else
    --          self.controller_:shareToGetChance()
    --          nk.TopTipManager:showTopTip(bm.LangUtil.getText("FEED", "SHARE_SUCCESS"))
    --      end
    --  end)

    nk.sendFeed:wheel_act_(function()
        self.controller_:shareToGetChance()  
    end,function()
        self.shareBtn:setButtonEnabled(true)
    end)

    -- WheelSharePopup.new(item, self):show()
end

function WheelPopup:onPlayBtnListener_()
    nk.SoundManager:playSound(nk.SoundManager.WHEEL_START)
    if self.controller_:isAllReady() and self.playTimes_ > 0 then
        self.playBtn_:setButtonEnabled(false)
        self.playBtn_:setVisible(false)
        self:playNow()
    end
end

function WheelPopup:show()
    nk.PopupManager:addPopup(self)
    return self
end

function WheelPopup:onShowed()
    self:getPlayTimes()
end

function WheelPopup:hide()
    nk.PopupManager:removePopup(self)
    return self
end

function WheelPopup:onCleanup()
    if self.rewardData_ then
        if self.rewardData_.money then
            local addMoney = self.rewardData_.money.addMoney
            local money = self.rewardData_.money.money
            nk.userData["aUser.money"] = money
        end
        self.rewardData_ = nil
    end
                
    self.controller_:dispose()
    display.removeSpriteFramesWithFile("wheel_texture.plist", "wheel_texture.png")
    nk.schedulerPool:delayCall(function()
        cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    end, 0.1)
    
    -- if nk.config.SONGKRAN_THEME_ENABLED then
    --     display.removeSpriteFramesWithFile("songkran_wheel_texture.plist", "songkran_wheel_texture.png")
    -- end
end

return WheelPopup
