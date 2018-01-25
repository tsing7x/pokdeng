--
-- Author: VanfoHuang
-- Date: 2015-09-10 
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

local StorePopup = import("app.module.newstore.StorePopup")
local HallSearchRoomPanel = import("app.module.hall.HallSearchRoomPanel")
local InvitePopup         = import("app.module.friend.InviteRecallPopup")

local HelpPopup = import(".personalRoomDialog.PersonelRoomHelpPopup")
local QRCodePopup = import(".personalRoomDialog.QRCodeShowPopup")
local PswEntryPopup = import(".personalRoomDialog.PswEntryPopup")
local PayGuidePopMgr = import("app.module.room.purchGuide.PayGuidePopMgr")

local AnimUpScrollQueue = import(".AnimUpScrollQueue")

local ChoosePersonalRoomView = class("ChoosePersonalRoomView", function ()
    return display.newNode()
end)

-- local ChooseRoomChip = import(".ChooseRoomChip")

local ChoosePersonalRoomItem = import(".ChoosePersonalRoomItem")

ChoosePersonalRoomView.PLAYER_LIMIT_SELECTED = 1 -- 1：9人场；2：5人场
ChoosePersonalRoomView.ROOM_LEVEL_SELECTED   = nil -- 1：初级场；2：中级场；3：高级场

local ROOM_LIST_PAGE_ITEMS_NUM = 50

local ROOM_TYPE_NOR = 1
local ROOM_TYPE_PRO = 2
local TOP_BUTTOM_WIDTH   = 78
local TOP_BUTTOM_HEIGHT  = 64
local TOP_BUTTOM_PADDING = 12
local TOP_TAB_BAR_WIDTH  = 612
local TOP_TAB_BAR_HEIGHT = 66
local CHIP_HORIZONTAL_DISTANCE = 240 * nk.widthScale
local CHIP_VERTICAL_DISTANCE   = 216 * nk.heightScale


local TOP_TITLE_HEIGHT = 51  --资源实际大小
local TOP_TITLE_WIDTH = 245

local LIST_NODE_WIDTH = display.width-90
local LIST_NODE_HEIGHT = 480
local LIST_NODE_MARGIN_TOP = 10
local LIST_NODE_POSY =  (display.cy - TOP_TAB_BAR_HEIGHT - TOP_BUTTOM_PADDING*2 - TOP_TITLE_HEIGHT -LIST_NODE_MARGIN_TOP - LIST_NODE_HEIGHT*0.5)

local LIST_TITLE_MARGIN_TOP = 10
local LIST_TITLE_WIDTH = LIST_NODE_WIDTH - 40
local LIST_TITLE_HEIGHT = 33
local LIST_TITLE_PADDING = 100
local LIST_TITLE_POSY = LIST_NODE_HEIGHT*0.5 - (LIST_TITLE_HEIGHT *0.5) - LIST_TITLE_MARGIN_TOP

local LIST_VIEW_MARGIN_TOP = 10
local LIST_VIEW_WIDTH = display.width-90
local LIST_VIEW_HEIGHT = 355
local LIST_VIEW_POSY = LIST_TITLE_POSY-(LIST_TITLE_HEIGHT *0.5) - LIST_VIEW_MARGIN_TOP - LIST_VIEW_HEIGHT*0.5

local LIST_BOTTOM_MARGIN_TOP = 10
local LIST_BOTTOM_WIDTH = display.width-90
local LIST_BOTTOM_HEIGHT = 55
local LIST_BOTTOM_POSY = LIST_VIEW_POSY - LIST_VIEW_HEIGHT * 0.5 - LIST_BOTTOM_MARGIN_TOP - (LIST_BOTTOM_HEIGHT*0.5)

local LIST_BOTTOM_BTN_WIDTH = 145
local LIST_BOTTOM_BTN_HEIGHT = 55
local LIST_BOTTOM_BTN_MARGIN_LEFT = 10

local LIST_BOTTOM_TIPS_WIDTH = LIST_TITLE_WIDTH/2 - 50--378
local LIST_BOTTOM_TIPS_HEIGHT = 55

function ChoosePersonalRoomView:ctor(controller, viewType)
    self.controller_ = controller
    self.controller_:setDisplayView(self)
    if viewType == controller.CHOOSE_PERSONAL_NOR_VIEW then
        self.roomType_ = ROOM_TYPE_NOR
        -- self.roomTypeIcon_ = display.newSprite("#choose_room_nor_icon.png")
    else
        self.roomType_ = ROOM_TYPE_PRO
        -- self.roomTypeIcon_ = display.newSprite("#choose_room_pro_icon.png")
    end

    self:setNodeEventEnabled(true)

    -- 桌子
    -- self.pokerTable_ = display.newNode():pos(0, -(display.cy + 146)):addTo(self):scale(self.controller_:getBgScale())
    -- local tableLeft = display.newSprite("#main_hall_table.png"):addTo(self.pokerTable_)
    -- tableLeft:setAnchorPoint(cc.p(1, 0.5))
    -- tableLeft:pos(2, 0)
    -- local tableRight = display.newSprite("#main_hall_table.png"):addTo(self.pokerTable_)
    -- tableRight:setScaleX(-1)
    -- tableRight:setAnchorPoint(cc.p(1, 0.5))
    -- tableRight:pos(-2, 0)

    -- self.roomTypeIcon_:align(display.LEFT_CENTER, -(display.cx + self.roomTypeIcon_:getContentSize().width), -CHIP_VERTICAL_DISTANCE * 0.5 + 40 * nk.heightScale)
    --     :addTo(self)

    -- 分割线
    -- self.splitLine_ = display.newSprite("#choose_room_split_line.png")
    --     :pos(0, display.cy - 146)
    --     :opacity(0)
    --     :addTo(self)
    -- self.splitLine_:setScaleX(nk.widthScale * 0.9)


    -- 在玩人数
    -- self.userOnline_ = display.newTTFLabel({text = bm.LangUtil.getText("HALL", "USER_ONLINE", 0), color = cc.c3b(0xA7, 0xF2, 0xB0), size = 24, align = ui.TEXT_ALIGN_CENTER})
    --     :pos(0, display.cy - 152)
    --     :opacity(0)
    --     :addTo(self)

    --[[
        顶部操作按钮
    ]] 
    -- self.topBtnNode_ = display.newNode()
    --     :pos(0, TOP_BUTTOM_HEIGHT + TOP_TAB_BAR_HEIGHT + TOP_BUTTOM_PADDING)
    --     :addTo(self)


    -- display.newSprite("#perTitleIcon.png")
    -- -- :pos(0,display.cy - TOP_TITLE_HEIGHT * 0.5 - TOP_BUTTOM_PADDING)
    -- :pos(0,display.cy - TOP_TITLE_HEIGHT * 0.5 - TOP_BUTTOM_PADDING-50)
    -- :addTo(self.topBtnNode_)

    -- self.nickText_ = display.newTTFLabel({text = "", color = cc.c3b(0xff, 0xff, 0xff), size = 24, align = ui.TEXT_ALIGN_CENTER})
    --     :align(display.LEFT_CENTER,-display.cx + TOP_BUTTOM_WIDTH + TOP_BUTTOM_PADDING*2 , display.cy - TOP_BUTTOM_HEIGHT - TOP_BUTTOM_PADDING * 2)
    --     -- :pos(-display.cx + TOP_BUTTOM_WIDTH + TOP_BUTTOM_PADDING*2 , display.cy - TOP_BUTTOM_HEIGHT - TOP_BUTTOM_PADDING * 2)
    --     :addTo(self.topBtnNode_)

    -- display.newSprite("#chip_icon.png")
    --     :align(display.LEFT_CENTER,-display.cx + TOP_BUTTOM_WIDTH + TOP_BUTTOM_PADDING*2 , display.cy - TOP_BUTTOM_HEIGHT - TOP_BUTTOM_PADDING * 4)
    --     :addTo(self.topBtnNode_)

    -- self.moneyText_ = display.newTTFLabel({text = "", color = cc.c3b(0xff, 0xd2, 0x00), size = 24, align = ui.TEXT_ALIGN_CENTER})
    --     :align(display.LEFT_CENTER,-display.cx + TOP_BUTTOM_WIDTH + TOP_BUTTOM_PADDING*4.5 , display.cy - TOP_BUTTOM_HEIGHT - TOP_BUTTOM_PADDING * 4)
    --     -- :pos(-display.cx + TOP_BUTTOM_WIDTH + TOP_BUTTOM_PADDING*2 , display.cy - TOP_BUTTOM_HEIGHT - TOP_BUTTOM_PADDING * 2)
    --     :addTo(self.topBtnNode_)

    -- -- 返回
    -- display.newScale9Sprite("#top_btn_bg.png", 0, 0, cc.size(TOP_BUTTOM_WIDTH + 4, TOP_BUTTOM_HEIGHT + 4))
    --     :pos(-display.cx + TOP_BUTTOM_WIDTH * 0.5 + TOP_BUTTOM_PADDING, display.cy - TOP_BUTTOM_HEIGHT * 0.5 - TOP_BUTTOM_PADDING)
    --     :addTo(self.topBtnNode_)
    -- display.newSprite("#top_return_btn_icon.png")
    --     :pos(-display.cx + TOP_BUTTOM_WIDTH * 0.5 + TOP_BUTTOM_PADDING, display.cy - TOP_BUTTOM_HEIGHT * 0.5 - TOP_BUTTOM_PADDING)
    --     :addTo(self.topBtnNode_)
    -- cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#rounded_rect_6.png"}, {scale9 = true})
    --     :setButtonSize(TOP_BUTTOM_WIDTH, TOP_BUTTOM_HEIGHT)
    --     :pos(-display.cx + TOP_BUTTOM_WIDTH * 0.5 + TOP_BUTTOM_PADDING, display.cy - TOP_BUTTOM_HEIGHT * 0.5 - TOP_BUTTOM_PADDING)
    --     :addTo(self.topBtnNode_)
    --     :onButtonClicked(buttontHandler(self, self.onReturnClick_))

    -- -- 帮助
    -- display.newScale9Sprite("#top_btn_bg.png", 0, 0, cc.size(TOP_BUTTOM_WIDTH + 4, TOP_BUTTOM_HEIGHT + 4))
    --     -- :pos(-display.cx + TOP_BUTTOM_WIDTH * 1.5 + TOP_BUTTOM_PADDING * 2, display.cy - TOP_BUTTOM_HEIGHT * 0.5 - TOP_BUTTOM_PADDING)
    --     :pos(display.cx - TOP_BUTTOM_WIDTH * 0.5 - TOP_BUTTOM_PADDING, display.cy - TOP_BUTTOM_HEIGHT * 0.5 - TOP_BUTTOM_PADDING)
    --     :addTo(self.topBtnNode_)
    -- display.newSprite("#top_help_btn_icon.png")
    --     -- :pos(-display.cx + TOP_BUTTOM_WIDTH * 1.5 + TOP_BUTTOM_PADDING * 2, display.cy - TOP_BUTTOM_HEIGHT * 0.5 - TOP_BUTTOM_PADDING)
    --    :pos(display.cx - TOP_BUTTOM_WIDTH * 0.5 - TOP_BUTTOM_PADDING, display.cy - TOP_BUTTOM_HEIGHT * 0.5 - TOP_BUTTOM_PADDING)
    --     :addTo(self.topBtnNode_)
    -- cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#rounded_rect_6.png"}, {scale9 = true})
    --     :setButtonSize(TOP_BUTTOM_WIDTH, TOP_BUTTOM_HEIGHT)
    --     -- :pos(-display.cx + TOP_BUTTOM_WIDTH * 1.5 + TOP_BUTTOM_PADDING * 2, display.cy - TOP_BUTTOM_HEIGHT * 0.5 - TOP_BUTTOM_PADDING)
    --     :pos(display.cx - TOP_BUTTOM_WIDTH * 0.5 - TOP_BUTTOM_PADDING, display.cy - TOP_BUTTOM_HEIGHT * 0.5 - TOP_BUTTOM_PADDING)
    --     :addTo(self.topBtnNode_)
    --     :onButtonClicked(buttontHandler(self, self.onHelpClick_))

    -- 顶部tab bar
    if ChoosePersonalRoomView.ROOM_LEVEL_SELECTED == nil then 
        -- ChoosePersonalRoomView.ROOM_LEVEL_SELECTED = nk.userData.DEFAULT_TAB or 1
        ChoosePersonalRoomView.ROOM_LEVEL_SELECTED =  1
    end

    self.roomListNode_ = display.newNode()
    :pos(0,- display.cy - LIST_NODE_HEIGHT * 0.5)
    -- :pos(0,LIST_NODE_POSY)
    :addTo(self)

    local listBg = display.newScale9Sprite("#perListBg.png",0,0,cc.size(LIST_NODE_WIDTH,LIST_NODE_HEIGHT))
    :addTo(self.roomListNode_)

    local listTitleNode = display.newNode()
    :pos(0,LIST_TITLE_POSY)
    :addTo(self.roomListNode_)
    local listTitleBg = display.newScale9Sprite("#perListTitleBg.png",0,0,cc.size(LIST_TITLE_WIDTH,LIST_TITLE_HEIGHT))
    :addTo(listTitleNode)

    local totalLen = LIST_TITLE_WIDTH - 20
    local itemLen = totalLen/8

    display.newTTFLabel({text = bm.LangUtil.getText("HALL","PERSONAL_ROOM_LIST_TITLE")[1], color = cc.c3b(0xff, 0xd2, 0x00), size = 24, align = ui.TEXT_ALIGN_CENTER})
        :align(display.LEFT_CENTER,-LIST_TITLE_WIDTH*0.5 + 10,0)
        -- :pos(-display.cx + TOP_BUTTOM_WIDTH + TOP_BUTTOM_PADDING*2 , display.cy - TOP_BUTTOM_HEIGHT - TOP_BUTTOM_PADDING * 2)
        :addTo(listTitleNode)
        :pos(-totalLen/2,0)

    display.newTTFLabel({text = bm.LangUtil.getText("HALL","PERSONAL_ROOM_LIST_TITLE")[2], color = cc.c3b(0xff, 0xd2, 0x00), size = 24, align = ui.TEXT_ALIGN_CENTER})
        :align(display.LEFT_CENTER,-LIST_TITLE_WIDTH*0.5 + 10 + LIST_TITLE_PADDING,0)
        -- :pos(-display.cx + TOP_BUTTOM_WIDTH + TOP_BUTTOM_PADDING*2 , display.cy - TOP_BUTTOM_HEIGHT - TOP_BUTTOM_PADDING * 2)
        :addTo(listTitleNode)
        :pos(-totalLen/2+itemLen,0)

    display.newTTFLabel({text = bm.LangUtil.getText("HALL","PERSONAL_ROOM_LIST_TITLE")[3], color = cc.c3b(0xff, 0xd2, 0x00), size = 24, align = ui.TEXT_ALIGN_CENTER})
        :align(display.LEFT_CENTER,-LIST_TITLE_WIDTH*0.5 + 10 + LIST_TITLE_PADDING*2.2,0)
        -- :pos(-display.cx + TOP_BUTTOM_WIDTH + TOP_BUTTOM_PADDING*2 , display.cy - TOP_BUTTOM_HEIGHT - TOP_BUTTOM_PADDING * 2)
        :addTo(listTitleNode)
        :pos(-totalLen/2+2*itemLen,0)

    display.newTTFLabel({text = bm.LangUtil.getText("HALL","PERSONAL_ROOM_LIST_TITLE")[4], color = cc.c3b(0xff, 0xd2, 0x00), size = 24, align = ui.TEXT_ALIGN_CENTER})
        :align(display.LEFT_CENTER,-LIST_TITLE_WIDTH*0.5 + 10 + LIST_TITLE_PADDING*3,0)
        -- :pos(-display.cx + TOP_BUTTOM_WIDTH + TOP_BUTTOM_PADDING*2 , display.cy - TOP_BUTTOM_HEIGHT - TOP_BUTTOM_PADDING * 2)
        :addTo(listTitleNode)
        :pos(-totalLen/2 + 3*itemLen - 20,0)

    display.newTTFLabel({text = bm.LangUtil.getText("HALL","PERSONAL_ROOM_LIST_TITLE")[5], color = cc.c3b(0xff, 0xd2, 0x00), size = 24, align = ui.TEXT_ALIGN_CENTER})
        :align(display.LEFT_CENTER,-LIST_TITLE_WIDTH*0.5 + 10 + LIST_TITLE_PADDING*4.2,0)
        -- :pos(-display.cx + TOP_BUTTOM_WIDTH + TOP_BUTTOM_PADDING*2 , display.cy - TOP_BUTTOM_HEIGHT - TOP_BUTTOM_PADDING * 2)
        :addTo(listTitleNode)
        :pos(-totalLen/2 + 4*itemLen,0)

    display.newTTFLabel({text = bm.LangUtil.getText("HALL","PERSONAL_ROOM_LIST_TITLE")[6], color = cc.c3b(0xff, 0xd2, 0x00), size = 24, align = ui.TEXT_ALIGN_CENTER})
        :align(display.LEFT_CENTER,-LIST_TITLE_WIDTH*0.5 + 10 + LIST_TITLE_PADDING*5.2,0)
        -- :pos(-display.cx + TOP_BUTTOM_WIDTH + TOP_BUTTOM_PADDING*2 , display.cy - TOP_BUTTOM_HEIGHT - TOP_BUTTOM_PADDING * 2)
        :addTo(listTitleNode)
        :pos(-totalLen/2 + 5*itemLen,0)

    display.newTTFLabel({text = bm.LangUtil.getText("HALL","PERSONAL_ROOM_LIST_TITLE")[7], color = cc.c3b(0xff, 0xd2, 0x00), size = 24, align = ui.TEXT_ALIGN_CENTER})
       :align(display.LEFT_CENTER,-LIST_TITLE_WIDTH*0.5 + 10 + LIST_TITLE_PADDING*6,0)
        -- :pos(-display.cx + TOP_BUTTOM_WIDTH + TOP_BUTTOM_PADDING*2 , display.cy - TOP_BUTTOM_HEIGHT - TOP_BUTTOM_PADDING * 2)
        :addTo(listTitleNode)
        :pos(-totalLen/2 + 6*itemLen,0)

    self:createListView_()

    self.bottomBtnNode = display.newNode()
        :pos(-LIST_BOTTOM_WIDTH*0.5,LIST_BOTTOM_POSY)
        :addTo(self.roomListNode_)

    self.bottomBtnNode:setContentSize(cc.size(LIST_BOTTOM_WIDTH, LIST_BOTTOM_HEIGHT))

    local createRoomBtnBg = display.newScale9Sprite("#perGreenBtn.png",0,0,cc.size(LIST_BOTTOM_BTN_WIDTH,LIST_BOTTOM_BTN_HEIGHT))
        :align(display.LEFT_CENTER, 400, 0)
        :addTo(self.bottomBtnNode)
        :pos(LIST_TITLE_WIDTH - 3*LIST_BOTTOM_BTN_WIDTH+15 - 2*LIST_BOTTOM_BTN_MARGIN_LEFT ,0)

    self.createRoomBtn_ = cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#rounded_rect_10.png", disabled = "#common_transparent_skin.png"}, {scale9 = true})
        :setButtonSize(LIST_BOTTOM_BTN_WIDTH, LIST_BOTTOM_BTN_HEIGHT)
        :align(display.LEFT_CENTER,400, 0)
        :setButtonLabel(display.newTTFLabel({text=bm.LangUtil.getText("HALL", "PERSONAL_ROOM_CREATE_ROOM"), size=24, color=cc.c3b(0xff, 0xff, 0xff), align=ui.TEXT_ALIGN_CENTER}))
        :addTo(self.bottomBtnNode)
        :pos(LIST_TITLE_WIDTH - 3*LIST_BOTTOM_BTN_WIDTH+15 -2*LIST_BOTTOM_BTN_MARGIN_LEFT ,0)
        :onButtonClicked(buttontHandler(self, self.onCreateRoomBtnClicked))

    local qrCodeBtnBg = display.newScale9Sprite("#perYelloBtn.png",0,0,cc.size(LIST_BOTTOM_BTN_WIDTH,LIST_BOTTOM_BTN_HEIGHT))
        :align(display.LEFT_CENTER, 400 + LIST_BOTTOM_BTN_WIDTH + LIST_BOTTOM_BTN_MARGIN_LEFT, 0)
        :addTo(self.bottomBtnNode)
        :pos(LIST_TITLE_WIDTH - 2*LIST_BOTTOM_BTN_WIDTH+15 -LIST_BOTTOM_BTN_MARGIN_LEFT ,0)

    self.qrCodeBtn = cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#rounded_rect_10.png"}, {scale9 = true})
        :setButtonSize(LIST_BOTTOM_BTN_WIDTH, LIST_BOTTOM_BTN_HEIGHT)
        :align(display.LEFT_CENTER,400 + LIST_BOTTOM_BTN_WIDTH + LIST_BOTTOM_BTN_MARGIN_LEFT, 0)
        :setButtonLabel(display.newTTFLabel({text=bm.LangUtil.getText("HALL", "PERSONAL_ROOM_QRCODE"), size=24, color=cc.c3b(0xff, 0xff, 0xff), align=ui.TEXT_ALIGN_CENTER}))
        :addTo(self.bottomBtnNode)
        :pos(LIST_TITLE_WIDTH - 2*LIST_BOTTOM_BTN_WIDTH+15 -LIST_BOTTOM_BTN_MARGIN_LEFT ,0)
        :onButtonClicked(buttontHandler(self, self.onQrCodeBtnClicked))


    local inviteBtnBg = display.newScale9Sprite("#perYelloBtn.png",0,0,cc.size(LIST_BOTTOM_BTN_WIDTH,LIST_BOTTOM_BTN_HEIGHT))
        :align(display.LEFT_CENTER, 400 + LIST_BOTTOM_BTN_WIDTH*2 + LIST_BOTTOM_BTN_MARGIN_LEFT*2, 0)
        :addTo(self.bottomBtnNode)
        :pos(LIST_TITLE_WIDTH - LIST_BOTTOM_BTN_WIDTH +15 ,0)

    self.inviteBtn_ = cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#rounded_rect_10.png", disabled = "#common_transparent_skin.png"}, {scale9 = true})
        :setButtonSize(LIST_BOTTOM_BTN_WIDTH, LIST_BOTTOM_BTN_HEIGHT)
        :align(display.LEFT_CENTER,400 + LIST_BOTTOM_BTN_WIDTH*2 + LIST_BOTTOM_BTN_MARGIN_LEFT*2, 0)
        :setButtonLabel(display.newTTFLabel({text=bm.LangUtil.getText("HALL", "PERSONAL_ROOM_INVITE_FRIEND"), size=24, color=cc.c3b(0xff, 0xff, 0xff), align=ui.TEXT_ALIGN_CENTER}))
        :addTo(self.bottomBtnNode)
        :onButtonClicked(buttontHandler(self, self.onInviteBtnClicked))
        :pos(LIST_TITLE_WIDTH -LIST_BOTTOM_BTN_WIDTH+15 ,0)

    local tipBg = display.newScale9Sprite("#perTipBg.png",0,0,cc.size(LIST_BOTTOM_TIPS_WIDTH,LIST_BOTTOM_TIPS_HEIGHT))
    :align(display.LEFT_CENTER, 20, 0)
    :addTo(self.bottomBtnNode)

    local contentSize = cc.size(LIST_BOTTOM_TIPS_WIDTH-20, LIST_BOTTOM_TIPS_HEIGHT-10)
    local lalSize =  32 --cc.size(LIST_BOTTOM_TIPS_WIDTH-20, LIST_BOTTOM_TIPS_HEIGHT)
    local color = cc.c3b(0xff, 0xff, 0xff)
    local textAlign = ui.TEXT_ALIGN_CENTER
    
    local dt = bm.LangUtil.getText("HALL","PERSONAL_HALL_TIPS")
    local tab = {}
    for i = 1, #dt do
       local tempTab =  nk.subStr2TbByWidth("", 22, dt[i], LIST_BOTTOM_TIPS_WIDTH - 20)
       table.insertto(tab, tempTab)
    end

    self.queue_ = AnimUpScrollQueue.new(contentSize, 22, color, textAlign):addTo(self.bottomBtnNode)
    self.queue_:pos(30, 0)
    self.queue_:setData(tab)
    self.queue_:startAnim()

    -- 添加数据观察器
    -- self:addPropertyObservers()
end


function ChoosePersonalRoomView:addPropertyObservers()
    -- self.nickObserverHandle_ = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "aUser.name", handler(self,self.updateNickText))
    -- self.moneyObserverHandle_ = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "aUser.money", handler(self, self.updateMoneyText))
end


function ChoosePersonalRoomView:removePropertyObservers()
    -- bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "aUser.name", self.nickObserverHandle_)
    -- bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "aUser.money", self.moneyObserverHandle_)
end


function ChoosePersonalRoomView:updateNickText(name)
    local nickTitle = bm.LangUtil.getText("SETTING","NICK").." : "
    self.nickText_:setString(nickTitle..nk.Native:getFixedWidthText("", 24, name, 200))
end

function ChoosePersonalRoomView:updateMoneyText(name)
    self.moneyText_:setString(bm.formatNumberWithSplit(nk.Native:getFixedWidthText("", 24, name, 200)))
end

function ChoosePersonalRoomView:onCreateRoomBtnClicked()
   -- dump("onCreateRoomBtnClicked=========")
    --nk.server:createPersonalRoom(nil,100,"私人房1","121312")

    local CreateRoomPopup= import("app.module.hall.personalRoomDialog.CreateRoomPopup")
    CreateRoomPopup.new():show()
end

function ChoosePersonalRoomView:onQrCodeBtnClicked()
    QRCodePopup.new():show()
end

function ChoosePersonalRoomView:onInviteBtnClicked()

    InvitePopup.new():show()
    -- if device.platform == "android" or device.platform == "ios" then
    --     cc.analytics:doCommand{command = "event", args = {eventId = "hall_Invite_friends",
    --         label = "user hall_Invite_friends"}}
                    
    -- end
end

function ChoosePersonalRoomView:createListView_(isAnim, datas)
    if not self.roomList_ then
        self.roomList_ = bm.ui.ListView.new(
            {
                viewRect = cc.rect(-LIST_VIEW_WIDTH * 0.5, -LIST_VIEW_HEIGHT * 0.5, LIST_VIEW_WIDTH, LIST_VIEW_HEIGHT),
                upRefresh = handler(self, self.onRoomListUpFrefresh_)
            }, 
            ChoosePersonalRoomItem
        )
        :pos(0, LIST_VIEW_POSY)
        :addTo(self.roomListNode_)

        self.roomList_:addEventListener("ITEM_EVENT", handler(self, self.onItemEvent_))

        local notOpenTipsParam = {
            frontSize = 36,
            color = cc.c3b(0xeb, 0x4d, 0x4d)
        }

        self.perRoomNotAccessTip_ = display.newTTFLabel({text = bm.LangUtil.getText("HALL", "NOTOPEN"), size = notOpenTipsParam.frontSize, color = notOpenTipsParam.color, align = ui.TEXT_ALIGN_CENTER})
            :pos(0, LIST_VIEW_POSY)
            :addTo(self.roomListNode_)
            :hide()
    end

    if datas then
        if isAnim then
            for _,v in pairs(datas) do
                if type(v) == "table" then
                    v.isAnim = true
                end
            end
        end
        -- self.roomList_:setData(datas)

        if nk.OnOff:check("privateroom") then
            --todo
            self.roomList_:appendData(datas)
        else
            self.perRoomNotAccessTip_:show()

            self.createRoomBtn_:setButtonEnabled(false)
            self.inviteBtn_:setButtonEnabled(false)
        end
        
        -- self:refleshRoomList()
    end
end

function ChoosePersonalRoomView:checkPayGuide(roomData)
    
-- dump(roomData, "roomData:=================")
    local roomDataFliter = {}
    roomDataFliter.blind = roomData.baseAnte
    roomDataFliter.minBuyIn = roomData.minAnte
    roomDataFliter.maxBuyIn = roomData.maxAnte
    
    local isSuccLoginRoom = PayGuidePopMgr.new(roomDataFliter):show()

    return isSuccLoginRoom

end

function ChoosePersonalRoomView:onRoomListUpFrefresh_()
    self:requestRoomListDataByPage()
end

function ChoosePersonalRoomView:onItemEvent_(evt)
    -- dump(evt.data,"ChoosePersonalRoomView:onItemEvent_")

    local canLogin = self:checkPayGuide(evt.data)
    if not canLogin then
        dump(tostring(canLogin),"checkPayGuide")
        return
    end

    local roomData = evt.data
    if roomData then
        if roomData.hasPwd == 1 then
            --有密码，弹密码框
            PswEntryPopup.new(roomData, handler(self, self.onPswPopCallback)):show()
            --传入这个回调 handler(self,self.onPswPopCallback)
        else
            --无密码，直接进
            nk.server:loginPersonalRoom(nil, roomData.tableID)
        end
    end
end

function ChoosePersonalRoomView:onPswPopCallback(psw,roomData)
    if not psw or not roomData then
        return
    end

    nk.server:loginPersonalRoom(nil,roomData.tableID,psw)
    dump(psw,"psw==onPswPopCallback")
end

function ChoosePersonalRoomView:refleshRoomList()
   self.roomList_:setScrollContentTouchRect()
   self.roomList_:update()
end

function ChoosePersonalRoomView:playShowAnim()
    local animTime = self.controller_.getAnimTime()

    local roomListPosYAdj = 50
    transition.moveTo(self.roomListNode_, {time = animTime, y = LIST_NODE_POSY + roomListPosYAdj, delay = animTime*1.8,easing = "BACKOUT",onComplete=
        handler(self,self.onRoomListShowAnimComplete)})
end

function ChoosePersonalRoomView:onRoomListShowAnimComplete()
    local testData = {
        [1] = {roomID = 121,tableID = 121,ownerUID = 555,roomName = "私人房1",baseChip = 2123,fee = 55,minAnte=123,maxAnte = 454,userCount = 5,hasPwd = 0,createTm = 213131312},
        [2] = {roomID = 1213,tableID = 1213,ownerUID = 555,roomName = "私人房2",baseChip = 2123,fee = 1231,minAnte=12,maxAnte = 454,userCount = 7,hasPwd = 1,createTm = 213131312},
        [3] = {roomID = 1313,tableID = 1313,ownerUID = 555,roomName = "私人房3",baseChip = 2123,fee = 22112,minAnte=1233,maxAnte = 454,userCount = 9,hasPwd = 2,createTm = 213131312},
        [4] = {roomID = 11313,tableID = 11313,ownerUID = 555,roomName = "私人房4",baseChip = 2123,fee = 211,minAnte=5123,maxAnte = 454,userCount = 3,hasPwd = 0,createTm = 213131312},
        [5] = {roomID = 12313,tableID = 12313,ownerUID = 555,roomName = "私人房5",baseChip = 2123,fee = 3,minAnte=1523,maxAnte = 454,userCount = 4,hasPwd = 1,createTm = 213131312},
        [6] = {roomID = 21313,tableID = 21313,ownerUID = 555,roomName = "私人房6",baseChip = 2123,fee = 45,minAnte=16723,maxAnte = 454,userCount = 5,hasPwd = 0,createTm = 213131312},
        [7] = {roomID = 1313,tableID = 1313,ownerUID = 555,roomName = "私人房7",baseChip = 2123,fee = 15,minAnte=7,maxAnte = 454,userCount = 5,hasPwd = 0,createTm = 213131312},
        [8] = {roomID = 13,tableID = 13,ownerUID = 555,roomName = "私人房8",baseChip = 2123,fee = 854,minAnte=65,maxAnte = 454,userCount = 7,hasPwd = 1,createTm = 213131312},
        [9] = {roomID = 313,tableID = 313,ownerUID = 555,roomName = "私人房9",baseChip = 2123,fee = 54,minAnte=4,maxAnte = 454,userCount = 6,hasPwd = 0,createTm = 213131312},
        [10] = {roomID = 1133,tableID = 1133,ownerUID = 555,roomName = "私人房10",baseChip = 2123,fee = 654,minAnte=14423,maxAnte = 454,userCount = 5,hasPwd = 1,createTm = 213131312},
        [11] = {roomID = 1113,tableID = 1113,ownerUID = 555,roomName = "私人房11",baseChip = 2123,fee = 66,minAnte=44,maxAnte = 454,userCount = 6,hasPwd = 1,createTm = 213131312},
        [12] = {roomID = 11513,tableID = 11513,ownerUID = 555,roomName = "私人房12",baseChip = 2123,fee = 454,minAnte=66,maxAnte = 454,userCount = 9,hasPwd = 0,createTm = 213131312},
        [13] = {roomID = 11633,tableID = 11633,ownerUID = 555,roomName = "私人房13",baseChip = 2123,fee = 45,minAnte=556,maxAnte = 454,userCount = 0,hasPwd = 1,createTm = 213131312},
        [14] = {roomID = 131,tableID = 131,ownerUID = 555,roomName = "私人房14",baseChip = 2123,fee = 54,minAnte=755,maxAnte = 454,userCount = 0,hasPwd = 0,createTm = 213131312},
    }

    -- self:createListView_(true,testData)
    if nk.OnOff:check("privateroom") then
        --todo
        self.cur_pages = 0
        self.total_pages = 1
        self:requestRoomListDataByPage()
    else
        self.perRoomNotAccessTip_:show()

        self.createRoomBtn_:setButtonEnabled(false)
        self.inviteBtn_:setButtonEnabled(false)
    end
end

function ChoosePersonalRoomView:requestRoomListDataByPage()
    if self.cur_pages >= self.total_pages then
        dump("not data","requestRoomListDataByPage")
        return
    end

    self.cur_pages = self.cur_pages + 1
    nk.server:getPersonalRoomList(nil, self.cur_pages, ROOM_LIST_PAGE_ITEMS_NUM)
end

function ChoosePersonalRoomView:onGetPersonalRoomList(isAnim, data)
    -- dump(data, "ChoosePersonalRoomView:onGetPersonalRoomList.data :==================")

    for k,v in pairs(data.roomlist) do
        print(k, v.tableID)
    end

    local total_pages = data.total_pages
    local cur_pages = data.cur_pages
    local roomlist = data.roomlist

    local oldPage = self.cur_pages
    self.total_pages = data.total_pages
    self.cur_pages = data.cur_pages

    if not self.roomListDatas_ then
        self.roomListDatas_ = {}
    end

    local tempArr = {}
    local count = 0
    for _,v in pairs(roomlist) do
        count = 0
        for __,vv in pairs(self.roomListDatas_) do
            if vv.tableID == v.tableID then
                break
            end
            count = count + 1
           
        end
        if count == #self.roomListDatas_ then
            table.insert(tempArr,v)
        end
       
    end
    table.insertto(self.roomListDatas_,tempArr)
    self:createListView_(isAnim,tempArr)
end

function ChoosePersonalRoomView:onSearchPersonalRoom(data)
    local ret = data.ret
    if ret == 0 then
         if data.hasPwd == 1 then
            PswEntryPopup.new(data, handler(self, self.onPswPopCallback)):show() 
        else
            nk.server:loginPersonalRoom(nil,data.tableID)
        end
    end
end

function ChoosePersonalRoomView:onCreatePersonalRoom(data)
    local ret = data.ret
    if ret == 0 then
        --创建成功直接进入房间
        nk.server:loginPersonalRoom(nil,data.tableID,(data.hasPwd == 1 and data.pwd or nil))
    end
end

function ChoosePersonalRoomView:onLoginPersonalRoom(data)
    local ret = data.ret
    local tid = data.tid

    --0成功 1房间不存在 2玩家已在某个房间 3房间已满 4密码错误
    if ret == 0 then
        nk.server:loginRoom(tid)
    elseif ret == 1 then

    elseif ret == 2 then

    elseif ret == 3 then

    elseif ret == 4 then 
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("HALL", "PERSONAL_ENTER_PSW_ERR"))
    end
end

function ChoosePersonalRoomView:playHideAnim()
    self:removeFromParent()
end

function ChoosePersonalRoomView:onReturnClick_()
    self.controller_:showMainHallView()
end

function ChoosePersonalRoomView:onHelpClick_()
    HelpPopup.new():show()
end

function ChoosePersonalRoomView:onSearchClick_()
    HallSearchRoomPanel.new(self.controller_,handler(self,self.onSearchPanelCallback)):showPanel()
end


function ChoosePersonalRoomView:onSearchPanelCallback(tableID)
    nk.server:searchPersonalRoom(nil,tableID)
end

function ChoosePersonalRoomView:onStoreClick_()
    StorePopup.new():showPanel()
end

function ChoosePersonalRoomView:onChipClick_(preCall)
    local playerCap = 9
    if ChoosePersonalRoomView.PLAYER_LIMIT_SELECTED == 2 then
        playerCap = 5
    end
    self.controller_:getEnterRoomData({tt = self.roomType_, sb = preCall, pc = playerCap})
end

function ChoosePersonalRoomView:onCleanup()
    nk.http.cancel(self.playerCountRequestId_)
    -- self:removePropertyObservers()
    self:stopAction(self.action_)
end

return ChoosePersonalRoomView