--
-- Author: Johnny Lee
-- Date: 2014-08-07 23:22:07
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

local StorePopup = import("app.module.newstore.StorePopup")
local HelpPopup = import("app.module.settingAndhelp.SettingAndHelpPopup")
local HallSearchRoomPanel = import("app.module.hall.HallSearchRoomPanel")
local PayGuide = import("app.module.room.purchGuide.PayGuide")
local FirChargePayGuidePopup = import("app.module.newstore.firChrgGuide.FirChrgPayGuidePopup")

local ChooseRoomView = class("ChooseRoomView", function ()
    return display.newNode()
end)

local ChooseRoomChip = import(".ChooseRoomChip")
local ChooseGrabRoomView = import(".ChooseGrabRoomView")

ChooseRoomView.PLAYER_LIMIT_SELECTED = 1 -- 1：9人场；2：5人场
ChooseRoomView.ROOM_LEVEL_SELECTED   = nil -- 1：初级场；2：中级场；3：高级场

local ROOM_TYPE_NOR = 1
local ROOM_TYPE_PRO = 2
local TOP_BUTTOM_WIDTH   = 78
local TOP_BUTTOM_HEIGHT  = 64
local TOP_BUTTOM_PADDING = 8
local TOP_TAB_BAR_WIDTH  = 612
local TOP_TAB_BAR_HEIGHT = 66
local CHIP_HORIZONTAL_DISTANCE = 240 * nk.widthScale
local CHIP_VERTICAL_DISTANCE   = 216 * nk.heightScale

function ChooseRoomView:ctor(controller, viewType)
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

    --[[
        桌子背景
    ]]
    self:addDataObservers()
    -- 桌子
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

    -- 分割线
    self.splitLine_ = display.newSprite("#choose_room_split_line.png")
        :pos(0, display.cy - 176)
        :opacity(0)
        :addTo(self)
    self.splitLine_:setScaleX(nk.widthScale * 0.9)


    -- 在玩人数
    self.userOnline_ = display.newTTFLabel({text = bm.LangUtil.getText("HALL", "USER_ONLINE", 0), color = cc.c3b(0xA7, 0xF2, 0xB0), size = 24, align = ui.TEXT_ALIGN_CENTER})
        :pos(0, display.cy - 152)
        :opacity(0)
        :addTo(self)

    --[[
        顶部操作按钮
    ]] 
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
    display.newScale9Sprite("#top_btn_bg.png", 0, 0, cc.size(TOP_BUTTOM_WIDTH + 4, TOP_BUTTOM_HEIGHT + 4))
        :pos(-display.cx + TOP_BUTTOM_WIDTH * 1.5 + TOP_BUTTOM_PADDING * 2, display.cy - TOP_BUTTOM_HEIGHT * 0.5 - TOP_BUTTOM_PADDING)
        :addTo(self.topBtnNode_)
    display.newSprite("#top_help_btn_icon.png")
        :pos(-display.cx + TOP_BUTTOM_WIDTH * 1.5 + TOP_BUTTOM_PADDING * 2, display.cy - TOP_BUTTOM_HEIGHT * 0.5 - TOP_BUTTOM_PADDING)
        :addTo(self.topBtnNode_)
    cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#rounded_rect_6.png"}, {scale9 = true})
        :setButtonSize(TOP_BUTTOM_WIDTH, TOP_BUTTOM_HEIGHT)
        :pos(-display.cx + TOP_BUTTOM_WIDTH * 1.5 + TOP_BUTTOM_PADDING * 2, display.cy - TOP_BUTTOM_HEIGHT * 0.5 - TOP_BUTTOM_PADDING)
        :addTo(self.topBtnNode_)
        :onButtonClicked(buttontHandler(self, self.onHelpClick_))

    -- 搜索房间
    display.newScale9Sprite("#top_btn_bg.png", 0, 0, cc.size(TOP_BUTTOM_WIDTH + 4, TOP_BUTTOM_HEIGHT + 4))
        :pos(display.cx - TOP_BUTTOM_WIDTH * 1.5 - TOP_BUTTOM_PADDING * 2, display.cy - TOP_BUTTOM_HEIGHT * 0.5 - TOP_BUTTOM_PADDING)
        :addTo(self.topBtnNode_):hide()
    display.newSprite("#top_search_room_btn_icon.png")
        :pos(display.cx - TOP_BUTTOM_WIDTH * 1.5 - TOP_BUTTOM_PADDING * 2, display.cy - TOP_BUTTOM_HEIGHT * 0.5 - TOP_BUTTOM_PADDING)
        :addTo(self.topBtnNode_):hide()
        :scale(0.88)
    cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#rounded_rect_6.png"}, {scale9 = true})
        :setButtonSize(TOP_BUTTOM_WIDTH, TOP_BUTTOM_HEIGHT)
        :pos(display.cx - TOP_BUTTOM_WIDTH * 1.5 - TOP_BUTTOM_PADDING * 2, display.cy - TOP_BUTTOM_HEIGHT * 0.5 - TOP_BUTTOM_PADDING)
        :addTo(self.topBtnNode_):hide()
        :onButtonClicked(buttontHandler(self, self.onSearchClick_))


    -- 商城
    local isShowPay = nk.OnOff:check("payGuide")
    local isPay = nk.userData.best and nk.userData.best.paylog == 1 or false

    if isShowPay and not isPay then
        --todo
        local firstChargeIconPath = nil

        -- if device.platform == "android" or device.platform == "windows" then
            --todo
        if nk.OnOff:check("firstchargeFavGray") then
            --todo
            firstChargeIconPath = "#chgFirFav_entry.png"
        else
            firstChargeIconPath = "#chargeFav_entry.png"
        end

        -- elseif device.platform == "ios" then
        --     --todo
        --     firstChargeIconPath = "#chargeFav_entry_ios.png"
        -- end

        self._firstChargeEntryBtn = cc.ui.UIPushButton.new(firstChargeIconPath, {scale9 = false})
            :pos(display.cx - TOP_BUTTOM_WIDTH / 2 - TOP_BUTTOM_PADDING, display.cy - TOP_BUTTOM_HEIGHT / 2 - TOP_BUTTOM_PADDING)
            :addTo(self.topBtnNode_)
            :onButtonClicked(buttontHandler(self, self._onChargeFavCallBack))
        
    else
        display.newScale9Sprite("#top_btn_bg.png", 0, 0, cc.size(TOP_BUTTOM_WIDTH + 4, TOP_BUTTOM_HEIGHT + 4))
            :pos(display.cx - TOP_BUTTOM_WIDTH * 0.5 - TOP_BUTTOM_PADDING, display.cy - TOP_BUTTOM_HEIGHT * 0.5 - TOP_BUTTOM_PADDING)
            :addTo(self.topBtnNode_)

        display.newSprite("#top_store_btn_icon.png")
            :pos(display.cx - TOP_BUTTOM_WIDTH * 0.5 - TOP_BUTTOM_PADDING, display.cy - TOP_BUTTOM_HEIGHT * 0.5 - TOP_BUTTOM_PADDING)
            :addTo(self.topBtnNode_)

        cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#rounded_rect_6.png"}, {scale9 = true})
            :setButtonSize(TOP_BUTTOM_WIDTH, TOP_BUTTOM_HEIGHT)
            :pos(display.cx - TOP_BUTTOM_WIDTH * 0.5 - TOP_BUTTOM_PADDING, display.cy - TOP_BUTTOM_HEIGHT * 0.5 - TOP_BUTTOM_PADDING)
            :addTo(self.topBtnNode_)
            :onButtonClicked(buttontHandler(self, self.onStoreClick_))
    end

    --默认场次类别
    local aUserMoney = nk.userData["aUser.money"]
    -- if aUserMoney < 10000000 then
    --     nk.userData.DEFAULT_TAB = 1
    -- else
    --     nk.userData.DEFAULT_TAB = 2
    -- end

    -- if aUserMoney>= 2000000 then
    --     nk.userData.DEFAULT_TAB  = 3 
    -- else
    --     nk.userData.DEFAULT_TAB  = 1
    -- end

    -- if nk.OnOff:check("grabDealerOpen")==false then
    --     nk.userData.DEFAULT_TAB  = 1
    -- end

    -- ChooseRoomView.ROOM_LEVEL_SELECTED = nk.userData.DEFAULT_TAB 


    -- 顶部tab bar
    if ChooseRoomView.ROOM_LEVEL_SELECTED == nil then 
        -- ChooseRoomView.ROOM_LEVEL_SELECTED = nk.userData.DEFAULT_TAB or 1
    end
   
    if  bm.DataProxy:getData(nk.dataKeys.ROOM_LIST_SELECT_TYPE) == 3 then
        ChooseRoomView.ROOM_LEVEL_SELECTED = 3
    end

    if nk.userData.TAB_SETING then
        ChooseRoomView.ROOM_LEVEL_SELECTED = nk.userData.TAB_SETING
        nk.userData.TAB_SETING = nil
    end

    --612 * 69
    local bgNode = display.newBatchNode("hall_texture.png", 140)
    bgNode:setContentSize(612, 69)
    local beginX = -66 * 4  - 2
    for i = 1, 134 do
        display.newSprite("#choose_room_level_tab_bar_bg_middle.png", beginX + 4 * (i - 1), 0):addTo(bgNode)
    end
    display.newSprite("#choose_room_level_tab_bar_bg_left.png"):pos(612 * -0.5, 0):addTo(bgNode):setAnchorPoint(cc.p(0, 0.5))
    display.newSprite("#choose_room_level_tab_bar_bg_right.png"):pos(612 * 0.5, 0):addTo(bgNode):setAnchorPoint(cc.p(1, 0.5))

    self.topTabBar_ = nk.ui.TabBarWithIndicator.new(
        {
            background = bgNode, 
            indicator = "#choose_room_level_tab_bar_indicator.png"
        }, 
        bm.LangUtil.getText("HALL", "ROOM_LEVEL_TEXT"), 
        {
            selectedText = {color = styles.FONT_COLOR.LIGHT_TEXT, size = 28}, 
            defaltText = {color = cc.c3b(0x1C, 0x84, 0x4A), size = 28}
        }, 
        false, 
        true
    )
        :pos(0, display.cy - 56 - TOP_TAB_BAR_HEIGHT * 0.5)
        :addTo(self.topBtnNode_)


    self.newIcon_ = display.newSprite("#grab_new_table.png")
    :addTo(self.topBtnNode_)
    :pos(612/2 - 100, display.cy - 56 - TOP_TAB_BAR_HEIGHT * 0.5 + 40)
    --20
    -- 右边tab bar
    -- self.rightTabBar_ = nk.ui.TabBarWithIndicator.new(
    --     {
    --         background = "#choose_room_player_limit_tab_bar_bg.png", 
    --         indicator = "#choose_room_player_limit_tab_bar_indicator.png"
    --     }, 
    --     bm.LangUtil.getText("HALL", "PLAYER_LIMIT_TEXT"), 
    --     {
    --         selectedText = {color = cc.c3b(0xA6, 0xF1, 0xAF), size = 32}, 
    --         defaltText = {color = cc.c3b(0x1C, 0x84, 0x4A), size = 32}
    --     }, 
    --     false, 
    --     true, 
    --     nk.ui.TabBarWithIndicator.VERTICAL
    -- )
    --     :pos(display.cx + 72, -CHIP_VERTICAL_DISTANCE * 0.5 + 40 * nk.heightScale)
    --     :addTo(self)

    --[[
        筹码操作区
    ]]
    self.chipBtnNode_ = display.newNode()
        :addTo(self)

    -- 筹码
    self.chips_ = {}
    local chipTextColors = {
        cc.c3b(0x37, 0x88, 0x1c), 
        cc.c3b(0xCA, 0x7C, 0x2C), 
        cc.c3b(0x2F, 0x88, 0xE1), 
        cc.c3b(0xBB, 0x06, 0x06), 
        cc.c3b(0xAD, 0x22, 0x9C), 
        cc.c3b(0xED, 0x61, 0x06), 
    }
    for i = 1, 6 do
        self.chips_[i] = ChooseRoomChip.new("#choose_room_chip_"..i..".png", chipTextColors[i])
            :pos(((i - 1) % 3 - 1) * CHIP_HORIZONTAL_DISTANCE, (math.floor((6 - i) / 3) - 1) * CHIP_VERTICAL_DISTANCE - display.cy - 81)
            :addTo(self.chipBtnNode_)
            :onChipClick(handler(self, self.onChipClick_))
    end
    self.grabDealerNode_ = ChooseGrabRoomView.new(self.controller_)
        :addTo(self)
        :hide()



    -- 设置筹码后，绑定tab change回调
    self.topTabBar_:onTabChange(handler(self, self.onTopTabChange_))
        :gotoTab(ChooseRoomView.ROOM_LEVEL_SELECTED, true)

    self.topTabBar_:setScale(.9)
    -- self.rightTabBar_:onTabChange(handler(self, self.onRightTabChange_))
    --     :gotoTab(ChooseRoomView.PLAYER_LIMIT_SELECTED, true)
end

function ChooseRoomView:playShowAnim()
    local animTime = self.controller_.getAnimTime()
    -- 桌子
    transition.moveTo(self.pokerTable_, {time = animTime, y = 0})
    -- icon
    transition.moveTo(self.roomTypeIcon_, {time = animTime, x = -display.cx, delay = animTime})
    -- 分割线
    transition.fadeIn(self.splitLine_, {time = animTime, opacity = 255, delay = animTime})
    -- 在线人数
    transition.fadeIn(self.userOnline_, {time = animTime, opacity = 255, delay = animTime})
    -- 顶部操作区
    transition.moveTo(self.topBtnNode_, {time = animTime, y = 0, delay = animTime})
    -- 筹码
    for i, chip in ipairs(self.chips_) do
        transition.moveTo(chip, {
            time = animTime, 
            y = (math.floor((6 - i) / 3) - 1) * CHIP_VERTICAL_DISTANCE + 40 * nk.heightScale, 
            delay = animTime + 0.05 * ((i <= 3 and i or (i - 3)) - 1),     
            easing = "BACKOUT"
        })
    end
    -- 右边tab bar
    -- transition.moveTo(self.rightTabBar_, {time = animTime, x = display.cx - 72, delay = animTime})
end

function ChooseRoomView:playHideAnim()
    self:removeFromParent()
end

function ChooseRoomView:onReturnClick_()
    self.controller_:showMainHallView()
end

function ChooseRoomView:onHelpClick_()
    HelpPopup.new(false, true, 2):show()
end

function ChooseRoomView:onSearchClick_()
    HallSearchRoomPanel.new(self.controller_,handler(self,self.onSearchPanelCallback)):showPanel()
end



function ChooseRoomView:onSearchPanelCallback(roomId)
    -- dump(roomId,"ChooseRoomView:onSearchPanelCallback")
    local roomData = {}
    roomData.roomid = roomId--26280117
    bm.EventCenter:dispatchEvent({name = nk.eventNames.ENTER_ROOM_WITH_DATA, data = roomData})
end

function ChooseRoomView:onStoreClick_()
    StorePopup.new():showPanel()
end

function ChooseRoomView:_onChargeFavCallBack()
    -- body

    local shownScene = 1
    local isThirdPayOpen = true
    local isFirstCharge = true
    local payBillType = nil

    if nk.OnOff:check("firstchargeFavGray") then
        --todo
        FirChargePayGuidePopup.new():showPanel()
    else
        local params = {}

        params.isOpenThrPartyPay = isThirdPayOpen
        params.isFirstCharge = isFirstCharge
        params.sceneType = shownScene
        params.payListType = payBillType

        PayGuide.new(params):show()
    end
end

function ChooseRoomView:onGetPlayerCountData(data, field)
    local levelSelected = ChooseRoomView.ROOM_LEVEL_SELECTED
    if field ~= levelSelected then
        return
    end    
    self.fivePlayerCounts_ = data[1][field]
    self.ninePlayerCounts_ = data[1][field]
    local playerCounts = nil
    local totalPlayer = 0
    if ChooseRoomView.PLAYER_LIMIT_SELECTED == 1 then
        playerCounts = self.ninePlayerCounts_
    elseif ChooseRoomView.PLAYER_LIMIT_SELECTED == 2 then
        playerCounts = self.fivePlayerCounts_
    end
      
    -- 设置对应筹码的在玩人数
    for i, chip in ipairs(self.chips_) do        
        local chipVal = chip:getValue()        
        if playerCounts and playerCounts[chipVal] then
            chip:setPlayerCount(playerCounts[chipVal])
            totalPlayer = totalPlayer + playerCounts[chipVal]
        else
            chip:setPlayerCount(0)
        end
    end
    -- 设置总在玩人数
    self.userOnline_:setString(bm.LangUtil.getText("HALL", "USER_ONLINE", totalPlayer))
end

-- 顶部tab切换
function ChooseRoomView:onTopTabChange_(selectedTab)
    bm.DataProxy:setData(nk.dataKeys.ROOM_LIST_SELECT_TYPE, selectedTab) 
    if selectedTab == 3 then

        if nk.OnOff:check("grabDealerOpen") then
            self.chipBtnNode_:hide()
            self.grabDealerNode_:show()

            if self.grabDealerNode_:getIsCreateFirst() then
                self.grabDealerNode_:reset()
                self.grabDealerNode_:showGrabList(true)
                self.grabDealerNode_:setIsCreateFirst(false)
            else
                self.grabDealerNode_:showGrabList(false)
            end
            
            self.splitLine_:hide()
            self.userOnline_:hide()
            -- nk.server:requestGrabRoomList()
        else
            nk.ui.Dialog.new({
            messageText = T("暂未开放 敬请期待"), 
            secondBtnText = T("确定"),
            closeWhenTouchModel = true,
            hasFirstButton = false,
            hasCloseButton = false,
            callback = function (type)
                if type == nk.ui.Dialog.SECOND_BTN_CLICK then               
                end
            end,
            }):show()
             self.topTabBar_:gotoTab(1, true)
        end
        return
    end
    self.grabDealerNode_:hide()
    self.chipBtnNode_:show()
    self.splitLine_:show()
    self.userOnline_:show()

    ChooseRoomView.ROOM_LEVEL_SELECTED = selectedTab

    -- 清空、拉取在玩人数
    self.fivePlayerCounts_ = nil
    self.ninePlayerCounts_ = nil
    self.controller_:getPlayerCountData(self.roomType_, selectedTab)

    -- 给筹码设置前注

    -- dump(tableConf,"tableConf :===========",10)
    -- dump(ChooseRoomView.PLAYER_LIMIT_SELECTED,"PLAYER_LIMIT_SELECTED :=============")
    -- dump(selectedTab,"selectedTab :============")

    local tableConf = bm.DataProxy:getData(nk.dataKeys.TABLE_CONF)
    local preCalls = tableConf[ChooseRoomView.PLAYER_LIMIT_SELECTED][selectedTab]

    for i, chip in ipairs(self.chips_) do
        if preCalls and preCalls[i] then
            chip:show()
            chip:setPreCall(preCalls[i])
        else
            chip:hide()
        end
    end
end

-- 右侧tab切换
function ChooseRoomView:onRightTabChange_(selectedTab)
    ChooseRoomView.PLAYER_LIMIT_SELECTED = selectedTab
    local playerCounts = nil
    local totalPlayer = 0
    if selectedTab == 1 then
        playerCounts = self.ninePlayerCounts_
    elseif selectedTab == 2 then
        playerCounts = self.fivePlayerCounts_
    end
    local tableConf = bm.DataProxy:getData(nk.dataKeys.TABLE_CONF)
    local preCalls = tableConf[selectedTab][ChooseRoomView.ROOM_LEVEL_SELECTED]
    for i, chip in ipairs(self.chips_) do
        if preCalls and preCalls[i] then
            chip:show()
            chip:setPreCall(preCalls[i])
            -- 设置对应筹码的在玩人数
            if playerCounts and  playerCounts[i] then
                chip:setPlayerCount(playerCounts[i].c)
                totalPlayer = totalPlayer + playerCounts[i].c
            else
                chip:setPlayerCount(0)
            end
        else
            chip:hide()
        end
    end
    -- 设置总在玩人数
    self.userOnline_:setString(bm.LangUtil.getText("HALL", "USER_ONLINE", totalPlayer))
end

function ChooseRoomView:refreshFirstChargeFavEntryUi(isOpen)
    -- body
    if not isOpen then
        --todo

        if self._firstChargeEntryBtn then
        --todo
            self._firstChargeEntryBtn:removeFromParent()
            self._firstChargeEntryBtn = nil

            display.newScale9Sprite("#top_btn_bg.png", 0, 0, cc.size(TOP_BUTTOM_WIDTH + 4, TOP_BUTTOM_HEIGHT + 4))
                :pos(display.cx - TOP_BUTTOM_WIDTH * 0.5 - TOP_BUTTOM_PADDING, display.cy - TOP_BUTTOM_HEIGHT * 0.5 - TOP_BUTTOM_PADDING)
                :addTo(self.topBtnNode_)

            display.newSprite("#top_store_btn_icon.png")
                :pos(display.cx - TOP_BUTTOM_WIDTH * 0.5 - TOP_BUTTOM_PADDING, display.cy - TOP_BUTTOM_HEIGHT * 0.5 - TOP_BUTTOM_PADDING)
                :addTo(self.topBtnNode_)

            cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#rounded_rect_6.png"}, {scale9 = true})
                :setButtonSize(TOP_BUTTOM_WIDTH, TOP_BUTTOM_HEIGHT)
                :pos(display.cx - TOP_BUTTOM_WIDTH * 0.5 - TOP_BUTTOM_PADDING, display.cy - TOP_BUTTOM_HEIGHT * 0.5 - TOP_BUTTOM_PADDING)
                :addTo(self.topBtnNode_)
                :onButtonClicked(buttontHandler(self, self.onStoreClick_))
        end
    end
    
end

-- 点击筹码play now指定条件场次
function ChooseRoomView:onChipClick_(preCall)
    local playerCap = 9
    if ChooseRoomView.PLAYER_LIMIT_SELECTED == 2 then
        playerCap = 5
    end
    self.controller_:getEnterRoomData({tt = self.roomType_, sb = preCall, pc = playerCap})
end

function ChooseRoomView:addDataObservers()
    -- body
    self.onChargeFavOnOffObserver = bm.DataProxy:addDataObserver(nk.dataKeys.CHARGEFAV_ONOFF, handler(self, self.refreshFirstChargeFavEntryUi))
end
function ChooseRoomView:onSetGrabRoomList(data)
    if self.grabDealerNode_["onSetGrabRoomList"] then
        self.grabDealerNode_:onSetGrabRoomList(data)
    end
end
function ChooseRoomView:onCleanup()

    nk.http.cancel(self.playerCountRequestId_)

    bm.DataProxy:removeDataObserver(nk.dataKeys.CHARGEFAV_ONOFF, self.onChargeFavOnOffObserver)
end

return ChooseRoomView