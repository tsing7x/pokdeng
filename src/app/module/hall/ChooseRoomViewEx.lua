--
-- Author: TsingZhang@boyaa.com
-- Date: 2016-05-10 11:48:14
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- Description: ChooseRoomViewEx.lua By TsingZhang.
--

local StorePopup = import("app.module.newstore.StorePopup")
local ScoreMarketView = import("app.module.scoreMarket.ScoreMarketView")
local HelpPopup = import("app.module.settingAndhelp.SettingAndHelpPopup")
local HallSearchRoomPanel = import("app.module.hall.HallSearchRoomPanel")
local PayGuide = import("app.module.room.purchGuide.PayGuide")
local FirChargePayGuidePopup = import("app.module.newstore.firChrgGuide.FirChrgPayGuidePopup")
local AgnChargePayGuidePopup = import("app.module.newstore.agnChrgGuide.AgnChrgPayGuidePopup")
local SuonaUsePopup = import("app.module.suona.SuonaUsePopup")

local ChoosePersonalRoomView = import(".ChoosePersonalRoomView")

local ChooseRoomViewEx = class("ChooseRoomViewEx", function ()
    return display.newNode()
end)

local ChooseRoomChip = import(".ChooseRoomChip")
local ChooseCashRoomChip = import(".ChooseCashRoomChip")
local ProRoomListItem = import(".ChooseProRoomListItem")
-- local ChooseGrabRoomView = import(".ChooseGrabRoomView")

ChooseRoomViewEx.PLAYER_LIMIT_SELECTED = 1 -- 1：9人场；2：5人场
ChooseRoomViewEx.ROOM_LEVEL_SELECTED   = 1 -- 1：初级场；2：中级场；3：高级场

local ROOM_TYPE_NOR = 1
local ROOM_TYPE_PRO = 2
local TOP_BUTTOM_WIDTH   = 78
local TOP_BUTTOM_HEIGHT  = 64
local TOP_BUTTOM_PADDING = 8
-- local TOP_TAB_BAR_WIDTH  = 612
local TOP_TAB_BAR_HEIGHT = 66
local CHIP_HORIZONTAL_DISTANCE = 192 * nk.widthScale  -- 240 * nk.widthScale
local CHIP_VERTICAL_DISTANCE   = 188 * nk.heightScale  -- 216 * nk.heightScale

local AVATAR_TAG = 100

function ChooseRoomViewEx:ctor(controller, viewType)
    self.controller_ = controller
    self.controller_:setDisplayView(self)

    if viewType == controller.CHOOSE_NOR_VIEW then
        self.roomType_ = ROOM_TYPE_NOR
        self.roomTypeIcon_ = display.newSprite("#choose_room_nor_icon.png")
    else
        self.roomType_ = ROOM_TYPE_PRO
        self.roomTypeIcon_ = display.newSprite("#choose_room_pro_icon.png")
    end

    self:setNodeEventEnabled(true)

    self.isShowAnimPlayed_ = false
    self.perRoomChosPageAnimPlayed_ = false
    -- 桌子
    self.pokerTable_ = display.newNode():pos(0, - (display.cy + 146)):addTo(self):scale(self.controller_:getBgScale())
    local tableLeft = display.newSprite("#main_hall_table.png"):addTo(self.pokerTable_)
    tableLeft:setAnchorPoint(cc.p(1, 0.5))
    tableLeft:pos(2, 0)
    local tableRight = display.newSprite("#main_hall_table.png"):addTo(self.pokerTable_)
    tableRight:setScaleX(- 1)
    tableRight:setAnchorPoint(cc.p(1, 0.5))
    tableRight:pos(-2, 0)

    self.roomTypeIcon_:align(display.LEFT_CENTER, -(display.cx + self.roomTypeIcon_:getContentSize().width), - CHIP_VERTICAL_DISTANCE * 0.5 + 40 * nk.heightScale)
        :addTo(self)

    --[[ 顶部操作按钮 ]]--
    self.topBtnNode_ = display.newNode()
        :pos(0, TOP_BUTTOM_HEIGHT + TOP_TAB_BAR_HEIGHT + TOP_BUTTOM_PADDING)
        :addTo(self)

    -- 返回
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

    -- 帮助
    self.btnHelp_ = cc.ui.UIPushButton.new({normal = "#check_match_info_btn_up.png", pressed = "#check_match_info_btn_down.png"})
        :pos(-display.cx + TOP_BUTTOM_WIDTH * 0.5 + TOP_BUTTOM_PADDING, display.cy - TOP_BUTTOM_HEIGHT * 0.5 - TOP_BUTTOM_PADDING - 90)
        :addTo(self.topBtnNode_)
        :onButtonClicked(buttontHandler(self, self.onHelpClick_))

    -- 反馈
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
   
    --积分商城
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

    --默认场次划分 // 稍后处理
    if not nk.userData.DEFAULT_TAB then
        --todo
        local userMoney = nk.userData["aUser.money"]
        local userCashMoney = nk.userData["match.point"]

        if userCashMoney >= 10 then
            --todo
            nk.userData.DEFAULT_TAB = 2
        elseif userMoney >= 50000000000 then
            --todo
            nk.userData.DEFAULT_TAB = 1
        else
            nk.userData.DEFAULT_TAB = 1
        end
    end
    
    -- 默认页,由上面条件控制
    if nk.userData.DEFAULT_TAB ~= 1 then
        --todo
        self.defualtTabIdx_ = nk.userData.DEFAULT_TAB
    end
    -- 选场页面 
    self.chooseRoomPageNode_ = display.newNode()
        -- :pos(0, 0)
        :addTo(self)

    self.mainTabBar_ = nk.ui.CommonPopupTabBar.new(
        {
            popupWidth = display.width - 230, 
            iconOffsetX = 10, 
            iconTexture = {
                {"#choose_roomTypeNor_sel.png", "#choose_roomTypeNor_unSel.png"}, 
                {"#choose_roomTypeCash_sel.png", "#choose_roomTypeCash_unSel.png"},
                {"#choose_roomTypeGrab_sel.png", "#choose_roomTypeGrab_unSel.png"}
            }, 
            btnText = bm.LangUtil.getText("HALL", "ROOM_LEVEL_TEXT")
        })
        :setTabBarExtraParam({noIconCircle = true, tabFrontSize = 24, buttonLabelOffset = {x = - 10, y = 0}})
        :pos(- 20, display.cy - TOP_TAB_BAR_HEIGHT * 0.5 - 2)
        :addTo(self.topBtnNode_)

    -- tags --
    local tagsPosXShift = 25

    -- display.newSprite("#choose_roomTag_hot.png")
    --     :pos((display.width - 230) * 0.85 / 6 - tagsPosXShift, display.cy - 20)
    --     :addTo(self.topBtnNode_)

    display.newSprite("#choose_roomTag_new.png")
        :pos((display.width - 230) * 0.85 / 6 * 3 - tagsPosXShift, display.cy - 20)
        :addTo(self.topBtnNode_)

    --系统提示
    self.bordCastMsgNode_ = display.newNode()
        :addTo(self.topBtnNode_)

    local systemTipWidth = (display.width - 230) * 0.85
    local systemTipHeight = 51

    local bordCastMsgShownPanel = display.newScale9Sprite("#hall_system_info_bg.png", 0, 0, cc.size(systemTipWidth, systemTipHeight))
        :addTo(self.bordCastMsgNode_)
        :pos(- 20, display.cy  - TOP_TAB_BAR_HEIGHT * 0.5 - 95)

    local suonaIcon = display.newSprite("#hall_system_info_icon.png")
        :addTo(self.bordCastMsgNode_)
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
        :addTo(self.bordCastMsgNode_)

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

    display.newScale9Sprite("#hall_choose_yellow_btn.png",0,0,cc.size(yellowBtnWidth, yellowBtnHeight))
        :pos(display.width / 2 - yellowBtnWidth + 45, pos_y)
        :addTo(self.bottomNode_)

    self.storeIcon_ = nil
    if self.defualtTabIdx_ == 3 then
        --todo
        self.storeIcon_ = display.newSprite("#hall_small_cash_icon.png")
    else
        self.storeIcon_ = display.newSprite("#hall_small_chip_icon.png")
    end
    
    self.storeIcon_:addTo(self.bottomNode_)
        :pos(display.width / 2 - yellowBtnWidth + 45 - 40, pos_y)

    display.newTTFLabel({text = bm.LangUtil.getText("COMMON", "BUY"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 20, align = ui.TEXT_ALIGN_CENTER})
        :addTo(self.bottomNode_)
        :pos(display.width / 2 - yellowBtnWidth + 55, pos_y)

    cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#rounded_rect_10.png"}, {scale9 = true})
        :setButtonSize(yellowBtnWidth - 5, yellowBtnHeight)
        :onButtonClicked(buttontHandler(self, self.onStoreClick_))
        :pos(display.width / 2 - yellowBtnWidth + 45, pos_y)
        :addTo(self.bottomNode_)

    self.mainTabBar_:onTabChange(handler(self, self.onMainTabChange))

    if self.defualtTabIdx_ and self.defualtTabIdx_ ~= 1 then
        --todo
        self.mainTabBar_:gotoTab(self.defualtTabIdx_)
    end
end

function ChooseRoomViewEx:renderChooseRoomPage(pageIdx)
    -- body
    local drawRoomListPageByIndex = {
        [1] = function()  -- 普通场选场list
            -- body
            local normalRoomChoosePage = display.newNode()

            -- local testLabel = display.newTTFLabel({text = "This is Page NorRoomList!", size = 24, align = ui.TEXT_ALIGN_CENTER})
            --     :addTo(normalRoomChoosePage)

            self.userOnline_ = display.newTTFLabel({text = bm.LangUtil.getText("HALL", "USER_ONLINE", 0), color = cc.c3b(0xA7, 0xF2, 0xB0), size = 24, align = ui.TEXT_ALIGN_CENTER})
                :pos(0, display.cy - 182)
                :opacity(0)
                :addTo(normalRoomChoosePage)

            self.roomChips_ = {}
            local chipTextColors = {
                cc.c3b(0x37, 0x88, 0x1c), 
                cc.c3b(0xCA, 0x7C, 0x2C), 
                cc.c3b(0x2F, 0x88, 0xE1), 
                cc.c3b(0xBB, 0x06, 0x06), 
                cc.c3b(0xED, 0x61, 0x06), 
                cc.c3b(0xAD, 0x22, 0x9C),
                cc.c3b(0x39, 0x4B, 0xB0),
                cc.c3b(0x60, 0x60, 0x60)
            }

             -- 每一次切换tab都重新设置底注和最小买入信息？！遵循之前的方案。

            local tempTb = nk.getRoomDatasByLimitAndTab(ChooseRoomViewEx.PLAYER_LIMIT_SELECTED,ChooseRoomViewEx.ROOM_LEVEL_SELECTED)
            local chipClass 
            local chipSkin
            for i = 1, 8 do
                if tempTb[i] and tempTb[i].rType == 2 then
                    chipClass = ChooseCashRoomChip
                    chipSkin = "#choose_roomCashChip.png"
                elseif (not tempTb[i] or tempTb[i].rType == 1) then

                     chipClass = ChooseRoomChip
                     chipSkin = "#choose_roomNorChip_"..i..".png"
                end

            self.roomChips_[i] = chipClass.new(chipSkin, chipTextColors[i])
                    :pos(((i - 1) % 4 - 1 - 1 / 2) * CHIP_HORIZONTAL_DISTANCE, (math.floor((8 - i) / 4) - 1) * CHIP_VERTICAL_DISTANCE - display.cy - 60)
                    :onChipClick(handler(self, self.onChipClick_))
                    :addTo(normalRoomChoosePage,1)
            end

            return normalRoomChoosePage
        end,

        [2] = function()  -- 现金币场选场list
            -- body
            local cashRoomChoosePage = display.newNode()

            -- local testLabel = display.newTTFLabel({text = "This is Page CashRoomList!", size = 24, align = ui.TEXT_ALIGN_CENTER})
            --     :addTo(cashRoomChoosePage)
            self.cashGroupNameNode_ = display.newNode()
                :pos(0, display.cy)
                :addTo(cashRoomChoosePage)

            local groupNameStr = bm.LangUtil.getText("HALL", "CHOOSE_NORROOM_GROUP_TEXT")
            -- {
            --     "庄家",
            --     "上庄资产",
            --     "底注",
            --     "MIN上庄值",
            --     "入场门槛",
            --     "在线人数"
            -- }

            local pageContPaddingEachSide = 20
            local roomListButtonSizeWidth = 164

            local groupIndexAreaWidth = display.width - pageContPaddingEachSide * 2 - roomListButtonSizeWidth

            local infoGroupBlockPaddingTop = 182
            local groupLabelParam = {
                frontSize = 25,
                color = cc.c3b(174, 226, 113)
            }

            for i = 1, #groupNameStr do

                if i ~= #groupNameStr then
                    --todo
                    display.newSprite("#chipChos_divLine_vertical.png")
                        :pos(- display.cx + pageContPaddingEachSide + groupIndexAreaWidth / 6 * i, display.cy - infoGroupBlockPaddingTop)
                        :addTo(self.cashGroupNameNode_)
                end
                
                display.newTTFLabel({text = groupNameStr[i], size = groupLabelParam.frontSize, color = groupLabelParam.color, align = ui.TEXT_ALIGN_CENTER})
                    :pos(- display.cx + pageContPaddingEachSide + groupIndexAreaWidth / 12 * (2 * i - 1), display.cy - infoGroupBlockPaddingTop)
                    :addTo(self.cashGroupNameNode_)
            end

            local roomListHeight = 372
            local roomListPosYAdjust = 70

            self.cashRoomList_ = bm.ui.ListView.new({viewRect = cc.rect(- (display.width - pageContPaddingEachSide * 2) * 0.5,
                - roomListHeight / 2, (display.width - pageContPaddingEachSide * 2), roomListHeight), upRefresh = handler(self, self.onCashRoomListUpRefresh_)},
                    ProRoomListItem)
                :pos(0, - roomListPosYAdjust)
                :addTo(cashRoomChoosePage)

            self.cashRoomList_:addEventListener("ITEM_EVENT", handler(self, self.onProRoomLogin_))
            self.cashRoomList_.itemClass_:setItemRoomType(0)

            local notOpenTipsParam = {
                frontSize = 36,
                color = cc.c3b(0xeb, 0x4d, 0x4d)
            }

            self.cashNotOpenTips_ = display.newTTFLabel({text = bm.LangUtil.getText("HALL", "NOTOPEN"), size = notOpenTipsParam.frontSize, color = notOpenTipsParam.color, align = ui.TEXT_ALIGN_CENTER})
                :pos(0, - roomListPosYAdjust)
                :addTo(cashRoomChoosePage)
                :hide()
            -- self.cashRoomList_:setData({1, 2, 3, 4, 5, 6})

            -- cashRoomChoosePage:setOpacity(0)
            return cashRoomChoosePage
        end,

        [3] = function()  -- 私人房选场list
            -- body
            local perRoomChoosePage = display.newNode()

            self.perRoomPage_ = ChoosePersonalRoomView.new(self.controller_, self.controller_.CHOOSE_PERSONAL_NOR_VIEW)
                :addTo(perRoomChoosePage)

            return perRoomChoosePage
        end
    }

    return drawRoomListPageByIndex[pageIdx]()
end

function ChooseRoomViewEx:onAvatarImgLoadComplete_(success, sprite)
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

function ChooseRoomViewEx:playShowAnim()
    local animTime = self.controller_:getAnimTime()
    -- 桌子
    transition.moveTo(self.pokerTable_, {time = animTime, y = 0})

    -- icon
    transition.moveTo(self.roomTypeIcon_, {time = animTime, x = - display.cx, delay = animTime})

    -- 分割线
    -- transition.fadeIn(self.splitLine_, {time = animTime, opacity = 255, delay = animTime})

    -- 顶部操作区
    transition.moveTo(self.topBtnNode_, {time = animTime, y = 0, delay = animTime})

    -- 底部区域
    transition.moveTo(self.bottomNode_, {time = animTime, y = - display.height / 2 + 45, delay = animTime})
   
    -- 筹码
    if self.roomChoosePages_[1] then
        --todo
        for i, chip in ipairs(self.roomChips_) do
            local onComplete 
            if i == #self.roomChips_ then
                onComplete = handler(self,self.onPlayChipAnimComplete)
            end
            transition.moveTo(chip, {
                time = animTime, 
                y = (math.floor((8 - i) / 4) - 1) * CHIP_VERTICAL_DISTANCE + 40 * nk.heightScale, 
                delay = animTime + 0.05 * ((i <= 4 and i or (i - 4)) - 1),     
                easing = "BACKOUT", onComplete = onComplete})
        end

        -- 在线人数
        transition.fadeIn(self.userOnline_, {time = animTime, opacity = 255, delay = animTime})
    end

    if self.roomChoosePages_[2] then
        --todo
        local grabGroupNodeAnimDelay = - 0.02

        transition.moveTo(self.cashGroupNameNode_, {time = animTime, y = 0, delay = animTime + grabGroupNodeAnimDelay})
    end

    if self.roomChoosePages_[3] and not self.perRoomChosPageAnimPlayed_ then
        --todo
        -- local cashGroupNodeAnimDelay = - 0.02
        self.perRoomPage_:playShowAnim()
        -- transition.moveTo(self.grabGroupNameNode_, {time = animTime, y = 0, delay = animTime + cashGroupNodeAnimDelay})
        self.perRoomChosPageAnimPlayed_ = true
    end

    self.isShowAnimPlayed_ = true
    -- 右边tab bar
    -- transition.moveTo(self.rightTabBar_, {time = animTime, x = display.cx - 72, delay = animTime})
end

function ChooseRoomViewEx:onPlayChipAnimComplete()
    self:checkGroupGuide()

    self:checkHallCashGuide()
end

function ChooseRoomViewEx:playHideAnim()
    self:removeFromParent()
end

function ChooseRoomViewEx:playSuonaMsgScrolling()
    -- body
    if not self.suonaMsgPlaying_ then
        --todo
        self:playSuonaMsgNext()
    end
end

function ChooseRoomViewEx:playSuonaMsgNext()
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

function ChooseRoomViewEx:onReturnClick_()
    self.controller_:showMainHallView()
    nk.userData.DEFAULT_TAB = nil
end

function ChooseRoomViewEx:onHelpClick_()
    -- self.btnHelp_:setButtonEnabled(false)

    HelpPopup.new(false, true, 2):show()
    -- self.btnHelp_:setButtonEnabled(true)
end

function ChooseRoomViewEx:onFeedbackClick_()
    -- self.btnFeedBack_:setButtonEnabled(false)

    HelpPopup.new(false, true, 1):show()
    -- self.btnFeedBack_:setButtonEnabled(true)
end

function ChooseRoomViewEx:onExchangeStoreClick_(evt)
    -- body
    self.btnExStore_:setButtonEnabled(false)

    display.addSpriteFrames("scoreMarket_th.plist", "scoreMarket_th.png", function()
        self.scoreMarket_ = ScoreMarketView.new():show()
        self.btnExStore_:setButtonEnabled(true)
    end)
end

function ChooseRoomViewEx:onMainTabChange(selectedTab)
    -- body
    -- bm.DataProxy:setData(nk.dataKeys.ROOM_LIST_SELECT_TYPE, selectedTab)

    if self.selectedTabIdx_ then
        --todo
        if selectedTab == 2 then
            --todo
            self.storeIcon_:setSpriteFrame(display.newSpriteFrame("hall_small_cash_icon.png"))
        else
            self.storeIcon_:setSpriteFrame(display.newSpriteFrame("hall_small_chip_icon.png"))
        end
    end

    self.roomChoosePages_ = self.roomChoosePages_ or {}

    for _, page in pairs(self.roomChoosePages_) do
        if page then
            --todo
            page:hide()
        end
    end

    -- local page = self.roomChoosePages_[selectedTab]

    if not self.roomChoosePages_[selectedTab] then
        --todo
        self.roomChoosePages_[selectedTab] = self:renderChooseRoomPage(selectedTab)

        -- self.roomChoosePages_[selectedTab] = page
        self.roomChoosePages_[selectedTab]:addTo(self.chooseRoomPageNode_)

        if selectedTab == 2 then
            --todo
            -- local animTime = self.controller_:getAnimTime()

            -- transition.moveTo(self.groupNameNode_, {time = animTime, y =0, delay = animTime + 0.8})
            -- if self.isShowAnimPlayed_ then
            --     --todo
            --     self.grabGroupNameNode_:pos(0, 0)
            -- end

            if self.isShowAnimPlayed_ then
                --todo
                self.cashGroupNameNode_:pos(0, 0)
            end
           
        elseif selectedTab == 3 then
            --todo
            if not self.perRoomChosPageAnimPlayed_ then
                --todo
                self.perRoomPage_:playShowAnim()
                self.perRoomChosPageAnimPlayed_ = true
            end
        end
    end

    if selectedTab == 3 then
        --todo
        self.btnHelp_:hide()
        self.bordCastMsgNode_:hide()
    else
        self.btnHelp_:show()
        self.bordCastMsgNode_:show()
    end

    self.roomChoosePages_[selectedTab]:show()

    self.selectedTabIdx_ = selectedTab
    nk.userData.DEFAULT_TAB = self.selectedTabIdx_
    -- bm.DataProxy:setData(nk.dataKeys.ROOMNOR_LIST_SELECT_TYPE, self.selectedTabIdx_)

    self:getRoomListData()
end

-- function ChooseRoomViewEx:onSearchClick_()
--     HallSearchRoomPanel.new(self.controller_,handler(self,self.onSearchPanelCallback)):showPanel()
-- end

-- function ChooseRoomViewEx:onSearchPanelCallback(roomId)
--     -- dump(roomId,"ChooseRoomViewEx:onSearchPanelCallback")
--     local roomData = {}
--     roomData.roomid = roomId--26280117
--     bm.EventCenter:dispatchEvent({name = nk.eventNames.ENTER_ROOM_WITH_DATA, data = roomData})
-- end

function ChooseRoomViewEx:onStoreClick_()

    local isShowPay = nk.OnOff:check("payGuide")
    local isPay = nk.userData.best and nk.userData.best.paylog == 1 or false
    -- local isAlmChargeFavPay = nk.userData.bagPayList and nk.userData.bagPayList.almRechgFav == 1 or false

    local shownSence = 1
    local isThirdPayOpen = isShowPay
    local isFirstCharge = not isPay
    local payBillType = nil

    if isThirdPayOpen then
        --todo
        if isFirstCharge then
            --todo
            if nk.OnOff:check("firstchargeFavGray") then
                --todo
                FirChargePayGuidePopup.new(1):showPanel()
            else
                if self.selectedTabIdx_ ~= 3 then
                    --todo
                    local params = {}

                    params.isOpenThrPartyPay = isThirdPayOpen
                    params.isFirstCharge = isFirstCharge
                    params.sceneType = shownSence
                    params.payListType = payBillType

                    PayGuide.new(params):show()
                else
                    local cashPaymentPageIdx = 2
                    StorePopup.new(cashPaymentPageIdx):showPanel()
                end
            end
        else
            local rechargeFavAccess = nk.userData.bagPayList and nk.userData.bagPayList.access == 1 or false
            if nk.OnOff:check("rechargeFavGray") and rechargeFavAccess then
                --todo
                AgnChargePayGuidePopup.new():showPanel()
            else
                if self.selectedTabIdx_ ~= 3 then
                    --todo
                    StorePopup.new():showPanel()
                else
                    local cashPaymentPageIdx = 2
                    StorePopup.new(cashPaymentPageIdx):showPanel()
                end
            end
        end
    else
        if self.selectedTabIdx_ ~= 2 then
            --todo
            StorePopup.new():showPanel()
        else
            local cashPaymentPageIdx = 2
            StorePopup.new(cashPaymentPageIdx):showPanel()
        end
    end
end

function ChooseRoomViewEx:onSendBordBtnCallBack_(evt)
    -- body
    SuonaUsePopup.new():show()
end

function ChooseRoomViewEx:onGrabQuickPlayCallBack_(evt)
    -- body
    local roomLevel = nk.getRoomLevelByMoney(nk.userData["aUser.money"])

    bm.EventCenter:dispatchEvent({name = nk.eventNames.ENTER_GRAB_DEALER_ROOM, data = {gameLevel = roomLevel}})
end

function ChooseRoomViewEx:onGrabRoomListUpRefresh_()
    -- body
    if nk.OnOff:check("grabDealerOpen") then
        --todo
        self:reqGrabRoomListDataByPage()
    else
        dump("grabRoom OnOff Close!")
    end
end

function ChooseRoomViewEx:onCashRoomListUpRefresh_()
    -- body
    if nk.OnOff:check("cashRoom") then
        --todo
        self:reqCashRoomListDataByPage()
    else
        dump("cashRoom OnOff Close!")
    end
end

-- 点击筹码play now指定条件场次
function ChooseRoomViewEx:onChipClick_(preCall)
    local playerCap = 9

    if ChooseRoomViewEx.PLAYER_LIMIT_SELECTED == 2 then
        playerCap = 5
    end

    local rType = checkint(preCall[20])
    if 2 == rType then
        local sendData = {gameLevel = checkint(preCall[1]),tableId = 0}
        bm.EventCenter:dispatchEvent({name = nk.eventNames.ENTER_GRAB_DEALER_ROOM, data = sendData})

    else
        self.controller_:getEnterRoomData({tt = self.roomType_, sb = preCall, pc = playerCap})
    end
end

-- 统一上庄和现金币场进入为一个方法！
function ChooseRoomViewEx:onProRoomLogin_(evt)
    -- body
    bm.EventCenter:dispatchEvent({name = nk.eventNames.ENTER_GRAB_DEALER_ROOM, data = evt.data})
end

function ChooseRoomViewEx:getRoomListData()
    -- body
    local reqRoomListDataByRoomTabIdx = {
        [1] = function()
            -- body
            self.controller_:getPlayerCountData(self.roomType_)

            -- 每一次切换tab都重新设置底注和最小买入信息？！遵循之前的方案。
            local tableConf = bm.DataProxy:getData(nk.dataKeys.TABLE_CONF)
            local tabConfLimt = tableConf[ChooseRoomViewEx.PLAYER_LIMIT_SELECTED]

            -- dump(tableConf, "tableConf :====================", 8)

            -- 100  500  1000  初级
            -- 10000    50000  中级
            -- 100000 200000  1000000高级
            if not tabConfLimt then
                --todo
                return
            end

            local preCalls = {}

            for i, v in ipairs(tabConfLimt) do
                for j, roomConf in ipairs(v) do
                    table.insert(preCalls, roomConf)
                end
            end

            -- dump(preCalls, "preCalls :=====================")
            for i, chip in ipairs(self.roomChips_) do
                if preCalls[i] then
                    chip:show()
                    chip:setPreCall(preCalls[i])
                else
                    chip:hide()
                end
            end
        end,

        [2] = function()
            -- body
            if not self.cashRoomDataList_ then
                --todo
                self.cashCurPage = 0
                self.cashTotalPage = 1

                self:reqCashRoomListData()
            end

        end,

        [3] = function()
            -- body
            -- if not self.grabRoomDataList_ then
            --     --todo
            --     self.grabCurPage = 0
            --     self.grabTotalPage = 1

            --     self:reqGrabRoomListData()
            -- end

            -- if not self.perRoomDataList_ then
            --     --todo

            --     self:reqPerRoomListData()
            -- end
            dump("Data Not Load Here!")
        end
    }

    reqRoomListDataByRoomTabIdx[self.selectedTabIdx_]()
end

-- data :onGetPlayerCountData.data, field :tabLevel
function ChooseRoomViewEx:onGetPlayerCountData(data, field)

    -- dump(data, "onGetPlayerCountData.data :===================")
    -- local levelSelected = ChooseRoomViewEx.ROOM_LEVEL_SELECTED
    -- if field ~= levelSelected then
    --     return
    -- end

    self.ninePlayerCounts_ = data[1]  -- 9人场
    self.fivePlayerCounts_ = data[2]  -- 5人场

    local playerCounts = nil
    local totalPlayer = 0

    if ChooseRoomViewEx.PLAYER_LIMIT_SELECTED == 1 then
        playerCounts = self.ninePlayerCounts_
    elseif ChooseRoomViewEx.PLAYER_LIMIT_SELECTED == 2 then
        playerCounts = self.fivePlayerCounts_
    end

    -- dump(playerCounts, "playerCounts :====================")

    local playerOlineDataList = {}
    for i, v in pairs(playerCounts) do
        -- dump(v, "v :==================")
        for j, roomOnlineData in pairs(v) do
            -- dump(roomOnlineData, "roomOnlineData :====================")
            -- table.insert(playerOlineDataList, roomOnlieData)
            playerOlineDataList[j] = roomOnlineData
        end
    end

    -- dump(playerOlineDataList, "playerOlineDataList :=====================")

    -- 设置对应筹码的在玩人数
    for i, chip in ipairs(self.roomChips_) do        
        local chipVal = chip:getValue()        
        if playerOlineDataList[chipVal] then
            chip:setPlayerCount(playerOlineDataList[chipVal])
            totalPlayer = totalPlayer + playerOlineDataList[chipVal]
        else
            chip:setPlayerCount(0)
        end
    end

    -- 设置总在玩人数
    self.userOnline_:setString(bm.LangUtil.getText("HALL", "USER_ONLINE", totalPlayer))
end

function ChooseRoomViewEx:reqGrabRoomListData()
    -- body
    if nk.OnOff:check("grabDealerOpen") then
        --todo
        self:reqGrabRoomListDataByPage()
    else
        if self.grabNotOpenTips_ then
            --todo
            self.grabNotOpenTips_:show()
        end
    end
end

function ChooseRoomViewEx:reqCashRoomListData()
    -- body
    if nk.OnOff:check("cashRoom") then
        --todo
        self:reqCashRoomListDataByPage()
    else
        if self.cashNotOpenTips_ then
            --todo
            self.cashNotOpenTips_:show()
        end
    end
end

function ChooseRoomViewEx:reqGrabRoomListDataByPage()
    -- body
    if self.grabCurPage >= self.grabTotalPage then
        --todo
        dump("No GrabRoom Data! =============")
        return
    end

    self.grabCurPage = self.grabCurPage + 1

    local grabRoomListDataReqParam = {
        roomType = 0, -- 0非现金币场 1现金币场 2混合
        pageItemNum = 20
    }

    nk.server:requestGrabRoomList(grabRoomListDataReqParam.roomType, self.grabCurPage, grabRoomListDataReqParam.pageItemNum)
end

function ChooseRoomViewEx:reqCashRoomListDataByPage()
    -- body
    if self.cashCurPage >= self.cashTotalPage then
        --todo
        dump("No CashRoom Data! =============")
        return
    end

    self.cashCurPage = self.cashCurPage + 1

    local cashRoomListDataReqParam = {
        roomType = 1, -- 0非现金币场 1现金币场 2混合
        pageItemNum = 20
    }

    nk.server:requestGrabRoomList(cashRoomListDataReqParam.roomType, self.cashCurPage, cashRoomListDataReqParam.pageItemNum)
    
end


function ChooseRoomViewEx:checkHallCashGuide()
    if not nk.NewerGuideTip then
        return
    end
    if self.roomChips_ and #self.roomChips_ > 0 then
        for _,chip in pairs(self.roomChips_) do
            local preCall = chip:getPreCall()
            --现金币场，且底注为1
            if preCall and (checkint(preCall[20]) == 2) and (checkint(preCall[2]) == 1) then
                local parent = chip:getParent()
                local pos = {x = chip:getPositionX(),y = chip:getPositionY()}
                --nk.NewerGuideTip:checkShowHallCashTip(bm.LangUtil.getText("NEWER", "GUIDE_HALL_CASH_TIP"),parent,pos.x,pos.y+134)
                break
            end
        end
    end
end

function ChooseRoomViewEx:checkGroupGuide()
    local roomLevel,roomData = nk.getGuideChipRoomLevelByMoney(nk.userData["aUser.money"])
    if roomLevel and roomData then
        if self.roomChips_ and #self.roomChips_ > 0 then
            for _,chip in pairs(self.roomChips_) do
                local preCall = chip:getPreCall()
                if preCall and preCall[1] == roomLevel then
                    local parent = chip:getParent()
                    local pos = {x = chip:getPositionX(),y = chip:getPositionY()}
                    self:showGroupGuideEffect(parent,pos)
                    break
                end
            end
        end
    end
end

function ChooseRoomViewEx:showGroupGuideEffect(parent,pos)
    dump(pos,"showGroupGuideEffect")
    if not parent then
        return
    end

    if not pos then
        pos = {x = 0,y = 0}
    end

    local params = 
    {
        skeleton="dragonbones/group_guide_effect/skeleton.xml",
        texture="dragonbones/group_guide_effect/texture.xml",
        armatureName="fla_mangxuan",
        skeletonName="fla_mangxuan",
    }
    self.groupGuideEff_ = dragonbones.new(params)
    :addTo(parent)
    :scale(0.9)
    :pos(pos.x,pos.y)
    :getAnimation()
    :play()
end

function ChooseRoomViewEx:sortGrabRoomDataList(tb)
    -- body
    table.sort(tb, function(t1, t2)
        if t1.basechip > t2.basechip then
            return true
        elseif t1.basechip == t2.basechip then
            if t1.userCount > t2.userCount then
                return true
            elseif t1.userCount == t2.userCount then
                if t1.ante > t2.ante then
                    return true
                else
                    return false
                end
            else
                return false
            end
        else
            return false
        end
    end)
end

function ChooseRoomViewEx:sortCashRoomDataList(tb)
    -- body
    table.sort(tb, function(t1, t2)
        if t1.basechip > t2.basechip then
            return false
        elseif t1.basechip == t2.basechip then      
            if t1.userCount > t2.userCount then
                return true
            else
                return false
            end
        else
            return true
        end
    end)
end

function ChooseRoomViewEx:onSetGrabRoomList(data)
    -- dump(data, "onSetGrabRoomList.data :=====================")

    if self.selectedTabIdx_ == 3 then
        -- 上庄场数据
        --todo
        self.grabCurPage = data.cur_pages
        self.grabTotalPage = data.total_pages

        local desRoomTableList = {}
        local emptyRoomTable = {}
        local unEmptyRoomTable = {}

        for _, v in pairs(data.roomlist) do
            if v.userCount > 0  then
                -- if v.level ~= consts.ROOM_GAME_LEVEL.GRAB_CASH_ROOM_LEVEL then
                table.insert(unEmptyRoomTable, v)
                -- end
            else
                -- if v.level ~= consts.ROOM_GAME_LEVEL.GRAB_CASH_ROOM_LEVEL then
                table.insert(emptyRoomTable, v)
                -- end
            end
        end

        self:sortGrabRoomDataList(unEmptyRoomTable)
        self:sortGrabRoomDataList(emptyRoomTable)

        table.insertto(desRoomTableList, unEmptyRoomTable)
        table.insertto(desRoomTableList, emptyRoomTable)

        if not self.grabRoomDataList_ then
            --todo
            self.grabRoomDataList_ = {}
        end

        local tmpRoomTableList = {}
        local count = 0
        local newRoomTableIdx = nil
        local oldRoomTableIdx = nil

        for _, newTab in pairs(desRoomTableList) do
            count = 0
            newRoomTableIdx = tonumber(newTab.tableId) or - 1
            for __, oldTab in pairs(self.grabRoomDataList_) do
                oldRoomTableIdx = tonumber(oldTab.tableId) or - 1
                -- dump(newTableId,"newTableId")
                -- dump(oldTableId,"oldTableId")
                -- dump(oldTableId == newTableId," === ")
                if (oldRoomTableIdx ~= - 1 and newRoomTableIdx ~= - 1 ) and (oldRoomTableIdx == newRoomTableIdx) then
                    -- dump("old000","old000")
                    break
                end
                count = count + 1  -- (count <= #self.grabRoomDataList_) == true
            end

            if count == #self.grabRoomDataList_ then
                table.insert(tmpRoomTableList, newTab)
            end
        end

        table.insertto(self.grabRoomDataList_, tmpRoomTableList)
        -- self.grabRoomList_:setData(self.grabRoomDataList_)
        -- self.grabRoomQuickPlayBtn_:setButtonEnabled(true)

        local grabRoomLoadingBarPosAdj = 80

        self.grabRoomLoadingBar_ = nk.ui.Juhua.new()
            :pos(0, - grabRoomLoadingBarPosAdj)
            :addTo(self)

        self:performWithDelay(function()
            -- body

            if self.grabRoomList_ then
                --todo
                self.grabRoomList_:setData(self.grabRoomDataList_)
            end
            
            if self.grabRoomQuickPlayBtn_ then
                --todo
                self.grabRoomQuickPlayBtn_:setButtonEnabled(true)
            end

            self.grabRoomLoadingBar_:removeSelf()
            self.grabRoomLoadingBar_ = nil
        end, 0.1)

        -- dump(self.grabRoomDataList_, "self.grabRoomDataList_ :======================")
        

    elseif self.selectedTabIdx_ == 2 then
        -- 现金币场数据
        --todo
        self.cashCurPage = data.cur_pages
        self.cashTotalPage = data.total_pages

        local desRoomTableList = {}
        local emptyRoomTable = {}
        local unEmptyRoomTable = {}

        for _, v in pairs(data.roomlist) do
            if v.userCount > 0  then
                -- if v.level ~= consts.ROOM_GAME_LEVEL.GRAB_CASH_ROOM_LEVEL then
                table.insert(unEmptyRoomTable, v)
                -- end
            else
                -- if v.level ~= consts.ROOM_GAME_LEVEL.GRAB_CASH_ROOM_LEVEL then
                table.insert(emptyRoomTable, v)
                -- end
            end
        end

        self:sortCashRoomDataList(unEmptyRoomTable)
        self:sortCashRoomDataList(emptyRoomTable)

        table.insertto(desRoomTableList, unEmptyRoomTable)
        table.insertto(desRoomTableList, emptyRoomTable)

        if not self.cashRoomDataList_ then
            --todo
            self.cashRoomDataList_ = {}
        end

        local tmpRoomTableList = {}
        local count = nil
        local newRoomTableIdx = nil
        local oldRoomTableIdx = nil

        for _, newTab in pairs(desRoomTableList) do
            count = 0
            newRoomTableIdx = tonumber(newTab.tableId) or - 1
            for __, oldTab in pairs(self.cashRoomDataList_) do
                oldRoomTableIdx = tonumber(oldTab.tableId) or - 1
                -- dump(newTableId,"newTableId")
                -- dump(oldTableId,"oldTableId")
                -- dump(oldTableId == newTableId," === ")
                if (oldRoomTableIdx ~= - 1 and newRoomTableIdx ~= - 1 ) and (oldRoomTableIdx == newRoomTableIdx) then
                    -- dump("old000","old000")
                    break
                end
                count = count + 1
            end

            if count == #self.cashRoomDataList_ then
                table.insert(tmpRoomTableList, newTab)
            end
        end

        table.insertto(self.cashRoomDataList_, tmpRoomTableList)

        local cashRoomLoadingBarPosAdj = 80
        self.cashRoomLoadingBar_ = nk.ui.Juhua.new()
            :pos(0, - cashRoomLoadingBarPosAdj)
            :addTo(self)

        self:performWithDelay(function()
            -- body
            if self.cashRoomList_ then
                --todo
                self.cashRoomList_:setData(self.cashRoomDataList_)
            end

            self.cashRoomLoadingBar_:removeSelf()
            self.cashRoomLoadingBar_ = nil
        end, 0.1)

        -- self.cashRoomList_:setData(self.cashRoomDataList_)
    end
end

function ChooseRoomViewEx:onGetPersonalRoomList(isAnim, data)
    -- body
    self.perRoomPage_:onGetPersonalRoomList(isAnim, data)
end

function ChooseRoomViewEx:addDataObservers()
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
        if not money then
            return
        end

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

function ChooseRoomViewEx:onEnter()
    -- body
    self:addDataObservers()
end

function ChooseRoomViewEx:onExit()
    -- body
    nk.ImageLoader:cancelJobByLoaderId(self.userAvatarLoaderId_)
    bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "aUser.micon", self.avatarUrlObserverHandle_)
    bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "aUser.money", self.userMoneyChangeObserver_)
    bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "match.point", self.userCashChangeObserver_)
end

function ChooseRoomViewEx:onCleanup()
    if self.suonaMsgScrollAnim_ then
        --todo
        self:stopAction(self.suonaMsgScrollAnim_)
    end

    if self.suonaDelayCallHandler_ then
        --todo
        nk.schedulerPool:clear(self.suonaDelayCallHandler_)
    end
end

return ChooseRoomViewEx