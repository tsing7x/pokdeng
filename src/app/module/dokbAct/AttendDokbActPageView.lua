--
-- Author: TsingZhang@boyaa.com
-- Date: 2016-05-26 10:49:38
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- Description: AttendDokbActPageView.lua By TsingZhang.
--
local HelpPopup = import("app.module.settingAndhelp.SettingAndHelpPopup")
local ScoreMarketView = import("app.module.scoreMarket.ScoreMarketView")
local StorePopup = import("app.module.newstore.StorePopup")
local PayGuide = import("app.module.room.purchGuide.PayGuide")
local FirChargePayGuidePopup = import("app.module.newstore.firChrgGuide.FirChrgPayGuidePopup")
local AgnChargePayGuidePopup = import("app.module.newstore.agnChrgGuide.AgnChrgPayGuidePopup")
local SuonaUsePopup = import("app.module.suona.SuonaUsePopup")

local DokbHelpPopup = import(".actView.DokbActHelpPopup")

local DokbActListTermItem = import(".DokbActListTermItem")
local LotryRecListItem = import(".DokbLotryRecListItem")
local MyRecListItem = import(".DokbMyRecListItem")

-- Normal Const --
local TOP_BUTTOM_WIDTH   = 78
local TOP_BUTTOM_HEIGHT  = 64
local TOP_BUTTOM_PADDING = 8
-- local TOP_TAB_BAR_WIDTH  = 612
local TOP_TAB_BAR_HEIGHT = 66
local AVATAR_TAG = 100

local ActContPageParam = {
	WIDTH = 902,
	HEIGHT = 404
}

local CHIP_HORIZONTAL_DISTANCE = 192 * nk.widthScale  -- 240 * nk.widthScale
local CHIP_VERTICAL_DISTANCE   = 188 * nk.heightScale  -- 216 * nk.heightScale

local AttendDokbActPageView = class("AttendDokbActPageView", function()
	-- body
	return display.newNode()
end)

function AttendDokbActPageView:ctor(controller)
	-- body
	self.controller_ = controller
	self.controller_:setDisplayView(self)

	self:setNodeEventEnabled(true)

    display.addSpriteFrames("dokb_act.plist", "dokb_act.png")

	-- Main UI --
	local bgScale = self.controller_:getBgScale()

	-- Bg Display -- dokbAct_main_bg.png
	self.bgNode_ = display.newNode()
		:addTo(self)
		:scale(bgScale)

	local dokbBackground = display.newSprite("dokbAct_main_bg.png")
		:addTo(self.bgNode_)

    dokbBackground:setTouchEnabled(true)
    dokbBackground:setTouchSwallowEnabled(true)

	-- Top Operate Area --
	self.topBtnNode_ = display.newNode()
		:pos(0, TOP_BUTTOM_HEIGHT + TOP_TAB_BAR_HEIGHT + TOP_BUTTOM_PADDING)
		:addTo(self)

	-- btnReturn --
	display.newScale9Sprite("#top_btn_bg.png", 0, 0, cc.size(TOP_BUTTOM_WIDTH + 4, TOP_BUTTOM_HEIGHT + 4))
        :pos(- display.cx + TOP_BUTTOM_WIDTH * 0.5 + TOP_BUTTOM_PADDING, display.cy - TOP_BUTTOM_HEIGHT * 0.5 - TOP_BUTTOM_PADDING)
        :addTo(self.topBtnNode_)

    display.newSprite("#hall_top_return_icon_up.png")
        :pos(- display.cx + TOP_BUTTOM_WIDTH * 0.5 + TOP_BUTTOM_PADDING, display.cy - TOP_BUTTOM_HEIGHT * 0.5 - TOP_BUTTOM_PADDING)
        :addTo(self.topBtnNode_)

    self.btnRetrun_ = cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#rounded_rect_6.png"}, {scale9 = true})
	    :setButtonSize(TOP_BUTTOM_WIDTH, TOP_BUTTOM_HEIGHT)
	    :pos(- display.cx + TOP_BUTTOM_WIDTH * 0.5 + TOP_BUTTOM_PADDING, display.cy - TOP_BUTTOM_HEIGHT * 0.5 - TOP_BUTTOM_PADDING)
	    :addTo(self.topBtnNode_)
	    :onButtonClicked(buttontHandler(self, self.onReturnClick_))

	-- btnHelp --
	self.btnHelp_ = cc.ui.UIPushButton.new({normal = "#dokb_btnHelp_nor.png", pressed = "#dokb_btnHelp_pre.png"})
        :pos(- display.cx + TOP_BUTTOM_WIDTH * 0.5 + TOP_BUTTOM_PADDING, display.cy - TOP_BUTTOM_HEIGHT * 0.5 - TOP_BUTTOM_PADDING - 90)
        :addTo(self.topBtnNode_)
        :onButtonClicked(buttontHandler(self, self.onHelpClick_))

    -- btnFeedBack
    display.newScale9Sprite("#top_btn_bg.png", 0, 0, cc.size(TOP_BUTTOM_WIDTH + 4, TOP_BUTTOM_HEIGHT + 4))
        :pos(display.cx - TOP_BUTTOM_WIDTH * 1.5 - TOP_BUTTOM_PADDING * 2, display.cy - TOP_BUTTOM_HEIGHT * 0.5 - TOP_BUTTOM_PADDING)
        :addTo(self.topBtnNode_)

    display.newSprite("#feedback_hall_icon_up.png")
        :pos(display.cx - TOP_BUTTOM_WIDTH * 1.5 - TOP_BUTTOM_PADDING * 2, display.cy - TOP_BUTTOM_HEIGHT * 0.5 - TOP_BUTTOM_PADDING)
        :addTo(self.topBtnNode_)
        :scale(0.88)

    self.btnFeedBack_ = cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#rounded_rect_6.png"}, {scale9 = true})
        :setButtonSize(TOP_BUTTOM_WIDTH, TOP_BUTTOM_HEIGHT)
        :pos(display.cx - TOP_BUTTOM_WIDTH * 1.5 - TOP_BUTTOM_PADDING * 2, display.cy - TOP_BUTTOM_HEIGHT * 0.5 - TOP_BUTTOM_PADDING)
        :addTo(self.topBtnNode_)
        :onButtonClicked(buttontHandler(self, self.onFeedbackClick_))
   
    -- btnScorMarket
    display.newScale9Sprite("#top_btn_bg.png", 0, 0, cc.size(TOP_BUTTOM_WIDTH + 4, TOP_BUTTOM_HEIGHT + 4))
	    :pos(display.cx - TOP_BUTTOM_WIDTH * 0.5 - TOP_BUTTOM_PADDING, display.cy - TOP_BUTTOM_HEIGHT * 0.5 - TOP_BUTTOM_PADDING)
	    :addTo(self.topBtnNode_)

    display.newSprite("#market_hall_icon_up.png")
        :pos(display.cx - TOP_BUTTOM_WIDTH * 0.5 - TOP_BUTTOM_PADDING, display.cy - TOP_BUTTOM_HEIGHT * 0.5 - TOP_BUTTOM_PADDING)
        :addTo(self.topBtnNode_)

    self.btnExStore_ = cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#rounded_rect_6.png"}, {scale9 = true})
        :setButtonSize(TOP_BUTTOM_WIDTH, TOP_BUTTOM_HEIGHT)
        :pos(display.cx - TOP_BUTTOM_WIDTH * 0.5 - TOP_BUTTOM_PADDING, display.cy - TOP_BUTTOM_HEIGHT * 0.5 - TOP_BUTTOM_PADDING)
        :addTo(self.topBtnNode_)
        :onButtonClicked(buttontHandler(self, self.onExchangeStoreClick_))

    -- if not nk.userData.DOKB_TAB then
    --     --todo
    -- end
    local dokbActContPageNodePaddingTop = 165
 --    local contBgSize = {
 --    	width = 902,
 --    	height = 404
	-- }

    self.dokbActPageNode_ = display.newNode()
    	:pos(0, display.cy - ActContPageParam.HEIGHT / 2 - dokbActContPageNodePaddingTop)
    	:addTo(self)

    -- local actPageBgPaddingBot = 76
    local actContPageBg = display.newScale9Sprite("#dokb_bgActPanel.png", 0, 0,
    	cc.size(ActContPageParam.WIDTH, ActContPageParam.HEIGHT))
    	:addTo(self.dokbActPageNode_)

    -- 后面根据条件修改这两个defaultTabIdx 值 --
    self.defaultTabIdx_ = nk.userData.DOKB_TAB or 1
    -- self.defaultActTypeIdx_ = 1
    self.defaultLotryRecSubItemIdx_ = 1

    self.mainTabBar_ = nk.ui.CommonPopupTabBar.new(
        {
            popupWidth = display.width - 230, 
            iconOffsetX = 15, 
            iconTexture = {
                {"#dokb_tabActList_sel.png", "#dokb_tabActList_unSel.png"}, 
                {"#dokb_tabLottryRec_sel.png", "#dokb_tabLottryRec_unSel.png"}, 
                {"#dokb_tabMyRec_sel.png", "#dokb_tabMyRec_unSel.png"}
            }, 
            btnText = bm.LangUtil.getText("DOKB", "DOKB_PAGE_INDEX")
        })
        :setTabBarExtraParam({noIconCircle = true, tabFrontSize = 24})
        :pos(- 20, display.cy - TOP_TAB_BAR_HEIGHT * 0.5 - 2)
        :onTabChange(handler(self, self.onMainTabChange))
        :addTo(self.topBtnNode_)

   	--BordcastMsg --
    local systemTipWidth = (display.width - 230) * 0.85
    local systemTipHeight = 51 --也是小喇叭的高度

    local bordCastMsgShownPanel = display.newScale9Sprite("#hall_system_info_bg.png", 0, 0, cc.size(systemTipWidth, systemTipHeight))
        :addTo(self.topBtnNode_)
        :pos(- 20, display.cy  - TOP_TAB_BAR_HEIGHT * 0.5 - 95)

    local suonaIcon = display.newSprite("#hall_system_info_icon.png")
        :addTo(self.topBtnNode_)
        :pos(- 20 - systemTipWidth / 2 + systemTipHeight / 2, display.cy  - TOP_TAB_BAR_HEIGHT * 0.5 - 95)

    local suonaIconSize = suonaIcon:getContentSize()

    local sendBordCBtnSize = {
        width = 128,
        height = 54
    }

    local btnSendLabelParam = {
        frontSize = 24,
        color = display.COLOR_WHITE
    }

    self.btnSendBordCast_ = cc.ui.UIPushButton.new({normal = "#common_btnGreenCor_nor.png", pressed = "#common_btnGreenCor_pre.png", disabled = "#common_btnGreenCor_nor.png"},
        {scale9 = true})
        :setButtonSize(sendBordCBtnSize.width, sendBordCBtnSize.height)
        :setButtonLabel(display.newTTFLabel({text = bm.LangUtil.getText("COMMON", "SEND"), size = btnSendLabelParam.frontSize, color = btnSendLabelParam.color, align = ui.TEXT_ALIGN_CENTER}))
        :onButtonClicked(buttontHandler(self, self.onSendBordBtnCallBack_))
        :pos(systemTipWidth / 2 - sendBordCBtnSize.width / 2 - 20, display.cy  - TOP_TAB_BAR_HEIGHT * 0.5 - 96)
        :addTo(self.topBtnNode_)

    local suonaMsgClipNodeMagrinHoriz = 5
    local suonaMsgClipNodeCrosRightBtnWidth = sendBordCBtnSize.width / 2 + 62

    local suonaMsgLabelStencil = display.newDrawNode()
    suonaMsgLabelStencil:drawPolygon({
        {- systemTipWidth / 2 + suonaIconSize.width + suonaMsgClipNodeMagrinHoriz, - systemTipHeight / 2}, 
        {- systemTipWidth / 2 + suonaIconSize.width + suonaMsgClipNodeMagrinHoriz,  systemTipHeight / 2}, 
        {systemTipWidth / 2 - suonaMsgClipNodeCrosRightBtnWidth - suonaMsgClipNodeMagrinHoriz,  systemTipHeight / 2}, 
        {systemTipWidth / 2 - suonaMsgClipNodeCrosRightBtnWidth - suonaMsgClipNodeMagrinHoriz, - systemTipHeight / 2}
    })

    local suonaMsgClipNode = cc.ClippingNode:create()
        :pos(systemTipWidth / 2, systemTipHeight / 2)
        :addTo(bordCastMsgShownPanel)
    suonaMsgClipNode:setStencil(suonaMsgLabelStencil)

    -- local bordCastMsgLabelMagrinRight = 10
    self.bordCastMsg_ = display.newTTFLabel({text = bm.LangUtil.getText("HALL", "CHOOSE_ROOM_SUONA_USE_TIP"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 22, align = ui.TEXT_ALIGN_CENTER})

    self.bordCastMsg_:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER_LEFT])
        -- :align(display.LEFT_CENTER)
    self.bordCastMsg_:pos(systemTipWidth / 2 - suonaMsgClipNodeCrosRightBtnWidth - suonaMsgClipNodeMagrinHoriz - self.bordCastMsg_:getContentSize().width,
        0)
        :addTo(suonaMsgClipNode)

    self.bordCastMsgStartX_ = systemTipWidth / 2 - suonaMsgClipNodeCrosRightBtnWidth - suonaMsgClipNodeMagrinHoriz
    self.bordCastMsgDesX_ = - systemTipWidth / 2 + suonaIconSize.width + suonaMsgClipNodeMagrinHoriz

    local lastRecordDay = nk.userDefault:getStringForKey(nk.cookieKeys.ATTEND_DOKBACT_TIP_LASTRECDDAY)
    local dayNow = os.date("%Y%m%d")

    local tipAnimShownTimes = nk.userDefault:getIntegerForKey(nk.cookieKeys.ATTEND_DOKBACT_TIP_SHOWNTIME, 0)
    local tipAnimShownTimeOneDay = 1

    local bgHelpInsSize = {
        width = 180,
        height = 48
    }
    local bgHelpInsPosXAdj, bgHelpInsPosYAdj = 30, 5

    local bgHelpInsRectParam = {
        orignPos = {
            x = 33,
            y = 10
        },
        rectSize = {
            width = 18,
            height = 26
        }
    }
    self.bgHelpTipInsNode_ = display.newNode()
        :pos(- display.cx + TOP_BUTTOM_WIDTH * 0.5 + TOP_BUTTOM_PADDING + bgHelpInsPosXAdj + bgHelpInsSize.width / 2,
            display.cy - TOP_BUTTOM_HEIGHT * 0.5 - TOP_BUTTOM_PADDING - 90 + bgHelpInsPosYAdj)
        :addTo(self.topBtnNode_)

    if string.len(lastRecordDay) <= 0 or lastRecordDay ~= dayNow then
        --todo

        local bgHelpInsHili = display.newScale9Sprite("#dokb_bgInsTips_help.png", 0, 0, cc.size(bgHelpInsSize.width, bgHelpInsSize.height),
            cc.rect(bgHelpInsRectParam.orignPos.x, bgHelpInsRectParam.orignPos.y, bgHelpInsRectParam.rectSize.width, bgHelpInsRectParam.rectSize.height))
            :addTo(self.bgHelpTipInsNode_)

        local checkHelpTipLblParam = {
            frontSize = 24,
            color = cc.c3b(146, 79, 5)
        }

        local checkHelpTipsPosAdj = {
            x = 3,
            y = 4
        }
        local checkHelpTips = display.newTTFLabel({text = bm.LangUtil.getText("DOKB", "CHECK_HELP_TIP"), size = checkHelpTipLblParam.frontSize, color = checkHelpTipLblParam.color,
            align = ui.TEXT_ALIGN_CENTER})
        checkHelpTips:pos(bgHelpInsRectParam.orignPos.x + checkHelpTips:getContentSize().width / 2 + checkHelpTipsPosAdj.x, bgHelpInsSize.height / 2 - checkHelpTipsPosAdj.y)
            :addTo(bgHelpInsHili)

        local actionPosXMove = 8
        local actionMoveTime = 0.8

        self.checkHelpInsTipsRepeatAction_ = self.bgHelpTipInsNode_:runAction(cc.RepeatForever:create(transition.sequence({
            cc.MoveBy:create(actionMoveTime, cc.p(actionPosXMove, 0)),            -- cc.DelayTime:create(0.3),
            cc.MoveBy:create(actionMoveTime, cc.p(- actionPosXMove, 0))            -- cc.DelayTime:create(0.1),
        })))

        nk.userDefault:setStringForKey(nk.cookieKeys.ATTEND_DOKBACT_TIP_LASTRECDDAY, dayNow)
        nk.userDefault:setIntegerForKey(nk.cookieKeys.ATTEND_DOKBACT_TIP_SHOWNTIME, 1)
    else
        if tipAnimShownTimes < tipAnimShownTimeOneDay then
            --todo
            local bgHelpInsHili = display.newScale9Sprite("#dokb_bgInsTips_help.png", 0, 0, cc.size(bgHelpInsSize.width, bgHelpInsSize.height),
                cc.rect(bgHelpInsRectParam.orignPos.x, bgHelpInsRectParam.orignPos.y, bgHelpInsRectParam.rectSize.width, bgHelpInsRectParam.rectSize.height))
                :addTo(self.bgHelpTipInsNode_)

            local checkHelpTipLblParam = {
                frontSize = 24,
                color = cc.c3b(146, 79, 5)
            }

            local checkHelpTipsPosAdj = {
                x = 3,
                y = 4
            }
            local checkHelpTips = display.newTTFLabel({text = bm.LangUtil.getText("DOKB", "CHECK_HELP_TIP"), size = checkHelpTipLblParam.frontSize, color = checkHelpTipLblParam.color,
                align = ui.TEXT_ALIGN_CENTER})
            checkHelpTips:pos(bgHelpInsRectParam.orignPos.x + checkHelpTips:getContentSize().width / 2 + checkHelpTipsPosAdj.x, bgHelpInsSize.height / 2 - checkHelpTipsPosAdj.y)
                :addTo(bgHelpInsHili)

            local actionPosXMove = 8
            local actionMoveTime = 0.8

            self.checkHelpInsTipsRepeatAction_ = self.bgHelpTipInsNode_:runAction(cc.RepeatForever:create(transition.sequence({
                cc.MoveBy:create(actionMoveTime, cc.p(actionPosXMove, 0)),            -- cc.DelayTime:create(0.3),
                cc.MoveBy:create(actionMoveTime, cc.p(- actionPosXMove, 0))            -- cc.DelayTime:create(0.1),
            })))

            nk.userDefault:setIntegerForKey(nk.cookieKeys.ATTEND_DOKBACT_TIP_SHOWNTIME, tipAnimShownTimes + 1)
        end
    end

    --底部
    self.bottomNode_ = display.newSprite()
        :addTo(self)
        :pos(0,- display.height)

    local BUTTOM_BG_H = 45

    display.newScale9Sprite("#hall_chooseView_buttom_bg.png", 0, 0, cc.size(display.width, BUTTOM_BG_H))
        :addTo(self.bottomNode_)
        :pos(0, - BUTTOM_BG_H / 2)

    self.userAvatarLoaderId_ = nk.ImageLoader:nextLoaderId()

    local avatarSizeBorderShown = 35

    self.avatar_ = display.newSprite("#common_male_avatar.png")
    self.avatar_:addTo(self.bottomNode_, 0, AVATAR_TAG)
    self.avatar_:align(display.LEFT_CENTER)
    self.avatar_:pos(- display.width / 2 + 20, - 23)

    local avatarSizeWidthReal = self.avatar_:getContentSize().width
    self.avatar_:setScale(avatarSizeBorderShown / avatarSizeWidthReal)

    -- nk.ImageLoader:loadAndCacheImage(self.userAvatarLoaderId_, nk.userData["aUser.micon"], handler(self, self.onAvatarImgLoadComplete_), nk.ImageLoader.CACHE_TYPE_USER_HEAD_IMG)

    local pos_y = - 23 --底部元素y值
    local icon_gap = 180 --底部icon间隔
    local start_x = - display.width / 2 + 120 --底部icon起点值
    local buttom_Txt_width = 120 --底部文本宽度
    local txt_left_icon = 15 --底部文本相对icon偏移值

    local iconChip = display.newSprite("#hall_small_chip_icon.png")
        :addTo(self.bottomNode_)
        :pos(start_x, pos_y)

    local iconCash = display.newSprite("#hall_small_cash_icon.png")
        :addTo(self.bottomNode_)
    iconCash:pos(start_x + icon_gap + iconCash:getContentSize().width / 2, pos_y)

    -- 去掉关于比赛的数据项显示
    -- local iconDTicket = display.newSprite("#hall_small_d_ticket.png")
    --     :addTo(self.bottomNode_)
    -- iconDTicket:pos(start_x + 2 * icon_gap + iconDTicket:getContentSize().width / 2, pos_y)

    -- local iconTTicket = display.newSprite("#hall_small_t_ticket.png")
    --     :addTo(self.bottomNode_)
    -- iconTTicket:pos(start_x + 3 * icon_gap + iconTTicket:getContentSize().width / 2, pos_y)

    -- local iconMatchCup = display.newSprite("#hall_small_c_cion.png")
    --     :addTo(self.bottomNode_)
    -- iconMatchCup:pos(start_x + 4 * icon_gap + iconMatchCup:getContentSize().width / 2, pos_y)

    self.chipsNum_ = display.newTTFLabel({text = bm.formatNumberWithSplit(nk.userData["aUser.money"]), color = cc.c3b(0xff, 0xff, 0xff), dimensions = cc.size(buttom_Txt_width, 30), size = 20, align = ui.TEXT_ALIGN_LEFT})
        :align(display.LEFT_CENTER)
        :addTo(self.bottomNode_)
        :pos(iconChip:getPositionX() + txt_left_icon, pos_y)

    if nk.userData["aUser.money"] >= 1000000000 then
        --todo
        self.chipsNum_:setString(bm.formatBigNumber(nk.userData["aUser.money"]))
    end

    self.cashNum_ = display.newTTFLabel({text = bm.formatNumberWithSplit(nk.userData["match.point"]), color = cc.c3b(0xe1, 0xc8, 0x02),dimensions = cc.size(buttom_Txt_width, 30), size = 20, align = ui.TEXT_ALIGN_LEFT})
        :align(display.LEFT_CENTER)
        :addTo(self.bottomNode_)
        :pos(iconCash:getPositionX() + txt_left_icon, pos_y)

    if nk.userData["match.point"] >= 1000000000 then
        --todo
        self.cashNum_:setString(bm.formatBigNumber(nk.userData["match.point"]))
    end

    -- self.ticketDNum_ = display.newTTFLabel({text = "0", color = cc.c3b(0xe1, 0xc8, 0x02),dimensions = cc.size(buttom_Txt_width, 30), size = 20, align = ui.TEXT_ALIGN_LEFT})
    --     :align(display.LEFT_CENTER)
    --     :addTo(self.bottomNode_)
    --     :pos(iconDTicket:getPositionX() + txt_left_icon + 10, pos_y)

    -- self.ticketTNum_ = display.newTTFLabel({text = "0", color = cc.c3b(0xe1, 0xc8, 0x02),dimensions = cc.size(buttom_Txt_width, 30), size = 20, align = ui.TEXT_ALIGN_LEFT})
    --     :align(display.LEFT_CENTER)
    --     :addTo(self.bottomNode_)
    --     :pos(iconTTicket:getPositionX() + txt_left_icon + 10, pos_y)

    -- self.matchCupNum_ = display.newTTFLabel({text = "0", color = cc.c3b(0x92, 0xdc, 0x5f),dimensions = cc.size(buttom_Txt_width, 30), size = 20, align = ui.TEXT_ALIGN_LEFT})
    --     :align(display.LEFT_CENTER)
    --     :addTo(self.bottomNode_)
    --     :pos(iconMatchCup:getPositionX() + txt_left_icon, pos_y)

    local yellowBtnWidth = 148
    local yellowBtnHeight = 42

    display.newScale9Sprite("#hall_choose_yellow_btn.png", 0, 0, cc.size(yellowBtnWidth, yellowBtnHeight))
        :pos(display.width / 2 - yellowBtnWidth + 45, pos_y)
        :addTo(self.bottomNode_)

    local storeIcon = display.newSprite("#hall_small_cash_icon.png")
	    :addTo(self.bottomNode_)
        :pos(display.width / 2 - yellowBtnWidth + 45 - 40, pos_y)

    display.newTTFLabel({text = bm.LangUtil.getText("COMMON", "BUY"), color = cc.c3b(75, 19, 19), size = 20, align = ui.TEXT_ALIGN_CENTER})
        :addTo(self.bottomNode_)
        :pos(display.width / 2 - yellowBtnWidth + 55, pos_y)

    cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#rounded_rect_10.png"}, {scale9 = true})
        :setButtonSize(yellowBtnWidth - 5, yellowBtnHeight)
        :onButtonClicked(buttontHandler(self, self.onStoreClick_))
        :pos(display.width / 2 - yellowBtnWidth + 45, pos_y)
        :addTo(self.bottomNode_)

    if self.defaultTabIdx_ ~= 1 then
        --todo
        self.mainTabBar_:gotoTab(self.defaultTabIdx_)
    end
end

function AttendDokbActPageView:renderDokbActPageByIdx(pageIdx)
	-- body
	local drawDokbActPagesByIdex = {
		[1] = function()
			-- body
			local actListPage = display.newNode()
			-- local testLabel = display.newTTFLabel({text = "This is Page ActList!", size = 24, align = ui.TEXT_ALIGN_CENTER})
			-- 	:addTo(actListPage)
			local actTermLblParam = {
				frontSize = 20,
				color = cc.c3b(255, 227, 35)
			}

			local actTermLblMagrins = {
				left = 40,
				top = 30
			}
			self.actTermNum_ = display.newTTFLabel({text = "Term Id: 0", size = actTermLblParam.frontSize, color = actTermLblParam.color, align = ui.TEXT_ALIGN_CENTER})
			self.actTermNum_:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER_LEFT])
			self.actTermNum_:pos(- ActContPageParam.WIDTH / 2 + actTermLblMagrins.left, ActContPageParam.HEIGHT / 2 - actTermLblMagrins.top)
				:addTo(actListPage)

			-- self.actListSubAreaBtnGroup_ = nk.ui.CheckBoxButtonGroup.new()

			-- local subAreaNameStr = {
			-- 	"1-5现金币专区",
			-- 	"10现金币专区",
			-- 	"活动专区"
			-- }

			-- local subAreaBtnSize = {
			-- 	width = 172,
			-- 	height = 42
			-- }

			-- local subAreaBtnMagrins = {
			-- 	top = 10,
			-- 	each = 2
			-- }

			-- local subAreaBtnLabelParam = {
			-- 	frontSize = 20,
			-- 	color = display.COLOR_WHITE
			-- }

			-- self.actListSubAreaBtns_ = {}
			-- for i = 1, #subAreaNameStr do
			-- 	self.actListSubAreaBtns_[i] = cc.ui.UICheckBoxButton.new({on = "#dokb_btnSubArea_sel.png", off = "#dokb_btnSubArea_unSel.png"},
			-- 		{scale9 = true})
			-- 		:setButtonSize(subAreaBtnSize.width, subAreaBtnSize.height)
			-- 		-- :setButtonLabel(display.newTTFLabel({text = subAreaNameStr[i], size = subAreaBtnLabelParam.frontSize, color = subAreaBtnLabelParam.color, align = ui.TEXT_ALIGN_CENTER}))
			-- 		:pos((i - 2) * (subAreaBtnSize.width + subAreaBtnMagrins.each), ActContPageParam.HEIGHT / 2 - subAreaBtnSize.height / 2 - subAreaBtnMagrins.top)
			-- 		:addTo(actListPage)

			-- 	self.actListSubAreaBtns_[i].label_ = display.newTTFLabel({text = subAreaNameStr[i], size = subAreaBtnLabelParam.frontSize, color = subAreaBtnLabelParam.color, align = ui.TEXT_ALIGN_CENTER})
			-- 		:addTo(self.actListSubAreaBtns_[i])

			-- 	self.actListSubAreaBtnGroup_:addButton(self.actListSubAreaBtns_[i])
			-- end

			-- self.actListSubAreaBtnGroup_:onButtonSelectChanged(handler(self, self.onActTypeSelectChanged))
			-- self.actListSubAreaBtnGroup_:getButtonAtIndex(self.defaultActTypeIdx_):setButtonSelected(true)

			local actListItemParam = {
				width = 252,
				height = 324
			}

			local itemMagrinEach = 35

			self.actListTermItems_ = {}
			for i = 1, 3 do
				self.actListTermItems_[i] = DokbActListTermItem.new()
					:pos((i - 2) * (actListItemParam.width + itemMagrinEach), - display.cy - actListItemParam.height / 2)
					:addTo(actListPage)
			end

			return actListPage
		end,

		[2] = function()
			-- body
			local lottryRecPage = display.newNode()
			-- local testLabel = display.newTTFLabel({text = "This is Page LottryRec!", size = 24, align = ui.TEXT_ALIGN_CENTER})
   --              :addTo(lottryRecPage)
   			self.lotryTermIdBtnGroup_ = nk.ui.CheckBoxButtonGroup.new()

   			local lotryTermIdStr = {
   				"Last 1 Id: 0",
   				"Last 2 Id: 0",
   				"Last 3 Id: 0",
   				"Last 4 Id: 0",
   				"Last 5 Id: 0",
   				"Last 6 Id: 0"
   			}

   			local lotryTermBtnSize = {
				width = 138,
				height = 42
			}

			local lotryTermBtnMagrins = {
				top = 15,
				each = 2,
				totalRight = 22
			}

			local lotryTermBtnLabelParam = {
				frontSize = 18,
				color = cc.c3b(182, 200, 240)
			}

			self.lotryTermsIdBtns = {}
			for i = 1, #lotryTermIdStr do
				self.lotryTermsIdBtns[i] = cc.ui.UICheckBoxButton.new({on = "#dokb_btnSubArea_sel.png", off = "#dokb_btnSubArea_unSel.png"},
					{scale9 = true})
					:setButtonSize(lotryTermBtnSize.width, lotryTermBtnSize.height)
					-- :setButtonLabel(display.newTTFLabel({text = subAreaNameStr[i], size = subAreaBtnLabelParam.frontSize, color = subAreaBtnLabelParam.color, align = ui.TEXT_ALIGN_CENTER}))
					:pos((2 * (i - 4) + 1) / 2 * (lotryTermBtnSize.width + lotryTermBtnMagrins.each) - lotryTermBtnMagrins.totalRight, ActContPageParam.HEIGHT / 2 - lotryTermBtnSize.height / 2
						- lotryTermBtnMagrins.top)
					:addTo(lottryRecPage)

				self.lotryTermsIdBtns[i].label_ = display.newTTFLabel({text = lotryTermIdStr[i], size = lotryTermBtnLabelParam.frontSize, color = lotryTermBtnLabelParam.color, align = ui.TEXT_ALIGN_CENTER})
					:addTo(self.lotryTermsIdBtns[i])

				self.lotryTermIdBtnGroup_:addButton(self.lotryTermsIdBtns[i])
			end

			self.lotryTermIdBtnGroup_:onButtonSelectChanged(handler(self, self.onLotryRecTermIdSelectChanged))
			-- 请求错误不设置默认的选中button --
			-- self.lotryTermIdBtnGroup_:getButtonAtIndex(self.defaultLotryRecSubItemIdx_):setButtonSelected(true)

			local lotryRefreshBtnSize = {
				width = 45,
				height = 45
			}

			local lotryRefreshBtnPosAdj = {
				x = 6,
				y = 0
			}

			self.lotryRecRefreshBtn_ = cc.ui.UIPushButton.new({normal = "#dokb_btnRefresh_nor.png", pressed = "#dokb_btnRefresh_pre.png", disabled = "#dokb_btnRefresh_nor.png"}, {scale9 = false})
				:onButtonClicked(function()
					-- body
					self.lotryRecRefreshBtn_:setButtonEnabled(false)

					self:getDokePageData()
				end)
				:pos(ActContPageParam.WIDTH / 2 - lotryRefreshBtnSize.width / 2 - lotryRefreshBtnPosAdj.x, ActContPageParam.HEIGHT / 2 - lotryTermBtnSize.height / 2
						- lotryTermBtnMagrins.top - lotryRefreshBtnPosAdj.y)
				:addTo(lottryRecPage)

			local bgDentLotryRecSize = {
				width = 868,
				height = 320
			}

			local lotryRecBgPosYAdj = 30

			local lotryRecBgDent = display.newScale9Sprite("#dokb_bgDent.png", 0, - lotryRecBgPosYAdj, cc.size(bgDentLotryRecSize.width, bgDentLotryRecSize.height))
				:addTo(lottryRecPage)

			local bgGroupTitleSize = {
				width = bgDentLotryRecSize.width,
				height = 40
			}

			local lotryRecGroupTitleBg = display.newScale9Sprite("#dokb_bgTitle_rec.png", 0, bgDentLotryRecSize.height / 2 - bgGroupTitleSize.height / 2 - lotryRecBgPosYAdj,
				cc.size(bgGroupTitleSize.width, bgGroupTitleSize.height))
				:addTo(lottryRecPage)

			local groupNameStr = bm.LangUtil.getText("DOKB", "LOTRYREC_GROUP_NAME")
   --          {
			-- 	"夺宝物品",
			-- 	"中奖编号",
			-- 	"获奖用户",
			-- 	"我的夺宝编号"
			-- }

			-- local groupGapWidth = bgGroupTitleSize.width / 5
			local groupNameLblParam = {
				frontSize = 20,
				color = cc.c3b(225, 210, 109)
			}

			local groupDivLine = nil
			local groupNameLbl = nil

			for i = 1, #groupNameStr do
				if i ~= #groupNameStr then
					--todo

					groupDivLine = display.newSprite("#dokb_divLine_recGroup.png")
						:pos(bgGroupTitleSize.width / 5 * i, bgGroupTitleSize.height / 2)
						:addTo(lotryRecGroupTitleBg)

					groupNameLbl = display.newTTFLabel({text = groupNameStr[i], size = groupNameLblParam.frontSize, color = groupNameLblParam.color, align = ui.TEXT_ALIGN_CENTER})
						:pos(bgGroupTitleSize.width / 10 * (2 * i - 1), bgGroupTitleSize.height / 2)
						:addTo(lotryRecGroupTitleBg)
				else
					groupNameLbl = display.newTTFLabel({text = groupNameStr[i], size = groupNameLblParam.frontSize, color = groupNameLblParam.color, align = ui.TEXT_ALIGN_CENTER})
						:pos(bgGroupTitleSize.width * 4 / 5, bgGroupTitleSize.height / 2)
						:addTo(lotryRecGroupTitleBg)
				end
			end

			local lotryRecListParam = {
				width = 872,
				height = 276
			}

			-- local lotryRecListPosYAdj = 4
			self.lotryRecList_ = bm.ui.ListView.new({viewRect = cc.rect(- lotryRecListParam.width * 0.5, - lotryRecListParam.height * 0.5, lotryRecListParam.width,
				lotryRecListParam.height) --[[upRefresh = handler(self, self.onLotryRecUpToRefresh_)]]}, LotryRecListItem)
                :pos(0, - lotryRecBgPosYAdj - bgGroupTitleSize.height / 2)
                :addTo(lottryRecPage)

            local noRecTipsLblParam = {
            	frontSize = 36,
            	color = cc.c3b(224, 105, 105)
        	}

            self.noLotryRecTip_ = display.newTTFLabel({text = bm.LangUtil.getText("DOKB", "LOTRYREC_NORECTIP"), size = noRecTipsLblParam.frontSize, color = noRecTipsLblParam.color, align = ui.TEXT_ALIGN_CENTER})
            	:pos(0, - lotryRecBgPosYAdj - bgGroupTitleSize.height / 2)
            	:addTo(lottryRecPage)
            	:hide()
            -- self.lotryRecList_:setData({1, 2, 3, 4, 5, 6})

			return lottryRecPage
		end,

		[3] = function()
			-- body
			local myPaticRecPage = display.newNode()
			-- local testLabel = display.newTTFLabel({text = "This is Page MyPaticRec!", size = 24, align = ui.TEXT_ALIGN_CENTER})
   --              :addTo(myPaticRecPage)
   			local bgDentMyRecSize = {
				width = 866,
				height = 368
			}

			local myRecBgPosYAdj = 0

			local myRecBgDent = display.newScale9Sprite("#dokb_bgDent.png", 0, - myRecBgPosYAdj, cc.size(bgDentMyRecSize.width, bgDentMyRecSize.height))
				:addTo(myPaticRecPage)

			local bgGroupTitleSize = {
				width = bgDentMyRecSize.width,
				height = 40
			}

			local myRecGroupTitleBg = display.newScale9Sprite("#dokb_bgTitle_rec.png", 0, bgDentMyRecSize.height / 2 - bgGroupTitleSize.height / 2 - myRecBgPosYAdj,
				cc.size(bgGroupTitleSize.width, bgGroupTitleSize.height))
				:addTo(myPaticRecPage)

			local groupNameStr = bm.LangUtil.getText("DOKB", "MYREC_GROUP_NAME")
   --          {
			-- 	"夺宝期号",
			-- 	"夺宝物品",
			-- 	"中奖编号",
			-- 	"过期时间",
			-- 	"领奖查询"
			-- }

			local groupNameLblParam = {
				frontSize = 20,
				color = cc.c3b(196, 183, 97)
			}

			for i = 1, #groupNameStr do
				if i ~= #groupNameStr then
					--todo
					local groupDivLine = display.newSprite("#dokb_divLine_recGroup.png")
						:pos(bgGroupTitleSize.width / 5 * i, bgGroupTitleSize.height / 2)
						:addTo(myRecGroupTitleBg)
				end

				local groupNameLbl = display.newTTFLabel({text = groupNameStr[i], size = groupNameLblParam.frontSize, color = groupNameLblParam.color, align = ui.TEXT_ALIGN_CENTER})
					:pos(bgGroupTitleSize.width / 10 * (2 * i - 1), bgGroupTitleSize.height / 2)
					:addTo(myRecGroupTitleBg)
			end

			local myRecListParam = {
				width = 865,
				height = 320
			}

			self.myRecList_ = bm.ui.ListView.new({viewRect = cc.rect(- myRecListParam.width * 0.5, - myRecListParam.height * 0.5, myRecListParam.width,
				myRecListParam.height) --[[upRefresh = handler(self, self.onMyRecUpToRefresh_)]]}, MyRecListItem)
                :pos(0, - bgGroupTitleSize.height / 2)
                :addTo(myPaticRecPage)

            -- self.myRecList_:setData({1, 2, 3, 4, 5, 6, 8})

            local noRecTipsLblParam = {
            	frontSize = 36,
            	color = cc.c3b(224, 105, 105)
        	}

            self.noMyRecTip_ = display.newTTFLabel({text = bm.LangUtil.getText("DOKB", "MYREC_NORECTIP"), size = noRecTipsLblParam.frontSize, color = noRecTipsLblParam.color, align = ui.TEXT_ALIGN_CENTER})
            	:pos(0, - bgGroupTitleSize.height / 2)
            	:addTo(myPaticRecPage)
            	:hide()

			return myPaticRecPage
		end
	}

	return drawDokbActPagesByIdex[pageIdx]()
end

function AttendDokbActPageView:onAvatarImgLoadComplete_(success, sprite)
	-- body
	if success then
        --todo
        local oldAvatar = self.bottomNode_:getChildByTag(AVATAR_TAG)
        if oldAvatar then
            --todo
            oldAvatar:removeFromParent()
        end

        local avatarSizeBorderShown = 35

        local sprSize = sprite:getContentSize()
        if sprSize.width > sprSize.height then
            sprite:scale(avatarSizeBorderShown / sprSize.width)
        else
            sprite:scale(avatarSizeBorderShown / sprSize.height)
        end
        
        sprite:align(display.LEFT_CENTER, - display.width / 2 + 20, - 23)
            -- :pos(- display.width / 2 + 20, - 23)
            :addTo(self.bottomNode_, 0, AVATAR_TAG)
    end
end

function AttendDokbActPageView:onReturnClick_(evt)
	-- body
	-- self.controller_:showMainHallView()
    self:hidePanel()
    nk.userData.DOKB_TAB = nil
end

function AttendDokbActPageView:onHelpClick_(evt)
	-- body
	DokbHelpPopup.new():showPanel(handler(self, self.onHelpPopShowed))
end

function AttendDokbActPageView:onFeedbackClick_(evt)
	-- body
	HelpPopup.new(false, true, 1):show()
end

function AttendDokbActPageView:onExchangeStoreClick_(evt)
	-- body
	self.btnExStore_:setButtonEnabled(false)

    display.addSpriteFrames("scoreMarket_th.plist", "scoreMarket_th.png", function()
        self.scoreMarket_ = ScoreMarketView.new():show()
        self.btnExStore_:setButtonEnabled(true)
    end)
end

function AttendDokbActPageView:onSendBordBtnCallBack_(evt)
	-- body

    -- local msgInfo = {
    --     type = 1,
    --     name = "tsing",
    --     content = "擦擦擦擦啊擦擦擦啊擦擦！"
    -- }

    -- local msgJson = json.encode(msgInfo)
    -- self.controller_:onSuonaBroadRecv_({data = {msg_info = msgJson}})

    -- do return end
    SuonaUsePopup.new():show()
end

function AttendDokbActPageView:onStoreClick_(evt)
	-- body
    local isPay = nk.userData.best and nk.userData.best.paylog == 1 or false
    -- local isAlmChargeFavPay = nk.userData.bagPayList and nk.userData.bagPayList.almRechgFav == 1 or false

    local isThirdPayOpen = nk.OnOff:check("payGuide")
    local isFirstCharge = not isPay

    if isThirdPayOpen then
        --todo
        if isFirstCharge then
            --todo
            if nk.OnOff:check("firstchargeFavGray") then
                --todo
                FirChargePayGuidePopup.new(1):showPanel()
            else
                local params = {}

                params.isOpenThrPartyPay = true
                params.isFirstCharge = true
                params.sceneType = 1
                params.payListType = nil
                params.isSellCashCoin = true

                PayGuide.new(params):show()
            end
        else

            local rechargeFavAccess = nk.userData.bagPayList and nk.userData.bagPayList.access == 1 or false
            if nk.OnOff:check("rechargeFavGray") and rechargeFavAccess then
                --todo
                AgnChargePayGuidePopup.new():showPanel()
            else
                local params = {}

                params.isOpenThrPartyPay = true
                params.isFirstCharge = true
                params.sceneType = 1
                params.payListType = nil
                params.isSellCashCoin = true

                PayGuide.new(params):show()
            end
        end
    else
        local cashPaymentPageIdx = 2
        StorePopup.new(cashPaymentPageIdx):showPanel()
    end
end

-- Standby! --
function AttendDokbActPageView:onActTypeSelectChanged(evt)
	-- body

	self.dokbActTypeSelectedIdx_ = evt.selected
end

function AttendDokbActPageView:onLotryRecTermIdSelectChanged(evt)
	-- body
	if self.lotryRecTermIds_ and self.lotryRecTermIds_[evt.selected] then
		--todo
        self.defaultLotryRecSubItemIdx_ = evt.selected
		self.lotryRecTermIdSelected_ = self.lotryRecTermIds_[evt.selected]
	else
		self.lotryRecTermIdSelected_ = 0
	end
	
	-- local termId = self.lotryRecTermIds_[evt.selected]

	self:getLotryRecInTermId()
end

function AttendDokbActPageView:onMainTabChange(selectedTab)
	-- body

	self.dokbActPages_ = self.dokbActPages_ or {}

    for _, page in pairs(self.dokbActPages_) do
        if page then
            --todo
            page:hide()
        end
    end

    -- local page = self.roomChoosePages_[selectedTab]

    if not self.dokbActPages_[selectedTab] then
        --todo
        self.dokbActPages_[selectedTab] = self:renderDokbActPageByIdx(selectedTab)

        -- self.dokbActPages_[selectedTab] = page
        self.dokbActPages_[selectedTab]:addTo(self.dokbActPageNode_)
    end
    self.dokbActPages_[selectedTab]:show()

    self.selectedTabIdx_ = selectedTab
    nk.userData.DOKB_TAB = self.selectedTabIdx_

    self:getDokePageData()
end

function AttendDokbActPageView:onHelpPopShowed()
	-- body
	if self.checkHelpInsTipsRepeatAction_ then
		--todo
		self:stopAction(self.checkHelpInsTipsRepeatAction_)
	end

	if self and self.bgHelpTipInsNode_ then
		--todo
		self.bgHelpTipInsNode_:removeFromParent()
        self.bgHelpTipInsNode_ = nil
	end
end

function AttendDokbActPageView:getDokePageData()
	-- body
	local getDokbPageDataByIdx = {
		[1] = function()
			-- body
			self.getDokbActListDataReq_ = nk.http.getDokbActList(function(retData)
				-- body
				-- dump(retData, "getDokbActList.data :====================", 5)

				if retData and retData.data then
					--todo
					if self and self.actTermNum_ then
						--todo
						self.actTermNum_:setString(bm.LangUtil.getText("DOKB", "TERM_SERIAL_NUMBER", retData.daytime or 0))
					end

					if self and self.actListTermItems_ then
						--todo
						for i = 1, #self.actListTermItems_ do
							if retData.data[i] then
								--todo
								retData.data[i].termId_ = retData.daytime

								self.actListTermItems_[i]:refreshTermItemUiData(retData.data[i])
							end
						end
					end
				end
			end, function(errData)
				-- body
				self.getDokbActListDataReq_ = nil
				-- dump(errData, "getDokbActList.errData :==================")

				if self and self.onGetPageDataWrong then
					--todo
					self:onGetPageDataWrong()
				end
			end)
		end,

		[2] = function()
			-- body
			self.getDokbLotryRecTermIdReq_ = nk.http.getDokbLotryRecTermId(function(retData)
				-- body
				-- dump(retData, "getDokbLotryRecTermId.data :====================")
				if self.lotryRecTermIds_ then
					--todo
					self.lotryRecTermIds_ = nil
				end

				self.lotryRecTermIds_ = {}
				for i = 1, #retData do
					if retData[i] then
						--todo
						table.insert(self.lotryRecTermIds_, retData[i].time)
					end
				end

				if self and self.lotryTermsIdBtns then
					--todo
					for i = 1, #self.lotryTermsIdBtns do

						self.lotryTermsIdBtns[i]:show()

						if self.lotryRecTermIds_[i] then
							--todo
							self.lotryTermsIdBtns[i].label_:setString(bm.LangUtil.getText("DOKB", "TERM_SERIAL_NUMBER", self.lotryRecTermIds_[i]))
						else
							self.lotryTermsIdBtns[i]:hide()
						end
						
					end
				end

				if self and self.lotryTermIdBtnGroup_ then
					--todo
					if self.lotryTermIdBtnGroup_:getButtonAtIndex(self.defaultLotryRecSubItemIdx_):isButtonSelected() then
						--todo
						self:getLotryRecInTermId()
					else
						self.lotryTermIdBtnGroup_:getButtonAtIndex(self.defaultLotryRecSubItemIdx_):setButtonSelected(true)
					end
				end

				if self and self.lotryRecRefreshBtn_ then
					--todo
					self.lotryRecRefreshBtn_:setButtonEnabled(true)
				end
			end, function(errData)
				-- body
				self.getDokbLotryRecTermIdReq_ = nil

				-- dump(errData, "getDokbLotryRecTermId.errData :==================")

				if self and self.onGetPageDataWrong then
					--todo
					self:onGetPageDataWrong()
				end

				if self and self.lotryRecRefreshBtn_ then
					--todo
					self.lotryRecRefreshBtn_:setButtonEnabled(true)
				end
			end)
		end,

		[3] = function()
			-- body
			self.getDokbMyRecDataReq_ = nk.http.getDokbMyAtdRec(function(retData)
				-- body
				-- dump(retData, "getDokbMyAtdRec.data :====================")

				if #retData <= 0 then
					--todo
					self.myRecList_:setData(nil)
					self.noMyRecTip_:show()
				else
					self.noMyRecTip_:hide()
					self.myRecList_:setData(retData)
				end
				
			end, function(errData)
				-- body
				self.getDokbMyRecDataReq_ = nil
				-- dump(errData, "getDokbMyAtdRec.errData :=====================")

				if self and self.onGetPageDataWrong then
					--todo
					self:onGetPageDataWrong()
				end
			end)

		end
	}

	getDokbPageDataByIdx[self.selectedTabIdx_]()
end

function AttendDokbActPageView:getLotryRecInTermId()
	-- body

	-- 只要self.lotryRecTermIdSelected_ 不为空,最近6期就至少有一个有期号,该接口返回为空说明当期没有记录,
	-- 显示 NoLotryRecTips, 否则必为空，显示 NoLotryRecTips

	self.getLotryRecDataByTermIdReq_ = nk.http.getDokbLotryRec(self.lotryRecTermIdSelected_, function(retData)
		-- body
		-- dump(retData, "getDokbLotryRec.data :=====================", 6)

		if retData then
			--todo
			if #retData <= 0 then
				--todo
				self.lotryRecList_:setData(nil)
				self.noLotryRecTip_:show()
			else
				self.noLotryRecTip_:hide()
				self.lotryRecList_:setData(retData)
			end
		end

	end, function(errData)
		-- body
		self.getLotryRecDataByTermIdReq_ = nil
		-- dump(errData, "getDokbLotryRec.errData :==================")

		nk.ui.Dialog.new({messageText = bm.LangUtil.getText("COMMON", "REQUEST_DATA_FAIL"), secondBtnText = bm.LangUtil.getText("COMMON", "RETRY"), 
	        callback = function (type)
	            if type == nk.ui.Dialog.SECOND_BTN_CLICK then
	                self:getLotryRecInTermId()
	            end
	        end}):show()
	end)
end

function AttendDokbActPageView:onGetPageDataWrong()
	-- body
	nk.ui.Dialog.new({messageText = bm.LangUtil.getText("COMMON", "REQUEST_DATA_FAIL"), secondBtnText = bm.LangUtil.getText("COMMON", "RETRY"), 
        callback = function (type)
            if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                self:getDokePageData()
            end
        end}):show()
end

function AttendDokbActPageView:reloadActListData(evt)
	-- body
	self:getDokePageData()
end

function AttendDokbActPageView:addDataObservers()
	-- body
	self.avatarUrlObserverHandle_ = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "aUser.micon", function(micon)
        if not micon or string.len(micon) <= 5 then
            if nk.userData["aUser.msex"] == 2 or nk.userData["aUser.msex"] == 0 then
                self:onAvatarImgLoadComplete_(true, display.newSprite("#common_female_avatar.png"))
            else
                self:onAvatarImgLoadComplete_(true, display.newSprite("#common_male_avatar.png"))
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
            -- dump(imgurl,"fuckmicon")

            nk.ImageLoader:loadAndCacheImage(self.userAvatarLoaderId_, imgurl, 
                handler(self, self.onAvatarImgLoadComplete_), nk.ImageLoader.CACHE_TYPE_USER_HEAD_IMG)
        end
    end)

	self.userMoneyChangeObserver_ = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "aUser.money", function(money)
        -- body
        if not money then return end

        if self.chipsNum_ then
            --todo
            if money >= 1000000000 then
                --todo
                self.chipsNum_:setString(bm.formatBigNumber(money))
            else
                self.chipsNum_:setString(bm.formatNumberWithSplit(money))
            end
        end
    end)

    self.userCashChangeObserver_ = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "match.point", function(cashNum)
        -- body
        if not cashNum then
            --todo
            return
        end

        if self.cashNum_ then
            --todo
            if cashNum >= 1000000000 then
                --todo
                self.cashNum_:setString(bm.formatBigNumber(cashNum))
            else
                self.cashNum_:setString(bm.formatNumberWithSplit(cashNum))
            end
        end
    end)
end

function AttendDokbActPageView:playSuonaMsgScrolling()
    -- body
    if not self.suonaMsgPlaying_ then
        --todo
        self:playSuonaMsgNext()
    end
end

function AttendDokbActPageView:playSuonaMsgNext()
    -- body
    -- self.bordCastMsg_
    -- self.bordCastMsgStartX_
    -- self.bordCastMsgDesX_

    local currentSuonaMsgData = nil

    -- local suonaMsgShownColor = {
    --     tip = display.COLOR_WHITE,
    --     msg = cc.c3b(255, 0, 255)
    -- }
    if self.controller_.suonaMsgQueue_[1] then
        --todo
        currentSuonaMsgData = table.remove(self.controller_.suonaMsgQueue_, 1)
    else
        -- 调整label 的显示,"点击这里使用小喇叭 >>"
        self.bordCastMsg_:setString(bm.LangUtil.getText("HALL", "CHOOSE_ROOM_SUONA_USE_TIP"))
        -- self.suonaChatInfo_:setTextColor(suonaMsgShownColor.tip)
        self.bordCastMsg_:setPositionX(self.bordCastMsgStartX_ - self.bordCastMsg_:getContentSize().width)

        -- self.topSuonaTipPanel_:setOpacity(0)
        -- -- self.suonaBtnTop_:setOpacity(255)
        -- self.suonaChatInfo_:setOpacity(0)
        -- -- self.suonaChatInfo_:hide()

        self.suonaMsgPlaying_ = false
        return
    end

    -- if self.suonaIconClickTipAction_ then
    --     --todo
    --     self:stopAction(self.suonaIconClickTipAction_)
    --     self.suonaIconClickTipAction_ = nil

    --     -- self.suonaChatInfo_:setOpacity(255)
    --     bm.DataProxy:setData(nk.dataKeys.SUONA_USETIP_ONOFF, false)
    -- end

    -- dump(currentSuonaMsgData, "currentSuonaMsgData: =================")

    self.suonaMsgPlaying_ = true
    -- self.topSuonaTipPanel_:setOpacity(255)

    -- -- self.suonaChatInfoclipNode_:setOpacity(255)
    self.bordCastMsg_:setString(currentSuonaMsgData)
    -- self.suonaChatInfo_:setTextColor(suonaMsgShownColor.msg)

    self.bordCastMsg_:pos(self.bordCastMsgStartX_, 0)

    local chatMsgPlayDelayTime = 0.2
    local chatMsgShownTimeIntval = 3
    -- -- local chatMsgLabelRollVelocity = 85
    local labelRollTime = 7
    -- -- self.suonaChatMsgStrPosXSrc - self.suonaChatMsgStrPosXDes / chatMsgLabelRollVelocity
    -- -- self.suonaChatInfo_:getContentSize().width / chatMsgLabelRollVelocity > 4 and 4 or self.suonaChatInfo_:getContentSize().width / chatMsgLabelRollVelocity
    -- -- self.suonaChatInfo_:show()
    -- self.suonaChatInfo_:setOpacity(255) -- cc.c3b(255, 0, 255)

    self.suonaMsgScrollAnim_ = transition.execute(self.bordCastMsg_, cc.MoveTo:create(labelRollTime,
        cc.p(self.bordCastMsgDesX_, 0)), {delay = chatMsgPlayDelayTime / 2})

    self.suonaDelayCallHandler_ = nk.schedulerPool:delayCall(handler(self, self.playSuonaMsgNext), labelRollTime + chatMsgPlayDelayTime + chatMsgShownTimeIntval)
end

function AttendDokbActPageView:playShowAnim()
	-- body
	local animTime = self.controller_:getAnimTime()

	transition.moveTo(self.topBtnNode_, {time = animTime, y = 0, delay = animTime})

    transition.moveTo(self.bottomNode_, {time = animTime, y = - display.height / 2 + 45, delay = animTime})

    if self.dokbActPages_[1] then
    	--todo
    	local dokbActTermsItemsPosYAdj = 30
	    for i, termItem in ipairs(self.actListTermItems_) do
	    	transition.moveTo(termItem, {time = animTime, y = - dokbActTermsItemsPosYAdj, delay = animTime + 0.05 * i,     
                easing = "BACKOUT"})
	    end
    end
    
    -- transition.fadeIn(self.dokbActPageNode_, {time = animTime, opacity = 255, delay = animTime * 2})
end

function AttendDokbActPageView:showPanel(showedCallBack, hideCallBack)
    -- body
    self.onShowedCallBack_ = showedCallBack
    -- self.hideCallBack_ = hideCallBack

    nk.PopupManager:addPopup(self, false, nil, nil, false)
    return self
end

function AttendDokbActPageView:onShowed()
    -- body
    if self and self.onShowedCallBack_ then
        --todo
        self.onShowedCallBack_()
    end
end

function AttendDokbActPageView:hidePanel()
    -- body
    self.controller_:showMainHallView()
    nk.PopupManager:removePopup(self)
    -- if self and self.hideCallBack_ then
    --     --todo
    --     local MainHallViewTablePosTop = 1
    --     self.hideCallBack_(MainHallViewTablePosTop)
    -- end
end

function AttendDokbActPageView:onEnter()
	-- body
	self:addDataObservers()

	bm.EventCenter:addEventListener(nk.eventNames.DOKB_LOTRY_LOAD_NEXTROUND_RERESHDATA, handler(self, self.reloadActListData))
end

function AttendDokbActPageView:onExit()
	-- body
    display.removeSpriteFramesWithFile("dokb_act.plist", "dokb_act.png")

    nk.schedulerPool:delayCall(function()
        cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    end, 0.1)

	nk.ImageLoader:cancelJobByLoaderId(self.userAvatarLoaderId_)

	if self.getDokbActListDataReq_ then
		--todo
		nk.http.cancel(self.getDokbActListDataReq_)
	end

	if self.getDokbLotryRecTermIdReq_ then
		--todo
		nk.http.cancel(self.getDokbLotryRecTermIdReq_)
	end

	if self.getLotryRecDataByTermIdReq_ then
		--todo
		nk.http.cancel(self.getLotryRecDataByTermIdReq_)
	end

	if self.getDokbMyRecDataReq_ then
		--todo
		nk.http.cancel(self.getDokbMyRecDataReq_)
	end

    bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "aUser.micon", self.avatarUrlObserverHandle_)
    bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "aUser.money", self.userMoneyChangeObserver_)
    bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "match.point", self.userCashChangeObserver_)

    bm.EventCenter:removeEventListenersByEvent(nk.eventNames.DOKB_LOTRY_LOAD_NEXTROUND_RERESHDATA)
end

function AttendDokbActPageView:onCleanup()
	-- body
	if self.suonaMsgScrollAnim_ then
        --todo
        self:stopAction(self.suonaMsgScrollAnim_)
    end

    if self.suonaDelayCallHandler_ then
        --todo
        nk.schedulerPool:clear(self.suonaDelayCallHandler_)
    end

    if self.checkHelpInsTipsRepeatAction_ then
    	--todo
    	self:stopAction(self.checkHelpInsTipsRepeatAction_)
    end
end

return AttendDokbActPageView