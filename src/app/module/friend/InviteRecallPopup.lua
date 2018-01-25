--
-- Author: johnny@boomegg.com
-- Date: 2016-04-12 13:22:07
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

local POPUP_WIDTH = 724
local POPUP_HEIGHT = 508
local TOP_BG_H = 80
local BOTTOM_BG_H = 85
local MIDDE_BG_H = 78
local logger = bm.Logger.new("InviteRecallPopup")
local InviteTabBar = import(".InviteTabBar")
local InviteListItem = import(".InviteListItemEx")
local RecallListItem = import(".RecallListItem")
local LIST_POS_Y = -48
local friendDataGlobal = {}
local InviteRecallPopup = class("InviteRecallPopup", function ()
    return display.newNode()
end)

function InviteRecallPopup:ctor(hall, defaultTabIdx)
    self.hall_ = hall
    self:setNodeEventEnabled(true)

    display.addSpriteFrames("recall_friend.plist", "recall_friend.png")
    self.background_ = display.newScale9Sprite("#recall_bg.png", 0, 0, cc.size(POPUP_WIDTH, POPUP_HEIGHT))
        :addTo(self)
    --self.background_:setCapInsets(cc.rect(2, 96, 4, 1))
    self.background_:setTouchEnabled(true)
    self.background_:setTouchSwallowEnabled(true)

    self.top_ = display.newScale9Sprite("#recall_bg_top.png",0,0,cc.size(POPUP_WIDTH,TOP_BG_H))
    :addTo(self)
    :pos(0,POPUP_HEIGHT/2 - TOP_BG_H/2)

    self.middle_ = display.newScale9Sprite("#recall_middle_bg.png",0,0,cc.size(POPUP_WIDTH-2,MIDDE_BG_H))
    :addTo(self)
    :pos(0,POPUP_HEIGHT/2 - TOP_BG_H-MIDDE_BG_H/2)

    self.bottom_ = display.newScale9Sprite("#recall_bg_bottom.png",0,0,cc.size(POPUP_WIDTH,BOTTOM_BG_H))
    :addTo(self)
    :pos(0,-(POPUP_HEIGHT/2 - BOTTOM_BG_H/2))

    bm.TouchHelper.new(display.newSprite("#invite_popup_close_btn_up.png")
            :pos(-POPUP_WIDTH * 0.5, POPUP_HEIGHT * 0.5)
            :addTo(self, 4, 4),

        function (target, evtName)
            if evtName == bm.TouchHelper.CLICK then
                nk.SoundManager:playSound(nk.SoundManager.CLOSE_BUTTON)
                nk.PopupManager:removePopup(self)
            end
        end)

    -- 一级tab bar
    self.mainTabBar_ =InviteTabBar.new({popupWidth = 650, iconOffsetX = 10, 
        iconTexture = {{"#recall_coin_down.png", "#recall_coin_up.png"},
            {"#recall_ticket_down.png", "#recall_ticket_up.png"}}, 
        btnText = bm.LangUtil.getText("FRIEND", "INVITE_TAB")})
        :pos(0, POPUP_HEIGHT * 0.5 - nk.ui.CommonPopupTabBar.TAB_BAR_HEIGHT * 0.5 - 8)
        :addTo(self)

    self.defaultTabSelIdx_ = defaultTabIdx or 1

    -- cancel button
    local frame = display.newSprite("#recall_big_unslect.png"):pos(-90 + 8 + 16, 0)
    self.selected_ = display.newSprite("#recall_big_select.png"):pos(-90 + 8 + 16, 0):hide()
    -- local btn

    self.setSelectedAll_ = function()
        if not self.userItems_ or #self.userItems_ == 0 then
            self.selected_:hide()
            return
        end
        local selectedNum = self:getSelectedItemNum()
        -- dump(#self.userItems_,"len")
        -- dump(selectedNum,"selectedNum")

        if nk.OnOff:check("inviteNumUnlimit") then
            --todo
            if --[[selectedNum == 50 or]] selectedNum == #self.userItems_ then
                self.selected_:show()
                self.btnSelectAll_:setButtonLabelString("normal", bm.LangUtil.getText("FRIEND", "DESELECT_ALL"))
            else
                self.selected_:hide()
                self.btnSelectAll_:setButtonLabelString("normal", bm.LangUtil.getText("FRIEND", "SELECT_ALL"))
            end
        else
            --todo
            if selectedNum == 50 or selectedNum == #self.userItems_ then
                self.selected_:show()
                self.btnSelectAll_:setButtonLabelString("normal", bm.LangUtil.getText("FRIEND", "DESELECT_ALL"))
            else
                self.selected_:hide()
                self.btnSelectAll_:setButtonLabelString("normal", bm.LangUtil.getText("FRIEND", "SELECT_ALL"))
            end
        end
    end

    self.btnSelectAll_ = cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#common_transparent_skin.png"}, {scale9=true})
        :setButtonLabel("normal", display.newTTFLabel({text = bm.LangUtil.getText("FRIEND", "SELECT_ALL"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 22, align = ui.TEXT_ALIGN_CENTER}))
        :setButtonLabelOffset(20, 0)
        :setButtonSize(140, 60)
        :pos(-POPUP_WIDTH * 0.5 + 90 + 10, POPUP_HEIGHT/2 - TOP_BG_H-MIDDE_BG_H/2+8)
        :addTo(self, 5, 5)
        :add(frame)
        :add(self.selected_)
        :onButtonClicked(buttontHandler(self, self.onSelectAllBtnCallBack_))

    -- invite button  382  46
    cc.ui.UIPushButton.new({normal = "#recall_send_up.png", pressed = "#recall_send_down.png"},{scale9=true})
        :setButtonSize(137,61)
        :setButtonLabel("normal", display.newTTFLabel({text = bm.LangUtil.getText("FRIEND", "SEND_INVITE"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 22, align = ui.TEXT_ALIGN_CENTER}))
        :pos(POPUP_WIDTH * 0.5 - 80, POPUP_HEIGHT/2 - TOP_BG_H-MIDDE_BG_H/2)
        :addTo(self, 6, 6)
        :onButtonClicked(buttontHandler(self, self.onBtnClick_))

	self.reloadIcon_ = cc.ui.UIPushButton.new({normal="#recall_reload_up.png",pressed = "#recall_reload_down.png"})
        :onButtonClicked(handler(self, self.reloadIconClick_))
        :pos(167, POPUP_HEIGHT/2 - TOP_BG_H-MIDDE_BG_H/2+10)
        :addTo(self, 11, 11)
    self.searchIcon_ = display.newSprite("#recall_search_up.png")
        :pos(-150, POPUP_HEIGHT/2 - TOP_BG_H-MIDDE_BG_H/2+10)
        :addTo(self, 12, 12)

    self.searchEdit_ = cc.ui.UIInput.new({
        size = cc.size(284, 44),
        align=ui.TEXT_ALIGN_CENTER - 30,
        image="#recall_input_friend.png",
        x = 10,
        y = POPUP_HEIGHT/2 - TOP_BG_H-MIDDE_BG_H/2 +10,
        listener = handler(self, self.onSearchStart_)
    })
    self.searchEdit_:setFontName(ui.DEFAULT_TTF_FONT)
    self.searchEdit_:setFontSize(24)
    self.searchEdit_:setFontColor(cc.c3b(0x92, 0x8d, 0x8d))
    self.searchEdit_:setPlaceholderFontName(ui.DEFAULT_TTF_FONT)
    self.searchEdit_:setPlaceholderFontSize(22)
    self.searchEdit_:setPlaceholderFontColor(cc.c3b(0x52,0x68,0xa2))
    self.searchEdit_:setPlaceHolder(bm.LangUtil.getText("FRIEND", "SEARCH_FRIEND"))
    self.searchEdit_:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.searchEdit_:setReturnType(cc.KEYBOARD_RETURNTYPE_GO)
    self.searchEdit_:addTo(self, 10, 10)


    -- invite tip
    self.inviteTip_ = display.newTTFLabel({text = bm.LangUtil.getText("FRIEND", "INVITE_SELECT_TIP", 0, 0), color = cc.c3b(0x52,0x68,0xa2), size = 16, align = ui.TEXT_ALIGN_CENTER})
        :pos(10, POPUP_HEIGHT * 0.5 - 80 -60-5)
        :addTo(self, 7, 7)

    self.selectTips_  = display.newTTFLabel({text = bm.LangUtil.getText("FRIEND", "RECALL_SELECT_NUM", 0), color = cc.c3b(0x52,0x68,0xa2), size = 16, align = ui.TEXT_ALIGN_CENTER})
    :pos(-250, POPUP_HEIGHT * 0.5 - 80 -60-5)
    :addTo(self, 30, 30)
    --self:setLoading(true)
    --nk.Facebook:getInvitableFriends(handler(self, self.getFriendsData,nk.userData.inviteFriendLimit))

    
    local strArr = bm.LangUtil.getText("FRIEND", "INVITE_RECALL_INFO")
    local str = ""
    for i=1,2 do
        str = str..strArr[i].."\n"
    end
    local lastStr = bm.LangUtil.getText("FRIEND", "INVITE_RECALL_INFO3", "0/2")
    str = str..lastStr
    self.infomation_ = display.newTTFLabel({text =str , color = styles.FONT_COLOR.LIGHT_TEXT, size = 20, dimensions = cc.size(POPUP_WIDTH, BOTTOM_BG_H),align = ui.TEXT_ALIGN_LEFT})
    :addTo(self,20,20)
    :align(display.LEFT_CENTER)
    :pos(-POPUP_WIDTH/2+5,-(POPUP_HEIGHT/2 - BOTTOM_BG_H/2)-3)

    self.ticketbg1_ = display.newSprite("#recall_ticket_bg.png")
    :addTo(self, 21, 21)
    :pos(POPUP_WIDTH / 2 - 120, - (POPUP_HEIGHT / 2 - BOTTOM_BG_H / 2))

    self.ticketbg2_ = display.newSprite("#recall_ticket_bg.png")
    :addTo(self, 22, 22)
    :pos(POPUP_WIDTH / 2 - 120 + 65, - (POPUP_HEIGHT / 2 - BOTTOM_BG_H / 2))
    self.ticketbg2_:setScaleX(- 1)

    self.ticket_ = display.newSprite("#recall_chips_pic.png")
        :addTo(self, 23, 23)
        :pos(POPUP_WIDTH / 2 - 95, - (POPUP_HEIGHT / 2 - BOTTOM_BG_H / 2) + 5)
    self.ticket_:setScale(.9)
    
     -- self.goMatch_ = cc.ui.UIPushButton.new({normal = "#recall_to_match_up.png", pressed = "#recall_to_match_down.png"},{scale9=true})
     --    :setButtonSize(133,73)
     --    :setButtonLabel("normal", display.newTTFLabel({text = T("去参赛"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 22, align = ui.TEXT_ALIGN_CENTER}))
     --    :pos(POPUP_WIDTH/2-95,-(POPUP_HEIGHT/2 - BOTTOM_BG_H/2))
     --    :addTo(self, 24, 24)
     --    :onButtonClicked(buttontHandler(self, self.onGoMatch))

    --进度
    local progressWidth = 117
    local progressHeight = 14
    local progressMarginRight = 182
    local progressHeightAdjust = 20
    self.progress = nk.ui.ProgressBar.new(
        "#recall_progress_bg.png", 
        "#recall_progress_second.png", 
        {
            bgWidth = progressWidth, 
            bgHeight = progressHeight, 
            fillWidth = progressHeight, 
            fillHeight = progressHeight - 2
        }
    ):addTo(self, 25, 25):setValue(0.0)
    self.progress:setAnchorPoint(cc.p(1, 0.5))
    self.progress:pos(POPUP_WIDTH / 2 - 145, - (POPUP_HEIGHT / 2 - BOTTOM_BG_H / 2) - 30)

    --进度文字 
    self.progressLabel = display.newTTFLabel({
            text = "",
            size = 18,
            color = styles.FONT_COLOR.LIGHT_TEXT,
            align = ui.TEXT_ALIGN_CENTER
        }):addTo(self.progress):pos(progressWidth/2, 0) 

    self.progress:setValue(0 / 8)
    self.progressLabel:setString(0 .. "/" .. 8)

    self.myTicket_ = display.newTTFLabel({text = "x0", color = cc.c3b(0xff,0xd2,0x00), size = 22, align = ui.TEXT_ALIGN_CENTER})
    self.myTicket_:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER_LEFT])
    self.myTicket_:pos(POPUP_WIDTH / 2 - 72, -(POPUP_HEIGHT / 2 - BOTTOM_BG_H / 2) + 26)
        :addTo(self, 26, 26)

    self:setViewStatus(false)
    self:getInviteData()
end

function InviteRecallPopup:setViewStatus(isshow)
    if isshow then
        self.bottom_:show()
        self.ticketbg2_:show()
        self.ticketbg1_:show()
        self.ticket_:show()
        self.infomation_:show()
        -- self.goMatch_:show()
        self.myTicket_:show()
        self.progress:show()
        self.selectTips_:show()
    else
        self.bottom_:hide()
        self.ticketbg2_:hide()
        self.ticketbg1_:hide()
        self.ticket_:hide()
        self.infomation_:hide()
        -- self.goMatch_:hide()
        self.myTicket_:hide()
        self.progress:hide()
        self.selectTips_:hide()
    end
end
function InviteRecallPopup:getInviteData()
    self.getInitRecallReq_ = nk.http.getInitializeRecall(nk.userData["aUser.mid"], function(data)

        -- dump(data, "getInitializeRecall.data :===================")
        self.progress:setValue(checkint(data.friends or 0) / 8)
        self.progressLabel:setString(checkint(data.friends or 0) .. "/" .. 8)
        self.myTicket_:setString("x" .. bm.formatBigNumber(data.sum or 0))
        local strArr = bm.LangUtil.getText("FRIEND", "INVITE_RECALL_INFO")
        local str = ""
        for i=1,2 do
            str = str..strArr[i].."\n"
        end
        local lastStr = bm.LangUtil.getText("FRIEND", "INVITE_RECALL_INFO3",data.count .. "/2")
        str = str..lastStr
        self.infomation_:setString(str)

    end, function(errData)
        dump(errData, "getInitializeRecall.errData :===============")
    end)
end

function InviteRecallPopup:reloadIconClick_()
    if self.selectTab_ == 2 and self.reqGetRecallFriendId_ then
        return 
    end
    self.searchStr_ = ""
    self.searchEdit_:setText("")
    self:filterData()
end
function InviteRecallPopup:onGoMatch()
    --onMatchHallClick
    if self.hall_ and self.hall_["onMatchHallClick"]then
        self.hall_:onMatchHallClick()
        nk.SoundManager:playSound(nk.SoundManager.CLOSE_BUTTON)
        nk.PopupManager:removePopup(self)
    end
end
function InviteRecallPopup:searchIconClick_()
    self.searchStr = self.searchEdit_:getText()
    self:filterData()
end
function InviteRecallPopup:setNoDataTip(noData)
    if noData then
        if not self.noDataTip_ then
            self.noDataTip_ = display.newTTFLabel({text = bm.LangUtil.getText("FRIEND", "NO_FRIEND_TIP"), color = styles.FONT_COLOR.GREY_TEXT, size = 24, align = ui.TEXT_ALIGN_CENTER})
                :pos(0, LIST_POS_Y)
                :addTo(self, 8, 8)
        end
    else
        if self.noDataTip_ then
            self.noDataTip_:removeFromParent()
            self.noDataTip_ = nil
        end
    end
end
function InviteRecallPopup:onSearchStart_(event)
    print("event is " .. event)
    if event == "changed" then
        -- 输入框内容发生变化是
        self.searchStr_ = self.searchEdit_:getText()
    elseif event == "returnGo" then
        self:filterData()
    elseif event == "return" then
        self:filterData()
    end
end

function InviteRecallPopup:filterData()
    if self.scrollView_ then
        self.scrollView_:hide()
    end
    self:setNoDataTip(false)
    if self.searchStr_ and self.searchStr_ ~= nil then
        self:onGetData_(true, friendDataGlobal, self.searchStr_)
    end
end
function InviteRecallPopup:show(openType)
    self.openType = openType;
    nk.PopupManager:addPopup(self)
end

function InviteRecallPopup:onShowed()
    -- 延迟设置，防止list出现触摸边界的问题
    self.mainTabBar_:onTabChange(handler(self, self.onMainTabChange_))
    if self.scrollView_ then
        -- self.scrollView_:setScrollContentTouchRect()
        self.scrollView_:update()
    end

    if self.defaultTabSelIdx_ ~= 1 then
        --todo
        self.mainTabBar_:gotoTab(self.defaultTabSelIdx_)
    end
end
function InviteRecallPopup:onMainTabChange_(selectedTab)   
    self.selectTab_ = selectedTab
    
    if self.scrollView_ then
        --self.inviteUserNode_:removeFromParent()
        self.inviteUserNode_ = nil
        self.scrollView_:removeFromParent()
        self.scrollView_ = nil
    end
    if selectedTab == 2 then
        self:setViewStatus(true)
        if not self.recallData_ or #self.recallData_ == 0 then
            self.reqGetRecallFriendId_ = nk.http.getRecallFriends(nk.userData["aUser.mid"], function(data)
                self.reqGetRecallFriendId_  = nil
                if self then
                    --todo
                    -- dump(data, "getRecallFriends.retData :=====================")
                    self.reqGetRecallFriendId_ = nil
                    self.recallData_ = data
                    if self.recallData_ and #self.recallData_ > 0 then

                        if self.setNoDataTip then
                            --todo
                            self:setNoDataTip(false)
                        end

                        for i=1, #self.recallData_ do
                            self.recallData_[i].url = self.recallData_[i].micon
                            self.recallData_[i].id = self.recallData_[i].sitemid
                        end

                        if self.selectTab_ == 2 then
                            if self.onGetData_ then
                                --todo
                                self:onGetData_(true, self.recallData_, self.searchStr_)
                            end
                        end
                    else
                        if self.selectTab_ == 2 then
                            --todo
                            if self.setNoDataTip then
                                --todo
                                self:setNoDataTip(true)
                            end
                        end

                        self.userItems_ = nil
                        self.userItems_ = {}
                        friendDataGlobal = {}
                    end
                end

            end, function(errData)

                dump(errData, "getRecallFriends.errData :=====================")
                self.reqGetRecallFriendId_ = nil

                if self.selectTab_ == 2 then
                    --todo
                    if self and self.setNoDataTip then
                        --todo
                        self:setNoDataTip(true)
                    end
                end
                self.userItems_ = nil
                self.userItems_ = {}
                friendDataGlobal = {}
            end)
        else
            self:onGetData_(true,self.recallData_,self.searchStr_)
        end
        self:setSelecteTip()
        self.selectTips_:setString(bm.LangUtil.getText("FRIEND", "RECALL_SELECT_NUM", 0))
    else
        self:setViewStatus(false)
        if not self.friendData_ or #self.friendData_ == 0 then
            self:setLoading(true)
            self:setNoDataTip(false)
            nk.Facebook:getInvitableFriends(handler(self, self.getFriendsData), nk.userData.inviteFriendLimit)
        else
            self:setNoDataTip(false)
            self:onGetData_(true, self.friendData_, self.searchStr_)
        end
    end
end

function InviteRecallPopup:getFriendsData(success,friendData,filterStr)
    -- dump(json.encode(friendData), "nk.Facebook:getInvitableFriends.data :================")
    -- dump(filterStr, "nk.Facebook:getInvitableFriends.filterStr :=================")
    
    if self.selectTab_ == 1 then
        -- 如果授权不成功，不发送筛选请求
        if success then
            --todo

            if nk.OnOff:check("inviteFilter") then
                --todo
                local userHeadPics = {}

                for i, data in ipairs(friendData) do
                    local picName = self:getUserHeadImgName(data.url)
                    table.insert(userHeadPics, picName)
                end

                local userHeadImgPicNameList = table.concat(userHeadPics, ",")

                nk.http.getFriendFliterData(userHeadImgPicNameList, function(retData)
                    -- body
                    -- dump(retData, "getFriendFliterData.retData :=======================")

                    -- local friendFliteredData = json.decode(retData.data)
                    -- dump(friendFliteredData, "getFriendFliterData.retData.data<json.decode> :====================")
                    if self.selectTab_ == 1 then
                        --todo
                        local friendFliteredData = self:getFriendFliteredData(friendData, retData)
                        if self and self.onGetData_ then
                            --todo
                            self.friendData_ = friendFliteredData
                            self:onGetData_(success, friendFliteredData, filterStr)
                        end
                    else
                        self:setLoading(false)
                    end
                end, function(errData)
                    -- body
                    dump(errData, "getFriendFliterData.errData :=================")

                    if self then
                        --todo
                        if self.setLoading then
                            --todo
                            self:setLoading(false)
                        end

                        if self.setNoDataTip then
                            --todo
                            self:setNoDataTip(true)
                        end
                    end
                end)
            else
                self.friendData_ = friendData
                self:onGetData_(success, friendData, filterStr)
            end
        end
    end
end

function InviteRecallPopup:onGetData_(success, friendData, filterStr)
    
    friendDataGlobal = clone(friendData)
    -- print("the global data:" .. #friendDataGlobal)
    -- print("the friendData:" .. #friendData)
    self:setLoading(false)
    if success then
        -- for test
        -- nk.userDefault:setStringForKey(nk.cookieKeys.FACEBOOK_INVITED_NAMES, "")
        -- 排除今日邀请过的
        local invitedNames = nk.userDefault:getStringForKey(nk.cookieKeys.FACEBOOK_INVITED_NAMES, "")
        logger:debug("invitedNames:" .. invitedNames)        
        self.pageNum_ = checkint(nk.userDefault:getStringForKey(nk.cookieKeys.FACEBOOK_INVITED_PAGE, 0))        

        if invitedNames ~= "" then
            local namesTable = string.split(invitedNames, "#")
            if namesTable[1] ~= os.date("%Y%m%d") then
                logger:debug("clear invited names")
                nk.userDefault:setStringForKey(nk.cookieKeys.FACEBOOK_INVITED_NAMES, "")
                
                if nk.config.INVITE_SORT_TYPE == 2 then
                    -- 保存页数                
                    self.pageNum_ = self.pageNum_ + 1
                    if self.pageNum_ > math.ceil(#friendData / 50) then
                        self.pageNum_ = 1
                    end   
                    nk.userDefault:setStringForKey(nk.cookieKeys.FACEBOOK_INVITED_PAGE, self.pageNum_)
                end
                nk.userDefault:flush()
            else
                table.remove(namesTable, 1)
                for _, name in pairs(namesTable) do
                    local i, max = 1, #friendData
                    while i <= max do
                        if friendData[i].name == name then
                            logger:debug("remove invited name -> ", name)
                            table.remove(friendData, i)
                            i = i - 1
                            max = max - 1
                        end
                        i = i + 1
                    end
                end
                if nk.config.INVITE_SORT_TYPE == 2 and pageNum == 0 then
                    self.pageNum_ = 1
                    nk.userDefault:setStringForKey(nk.cookieKeys.FACEBOOK_INVITED_PAGE, pageNum)
                    nk.userDefault:flush()
                end
            end
        end
        if filterStr and filterStr ~= "" then
            print("string.lower(filterStr):" .. string.lower(filterStr))
            local tmpData = {}
            for k, v in pairs(friendData) do
                if (string.find(string.lower(v.name),string.lower(filterStr)) ~= nil) then
                    table.insert(tmpData,v)
                end
            end
            friendData = tmpData
        end

        friendData = self:sortFreind_(friendData)
        self.maxData_ = #friendData
        -- 只展示前300个
        if self.maxData_ >= 300 then
            self.maxData_ = 300
        elseif self.maxData_ == 0 then
            self:setNoDataTip(true)
            return
        end

        if self.scrollView_ then
            self.scrollView_:removeFromParent()
            self.scrollView_ = nil
            self.inviteUserNode_ = nil
        end
        
        self.scrollView_ = bm.ui.ScrollView.new()
        self.inviteUserNode_ = display.newNode()
        local nodeWidth = POPUP_WIDTH
        local nodeHeight = math.ceil(self.maxData_ / 3) * 100
        self.inviteUserNode_:setContentSize(cc.size(nodeWidth, nodeHeight))
        local UseItem
        if self.selectTab_ == 2 then
            UseItem = RecallListItem
        else
            UseItem = InviteListItem
        end
        self.userItems_ = nil
        self.userItems_ = {}
        for i = 1, self.maxData_ do
            friendData[i].chips =  nk.userData.inviteSendChips
            self.userItems_[i] = UseItem.new(friendData[i], self.scrollView_, self, i)
                :pos(
                    -nodeWidth * 0.5 + UseItem.ITEM_WIDTH * 0.5 + (i + 2) % 3 * UseItem.ITEM_WIDTH, 
                    nodeHeight * 0.5 - UseItem.ITEM_HEIGHT * 0.5 - math.floor((i - 1) / 3) * UseItem.ITEM_HEIGHT
                )
                :addTo(self.inviteUserNode_)
                self.userItems_[i]:setScale(.9)
        end
        local outterSelf = self
        local innerSelf = self.scrollView_
        self.scrollView_.onScrolling = function()
            if innerSelf.viewRectOriginPoint_ and #outterSelf.userItems_ > 0 then
                for _, item in ipairs(outterSelf.userItems_) do
                    local tempWorldPt = outterSelf.inviteUserNode_:convertToWorldSpace(cc.p(item:getPosition()))
                    if tempWorldPt.y > innerSelf.viewRectOriginPoint_.y + innerSelf.viewRect_.height + item.ITEM_HEIGHT or tempWorldPt.y < innerSelf.viewRectOriginPoint_.y - item.ITEM_HEIGHT - item.ITEM_HEIGHT then
                        item:hide()
                        if item.onItemDeactived then
                            if tempWorldPt.y - (innerSelf.viewRectOriginPoint_.y + innerSelf.viewRect_.height) > innerSelf.viewRect_.height or innerSelf.viewRectOriginPoint_.y - item.ITEM_HEIGHT - tempWorldPt.y > innerSelf.viewRect_.height then
                                item:onItemDeactived()
                            end
                        end
                    else
                        item:show()
                        if item.lazyCreateContent then
                            item:lazyCreateContent()
                        end
                    end
                end
            end
        end
        if self.selectTab_ == 2 then
            self.scrollView_:setViewRect(cc.rect(-POPUP_WIDTH * 0.5, - (POPUP_HEIGHT - TOP_BG_H - MIDDE_BG_H - BOTTOM_BG_H - 10) * 0.5, POPUP_WIDTH, POPUP_HEIGHT - TOP_BG_H - MIDDE_BG_H - BOTTOM_BG_H - 10))
            self.scrollView_:setScrollContent(self.inviteUserNode_)
            self.scrollView_:pos(0, LIST_POS_Y + 12):addTo(self, 2, 2)
        else
            self.scrollView_:setViewRect(cc.rect(-POPUP_WIDTH * 0.5, -(POPUP_HEIGHT - TOP_BG_H-MIDDE_BG_H - 10) * 0.5, POPUP_WIDTH, POPUP_HEIGHT - TOP_BG_H-MIDDE_BG_H - 10))
            self.scrollView_:setScrollContent(self.inviteUserNode_)
            self.scrollView_:pos(0, LIST_POS_Y-30):addTo(self, 2, 2)
        end
        
        self.scrollView_:update()
        -- self.scrollView_:update()

        self:onSelectAllBtnCallBack_()
    else
        self.userItems_ = nil
        self.userItems_ = {}
        self:setNoDataTip(true)
    end

    self:setSelecteTip()
end

function InviteRecallPopup:sortFreind_(friendData)
    -- 排序好友列表
    local count = #friendData
    if nk.config.INVITE_SORT_TYPE == 2 and count > 50 then
        --随机固定后分页邀请, 使好友的曝光度均等                
        math.randomseed(2015)
        for i=1, count do
            local j,k = math.random(count), math.random(count)
            friendData[j],friendData[k] = friendData[k],friendData[j]
        end
        math.newrandomseed()

        local pageStartIdx = (self.pageNum_ - 1) * 50 + 1
        local pageSizeCount = 50
        if count < pageStartIdx + 50 then
            pageSizeCount = count - pageStartIdx + 1
        end        
        local friendDataTmp = {}
        local k,j = 1,1   
        for i=1, count do
            if i < pageStartIdx or i >= pageStartIdx + pageSizeCount then              
                friendDataTmp[j] = friendData[i]
                j = j + 1
            else
                friendDataTmp[count - pageSizeCount + k] =  friendData[i]
                k = k + 1
            end
        end
        friendData = friendDataTmp
    elseif nk.config.INVITE_SORT_TYPE == 1 then
        --纯随机排序
        for i=1, count do
            local j,k = math.random(count), math.random(count)
            friendData[j],friendData[k] = friendData[k],friendData[j]
        end            
    end
    -- end
    return friendData
end

function InviteRecallPopup:setSelecteTip()
    local selectedNum = 0
    if not self.userItems_ then
        self.userItems_ = {}
    end
    for _, item in ipairs(self.userItems_) do
        if item and item.isSelected then
            --todo
            if item:isSelected() then
                --todo
                selectedNum = selectedNum + 1
            end
        end
    end
    
    if self.selectTab_ == 1 then
        
        self.inviteTip_:setString(bm.LangUtil.getText("FRIEND", "INVITE_SELECT_TIP", selectedNum, selectedNum * nk.userData.inviteSendChips))
        self.setSelectedAll_()
    else
        self.setSelectedAll_()
        self.inviteTip_:setString(T("每召回8位好友即可获得30K筹码"))
        self.selectTips_:setString(bm.LangUtil.getText("FRIEND", "RECALL_SELECT_NUM", selectedNum))
    end
end

function InviteRecallPopup:setLoading(isLoading)
    if isLoading then
        if not self.juhua_ then
            self.juhua_ = nk.ui.Juhua.new()
                :pos(0, LIST_POS_Y)
                :addTo(self, 9, 9)
        end
    else
        if self.juhua_ then
            self.juhua_:removeFromParent()
            self.juhua_ = nil
        end
    end
end

function InviteRecallPopup:getUserHeadImgName(url)
    -- body
    local p = ".*/(.*)_n%.jpg"
    local str = string.match(url, p)
    local md5str = crypto.md5(str)

    return md5str
end

function InviteRecallPopup:getFriendFliteredData(friendData, fliterArray)
    -- body

    if #fliterArray > 0 then
        --todo
        for i = #fliterArray, 1 do
            table.remove(friendData, fliterArray[i])
        end
    end

    return friendData
end

function InviteRecallPopup:getSelectedItemNum()
    local selectedNum = 0
    if self.userItems_ then
        for _, item in ipairs(self.userItems_) do
            if item and item.isSelected then
                --todo
                if item:isSelected() then
                    selectedNum = selectedNum + 1
                end
            end
        end
    end
    return selectedNum
end

function InviteRecallPopup:onSelectAllBtnCallBack_(evt)
    -- body
    if not self.userItems_ or #self.userItems_ == 0 then
        self.selected_:hide()
        self.btnSelectAll_:setButtonLabelString("normal", bm.LangUtil.getText("FRIEND", "SELECT_ALL"))
        return
    end

    local selectedNum = self:getSelectedItemNum()
    if nk.OnOff:check("inviteNumUnlimit") then
        --todo
        if --[[selectedNum == 50 or]] selectedNum == #self.userItems_ then
            for _, item in ipairs(self.userItems_) do
                item:setSelected(false)
            end
        else
            for _, item in ipairs(self.userItems_) do
                if not item:isSelected() then
                    selectedNum = selectedNum + 1
                    item:setSelected(true)
                    -- if selectedNum == 50 then
                    --     break
                    -- end
                end
            end
        end
    else
        if selectedNum == 50 or selectedNum == #self.userItems_ then
            for _, item in ipairs(self.userItems_) do
                item:setSelected(false)
            end
        else
            for _, item in ipairs(self.userItems_) do

                if item and item.isSelected then
                    --todo
                    if not item:isSelected() then
                        selectedNum = selectedNum + 1
                        item:setSelected(true)
                        if selectedNum == 50 then
                            break
                        end
                    end
                end
            end
        end
    end

    self:setSelecteTip()
end

function InviteRecallPopup:onBtnClick_(arg)
    if self.selectTab_ == 2 then
        self:onRecallClick_(arg)
    else
        self:onInviteClick_(arg)
    end
end
function InviteRecallPopup:onInviteClick_(arg)

    if not self.userItems_ then return end
    -- nk.PopupManager:removePopup(self)
    local select_tab = self.selectTab_
    
    local toIds = ""
    local names = ""
    local userHeadImgs = ""

    local toIdArr = {}
    local nameArr = {}
    local userHeadImgArr = {}

    for _, item in ipairs(self.userItems_) do
        if item:isSelected() then
            table.insert(toIdArr, item:getData().id)
            table.insert(nameArr, item:getData().name)
            table.insert(userHeadImgArr, self:getUserHeadImgName(item:getData().url))
        end
    end

    if #toIdArr > 50 then
        --todo
        local toIdArrayTmp = {}
        local nameArrayTmp = {}
        local headImgArrayTmp = {}

        for i = 1, math.ceil(#toIdArr / 50) do
            if i == math.ceil(#toIdArr / 50) then
                --todo
                for j = 1, #toIdArr - (math.ceil(#toIdArr / 50) - 1) * 50 do
                    table.insert(toIdArrayTmp, toIdArr[(i - 1) * 50 + j])
                    table.insert(nameArrayTmp, nameArr[(i - 1) * 50 + j])
                    table.insert(headImgArrayTmp, userHeadImgArr[(i - 1) * 50 + j])
                end

                toIds = table.concat(toIdArrayTmp, ",")
                names = table.concat(nameArrayTmp, "#")
                userHeadImgs = table.concat(headImgArrayTmp, ",")

                self:reqSendInvites(toIds, names, userHeadImgs)
            else
                for j = 1, 50 do
                    table.insert(toIdArrayTmp, toIdArr[(i - 1) * 50 + j])
                    table.insert(nameArrayTmp, nameArr[(i - 1) * 50 + j])
                    table.insert(headImgArrayTmp, userHeadImgArr[(i - 1) * 50 + j])
                end

                toIds = table.concat(toIdArrayTmp, ",")
                names = table.concat(nameArrayTmp, "#")
                userHeadImgs = table.concat(headImgArrayTmp, ",")

                self:reqSendInvites(toIds, names, userHeadImgs)
            end
        end
    else
        toIds = table.concat(toIdArr, ",")
        names = table.concat(nameArr, "#")
        userHeadImgs = table.concat(userHeadImgArr, ",")

        if toIds ~= "" then
            --todo
            self:reqSendInvites(toIds, names, userHeadImgs)
        else
            nk.PopupManager:removePopup(self)
        end
    end
end

function InviteRecallPopup:onRecallClick_(arg)
    if not self.userItems_ then return end

    -- nk.PopupManager:removePopup(self)
    local select_tab = self.selectTab_
    local toIds = ""
    local names = ""
    -- local userHeadImgs = ""

    local toIdArr = {}
    local nameArr = {}

    for _, item in ipairs(self.userItems_) do
        if item and item.isSelected then
            --todo
            if item:isSelected() then
                table.insert(toIdArr, item:getData().id)
                table.insert(nameArr, item:getData().name)
            end
        end
    end

    if #toIdArr > 50 then
        --todo
        local toIdArrayTmp = {}
        local nameArrayTmp = {}

        for i = 1, math.ceil(#toIdArr / 50) do
            if i == math.ceil(#toIdArr / 50) then
                --todo
                for j = 1, #toIdArr - (math.ceil(#toIdArr / 50) - 1) * 50 do
                    table.insert(toIdArrayTmp, toIdArr[(i - 1) * 50 + j])
                    table.insert(nameArrayTmp, nameArr[(i - 1) * 50 + j])
                end

                toIds = table.concat(toIdArrayTmp, ",")
                names = table.concat(nameArrayTmp, "#")

                self:reqSendRecalls(toIds, names)
            else
                for j = 1, 50 do
                    table.insert(toIdArrayTmp, toIdArr[(i - 1) * 50 + j])
                    table.insert(nameArrayTmp, nameArr[(i - 1) * 50 + j])
                end

                toIds = table.concat(toIdArrayTmp, ",")
                names = table.concat(nameArrayTmp, "#")

                self:reqSendRecalls(toIds, names)
            end
        end
    else
        toIds = table.concat(toIdArr, ",")
        names = table.concat(nameArr, "#")

        if toIds ~= "" then
            --todo
            self:reqSendRecalls(toIds, names)
        else
            nk.PopupManager:removePopup(self)
        end
    end
end

function InviteRecallPopup:reqSendInvites(toIds, names, userHeadImgs)
    -- body
    local openMotherInvite = self.openType
    nk.http.getInviteId(function(data)

        -- dump(data, "nk.http.getInviteId.data :================")
        -- local retData = json.decode(data)
        local retData = data
        local requestData = ""
        -- response={"ret":0,"id":"1410441582080477","sk":"26df09e2aec7f4effd3b50985b4e827c","u":13877}
        -- if retData.ret and retData.ret == 0 then
            -- requestData = "u:"..retData.u..";id:"..retData.id..";sk:"..retData.sk
        if openMotherInvite and openMotherInvite == 1 then
           requestData = retData.sk .. ";" .. "typeMouther"
        else
            requestData = retData.sk
        end
        -- end

        if nk.Facebook and nk.Facebook.sendInvites then
            --todo
            nk.Facebook:sendInvites(requestData, toIds, bm.LangUtil.getText("FRIEND", "INVITE_SUBJECT"),
                bm.LangUtil.getText("FRIEND", "INVITE_CONTENT", "100K"), function (success, result)
                if success then
                    -- 保存邀请过的名字
                    if names ~= "" then
                        local invitedNames = nk.userDefault:getStringForKey(nk.cookieKeys.FACEBOOK_INVITED_NAMES, "")
                        local today = os.date("%Y%m%d")
                        if invitedNames == "" or string.sub(invitedNames, 1, 8) ~= today then
                            invitedNames = today .."#" .. names
                        else
                            invitedNames = invitedNames .. "#" .. names
                        end
                        nk.userDefault:setStringForKey(nk.cookieKeys.FACEBOOK_INVITED_NAMES, invitedNames)
                        nk.userDefault:flush()
                    end
                    -- 去掉最后一个逗号
                    if result.toIds then

                        local idLen = string.len(result.toIds)
                        if idLen > 0 and string.sub(result.toIds, idLen, idLen) == "," then
                            result.toIds = string.sub(result.toIds, 1, idLen - 1)
                        end
                    end

                    local postData = {
                        data = requestData, 
                        requestid = result.requestId, 
                        toIds = result.toIds, 
                        source = "register"
                    }

                    if(openMotherInvite==1) then
                        postData.event = "flower"
                    end

                    postData.type = "register"

                    -- dump(postData, "nk.http.inviteReport:postDataParam :===================")

                    nk.http.inviteReport(postData, function (data)
                        -- response={"ret":0,"count":1,"money":500}
                        -- local retData = json.decode(data)   count:  money:
                        local retData = data
                        if retData and retData.money and retData.money > 0 then
                            local historyVal = nk.userDefault:getIntegerForKey(nk.cookieKeys.FACEBOOK_INVITE_MONEY, 0)
                            historyVal = historyVal + retData.money
                            nk.userDefault:setIntegerForKey(nk.cookieKeys.FACEBOOK_INVITE_MONEY, historyVal)
                            -- 给出提示
                            -- nk.TopTipManager:showTopTip(bm.LangUtil.getText("FRIEND", "INVITE_SUCC_TIP", retData.money))

                            nk.userData["aUser.money"] = nk.userData["aUser.money"] + retData.money

                        end

                        if retData and retData.props and (#retData.props > 0) then
                            --获取互动道具数量
                            nk.http.getUserProps(2,function(pdata)
                                if pdata then
                                    for _,v in pairs(pdata) do
                                        if tonumber(v.pnid) == 2001 then
                                            nk.userData.hddjNum = checkint(v.pcnter)
                                            break
                                        end
                                    end
                                end
                            end,function(errData)
                            end)
                        end
                        if retData and retData.text then
                            -- 给出提示
                            nk.TopTipManager:showTopTip(bm.LangUtil.getText("FRIEND", "INVITE_SUCC_TIP", retData.text))
                        end

                        nk.PopupManager:removePopup(self)
                    end)

                    if (result and result.toIds) and (string.len(result.toIds) > 0) then
                        local tempIdsArr = string.split(result.toIds,",")
                        bm.EventCenter:dispatchEvent({name = nk.DailyTasksEventHandler.REPORT_INVITES, 
                            data = {count = #tempIdsArr}})
                    end

                    if nk.OnOff:check("inviteFilter") then
                        --todo
                        nk.http.reportHasInvitedUserInfo(userHeadImgs, function(retData)
                            -- body
                            -- dump(retData, "reportHasInvitedUserInfo.retData :=================")
                        end, function(errData)
                            -- body
                            dump(errData, "reportHasInvitedUserInfo.errData :=================")
                        end)
                    end
                    
                end

            end, function(errData)
                dump(errData, "nk.Facebook:sendInvites.errData :=================")

                nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
            end)
        end
    end, function(errData)
        dump(errData, "nk.http.getInviteId.errData :===================")

        nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
    end)

    --nk.PopupManager:removePopup(self)
end

function InviteRecallPopup:reqSendRecalls(toIds, names)
    -- body
    local openMotherInvite = self.openType

    nk.http.getInviteId(function (data)

        local retData = data
        local requestData = ""
        if openMotherInvite and openMotherInvite==1 then
           requestData = retData.sk .. ";" .. "typeMouther"
        else
            requestData = retData.sk
        end

        nk.Facebook:sendInvites(requestData, toIds, bm.LangUtil.getText("FRIEND", "RECALL_SUBJECT"),
            bm.LangUtil.getText("FRIEND", "RECALL_CONTENT"), function (success, result)
            if success then
                -- 保存邀请过的名字 
                if names ~= "" then
                    local invitedNames =nk.userDefault:getStringForKey(nk.cookieKeys.FACEBOOK_INVITED_NAMES, "")
                    local today = os.date("%Y%m%d")
                    if invitedNames == "" or string.sub(invitedNames, 1, 8) ~= today then
                        invitedNames = today .."#" .. names
                    else
                        invitedNames = invitedNames .. "#" .. names
                    end
                    nk.userDefault:setStringForKey(nk.cookieKeys.FACEBOOK_INVITED_NAMES, invitedNames)
                    nk.userDefault:flush()
                end
                -- 去掉最后一个逗号
                if result.toIds then
                    local idLen = string.len(result.toIds)
                    if idLen > 0 and string.sub(result.toIds, idLen, idLen) == "," then
                        result.toIds = string.sub(result.toIds, 1, idLen - 1)
                    end
                end

                nk.http.recallFriends(nk.userData["aUser.mid"], result.toIds, function(data)
                    if data.state and checkint(data.state) == 1 then
                        nk.TopTipManager:showTopTip(T("恭喜您获得召回奖励:30K筹码"))
                    else
                        nk.TopTipManager:showTopTip(T("召回成功"))
                    end

                    if data.money and tonumber(data.money) >= 0 then
                        --todo
                        nk.userData["aUser.money"] = tonumber(data.money)
                    end
                end, function(errData)
                    dump(errData, "nk.http.recallFriends.errData :==============")
                    nk.TopTipManager:showTopTip(T("召回玩家上报失败"))
                end)
            end
        end)
    end, function (errData)
        dump(errData, "nk.http.getInviteId.errData :================")
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
    end)

    nk.PopupManager:removePopup(self)
end

function InviteRecallPopup:onExit()
    -- body
    display.removeSpriteFramesWithFile("recall_friend.plist", "recall_friend.png")
    nk.schedulerPool:delayCall(function()
        cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    end, 0.1)
end

function InviteRecallPopup:onCleanup()
    -- body
    
    if self.getInitRecallReq_ then
        --todo
        nk.http.cancel(self.getInitRecallReq_)
    end

    if self.reqGetRecallFriendId_ then
        --todo
        nk.http.cancel(self.reqGetRecallFriendId_)
    end
end

return InviteRecallPopup