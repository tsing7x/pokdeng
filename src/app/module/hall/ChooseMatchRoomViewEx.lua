-- --
-- -- Author: Johnny Lee
-- -- Date: 2014-08-07 23:22:07
-- -- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
-- --

-- local StorePopup = import("app.module.newstore.StorePopup")
-- local HelpPopup = import("app.module.settingAndhelp.SettingAndHelpPopup")
-- local HallSearchRoomPanel = import("app.module.hall.HallSearchRoomPanel")
-- local PayGuide = import("app.module.room.purchGuide.PayGuide")
-- local FirChargePayGuidePopup = import("app.module.newstore.firChrgGuide.FirChrgPayGuidePopup")
-- local ScoreMarketView = import("app.module.scoreMarket.ScoreMarketView")
-- local ChooseMatchRoomListItem = import(".ChooseMatchRoomListItem")
-- local SuonaUsePopup = import("app.module.suona.SuonaUsePopup")
-- local MatchTimeRegisterPopup = import("app.module.match.views.MatchTimeRegisterPopup")
-- local ChooseMatchRoomViewEx = class("ChooseMatchRoomViewEx", function ()
--     return display.newNode()
-- end)

-- local ChooseRoomChip = import(".ChooseRoomChip")
-- local ChooseGrabRoomView = import(".ChooseGrabRoomView")
-- local AVATAR_TAG = 100

-- ChooseMatchRoomViewEx.PLAYER_LIMIT_SELECTED = 1 -- 1：9人场；2：5人场
-- ChooseMatchRoomViewEx.ROOM_LEVEL_SELECTED   = nil -- 1：初级场；2：中级场；3：高级场

-- local ROOM_TYPE_NOR = 1
-- local ROOM_TYPE_PRO = 2
-- local TOP_BUTTOM_WIDTH   = 78
-- local TOP_BUTTOM_HEIGHT  = 64
-- local TOP_BUTTOM_PADDING = 8
-- local TOP_TAB_BAR_WIDTH  = 612
-- local TOP_TAB_BAR_HEIGHT = 66
-- local CHIP_HORIZONTAL_DISTANCE = 240 * nk.widthScale
-- local CHIP_VERTICAL_DISTANCE   = 216 * nk.heightScale

-- -- local PayGuide = import("app.module.room.purchGuide.PayGuide")
-- -- local FirChargePayGuidePopup = import("app.module.newstore.firChrgGuide.FirChrgPayGuidePopup")

-- function ChooseMatchRoomViewEx:ctor(controller, viewType)
--     self.controller_ = controller
--     self.controller_:setDisplayView(self)
--     if viewType == controller.CHOOSE_NOR_VIEW then
--         self.roomType_ = ROOM_TYPE_NOR
--         self.roomTypeIcon_ = display.newSprite("#choose_room_nor_icon.png")
--     else
--         self.roomType_ = ROOM_TYPE_PRO
--         self.roomTypeIcon_ = display.newSprite("#choose_room_pro_icon.png")
--     end

--     self:setNodeEventEnabled(true)

--     --[[
--         桌子背景
--     ]]
   
--     -- 桌子
--     self.pokerTable_ = display.newNode():pos(0, -(display.cy + 146)):addTo(self):scale(self.controller_:getBgScale())
--     local tableLeft = display.newSprite("#main_hall_table.png"):addTo(self.pokerTable_)
--     tableLeft:setAnchorPoint(cc.p(1, 0.5))
--     tableLeft:pos(2, 0)
--     local tableRight = display.newSprite("#main_hall_table.png"):addTo(self.pokerTable_)
--     tableRight:setScaleX(-1)
--     tableRight:setAnchorPoint(cc.p(1, 0.5))
--     tableRight:pos(-2, 0)

--     self.roomTypeIcon_:align(display.LEFT_CENTER, -(display.cx + self.roomTypeIcon_:getContentSize().width), -CHIP_VERTICAL_DISTANCE * 0.5 + 40 * nk.heightScale)
--         :addTo(self)

--     -- 分割线
--     self.splitLine_ = display.newSprite("#choose_room_split_line.png")
--         :pos(0, display.cy - 176)
--         :opacity(0)
--         :addTo(self)
--     self.splitLine_:setScaleX(nk.widthScale * 0.9)


   
--     --[[
--         顶部操作按钮
--     ]] 
--     self.topBtnNode_ = display.newNode()
--         :pos(0, TOP_BUTTOM_HEIGHT + TOP_TAB_BAR_HEIGHT + TOP_BUTTOM_PADDING)
--         :addTo(self)
--     -- 返回
--     display.newScale9Sprite("#top_btn_bg.png", 0, 0, cc.size(TOP_BUTTOM_WIDTH + 4, TOP_BUTTOM_HEIGHT + 4))
--         :pos(-display.cx + TOP_BUTTOM_WIDTH * 0.5 + TOP_BUTTOM_PADDING, display.cy - TOP_BUTTOM_HEIGHT * 0.5 - TOP_BUTTOM_PADDING)
--         :addTo(self.topBtnNode_)
--     display.newSprite("#hall_top_return_icon_up.png")
--         :pos(-display.cx + TOP_BUTTOM_WIDTH * 0.5 + TOP_BUTTOM_PADDING, display.cy - TOP_BUTTOM_HEIGHT * 0.5 - TOP_BUTTOM_PADDING)
--         :addTo(self.topBtnNode_)
--     cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#rounded_rect_6.png"}, {scale9 = true})
--         :setButtonSize(TOP_BUTTOM_WIDTH, TOP_BUTTOM_HEIGHT)
--         :pos(-display.cx + TOP_BUTTOM_WIDTH * 0.5 + TOP_BUTTOM_PADDING, display.cy - TOP_BUTTOM_HEIGHT * 0.5 - TOP_BUTTOM_PADDING)
--         :addTo(self.topBtnNode_)
--         :onButtonClicked(buttontHandler(self, self.onReturnClick_))

--     -- 帮助
--     cc.ui.UIPushButton.new({normal = "#check_match_info_btn_up.png", pressed = "#check_match_info_btn_down.png"})
--         :pos(-display.cx + TOP_BUTTOM_WIDTH * 0.5 + TOP_BUTTOM_PADDING, display.cy - TOP_BUTTOM_HEIGHT * 0.5 - TOP_BUTTOM_PADDING - 90)
--         :addTo(self.topBtnNode_)
--         :onButtonClicked(buttontHandler(self, self.onHelpClick_))

--     -- 反馈
--     display.newScale9Sprite("#top_btn_bg.png", 0, 0, cc.size(TOP_BUTTOM_WIDTH + 4, TOP_BUTTOM_HEIGHT + 4))
--         :pos(display.cx - TOP_BUTTOM_WIDTH * 1.5 - TOP_BUTTOM_PADDING * 2, display.cy - TOP_BUTTOM_HEIGHT * 0.5 - TOP_BUTTOM_PADDING)
--         :addTo(self.topBtnNode_)
--     display.newSprite("#feedback_hall_icon_up.png")
--         :pos(display.cx - TOP_BUTTOM_WIDTH * 1.5 - TOP_BUTTOM_PADDING * 2, display.cy - TOP_BUTTOM_HEIGHT * 0.5 - TOP_BUTTOM_PADDING)
--         :addTo(self.topBtnNode_)
--         :scale(0.88)
--     cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#rounded_rect_6.png"}, {scale9 = true})
--         :setButtonSize(TOP_BUTTOM_WIDTH, TOP_BUTTOM_HEIGHT)
--         :pos(display.cx - TOP_BUTTOM_WIDTH * 1.5 - TOP_BUTTOM_PADDING * 2, display.cy - TOP_BUTTOM_HEIGHT * 0.5 - TOP_BUTTOM_PADDING)
--         :addTo(self.topBtnNode_)
--         :onButtonClicked(buttontHandler(self, self.onFeedbackClick_))
   
--     --积分商城
--      display.newScale9Sprite("#top_btn_bg.png", 0, 0, cc.size(TOP_BUTTOM_WIDTH + 4, TOP_BUTTOM_HEIGHT + 4))
--             :pos(display.cx - TOP_BUTTOM_WIDTH * 0.5 - TOP_BUTTOM_PADDING, display.cy - TOP_BUTTOM_HEIGHT * 0.5 - TOP_BUTTOM_PADDING)
--             :addTo(self.topBtnNode_)

--         display.newSprite("#market_hall_icon_up.png")
--             :pos(display.cx - TOP_BUTTOM_WIDTH * 0.5 - TOP_BUTTOM_PADDING, display.cy - TOP_BUTTOM_HEIGHT * 0.5 - TOP_BUTTOM_PADDING)
--             :addTo(self.topBtnNode_)

--         cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#rounded_rect_6.png"}, {scale9 = true})
--             :setButtonSize(TOP_BUTTOM_WIDTH, TOP_BUTTOM_HEIGHT)
--             :pos(display.cx - TOP_BUTTOM_WIDTH * 0.5 - TOP_BUTTOM_PADDING, display.cy - TOP_BUTTOM_HEIGHT * 0.5 - TOP_BUTTOM_PADDING)
--             :addTo(self.topBtnNode_)
--             :onButtonClicked(buttontHandler(self, self.onStoreClick_))



   

--     --默认场次类别
--     -- local aUserMoney = nk.userData["aUser.money"]
--     -- if aUserMoney < 10000000 then
--     --     nk.userData.DEFAULT_TAB = 1
--     -- else
--     --     nk.userData.DEFAULT_TAB = 2
--     -- end

--     -- if aUserMoney>= 2000000 then
--     --     nk.userData.DEFAULT_TAB  = 3 
--     -- else
--     --     nk.userData.DEFAULT_TAB  = 1
--     -- end

--     -- if nk.OnOff:check("grabDealerOpen")==false then
--     --     nk.userData.DEFAULT_TAB  = 1
--     -- end

--     -- ChooseMatchRoomViewEx.ROOM_LEVEL_SELECTED = nk.userData.DEFAULT_TAB 


--     -- 顶部tab bar
--     if ChooseMatchRoomViewEx.ROOM_LEVEL_SELECTED == nil then 
--         -- ChooseMatchRoomViewEx.ROOM_LEVEL_SELECTED = nk.userData.DEFAULT_TAB or 1
--     end
   
--     -- if  bm.DataProxy:getData(nk.dataKeys.ROOM_LIST_SELECT_TYPE) == 3 then
--     --     ChooseMatchRoomViewEx.ROOM_LEVEL_SELECTED = 3
--     -- end

--     if nk.userData.TAB_SETING then
--         ChooseMatchRoomViewEx.ROOM_LEVEL_SELECTED = nk.userData.TAB_SETING
--         nk.userData.TAB_SETING = nil
--     end

--     --612 * 69
--     local bgNode = display.newBatchNode("hall_texture.png", 140)
--     bgNode:setContentSize(612, 69)
--     local beginX = -66 * 4  - 2
--     for i = 1, 134 do
--         display.newSprite("#choose_room_level_tab_bar_bg_middle.png", beginX + 4 * (i - 1), 0):addTo(bgNode)
--     end
--     display.newSprite("#choose_room_level_tab_bar_bg_left.png"):pos(612 * -0.5, 0):addTo(bgNode):setAnchorPoint(cc.p(0, 0.5))
--     display.newSprite("#choose_room_level_tab_bar_bg_right.png"):pos(612 * 0.5, 0):addTo(bgNode):setAnchorPoint(cc.p(1, 0.5))

   
--     -- self.chipBtnNode_ = display.newNode()
--     --     :addTo(self)

   
--     self.grabDealerNode_ = ChooseGrabRoomView.new(self.controller_)
--         :addTo(self)
--         :hide()

--    -- 一级tab bar
--     self.mainTabBar_ = nk.ui.CommonPopupTabBar.new(
--         {
--             popupWidth = display.width-230, 
--             iconOffsetX = 10, 
--             iconTexture = {
--                 {"#hot_room_tab_icon_selected.png", "#hot_room_tab_icon_unselected.png"}, 
--                 {"#nor_room_tab_icon_selected.png", "#nor_room_tab_icon_unselected.png"}, 
--                 {"#wait_tab_icon_selected.png", "#wait_tab_icon_unselected.png"}
--             }, 
--             btnText = bm.LangUtil.getText("HALL", "ROOM_LIST_TAB_TEXT"), 
--         }
--     )
--        :pos(-20, display.cy  - TOP_TAB_BAR_HEIGHT * 0.5-2)
--         :addTo(self.topBtnNode_)

--     --系统提示
--     local systemTipWidth = 614
--     local systemTipHeight = 51 --也是小喇叭的宽度
--     -- display.newScale9Sprite("#hall_system_info_bg.png",0,0,cc.size(systemTipWidth,systemTipHeight))
--     -- :addTo(self.topBtnNode_)
--     -- :pos(-20,display.cy  - TOP_TAB_BAR_HEIGHT * 0.5-95)

--     -- display.newSprite("#hall_system_info_icon.png")
--     -- :addTo(self.topBtnNode_)
--     -- :pos(-20-systemTipWidth/2+systemTipHeight/2,display.cy  - TOP_TAB_BAR_HEIGHT * 0.5-95)

--     -- self.sysMsgLabel_ = display.newTTFLabel({text = "系统通知.....", color = styles.FONT_COLOR.LIGHT_TEXT, size = 20, align = ui.TEXT_ALIGN_LEFT,dimensions = cc.size(systemTipWidth-systemTipHeight, 30)})
--     -- :addTo(self.topBtnNode_)
--     -- :align(display.LEFT_CENTER)
--     -- :pos(-20-systemTipWidth/2+systemTipHeight+20,display.cy  - TOP_TAB_BAR_HEIGHT * 0.5-95)

--      local bordCastMsgShownPanel = display.newScale9Sprite("#hall_system_info_bg.png", 0, 0, cc.size(systemTipWidth, systemTipHeight))
--         :addTo(self.topBtnNode_)
--         :pos(- 20, display.cy  - TOP_TAB_BAR_HEIGHT * 0.5 - 95)

--     local suonaIcon = display.newSprite("#hall_system_info_icon.png")
--         :addTo(self.topBtnNode_)
--         :pos(- 20 - systemTipWidth / 2 + systemTipHeight / 2, display.cy  - TOP_TAB_BAR_HEIGHT * 0.5 - 95)

--     local suonaIconSize = suonaIcon:getContentSize()

--     local sendBordCBtnSize = {
--         width = 128,
--         height = 54
--     }

--     local btnSendLabelParam = {
--         frontSize = 24,
--         color = display.COLOR_WHITE
--     }

--     self.btnSendBordCast_ = cc.ui.UIPushButton.new({normal = "#common_btnGreenCor_nor.png", pressed = "#common_btnGreenCor_pre.png", disabled = "#common_btnGreenCor_nor.png"},
--         {scale9 = true})
--         :setButtonSize(sendBordCBtnSize.width, sendBordCBtnSize.height)
--         :setButtonLabel(display.newTTFLabel({text = bm.LangUtil.getText("COMMON", "SEND"), size = btnSendLabelParam.frontSize, color = btnSendLabelParam.color, align = ui.TEXT_ALIGN_CENTER}))
--         :onButtonClicked(buttontHandler(self, self.onSendBordBtnCallBack_))
--         :pos(systemTipWidth / 2 - sendBordCBtnSize.width / 2 - 20, display.cy  - TOP_TAB_BAR_HEIGHT * 0.5 - 96)
--         :addTo(self.topBtnNode_)

--     local suonaMsgClipNodeMagrinHoriz = 5
--     local suonaMsgClipNodeCrosRightBtnWidth = sendBordCBtnSize.width / 2 + 62

--     local suonaMsgLabelStencil = display.newDrawNode()
--     suonaMsgLabelStencil:drawPolygon({
--         {- systemTipWidth / 2 + suonaIconSize.width + suonaMsgClipNodeMagrinHoriz, - systemTipHeight / 2}, 
--         {- systemTipWidth / 2 + suonaIconSize.width + suonaMsgClipNodeMagrinHoriz,  systemTipHeight / 2}, 
--         {systemTipWidth / 2 - suonaMsgClipNodeCrosRightBtnWidth - suonaMsgClipNodeMagrinHoriz,  systemTipHeight / 2}, 
--         {systemTipWidth / 2 - suonaMsgClipNodeCrosRightBtnWidth - suonaMsgClipNodeMagrinHoriz, - systemTipHeight / 2}
--     })

--     local suonaMsgClipNode = cc.ClippingNode:create()
--         :pos(systemTipWidth / 2, systemTipHeight / 2)
--         :addTo(bordCastMsgShownPanel)
--     suonaMsgClipNode:setStencil(suonaMsgLabelStencil)

--     -- local bordCastMsgLabelMagrinRight = 10
--     self.bordCastMsg_ = display.newTTFLabel({text = bm.LangUtil.getText("HALL", "CHOOSE_ROOM_SUONA_USE_TIP"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 22, align = ui.TEXT_ALIGN_CENTER})

--     self.bordCastMsg_:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER_LEFT])
--         -- :align(display.LEFT_CENTER)
--     self.bordCastMsg_:pos(systemTipWidth / 2 - suonaMsgClipNodeCrosRightBtnWidth - suonaMsgClipNodeMagrinHoriz - self.bordCastMsg_:getContentSize().width,
--         0)
--         :addTo(suonaMsgClipNode)

--     self.bordCastMsgStartX_ = systemTipWidth / 2 - suonaMsgClipNodeCrosRightBtnWidth - suonaMsgClipNodeMagrinHoriz
--     self.bordCastMsgDesX_ = - systemTipWidth / 2 + suonaIconSize.width + suonaMsgClipNodeMagrinHoriz

--     self.roomListNode_ = display.newNode()
--     :addTo(self)

--     self.list_ = bm.ui.ListView.new(
--         {
--             viewRect = cc.rect(-(display.width-40) * 0.5, -360 * 0.5, (display.width-40), 360)
--         }, 
--         ChooseMatchRoomListItem
--     )
--     :pos(0, -70)
--     :addTo(self.roomListNode_)
    
--     self.list_:addEventListener("ITEM_EVENT",handler(self,self.onChipClick))
--     --self.list_.controller_ = self.controller_

--     --底部
--     self.buttom_Node_ = display.newSprite()
--     :addTo(self)
--     :pos(0,-display.height)

--     local BUTTOM_BG_H = 45
--     display.newScale9Sprite("#hall_chooseView_buttom_bg.png",0,0,cc.size(display.width,BUTTOM_BG_H))
--     :addTo(self.buttom_Node_)
--     :pos(0,-BUTTOM_BG_H/2)

--      -- 头像加载id
--     self.userAvatarLoaderId_ = nk.ImageLoader:nextLoaderId()
--     -- 默认头像
--     self.avatar_ = display.newSprite("#common_transparent_skin.png")
--     self.avatar_:addTo(self.buttom_Node_)
--     self.avatar_:align(display.LEFT_CENTER)
--     self.avatar_:pos(-display.width/2+20,-23)

--     local pos_y = -23 --底部元素y值
--     local icon_gap = 125 --底部icon间隔
--     local start_x = -display.width/2+100 --底部icon起点值
--     local buttom_Txt_width = 100 --底部文本宽度
--     local txt_left_icon = 15 --底部文本相对icon偏移值

--     display.newSprite("#hall_small_chip_icon.png")
--     :addTo(self.buttom_Node_)
--     :pos(start_x,pos_y)

--     display.newSprite("#hall_small_cash_icon.png")
--     :addTo(self.buttom_Node_)
--     :pos(start_x+icon_gap,pos_y)

--     display.newSprite("#hall_small_ticket_7101.png")
--     :addTo(self.buttom_Node_)
--     :pos(start_x+2*icon_gap,pos_y)

--     display.newSprite("#hall_small_ticket_7104.png")
--     :addTo(self.buttom_Node_)
--     :pos(start_x+3*icon_gap,pos_y)

--     display.newSprite("#hall_small_c_cion.png")
--     :addTo(self.buttom_Node_)
--     :pos(start_x+4*icon_gap,pos_y)

--     --金币
--     self.moneyLabel_ = display.newTTFLabel({text = "0", color = cc.c3b(0xff,0xff,0xff),dimensions = cc.size(buttom_Txt_width, 30), size = 20, align = ui.TEXT_ALIGN_LEFT})
--     :align(display.LEFT_CENTER)
--     :addTo(self.buttom_Node_)
--     :pos(start_x+txt_left_icon,pos_y)
--     --现金币
--     self.cashLabel_ = display.newTTFLabel({text = "0", color = cc.c3b(0xe1,0xc8,0x02),dimensions = cc.size(buttom_Txt_width, 30), size = 20, align = ui.TEXT_ALIGN_LEFT})
--     :align(display.LEFT_CENTER)
--     :addTo(self.buttom_Node_)
--     :pos(start_x+icon_gap+txt_left_icon,pos_y)
--     --普通门票
--     self.normalTicketLabel_ = display.newTTFLabel({text = "0", color = cc.c3b(0xe1,0xc8,0x02),dimensions = cc.size(buttom_Txt_width, 30), size = 20, align = ui.TEXT_ALIGN_LEFT})
--     :align(display.LEFT_CENTER)
--     :addTo(self.buttom_Node_)
--     :pos(start_x+2*icon_gap+txt_left_icon + 10,pos_y)
--     --通用门票
--     self.specialTicketLabel_ = display.newTTFLabel({text = "0", color = cc.c3b(0xe1,0xc8,0x02),dimensions = cc.size(buttom_Txt_width, 30), size = 20, align = ui.TEXT_ALIGN_LEFT})
--     :align(display.LEFT_CENTER)
--     :addTo(self.buttom_Node_)
--     :pos(start_x+3*icon_gap+txt_left_icon+ 10,pos_y)
--     --奖杯数量
--     self.clubLabel_ = display.newTTFLabel({text = "0", color = cc.c3b(0x92,0xdc,0x5f),dimensions = cc.size(buttom_Txt_width, 30), size = 20, align = ui.TEXT_ALIGN_LEFT})
--     :align(display.LEFT_CENTER)
--     :addTo(self.buttom_Node_)
--     :pos(start_x+4*icon_gap+txt_left_icon,pos_y)

--     if nk.userData["aUser.money"] < 100000 then
--         self.moneyLabel_:setString(bm.formatNumberWithSplit(nk.userData["aUser.money"]))
--     else
--         self.moneyLabel_:setString(bm.formatBigNumber(nk.userData["aUser.money"]))
--     end
--     self.cashLabel_:setString(bm.formatBigNumber(nk.userData["match.point"]))

--     local yellowBtnWidth = 148
--     local yellowBtnHeight = 42
--     self.buyTicketNode_ = display.newNode():addTo(self.buttom_Node_)
--     :pos(display.width/2-yellowBtnWidth+45,pos_y)

--     display.newScale9Sprite("#hall_choose_yellow_btn.png",0,0,cc.size(yellowBtnWidth,yellowBtnHeight))
--     :addTo(self.buyTicketNode_)
--     display.newSprite("#hall_small_ticket_7104.png")
--     :addTo(self.buyTicketNode_)
--     :pos(-40,0)

--     display.newTTFLabel({text = bm.LangUtil.getText("COMMON", "BUY"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 20, align = ui.TEXT_ALIGN_CENTER})
--     :addTo(self.buyTicketNode_)
--     :pos(10,0)

--     cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#rounded_rect_10.png"}, {scale9 = true})
--     :setButtonSize(yellowBtnWidth-5, yellowBtnHeight)
--     :onButtonClicked(buttontHandler(self,self.buyTicket_))
--     :addTo(self.buyTicketNode_)

--     self.mainTabBar_:onTabChange(handler(self, self.onMainTabChange_))
--     self:addDataObservers()


--     nk.MatchConfigEx:loadConfig(nil,handler(self,self.onLoadMatchConfig))
-- end

-- function ChooseMatchRoomViewEx:playShowAnim()
--     local animTime = self.controller_.getAnimTime()
--     -- 桌子
--     transition.moveTo(self.pokerTable_, {time = animTime, y = 0})
--     -- icon
--     transition.moveTo(self.roomTypeIcon_, {time = animTime, x = -display.cx, delay = animTime})
--     -- 分割线
--     --transition.fadeIn(self.splitLine_, {time = animTime, opacity = 255, delay = animTime})
--     -- 在线人数
--     --transition.fadeIn(self.userOnline_, {time = animTime, opacity = 255, delay = animTime})
--     -- 顶部操作区
--     transition.moveTo(self.topBtnNode_, {time = animTime, y = 0, delay = animTime})

--     -- 顶部操作区
--     transition.moveTo(self.buttom_Node_, {time = animTime, y = -display.height/2 + 45, delay = animTime})
    
--     -- self.list_:setData({1,1,1,1,1,1})
    
-- end

-- function ChooseMatchRoomViewEx:playHideAnim()
--     self:removeFromParent()
-- end

-- function ChooseMatchRoomViewEx:onReturnClick_()
--     self.controller_:showMainHallView()
-- end

-- function ChooseMatchRoomViewEx:onHelpClick_()
--     HelpPopup.new(false, true, 2):show()
--     -- MatchTimeRegisterPopup.new():show()
-- end

-- function ChooseMatchRoomViewEx:onFeedbackClick_()
--     HelpPopup.new(false, true,1):show()
--     -- MatchTimeRegisterPopup.new():show()
-- end

-- function ChooseMatchRoomViewEx:onMainTabChange_(selectedTab)
    
-- end

-- function ChooseMatchRoomViewEx:onSearchPanelCallback(roomId)
   
-- end

-- function ChooseMatchRoomViewEx:onStoreClick_()
--     if self.scoreMarket_ then
--         self.scoreMarket_ = nil

--     end
--        display.addSpriteFrames("scoreMarket_th.plist", "scoreMarket_th.png", function()
--          self.scoreMarket_ = ScoreMarketView.new():show()
--     end)
-- end

-- function ChooseMatchRoomViewEx:_onChargeFavCallBack()
   
-- end

-- function ChooseMatchRoomViewEx:onGetPlayerCountData(data, field)
   
-- end

-- -- 顶部tab切换
-- function ChooseMatchRoomViewEx:onTopTabChange_(selectedTab)

-- end

-- -- 右侧tab切换
-- function ChooseMatchRoomViewEx:onRightTabChange_(selectedTab)
   
-- end

-- function ChooseMatchRoomViewEx:refreshFirstChargeFavEntryUi(isOpen)
   
-- end


-- function ChooseMatchRoomViewEx:updateSomeInfoByInterval()

--     if self.getMatchPeopleAction_ then
--         self:stopAction(self.getMatchPeopleAction_)
--         self.getMatchPeopleAction_ = nil
--     end

    
--     self.getMatchPeopleAction_ = self:schedule(function ()
--         if self.matchDatas_ and #self.matchDatas_ > 0 then
--             -- 定时刷新报名人数
--             dump("updateSomeInfoByInterval====")
--             self:getTimeMatchPlayerCountData(self.matchDatas_)
--         end
--     end, 30)

   
    
-- end


-- function ChooseMatchRoomViewEx:onLoadMatchConfig(isSuccess,matchsdata)


   
--     if isSuccess and matchsdata then
--         --test
--         local nowTime = os.date("%X")
--         dump(nowTime,"onLoadMatchConfig - nowTime")
--         local count = 2
--         local mlistData = nk.MatchConfigEx:findNextSomeTimeMatchs()
--         table.walk(mlistData, function(v, k)
--             -- 检查场次是否已经报过名
--             local regData = nk.MatchConfigEx:findRegisterMatchByIdAndTime(v.id,v.mtime.timestamp)
--             if regData then
--                 v.isReg = true
--             end
--         end)
--         table.sort(mlistData,function(t1,t2)
--             return t1.mtime.timestamp < t2.mtime.timestamp
--         end)

--        dump(mlistData,"mlistData")
--        self:onUpdateChipsBaseInfo(mlistData)


--        self:getTimeMatchPlayerCountData(mlistData)

--        self:updateSomeInfoByInterval()

--     else
--         self:onUpdateChipsBaseInfo({})
--     end
    
-- end



-- function ChooseMatchRoomViewEx:getTimeMatchPlayerCountData(listDatas)
--     local tb = {}

--     for _,v in pairs(listDatas) do
--         local id = tostring(v["id"])
--         if not tb[id] then
--             tb[id] = {}
--         end
--         table.insert(tb[id],tostring(v.mtime.timestamp))
--     end
--     self.controller_:getTimeMatchPlayerCountData(tb)
-- end

-- function ChooseMatchRoomViewEx:onUpdateChipsBaseInfo(mData)

--     self.matchDatas_ = mData

--     if self.list_ then
--         self.list_:setData(mData or {})
--     end
-- end


-- function ChooseMatchRoomViewEx:onGetTimeMatchPlayerCountData(datas)
--     self:updataOnlineNum(datas)
-- end


-- function ChooseMatchRoomViewEx:updataOnlineNum(datas)
--     dump(datas,"ChooseMatchRoomViewEx:updataOnlineNum")

--     local total = 0
--     for i, baseData in ipairs(self.matchDatas_) do  

--         local id = baseData["id"]  
--         local timestamp = baseData["mtime"]["timestamp"]
--         local onlineData = datas[tostring(id)]
--         local count = 0
--         if onlineData then
--             count = onlineData[tostring(timestamp)] or 0
           
--         else
--             count = math.floor(math.random(5,30))
--         end

--         baseData.playerCount = count
--         total = total + count
        
--         if self.list_ then
--             self.list_:updateData(i,baseData)
--         end
--     end
-- end


-- function ChooseMatchRoomViewEx:buyTicket_()

--     local isThirdPayOpen = nk.OnOff:check("payGuide")
--     local isFirstCharge = nk.userData.best.paylog == 0 or false

--     if nk.OnOff:check("firstchargeFavGray") and isThirdPayOpen and isFirstCharge then
--         --todo
--         FirChargePayGuidePopup.new():showPanel()
--     else
--         local params = {}

--         params.isOpenThrPartyPay = isThirdPayOpen
--         params.isFirstCharge = isFirstCharge
--         params.sceneType = 1
--         params.payListType = nil
--         params.isSellCashCoin = true

--         if isThirdPayOpen then
--             --todo
--             PayGuide.new(params):show()
--         else
--             local cashPaymentPageIdx = 2
--             StorePopup.new(cashPaymentPageIdx):showPanel()
--         end
--     end
-- end
-- -- 点击筹码play now指定条件场次
-- function ChooseMatchRoomViewEx:onChipClick(evt)
--     -- dump(evt,"onChipClick")
--     MatchTimeRegisterPopup.new(evt.data,handler(self,self.onRegisterCallback)):show()
-- end


-- function ChooseMatchRoomViewEx:onUpdateRegisterStatue()
    
-- end

-- function ChooseMatchRoomViewEx:onRegisterCallback(data)
--     -- {id = id,matchid = matchid,time = matchTime}
--     dump(data,"onRegisterCallback")
--     if self.matchDatas_ then
--         for i,v in ipairs(self.matchDatas_) do
--             if v.id == data.id and v.mtime.timestamp == data.time then
--                 --是否已报名标识
--                 v.isReg = true

--                 if self.list_ then
--                     self.list_:updateData(i,v)
--                 end

--             end
--         end
--     end
-- end

-- function ChooseMatchRoomViewEx:addDataObservers()
--     -- body
--     self.onChargeFavOnOffObserver = bm.DataProxy:addDataObserver(nk.dataKeys.CHARGEFAV_ONOFF, handler(self, self.refreshFirstChargeFavEntryUi))

--     self.avatarUrlObserverHandle_ = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "aUser.micon", handler(self, function (obj, micon)
--         if not micon or string.len(micon) <= 5 then
--             if nk.userData["aUser.msex"] == 2 or nk.userData["aUser.msex"] == 0 then
--                 self:onAvatarLoadComplete_(true, display.newSprite("#common_female_avatar.png"))
--             else
--                 self:onAvatarLoadComplete_(true, display.newSprite("#common_male_avatar.png"))
--             end
--         else
--             local imgurl = micon
--             dump(imgurl,"fuckmicon")
--                 if string.find(imgurl, "facebook") then
--                     if string.find(imgurl, "?") then
--                         imgurl = imgurl .. "&width=100&height=100"
--                     else
--                         imgurl = imgurl .. "?width=100&height=100"
--                     end
--                 end
                
--                 nk.ImageLoader:loadAndCacheImage(
--                     obj.userAvatarLoaderId_, 
--                     imgurl, 
--                     handler(obj, obj.onAvatarLoadComplete_), 
--                     nk.ImageLoader.CACHE_TYPE_USER_HEAD_IMG
--                 )
--         end
        
--     end))


--     if not self.appForegroundListenerId_ then
--         self.appForegroundListenerId_ = bm.EventCenter:addEventListener(nk.eventNames.APP_ENTER_FOREGROUND, handler(self, self.onEnterForeground_))
--     end

--     if not self.timeMatchOpenListenerId_ then
--         self.timeMatchOpenListenerId_ = bm.EventCenter:addEventListener(nk.eventNames.TIME_MATCH_OPEN, handler(self, self.onTimeMatchOpen_))
--     end

--     -- self.requestMatchInfoId_ = nk.http.matchHallInfo(
--     --     function(data)
--     --         -- self.moneyLabel_
--     --         -- self.cashLabel_
--     --         -- self.specialTicketLabel_
--     --         -- self.clubLabel_
--     --         -- self.normalTicketLabel_

--     --         if checkint(data.money) < 100000 then
--     --             self.moneyLabel_:setString(bm.formatNumberWithSplit(checkint(data.money)))
--     --         else
--     --             self.moneyLabel_:setString(bm.formatBigNumber(checkint(data.money)))
--     --         end
--     --         nk.userData["match.point"] = checkint(data.point)
--     --         self.cashLabel_:setString(bm.formatBigNumber(nk.userData["match.point"]))
--     --         nk.userData["match.highPoint"] = checkint(data.highPoint)
--     --         self.clubLabel_:setString(bm.formatBigNumber(nk.userData["match.highPoint"]))
--     --         local tickets = data.tickets
--     --         for i=1,#tickets do
--     --             local item = tickets[i]
--     --             if item.pnid == "7101" then
--     --                 self.normalTicketLabel_:setString(item.pcnter)
--     --             elseif item.pnid == "7104" then
--     --                 self.specialTicketLabel_:setString(item.pcnter)
--     --             end
--     --         end
--     --     end,
--     --     function(errordata)

--     --     end
--     -- )

--     self:getMatchHallInfo()
-- end


-- function ChooseMatchRoomViewEx:getMatchHallInfo()
--     local retryLimit = 3
--     local loadConfigFunc
--     requestFun = function()
--             self.requestMatchInfoId_ = nk.http.matchHallInfo(function(data)
--                 self.requestMatchInfoId_ = nil
--                if checkint(data.money) < 100000 then
--                     self.moneyLabel_:setString(bm.formatNumberWithSplit(checkint(data.money)))
--                 else
--                     self.moneyLabel_:setString(bm.formatBigNumber(checkint(data.money)))
--                 end
--                 nk.userData["match.point"] = checkint(data.point)
--                 self.cashLabel_:setString(bm.formatBigNumber(nk.userData["match.point"]))
--                 nk.userData["match.highPoint"] = checkint(data.highPoint)
--                 self.clubLabel_:setString(bm.formatBigNumber(nk.userData["match.highPoint"]))
--                 local tickets = data.tickets
--                 for i=1,#tickets do
--                     local item = tickets[i]
--                     if item.pnid == "7101" then
--                         self.normalTicketLabel_:setString(item.pcnter)
--                     elseif item.pnid == "7104" then
--                         self.specialTicketLabel_:setString(item.pcnter)
--                     end

--                     local tickKey = "match.ticket_" .. item.pnid
--                     nk.userData[tickKey] = checkint(item.pcnter)
--                     dump(nk.userData[tickKey],"getMatchHallInfo=========")
--                 end

--             end,function(errData)
--                 self.requestMatchInfoId_ = nil
--                 retryLimit = retryLimit - 1
--                 if retryLimit > 0 then
--                     nk.schedulerPool:delayCall(function()
--                         requestFun()
--                     end, 1)
--                 else
                   
--                 end

--             end)
--     end

--     requestFun()
-- end


-- function ChooseMatchRoomViewEx:onTimeMatchOpen_()
--     nk.MatchConfigEx:loadConfig(nil,handler(self,self.onLoadMatchConfig))
-- end

-- function ChooseMatchRoomViewEx:onAvatarLoadComplete_(success, sprite)
--      if success then
--         local oldAvatar = self:getChildByTag(AVATAR_TAG)
--         if oldAvatar then
--             self.avatar_:removeFromParent()
--         end
--         local tex = sprite:getTexture()
--         local texSize = tex:getContentSize()

--         --if self and self.avatar_ then
--             --todo
--            -- dump("imgurl","fuckmicon")
--             -- self.avatar_:setTexture(tex)
--             -- self.avatar_:setTextureRect(cc.rect(0, 0, texSize.width, texSize.height))
--             -- self.avatar_:setScaleX(35 / texSize.width)
--             -- self.avatar_:setScaleY(35 / texSize.height)

--             local sprSize = sprite:getContentSize()
--             if sprSize.width > sprSize.height then
--                 sprite:scale(35 / sprSize.width)
--             else
--                 sprite:scale(35 / sprSize.height)
--             end
--             sprite:addTo(self.avatar_,0,AVATAR_TAG)
--             :pos(35/2,0)
--        -- end
--        -- self.avatarLoaded_ = true
--     end
-- end
-- function ChooseMatchRoomViewEx:onSetGrabRoomList(data)
   
-- end
-- function ChooseMatchRoomViewEx:onSendBordBtnCallBack_(evt)
--     -- body

--     -- local msgInfo = {
--     --     type = 1,
--     --     name = "tsing",
--     --     content = "god like"
--     -- }

--     -- local msgJson = json.encode(msgInfo)
--     -- self.controller_:onSuonaBroadRecv_({data = {msg_info = msgJson}})

--     -- do return end
--     SuonaUsePopup.new():show()
-- end

-- function ChooseMatchRoomViewEx:onEnterForeground_()
--     --切后台回来更新比赛场列表显示
--     nk.MatchConfigEx:loadConfig(nil,handler(self,self.onLoadMatchConfig),true)
-- end



-- function ChooseMatchRoomViewEx:playSuonaMsgScrolling()
--     -- body
--     if not self.suonaMsgPlaying_ then
--         --todo
--         self:playSuonaMsgNext()
--     end
-- end

-- function ChooseMatchRoomViewEx:playSuonaMsgNext()
--     -- body
--     -- self.bordCastMsg_
--     -- self.bordCastMsgStartX_
--     -- self.bordCastMsgDesX_

--     local currentSuonaMsgData = nil

--     -- local suonaMsgShownColor = {
--     --     tip = display.COLOR_WHITE,
--     --     msg = cc.c3b(255, 0, 255)
--     -- }
--     if self.controller_.suonaMsgQueue_[1] then
--         --todo
--         currentSuonaMsgData = table.remove(self.controller_.suonaMsgQueue_, 1)
--     else
--         -- 调整label 的显示,"点击这里使用小喇叭 >>"
--         self.bordCastMsg_:setString(T("点击这里使用小喇叭 >>"))
--         -- self.suonaChatInfo_:setTextColor(suonaMsgShownColor.tip)
--         self.bordCastMsg_:setPositionX(self.bordCastMsgStartX_ - self.bordCastMsg_:getContentSize().width)

--         -- self.topSuonaTipPanel_:setOpacity(0)
--         -- -- self.suonaBtnTop_:setOpacity(255)
--         -- self.suonaChatInfo_:setOpacity(0)
--         -- -- self.suonaChatInfo_:hide()

--         self.suonaMsgPlaying_ = false
--         return
--     end

--     -- if self.suonaIconClickTipAction_ then
--     --     --todo
--     --     self:stopAction(self.suonaIconClickTipAction_)
--     --     self.suonaIconClickTipAction_ = nil

--     --     -- self.suonaChatInfo_:setOpacity(255)
--     --     bm.DataProxy:setData(nk.dataKeys.SUONA_USETIP_ONOFF, false)
--     -- end

--     -- dump(currentSuonaMsgData, "currentSuonaMsgData: =================")

--     self.suonaMsgPlaying_ = true
--     -- self.topSuonaTipPanel_:setOpacity(255)

--     -- -- self.suonaChatInfoclipNode_:setOpacity(255)
--     self.bordCastMsg_:setString(currentSuonaMsgData)
--     -- self.suonaChatInfo_:setTextColor(suonaMsgShownColor.msg)

--     self.bordCastMsg_:pos(self.bordCastMsgStartX_, 0)

--     local chatMsgPlayDelayTime = 0.2
--     local chatMsgShownTimeIntval = 3
--     -- -- local chatMsgLabelRollVelocity = 85
--     local labelRollTime = 7
--     -- -- self.suonaChatMsgStrPosXSrc - self.suonaChatMsgStrPosXDes / chatMsgLabelRollVelocity
--     -- -- self.suonaChatInfo_:getContentSize().width / chatMsgLabelRollVelocity > 4 and 4 or self.suonaChatInfo_:getContentSize().width / chatMsgLabelRollVelocity
--     -- -- self.suonaChatInfo_:show()
--     -- self.suonaChatInfo_:setOpacity(255) -- cc.c3b(255, 0, 255)


--     self.suonaMsgScrollAnim_ = transition.execute(self.bordCastMsg_, cc.MoveTo:create(labelRollTime,
--         cc.p(self.bordCastMsgDesX_, 0)), {delay = chatMsgPlayDelayTime / 2})

--     self.suonaDelayCallHandler_ = nk.schedulerPool:delayCall(handler(self, self.playSuonaMsgNext), labelRollTime + chatMsgPlayDelayTime + chatMsgShownTimeIntval)
-- end


-- function ChooseMatchRoomViewEx:removeDataObserver()
--     bm.DataProxy:removeDataObserver(nk.dataKeys.CHARGEFAV_ONOFF, self.onChargeFavOnOffObserver)
--     bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "aUser.micon", self.avatarUrlObserverHandle_)
--     if self.appForegroundListenerId_ then
--         bm.EventCenter:removeEventListener(self.appForegroundListenerId_)
--         self.appForegroundListenerId_ = nil
--     end

--     if self.timeMatchOpenListenerId_ then
--         bm.EventCenter:removeEventListener(self.timeMatchOpenListenerId_)
--         self.timeMatchOpenListenerId_ = nil
--     end
-- end

-- function ChooseMatchRoomViewEx:onCleanup()

--     nk.http.cancel(self.playerCountRequestId_)
--     nk.http.cancel(self.requestMatchInfoId_)
--     nk.MatchConfigEx:cancel()
--     self:removeDataObserver()
-- end

-- return ChooseMatchRoomViewEx