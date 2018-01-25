--
-- Author: johnny@boomegg.com
-- Date: 2014-09-10 13:22:07
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

local POPUP_WIDTH = 780
local POPUP_HEIGHT = 520
local LIST_POS_Y = -48
local friendDataGlobal = {}
local InvitePopup = class("InvitePopup", function ()
    return display.newNode()
end)
local InviteListItem = import(".InviteListItem")
local logger = bm.Logger.new("InvitePopup")

function InvitePopup:ctor()
    cc.Director:getInstance():getTextureCache():removeUnusedTextures()

    -- background
    self.background_ = display.newScale9Sprite("#invite_popup_bg.png", 0, 0, cc.size(POPUP_WIDTH, POPUP_HEIGHT))
        :addTo(self, 1, 1)
    self.background_:setCapInsets(cc.rect(2, 96, 4, 1))
    self.background_:setTouchEnabled(true)
    self.background_:setTouchSwallowEnabled(true)

    self.cover_ = display.newScale9Sprite("#invite_popup_bg.png", 0, POPUP_HEIGHT * 0.5 - 98 * 0.5, cc.size(POPUP_WIDTH, 98))
        :addTo(self, 3, 3)
    self.cover_:setCapInsets(cc.rect(2, 96, 4, 1))
    self.cover_:setTouchEnabled(true)
    self.cover_:setTouchSwallowEnabled(true)

    -- close button
    bm.TouchHelper.new(
        display.newSprite("#invite_popup_close_btn_up.png")
            :pos(-POPUP_WIDTH * 0.5, POPUP_HEIGHT * 0.5)
            :addTo(self, 4, 4),
        function (target, evtName)
            if evtName == bm.TouchHelper.CLICK then
                nk.SoundManager:playSound(nk.SoundManager.CLOSE_BUTTON)
                nk.PopupManager:removePopup(self)
            end
        end
    )

    -- cancel button
    local frame = display.newSprite("#invite_friend_selectall_checkbox_bg.png"):pos(-90 + 8 + 16, 0)
    local selected = display.newSprite("#invite_friend_selectall_checkbox_selected.png"):pos(-90 + 8 + 16, 0):hide()
    local btn
    self.setSelectedAll_ = function()
        if not self.userItems_ or #self.userItems_ == 0 then
            selected:hide()
            return
        end
        local selectedNum = self:getSelectedItemNum()
        if selectedNum == 50 or selectedNum == #self.userItems_ then
            selected:show()
            btn:setButtonLabelString("normal", bm.LangUtil.getText("FRIEND", "DESELECT_ALL"))
        else
            selected:hide()
            btn:setButtonLabelString("normal", bm.LangUtil.getText("FRIEND", "SELECT_ALL"))
        end
    end
    btn = cc.ui.UIPushButton.new({normal = "#invite_popup_btn_up.png", pressed = "#invite_popup_btn_down.png"}, {scale9=true})
        :setButtonLabel("normal", display.newTTFLabel({text = bm.LangUtil.getText("FRIEND", "SELECT_ALL"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 22, align = ui.TEXT_ALIGN_CENTER}))
        :setButtonLabelOffset(20, 0)
        :setButtonSize(180, 60)
        :pos(-POPUP_WIDTH * 0.5 + 90 + 30, POPUP_HEIGHT * 0.5 + LIST_POS_Y)
        :addTo(self, 5, 5)
        :add(frame)
        :add(selected)
        :onButtonClicked(buttontHandler(self, function()
                if not self.userItems_ or #self.userItems_ == 0 then
                    selected:hide()
                    btn:setButtonLabelString("normal", bm.LangUtil.getText("FRIEND", "SELECT_ALL"))
                    return
                end
                local selectedNum = self:getSelectedItemNum()
                if selectedNum == 50 or selectedNum == #self.userItems_ then
                    for _, item in ipairs(self.userItems_) do
                        item:setSelected(false)
                    end
                else
                    for _, item in ipairs(self.userItems_) do
                        if not item:isSelected() then
                            selectedNum = selectedNum + 1
                            item:setSelected(true)
                            if selectedNum == 50 then
                                break
                            end
                        end
                    end
                end
                self:setSelecteTip()
            end))

    -- invite button
    cc.ui.UIPushButton.new({normal = "#invite_popup_btn_up.png", pressed = "#invite_popup_btn_down.png"})
        :setButtonLabel("normal", display.newTTFLabel({text = bm.LangUtil.getText("FRIEND", "SEND_INVITE"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 22, align = ui.TEXT_ALIGN_CENTER}))
        :pos(POPUP_WIDTH * 0.5 - 80, POPUP_HEIGHT * 0.5 + LIST_POS_Y)
        :addTo(self, 6, 6)
        :onButtonClicked(buttontHandler(self, self.onInviteClick_))

    -- invite search
    -- self.reloadIcon_ = display.newSprite("#invite_friend_reload.png",0, 0, cc.size(44, 40))
    --     :pos(202, POPUP_HEIGHT * 0.5 + LIST_POS_Y + 10 )
    --     :addTo(self, 11, 11)
    self.reloadIcon_ = cc.ui.UIPushButton.new({normal="#invite_friend_reload.png"})
        :onButtonClicked(handler(self, self.reloadIconClick_))
        :pos(187, POPUP_HEIGHT * 0.5 + LIST_POS_Y + 10 )
        :addTo(self, 11, 11)
    self.searchIcon_ = display.newSprite("#invite_friend_search.png")
        :pos(-135, POPUP_HEIGHT * 0.5 + LIST_POS_Y + 10)
        :addTo(self, 12, 12)

    self.searchEdit_ = cc.ui.UIInput.new({
        size = cc.size(300, 40),
        align=ui.TEXT_ALIGN_CENTER - 30,
        image="#invite_friend_inputback.png",
        x = 30,
        y = POPUP_HEIGHT * 0.5 + LIST_POS_Y + 10 ,
        listener = handler(self, self.onSearchStart_)
    })
    self.searchEdit_:setFontName(ui.DEFAULT_TTF_FONT)
    self.searchEdit_:setFontSize(24)
    self.searchEdit_:setFontColor(cc.c3b(0x92, 0x8d, 0x8d))
    self.searchEdit_:setPlaceholderFontName(ui.DEFAULT_TTF_FONT)
    self.searchEdit_:setPlaceholderFontSize(38)
    self.searchEdit_:setPlaceholderFontColor(cc.c3b(0x92, 0x8d, 0x8d))
    self.searchEdit_:setPlaceHolder(bm.LangUtil.getText("FRIEND", "SEARCH_FRIEND"))
    self.searchEdit_:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.searchEdit_:setReturnType(cc.KEYBOARD_RETURNTYPE_GO)
    self.searchEdit_:addTo(self, 10, 10)


    -- invite tip
    self.inviteTip_ = display.newTTFLabel({text = bm.LangUtil.getText("FRIEND", "INVITE_SELECT_TIP", 0, 0), color = styles.FONT_COLOR.LIGHT_TEXT, size = 16, align = ui.TEXT_ALIGN_CENTER})
        :pos(30, POPUP_HEIGHT * 0.5 - 80)
        :addTo(self, 7, 7)

    -- get invitable friend data
    self:setLoading(true)
    nk.Facebook:getInvitableFriends(handler(self, self.onGetData_,nk.userData.inviteFriendLimit))
    self:reportNewUserClickInviteBtn_()
end

function InvitePopup:reloadIconClick_()
    self.searchStr_ = ""
    self.searchEdit_:setText("")
    self:filterData()
end

function InvitePopup:searchIconClick_()
    self.searchStr = self.searchEdit_:getText()
    self:filterData()
end

function InvitePopup:onSearchStart_(event)
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

function InvitePopup:filterData()
    self.scrollView_:hide()
    self:setNoDataTip(false)
    if self.searchStr_ and self.searchStr_ ~= nil then
        self:onGetData_(true, friendDataGlobal, self.searchStr_)
    end
end

-- 上报新用户facebook邀请点击量
function InvitePopup:reportNewUserClickInviteBtn_()
    -- if device.platform == "android" or device.platform == "ios" then
    --     if nk.userData.loginRewardStep == 1 then
    --         cc.analytics:doCommand{
    --             command = "event",args = {eventId = "new_user_fb_invite_click",label = "new_user_fb_invite_click"}
    --         }
    --     end
    -- end
end


function InvitePopup:onGetData_(success, friendData, filterStr)
    
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
        self.scrollView_ = bm.ui.ScrollView.new()
        self.inviteUserNode_ = display.newNode()
        local nodeWidth = POPUP_WIDTH
        local nodeHeight = math.ceil(self.maxData_ / 3) * 100
        self.inviteUserNode_:setContentSize(cc.size(nodeWidth, nodeHeight))
        self.userItems_ = {}
        for i = 1, self.maxData_ do
            friendData[i].chips =  nk.userData.inviteSendChips
            self.userItems_[i] = InviteListItem.new(friendData[i], self.scrollView_, self, i)
                :pos(
                    -nodeWidth * 0.5 + InviteListItem.ITEM_WIDTH * 0.5 + (i + 2) % 3 * InviteListItem.ITEM_WIDTH, 
                    nodeHeight * 0.5 - InviteListItem.ITEM_HEIGHT * 0.5 - math.floor((i - 1) / 3) * InviteListItem.ITEM_HEIGHT
                )
                :addTo(self.inviteUserNode_)
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

        self.scrollView_:setViewRect(cc.rect(-POPUP_WIDTH * 0.5, -(POPUP_HEIGHT - 96) * 0.5, POPUP_WIDTH, POPUP_HEIGHT - 96))
        self.scrollView_:setScrollContent(self.inviteUserNode_)
        self.scrollView_:pos(0, LIST_POS_Y):addTo(self, 2, 2)
        self.scrollView_:update()
        self.scrollView_:update()
    else
        self:setNoDataTip(true)
    end
end


function InvitePopup:sortFreind_(friendData)
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

function InvitePopup:getSelectedItemNum()
    local selectedNum = 0
    if self.userItems_ then
        for _, item in ipairs(self.userItems_) do
            if item:isSelected() then
                selectedNum = selectedNum + 1
            end
        end
    end
    return selectedNum
end

function InvitePopup:setSelecteTip()
    local selectedNum = 0
    for _, item in ipairs(self.userItems_) do
        if item:isSelected() then
            selectedNum = selectedNum + 1
        end
    end
    self.inviteTip_:setString(bm.LangUtil.getText("FRIEND", "INVITE_SELECT_TIP", selectedNum, selectedNum * nk.userData.inviteSendChips))
    self.setSelectedAll_()
end

function InvitePopup:onInviteClick_()
    if not self.userItems_ then return end
    nk.PopupManager:removePopup(self)

    local toIds = ""
    local names = ""
    local toIdArr = {}
    local nameArr = {}
    for _, item in ipairs(self.userItems_) do
        if item:isSelected() then
            table.insert(toIdArr, item:getData().id)
            table.insert(nameArr, item:getData().name)
        end
    end
    toIds = table.concat(toIdArr, ",")
    names = table.concat(nameArr, "#")

    -- 发送邀请
    if toIds ~= "" then
        local openMotherInvite = self.openType;
        nk.http.getInviteId(
            function (data)
                -- local retData = json.decode(data)
                local retData = data;
                local requestData = ""
                -- response={"ret":0,"id":"1410441582080477","sk":"26df09e2aec7f4effd3b50985b4e827c","u":13877}
                -- if retData.ret and retData.ret == 0 then
                    -- requestData = "u:"..retData.u..";id:"..retData.id..";sk:"..retData.sk
                    if openMotherInvite and openMotherInvite==1 then
                       requestData = retData.sk .. ";" .. "typeMouther";
                    else
                        requestData = retData.sk
                    end
                -- end

                nk.Facebook:sendInvites(
                    requestData, 
                    toIds, 
                    bm.LangUtil.getText("FRIEND", "INVITE_SUBJECT"), 
                    bm.LangUtil.getText("FRIEND", "INVITE_CONTENT"), 
                    function (success, result)
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
                                postData.event = "flower";
                            end
                            postData.type = "register"

                            nk.http.inviteReport(
                                postData, 
                                function (data)
                                    -- response={"ret":0,"count":1,"money":500}
                                    -- local retData = json.decode(data)   count:  money:
                                    local retData = data
                                    if retData and retData.money and retData.money > 0 then
                                        local historyVal = nk.userDefault:getIntegerForKey(nk.cookieKeys.FACEBOOK_INVITE_MONEY, 0)
                                        historyVal = historyVal + retData.money
                                        nk.userDefault:setIntegerForKey(nk.cookieKeys.FACEBOOK_INVITE_MONEY, historyVal)
                                        -- 给出提示
                                        -- nk.TopTipManager:showTopTip(bm.LangUtil.getText("FRIEND", "INVITE_SUCC_TIP", retData.money))

                                        nk.userData["aUser.money"] = (nk.userData["aUser.money"] + retData.money)

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
                                            
                                        end,function()
                                            
                                        end)
                                    end


                                    if retData and retData.text then
                                        -- 给出提示
                                        nk.TopTipManager:showTopTip(bm.LangUtil.getText("FRIEND", "INVITE_SUCC_TIP", retData.text))
                                    end
                                end
                            )

                            if (result and result.toIds) and (string.len(result.toIds) > 0) then
                                local tempIdsArr = string.split(result.toIds,",")
                                bm.EventCenter:dispatchEvent({name = nk.DailyTasksEventHandler.REPORT_INVITES, 
                                data = {count = #tempIdsArr}})
                            end

                            -- 上报php，领奖

                            --[[
                            local postData = {
                                mod = "invite", 
                                act = "report", 
                                data = requestData, 
                                requestid = result.requestId, 
                                list = result.toIds, 
                                source = "register"
                            }
                            postData.type = "register"
                            bm.HttpService.POST(
                                postData, 
                                function (data)
                                    -- response={"ret":0,"count":1,"money":500}
                                    local retData = json.decode(data)
                                    if retData and retData.ret == 0 and retData.money and retData.money > 0 then
                                        local historyVal = nk.userDefault:getIntegerForKey(nk.cookieKeys.FACEBOOK_INVITE_MONEY, 0)
                                        historyVal = historyVal + retData.money
                                        nk.userDefault:setIntegerForKey(nk.cookieKeys.FACEBOOK_INVITE_MONEY, historyVal)
                                        -- 给出提示
                                        nk.TopTipManager:showTopTip(bm.LangUtil.getText("FRIEND", "INVITE_SUCC_TIP", retData.money))
                                    end
                                end
                            )
                            --]]
                        end
                    end
                )
            end, 
            function ()
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
            end
        )


        --[[
        bm.HttpService.POST(
            {
                mod = "invite", 
                act = "getInviteID"
            }, 
            function (data)
                local retData = json.decode(data)
                local requestData = ""
                -- response={"ret":0,"id":"1410441582080477","sk":"26df09e2aec7f4effd3b50985b4e827c","u":13877}
                if retData.ret and retData.ret == 0 then
                    requestData = "u:"..retData.u..";id:"..retData.id..";sk:"..retData.sk
                end

                nk.Facebook:sendInvites(
                    requestData, 
                    toIds, 
                    bm.LangUtil.getText("FRIEND", "INVITE_SUBJECT"), 
                    bm.LangUtil.getText("FRIEND", "INVITE_CONTENT"), 
                    function (success, result)
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
                            -- 上报php，领奖
                            local postData = {
                                mod = "invite", 
                                act = "report", 
                                data = requestData, 
                                requestid = result.requestId, 
                                list = result.toIds, 
                                source = "register"
                            }
                            postData.type = "register"
                            bm.HttpService.POST(
                                postData, 
                                function (data)
                                    -- response={"ret":0,"count":1,"money":500}
                                    local retData = json.decode(data)
                                    if retData and retData.ret == 0 and retData.money and retData.money > 0 then
                                        local historyVal = nk.userDefault:getIntegerForKey(nk.cookieKeys.FACEBOOK_INVITE_MONEY, 0)
                                        historyVal = historyVal + retData.money
                                        nk.userDefault:setIntegerForKey(nk.cookieKeys.FACEBOOK_INVITE_MONEY, historyVal)
                                        -- 给出提示
                                        nk.TopTipManager:showTopTip(bm.LangUtil.getText("FRIEND", "INVITE_SUCC_TIP", retData.money))
                                    end
                                end
                            )
                        end
                    end
                )
            end, 
            function ()
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
            end
        )

        --]]
    end
end

function InvitePopup:setLoading(isLoading)
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

function InvitePopup:setNoDataTip(noData)
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

function InvitePopup:show(openType)
    self.openType = openType;
    nk.PopupManager:addPopup(self)
end

function InvitePopup:onShowed()
    -- 延迟设置，防止list出现触摸边界的问题
    if self.scrollView_ then
        self.scrollView_:setScrollContentTouchRect()
    end
end

function InvitePopup:onExit()
    nk.schedulerPool:delayCall(function()
        cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    end, 0.1)
end

return InvitePopup