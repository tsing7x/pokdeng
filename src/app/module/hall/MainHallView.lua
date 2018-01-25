--
-- Author: johnny@boomegg.com
-- Date: 2014-08-04 15:59:48
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

local MainHallView = class("MainHallView", function ()
    return display.newNode()
end)
local UserInfoPopup       = import("app.module.userInfo.UserInfoPopup")

local StorePopup          = import("app.module.newstore.StorePopup")
local FriendPopup         = import("app.module.friend.FriendPopup")
local RankingPopup        = import("app.module.ranking.RankingPopup")
local SettingAndHelpPopup = import("app.module.settingAndhelp.SettingAndHelpPopup")
local NewestActPopup      = import("app.module.newestact.NewestActPopup")
local MessageView         = import("app.module.hall.message.MessageView")
local DailyTasksPopup     = import("app.module.dailytasks.DailyTasksPopup")
local InvitePopup         = import("app.module.friend.InvitePopup")
local InviteRecallPopup   = import("app.module.friend.InviteRecallPopup")
local LoginRewardView     = import("app.module.loginreward.LoginRewardView")
local MessageData         = import("app.module.hall.message.MessageData")
local ExchangeCodePop     = import("app.module.exchangecode.ExchangeCode")
local WheelPopup          = import("app.module.wheel.WheelPopup")
local TutorialButton      = import("app.module.tutorial.TutorialButton")
local CornuPopup          = import("app.module.cornucopiaEx.CornuPopup")
local PokdengAdPopup      = import("app.module.pokdeng.PokdengAdPopup")
local PromotActPopup      = import("app.module.unionAct.PromotActPopup")
local PayGuide            = import("app.module.room.purchGuide.PayGuide")
local FirChargePayGuidePopup = import("app.module.newstore.firChrgGuide.FirChrgPayGuidePopup")
local AgnChargePayGuidePopup = import("app.module.newstore.agnChrgGuide.AgnChrgPayGuidePopup")
local ScoreMarketView = import("app.module.scoreMarket.ScoreMarketView")

local SuonaUsePopup = import("app.module.suona.SuonaUsePopup")
local AdPromotPopup = import("app.module.adPromot.AdPromotPopup")
local SignInContPopup = import("app.module.signIn.SignInContPopup")
local PURCHASE_TYPE = import("app.module.newstore.PURCHASE_TYPE")
local UpdatePopup = import("app.module.settingAndhelp.setting.UpdatePopup")
local GucuReCallPopup = import("app.module.gucuRecall.GucuReCallPopup")

local NewerGuidePopup = import("app.module.newer.NewerGuidePopup")
local NewerPlayPopup = import("app.module.newer.NewerPlayPopup")

-- just for Test --
-- local QuickShortBillPay = import("app.module.newstore.quickSortPay.QuickShortBillPay")
-- local UserCrash = import("app.module.room.userCrash.UserCrash")
-- local AwardAddrComfirmPopup = import("app.module.hall.awardAddrView.AwardAddComfirmPopup")
-- local GiftStorePopup = import("app.module.newstore.GiftStorePopup")
-- local AuctionMarketPopup = import("app.module.auctionmarket.AuctionMarketPopup")
-- local AuctionMarketHelpPopup = import("app.module.auctionmarket.AuctionMarketHelpPopup")
-- local AucteProdPopup = import("app.module.auctionmarket.AucteProdPopup")
-- local AucteProdFixedPricePopup = import("app.module.auctionmarket.AucteProdFixedPricePopup")
-- local AuctSellProdPopup = import("app.module.auctionmarket.AuctSellProdPopup")

-- local EnterRoomTip        = import("app.module.room.purchGuide.RoomEnterTip")
-- local UserCrash           = import("app.module.room.userCrash.UserCrash")

-- local QRCodeShowPopup = import("app.module.hall.personalRoomDialog.QRCodeShowPopup")
-- local PersonelRoomHelpPopup = import("app.module.hall.personalRoomDialog.PersonelRoomHelpPopup")
-- local PswEntryPopup = import("app.module.hall.personalRoomDialog.PswEntryPopup")

-- local MatchRoomChooseHelpPopup = import("app.module.hall.MatchRoomChooseHelpPopup")
-- end --

MainHallView.TABLE_POS_TOP    = 1 -- 顶部
MainHallView.TABLE_POS_BOTTOM = 2 -- 底部

local MORE_CHIP_PANEL_HEIGHT = 140
local BRICK_WIDTH            = 180
local BRICK_HEIGHT           = 220

local BOTTOM_USER_INFO_WIDTH = 300 * nk.widthScale
local BOTTOM_MAIN_BTN_WIDTH  = 140 * nk.widthScale -- 3个按钮
local BOTTOM_SUB_BTN_WIDTH   = 90 * nk.widthScale -- 2个按钮
local BOTTOM_PANEL_HEIGHT    = 107
local AVATAR_TAG             = 100
local BRICK_GAP              = nk.widthScale * 32
local BRICK_DISTANCE         = BRICK_WIDTH + BRICK_GAP

function MainHallView:ctor(controller, tablePos)
    self.controller_ = controller
    self.controller_:setDisplayView(self)
    self.tablePos_ = tablePos

    self:setNodeEventEnabled(true)

    --[[
        桌子和筹码背景
    ]]
    self.tableNode_ = display.newNode()
        :addTo(self)

    -- 桌子
    local bgScale = self.controller_:getBgScale()

    self.pokerTable_ = display.newNode():addTo(self.tableNode_):scale(bgScale)
    local tableLeft = display.newSprite("#main_hall_table.png"):addTo(self.pokerTable_)
    tableLeft:setAnchorPoint(cc.p(1, 0.5))
    tableLeft:pos(2, 0)
    local tableRight = display.newSprite("#main_hall_table.png"):addTo(self.pokerTable_)
    tableRight:setScaleX(-1)
    tableRight:setAnchorPoint(cc.p(1, 0.5))
    tableRight:pos(-2, 0)

    -- 筹码
    self.leftChip_ = display.newSprite("#left_chip_stack.png")
        :scale(bgScale)
    self.leftChip_:pos(-BRICK_DISTANCE * 1.5, -(display.cy + self.leftChip_:getContentSize().height))
        :addTo(self.tableNode_)
    self.rightChip_ = display.newSprite("#right_chip_stack.png")
        :scale(bgScale)
    self.rightChip_:pos(BRICK_DISTANCE * 1.5, -(display.cy + self.rightChip_:getContentSize().height))
        :addTo(self.tableNode_)

    --[[
        顶部操作区域
    ]]
    self.halfTopNode_ = display.newNode()
        :addTo(self)
    
    local topSuonaTipSize = {
        width = display.width,
        height = 45
    }

    self.topSuonaTipPanel_ = display.newScale9Sprite("#suona_bgTipTop.png", 0, display.cy - topSuonaTipSize.height / 2,
        cc.size(topSuonaTipSize.width, topSuonaTipSize.height))
        :addTo(self.halfTopNode_)

    self.topSuonaTipPanel_:setOpacity(0)

    local suonaBtnMagrinLeft = 3
    local suonaBtnSize = {
        width = 44,
        height = 40
    }

    self.suonaBtnTop_ = cc.ui.UIPushButton.new("#suona_icon.png", {scale9 = false})
        :onButtonClicked(handler(self, self.onTopSuonaBtnCallBack_))
        :pos(- display.cx + suonaBtnSize.width / 2 + suonaBtnMagrinLeft, display.cy - topSuonaTipSize.height / 2)
        :addTo(self.halfTopNode_)

    local suonaChatLabelMagrinLeft = 10
    local chatLabelHeight = 30

    local chatInfoLabelStencil = display.newDrawNode()
    chatInfoLabelStencil:drawPolygon({
        {- topSuonaTipSize.width / 2 + suonaBtnSize.width + suonaBtnMagrinLeft + suonaChatLabelMagrinLeft, - chatLabelHeight / 2}, 
        {- topSuonaTipSize.width / 2 + suonaBtnSize.width + suonaBtnMagrinLeft + suonaChatLabelMagrinLeft,  chatLabelHeight / 2}, 
        {topSuonaTipSize.width / 2 - suonaBtnSize.width - suonaBtnMagrinLeft - suonaChatLabelMagrinLeft,  chatLabelHeight / 2}, 
        {topSuonaTipSize.width / 2 - suonaBtnSize.width - suonaBtnMagrinLeft - suonaChatLabelMagrinLeft, - chatLabelHeight / 2}
    })

    self.suonaChatInfoclipNode_ = cc.ClippingNode:create()
        :pos(topSuonaTipSize.width / 2, topSuonaTipSize.height / 2)
        :addTo(self.topSuonaTipPanel_)
    self.suonaChatInfoclipNode_:setStencil(chatInfoLabelStencil)

    self.suonaChatMsgStrPosXSrc = topSuonaTipSize.width / 2 - suonaBtnSize.width - suonaBtnMagrinLeft - suonaChatLabelMagrinLeft
    self.suonaChatMsgStrPosXDes = - topSuonaTipSize.width / 2 + suonaBtnSize.width + suonaBtnMagrinLeft + suonaChatLabelMagrinLeft

    local suonaChatLabelParam = {
        frontSize = 22,
        color = display.COLOR_WHITE
        -- cc.c3b(255, 0, 255)
    }

    self.suonaChatInfo_ = display.newTTFLabel({text = bm.LangUtil.getText("SUONA", "SUONAUSE_TOPTIP"), size = suonaChatLabelParam.frontSize, color = suonaChatLabelParam.color, align = ui.TEXT_ALIGN_CENTER})
    self.suonaChatInfo_:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER_LEFT])
    self.suonaChatInfo_:pos(- topSuonaTipSize.width / 2 + suonaBtnSize.width + suonaBtnMagrinLeft + suonaChatLabelMagrinLeft,
        0)
        :addTo(self.suonaChatInfoclipNode_)

    self.suonaChatInfo_:setOpacity(0)
    -- self.suonaChatInfo_:hide()

    -- self.suonaChatInfo_:setOpacity(0)  -- setOpacity 失效？！
    local logPosAdjust = {
        x = - 10,
        y = 5
    }

    -- 游戏logo
    self.gameLogo_ = display.newSprite("#game_logo.png")
        :pos(-display.cx + 118 + logPosAdjust.x, display.cy - 88 - logPosAdjust.y)
        :addTo(self.halfTopNode_)

    -- 在线人数
    self.userOnline_ = display.newTTFLabel({text = bm.LangUtil.getText("HALL", "USER_ONLINE", "9,999"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 26, align = ui.TEXT_ALIGN_CENTER})
        :pos(display.cx - 150, display.cy - 55)
        :addTo(self.halfTopNode_)

    -- 邀请好友
    self:addInviteBarBushAnim()
    local inviteZOrder = 9

    local inviteBtnBgUp = display.newScale9Sprite("#invite_btn_up.png", 0, 0, cc.size(260, 38), cc.rect(72, 20, 1, 1))
        :pos(display.cx - 150, display.cy - 86)
        :addTo(self.halfTopNode_,inviteZOrder)
    local inviteBtnBgDown = display.newScale9Sprite("#invite_btn_down.png", 0, 0, cc.size(260, 38), cc.rect(72, 20, 1, 1))
        :pos(display.cx - 150, display.cy - 86)
        :addTo(self.halfTopNode_,inviteZOrder):hide()
    cc.ui.UIPushButton.new("#common_transparent_skin.png", {scale9 = true})
        :setButtonSize(258, 36) -- 3像素的透明边缘
        :add(display.newTTFLabel({text = bm.LangUtil.getText("HALL", "INVITE_FRIEND", bm.formatNumberWithSplit(nk.userData.inviteBackChips)), color = styles.FONT_COLOR.GOLDEN_TEXT, size = 20, align = ui.TEXT_ALIGN_CENTER})
            :pos(32, 0), 0, 999)
        :pos(display.cx - 150, display.cy - 88)
        :addTo(self.halfTopNode_, inviteZOrder + 1, 999)
        :onButtonPressed(function()
            inviteBtnBgUp:hide()
            inviteBtnBgDown:show()
        end)
        :onButtonRelease(function()
            inviteBtnBgUp:show()
            inviteBtnBgDown:hide()
        end)
        :onButtonClicked(buttontHandler(self, self.onInviteBtnClick))

    --新手教程
    if nk.config.TUTORIAL_ENABLED then
        local tutorialMarginTop = display.cy - 88 - 36
        TutorialButton.new():addTo(self.halfTopNode_):pos(display.cx - 150, tutorialMarginTop - 64/2)
    end

    --[[
        方块与底部操作区域
    ]]
    self.halfBottomNode_ = display.newNode()
        :addTo(self)

    -- 更多筹码
    local bgY = display.cy - (MORE_CHIP_PANEL_HEIGHT + BRICK_HEIGHT * 0.5)
    self.moreChipNode_ = display.newNode()
        :addTo(self.halfBottomNode_, 1)
    self.moreChipsSprite_ = display.newSprite("#more_chip_brick_btn_bg.png")
        :addTo(self.moreChipNode_)
    local moreChipSize = self.moreChipsSprite_:getContentSize()
    self.moreChipsSprite_:pos(-BRICK_DISTANCE * 1.5, -bgY - (moreChipSize.height/2))

    -- local icCakePosYShift = 16
    -- local icCakeFiveYear = display.newSprite("#fiveYear_ic_cake.png")
    --     :pos(self.moreChipsSprite_:getContentSize().width / 2, self.moreChipsSprite_:getContentSize().height / 2 + icCakePosYShift)
    --     :addTo(self.moreChipsSprite_)

    cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#rounded_rect_10.png"}, {scale9 = true})
        :setButtonSize(BRICK_WIDTH - 16, (BRICK_HEIGHT - 16)/2) -- 8像素的透明边缘
        :pos(-BRICK_DISTANCE * 1.5, -bgY-moreChipSize.height/2)
        :addTo(self.moreChipNode_)
        :onButtonClicked(buttontHandler(self, self.onMoreChipClick))

    --私人房
    -- self.personalRoomSprite_ = display.newSprite("#personal_room_brick_btn_bg.png")
    --     :addTo(self.moreChipNode_)
    -- local personalSpriteSize = self.personalRoomSprite_:getContentSize()
    -- self.personalRoomSprite_:pos(-BRICK_DISTANCE * 1.5, -bgY+personalSpriteSize.height/2)

    -- cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#rounded_rect_10.png"}, {scale9 = true})
    --     :setButtonSize(BRICK_WIDTH - 16, (BRICK_HEIGHT - 16)/2) -- 8像素的透明边缘
    --     :pos(-BRICK_DISTANCE * 1.5, -bgY+personalSpriteSize.height/2)
    --     :addTo(self.moreChipNode_)
    --     :onButtonClicked(buttontHandler(self, self.onProHallClick))

    -- 夺宝 --
    local personalBrickHeight = 108
    self.dokbBtn_ = cc.ui.UIPushButton.new({normal = "#personal_room_brick_btn_bg_nor.png", pressed = "#personal_room_brick_btn_bg_pre.png", disabled = "#personal_room_brick_btn_bg_nor.png"},
        {scale9 = false})
        :onButtonClicked(buttontHandler(self, self.onDokbHallClick))
        :pos(- BRICK_DISTANCE * 1.5, - bgY + personalBrickHeight / 2)
        :addTo(self.moreChipNode_)

    local userLevelFact = nk.Level:getLevelByExp(nk.userData["aUser.exp"])
    if userLevelFact < 3 or nk.userData["aUser.mlevel"] < 3 then
        --todo

        local modelPosYAdj = 4
        self.dokbEntrySheildModel_ = display.newScale9Sprite("#rounded_rect_10.png", - BRICK_DISTANCE * 1.5, - bgY + personalBrickHeight / 2 - modelPosYAdj, cc.size(BRICK_WIDTH - 16, (BRICK_HEIGHT - 14) / 2))
            :addTo(self.moreChipNode_)

        local proRoomLockPosAdj = {
            x = 5,
            y = 18
        }
        self.lockDokbEntry_ = display.newSprite("#ngtip_lock.png")
            :pos(- BRICK_DISTANCE * 1.5 - proRoomLockPosAdj.x, - bgY + personalBrickHeight / 2 + proRoomLockPosAdj.y)
            :addTo(self.moreChipNode_)

        local lockTipsLblParam = {
            frontSize = 18,
            color = display.COLOR_WHITE
        }

        local proRoomLockTipPosYAdj = 18
        self.lockDokbTips_ = display.newTTFLabel({text = bm.LangUtil.getText("NEWER", "OPEN_HIGHER_LV3"), size = lockTipsLblParam.frontSize, color = lockTipsLblParam.color, align = ui.TEXT_ALIGN_CENTER})
            :pos(- BRICK_DISTANCE * 1.5 - proRoomLockPosAdj.x, - bgY + personalBrickHeight / 2 - proRoomLockTipPosYAdj)
            :addTo(self.moreChipNode_)
    end

    -- 普通场
    self.norHallNode_ = display.newNode()
        :addTo(self.halfBottomNode_, 1)
    display.newSprite("#nor_room_brick_btn_bg.png")
        :pos(-BRICK_DISTANCE * 0.5, -bgY)
        :addTo(self.norHallNode_)
    self.norRoomBtn_ = cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#rounded_rect_10.png"}, {scale9 = true})
        :setButtonSize(BRICK_WIDTH - 16, BRICK_HEIGHT - 16)
        :pos(-BRICK_DISTANCE * 0.5, -bgY)
        :addTo(self.norHallNode_)
        :onButtonClicked(buttontHandler(self, self.onNorHallClick))

    -- 专业场(比赛场)
    self.proHallNode_ = display.newNode()
        :addTo(self.halfBottomNode_, 1)
    display.newSprite("#pro_room_brick_btn_bg.png")
        :pos(BRICK_DISTANCE * 0.5, -bgY)
        :addTo(self.proHallNode_)
    self.porRoomBtn_ = cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#rounded_rect_10.png", disabled = "#common_transparent_skin.png"}, {scale9 = true})
        :setButtonSize(BRICK_WIDTH - 16, BRICK_HEIGHT - 16)
        :pos(BRICK_DISTANCE * 0.5, -bgY)
        :addTo(self.proHallNode_)        
        :onButtonClicked(buttontHandler(self, self.onMatchHallClick))

    local userLevelFact = nk.Level:getLevelByExp(nk.userData["aUser.exp"])
    if userLevelFact < 3 or nk.userData["aUser.mlevel"] < 3 then
        --todo
        -- self.porRoomBtn_:setButtonEnabled(false)
        self.proRoomSheildModel_ = display.newScale9Sprite("#rounded_rect_10.png", BRICK_DISTANCE * 0.5, - bgY, cc.size(BRICK_WIDTH - 16, BRICK_HEIGHT - 16))
            :addTo(self.proHallNode_)

        local proRoomLockPosAdj = {
            x = 5,
            y = 18
        }
        self.lockProRoom_ = display.newSprite("#ngtip_lock.png")
            :pos(BRICK_DISTANCE * 0.5 - proRoomLockPosAdj.x, - bgY + proRoomLockPosAdj.y)
            :addTo(self.proHallNode_)

        local lockTipsLblParam = {
            frontSize = 18,
            color = display.COLOR_WHITE
        }

        local proRoomLockTipPosYAdj = 18
        self.lockProRoomTips_ = display.newTTFLabel({text = bm.LangUtil.getText("NEWER", "OPEN_HIGHER_LV3"), size = lockTipsLblParam.frontSize, color = lockTipsLblParam.color, align = ui.TEXT_ALIGN_CENTER})
            :pos(BRICK_DISTANCE * 0.5 - proRoomLockPosAdj.x, - bgY - proRoomLockTipPosYAdj)
            :addTo(self.proHallNode_)
    end

    -- 快速开始
    self.playNowNode_ = display.newNode()
        :addTo(self.halfBottomNode_, 1)
    display.newSprite("#play_now_brick_btn_bg.png")
        :pos(BRICK_DISTANCE * 1.5, -bgY)
        :addTo(self.playNowNode_)
    cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#rounded_rect_10.png"}, {scale9 = true})
        :setButtonSize(BRICK_WIDTH - 16, BRICK_HEIGHT - 16)
        :pos(BRICK_DISTANCE * 1.5, -bgY)
        :addTo(self.playNowNode_)
        :onButtonClicked(buttontHandler(self, self.onPlayNowClick))


    -- 底部裁剪区域（显示更多筹码展开panel）
    local stencil = display.newDrawNode()
    stencil:drawPolygon({
            {-display.width * 0.5, -display.height * 0.5 + MORE_CHIP_PANEL_HEIGHT}, 
            {-display.width * 0.5, -display.height * 0.5}, 
            { display.width * 0.5, -display.height * 0.5}, 
            { display.width * 0.5, -display.height * 0.5 + MORE_CHIP_PANEL_HEIGHT}
        })
    self.panelClipNode_ = cc.ClippingNode:create()
        :addTo(self.halfBottomNode_, 3)
    self.panelClipNode_:setStencil(stencil)

    -- 底部背景
    self.bottomPanelNode_ = display.newNode()
        :addTo(self.halfBottomNode_)
    display.newScale9Sprite("#bottom_panel_bg.png", 0, 0, cc.size(display.width, BOTTOM_PANEL_HEIGHT))
        :pos(0, -display.cy + BOTTOM_PANEL_HEIGHT * 0.5)
        :addTo(self.bottomPanelNode_)
    display.newTilesSprite("repeat/panel_repeat_tex.png", cc.rect(0, 0, display.width, BOTTOM_PANEL_HEIGHT))
        :pos(-display.cx, -display.cy)
        :addTo(self.bottomPanelNode_)

    -- 用户信息按钮
    self.userInfoBtn_ = cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#main_hall_bottom_down.png"}, {scale9 = true})
        :setButtonSize(BOTTOM_USER_INFO_WIDTH, BOTTOM_PANEL_HEIGHT - 2)
        :pos(-display.cx + BOTTOM_USER_INFO_WIDTH * 0.5, -display.cy + BOTTOM_PANEL_HEIGHT * 0.5 - 1)
        :addTo(self.bottomPanelNode_)
        :onButtonClicked(buttontHandler(self, self.onUserInfoBtnClicked))

    -- 头像边框
    display.newScale9Sprite("#user_avatar_frame.png", 0, 0, cc.size(82, 82))
        :align(display.LEFT_CENTER, -display.cx + 12, -display.cy + BOTTOM_PANEL_HEIGHT * 0.5 - 2)
        :addTo(self.bottomPanelNode_)

    -- 默认头像
    display.newSprite("#common_male_avatar.png")
        :scale(0.82)
        :align(display.LEFT_CENTER, -display.cx + 12, -display.cy + BOTTOM_PANEL_HEIGHT * 0.5 - 2)
        :addTo(self.bottomPanelNode_, 0, AVATAR_TAG)

    -- 昵称
    self.nick_ = display.newTTFLabel({text = "", color = styles.FONT_COLOR.LIGHT_TEXT, size = 24, align = ui.TEXT_ALIGN_CENTER})
        :align(display.LEFT_CENTER, -display.cx + 104, -display.cy + BOTTOM_PANEL_HEIGHT - 24)
        :addTo(self.bottomPanelNode_)

    -- 筹码
    display.newSprite("#chip_icon.png")
        :align(display.LEFT_CENTER, -display.cx + 104, -display.cy + BOTTOM_PANEL_HEIGHT - 56)
        :addTo(self.bottomPanelNode_)
    self.money_ = display.newTTFLabel({text = "", color = styles.FONT_COLOR.GOLDEN_TEXT, size = 24, align = ui.TEXT_ALIGN_CENTER})
        :align(display.LEFT_CENTER, -display.cx + 104 + 32, -display.cy + BOTTOM_PANEL_HEIGHT - 56)
        :addTo(self.bottomPanelNode_)

    -- 等级
    self.level_ = display.newTTFLabel({text = "", color = styles.FONT_COLOR.LIGHT_TEXT, size = 18, align = ui.TEXT_ALIGN_CENTER})
        :align(display.LEFT_CENTER, -display.cx + 104, -display.cy + BOTTOM_PANEL_HEIGHT - 86)
        :addTo(self.bottomPanelNode_)

    -- 经验条
    local expBarWidth = 130 * nk.widthScale
    self.expBar_ = nk.ui.ProgressBar.new(
        "#blue_exp_progress_bar_bg.png", 
        "#blue_exp_progress_bar_fill.png", 
        {
            bgWidth = expBarWidth, 
            bgHeight = 12, 
            fillWidth = 12, 
            fillHeight = 12
        }
    )
        :pos(-display.cx + 104 + 52, -display.cy + BOTTOM_PANEL_HEIGHT - 86)
        :addTo(self.bottomPanelNode_)

    -- 商城按钮
    cc.ui.UIPushButton.new({normal = "#store_btn_up.png", pressed = "#store_btn_down.png"}, {scale9 = true})
        :setButtonSize(BOTTOM_MAIN_BTN_WIDTH + 12, 110)
        :pos(-display.cx + BOTTOM_USER_INFO_WIDTH + BOTTOM_MAIN_BTN_WIDTH * 0.5, -display.cy + 110 * 0.5)
        :addTo(self.bottomPanelNode_)
        :add(display.newSprite("#store_btn_icon.png")
            :pos(0, 16))
        :add(display.newTTFLabel({text = bm.LangUtil.getText("HALL", "STORE_BTN_TEXT"), color = cc.c3b(0x94, 0x2e, 0x24), size = 28, align = ui.TEXT_ALIGN_CENTER})
            :pos(0, -24))
        :onButtonClicked(buttontHandler(self, self.onStoreBtnClicked))

    -- 好友按钮
    local friendIcon = display.newSprite("#friend_btn_icon_up.png"):pos(0, 16)
    local friendTxtUp = display.newTTFLabel({text = bm.LangUtil.getText("HALL", "FRIEND_BTN_TEXT"), color = cc.c3b(0xca, 0xca, 0xca), size = 28, align = ui.TEXT_ALIGN_CENTER}):pos(0, -24)
    local friendTxtDown = display.newTTFLabel({text = bm.LangUtil.getText("HALL", "FRIEND_BTN_TEXT"), color = cc.c3b(0x51, 0xB3, 0xFF), size = 28, align = ui.TEXT_ALIGN_CENTER}):pos(0, -24):hide()
    cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#main_hall_bottom_btn_down.png"}, {scale9 = true})
        :setButtonSize(BOTTOM_MAIN_BTN_WIDTH - 45, 90)
        :pos(-display.cx + BOTTOM_USER_INFO_WIDTH + BOTTOM_MAIN_BTN_WIDTH * 1.4, -display.cy + BOTTOM_PANEL_HEIGHT * 0.5 - 2)
        :addTo(self.bottomPanelNode_)
        :add(friendIcon)
        :add(friendTxtUp):add(friendTxtDown)
        :onButtonClicked(buttontHandler(self, self.onFriendBtnClicked))
        :onButtonPressed(function()
            friendIcon:setSpriteFrame(display.newSpriteFrame("friend_btn_icon_down.png"))
            friendTxtUp:hide()
            friendTxtDown:show()
        end)
        :onButtonRelease(function()
            friendIcon:setSpriteFrame(display.newSpriteFrame("friend_btn_icon_up.png"))
            friendTxtUp:show()
            friendTxtDown:hide()
        end)

    -- 排行按钮
    local rankingIcon = display.newSprite("#ranking_btn_icon_up.png"):pos(0, 16)
    local rankingTxtUp = display.newTTFLabel({text = bm.LangUtil.getText("HALL", "RANKING_BTN_TEXT"), color = cc.c3b(0xca, 0xca, 0xca), size = 28, align = ui.TEXT_ALIGN_CENTER}):pos(0, -24)
    local rankingTxtDown = display.newTTFLabel({text = bm.LangUtil.getText("HALL", "RANKING_BTN_TEXT"), color = cc.c3b(0x51, 0xB3, 0xFF), size = 28, align = ui.TEXT_ALIGN_CENTER}):pos(0, -24):hide()
    cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#main_hall_bottom_btn_down.png"}, {scale9 = true})
        :setButtonSize(BOTTOM_MAIN_BTN_WIDTH - 45, 90)
        :pos(-display.cx + BOTTOM_USER_INFO_WIDTH + BOTTOM_MAIN_BTN_WIDTH * 2.1+3 , -display.cy + BOTTOM_PANEL_HEIGHT * 0.5 - 2)
        :addTo(self.bottomPanelNode_)
        :add(rankingIcon)
        :add(rankingTxtUp):add(rankingTxtDown)
        :onButtonClicked(buttontHandler(self, self.onRankingBtnClicked))
        :onButtonPressed(function()
            rankingIcon:setSpriteFrame(display.newSpriteFrame("ranking_btn_icon_down.png"))
            rankingTxtUp:hide()
            rankingTxtDown:show()
        end)
        :onButtonRelease(function()
            rankingIcon:setSpriteFrame(display.newSpriteFrame("ranking_btn_icon_up.png"))
            rankingTxtUp:show()
            rankingTxtDown:hide()
        end)

        -- 兑换商城按钮
        local scroreMarketNewIcon = display.newSprite("#score_market_btn_new_icon.png"):pos(- 42, 26)
        local scoreMarketIcon = display.newSprite("#score_market_btn_icon_up.png"):pos(0, 16)
        local scoreMarketTxtUp = display.newTTFLabel({text = bm.LangUtil.getText("HALL", "SCORE_MARKET_BTN_TEXT"), color = cc.c3b(0xca, 0xca, 0xca), size = 28, align = ui.TEXT_ALIGN_CENTER}):pos(0, -24)
        local scoreMarketTxtDown = display.newTTFLabel({text = bm.LangUtil.getText("HALL", "SCORE_MARKET_BTN_TEXT"), color = cc.c3b(0x51, 0xB3, 0xFF), size = 28, align = ui.TEXT_ALIGN_CENTER}):pos(0, -24):hide()
        cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#main_hall_bottom_btn_down.png"}, {scale9 = true})
            :setButtonSize(BOTTOM_MAIN_BTN_WIDTH - 45, 90)
            :pos(-display.cx + BOTTOM_USER_INFO_WIDTH + BOTTOM_MAIN_BTN_WIDTH * 2.8 + 3, -display.cy + BOTTOM_PANEL_HEIGHT * 0.5 - 2)
            :addTo(self.bottomPanelNode_)
            :add(scoreMarketIcon)
            :add(scoreMarketTxtUp):add(scoreMarketTxtDown)
            :add(scroreMarketNewIcon)
            :onButtonClicked(buttontHandler(self, self.onScoreMarketBtnClicked))
            :onButtonPressed(function()
                scoreMarketIcon:setSpriteFrame(display.newSpriteFrame("score_market_btn_icon_down.png"))
                scoreMarketTxtUp:hide()
                scoreMarketTxtDown:show()
            end)
            :onButtonRelease(function()
                scoreMarketIcon:setSpriteFrame(display.newSpriteFrame("score_market_btn_icon_up.png"))
                scoreMarketTxtUp:show()
                scoreMarketTxtDown:hide()
            end)


    -- 消息按钮
    local msgIcon = display.newSprite("#message_btn_icon_up.png"):pos(0, -3)
    cc.ui.UIPushButton.new({normal = "#bottom_sub_btn_up.png", pressed = "#bottom_sub_btn_down.png"}, {scale9=true})
        :setButtonSize(90, 60)
        :pos(-display.cx + BOTTOM_USER_INFO_WIDTH + BOTTOM_MAIN_BTN_WIDTH * 3 + BOTTOM_SUB_BTN_WIDTH * 0.5 + 24, -display.cy + BOTTOM_PANEL_HEIGHT * 0.5 - 1)
        :addTo(self.bottomPanelNode_)
        :add(msgIcon)
        :onButtonClicked(buttontHandler(self, self.onMessageBtnClicked))
        :onButtonPressed(function()
            msgIcon:setSpriteFrame(display.newSpriteFrame("message_btn_icon_down.png"))
        end)
        :onButtonRelease(function()
            msgIcon:setSpriteFrame(display.newSpriteFrame("message_btn_icon_up.png"))
        end)

    -- new message point
    self.newMessagePoint = display.newSprite("#common_small_point.png")
        :pos(-display.cx + BOTTOM_USER_INFO_WIDTH + BOTTOM_MAIN_BTN_WIDTH * 3 + BOTTOM_SUB_BTN_WIDTH * 0.5 + 24 + 45, -display.cy + BOTTOM_PANEL_HEIGHT * 0.5 - 1 + 30)
        :addTo(self.bottomPanelNode_)
    if MessageData.hasNewMessage then
        self.newMessagePoint:show()
    else
        self.newMessagePoint:hide()
    end


    self.updateVerBtn_ = cc.ui.UIPushButton.new("#update_ver_icon.png", {scale9 = false})
        :pos(-display.cx + 60 + logPosAdjust.x, display.cy - 88 - logPosAdjust.y - self.gameLogo_:getContentSize().height-10)
        :onButtonClicked(buttontHandler(self, self.onUpdateVerBtnClicked))
        :addTo(self.halfTopNode_)
        :hide()

    -- 新手奖励
    self.newerGuideBtn_ = cc.ui.UIPushButton.new({normal = "newerguide/newer_purple_up.png", pressed = "newerguide/newer_purple_down.png"})
        :align(display.CENTER_LEFT,-display.cx,display.cy - 85 - logPosAdjust.y - self.gameLogo_:getContentSize().height)
        :onButtonClicked(buttontHandler(self, self.onNewerGuideBtnClicked))
        :setButtonLabel(display.newTTFLabel({text = "",size=24, color=cc.c3b(0xff, 0xff, 0xff), align=ui.TEXT_ALIGN_CENTER}))
        :addTo(self.halfTopNode_)
        :hide()

    -- 设置按钮
    local settingIcon = display.newSprite("#setting_btn_icon_up.png"):pos(0, -3)
    cc.ui.UIPushButton.new({normal = "#bottom_sub_btn_up.png", pressed = "#bottom_sub_btn_down.png"}, {scale9=true})
        :setButtonSize(90, 60)
        :pos(-display.cx + BOTTOM_USER_INFO_WIDTH + BOTTOM_MAIN_BTN_WIDTH * 3 + BOTTOM_SUB_BTN_WIDTH * 1.5 + 24 + 24, -display.cy + BOTTOM_PANEL_HEIGHT * 0.5 - 1)
        :addTo(self.bottomPanelNode_)
        :add(settingIcon)
        :onButtonClicked(buttontHandler(self, self.onSettingBtnClicked))
        :onButtonPressed(function()
            settingIcon:setSpriteFrame(display.newSpriteFrame("setting_btn_icon_down.png"))
        end)
        :onButtonRelease(function()
            settingIcon:setSpriteFrame(display.newSpriteFrame("setting_btn_icon_up.png"))
        end)

    if nk.config.CHRISTMAS_THEME_ENABLED then
        if not nk.userData.__christmas then
            audio.playMusic("sounds/Christmas.mp3", false)
            nk.userData.__christmas = true
        end

        display.addSpriteFrames("christmas_texture.plist", "christmas_texture.png")

        -- 大的灯笼
        self.smallLanternNode = display.newNode()
            :pos(display.cx - 370, display.cy - 23)
            :addTo(self)

        self.smallLanternIcon_ = display.newSprite("#christmas-big-lantern.png")
            :pos(0, -23)
            :addTo(self.smallLanternNode)

        local smallLanternSequenceAct = transition.sequence({
            cc.RotateTo:create(5,10), 
            cc.RotateTo:create(5,-10)
            })
        self.smallLanternNode:runAction(cc.RepeatForever:create(smallLanternSequenceAct))

        -- 小的灯笼
        self.bigLanternNode = display.newNode()
            :pos(display.cx - 300, display.cy - 17)
            :addTo(self)

        self.bigLanternIcon_ = display.newSprite("#christmas-small-lantern.png")
            :pos(0, -73)
            :addTo(self.bigLanternNode)

        local bigLanternSequenceAct = transition.sequence({
            cc.RotateTo:create(5,10), 
            cc.RotateTo:create(5,-10)
            })
        self.bigLanternNode:runAction(cc.RepeatForever:create(bigLanternSequenceAct))

        -- 圣诞袜子
        self.socksNode_ = display.newNode()
            :pos(display.c_left + 250 , display.cy - 23)
            :addTo(self)

        self.socksIcon_ = display.newSprite("#chiristmas-sock.png")
            :pos(0 ,  - 73)
            :addTo(self.socksNode_)

        local socksSequenceAct = transition.sequence({
            cc.RotateTo:create(5,10), 
            cc.RotateTo:create(5,-10)
            })
        self.socksNode_:runAction(cc.RepeatForever:create(socksSequenceAct))

        -- Remove Logo Snow.
        -- self.logoSnow_ = display.newSprite("#christmas-game-logo.png")
        --     :pos(- display.cx + 140, display.cy - 130)
        --     :addTo(self.halfTopNode_)

        self.inviteFriendRightSnow_ = display.newSprite("#chiristmas-invite-friend-right.png")
            :pos(display.cx - 60, display.cy - 77)
            :addTo(self.halfTopNode_)

        self.inviteFriendDownSnow_ = display.newSprite("#chiristmas-invite-friend-down.png")
            :pos(display.cx - 150, display.cy - 123)
            :addTo(self.halfTopNode_)


        self.snowIcon_1 = display.newSprite("#christmas-free-chip-snow.png")
            :pos(-BRICK_DISTANCE * 1.5, -bgY + 54)
            :addTo(self.moreChipNode_)

        self.snowIcon_2 = display.newSprite("#christmas-normal-room-snow.png")
            :pos(-BRICK_DISTANCE * 0.5, -bgY + 56)
            :addTo(self.norHallNode_)

        self.snowIcon_3 = display.newSprite("#christmas-professional-room-snow.png")
            :pos(BRICK_DISTANCE * 0.5, -bgY + 56)
            :addTo(self.proHallNode_)

        self.snowIcon_4 = display.newSprite("#christmas-quick-room-snow.png")
            :pos(BRICK_DISTANCE * 1.5, -bgY + 54)
            :addTo(self.playNowNode_)

        -- 加上两张冰窗效果！
        local snowWindowLeftPosShift = {
            x = 75,
            y = 72
        }
        local snowWindowStateLeft = display.newSprite("#christ_snowCorner_right.png")
            :rotation(90)
            :pos(- display.cx + snowWindowLeftPosShift.x, - display.cy + BOTTOM_PANEL_HEIGHT + snowWindowLeftPosShift.y)
            :addTo(self.bottomPanelNode_)

        local snowWindowRightPosShift = {
            x = 75,
            y = 72
        }

        local snowWindowStateRight = display.newSprite("#christ_snowCorner_right.png")
            :pos(display.cx - snowWindowRightPosShift.x, - display.cy + BOTTOM_PANEL_HEIGHT + snowWindowRightPosShift.y)
            :addTo(self.bottomPanelNode_)


        self.userInfoSnow_ = display.newSprite("#christmas-person-informal-snow.png")
            :pos(-display.cx + BOTTOM_USER_INFO_WIDTH * 0.5 - 58, -display.cy + BOTTOM_PANEL_HEIGHT * 0.5 + 50)
            :addTo(self.bottomPanelNode_)

        -- 圣诞树
        self.settingSnowIcon_ = display.newSprite("#christmas-tree-snow.png")
            :pos(-display.cx + BOTTOM_USER_INFO_WIDTH + BOTTOM_MAIN_BTN_WIDTH * 3 + BOTTOM_SUB_BTN_WIDTH * 1.5 + 66, -display.cy + BOTTOM_PANEL_HEIGHT * 0.5 + 77)
            :addTo(self.bottomPanelNode_)

        -- 雪花效果
        self.newSnow_ = display.newNode()
            :addTo(self)
            
        local emitter = cc.ParticleSystemQuad:create("particle_texture.plist")
        emitter:pos(0, display.cy)
        emitter:addTo(self.newSnow_)
    end

    -- 宋干节
    if nk.config.SONGKRAN_THEME_ENABLED then

        display.addSpriteFrames("songkran_texture.plist", "songkran_texture.png")
        
        -- 左边
        self.songkranHallLeft_ = display.newSprite("#songkran_hall_left.png")
        local leftSize = self.songkranHallLeft_:getContentSize()
        self.songkranHallLeft_:pos(-display.cx + leftSize.width / 2, -display.cy + BOTTOM_PANEL_HEIGHT - 1 + leftSize.height / 2)
        self.songkranHallLeft_:addTo(self.bottomPanelNode_)
        
        -- 右边
        self.songkranHallRight_ = display.newSprite("#songkran_hall_right.png")
        local rightSize = self.songkranHallRight_:getContentSize()
        self.songkranHallRight_:pos(display.cx - rightSize.width / 2, -display.cy + BOTTOM_PANEL_HEIGHT - 1 + rightSize.height / 2)
        self.songkranHallRight_:addTo(self.bottomPanelNode_)

        -- moreChip水滴
        self.songKranHallMoreChip = display.newSprite("#songkran_hall_morechip.png")
            :pos(-BRICK_DISTANCE * 1.5, -bgY)
            :addTo(self.moreChipNode_)

        -- combat水滴
        self.songKranHallMoreChip = display.newSprite("#songkran_hall_combat.png")
            :pos(-BRICK_DISTANCE * 0.5, -bgY)
            :addTo(self.norHallNode_)
        
        -- 2 cards水滴
        self.songKranHallMoreChip = display.newSprite("#songkran_hall_2_cards.png")
            :pos(BRICK_DISTANCE * 0.5, -bgY)
            :addTo(self.proHallNode_)

        -- PlayNow水滴
        self.songKranHallMoreChip = display.newSprite("#songkran_hall_quickstart.png")
            :pos(BRICK_DISTANCE * 1.5 - 10, -bgY + 15)
            :addTo(self.playNowNode_)
    end


    -- 头像加载id
    self.userAvatarLoaderId_ = nk.ImageLoader:nextLoaderId()

    self.discountTagBg_ = display.newSprite("#store_discount_tag_bg.png")
        :pos(-display.cx + BOTTOM_USER_INFO_WIDTH + BOTTOM_MAIN_BTN_WIDTH - 12, -display.cy + 110 -20)
        :addTo(self.bottomPanelNode_)
        :hide()
    self.discountTagText_ = display.newTTFLabel({text = "", color = cc.c3b(0xF6, 0xDF, 0x64), size = 20, align = ui.TEXT_ALIGN_CENTER})
        :pos(-display.cx + BOTTOM_USER_INFO_WIDTH + BOTTOM_MAIN_BTN_WIDTH - 12, -display.cy + 110 -20)
        :rotation(14)
        :addTo(self.bottomPanelNode_)
        :hide()

    -- 添加数据观察器
    self:addPropertyObservers()

     -- init analytics
    -- if device.platform == "android" or device.platform == "ios" then
        -- cc.analytics:start("analytics.UmengAnalytics")
    -- end

    local signInBtnPosAdjust = {
        x = 80,
        y = 150
    }

    local function addFlashBarClip()
        -- body
        local newstActNodePosShift = {
            x = 1,
            y = 6
        }

        self._newstActNode = cc.ClippingNode:create()
            :addTo(self.halfTopNode_)
            :pos(display.cx - signInBtnPosAdjust.x - newstActNodePosShift.x, display.cy - signInBtnPosAdjust.y + newstActNodePosShift.y)
       

        -- local lightCoinSize = {
        --     width = 66,
        --     height = 66
        -- }

        -- local lightBarClipRect = {
        --     src = {
        --         x = 1,
        --         y = 1
        --     },

        --     dest = {
        --         x = 72,
        --         y = 20
        --     }
        -- }

        -- local lightBarStencil = display.newScale9Sprite("#newest_act_hallEntry_icon.png", 0, 0, cc.size(lightCoinSize.width,
        --     lightCoinSize.height), cc.rect(lightBarClipRect.dest.x, lightBarClipRect.dest.y, lightBarClipRect.org.x, lightBarClipRect.org.y))
        local lightBarStencil = display.newSprite("#newest_act_hallEntry_icon.png")

        self._newstActNode:setStencil(lightBarStencil)
        self._newstActNode:setAlphaThreshold(0.01)
        -- self._newstActNode:setInverted(true)

        self._coinLightBar = display.newSprite("#store_btn_up.png")
        local coinLightShownSize = {
            width = 20,
            height = 120
        }

        self._coinLightBar:setScaleX(coinLightShownSize.width / self._coinLightBar:getContentSize().width)
        self._coinLightBar:setScaleY(coinLightShownSize.height / self._coinLightBar:getContentSize().height)
        -- self._coinLightBar = display.newScale9Sprite("#store_btn_up.png", 0, 0, cc.size(coinLightShownSize.width, coinLightShownSize.height))

        self._coinLightBar:setBlendFunc(GL_DST_COLOR, GL_ONE)

        local Ssz = lightBarStencil:getContentSize()
        local isz = self._coinLightBar:getContentSize()

        self._coinLeftX = - Ssz.width * 0.5 - isz.width * 1.5
        self._coinRightX = Ssz.width * 0.5 + isz.width * 1.5

        self._coinLightBar:pos(self._coinLeftX, 0)
        self._coinLightBar:rotation(40)
        -- self._coinLightBar:scale(0.6)
        self._coinLightBar:setVisible(false)
        self._newstActNode:addChild(self._coinLightBar)
    end

    local signInBtn = cc.ui.UIPushButton.new("#newest_act_hallEntry_icon.png", {scale9 = false})
        :pos(display.cx - signInBtnPosAdjust.x, display.cy - signInBtnPosAdjust.y)
        :onButtonClicked(buttontHandler(self, self._onSignInBtnCallBack))
        :addTo(self.halfTopNode_)

    -- signInBtn:setScale(0.75)

    -- 这里增加闪光特效模板和裁剪 --
    -- addFlashBarClip()

    local newstActFlagPosYAdjust = 178

    local newstActBtnFlag = display.newSprite("#newst_act_hallFlag.png")
        :pos(display.cx - signInBtnPosAdjust.x, display.cy - newstActFlagPosYAdjust)
        :addTo(self.halfTopNode_)
    -- self._signInNewIcon = display.newSprite("#newIcon.png")
    --     :pos(newIconPosAdjust.x, newIconPosAdjust.y)

    -- self._signInNewIcon:scale(0.8)
    -- self._signInNewIcon:addTo(signInBtn)

    -- @param offset: 正值表示横向拉伸，负值表示纵向拉伸！
    local function zoom(offset, time, onComplete)
        -- body
        local x, y = signInBtn:getPosition()
        local size = {
            width = 66,
            height = 66
        }

        local scaleX = signInBtn:getScaleX() * (size.width + offset) / size.width
        local scaleY = signInBtn:getScaleY() * (size.height - offset) / size.height

        transition.moveTo(signInBtn, {y = y - offset, time = time})
        transition.scaleTo(signInBtn, {
            scaleX     = scaleX,
            scaleY     = scaleY,
            time       = time,
            onComplete = onComplete,
        })
    end

    -- 还原回去!
    local function zoom_(offset, time, onComplete)
        local x, y = signInBtn:getPosition()

        transition.moveTo(signInBtn, {y = y + offset, time = time})
        transition.scaleTo(signInBtn, {
            scaleX     = 1,
            scaleY     = 1,
            time       = time,
            onComplete = onComplete,
        })
    end

    -- @offset :正值向上移动offset距离，负值向下移动offset距离
    local function jumpMove(offset, time, onComplete)
        -- body
        local x, y = signInBtn:getPosition()

        transition.moveTo(signInBtn, {y = y + offset, time = time, onComplete = onComplete})
    end

    local function showFlashLightAnim()
        -- body 
        self._coinLightBar:setVisible(true)
        -- local moveAction = cc.MoveTo:create(0.5, cc.p(self._coinLeftX, 0))
        local moveBackAction = cc.MoveTo:create(1, cc.p(self._coinRightX, 0))
        self._coinLightBar:runAction(transition.sequence({
                -- moveAction,
                -- cc.DelayTime:create(3.0),
                moveBackAction,
                cc.DelayTime:create(0.2),
                cc.CallFunc:create(function()
                    self._coinLightBar:pos(self._coinLeftX, 0)
                    self._coinLightBar:setVisible(false)
                end)
            }))
    end

    local signInBtnActionSequenfunc = function()
        -- body
        zoom(2, 0.1, function()
            -- body
            zoom(5, 0.25, function()
                -- body
                zoom_(7, 0.25, function()
                    -- body
                    jumpMove(20, 0.3, function()
                    -- body
                        zoom(2, 0.1, function()
                            -- body
                            jumpMove(- 20, 0.3, function()
                                -- body
                                zoom(5, 0.15, function()
                                    -- body
                                    zoom_(7, 0.2, function()
                                        -- body
                                        -- 播放闪光动画
                                        -- showFlashLightAnim()
                                    end)
                                end)
                            end)
                        end)
                    end)

                end)

            end)

        end)
    end
    self._coinAnim = signInBtn:schedule(signInBtnActionSequenfunc, 3.5)


    -- plan 2 --

    -- local promtBtnPosShift = {
    --         x = 108,
    --         y = 208
    --     }

    -- self._unionActEntrance = cc.ui.UIPushButton.new("#hall_ic_prom.png", {scale9 = false})
    --         :pos(- display.cx + promtBtnPosShift.x, display.cy - promtBtnPosShift.y)
    --         :onButtonClicked(buttontHandler(self, self._onActPromtCallBack))
    --         :addTo(self.halfTopNode_)
    --         :setVisible(false)

    -- end --

    -- just for test --
    -- self:initUnionActEntryUi(true)
    -- self:initFirstChargeFavEntry(true)

    -- self:initNewsActPaopTip(true)
    --  end --
end

-- 入场动画
function MainHallView:playShowAnim()
    local animTime = self.controller_.getAnimTime()

    -- 桌子与筹码
    if self.tablePos_ == 1 then
        self.pokerTable_:pos(0, 0)
    else
        self.pokerTable_:pos(0, -(display.cy + 320))
    end
    transition.moveTo(self.pokerTable_, {time = animTime, y = -(display.cy + 146)})
    transition.moveTo(self.leftChip_,   {time = animTime, y = -(display.cy - 116)})
    transition.moveTo(self.rightChip_,  {time = animTime, y = -(display.cy - 116)})

    -- 方块panel
    local posY = -(MORE_CHIP_PANEL_HEIGHT + BRICK_HEIGHT)
    local baseDelayTime = 0.05
    self.moreChipNode_:pos(0, posY)
    transition.moveTo(self.moreChipNode_, {time = animTime, y = 0, delay = animTime + baseDelayTime * 0, easing = "BACKOUT"})
    self.norHallNode_:pos(0, posY)
    transition.moveTo(self.norHallNode_, {time = animTime, y = 0, delay = animTime + baseDelayTime * 1, easing = "BACKOUT"})
    self.proHallNode_:pos(0, posY)
    transition.moveTo(self.proHallNode_, {time = animTime, y = 0, delay = animTime + baseDelayTime * 2, easing = "BACKOUT"})
    self.playNowNode_:pos(0, posY)
    transition.moveTo(self.playNowNode_, {time = animTime, y = 0, delay = animTime + baseDelayTime * 3, easing = "BACKOUT"})

    -- 底部panel
    self.bottomPanelNode_:pos(0, -BOTTOM_PANEL_HEIGHT)
    transition.moveTo(self.bottomPanelNode_, {time = animTime, y = 0, delay = animTime + baseDelayTime * 3})

    -- 顶部panel
    self.halfTopNode_:pos(0, self.gameLogo_:getContentSize().height + 150)
    transition.moveTo(self.halfTopNode_, {time = animTime, y = 0, delay = animTime + baseDelayTime * 3, onComplete =
        handler(self, function(obj)
            --楼下这段十分飘逸的逻辑，，
            --在玩家在房间内收到来自其他玩家的私人房邀请的时候
            --只做提示，，待到他退出到大厅的时候，并且时间间隔
            --5分钟之内，则弹出提示！
            if nk.userData["inviteRoomData"] then
                local tid = nk.userData["inviteRoomData"].tid
                local inviteName = nk.userData["inviteRoomData"].inviteName;
                local content_ = bm.LangUtil.getText("HALL","PERSONAL_ROOM_INVITE_CONTENT",inviteName);
                local currentTime_ = os.time()
                local leftTime_ = currentTime_ - nk.userData["inviteRoomData"].time;
                if leftTime_ <= 300 then
                    nk.ui.Dialog.new({
                                    messageText = content_,
                                    callback = function (type)
                                        if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                                            nk.server:searchPersonalRoom(nil,tid)
                                        end
                                    end
                                })
                                    :show()
                    nk.userData["inviteRoomData"] = nil
                    return
                end
            end

            local invitePopupdateDate = nk.userDefault:getStringForKey(nk.cookieKeys.DALIY_POPUP_INVITABLE)
            if invitePopupdateDate ~= os.date("%Y%m%d") then

                local lastLoginType = nk.userDefault:getStringForKey(nk.cookieKeys.LAST_LOGIN_TYPE)
                if lastLoginType ~= "GUEST" and nk.userData['aUser.mlevel'] >= 3 then

                        local codeNum = bm.DataProxy:getData(nk.dataKeys.FARM_TIPS)
                        if codeNum == 1 then
                            local lastEnterScene = bm.DataProxy:getData(nk.dataKeys.LAST_ENTER_SCENE)
                            if (lastEnterScene ~= nil ) and (lastEnterScene == "RoomScene") then
                                    --优先弹邀请活动框
                                nk.userDefault:setStringForKey(nk.cookieKeys.DALIY_POPUP_INVITABLE, os.date("%Y%m%d"))
                                nk.ui.Dialog.new({
                                    hasCloseButton = true,
                                    messageText = bm.LangUtil.getText("DORNUCOPIA", "HALL_TIPS"), 
                                    callback = function (type)
                                        if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                                                 CornuPopup.new():show()
                                        elseif type == nk.ui.Dialog.FIRST_BTN_CLICK or type == nk.ui.Dialog.CLOSE_BTN_CLICK then

                                        end
                                    end
                                }):show()
                                bm.DataProxy:setData(nk.dataKeys.FARM_TIPS, -3)
                            end
                        end
                end
       
    
                local invitePopupdateDate = nk.userDefault:getStringForKey(nk.cookieKeys.DALIY_POPUP_INVITABLE)
                if invitePopupdateDate ~= os.date("%Y%m%d") then
                    --[[
                    nk.userDefault:setStringForKey(nk.cookieKeys.DALIY_POPUP_INVITABLE, os.date("%Y%m%d"))  
                    NewestActPopup.new(1,function(action)
                        if action == "invite" then
                            if self and self["onInviteBtnClick"] then
                                self:onInviteBtnClick()
                            end
                        elseif action == "openShop" then
                            if self and self["onStoreBtnClicked"] then
                                -- self:onStoreBtnClicked()
                                StorePopup.new(nil,PURCHASE_TYPE.BLUE_PAY):showPanel()
                            end
                        end
                    end):show()
                    --]]
                else
                    --从房间回来，一个feed逻辑
                    if nk.userData["aUser.conWinNum_"] and nk.userData["aUser.conWinNum_"] == 5 then
                        nk.ui.Dialog.new({
                                    messageText = bm.LangUtil.getText("HALL","SHARE_CONWIN_FIVE"),
                                    callback = function (type)
                                        if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                                            nk.sendFeed:win_five_()
                                        end
                                    end
                                })
                                    :show()
                    elseif nk.userData["aUser.card_five_multiple_"] and nk.userData["aUser.card_five_multiple_"]==1  then
                       nk.ui.Dialog.new({
                                    messageText = bm.LangUtil.getText("HALL","SHARE_FIVE_CARD"),
                                    callback = function (type)
                                        if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                                            nk.sendFeed:five_Card_()
                                        end
                                    end
                                })
                                :show()
                    end

                end



            end
            

            nk.userData["aUser.conWinNum_"] = nil;
            nk.userData["aUser.card_five_multiple_"] = nil;
        end
        )
    })
end

-- 出场动画
function MainHallView:playHideAnim()
    local animTime = self.controller_.getAnimTime()

    if self and self.pokerTable_ then
        --todo
        self.pokerTable_:removeFromParent()
        self.pokerTable_ = nil
    end
    
    transition.moveTo(self.halfTopNode_, {time = animTime, y = self.gameLogo_:getContentSize().height + 80})
    transition.moveTo(self.tableNode_, {time = animTime, y = -(MORE_CHIP_PANEL_HEIGHT + BRICK_HEIGHT)})
    transition.moveTo(self.halfBottomNode_, {
        time = animTime, 
        y = -(MORE_CHIP_PANEL_HEIGHT + BRICK_HEIGHT), 
        onComplete = handler(self, function (obj)
            obj:removeFromParent()
        end)
    })
end

function MainHallView:initUnionActEntryUi(isOpen)
    -- body

    if isOpen then
        -- display.addSpriteFrames("pokdeng_ad_texture.plist", "pokdeng_ad_texture.png")
        -- cc.ui.UIPushButton.new({normal = "#pokdeng_ad_popup_open.png"})
        --     :pos(-display.cx + 108, display.cy - 208)
        --     :addTo(self.halfTopNode_)
        --     :onButtonClicked(buttontHandler(self, self.onPokdengAdClick_))

        -- plan 1 --

        if not self._unionActEntrance then
            --todo
            local promtBtnPosShift = {
                x = 108,
                y = 208
            }

        self._unionActEntrance = cc.ui.UIPushButton.new("#hall_ic_prom.png", {scale9 = false})
            :pos(- display.cx + promtBtnPosShift.x, display.cy - promtBtnPosShift.y)
            :onButtonClicked(buttontHandler(self, self._onActPromtCallBack))
            :addTo(self.halfTopNode_)
        end
        
        -- end --


        -- plan 2 --
        -- self._unionActEntrance:setVisible(true)
        -- end --
    else

        -- plan 1 --
        if self._unionActEntrance then
            --todo
            self._unionActEntrance:removeFromParent()
            self._unionActEntrance = nil
        end

        -- end -- 

        -- plan 2 --
        -- self._unionActEntrance:setVisible(false)
        -- plan 2 --
    end
end

function MainHallView:initFirstChargeFavEntry(isOpen)
    -- body
    if isOpen then
        --todo

        if not self._firstChargeFavEntrance then
            --todo

            local firstChargeFavBtnPosAdjust = {
                x = 160,
                y = 150,
            }

            local firstChargeIconPath = nil

            if device.platform == "android" or device.platform == "windows" then
                --todo
                if nk.OnOff:check("firstchargeFavGray") then
                    --todo
                    firstChargeIconPath = "#chgFirFav_entry.png"
                else
                    firstChargeIconPath = "#chargeFav_entry.png"
                end
            elseif device.platform == "ios" then
                --todo
                if nk.OnOff:check("firstchargeFavGray") then
                    --todo
                    firstChargeIconPath = "#chgFirFav_entry.png"
                else
                    firstChargeIconPath = "#chargeFav_entry_ios.png"
                end
                -- firstChargeIconPath = "#chargeFav_entry_ios.png"
            end

            self._firstChargeFavEntrance = cc.ui.UIPushButton.new(firstChargeIconPath, {scale9 = false})
                :pos(display.cx - firstChargeFavBtnPosAdjust.x, display.cy - firstChargeFavBtnPosAdjust.y)
                :onButtonClicked(buttontHandler(self, self._onFirstChargeFavBtnCallBack))
                :addTo(self.halfTopNode_)
            -- self._firstChargeFavEntrance:setScale(0.75)
        else
            local firstChargeIconPath = nil

            if device.platform == "android" or device.platform == "windows" then
                --todo
                if nk.OnOff:check("firstchargeFavGray") then
                    --todo
                    firstChargeIconPath = "#chgFirFav_entry.png"
                else
                    firstChargeIconPath = "#chargeFav_entry.png"
                end
            elseif device.platform == "ios" then
                --todo
                if nk.OnOff:check("firstchargeFavGray") then
                    --todo
                    firstChargeIconPath = "#chgFirFav_entry.png"
                else
                    firstChargeIconPath = "#chargeFav_entry_ios.png"
                end
                -- firstChargeIconPath = "#chargeFav_entry_ios.png"
            end

            self._firstChargeFavEntrance:setButtonImage("normal", firstChargeIconPath)
            self._firstChargeFavEntrance:setButtonImage("pressed", firstChargeIconPath)
        end
    else

        if self._firstChargeFavEntrance then
            --todo
            self._firstChargeFavEntrance:removeFromParent()
            self._firstChargeFavEntrance = nil
        end

    end

end

function MainHallView:initAlmRechargeFavEntryUi(isOpen)
    -- body
    if isOpen then
        --todo
        if not self.almRechargeEntryBtn_ then
            --todo
            local chargeFavBtnPosAdjust = {
                x = 160,
                y = 150,
            }

            local reChargeIconResKey = {}

            reChargeIconResKey[1] = "#chgAgnFav_entry_nor.png"  -- nor
            reChargeIconResKey[2] = "#chgAgnFav_entry_pre.png"  -- pre
            reChargeIconResKey[3] = "#chgAgnFav_entry_nor.png"  -- dis

            self.almRechargeEntryBtn_ = cc.ui.UIPushButton.new({normal = reChargeIconResKey[1], pressed = reChargeIconResKey[2], disabled = reChargeIconResKey[3]},
                {scale9 = false})
                :onButtonClicked(buttontHandler(self, self.onAlmRechargeFavCallBack_))
                :pos(display.cx - chargeFavBtnPosAdjust.x, display.cy - chargeFavBtnPosAdjust.y)
                :addTo(self.halfTopNode_)
        end
    else
        if self.almRechargeEntryBtn_ then
            --todo
            self.almRechargeEntryBtn_:removeFromParent()
            self.almRechargeEntryBtn_ = nil
        end
    end
end

function MainHallView:initNewsActPaopTip(isOpen)
    -- body
    -- dump(nk.userData, "look for isFirst:===============")

    if isOpen then
        --todo
        if not self._newstActEntryPaopTip then
            --todo

            local paopTipPosAdjust = {
                x = 80,
                y = 215
            }

            self._newstActEntryPaopTip = display.newSprite("#hall_newstAct_entryTipPaop_com.png")
                :pos(display.cx - paopTipPosAdjust.x, display.cy - paopTipPosAdjust.y)
                :addTo(self.halfTopNode_)

            local tipsLabelPosShift = {
                x = 0,
                y = 4
            }

            local tipsFrontSize = 16
            local tipsLabel = display.newTTFLabel({text = bm.LangUtil.getText("HALL", "NEWSTACT_PAOPTIP"), size = tipsFrontSize, color = display.COLOR_WHITE, align = ui.TEXT_ALIGN_CENTER})
                :pos(self._newstActEntryPaopTip:getContentSize().width / 2 + tipsLabelPosShift.x, self._newstActEntryPaopTip:getContentSize().height / 2 - tipsLabelPosShift.y)
                :addTo(self._newstActEntryPaopTip)

            local function paopTipAnim()
                -- body
                self._newstActEntryPaopTip:setSpriteFrame(display.newSpriteFrame("hall_newstAct_entryTipPaop_lig.png"))
                self._newstActEntryPaopTip:performWithDelay(function ()
                    self._newstActEntryPaopTip:setSpriteFrame(display.newSpriteFrame("hall_newstAct_entryTipPaop_com.png"))
                        end, 0.45) 
            end

            self._newstActEntryPaopAnim = self._newstActEntryPaopTip:schedule(paopTipAnim, 0.9)

            self._newstActEntryPaopTip:performWithDelay(function ()
                if self._newstActEntryPaopAnim then
                    --todo
                    self:stopAction(self._newstActEntryPaopAnim)
                    self._newstActEntryPaopAnim = nil
                end

                self._newstActEntryPaopTip:removeFromParent()
                self._newstActEntryPaopTip = nil

                bm.DataProxy:setData(nk.dataKeys.HALL_NEWSTACT_PAOPTIP, false)
                end, 10.9)
        end
    else

        if self._newstActEntryPaopTip then
            --todo
            self._newstActEntryPaopTip:removeFromParent()
            self._newstActEntryPaopTip = nil
        end
    end
end

function MainHallView:addInviteBarBushAnim()
    -- body
    display.addSpriteFrames("anims/inviteBushBarAnim.plist", "anims/inviteBushBarAnim.png",function()
        if self.isOnCleanup_ then
            display.removeSpriteFramesWithFile("anims/inviteBushBarAnim.plist", "anims/inviteBushBarAnim.png")
            return
        end
        local frames = display.newFrames("invtAnim_tex_%d.png", 1, 16, false)
        local animation = display.newAnimation(frames, 1.2 / 16)
        -- display.setAnimationCache(animName, animation)
        local bushSprPosYAdj = 4
        local sp = display.newSprite()
        :pos(display.cx - 150, display.cy - 88 - bushSprPosYAdj)
        :addTo(self.halfTopNode_)
        transition.playAnimationForever(sp, animation)


    end)

    -- local bushSprPosYAdj = 4
    -- self.inviteBarBushAnimSpr_ = display.newSprite()
    --     :pos(display.cx - 150, display.cy - 88 - bushSprPosYAdj)
    --     :addTo(self.halfTopNode_)

    -- local function playOneRoundAnim()
    --     -- body
    --     local texNum = 16

    --     for i = 1, texNum do
    --         self.inviteBarBushAnimSpr_:performWithDelay(function()
    --             -- body
    --             self.inviteBarBushAnimSpr_:setSpriteFrame(display.newSpriteFrame("invtAnim_tex_" .. i .. ".png"))
    --         end, 0.06 * i)
    --     end
    -- end

    -- playOneRoundAnim()
    -- self.inviteBarBushAnimSpr_:schedule(playOneRoundAnim, 0.96)
end

function MainHallView:onSetNewerGuideDay(day)
    day = checkint(day)
    if day == 0 then
        -- if self.newerGuideBtn_ then
            -- self.newerGuideBtn_:removeFromParent()
            -- self.newerGuideBtn_ = nil
        -- end
        self.newerGuideBtn_:hide()
    elseif day == 1 then
        local firstRewardFlag = nk.NewerGuide:getFirstRewardFlag()

        if firstRewardFlag then
            self.newerGuideBtn_:hide()
        else
            self.newerGuideBtn_:show()
        end

        self.newerGuideBtn_:setButtonImage("normal","newerguide/newer_purple_up.png")
        self.newerGuideBtn_:setButtonImage("pressed","newerguide/newer_purple_down.png")
        local btnLabel = self.newerGuideBtn_:getButtonLabel()
        if btnLabel then
            btnLabel:setTextColor(cc.c3b(0xff, 0xfb, 0xde))
        end
        self.newerGuideBtn_:setButtonLabelString(bm.LangUtil.getText("NEWER", "GUIDE_HALL_BTN_LABEL_1"))

    elseif day == 2 then
        if not nk.NewerGuide or (nk.NewerGuide:isNextRewardDone()) then
            self.newerGuideBtn_:hide()
        else
            self.newerGuideBtn_:show()
          
            self.newerGuideBtn_:setButtonImage("normal","newerguide/newer_blue_up.png")
            self.newerGuideBtn_:setButtonImage("pressed","newerguide/newer_blue_down.png")
            local btnLabel = self.newerGuideBtn_:getButtonLabel()
            if btnLabel then
                btnLabel:setTextColor(cc.c3b(0xfe, 0xd7, 0x6e))
            end
            self.newerGuideBtn_:setButtonLabelString(bm.LangUtil.getText("NEWER", "GUIDE_HALL_BTN_LABEL_2"))
        end
        
    end
end

function MainHallView:onSetUpdateVerInfo(data)
    if not data or (not data.version) then
        return
    end

    local currentVersion = nk.Native:getAppVersion()
    currentVersion = BM_UPDATE and BM_UPDATE.VERSION or currentVersion

    local numStr
    local numInt
    tb = string.split(currentVersion,".")
    if tb and #tb >= 3 then
        numStr = string.format("%02d%02d%02d",tonumber(tb[1]),tonumber(tb[2]),tonumber(tb[3]))
        numInt = tonumber(numStr)
    end

    local numStr1
    local numInt1
    tb2 = string.split(data.version,".")
    if tb and #tb >= 3 then
        numStr1 = string.format("%02d%02d%02d",tonumber(tb2[1]),tonumber(tb2[2]),tonumber(tb2[3]))
        numInt1 = tonumber(numStr1)
    end


    if numInt and numInt1 then
        if numInt < numInt1 then
            --低于目标版本号显示按钮
            self.updateVerBtn_:setVisible(true)
            data.type = 1
        elseif numInt == numInt1 then
            --等于于目标版本号显示按钮
            data.type = 2
            if data.hasGetPrize == 1 then
                self.updateVerBtn_:setVisible(false)
            else
                self.updateVerBtn_:setVisible(true)
            end
            
        elseif numInt > numInt1 then
            data.type = 3
            --高于目标版本号显示按钮
            self.updateVerBtn_:setVisible(false)
        end
    end 

end

function MainHallView:refreshSuonaTipAnim(isShow)
    -- body
    if isShow then
        --todo
        local function suonaTipsAnim()
            -- body
            if not self.suonaIconClickTipAction_ then
                --todo
                return
            end

            self.suonaChatInfo_:setOpacity(255)
            -- self.suonaChatInfo_.show()
            self.suonaChatInfo_:performWithDelay(function()
                -- body
                if not self.suonaIconClickTipAction_ then
                    --todo
                    return
                end

                self.suonaChatInfo_:setOpacity(0)
                -- self.suonaChatInfo_:hide()
            end, 0.45)
        end

        self.suonaIconClickTipAction_ = self.suonaChatInfo_:schedule(suonaTipsAnim, 0.9)

        self.suonaChatInfo_:performWithDelay(function()
            -- body
            if self.suonaIconClickTipAction_ then
                --todo
                self:stopAction(self.suonaIconClickTipAction_)
                self.suonaIconClickTipAction_ = nil

                bm.DataProxy:setData(nk.dataKeys.SUONA_USETIP_ONOFF, false)
                -- self.suonaChatInfo_:hide()
                self.suonaChatInfo_:setOpacity(0)
            end
        end, 10.9)
    else
        dump(isShow, "isSuonaUseTipShow: ===============")
    end

end

function MainHallView:onTopSuonaBtnCallBack_()
    -- body
    -- local msgInfo = {
    --     type = 1,
    --     content = "通知:唉纱布的骄傲比我都看见爱我不打开暗红色的金卡和贷款还逗我还等哈啊肯定会！          ",
    --     -- location = "fillawrdaddr",
    --     name = "tsing"
    -- }
    -- local msgJson = json.encode(msgInfo)

    -- self.controller_:onSuonaBroadRecv_({data = {msg_info = msgJson}})
    -- do return end

    SuonaUsePopup.new():show()
end

function MainHallView:onInviteBtnClick()
    -- display.addSpriteFrames("activity_th.plist", "activity_th.png")
    -- nk.ui.MothersDayTips.new():show({flower=10,getMoney=5000})
    -- do return end
    --InvitePopup.new():show()
    nk.DReport:report({id = "inviteClick"})
    InviteRecallPopup.new(self):show()
    -- if device.platform == "android" or device.platform == "ios" then
    --     cc.analytics:doCommand{command = "event",
    --                 args = {eventId = "hall_Invite_friends", label = "user hall_Invite_friends"}}
                    
    -- end
end

function MainHallView:onMoreChipClick()
    nk.DReport:report({id = "actCenterEntryClk"})
    if nk.ByActivity then
        --todo
        -- nk.ByActivity:setWebViewTimeOut(3000)
        -- nk.ByActivity:setWebViewCloseTip(bm.LangUtil.getText("NEWSTACT", "DOUBLE_CLICK_EXIT"))
        -- nk.ByActivity:setNetWorkBadTip(bm.LangUtil.getText("COMMON", "REQUEST_DATA_FAIL"))
        -- nk.ByActivity:setAnimIn(1)
        -- nk.ByActivity:setAnimOut(3)

        nk.ByActivity:display()
        
        -- set displayForce, @param size: 0, small; 1, middle; 2, large
        -- nk.ByActivity:setup(function(data)
        --     -- body
        --     nk.ByActivity:setWebViewTimeOut(3000)
        --     nk.ByActivity:setWebViewCloseTip(bm.LangUtil.getText("NEWSTACT", "DOUBLE_CLICK_EXIT"))
        --     nk.ByActivity:setNetWorkBadTip(bm.LangUtil.getText("COMMON", "REQUEST_DATA_FAIL"))

        --     nk.ByActivity:displayForce(2, function(data)
        --         -- body
        --         dump(data, "displayForce:displayCallBack.data :==============")
        --     end, function(str)
        --         -- body
        --         dump(str, "displayForce:closeCallBack.str :================")
        --     end)
        -- end, 3)
    else
        dump("ActivityCenter Data Wrong!")
    end
end

function MainHallView:onDokbHallClick(evt)
    -- body
    -- Just for Test Actcenter act_push --
    -- if nk.ByActivity then
    --     --todo
    --     nk.ByActivity:clearRelatedCache()
    -- end

    -- do return end

    self:onDokbActHallClick()
end

function MainHallView:onProHallClick()

    if nk.OnOff:check("privateroom") then
        self:onPersonalHallClick()
    else
        local tipTxt = nk.OnOff:checkTip("privateroom")

        local defaultTxt = T("暂未开放 敬请期待")
        if tipTxt then
            defaultTxt = tipTxt
        end

        nk.ui.Dialog.new({messageText = defaultTxt, secondBtnText = T("确定"), closeWhenTouchModel = true,
            hasFirstButton = false, hasCloseButton = false,
            callback = function (type)
            end
        }):show()
    end
end

function MainHallView:onNorHallClick()
    -- Just for Test Actcenter act_push --
    -- if nk.ByActivity then
    --     --todo
    --     nk.ByActivity:switchServer(0) -- 切换到正式服
    -- end

    -- do return end

    nk.DReport:report({id = "nor_enter_room"})
    self.norRoomBtn_:setButtonEnabled(false)
    self.controller_:showChooseRoomView(self.controller_.CHOOSE_NOR_VIEW)
    -- self.norRoomBtn_:setButtonEnabled(true)
    -- if device.platform == "android" or device.platform == "ios" then1
    --     cc.analytics:doCommand{command = "event",
    --                 args = {eventId = "nor_enter_room", label = "user nor_enter_room"}}
    -- end
end

function MainHallView:onMatchHallClick()
    -- Just for Test Actcenter act_push --
    -- if nk.ByActivity then
    --     --todo
    --     nk.ByActivity:switchServer(1) -- 切换到测试服
    -- end
    -- do return end

    nk.DReport:report({id = "enterMatchClick"})
    if nk.OnOff:check("match") then

        local userLevelFact = nk.Level:getLevelByExp(nk.userData["aUser.exp"])
        if userLevelFact < 3 or nk.userData["aUser.mlevel"] < 3 then
            --todo
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("NEWER", "NOT_MEET_LEVEL_TIP"))
            return
        end

        self.porRoomBtn_:setButtonEnabled(false)
        self.controller_:showChooseMatchRoomView(self.controller_.CHOOSE_MATCH_NOR_VIEW)
    else
        local tipTxt = nk.OnOff:checkTip("match")
        local defaultTxt = T("暂未开放 敬请期待")

        if tipTxt then
            defaultTxt = tipTxt
        end

        nk.ui.Dialog.new({messageText = defaultTxt, secondBtnText = T("确定"), closeWhenTouchModel = true,
            hasFirstButton = false, hasCloseButton = false,
            callback = function (type)
            end
        }):show()
    end
end

function MainHallView:onPlayNowClick()
    nk.DReport:report({id = "fastEnterClick"})
    local preType = bm.DataProxy:getData(nk.dataKeys.ROOM_INFO_TYPE)
    if preType == 1 or preType == nil then
        self.controller_:getEnterRoomData(nil, true)
    elseif preType==2 then
        if nk.userData["match.point"] < 10 then
            self.controller_:getEnterRoomData(nil, true)
        else
            self.controller_:getEnterCashRoomData()
        end
    end
    -- if device.platform == "android" or device.platform == "ios" then
    --     cc.analytics:doCommand{command = "event",
    --                 args = {eventId = "play_now_enter_room", label = "user play_now_enter_room"}}
    -- end
end


function MainHallView:onPokdengAdClick_()
    PokdengAdPopup.new():show()
end

function MainHallView:_onSignInBtnCallBack()
    -- body
    if self.moreChipModal_ then
        self.moreChipModal_:removeFromParent()
        self.moreChipModal_ = nil
        self.moreChipPanelNode_:removeFromParent()
    else
        if self._newstActEntryPaopAnim then
            --todo
            self:stopAction(self._newstActEntryPaopAnim)
            self._newstActEntryPaopAnim = nil
        end

        if self._newstActEntryPaopTip then
            --todo
            self._newstActEntryPaopTip:removeFromParent()
            self._newstActEntryPaopTip = nil
        end

        bm.DataProxy:setData(nk.dataKeys.HALL_NEWSTACT_PAOPTIP, false)
        -- 更多筹码模态
        self.moreChipModal_ = display.newScale9Sprite("#modal_texture.png", 0, 0, cc.size(display.width, display.height))
            :addTo(self.halfBottomNode_, 2)
        bm.TouchHelper.new(self.moreChipModal_, handler(self, self.onModalTouch_))

        -- 操作栏移出动画
        self.moreChipPanelNode_ = display.newNode()
            :pos(0, - display.cy + MORE_CHIP_PANEL_HEIGHT * 1.5)
            :addTo(self.panelClipNode_)
        self.moreChipPanelNode_:setTouchEnabled(true)
        self.moreChipPanelNode_:moveTo(0.2, display.left, - display.cy + MORE_CHIP_PANEL_HEIGHT * 0.5)

        -- 背景
        display.newScale9Sprite("#more_chip_panel_bg.png", 0, 0, cc.size(display.width, 132))
            :pos(0, -4)
            :addTo(self.moreChipPanelNode_)
        display.newSprite("#more_chip_panel_arrow.png")
            :pos(-BRICK_DISTANCE * 1.5, MORE_CHIP_PANEL_HEIGHT * 0.5 - 6)
            :addTo(self.moreChipPanelNode_)

        -- 分割线

        local ToAddFarmFixPosX = 20
        local BRICK_GAP_DISTANCE = 150+BRICK_GAP - ToAddFarmFixPosX;

        local PosXFixDistance = 62
        for i = 1, 5 do
            display.newSprite("#panel_split_line.png")
                :pos(BRICK_GAP_DISTANCE * (i - 2)-100 - PosXFixDistance, -4)
                :addTo(self.moreChipPanelNode_)
        end

        local touchSize = cc.size(200, 180)
        -- 图标
        self.dailyMissionPressed_ = display.newSprite("#act_button_pressed.png", -BRICK_GAP_DISTANCE * 1.5-100 - PosXFixDistance, 10):addTo(self.moreChipPanelNode_):hide()
        local dailyMission = display.newSprite("#daily_mission_icon.png")
            :pos(-BRICK_GAP_DISTANCE * 1.5-100 - PosXFixDistance, 10)
            :addTo(self.moreChipPanelNode_)
        local dailyMissionTouch_ = display.newScale9Sprite("#transparent.png", -BRICK_GAP_DISTANCE * 1.5-100 - PosXFixDistance, 10, touchSize):addTo(self.moreChipPanelNode_)
        bm.TouchHelper.new(dailyMissionTouch_, handler(self, self.onDailyMissionClick))
        
        self.dailyBonusPressed_ = display.newSprite("#act_button_pressed.png", -BRICK_GAP_DISTANCE * 0.5-100 - PosXFixDistance, 10):addTo(self.moreChipPanelNode_):hide()
        local dailyBonus = display.newSprite("#daily_bonus_icon.png")
            :pos(-BRICK_GAP_DISTANCE * 0.5-100 - PosXFixDistance, 10)
            :addTo(self.moreChipPanelNode_)
        local dailyBonusTouch_ = display.newScale9Sprite("#transparent.png", -BRICK_GAP_DISTANCE * 0.5-100 - PosXFixDistance, 10, touchSize):addTo(self.moreChipPanelNode_)
        bm.TouchHelper.new(dailyBonusTouch_, handler(self, self.onDailyBonusClick))
        
        self.newestActivityPressed_ = display.newSprite("#act_button_pressed.png", BRICK_GAP_DISTANCE * 0.5-100 - PosXFixDistance, 10):addTo(self.moreChipPanelNode_):hide()
        local newestActivity = display.newSprite("#newest_activity_icon.png")
            :pos(BRICK_GAP_DISTANCE * 0.5-100 - PosXFixDistance, 10)
            :addTo(self.moreChipPanelNode_)
        local newestActivityTouch_ = display.newScale9Sprite("#transparent.png", BRICK_GAP_DISTANCE * 0.5-100 - PosXFixDistance, 10, touchSize):addTo(self.moreChipPanelNode_)
        bm.TouchHelper.new(newestActivityTouch_, handler(self, self.onNewestActivityClick))

        -- self.newActPoint = display.newSprite("#common_small_point.png")
        --     :pos(BRICK_GAP_DISTANCE * 0.5-50 - PosXFixDistance, 30)
        --     :addTo(self.moreChipPanelNode_)

        -- if nk.OnOff:check("mother") then 
        --     local isClickedMotherDay = bm.DataProxy:getData(nk.dataKeys.MOTHER_DAY)
        --     dump(isClickedMotherDay,"isClickedMotherDay")
        --     if isClickedMotherDay == 1 then
        --         bm.DataProxy:setData(nk.dataKeys.MOTHER_DAY, 1)
        --     else
        --         bm.DataProxy:setData(nk.dataKeys.MOTHER_DAY, 0)
        --     end
        -- else
        --      bm.DataProxy:setData(nk.dataKeys.MOTHER_DAY, 1)
        -- end
        
        
        self.luckyWheelPressed_ = display.newSprite("#act_button_pressed.png", BRICK_GAP_DISTANCE * 1.5-100 - PosXFixDistance, 10):addTo(self.moreChipPanelNode_):hide()
        local luckyWheel = display.newSprite("#lucky_wheel_icon.png")
            :pos(BRICK_GAP_DISTANCE * 1.5-100 - PosXFixDistance, 10)
            :addTo(self.moreChipPanelNode_)
        local luckyWheelTouch_ = display.newScale9Sprite("#transparent.png", BRICK_GAP_DISTANCE * 1.5-100 - PosXFixDistance, 10, touchSize):addTo(self.moreChipPanelNode_)
        bm.TouchHelper.new(luckyWheelTouch_, handler(self, self.onLuckyWheelClick))

        self.sharegamePressed_ = display.newSprite("#act_button_pressed.png", BRICK_GAP_DISTANCE * 2.5-100 - PosXFixDistance, 10):addTo(self.moreChipPanelNode_):hide()
        local sharegamebtn = display.newSprite("#share_game_icon.png")
            :pos(BRICK_GAP_DISTANCE * 2.5-100 - PosXFixDistance, 10)
            :addTo(self.moreChipPanelNode_)
        local sharegamebtnTouch_ = display.newScale9Sprite("#transparent.png", BRICK_GAP_DISTANCE * 2.5-100 - PosXFixDistance, 10, touchSize):addTo(self.moreChipPanelNode_)
        bm.TouchHelper.new(sharegamebtnTouch_, handler(self, self.onShareClick))

        local signInNewIconBottomPosShift = {
            x = 50,
            y = 25
        }
        self.signInNewIconBottom_ = display.newSprite("#common_small_point.png")
            :pos(BRICK_GAP_DISTANCE * 2.5 - 100 - PosXFixDistance + signInNewIconBottomPosShift.x, 10 + signInNewIconBottomPosShift.y)
            :addTo(self.moreChipPanelNode_)
            :hide()

        -- self._signInNewIconBottom:setScale(0.6)
        local isShowState = bm.DataProxy:getData(nk.dataKeys.HALL_SIGNIN_NEW)
        
        if isShowState then
            --todo
            self.signInNewIconBottom_:setVisible(isShowState)
        else
            self.signInNewIconBottom_:setVisible(false)
        end

        -- 农场 -- 
        self._iconFarmPressed = display.newSprite("#act_button_pressed.png", BRICK_GAP_DISTANCE * 3.5 - 100 - PosXFixDistance, 10):addTo(self.moreChipPanelNode_):hide()
        local iconFarm = display.newSprite("#hall_ic_farm.png")
            :pos(BRICK_GAP_DISTANCE * 3.5 - 100 - PosXFixDistance, -5)
            :addTo(self.moreChipPanelNode_)

        -- local mylevel = nk.userData["aUser.mlevel"]
        local userLevelFact = nk.Level:getLevelByExp(nk.userData["aUser.exp"])
        if userLevelFact >= 3 then
            display.newSprite("#common_small_point.png")
            :pos(BRICK_GAP_DISTANCE * 3.5-50 - PosXFixDistance, 30)
            :addTo(self.moreChipPanelNode_)
        end

        local _iconFarmTouch = display.newScale9Sprite("#transparent.png", BRICK_GAP_DISTANCE * 3.5 - 100 - PosXFixDistance, -5, touchSize):addTo(self.moreChipPanelNode_)
        bm.TouchHelper.new(_iconFarmTouch, handler(self, self.onIconFarmClick))
        -- 农场 --

        -- 文本标签
        display.newTTFLabel({text = bm.LangUtil.getText("HALL", "DAILY_MISSION"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 24, align = ui.TEXT_ALIGN_CENTER})
            :pos(-BRICK_GAP_DISTANCE * 1.5-100 - PosXFixDistance, -48)
            :addTo(self.moreChipPanelNode_)
        display.newTTFLabel({text = bm.LangUtil.getText("ECODE", "TITLE"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 24, align = ui.TEXT_ALIGN_CENTER})
            :pos(-BRICK_GAP_DISTANCE * 0.5-100 - PosXFixDistance, -48)
            :addTo(self.moreChipPanelNode_)
        display.newTTFLabel({text = bm.LangUtil.getText("HALL", "NEWEST_ACTIVITY"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 24, align = ui.TEXT_ALIGN_CENTER})
            :pos(BRICK_GAP_DISTANCE * 0.5-100 - PosXFixDistance, -48)
            :addTo(self.moreChipPanelNode_)
        display.newTTFLabel({text = bm.LangUtil.getText("HALL", "LUCKY_WHEEL"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 24, align = ui.TEXT_ALIGN_CENTER})
            :pos(BRICK_GAP_DISTANCE * 1.5-100 - PosXFixDistance, -48)
            :addTo(self.moreChipPanelNode_)
        display.newTTFLabel({text = bm.LangUtil.getText("HALL", "SIGN_IN"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 24, align = ui.TEXT_ALIGN_CENTER})
            :pos(BRICK_GAP_DISTANCE * 2.5-100 - PosXFixDistance, -48)
            :addTo(self.moreChipPanelNode_)

        display.newTTFLabel({text = bm.LangUtil.getText("DORNUCOPIA", "FARM"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 24, align = ui.TEXT_ALIGN_CENTER})
            :pos(BRICK_GAP_DISTANCE * 3.5 - 100 - PosXFixDistance, -48)
            :addTo(self.moreChipPanelNode_)
    end

    -- local defaultTabIndex = 1
    -- if checkint(nk.userData["aUser.money"]) > 50000 then
    --     defaultTabIndex = 3
    -- end
end

function MainHallView:onDokbActHallClick()
    -- body
    nk.DReport:report({id = "dokbClick"})
    if nk.OnOff:check("dokbAct") then
        --todo
        local userLevelFact = nk.Level:getLevelByExp(nk.userData["aUser.exp"])
        if userLevelFact < 3 or nk.userData["aUser.mlevel"] < 3 then
            --todo
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("NEWER", "NOT_MEET_LEVEL_TIP"))
            return
        end

        self.dokbBtn_:setButtonEnabled(false)
        self.controller_:showDobkActPageView()
    else
        -- local tipTxt = nk.OnOff:checkTip("privateroom")
        -- local defaultTxt = T("暂未开放 敬请期待")
        -- if tipTxt then
        --     defaultTxt = tipTxt
        -- end
        nk.ui.Dialog.new({messageText = T("暂未开放 敬请期待"), secondBtnText = T("确定"), closeWhenTouchModel = true, hasFirstButton = false,
            hasCloseButton = false, callback = function (type)
                if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                end
        end})
            :show()
        
    end
    
    -- self.dokbBtn_:setButtonEnabled(true)
end

function MainHallView:onPersonalHallClick()
    self.controller_:showChoosePersonalRoomView(self.controller_.CHOOSE_PERSONAL_NOR_VIEW)
    -- if device.platform == "android" or device.platform == "ios" then
    --     cc.analytics:doCommand{command = "event",
    --                 args = {eventId = "nor_enter_room", label = "user nor_enter_room"}}
    -- end
end

function MainHallView:_onActPromtCallBack()
    -- body
    PromotActPopup.new():show()

     -- self.reportActRequest_ = nk.http.ReportActData(1,
     --    function(data)
     --        nk.http.cancel(self.reportActRequest_)
     --        -- body
     --    end,
     --    function(errData)
     --        nk.http.cancel(self.reportActRequest_)
     --        -- body
     --    end)

    nk.DReport:report({id = "unionActEntryClk"})
end



function MainHallView:_onFirstChargeFavBtnCallBack()
    -- body
    local payGuideShownType = 1
    local isThirdPayOpen = true
    local isFirstCharge = true
    local payBillType = nil

    -- Change Temporary --
    -- if device.platform == "ios" then
    --     --todo
    --     StorePopup.new():showPanel()

    --     return
    -- end

    if nk.OnOff:check("firstchargeFavGray") then
        --todo
        FirChargePayGuidePopup.new():showPanel()
    else
        local params = {}

        params.isOpenThrPartyPay = isThirdPayOpen
        params.isFirstCharge = isFirstCharge
        params.sceneType = payGuideShownType
        params.payListType = payBillType

        PayGuide.new(params):show() 
    end
end

function MainHallView:onAlmRechargeFavCallBack_(evt)
    -- body
    AgnChargePayGuidePopup.new():showPanel()
end

function MainHallView:onModalTouch_(target, evt)
    if evt == bm.TouchHelper.CLICK then
        if self.moreChipModal_ then
            nk.SoundManager:playSound(nk.SoundManager.CLOSE_BUTTON)
            self.moreChipModal_:removeFromParent()
            self.moreChipModal_ = nil
            self.moreChipPanelNode_:removeFromParent()
        end
    end
end

function MainHallView:onDailyMissionClick(target, evt)
    if evt == bm.TouchHelper.TOUCH_BEGIN then
        self.dailyMissionPressed_:show()
    elseif evt == bm.TouchHelper.TOUCH_END then
        self.dailyMissionPressed_:hide()
    elseif evt == bm.TouchHelper.CLICK then
        self.dailyMissionPressed_:hide()
        nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
        DailyTasksPopup.new():show()
        -- if self.moreChipModal_ then
        --     self.moreChipModal_:removeFromParent()
        --     self.moreChipModal_ = nil
        --     self.moreChipPanelNode_:removeFromParent()
        -- end
    end
end

function MainHallView:onDailyBonusClick(target, evt)
if evt == bm.TouchHelper.TOUCH_BEGIN then
        self.dailyBonusPressed_:show()
    elseif evt == bm.TouchHelper.TOUCH_END then
        self.dailyBonusPressed_:hide()
    elseif evt == bm.TouchHelper.CLICK then
        self.dailyBonusPressed_:hide()
        nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
        nk.PopupManager:addPopup(ExchangeCodePop.new())
        -- if self.moreChipModal_ then
        --     self.moreChipModal_:removeFromParent()
        --     self.moreChipModal_ = nil
        --     self.moreChipPanelNode_:removeFromParent()
        -- end
    end
end

function MainHallView:onLoadLgTextureComplete(str, texture)
    LoginRewardView.new():show_()
end

function MainHallView:onNewestActivityClick(target, evt)

    if device.platform == "android" or device.platform == "windows" then
        --todo
        if evt == bm.TouchHelper.TOUCH_BEGIN then
            self.newestActivityPressed_:show()
        elseif evt == bm.TouchHelper.TOUCH_END then
            self.newestActivityPressed_:hide()
        elseif evt == bm.TouchHelper.CLICK then
            self.newestActivityPressed_:hide()
            nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
            NewestActPopup.new(1, function(action, param)
                if action == "playnow" then
                    self.controller_:getEnterRoomData(nil, true)
                elseif action == "gotoChoseRoomView" then
                    self.controller_:showChooseRoomView(param)
                elseif action == "invite" then
                    if self and self["onInviteBtnClick"] then
                        self:onInviteBtnClick()
                    end
                elseif action == "openShop" then
                    if self and self["onStoreBtnClicked"] then
                        -- self:onStoreBtnClicked()
                        StorePopup.new(nil,param and param.purchaseType or nil):showPanel()
                    end
                elseif action == "goMatchRoom" then
                    -- self.controller_:showChooseMatchRoomView(self.controller_.CHOOSE_MATCH_NOR_VIEW)
                    if self and self.onMatchHallClick then
                        --todo
                        self:onMatchHallClick()
                    end
                    -- local matchDataInfo = nk.MatchConfigEx:getMatchDataById(3)

                    -- if matchDataInfo then
                    --     --todo
                    --     -- nk.runningScene.controller_.view_:onChipClick_(matchDataInfo)
                    --     -- dump(matchDataInfo, "matchDataInfo :===============")
                    --     self.controller_.view_:onChipClick_(matchDataInfo)
                    --     -- MatchApplyPopup.new(matchDataInfo):show()
                    -- else
                    --     dump("matchRoomData config Wrong!")
                    -- end
                elseif action == "clkActCenter" then
                    --todo
                    if self and self.onMoreChipClick then
                        --todo
                        self:onMoreChipClick()
                    end
                elseif action == "openScoreMarket" then
                    self:onScoreMarketBtnClicked()
                elseif action == "openGrab" then
                    self.moreChipModal_:removeFromParent()
                    self.moreChipModal_ = nil
                    self.moreChipPanelNode_:removeFromParent()

                    nk.userData.DEFAULT_TAB = 2
                    self:onNorHallClick()
                end
            end):show()
            -- if self.moreChipModal_ then
            --     self.moreChipModal_:removeFromParent()
            --     self.moreChipModal_ = nil
            --     self.moreChipPanelNode_:removeFromParent()
            -- end

            -- local isClick = bm.DataProxy:getData(nk.dataKeys.MOTHER_DAY)
            -- if isClick ~= 1 then
            --     bm.DataProxy:setData(nk.dataKeys.MOTHER_DAY, 1)
            -- end
            
        end
    elseif device.platform == "ios" then
        --todo
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("HALL", "NOTOPEN"))
    end
end

function MainHallView:onLuckyWheelClick(target, evt)
    if evt == bm.TouchHelper.TOUCH_BEGIN then
        self.luckyWheelPressed_:show()
    elseif evt == bm.TouchHelper.TOUCH_END then
        self.luckyWheelPressed_:hide()
    elseif evt == bm.TouchHelper.CLICK then
        self.luckyWheelPressed_:hide()
        nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
        if nk.config.SONGKRAN_THEME_ENABLED then
            display.addSpriteFrames("songkran_wheel_texture.plist", "songkran_wheel_texture.png")
        end
        display.addSpriteFrames("wheel_texture.plist", "wheel_texture.png", function()
            WheelPopup.new():show()
        end)
        -- if self.moreChipModal_ then
        --     self.moreChipModal_:removeFromParent()
        --     self.moreChipModal_ = nil
        --     self.moreChipPanelNode_:removeFromParent()
        -- end
    end
end
function MainHallView:onShareClick(target,evt)
    if evt == bm.TouchHelper.TOUCH_BEGIN then
        self.sharegamePressed_:show()
    elseif evt == bm.TouchHelper.TOUCH_END then
        self.sharegamePressed_:hide()
    elseif evt == bm.TouchHelper.CLICK then
        self.sharegamePressed_:hide()
        nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)

        -- local feedData = clone(bm.LangUtil.getText("FEED", "FREE_COIN"))
        --     nk.Facebook:shareFeed(feedData, function(success, result)
        --     print("FEED.FREE_COIN result handler -> ", success, result)
        --     if not success then
        --         nk.TopTipManager:showTopTip(bm.LangUtil.getText("FEED", "SHARE_FAILED")) 
        --      else
        --         nk.TopTipManager:showTopTip(bm.LangUtil.getText("FEED", "SHARE_SUCCESS")) 
        --      end
        -- end)
        
        -- 可能要去掉,看需求而定！ --
        -- nk.sendFeed:free_coin_()
        -- end --
        
        SignInContPopup.new():show()

        -- if self.moreChipModal_ then
        --     self.moreChipModal_:removeFromParent()
        --     self.moreChipModal_ = nil
        --     self.moreChipPanelNode_:removeFromParent()
        -- end
    end
end

function MainHallView:onIconFarmClick(target, event)
    -- body
    if event == bm.TouchHelper.TOUCH_BEGIN then
        self._iconFarmPressed:show()
    elseif event == bm.TouchHelper.TOUCH_END then
        self._iconFarmPressed:hide()
    elseif event == bm.TouchHelper.CLICK then
        self._iconFarmPressed:hide()
        nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)

        -- 添加弹出窗 -- 
        local lastLoginType = nk.userDefault:getStringForKey(nk.cookieKeys.LAST_LOGIN_TYPE)
        if lastLoginType == "GUEST" then
            --todo
            -- local CornuPopup     = import("app.module.cornucopiaEx.CornuPopup")
            -- CornuPopup.new():show()
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("DORNUCOPIA", "GUEST_CANT_ACCESS_TIP"))
        elseif nk.userData['aUser.mlevel'] < 3 then
             nk.TopTipManager:showTopTip(bm.LangUtil.getText("DORNUCOPIA", "LEVEL_CANT_ACCESS_TIP"))
        else
            CornuPopup.new():show()
        end
    end
end

function MainHallView:onAvatarLoadComplete_(success, sprite)
    if success then
        local oldAvatar = self.bottomPanelNode_:getChildByTag(AVATAR_TAG)
        if oldAvatar then
            oldAvatar:removeFromParent()
        end
        local sprSize = sprite:getContentSize()
        if sprSize.width > sprSize.height then
            sprite:scale(82 / sprSize.width)
        else
            sprite:scale(82 / sprSize.height)
        end
        sprite:align(display.LEFT_CENTER, -display.cx + 12, -display.cy + BOTTOM_PANEL_HEIGHT * 0.5 - 2)
            :addTo(self.bottomPanelNode_, 0, AVATAR_TAG)
    end
end

function MainHallView:addPropertyObservers()
    self.nickObserverHandle_ = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "aUser.name", handler(self, function (obj, name)
        if obj and obj.nick_ then
            obj.nick_:setString(nk.Native:getFixedWidthText("", 24, name, 200))
        end
        
    end))
    self.moneyObserverHandle_ = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "aUser.money", handler(self, function (obj, money)
        if obj and obj.money_ then
            obj.money_:setString(bm.formatNumberWithSplit(money))
        end
        
    end))
    -- self.levelObserverHandle_ = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "aUser.mlevel", handler(self, function (obj, level)
    --     obj.level_:setString(bm.LangUtil.getText("COMMON", "LEVEL", level))
    -- end))
    self.experienceObserverHandle_ = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "aUser.exp", handler(self, function (obj, experience)
        local percent,progress,all
        percent,progress,all,self.lvRequest_ = nk.Level:getLevelUpProgress(experience, function(levelData, percent, progress, all)

            if obj then
                --todo
                if obj.expBar_ then
                    --todo
                    obj.expBar_:setValue(percent)
                end

                if obj.level_ then
                    --todo
                    obj.level_:setString(bm.LangUtil.getText("COMMON", "LEVEL", nk.Level:getLevelByExp(experience)))
                end

                if obj.refreshMatchAndDokbEntryUi then
                    --todo
                    obj:refreshMatchAndDokbEntryUi()
                end

                self.lvRequest_ = nil
            end

        end)
        
        if obj then
            --todo
            if obj.expBar_ then
                --todo
                obj.expBar_:setValue(percent)
            end

            if obj.level_ then
                --todo
                obj.level_:setString(bm.LangUtil.getText("COMMON", "LEVEL", nk.Level:getLevelByExp(experience)))
            end

            if obj.refreshMatchAndDokbEntryUi then
                --todo
                obj:refreshMatchAndDokbEntryUi()
            end
        end
    end))

    self.discountObserverHandle_ = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "__user_discount", function(discount)
        if discount and discount > 1 then
            self.discountTagBg_:show()
            self.discountTagText_:show():setString(string.format("%+d%%", math.round((discount - 1) * 100)))
        else
            self.discountTagBg_:hide()
            self.discountTagText_:hide()
        end
    end)

    self.avatarUrlObserverHandle_ = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "aUser.micon", handler(self, function (obj, micon)
        if not micon or string.len(micon) <= 5 then
            if nk.userData["aUser.msex"] == 2 or nk.userData["aUser.msex"] == 0 then
                self:onAvatarLoadComplete_(true, display.newSprite("#common_female_avatar.png"))
            else
                self:onAvatarLoadComplete_(true, display.newSprite("#common_male_avatar.png"))
            end
        else
            local imgurl = micon
            if string.find(imgurl, "facebook") then
                if string.find(imgurl, "?") then
                    imgurl = imgurl .. "&width=100&height=100"
                else
                    imgurl = imgurl .. "?width=100&height=100"
                end
            end
            nk.ImageLoader:loadAndCacheImage(
                obj.userAvatarLoaderId_, 
                imgurl, 
                handler(obj, obj.onAvatarLoadComplete_), 
                nk.ImageLoader.CACHE_TYPE_USER_HEAD_IMG)
        end
        
    end))

    self.userOnlineObserverHandle_ = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "USER_ONLINE", handler(self, function (obj, userOnline)
        if obj and obj.userOnline_ then
            obj.userOnline_:setString(bm.LangUtil.getText("HALL", "USER_ONLINE", bm.formatNumberWithSplit(userOnline)))
        end
        
    end))

    self.onNewMessageDataObserver = bm.DataProxy:addDataObserver(nk.dataKeys.NEW_MESSAGE, handler(self, self.messagePoint))
    -- self.onNewActDataObserver = bm.DataProxy:addDataObserver(nk.dataKeys.MOTHER_DAY, handler(self, self.actPoint))
    self.onHallNewsIconObserver = bm.DataProxy:addDataObserver(nk.dataKeys.OPEN_ACT,handler(self,self.hallNewIcon))
    self.onHallInviteChipsObserver = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "inviteBackChips", handler(self,self.upInviteBackChips))
    self.onSignInNewPointActObserver = bm.DataProxy:addDataObserver(nk.dataKeys.HALL_SIGNIN_NEW, handler(self, self.refreshSigninNewActPointSate))

    -- Note Below For Test initUnionActEntryUi() || initFirstChargeFavEntry() || initNewsActPaopTip()--
    self.onUnionActOnOffObserver = bm.DataProxy:addDataObserver(nk.dataKeys.UNIONACT_ONOFF, handler(self, self.initUnionActEntryUi))
    self.onChargeFavOnOffObserver = bm.DataProxy:addDataObserver(nk.dataKeys.CHARGEFAV_ONOFF, handler(self, self.initFirstChargeFavEntry))
    self.onAlmRechargeFavOnOffObserver = bm.DataProxy:addDataObserver(nk.dataKeys.ALMRECHARGEFAV_ONOFF, handler(self, self.initAlmRechargeFavEntryUi))
    self.onNewstActPaopTipObserver = bm.DataProxy:addDataObserver(nk.dataKeys.HALL_NEWSTACT_PAOPTIP, handler(self, self.initNewsActPaopTip))
    self.onSuonaTipsObserver = bm.DataProxy:addDataObserver(nk.dataKeys.SUONA_USETIP_ONOFF, handler(self, self.refreshSuonaTipAnim))
    self.onUpdateVerInfoObserver = bm.DataProxy:addDataObserver(nk.dataKeys.UPDATE_INFO,handler(self,self.onSetUpdateVerInfo))

    self.onNewerGuideDayObserver = bm.DataProxy:addDataObserver(nk.dataKeys.NEWER_GUIDE_DAY,handler(self,self.onSetNewerGuideDay))
end


function MainHallView:upInviteBackChips(chips)
    local inviteBtn = nil
    if self.halfTopNode_ then 
        inviteBtn = self.halfTopNode_:getChildByTag(999)
    end
    if inviteBtn then
        local inviteLabel = inviteBtn:getChildByTag(999)
        if inviteLabel then
            inviteLabel:setString(bm.LangUtil.getText("HALL", "INVITE_FRIEND", bm.formatNumberWithSplit(nk.userData.inviteBackChips)))
        end
    end
end

function MainHallView:messagePoint(hasNewMessage) 
    if hasNewMessage then
        self.newMessagePoint:show()
    else 
        self.newMessagePoint:hide()
    end
end
function MainHallView:hallNewIcon(isOpen)
    -- if isOpen == 1 then
    --     self.newActHallPoint = display.newSprite("#newIcon.png")
    --     --:pos(-230,30)
    --     :addTo(self.moreChipNode_)
    --      local bgY = display.cy - (MORE_CHIP_PANEL_HEIGHT + BRICK_HEIGHT * 0.5)
    --     -- local tempW,tempH = self.moreChipNode_:getContentSize()
    --     --BRICK_WIDTH - 16, BRICK_HEIGHT
    --     local tempW = (BRICK_WIDTH - 16)/2
    --     local tempH = (BRICK_HEIGHT - 16)/2
    --      self.newActHallPoint:pos(-BRICK_DISTANCE * 1.5 +tempW, -bgY +tempH)
    -- else

    -- end
end

function MainHallView:popAdPromot()
    -- body
    AdPromotPopup.new(function(action)
        -- body

        local doActionByIns = {
            ["matchlist"] = function()
                -- body

                self:onMatchHallClick()
                -- self.controller_:showChooseMatchRoomView(self.controller_.CHOOSE_MATCH_NOR_VIEW)
            end,

            ["shoplist"] = function()
                -- body
                StorePopup.new():showPanel()
            end,

            ["invitefriends"] = function()
                -- body
                self:onInviteBtnClick()
            end,

            ["activitycenter"] = function()
                -- body
                self:onMoreChipClick()
                -- local grabDealerViewTab = 3

                -- self.controller_:showChooseRoomView(self.controller_.CHOOSE_NOR_VIEW)
                -- self.controller_.view_.topTabBar_:gotoTab(grabDealerViewTab)
            end,

            ["freechips"] = function()
                -- body
                self:_onSignInBtnCallBack()
            end,

            ["openrank"] = function()
                -- body
                RankingPopup.new():show()
            end,

            ["openfriends"] = function()
                -- body
                FriendPopup.new():show()
            end,

            ["openpersondata"] = function()
                -- body
                self:onUserInfoBtnClicked()
            end,

            ["gograbdealer"] = function()
                -- body
                local grabDealerViewTab = 2

                nk.userData.DEFAULT_TAB = grabDealerViewTab
                self:onNorHallClick()
                -- self.controller_:showChooseRoomView(self.controller_.CHOOSE_NOR_VIEW)
                -- self.controller_.view_.topTabBar_:gotoTab(grabDealerViewTab)
            end,

            ["gochsnorroom"] = function()
                -- body
                local chooseNorViewTab = 1
                nk.userData.DEFAULT_TAB = chooseNorViewTab
                self:onNorHallClick()
                
                -- self.controller_.view_.mainTabBar_:gotoTab(chooseNorViewTab)
                -- self.controller_:showChooseRoomView(self.controller_.CHOOSE_NOR_VIEW)
            end,

            ["gocashroom"] = function()
                -- body
                local chooseCashViewTab = 3
                nk.userData.DEFAULT_TAB = chooseCashViewTab
                self:onNorHallClick()
            end,

            ["fillawrdaddr"] = function()
                -- body
                local isPopFillAdress = true

                self:onScoreMarketBtnClicked(isPopFillAdress)
                -- self.scoreMarketView_:onShowAddressPopul_()
            end
        }

        if action and doActionByIns[action] then
            --todo
            doActionByIns[action]()
        else
            dump("wrong actionType!")
        end
        -- doActionByIns[action]()
    end):show()
end

function MainHallView:popGucuRecallReward()
    -- body
    GucuReCallPopup.new():showPanel()
end

function MainHallView:refreshSigninNewActPointSate(isShow)

    -- dump(isShow,"refreshSigninNewActPointSate")
    -- dump(self.signInNewIconBottom_,"refreshSigninNewActPointSate=====")
    -- body
    if self.signInNewIconBottom_ then
        --todo
        self.signInNewIconBottom_:setVisible(isShow)
    end
    
    -- if isShow then
    --     --todo
    --     self.signInNewIconBottom_:setVisible()
    -- else
    --     self.signInNewIconBottom_:setVisible()
    -- end
end

function MainHallView:playSuonaMsgScrolling(suonaMsg)
    -- body
    -- self.suonaMsgQueue_ = self.suonaMsgQueue_ or {}
    -- table.insert(self.suonaMsgQueue_, suonaMsg)

    if not self.suonaMsgPlaying_ then
        -- self.suonaMsgPosXSrc = self.suonaChatInfo_:getPositionX()
        self:playSuonaMsgNext()
    end
end

function MainHallView:playSuonaMsgNext()
    -- body
    local currentSuonaMsgData = nil

    local suonaMsgShownColor = {
        tip = display.COLOR_WHITE,
        msg = cc.c3b(255, 0, 255)
    }
    if self.controller_.suonaMsgQueue_[1] then
        --todo
        currentSuonaMsgData = table.remove(self.controller_.suonaMsgQueue_, 1)
    else
        -- 调整label 的显示,"<<点击这里使用小喇叭"
        self.suonaChatInfo_:setString(bm.LangUtil.getText("SUONA", "SUONAUSE_TOPTIP"))
        self.suonaChatInfo_:setTextColor(suonaMsgShownColor.tip)
        self.suonaChatInfo_:pos(self.suonaChatMsgStrPosXDes, 0)

        self.topSuonaTipPanel_:setOpacity(0)
        -- self.suonaBtnTop_:setOpacity(255)
        self.suonaChatInfo_:setOpacity(0)
        -- self.suonaChatInfo_:hide()

        self.suonaMsgPlaying_ = false
        return
    end

    if self.suonaIconClickTipAction_ then
        --todo
        self:stopAction(self.suonaIconClickTipAction_)
        self.suonaIconClickTipAction_ = nil

        -- self.suonaChatInfo_:setOpacity(255)
        bm.DataProxy:setData(nk.dataKeys.SUONA_USETIP_ONOFF, false)
    end

    -- dump(currentSuonaMsgData, "currentSuonaMsgData: =================")

    self.suonaMsgPlaying_ = true
    self.topSuonaTipPanel_:setOpacity(255)

    -- self.suonaChatInfoclipNode_:setOpacity(255)
    self.suonaChatInfo_:setString(currentSuonaMsgData)
    self.suonaChatInfo_:setTextColor(suonaMsgShownColor.msg)

    self.suonaChatInfo_:setTextColor(display.COLOR_WHITE)

    self.suonaChatInfo_:pos(self.suonaChatMsgStrPosXSrc, 0)

    local chatMsgPlayDelayTime = 0.2
    local chatMsgShownTimeIntval = 3
    -- local chatMsgLabelRollVelocity = 85
    local labelRollTime = 7
    -- self.suonaChatMsgStrPosXSrc - self.suonaChatMsgStrPosXDes / chatMsgLabelRollVelocity
    -- self.suonaChatInfo_:getContentSize().width / chatMsgLabelRollVelocity > 4 and 4 or self.suonaChatInfo_:getContentSize().width / chatMsgLabelRollVelocity
    -- self.suonaChatInfo_:show()
    self.suonaChatInfo_:setOpacity(255) -- cc.c3b(255, 0, 255)

    self.suonaMsgAnim_ = transition.execute(self.suonaChatInfo_, cc.MoveTo:create(labelRollTime,
        cc.p(self.suonaChatMsgStrPosXDes, 0)), {delay = chatMsgPlayDelayTime / 2})

    self.suonaDelayCallHandler_ = nk.schedulerPool:delayCall(handler(self, self.playSuonaMsgNext), labelRollTime + chatMsgPlayDelayTime + chatMsgShownTimeIntval)
    -- self.delayScheduleHandle_ = scheduler.performWithDelayGlobal(handler(self, self.delayCallback_), 0.3 + DEFAULT_STAY_TIME + scrollTime)
end

function MainHallView:onNewerGuideBtnClicked()
    dump("MainHallView:onNewerGuideBtnClicked")
    local day = 0 
    if nk.NewerGuide then
        day = nk.NewerGuide:getNewerDay()
    end

    local data = {}
    if 1 == day then
        data.content = bm.LangUtil.getText("NEWER", "GUIDE_REWARD_CONTENT_2",200000)
        data.iconFlag = 2
        NewerGuidePopup.new():show(data)
    elseif 2 == day then
        --领取次日奖励
        if nk.NewerGuide then
            nk.NewerGuide:requestNextDayReward()
        end
    end
end

function MainHallView:onUpdateVerBtnClicked()
    local updata = bm.DataProxy:getData(nk.dataKeys.UPDATE_INFO)
    if not updata then
        return
    end

    if not updata.type then
        return
    end

    if 1 == updata.type then
        -- 弹升级框
        nk.ui.Dialog.new({
            hasCloseButton = false,
            messageText = updata.prizedesc or "", 
            firstBtnText = bm.LangUtil.getText("UPDATE", "DO_LATER"),
            secondBtnText = bm.LangUtil.getText("UPDATE", "UPDATE_NOW"), 
            callback = function (type)
                if type == nk.ui.Dialog.FIRST_BTN_CLICK then
                    
                elseif type == nk.ui.Dialog.SECOND_BTN_CLICK then
                    self:checkToUpdate()
                end
            end
        }):show()
    elseif 2 == updata.type then
        if not updata.hasGetPrize or (updata.hasGetPrize == 0) then
            --领取奖励，请求接口

            self.getUpdateRequestId_ = nk.http.GetUpdateVerReward(function(data)
                self.getUpdateRequestId_ = nil
                if data and data.money and data.getmoney then
                    local version = BM_UPDATE and BM_UPDATE.VERSION or nk.Native:getAppVersion()
                    nk.userData["aUser.money"] = data.money
                    nk.TopTipManager:showTopTip(string.format("ยินดีด้วยค่ะ คุณได้รับรางวัล %s ชิป เวอร์ชั่นปัจจุบันของคุณ:V%s.",(data.getmoney or 0),version) )
                    updata.hasGetPrize = 1
                    bm.DataProxy:setData(nk.dataKeys.UPDATE_INFO,updata)

                end
            end,function(errData)
                self.getUpdateRequestId_ = nil
                -- body
            end)

        else
             --已经领取过了
        end

    end
end


function MainHallView:checkToUpdate()
    local params = 
    {
        device = (device.platform == "windows" and "android" or device.platform), 
        pay = (device.platform == "windows" and "android" or device.platform), 
        noticeVersion = "noticeVersion",
        osVersion = BM_UPDATE and BM_UPDATE.VERSION or nk.Native:getAppVersion(),
        version = BM_UPDATE and BM_UPDATE.VERSION or nk.Native:getAppVersion(),
        sid = appconfig.ROOT_CGI_SID,
    }
    
    if IS_DEMO then
        params.demo = 1
    end

    nk.http.post_url(appconfig.VERSION_CHECK_URL,params,
        function (data)
            if data then
                local retData = json.decode(data)
                self:checkUpdate(retData.curVersion, retData.verTitle, retData.verMessage, retData.updateUrl)
            end
        end, 
        function ()
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "BAD_NETWORK"))  
        end)
end


function MainHallView:checkUpdate(curVersion, verTitle, verMessage, updateUrl)
    local latestVersionNum = bm.getVersionNum(curVersion)
    local installVersionNum = bm.getVersionNum(BM_UPDATE.VERSION)
    print("latestVersionNum:"..latestVersionNum)
    print("installVersionNum:"..installVersionNum)

    if latestVersionNum <= installVersionNum then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("UPDATE", "HAD_UPDATED"))
    else
        UpdatePopup.new(verTitle, verMessage, updateUrl):show()
    end
end


function MainHallView:refreshMatchAndDokbEntryUi()
    -- body
    local userLevelFact = nk.Level:getLevelByExp(nk.userData["aUser.exp"])
    if userLevelFact >= 3 or nk.userData["aUser.mlevel"] >= 3 then
        --todo
        if self then
            --todo
            -- Remove DokbEntry Sheild --
            if self.lockDokbTips_ then
                --todo
                self.lockDokbTips_:removeFromParent()
                self.lockDokbTips_ = nil
            end

            if self.lockDokbEntry_ then
                --todo
                self.lockDokbEntry_:removeFromParent()
                self.lockDokbEntry_ = nil
            end

            if self.dokbEntrySheildModel_ then
                --todo
                self.dokbEntrySheildModel_:removeFromParent()
                self.dokbEntrySheildModel_ = nil
            end

            -- Remove ProRoomEntry Sheild --
            if self.lockProRoomTips_ then
                --todo
                self.lockProRoomTips_:removeFromParent()
                self.lockProRoomTips_ = nil
            end

            if self.lockProRoom_ then
                --todo
                self.lockProRoom_:removeFromParent()
                self.lockProRoom_ = nil
            end

            if self.proRoomSheildModel_ then
                --todo
                self.proRoomSheildModel_:removeFromParent()
                self.proRoomSheildModel_ = nil
            end
        end
    else
        dump("User Level Lower Than 3!")
    end
end

function MainHallView:onUserInfoBtnClicked()

    nk.DReport:report({id = "userInfoClick"})
    local enterMatch = function()
        self:onMatchHallClick()
    end
    UserInfoPopup.new(nil,{enterMatch = enterMatch}):show(false)
    
end

function MainHallView:onStoreBtnClicked()
    nk.DReport:report({id = "openStoreClick"})
    StorePopup.new():showPanel()

     -- local InvitePlayPopup = import("app.module.invitePlay.InvitePlayPopup")
     -- InvitePlayPopup.new():show()
end

function MainHallView:onFriendBtnClicked()

    nk.DReport:report({id = "openFriendClick"})
    FriendPopup.new():show()
end


function MainHallView:onScoreMarketBtnClicked(isShowAddFill)
    nk.DReport:report({id = "openMarketClick"})
    display.addSpriteFrames("scoreMarket_th.plist", "scoreMarket_th.png", function()
        local scoreMarketView = ScoreMarketView.new():show()

        if isShowAddFill and type(isShowAddFill) == "boolean" then
            --todo
            scoreMarketView:onShowAddressPopul_()
        end
    end)
end

function MainHallView:onRankingBtnClicked()
   nk.DReport:report({id = "openRankClick"})
    RankingPopup.new():show()
end

function MainHallView:onMessageBtnClicked()
    nk.DReport:report({id = "openMessageClick"})
    MessageView.new():show()
end

function MainHallView:onSettingBtnClicked()
   
    SettingAndHelpPopup.new():show()
end

function MainHallView:removePropertyObservers()
    bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "aUser.name", self.nickObserverHandle_)
    bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "aUser.money", self.moneyObserverHandle_)
    bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "aUser.mlevel", self.levelObserverHandle_)
    bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "aUser.exp", self.experienceObserverHandle_)
    bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "aUser.micon", self.avatarUrlObserverHandle_)
    bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "USER_ONLINE", self.userOnlineObserverHandle_)
    bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "__user_discount", self.discountObserverHandle_)
    bm.DataProxy:removeDataObserver(nk.dataKeys.NEW_MESSAGE, self.onNewMessageDataObserver)
    -- bm.DataProxy:removeDataObserver(nk.dataKeys.MOTHER_DAY, self.onNewActDataObserver)
    bm.DataProxy:removeDataObserver(nk.dataKeys.OPEN_ACT,self.onHallNewsIconObserver)
    bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "inviteBackChips",self.onHallInviteChipsObserver)

    bm.DataProxy:removeDataObserver(nk.dataKeys.UNIONACT_ONOFF, self.onUnionActOnOffObserver)
    bm.DataProxy:removeDataObserver(nk.dataKeys.CHARGEFAV_ONOFF, self.onChargeFavOnOffObserver)
    bm.DataProxy:removeDataObserver(nk.dataKeys.ALMRECHARGEFAV_ONOFF, self.onAlmRechargeFavOnOffObserver)
    bm.DataProxy:removeDataObserver(nk.dataKeys.HALL_NEWSTACT_PAOPTIP, self.onNewstActPaopTipObserver)
    bm.DataProxy:removeDataObserver(nk.dataKeys.SUONA_USETIP_ONOFF, self.onSuonaTipsObserver)
    bm.DataProxy:removeDataObserver(nk.dataKeys.UPDATE_INFO,self.onUpdateVerInfoObserver)
    bm.DataProxy:removeDataObserver(nk.dataKeys.NEWER_GUIDE_DAY,self.onNewerGuideDayObserver)
end

function MainHallView:onCleanup()
    self:removePropertyObservers()
    nk.ImageLoader:cancelJobByLoaderId(self.userAvatarLoaderId_)
    if nk.config.CHRISTMAS_THEME_ENABLED then
        audio.stopMusic(true)
    end

     if self.lvRequest_ then
        nk.Level:cancel(self.lvRequest_)
        self.lvRequest_ = nil
    end

    if self._coinAnim then
        --todo
        self:stopAction(self._coinAnim)
    end

    if self._newstActEntryPaopAnim then
        --todo
        self:stopAction(self._newstActEntryPaopAnim)
        bm.DataProxy:setData(nk.dataKeys.HALL_NEWSTACT_PAOPTIP, false)
    end

    if self.suonaMsgAnim_ then
        --todo
        self:stopAction(self.suonaMsgAnim_)
    end

    if self.suonaDelayCallHandler_ then
        --todo
        nk.schedulerPool:clear(self.suonaDelayCallHandler_)
    end

    if self.suonaIconClickTipAction_ then
        --todo
        self:stopAction(self.suonaIconClickTipAction_)
        self.suonaIconClickTipAction_ = nil
        bm.DataProxy:setData(nk.dataKeys.SUONA_USETIP_ONOFF, false)
    end

    if self.getUpdateRequestId_ then
        nk.http.cancel(self.getUpdateRequestId_)
        self.getUpdateRequestId_ = nil
    end

	display.removeSpriteFramesWithFile("anims/inviteBushBarAnim.plist", "anims/inviteBushBarAnim.png")
    self.isOnCleanup_ = true
end

return MainHallView
