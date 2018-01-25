--
-- Author: Jonah0608@gmail.com
-- Date: 2015-05-05 10:59:31
--

local POPUP_WIDTH = 780
local POPUP_HEIGHT = 520
local LIST_POS_Y = -48

local InviteOldUserPopup = class("InviteOldUserPopup", function ()
    return display.newNode()
end)
local InviteListItem = import(".InviteListItem")
local logger = bm.Logger.new("InviteOldUserPopup")

function InviteOldUserPopup:ctor()
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

    -- invite tip
    self.inviteTip_ = display.newTTFLabel({text = bm.LangUtil.getText("FRIEND", "INVITE_SELECT_TIP", 0, 0), color = styles.FONT_COLOR.LIGHT_TEXT, size = 22, align = ui.TEXT_ALIGN_CENTER})
        :pos(0, POPUP_HEIGHT * 0.5 - 48)
        :addTo(self, 7, 7)

    self:setLoading(true)
    -- 获取可以邀请的老朋友
    bm.HttpService.POST(
        {
            mod = "recall",
            act = "list"
        },
        function(data)
            self:onGetData_(true,data)
        end,
        function(data)
            -- print(data)
        end)
end



function InviteOldUserPopup:onGetData_(success, friendData)
    self:setLoading(false)
    friendData = json.decode(friendData)
    if success then
        -- for test
        -- nk.userDefault:setStringForKey(nk.cookieKeys.FACEBOOK_INVITED_NAMES_OLD, "")
        -- 排除今日邀请过的
        -- local invitedNames = nk.userDefault:getStringForKey(nk.cookieKeys.FACEBOOK_INVITED_NAMES_OLD, "")
        -- logger:debug("invitedNames:" .. invitedNames)
        -- if invitedNames ~= "" then
        --     local namesTable = string.split(invitedNames, "#")
        --     if namesTable[1] ~= os.date("%Y%m%d") then
        --         logger:debug("clear invited names")
        --         nk.userDefault:setStringForKey(nk.cookieKeys.FACEBOOK_INVITED_NAMES_OLD, "")
        --         nk.userDefault:flush()
        --     else
        --         table.remove(namesTable, 1)
        --         for _, name in pairs(namesTable) do
        --             local i, max = 1, #friendData
        --             while i <= max do
        --                 if friendData[i].name == name then
        --                     logger:debug("remove invited name -> ", name)
        --                     table.remove(friendData, i)
        --                     i = i - 1
        --                     max = max - 1
        --                 end
        --                 i = i + 1
        --             end
        --         end
        --     end
        -- end
        
        -- 只展示前30个
        self.maxData_ = #friendData
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
            friendData[i].chips = nk.userData.recallSendChips -- 此处是召回邀请奖励 500
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

function InviteOldUserPopup:getSelectedItemNum()
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

function InviteOldUserPopup:setSelecteTip()
    local selectedNum = 0
    for _, item in ipairs(self.userItems_) do
        if item:isSelected() then
            selectedNum = selectedNum + 1
        end
    end
    self.inviteTip_:setString(bm.LangUtil.getText("FRIEND", "INVITE_SELECT_TIP", selectedNum, selectedNum *  nk.userData.recallSendChips))
    self.setSelectedAll_()
end

function InviteOldUserPopup:onInviteClick_()
    if not self.userItems_ then return end
    nk.PopupManager:removePopup(self)

    -- 上报使用邀请老用户好友功能的用户数上报
    local date = nk.userDefault:getStringForKey(nk.cookieKeys.DALIY_REPORT_OLDUSER_INVITED)
    if date ~= os.date("%Y%m%d") then
        nk.userDefault:setStringForKey(nk.cookieKeys.DALIY_REPORT_OLDUSER_INVITED, os.date("%Y%m%d"))
        -- cc.analytics:doCommand{
        --     command = "eventCustom",
        --     args = {
        --         eventId = "invite_olduser_count",
        --         attributes = "type,invite_olduser",
        --         counter = 1
        --     }
        -- }
    end

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
        bm.HttpService.POST(
            {
                mod = "recall", 
                act = "getRecallID"
            }, 
            function (data)
                local retData = json.decode(data)
                local requestData
                -- response={"ret":0,"id":"1410441582080477","sk":"26df09e2aec7f4effd3b50985b4e827c","u":13877}
                if retData.ret and retData.ret == 0 then
                    requestData = "u:"..retData.u..";id:"..retData.id..";sk:"..retData.sk
                end

                nk.Facebook:sendInvites(
                    "oldUserRecall" .. requestData, 
                    toIds, 
                    bm.LangUtil.getText("FRIEND", "INVITE_SUBJECT"), 
                    bm.LangUtil.getText("FRIEND", "INVITE_CONTENT_OLDUSER"), 
                    function (success, result)
                        if success then
                            -- 发送邀请成功人数消息
                            bm.EventCenter:dispatchEvent({name = nk.DailyTasksEventHandler.REPORT_FB_RECALL, data = #toIdArr})
                            -- 保存邀请过的名字
                            -- if names ~= "" then
                            --     local invitedNames = nk.userDefault:getStringForKey(nk.cookieKeys.FACEBOOK_INVITED_NAMES_OLD, "")
                            --     local today = os.date("%Y%m%d")
                            --     if invitedNames == "" or string.sub(invitedNames, 1, 8) ~= today then
                            --         invitedNames = today .."#" .. names
                            --     else
                            --         invitedNames = invitedNames .. "#" .. names
                            --     end
                            --     nk.userDefault:setStringForKey(nk.cookieKeys.FACEBOOK_INVITED_NAMES_OLD, invitedNames)
                            --     nk.userDefault:flush()
                            -- end
                            -- 去掉最后一个逗号
                            if result.toIds then
                                local idLen = string.len(result.toIds)
                                if idLen > 0 and string.sub(result.toIds, idLen, idLen) == "," then
                                    result.toIds = string.sub(result.toIds, 1, idLen - 1)
                                end
                            end
                            -- 上报php，领奖
                            local postData = {
                                mod = "recall", 
                                act = "report", 
                                data = requestData, 
                                requestid = result.requestId, 
                                list = result.toIds, 
                                sig = crypto.md5(result.toIds .. "ab*&()[cae!@+?>#5981~.,-zm"),
                                source = "recall"
                            }
                            postData.type = "recall"
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
    end
end

function InviteOldUserPopup:setLoading(isLoading)
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

function InviteOldUserPopup:setNoDataTip(noData)
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

function InviteOldUserPopup:show()
    nk.PopupManager:addPopup(self)
end

function InviteOldUserPopup:onShowed()
    -- 延迟设置，防止list出现触摸边界的问题
    if self.scrollView_ then
        self.scrollView_:setScrollContentTouchRect()
    end
end

function InviteOldUserPopup:onExit()
    nk.schedulerPool:delayCall(function()
        cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    end, 0.1)
end

return InviteOldUserPopup