local CornuFriendsView = class("CornuFriendsView", 
function()
	return display.newNode() 
end)
local WIDTH = 842
local HEIGHT = 444


local NOTICE_WIDTH = 240
local NOTICE_HEIGHT = 134

local MESSAGE_HEIGHT = 207
local NOTICE_TITLE_H = 26



local WORDS_BG_WIDTH = 154
local WORDS_BG_HEIGHT = 32
local CornuFriendItem = import(".CornuFriendItem")
local CornuFarmView = import(".CornuFarmView")
local CornuFriendMessageBoardItem = import(".CornuFriendMessageBoardItem")
function CornuFriendsView:ctor(parent,fid)
    self:setNodeEventEnabled(true)
	self.parent_ = parent
    self.goFid_ = fid

    --公告
    self.myNotice_ = display.newNode():addTo(self)
	:align(display.TOP_LEFT)
	:pos(-WIDTH/2+NOTICE_WIDTH/2 +10,HEIGHT/2-NOTICE_HEIGHT - 20)

	display.newScale9Sprite("#cor_small_bg.png", 0, 0, cc.size(NOTICE_WIDTH,NOTICE_HEIGHT))
    :addTo(self.myNotice_)
    display.newScale9Sprite("#cor_small_title.png", 0, 0, cc.size(NOTICE_WIDTH,NOTICE_TITLE_H))
    :addTo(self.myNotice_)
    :pos(0,NOTICE_HEIGHT/2-NOTICE_TITLE_H/2)

    display.newTTFLabel({text = bm.LangUtil.getText("DORNUCOPIA","HOMEPAGE")[1], color = cc.c3b(0x5A, 0x7C, 0xAE), size = 20,dimensions = cc.size(NOTICE_WIDTH, 0), align = ui.TEXT_ALIGN_CENTER})
    :addTo(self.myNotice_)
    :pos(0,NOTICE_HEIGHT/2-NOTICE_TITLE_H/2)

    self.myNoticeText_ = display.newTTFLabel({text = "", color = cc.c3b(0x5A, 0x7C, 0xAE), size = 20,dimensions = cc.size(NOTICE_WIDTH, NOTICE_HEIGHT-NOTICE_TITLE_H), align = ui.TEXT_ALIGN_LEFT})
    :addTo(self.myNotice_)
    :align(display.TOP_LEFT)
    :pos(-NOTICE_WIDTH/2,NOTICE_HEIGHT/2-NOTICE_TITLE_H)

    


   --好友留言
    self.myMessage_ = display.newNode():addTo(self)
	:align(display.TOP_LEFT)
	:pos(-WIDTH/2+NOTICE_WIDTH/2 +10,HEIGHT/2-NOTICE_HEIGHT- MESSAGE_HEIGHT+10)

	display.newScale9Sprite("#cor_small_bg.png", 0, 0, cc.size(NOTICE_WIDTH,MESSAGE_HEIGHT))
    :addTo(self.myMessage_)
    display.newScale9Sprite("#cor_small_title.png", 0, 0, cc.size(NOTICE_WIDTH,NOTICE_TITLE_H))
    :addTo(self.myMessage_)
    :pos(0,MESSAGE_HEIGHT/2-NOTICE_TITLE_H/2)

    display.newTTFLabel({text = bm.LangUtil.getText("DORNUCOPIA","HOMEPAGE")[2], color = cc.c3b(0x5A, 0x7C, 0xAE), size = 20,dimensions = cc.size(NOTICE_WIDTH, 0), align = ui.TEXT_ALIGN_CENTER})
    :addTo(self.myMessage_)
    :pos(0,MESSAGE_HEIGHT/2-NOTICE_TITLE_H/2)


--

    -- display.newScale9Sprite("#cor_chat_drak.png", 0, 0, cc.size(145, 30)):addTo(self.myMessage_)
    -- :align(display.TOP_LEFT)
    -- :pos(-NOTICE_WIDTH/2+5,-MESSAGE_HEIGHT/2+30+5);
    self.messageEdit_ = cc.ui.UIInput.new({image = "#cor_chat_drak.png", listener = handler(self, self.onNoticeEdit_), size = cc.size(145, 30)})
        :align(display.TOP_LEFT)
        --:pos(-NOTICE_WIDTH/2,NOTICE_HEIGHT/2-NOTICE_TITLE_H)
        :pos(-NOTICE_WIDTH/2+5,-MESSAGE_HEIGHT/2+30+5)
        :addTo(self.myMessage_)
    self.messageEdit_:setFont(ui.DEFAULT_TTF_FONT, 20)
    self.messageEdit_:setPlaceholderFont(ui.DEFAULT_TTF_FONT, 20)
    self.messageEdit_:setMaxLength(145)
    self.messageEdit_:setPlaceholderFontColor(cc.c3b(0x5A, 0x7C, 0xAE))
    self.messageEdit_:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.messageEdit_:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self.messageEdit_:setPlaceHolder("")

    self.click_btn_ = cc.ui.UIPushButton.new({normal = "#cor_send_btn.png", pressed = "#cor_send_btn.png"}, {scale9 = true})
    :setButtonSize(75, 28)
    :setButtonLabel(cc.ui.UILabel.new({text = T("发送"), size = 24,  color = cc.c3b(0xff, 0xff, 0xff)}))
    :align(display.TOP_LEFT)
    :onButtonClicked(buttontHandler(self, self.click_))
    :addTo(self.myMessage_)
    :pos(-NOTICE_WIDTH/2+5+142,-MESSAGE_HEIGHT/2+34);

    self.farmView_ = CornuFarmView.new(self,2)
   	:addTo(self)
   	:pos(124,-40)

    self:onShowed()
end
function CornuFriendsView:onNoticeEdit_(event)
    if event == "began" then
        -- 开始输入
    elseif event == "changed" then
        -- 输入框内容发生变化self.addressEdit_

        --self.noticeEdit_:setText("")
        
        
    elseif event == "ended" then
        -- 输入结束
    elseif event == "return" then
        -- 从输入框返回
        -- print(self.editAddress_)
    end
end
function CornuFriendsView:click_()
    local text = self.messageEdit_:getText()
    
    if text == nil or text == "" or text == " " then
        return
    end

    local len = string.len(string.trim(text));
    if len > 200 then
        text = string.sub(text, 1, 200);
    end

    self.sendMsgRequestId_ = nk.http.sendMsgToFriend(self.fid_,text,
        function(data)
            self.sendMsgRequestId_ = nil
            self.messageEdit_:setText("")
            self:getFriendMessageList()
        end,
        function (errordata)
            self.sendMsgRequestId_ = nil
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("HALL", "PERSONAL_ROOM_INVITE_ONLINE")[6])
        end

    )
end
function CornuFriendsView:onShowed()
    if self.list_ then
        self.list_:removeFromParent()
        self.list_ = nil
    end
    self.list_ = bm.ui.ListView.new(
            {
                viewRect = cc.rect(-805 * 0.5, -85 * 0.5, 805, 85),
                direction = bm.ui.ScrollView.DIRECTION_HORIZONTAL
            }, 
            CornuFriendItem
    )
    :addTo(self)
    :pos(5,HEIGHT/2-45)

    self.list_:addEventListener("ITEM_EVENT", handler(self, self.onItemEvent_))

    self:setFriendsLoading(true)
    
     -- self.friendDataRequestId_ = nk.http.getHallFriendList(
     --    handler(self, self.onGetFriendData_), 
     -- function()
     --    nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "REQUEST_DATA_FAIL"))  
     -- end
     -- )

    self.getLevReqId_ = nk.http.getLevelRanlIds(nk.userData["aUser.mid"],
        handler(self, self.onGetFriendData_),
        function(errordata)
            self.getLevReqId_ = nil
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "REQUEST_DATA_FAIL"))
        end

    )


    if self.messageList_ then
        self.messageList_:removeFromParent()
        self.messageList_ = nil
    end
    self.messageList_ = bm.ui.ListView.new(
            {
                viewRect = cc.rect(-NOTICE_WIDTH * 0.5, -(MESSAGE_HEIGHT-60) * 0.5, NOTICE_WIDTH, MESSAGE_HEIGHT-60)
            }, 
            CornuFriendMessageBoardItem
    )
    :addTo(self.myMessage_)
    :pos(0,5)

    -- self.messageList_:setData({1,2,3,4,5,5})
    -- self.messageList_:update()

    
end

function CornuFriendsView:getFriendMessageList()
    self:setMessageLoading(true)

    self.getFriendsMesaage_ = nk.http.getFriendsMessage(
        self.fid_,
        function(data)
            self.getFriendsMesaage_ = nil
            self:setMessageLoading(false)

            -- local message = {}
            -- for k,v in pairs(data) do
            --     table.insert(message,v)
            -- end

            self.messageList_:setData(data)
            self.messageList_:update()
        end,

        function(errordata)
            self.getFriendsMesaage_ = nil
        end

    )
end

function CornuFriendsView:onGetFriendData_(data)
 self.getLevReqId_ = nil
    self:setFriendsLoading(false)
    if data then
        self.friendData_ = data
        local uidList = {}
        if self.friendData_ then
            for i, v in ipairs(self.friendData_) do
                uidList[#uidList + 1] = v.mid
                v.light = 0
            end
        end
        self.friendUidList_ = uidList

        self.list_:setData(self.friendData_)
        self.list_:update()

        if #self.friendData_>0 then
            self.fid_ = self.friendUidList_[1] 
            if self.goFid_ and self.goFid_ ~= 0 then
                self.fid_ = self.goFid_
                self.goFid_ = 0
            end

            local index = 1
            for i=1,#self.friendUidList_ do
                if checkint(self.fid_) == checkint(self.friendUidList_[i]) then
                    index = i
                end
            end
            self.friendData_[index].light = 1
            self.lastData_ = self.friendData_[index]
            self.list_:updateData(index,self.lastData_)

            if index<=5 or #self.friendData_<9 then

            elseif (index+3)>=#self.friendData_ then
                self.list_:scrollTo(-(#self.friendData_-8)*100)
            else
                self.list_:scrollTo(-(index-5)*100)
            end            

            self:getFriendNotice()
            self:getSelfCor()
            self:getFriendMessageList()
        end
    end
end
--获取公告
function CornuFriendsView:getFriendNotice()
    self:setNoticeLoading(true)
    self.requestMyNotice_ = nk.http.getNotice(self.fid_,
        function(data)
            self.requestMyNotice_ = nil
            self:setNoticeLoading(false)
            if data.notice == nil then
                data.notice = T("欢迎来到我这农场")
            end
            self.myNoticeText_:setString(""..data.notice)
        end,
        function(errordata)
            self.requestMyNotice_ = nil
        end
    )
end
--获取农场数据
function CornuFriendsView:getSelfCor()
    --self.myCoinTxt_:setString(bm.formatNumberWithSplit(nk.userData["aUser.money"]))
    self.farmView_:setLoading(true)
    self.getMyCorRequest_ = nk.http.getFriendCornucopia(self.fid_,
        function(data)
            self.getMyCorRequest_ = nil
            if self.farmView_ then
                --todo
                self.farmView_:setLoading(false)
                self.farmView_:setFriendBlow(data,self.fid_)
            end
            -- self.goldSeedTxt_:setString(""..data.jininfo.num)
            -- self.silverSeedTxt_:setString(""..data.yininfo.num)
            -- self.quickPotionTxt_:setString(''..data.shortinfo.num)
        end,

        function(errordata)
            self.getMyCorRequest_ = nil
        end
    )
end
function CornuFriendsView:setNoticeLoading(isLoading)
    if isLoading then
        if not self.notice_juhua_ then
            self.notice_juhua_ = nk.ui.Juhua.new()
                --:pos(NOTICE_WIDTH/2, NOTICE_HEIGHT/2+20)
                :addTo(self.myNotice_)
                :scale(.5)
        end
    else
        if self.notice_juhua_ then
            self.notice_juhua_:removeFromParent()
            self.notice_juhua_ = nil
        end
    end
end
function CornuFriendsView:onItemEvent_(evt)
    local data = evt.data
    if checkint(self.fid_) == checkint(data.mid) then
        return
    end

    if self.lastData_ then
        self.lastData_.light = 0
        local index = 1
        for i=1,#self.friendData_ do
            if checkint(self.lastData_.mid) == checkint(self.friendData_[i].mid) then
                index = i
            end
        end
        self.list_:updateData(index,self.lastData_)

    end

    local lastIndex = #self.friendData_
    local index = 1
    for i=1,#self.friendData_ do
        if checkint(data.mid) == checkint(self.friendData_[i].mid) then
            index = i
        end
    end
    data.light = 1
    self.list_:updateData(index,data)

    -- nk.TopTipManager:showTopTip("index="..index)
    -- self.list_:scrollTo((lastIndex-8)*100)

    self.lastData_ = data
    self.fid_ = data.mid
    self:getFriendNotice()
    self:getSelfCor()
    self:getFriendMessageList()
end
function CornuFriendsView:setMessageLoading(isLoading)
    if isLoading then
        if not self.message_juhua_ then
            self.message_juhua_ = nk.ui.Juhua.new()
                --:pos(NOTICE_WIDTH/2, MESSAGE_HEIGHT/2+20)
                :addTo(self.myMessage_)
                :scale(.5)
        end
    else
        if self.message_juhua_ then
            self.message_juhua_:removeFromParent()
            self.message_juhua_ = nil
        end
    end
end
function CornuFriendsView:setFriendsLoading(isLoading)
    if isLoading then
        if not self.friends_juhua_ then
            self.friends_juhua_ = nk.ui.Juhua.new()
                --:pos(NOTICE_WIDTH/2, MESSAGE_HEIGHT/2+20)
                :addTo(self)
                :pos(0,HEIGHT/2-50)
                :scale(.5)
        end
    else
        if self.friends_juhua_ then
            self.friends_juhua_:removeFromParent()
            self.friends_juhua_ = nil
        end
    end
end
function CornuFriendsView:onCleanup()
    

    nk.http.cancel(self.friendDataRequestId_)
    nk.http.cancel(self.getFriendsMesaage_)
    nk.http.cancel(self.sendMsgRequestId_)
    nk.http.cancel(self.getMyCorRequest_)
    nk.http.cancel(self.requestMyNotice_)
    nk.http.cancel(self.getLevReqId_)

    self.friendDataRequestId_ = nil
    self.getFriendsMesaage_ = nil
    self.sendMsgRequestId_ = nil
    self.getMyCorRequest_ = nil
    self.requestMyNotice_ = nil
    self.getLevReqId_ = nil
end

return CornuFriendsView