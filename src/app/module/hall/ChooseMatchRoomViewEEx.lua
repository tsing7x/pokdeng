
local StorePopup = import("app.module.newstore.StorePopup")
local HelpPopup_1 = import("app.module.match.views.MatchRoomChooseHelpPopup")
local HelpPopup_2 = import("app.module.settingAndhelp.SettingAndHelpPopup")
local HallSearchRoomPanel = import("app.module.hall.HallSearchRoomPanel")
local PayGuide = import("app.module.room.purchGuide.PayGuide")
local FirChargePayGuidePopup = import("app.module.newstore.firChrgGuide.FirChrgPayGuidePopup")
local ScoreMarketView = import("app.module.scoreMarket.ScoreMarketView")
local AuctionMarketPopup = import("app.module.auctionmarket.AuctionMarketPopup")
local MatchNormalRegisterPopup = import("app.module.match.views.MatchNormalRegisterPopup")
local MatchTimeRegisterPopup = import("app.module.match.views.MatchTimeRegisterPopup")
local ChooseMatchTimeItem = import(".ChooseMatchTimeItem")
local ChooseMatchNormalItem = import(".ChooseMatchNormalItem")
local SuonaUsePopup = import("app.module.suona.SuonaUsePopup")
local LoadMatchControlEx = import("app.module.match.LoadMatchControlEx")

local ChooseMatchRoomViewEEx = class("ChooseMatchRoomViewEEx", function ()
    return display.newNode()
end)

local ChooseMatchRoomChip = import(".ChooseMatchRoomChip")
local ChooseMatchRoomChipEx = import(".ChooseMatchRoomChipEx")

ChooseMatchRoomViewEEx.PLAYER_LIMIT_SELECTED = 1 -- 1：9人场；2：5人场
ChooseMatchRoomViewEEx.ROOM_LEVEL_SELECTED   = nil -- 1：初级场；2：中级场；3：高级场
ChooseMatchRoomViewEEx.MATCH_TYPE_TIME = 1
ChooseMatchRoomViewEEx.MATCH_TYPE_NORMAL = 2
ChooseMatchRoomViewEEx.MATCH_TYPE_OTHER = 3
ChooseMatchRoomViewEEx.MATCH_TYPE_SELECTED = nil

local ROOM_TYPE_NOR = 1
local ROOM_TYPE_PRO = 2
local TOP_BUTTOM_WIDTH   = 78
local TOP_BUTTOM_HEIGHT  = 64
local TOP_BUTTOM_PADDING = 8
local TOP_TAB_BAR_WIDTH  = 612
local TOP_TAB_BAR_HEIGHT = 66
local CHIP_HORIZONTAL_DISTANCE = 240 * nk.widthScale
local CHIP_VERTICAL_DISTANCE   = 216 * nk.heightScale

local maskEndX = 0
local foldBtnStartPos 
local foldBtnEndPos 

local AVATAR_TAG = 100

local TICKETS_IDS = {7101,7102,7104}

function ChooseMatchRoomViewEEx:ctor(controller, viewType)
    self.controller_ = controller
    self.controller_:setDisplayView(self)
    if viewType == controller.CHOOSE_MATCH_NOR_VIEW then
        self.roomType_ = ROOM_TYPE_NOR
        self.roomTypeIcon_ = display.newSprite("#choose_room_nor_icon.png")
    else
        self.roomType_ = ROOM_TYPE_PRO
        self.roomTypeIcon_ = display.newSprite("#choose_room_pro_icon.png")
    end

    self:setNodeEventEnabled(true)

    self.pokerTable_ = display.newNode():pos(0, -(display.cy + 146)):addTo(self):scale(self.controller_:getBgScale())
    local tableLeft = display.newSprite("#main_hall_table.png"):addTo(self.pokerTable_)
    tableLeft:setAnchorPoint(cc.p(1, 0.5))
    tableLeft:pos(2, 0)
    local tableRight = display.newSprite("#main_hall_table.png"):addTo(self.pokerTable_)
    tableRight:setScaleX(-1)
    tableRight:setAnchorPoint(cc.p(1, 0.5))
    tableRight:pos(-2, 0)

    self.roomTypeIcon_:align(display.LEFT_CENTER, -(display.cx + self.roomTypeIcon_:getContentSize().width), -CHIP_VERTICAL_DISTANCE * 0.5 + 40 * nk.heightScale)
        :addTo(self)

    self.splitLine_ = display.newSprite("#choose_room_split_line.png")
        :pos(0, display.cy - 176)
        :addTo(self)
        :opacity(0)
    self.splitLine_:setScaleX(nk.widthScale * 0.9)

    self.normalMatchListNode_ = display.newNode()
    :addTo(self)
    self:createNormalMatchListView()

    self.timeMatchListNode_ = display.newNode()
    :addTo(self)
    self:createTimeMatchListView()
    self:createBottomView()

    self:createTopBtnView()
    self:createBrocastView()

    local repArgs = {
        eventId = "ChooseMatchRoomView_Create",
        label = "ChooseMatchRoomView_Create",
    }
    self:reportUmeng_("event",repArgs)

    -- nk.MatchConfig:loadConfig(nk.userData.MATCH_JSON,handler(self,self.onLoadNormalMatchConfig))
    -- nk.MatchConfigEx:loadConfig(nil,handler(self,self.onLoadTimeMatchConfig))

    nk.MatchConfigEx:loadConfig(nil,handler(self,self.onLoadMatchConfig))

    self:addDataObservers()
	self:getMatchHallInfo()
end

function ChooseMatchRoomViewEEx:createTopBtnView()
	self.topBtnNode_ = display.newNode()
        :pos(0, TOP_BUTTOM_HEIGHT + TOP_TAB_BAR_HEIGHT + TOP_BUTTOM_PADDING)
        :addTo(self)
    -- 返回
    display.newScale9Sprite("#top_btn_bg.png", 0, 0, cc.size(TOP_BUTTOM_WIDTH + 4, TOP_BUTTOM_HEIGHT + 4))
        :pos(-display.cx + TOP_BUTTOM_WIDTH * 0.5 + TOP_BUTTOM_PADDING, display.cy - TOP_BUTTOM_HEIGHT * 0.5 - TOP_BUTTOM_PADDING)
        :addTo(self.topBtnNode_)
    display.newSprite("#top_return_btn_icon.png")
        :pos(-display.cx + TOP_BUTTOM_WIDTH * 0.5 + TOP_BUTTOM_PADDING, display.cy - TOP_BUTTOM_HEIGHT * 0.5 - TOP_BUTTOM_PADDING)
        :addTo(self.topBtnNode_)
    cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#rounded_rect_6.png"}, {scale9 = true})
        :setButtonSize(TOP_BUTTOM_WIDTH, TOP_BUTTOM_HEIGHT)
        :pos(-display.cx + TOP_BUTTOM_WIDTH * 0.5 + TOP_BUTTOM_PADDING, display.cy - TOP_BUTTOM_HEIGHT * 0.5 - TOP_BUTTOM_PADDING)
        :addTo(self.topBtnNode_)
        :onButtonClicked(buttontHandler(self, self.onReturnClick_))

    -- 帮助
    -- display.newScale9Sprite("#top_btn_bg.png", 0, 0, cc.size(TOP_BUTTOM_WIDTH + 4, TOP_BUTTOM_HEIGHT + 4))
    --     :pos(-display.cx + TOP_BUTTOM_WIDTH * 1.5 + TOP_BUTTOM_PADDING * 2, display.cy - TOP_BUTTOM_HEIGHT * 0.5 - TOP_BUTTOM_PADDING)
    --     :addTo(self.topBtnNode_)
    -- display.newSprite("#top_help_btn_icon.png")
    --     :pos(-display.cx + TOP_BUTTOM_WIDTH * 1.5 + TOP_BUTTOM_PADDING * 2, display.cy - TOP_BUTTOM_HEIGHT * 0.5 - TOP_BUTTOM_PADDING)
    --     :addTo(self.topBtnNode_)
    cc.ui.UIPushButton.new({normal = "#check_match_info_btn_up.png", pressed = "#check_match_info_btn_down.png"}, {scale9 = true})
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
    cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#rounded_rect_6.png"}, {scale9 = true})
        :setButtonSize(TOP_BUTTOM_WIDTH, TOP_BUTTOM_HEIGHT)
        :pos(display.cx - TOP_BUTTOM_WIDTH * 1.5 - TOP_BUTTOM_PADDING * 2, display.cy - TOP_BUTTOM_HEIGHT * 0.5 - TOP_BUTTOM_PADDING)
        :addTo(self.topBtnNode_)
        :onButtonClicked(buttontHandler(self, self.onFeedbackClick_))


    -- 积分商城
    display.newScale9Sprite("#top_btn_bg.png", 0, 0, cc.size(TOP_BUTTOM_WIDTH + 4, TOP_BUTTOM_HEIGHT + 4))
    	:pos(display.cx - TOP_BUTTOM_WIDTH * 0.5 - TOP_BUTTOM_PADDING, display.cy - TOP_BUTTOM_HEIGHT * 0.5 - TOP_BUTTOM_PADDING)
        -- :pos(display.cx - TOP_BUTTOM_WIDTH * 1.5 - TOP_BUTTOM_PADDING * 2, display.cy - TOP_BUTTOM_HEIGHT * 0.5 - TOP_BUTTOM_PADDING)
        :addTo(self.topBtnNode_)--:hide()
    display.newSprite("#match_score_market_btn.png")
    	:pos(display.cx - TOP_BUTTOM_WIDTH * 0.5 - TOP_BUTTOM_PADDING, display.cy - TOP_BUTTOM_HEIGHT * 0.5 - TOP_BUTTOM_PADDING)
        -- :pos(display.cx - TOP_BUTTOM_WIDTH * 1.5 - TOP_BUTTOM_PADDING * 2, display.cy - TOP_BUTTOM_HEIGHT * 0.5 - TOP_BUTTOM_PADDING)
        :addTo(self.topBtnNode_)--:hide()
        :scale(0.88)
    cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#rounded_rect_6.png"}, {scale9 = true})
        :setButtonSize(TOP_BUTTOM_WIDTH, TOP_BUTTOM_HEIGHT)
        :pos(display.cx - TOP_BUTTOM_WIDTH * 0.5 - TOP_BUTTOM_PADDING, display.cy - TOP_BUTTOM_HEIGHT * 0.5 - TOP_BUTTOM_PADDING)
        -- :pos(display.cx - TOP_BUTTOM_WIDTH * 1.5 - TOP_BUTTOM_PADDING * 2, display.cy - TOP_BUTTOM_HEIGHT * 0.5 - TOP_BUTTOM_PADDING)
        :addTo(self.topBtnNode_)--:hide()
        :onButtonClicked(buttontHandler(self, self.onScoreMarektClick_))

    if nk.OnOff:check("auction") then
        local auctionMarketEntryBtn = cc.ui.UIPushButton.new({normal = "#auctMar_entryBg_nor.png", pressed = "#auctMar_entryBg_pre.png"}, {scale9 = false})
        :onButtonClicked(buttontHandler(self, self.onAuctionMarketClk_))
        :pos(display.cx - TOP_BUTTOM_WIDTH * 0.5 - TOP_BUTTOM_PADDING, display.cy - TOP_BUTTOM_HEIGHT * 0.5 - TOP_BUTTOM_PADDING-70)
        :addTo(self.topBtnNode_)

        local auctionMarketEntryIcon = display.newSprite("#auctMar_icEntry.png")
        :addTo(auctionMarketEntryBtn)

    end

    self.mainTabBar_ = nk.ui.CommonPopupTabBar.new(
        {
            popupWidth = display.width-230, 
            iconOffsetX = 10, 
            iconTexture = {
                {"#hot_room_tab_icon_selected.png", "#hot_room_tab_icon_unselected.png"}, 
                {"#nor_room_tab_icon_selected.png", "#nor_room_tab_icon_unselected.png"}, 
                {"#wait_tab_icon_selected.png", "#wait_tab_icon_unselected.png"}
            }, 
            btnText = bm.LangUtil.getText("HALL", "ROOM_LIST_TAB_TEXT"), 
        }
    )
       :pos(-20, display.cy  - TOP_TAB_BAR_HEIGHT * 0.5-2)
        :addTo(self.topBtnNode_)

    self.mainTabBar_:onTabChange(handler(self, self.onMainTabChange_))
    self.mainTabBar_:gotoTab(ChooseMatchRoomViewEEx.MATCH_TYPE_TIME)

end

function ChooseMatchRoomViewEEx:onMainTabChange_(selectedTab)

	local lastSelected = ChooseMatchRoomViewEEx.MATCH_TYPE_SELECTED
	if selectedTab == ChooseMatchRoomViewEEx.MATCH_TYPE_OTHER then
		nk.TopTipManager:showTopTip(bm.LangUtil.getText("HALL","NOTOPEN"))
		if self.mainTabBar_ then
			self.mainTabBar_:gotoTab(lastSelected)
		end
		return
	end 

    self:setMainTabSelected(selectedTab)
end

function ChooseMatchRoomViewEEx:setMainTabSelected(selectedTab)
	
	ChooseMatchRoomViewEEx.MATCH_TYPE_SELECTED = selectedTab

	if selectedTab == ChooseMatchRoomViewEEx.MATCH_TYPE_TIME then
		local mlistData = self:findNextSomeTimeMatchs() or {}
        self:onUpdateTimeItemBaseInfo(mlistData)
        self:getTimeMatchPlayerCountData(mlistData)
   
		self.timeMatchListNode_:show()
		self.normalMatchListNode_:hide()
	elseif selectedTab == ChooseMatchRoomViewEEx.MATCH_TYPE_NORMAL then
		self.timeMatchListNode_:hide()
		self.normalMatchListNode_:show()
	elseif selectedTab == ChooseMatchRoomViewEEx.MATCH_TYPE_OTHER then

	end
end

function ChooseMatchRoomViewEEx:createBrocastView()
	local systemTipWidth = (display.width - 230) * 0.85
    local systemTipHeight = 51 --也是小喇叭的宽度

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

end

function ChooseMatchRoomViewEEx:onSendBordBtnCallBack_()
	SuonaUsePopup.new():show()
end

function ChooseMatchRoomViewEEx:createBottomView()
	self.bottomNode_ = display.newNode()
	:addTo(self)
    :pos(0,-display.height/2 + 45)

    local BUTTOM_BG_H = 45
    display.newScale9Sprite("#hall_chooseView_buttom_bg.png",0,0,cc.size(display.width,BUTTOM_BG_H))
    :addTo(self.bottomNode_)
    :pos(0,-BUTTOM_BG_H/2)



    self.bottomClippingNode_ = cc.ClippingNode:create()
        :addTo(self.bottomNode_)

    local pos_y = -23 --底部元素y值
    local icon_gap = 115 --底部icon间隔
    local start_x = -display.width/2+75 --底部icon起点值
    local buttom_Txt_width = 100 --底部文本宽度
    local txt_left_icon = 32 --底部文本相对icon偏移值

    local leftX = -display.width/2
    local rightX = start_x +5*icon_gap+10+buttom_Txt_width
    
    self.bottomStencil_ = display.newDrawNode()
    self.bottomStencil_:drawPolygon({
        {leftX, 0}, 
        {rightX,0}, 
        {rightX, -45}, 
        {leftX,-45}
    })


    self.maskW_ = math.abs(rightX - leftX)
    local mstartx = start_x + 3*icon_gap
    self.maskStartX_ = -math.abs(rightX - mstartx)
    self:setShowBottomIcon(true,false)

    foldBtnStartPos = {x = mstartx+8,y = -22}
    foldBtnEndPos = {x = rightX + 8,y = -22}

    
    self.bottomClippingNode_:setStencil(self.bottomStencil_)
    -- self.bottomStencil_:addTo(self.bottomNode_)

    self.foldBtn_ = cc.ui.UIPushButton.new({normal = "#icon_fold_btn_normal.png", pressed = "#icon_fold_btn_press.png"})
        :addTo(self.bottomNode_)
        :onButtonClicked(buttontHandler(self, self.onFoldBtnClick_))


    self:setShowFoldBtn(true,false)

    self.isFold_ = true

     -- 头像加载id
    self.userAvatarLoaderId_ = nk.ImageLoader:nextLoaderId()
    -- 默认头像
    self.avatar_ = display.newSprite("#common_transparent_skin.png")
    self.avatar_:addTo(self.bottomNode_, 0, AVATAR_TAG)
    self.avatar_:align(display.LEFT_CENTER)
    self.avatar_:pos(-display.width/2+20,-23)

    local iconNode = display.newNode()
    :addTo(self.bottomClippingNode_)

    display.newSprite("#hall_small_chip_icon.png")
    :align(display.LEFT_CENTER)
    :addTo(iconNode)
    :pos(start_x,pos_y)

    display.newSprite("#hall_small_cash_icon.png")
    :align(display.LEFT_CENTER)
    :addTo(iconNode)
    :pos(start_x+icon_gap,pos_y)

    display.newSprite("#hall_small_c_cion.png")
    :align(display.LEFT_CENTER)
    :addTo(iconNode)
    :pos(start_x+2*icon_gap,pos_y)

    display.newSprite("#hall_small_ticket_7101.png")
    :align(display.LEFT_CENTER)
    :addTo(iconNode)
    :pos(start_x+3*icon_gap,pos_y)

    display.newSprite("#hall_small_ticket_7102.png")
    :align(display.LEFT_CENTER)
    :addTo(iconNode)
    :pos(start_x+4*icon_gap,pos_y)

    display.newSprite("#hall_small_ticket_7104.png")
    :align(display.LEFT_CENTER)
    :addTo(iconNode)
    :pos(start_x+5*icon_gap,pos_y)

    --金币
    self.moneyLabel_ = display.newTTFLabel({text = "0", color = cc.c3b(0xff,0xff,0xff),dimensions = cc.size(buttom_Txt_width, 30), size = 19, align = ui.TEXT_ALIGN_LEFT})
    :align(display.LEFT_CENTER)
    :addTo(iconNode)
    :pos(start_x+txt_left_icon,pos_y)
    --现金币
    self.cashLabel_ = display.newTTFLabel({text = "0", color = cc.c3b(0xe1,0xc8,0x02),dimensions = cc.size(buttom_Txt_width, 30), size = 19, align = ui.TEXT_ALIGN_LEFT})
    :align(display.LEFT_CENTER)
    :addTo(iconNode)
    :pos(start_x+icon_gap+txt_left_icon,pos_y)
    --普通门票--奖杯数量
    self.clubLabel_ = display.newTTFLabel({text = "0", color = cc.c3b(0xe1,0xc8,0x02),dimensions = cc.size(buttom_Txt_width, 30), size = 19, align = ui.TEXT_ALIGN_LEFT})
    :align(display.LEFT_CENTER)
    :addTo(iconNode)
    :pos(start_x+2*icon_gap+txt_left_icon + 10,pos_y)
    --普通门票-
    self.normalTicketLabel_ = display.newTTFLabel({text = "0", color = cc.c3b(0xe1,0xc8,0x02),dimensions = cc.size(buttom_Txt_width, 30), size = 19, align = ui.TEXT_ALIGN_LEFT})
    :align(display.LEFT_CENTER)
    :addTo(iconNode)
    :pos(start_x+3*icon_gap+txt_left_icon+ 10,pos_y)
   

    self.chujiTicketLabel_ = display.newTTFLabel({text = "0", color = cc.c3b(0x92,0xdc,0x5f),dimensions = cc.size(buttom_Txt_width, 30), size = 19, align = ui.TEXT_ALIGN_LEFT})
    :align(display.LEFT_CENTER)
    :addTo(iconNode)
    :pos(start_x+4*icon_gap+txt_left_icon+10,pos_y)


     --通用门票
    self.specialTicketLabel_ = display.newTTFLabel({text = "0", color = cc.c3b(0x92,0xdc,0x5f),dimensions = cc.size(buttom_Txt_width, 30), size = 19, align = ui.TEXT_ALIGN_LEFT})
    :align(display.LEFT_CENTER)
    :addTo(iconNode)
    :pos(start_x+5*icon_gap+txt_left_icon+15,pos_y)


    if nk.userData["aUser.money"] < 100000 then
        self.moneyLabel_:setString(bm.formatNumberWithSplit(nk.userData["aUser.money"]))
    else
        self.moneyLabel_:setString(bm.formatBigNumber(nk.userData["aUser.money"]))
    end
    self.cashLabel_:setString(bm.formatBigNumber(nk.userData["match.point"]))

    local yellowBtnWidth = 148
    local yellowBtnHeight = 42
    self.buyTicketNode_ = display.newNode():addTo(self.bottomNode_)
    :pos(display.width/2-yellowBtnWidth+45,pos_y)

    display.newScale9Sprite("#hall_choose_yellow_btn.png",0,0,cc.size(yellowBtnWidth,yellowBtnHeight))
    :addTo(self.buyTicketNode_)
    display.newSprite("#hall_small_cash_icon.png")
    :addTo(self.buyTicketNode_)
    :pos(-40,0)

    display.newTTFLabel({text = bm.LangUtil.getText("COMMON", "BUY"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 20, align = ui.TEXT_ALIGN_CENTER})
    :addTo(self.buyTicketNode_)
    :pos(10,0)

    cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#rounded_rect_10.png"}, {scale9 = true})
    :setButtonSize(yellowBtnWidth-5, yellowBtnHeight)
    :onButtonClicked(buttontHandler(self,self.buyTicket_))
    :addTo(self.buyTicketNode_)
end


function ChooseMatchRoomViewEEx:createNormalMatchListView()
	if not self.normalMatchList_ then
		local LIST_WIDTH = 931
		local LIST_HEIGHT = 367
		self.normalMatchList_ = bm.ui.ListView.new(
	        {
	            viewRect = cc.rect(-(display.width-40) * 0.5, -360 * 0.5, (display.width-40), 360)
	        }, 
	        ChooseMatchNormalItem
    	)
    	:addTo(self.normalMatchListNode_)
    	:pos(0, -70)

    	self.normalMatchList_:addEventListener("ITEM_EVENT",handler(self,self.onNormalMatchClick))
	end
end

function ChooseMatchRoomViewEEx:onNormalMatchClick(evt)
	local matchBaseInfo = evt.data
	if matchBaseInfo then
		if tonumber(matchBaseInfo.open) == 0 then
	         nk.TopTipManager:showTopTip(bm.LangUtil.getText("HALL", "NOTOPEN"))
	    else

            MatchNormalRegisterPopup.new(matchBaseInfo):show()
	        -- MatchApplyPopul.new(matchBaseInfo):show()
	        local repArgs = {
	            eventId = "onMatchClipClick_",
	            attributes = "id," .. matchBaseInfo.id or -1,
	            counter = 1
	        }
	        self:reportUmeng_("eventCustom",repArgs)
	    end
	end
	
end

function ChooseMatchRoomViewEEx:createTimeMatchListView()
	if not self.timeMatchList_ then
		local LIST_WIDTH = 931
		local LIST_HEIGHT = 367
		self.timeMatchList_ = bm.ui.ListView.new(
	        {
	            viewRect = cc.rect(-(display.width-40) * 0.5, -360 * 0.5, (display.width-40), 360)
	        }, 
	        ChooseMatchTimeItem
    	)
    	:addTo(self.timeMatchListNode_)
    	:pos(0, -70)

    	self.timeMatchList_:addEventListener("ITEM_EVENT",handler(self,self.onTimeMatchClick))
	end
end

function ChooseMatchRoomViewEEx:onTimeMatchClick(evt)
	MatchTimeRegisterPopup.new(evt.data, handler(self,self.onTimeRegisterCallback)):show()
end

function ChooseMatchRoomViewEEx:onTimeRegisterCallback(matchData)
    -- {id = id,matchid = matchid,time = matchTime}
    -- self:getMatchHallInfo()
    dump(matchData,"onTimeRegisterCallback")
    if self.timeMatchDatas_ then
        for i,v in ipairs(self.timeMatchDatas_) do
            if v.id == matchData.id and v.mtime.timestamp == matchData.time then
                --是否已报名标识
                v.isReg = true

                if self.timeMatchList_ then
                    self.timeMatchList_:updateData(i,v)
                end

            end
        end

        --报名成功，刷新下人数
        self:getTimeMatchPlayerCountData(self.timeMatchDatas_)
    end

end

function ChooseMatchRoomViewEEx:findNextSomeTimeMatchs()
    local mlistData = nk.MatchConfigEx:findNextSomeTimeMatchs()
    if mlistData then
    	table.walk(mlistData, function(v, k)
	        -- 检查场次是否已经报过名
	        local regData = nk.MatchConfigEx:findRegisterMatchByIdAndTime(v.id,v.mtime.timestamp)
	        if regData then
	            v.isReg = true
	        end
	    end)
	    table.sort(mlistData,function(t1,t2)
	        return t1.mtime.timestamp < t2.mtime.timestamp
	    end)
    end
    

    return mlistData
end

function ChooseMatchRoomViewEEx:updateSomeInfoByInterval()

    if self.getMatchPeopleAction_ then
        self:stopAction(self.getMatchPeopleAction_)
        self.getMatchPeopleAction_ = nil
    end
    self.getMatchPeopleAction_ = self:schedule(function ()

    	if ChooseMatchRoomViewEEx.MATCH_TYPE_SELECTED == ChooseMatchRoomViewEEx.MATCH_TYPE_TIME then
			if self.timeMatchDatas_ and #self.timeMatchDatas_ > 0 then
	            -- 定时刷新报名人数
	            -- dump("updateSomeInfoByInterval====")
	            self:getTimeMatchPlayerCountData(self.timeMatchDatas_)
	        end
    	end
        
    end, 30)

   
    
end



function ChooseMatchRoomViewEEx:getTimeMatchPlayerCountData(listDatas)
    local tb = {}

    for _,v in pairs(listDatas) do
        local id = tostring(v["id"])
        if not tb[id] then
            tb[id] = {}
        end
        table.insert(tb[id],tostring(v.mtime.timestamp))
    end
    self.controller_:getTimeMatchPlayerCountData(tb)
end



function ChooseMatchRoomViewEEx:onGetTimeMatchPlayerCountData(datas)
    self:onUpdateTimeMatchPlayerNum(datas)
end


function ChooseMatchRoomViewEEx:onUpdateTimeMatchPlayerNum(datas)
    -- dump(datas,"ChooseMatchRoomViewEEx:updataOnlineNum")

    local total = 0
    for i, baseData in ipairs(self.timeMatchDatas_) do  

        local id = baseData["id"]  
        local timestamp = baseData["mtime"]["timestamp"]
        local onlineData = datas[tostring(id)]
        local count = 0
        if onlineData then
            count = onlineData[tostring(timestamp)] or 0
        else
            count = math.floor(math.random(5,30))
        end

        baseData.playerCount = count
        total = total + count
        
        if self.timeMatchList_ then
            self.timeMatchList_:updateData(i,baseData)
        end
    end
    
end

function ChooseMatchRoomViewEEx:onUpdateTimeItemBaseInfo(mData)
	self.timeMatchDatas_ = mData or {}

    if self.timeMatchList_ then
        self.timeMatchList_:setData(self.timeMatchDatas_)
    end
end

function ChooseMatchRoomViewEEx:onLoadTimeMatchConfig(isSuccess,matchsdata)
	if isSuccess and matchsdata then
        local mlistData = self:findNextSomeTimeMatchs() or {}
       -- dump(mlistData,"mlistData")
       self:onUpdateTimeItemBaseInfo(mlistData)
       self:getTimeMatchPlayerCountData(mlistData)
       self:updateSomeInfoByInterval()
    else
        self:onUpdateTimeItemBaseInfo({})
    end
end

function ChooseMatchRoomViewEEx:onUpdateNormalMatchPlayerNum(datas)
    if not self.normalMatchDatas_ then
        return
    end
    
    local total = 0
    for i, baseData in ipairs(self.normalMatchDatas_) do        
        local num = 0
        if (baseData and baseData["id"]) and (datas and datas[(baseData["id"])]) then
            num = datas[(baseData["id"])]
        else
            num = 50
        end
        total = total + num
        baseData.playerCount = num
        -- chip:setPlayerCount(num)
        if self.normalMatchList_ then
            self.normalMatchList_:updateData(i,baseData)
        end
    end

     -- 设置总在玩人数
    -- self:setPlayerCount(total)
end


function ChooseMatchRoomViewEEx:onUpdateNormalItemBaseInfo(data)

    self.normalMatchDatas_ = data

	if self.normalMatchList_ then
        self.normalMatchList_:setData(data)
    end

    
end



function ChooseMatchRoomViewEEx:onLoadMatchConfig(isSuccess,matchsdata)
    
    --定人赛---------------------------------------------------------------
        if isSuccess and matchsdata then
            -- local match = matchsdata["match"]
            local match = nk.MatchConfigEx:getMatchDatasByType(LoadMatchControlEx.TYPE_NORMAL_MATCH)
            self:onUpdateNormalItemBaseInfo(match)
            self.controller_:getMatchPlayerCountData()
        else
            self:onUpdateNormalItemBaseInfo({})
        end

    --定人赛---------------------------------------------------------------



    --定时赛---------------------------------------------------------------
        if isSuccess and matchsdata then
            local mlistData = self:findNextSomeTimeMatchs() or {}

           -- dump(mlistData, "TimeMatchData :===============", 8)
           self:onUpdateTimeItemBaseInfo(mlistData)
           self:getTimeMatchPlayerCountData(mlistData)
           self:updateSomeInfoByInterval()
        else
            self:onUpdateTimeItemBaseInfo({})
        end


    --定时赛---------------------------------------------------------------
end


-- function ChooseMatchRoomViewEEx:onLoadNormalMatchConfig(isSuccess,matchsdata)

-- 	if isSuccess and matchsdata then
--         local match = matchsdata["match"]
--         self:onUpdateNormalItemBaseInfo(match)
--         self.controller_:getMatchPlayerCountData()
--     else
--         self:onUpdateNormalItemBaseInfo({})
--     end

-- end


function ChooseMatchRoomViewEEx:onLoadNormalMatchConfigNew(isSuccess,matchsdata)

    if isSuccess and matchsdata then
        local match = matchsdata["match"]
        self:onUpdateNormalItemBaseInfo(match)
    else
        self:onUpdateNormalItemBaseInfo({})
    end

    if self.setOnlineNumRequest_ then
        self.setOnlineNumRequest_()
        self.setOnlineNumRequest_ = nil
    end

end





function ChooseMatchRoomViewEEx:setPlayerCount(count)
    if count >= 0 then
        self.userOnline_:setString(bm.LangUtil.getText("HALL", "USER_ONLINE", bm.formatNumberWithSplit(count)))
        local iconWidth = self.playerCountIcon_:getContentSize().width
        local labelWidth = self.userOnline_:getContentSize().width
        self.playerCountIcon_:show()
            :setPositionX(-(iconWidth + labelWidth + 6) * 0.5)
        self.userOnline_:show()
            :setPositionX(self.playerCountIcon_:getPositionX() + iconWidth + 6)
    end
end





function ChooseMatchRoomViewEEx:playShowAnim()


	
    local animTime = self.controller_.getAnimTime()
    -- 桌子
    transition.moveTo(self.pokerTable_, {time = animTime, y = 0})
    -- icon
    transition.moveTo(self.roomTypeIcon_, {time = animTime, x = -display.cx, delay = animTime})
    -- 分割线
    transition.fadeIn(self.splitLine_, {time = animTime, opacity = 255, delay = animTime})
    -- 在线人数
    -- transition.fadeIn(self.userOnline_, {time = animTime, opacity = 255, delay = animTime})
    -- 顶部操作区
    transition.moveTo(self.topBtnNode_, {time = animTime, y = 0, delay = animTime})
    -- 筹码


    local lastSelected = ChooseMatchRoomViewEEx.MATCH_TYPE_SELECTED

    dump(lastSelected,"playShowAnim")
    if selectedTab == ChooseMatchRoomViewEEx.MATCH_TYPE_TIME then
        -- transition.fadeIn(self.timeMatchListNode_, {time = animTime, opacity = 255, delay = animTime*5})
    elseif selectedTab == ChooseMatchRoomViewEEx.MATCH_TYPE_NORMAL then
        -- transition.fadeIn(self.normalMatchListNode_, {time = animTime, opacity = 255, delay = animTime*5})
    elseif selectedTab == ChooseMatchRoomViewEEx.MATCH_TYPE_OTHER then

    end
end

function ChooseMatchRoomViewEEx:playHideAnim()
    self:removeFromParent()
end

function ChooseMatchRoomViewEEx:playSuonaMsgScrolling()
    -- body
    if not self.suonaMsgPlaying_ then
        --todo
        self:playSuonaMsgNext()
    end
end

function ChooseMatchRoomViewEEx:playSuonaMsgNext()
    -- body
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

function ChooseMatchRoomViewEEx:onReturnClick_()
    self.controller_:showMainHallView()
end

function ChooseMatchRoomViewEEx:onHelpClick_()
	if ChooseMatchRoomViewEEx.MATCH_TYPE_SELECTED == ChooseMatchRoomViewEEx.MATCH_TYPE_NORMAL then
		HelpPopup_1.new():show()
	else
		HelpPopup_2.new(false, true, 2):show()
	end
    
end

function ChooseMatchRoomViewEEx:onFeedbackClick_()
    HelpPopup_2.new(false, true,1):show()
end


function ChooseMatchRoomViewEEx:onFoldBtnClick_()
    self.isFold_ =  (self.isFold_ == false) and true or false
    self:setShowFoldBtn(self.isFold_,true)
    self:setShowBottomIcon(self.isFold_,true)

end

function ChooseMatchRoomViewEEx:onScoreMarektClick_()
    display.addSpriteFrames("scoreMarket_th.plist", "scoreMarket_th.png", function()
             ScoreMarketView.new():show()
        end)
end

function ChooseMatchRoomViewEEx:onAuctionMarketClk_()
    -- body
    AuctionMarketPopup.new():showPanel_()
end


function ChooseMatchRoomViewEEx:onSearchPanelCallback(roomId)
    -- dump(roomId,"ChooseMatchRoomViewEEx:onSearchPanelCallback")
    local roomData = {}
    roomData.roomid = roomId--26280117
    bm.EventCenter:dispatchEvent({name = nk.eventNames.ENTER_ROOM_WITH_DATA, data = roomData})
end

function ChooseMatchRoomViewEEx:onStoreClick_()
    StorePopup.new(2):showPanel()
end

function ChooseMatchRoomViewEEx:getMatchPlayerCountData(data, field)

    -- dump(data,"getMatchPlayerCountData")

    --如果配置有更新，重新加载
    -- if isset(data,"configUrl") and (nk.userData.MATCH_JSON ~= data["configUrl"]) then
    --     nk.userData.MATCH_JSON = data["configUrl"]
    --     self.setOnlineNumRequest_ = function()
    --         self:onUpdateNormalMatchPlayerNum(data)
    --     end
    --     nk.MatchConfig:loadConfig(nk.userData.MATCH_JSON,handler(self,self.onLoadNormalMatchConfigNew))  
    -- else
        if isset(data,"onlinePeople") then
            local onlineData = data["onlinePeople"]
            if onlineData then
                 local desData = {}
                for k,v in pairs(onlineData) do
                    desData[(tonumber(k))] = checkint(v)
                end
                self:onUpdateNormalMatchPlayerNum(desData)
            end
        end
    -- end

end


function ChooseMatchRoomViewEEx:setShowFoldBtn(isFold,isAnim)
    if isFold then
        self.foldBtn_:setScaleX(-1)
        if isAnim then
            transition.moveTo(self.foldBtn_,{x = foldBtnStartPos.x,y = foldBtnStartPos.y,time = 0.4})
        else
            self.foldBtn_:pos(foldBtnStartPos.x,foldBtnStartPos.y)
        end
    else
        self.foldBtn_:setScaleX(1)
        if isAnim then
            transition.moveTo(self.foldBtn_,{x = foldBtnEndPos.x,y = foldBtnEndPos.y,time = 0.4})
        else
            self.foldBtn_:pos(foldBtnEndPos.x,foldBtnEndPos.y)
        end
    end
end

function ChooseMatchRoomViewEEx:setShowBottomIcon(isFold,isAnim)
    if isFold then
        if isAnim then
            transition.moveTo(self.bottomStencil_,{x = self.maskStartX_,time = 0.4})
        else
            self.bottomStencil_:pos(self.maskStartX_,0)
        end
    else
        if isAnim then
            transition.moveTo(self.bottomStencil_,{x = maskEndX,time = 0.4})
        else
            self.bottomStencil_:pos(maskEndX,0)
        end
    end
end

function ChooseMatchRoomViewEEx:getMatchHallInfo()
    local retryLimit = 3
    local loadConfigFunc
    requestFun = function()
            self.requestMatchInfoId_ = nk.http.matchHallInfo(function(data)
                self.requestMatchInfoId_ = nil
               if checkint(data.money) < 100000 then
                    self.moneyLabel_:setString(bm.formatNumberWithSplit(checkint(data.money)))
                else
                    self.moneyLabel_:setString(bm.formatBigNumber(checkint(data.money)))
                end
                nk.userData["match.point"] = checkint(data.point)
                self.cashLabel_:setString(bm.formatBigNumber(nk.userData["match.point"]))
                nk.userData["match.highPoint"] = checkint(data.highPoint)
                self.clubLabel_:setString(bm.formatBigNumber(nk.userData["match.highPoint"]))
                local tickets = data.tickets
                for i=1,#tickets do
                    local item = tickets[i]
                    if item.pnid == "7101" then
                        self.normalTicketLabel_:setString(item.pcnter)
                    elseif item.pnid == "7104" then
                        self.specialTicketLabel_:setString(item.pcnter)

                    elseif item.pnid == "7102" then
                        self.chujiTicketLabel_:setString(item.pcnter)
                    end

                    local tickKey = "match.ticket_" .. item.pnid
                    nk.userData[tickKey] = checkint(item.pcnter)
                    -- dump(nk.userData[tickKey],"getMatchHallInfo=========")
                end

            end,function(errData)
                self.requestMatchInfoId_ = nil
                retryLimit = retryLimit - 1
                if retryLimit > 0 then
                    nk.schedulerPool:delayCall(function()
                        requestFun()
                    end, 1)
                else
                   
                end

            end)
    end

    requestFun()
end




function ChooseMatchRoomViewEEx:reportUmeng_(command,args)
    -- if device.platform == "android" or device.platform == "ios" then  
    --         cc.analytics:doCommand{
    --                     command = command,
    --                     args = args
    --                 }
    --     end 
end

function ChooseMatchRoomViewEEx:addDataObservers()
    self.avatarUrlObserverHandle_ = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "aUser.micon", handler(self, function (obj, micon)
        if not micon or string.len(micon) <= 5 then
            if nk.userData["aUser.msex"] == 2 or nk.userData["aUser.msex"] == 0 then
                self:onAvatarLoadComplete_(true, display.newSprite("#common_female_avatar.png"))
            else
                self:onAvatarLoadComplete_(true, display.newSprite("#common_male_avatar.png"))
            end
        else
            local imgurl = micon
            -- dump(imgurl,"fuckmicon")
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
                    nk.ImageLoader.CACHE_TYPE_USER_HEAD_IMG
                )
        end
        
    end))


    if not self.appForegroundListenerId_ then
        self.appForegroundListenerId_ = bm.EventCenter:addEventListener(nk.eventNames.APP_ENTER_FOREGROUND, handler(self, self.onEnterForeground_))
    end

    if not self.timeMatchOpenListenerId_ then
        self.timeMatchOpenListenerId_ = bm.EventCenter:addEventListener(nk.eventNames.TIME_MATCH_OPEN, handler(self, self.onTimeMatchOpen_))
    end


    self.moneyObserverHandle_ = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "aUser.money", handler(self, function (obj, money)
        if obj and obj.moneyLabel_ then

             if money < 100000 then
                obj.moneyLabel_:setString(bm.formatNumberWithSplit(money))
            else
                obj.moneyLabel_:setString(bm.formatBigNumber(money))
            end

        end
        
    end))


    self.cashObserverHandle_ = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "match.point", handler(self, function (obj, point)
        if obj and obj.cashLabel_ then
            obj.cashLabel_:setString(bm.formatBigNumber(point))
        end
        
    end))


    for _,v in pairs(TICKETS_IDS) do
        local propertyKey = string.format("match.ticket_%s",v)
        local ticketObserverHandle = string.format("ticket_%s_handle_",v)
        self[ticketObserverHandle] = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, propertyKey, handler(self, function (obj, pcnter)
        if pcnter then
            if v == 7101 then
                self.normalTicketLabel_:setString(pcnter)
            elseif v == 7104 then
                self.specialTicketLabel_:setString(pcnter)

            elseif v == 7102 then
                self.chujiTicketLabel_:setString(pcnter)
            end

        end
        
        end))

    end

end


function ChooseMatchRoomViewEEx:onEnterForeground_()
    --切后台回来更新比赛场列表显示
    dump(os.time(),"ChooseMatchRoomViewEEx:onEnterForeground_")
    nk.MatchConfigEx:loadConfig(nil,handler(self,self.onLoadMatchConfig),true)
end

function ChooseMatchRoomViewEEx:onTimeMatchOpen_()

    dump("onTimeMatchOpen_-TIME_MATCH_OPEN")
    nk.MatchConfigEx:loadConfig(nil,handler(self,self.onLoadMatchConfig))
end


function ChooseMatchRoomViewEEx:onAvatarLoadComplete_(success, sprite)
     if success then
        local oldAvatar = self.bottomNode_:getChildByTag(AVATAR_TAG)
        if oldAvatar then
            oldAvatar:removeFromParent()
        end
        -- local tex = sprite:getTexture()
        -- local texSize = tex:getContentSize()

        --if self and self.avatar_ then
            --todo
           -- dump("imgurl","fuckmicon")
            -- self.avatar_:setTexture(tex)
            -- self.avatar_:setTextureRect(cc.rect(0, 0, texSize.width, texSize.height))
            -- self.avatar_:setScaleX(35 / texSize.width)
            -- self.avatar_:setScaleY(35 / texSize.height)

            local sprSize = sprite:getContentSize()
            if sprSize.width > sprSize.height then
                sprite:scale(35 / sprSize.width)
            else
                sprite:scale(35 / sprSize.height)
            end
            sprite:align(display.LEFT_CENTER, - display.width / 2 + 20,- 23)
                :addTo(self.bottomNode_, 0, AVATAR_TAG)
            
       -- end
       -- self.avatarLoaded_ = true
    end
end

function ChooseMatchRoomViewEEx:removeDataObserver()
    bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "aUser.micon", self.avatarUrlObserverHandle_)
    if self.appForegroundListenerId_ then
        bm.EventCenter:removeEventListener(self.appForegroundListenerId_)
        self.appForegroundListenerId_ = nil
    end

    if self.timeMatchOpenListenerId_ then
        bm.EventCenter:removeEventListener(self.timeMatchOpenListenerId_)
        self.timeMatchOpenListenerId_ = nil
    end


    for _,v in pairs(TICKETS_IDS) do
        local propertyKey = string.format("match.ticket_%s",v)
        local ticketObserverHandle = string.format("ticket_%s_handle_",v)
        bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, propertyKey, self[ticketObserverHandle])
    end

    bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "aUser.money", self.moneyObserverHandle_)
    bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "match.point", self.cashObserverHandle_)
end


function ChooseMatchRoomViewEEx:buyTicket_()

     StorePopup.new(2):showPanel()
    -- local payGuideShownType = 1
    -- local isShowPay = nk.OnOff:check("payGuide")
    -- local isThirdPayOpen = isShowPay
    -- local isFirstCharge = nk.userData.best.paylog == 0 or false
    -- local payBillType = nil
    -- local isMatchTicketGoods = true

    -- if nk.OnOff:check("firstchargeFavGray") and isThirdPayOpen and isFirstCharge then
    --     --todo
    --     FirChargePayGuidePopup.new():showPanel()
    -- else
    --     local params = {}

    --     params.isOpenThrPartyPay = isThirdPayOpen
    --     params.isFirstCharge = isFirstCharge
    --     params.sceneType = payGuideShownType
    --     params.payListType = payBillType
    --     params.isMatchTicket = isMatchTicketGoods

    --     PayGuide.new(params):show()
    -- end
end


function ChooseMatchRoomViewEEx:onCleanup()

    -- nk.MatchConfig:cancel()
    if self.suonaMsgScrollAnim_ then
        --todo
        self:stopAction(self.suonaMsgScrollAnim_)
    end

    if self.suonaDelayCallHandler_ then
        --todo
        nk.schedulerPool:clear(self.suonaDelayCallHandler_)
    end

    nk.http.cancel(self.requestMatchInfoId_)
    nk.MatchConfigEx:cancel()

    self:removeDataObserver()
end

return ChooseMatchRoomViewEEx