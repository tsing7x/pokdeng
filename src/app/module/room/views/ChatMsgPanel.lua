--
-- Author: tony
-- Date: 2014-08-06 11:56:22
--
local ChatMsgShortcutListItem = import(".ChatMsgShortcutListItem")
local ChatMsgHistoryListItem = import(".ChatMsgHistoryListItem")
local ChatTabPanel = import(".ChatTabPanel")
local ChatMsgPanel = class("ChatMsgPanel", ChatTabPanel)
-- local StorePopup = import("app.module.newstore.StorePopup")
local GiftStorePopup = import("app.module.newstore.GiftStorePopup")
local messageList = {}
local setMessageList = {}


function ChatMsgPanel:ctor()
    ChatMsgPanel.super.ctor(self, bm.LangUtil.getText("ROOM", "CHAT_TAB_SHORTCUT"), bm.LangUtil.getText("ROOM", "CHAT_TAB_HISTORY"))
    self:setNodeEventEnabled(true)

    --聊天输入框
    self.editBox_ = cc.ui.UIInput.new({
        image = "#room_chat_input_up_bg.png",
        imagePressed = "#room_chat_input_down_bg.png",
        size = cc.size(295, 58),
        x = - ChatMsgPanel.PAGE_WIDTH * 0.5 + 212,
        y = self.HEIGHT * 0.5 - 8 - 30 - 68,
        listener = handler(self, self.onEditBoxStateChange_)
    })
    self.editBox_:setFontName(ui.DEFAULT_TTF_FONT)
    self.editBox_:setFontSize(25)
    self.editBox_:setFontColor(cc.c3b(0xb7, 0xc8, 0xd4))
    self.editBox_:setPlaceholderFontName(ui.DEFAULT_TTF_FONT)
    self.editBox_:setPlaceholderFontSize(25)
    self.editBox_:setPlaceholderFontColor(cc.c3b(0xb7, 0xc8, 0xd4))
    self.editBox_:setPlaceHolder(bm.LangUtil.getText("ROOM", "INPUT_HINT_MSG"))
    self.editBox_:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    if device.platform == "ios" then
        self.editBox_:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    else
        self.editBox_:setReturnType(cc.KEYBOARD_RETURNTYPE_SEND)
    end
    self.editBox_:addTo(self)


    self.laSelectImage_ = cc.ui.UICheckBoxButton.new({off="#room-chat-pane-laba-background-up.png",on = "#room-chat-pane-laba-background-up.png"})
        :setButtonLabelOffset(12,-19)
        :pos(- ChatMsgPanel.PAGE_WIDTH * 0.5 + 32, self.HEIGHT * 0.5 - 8 - 30 - 68)
        :onButtonStateChanged(handler(self, self.selectChangeListener))
        :onButtonClicked(handler(self, self.laSelectImageHandler_))
        :onButtonPressed(function()
            self.laSelectImage_:setButtonImage("on","#room-chat-pane-laba-background-up.png")
        end)
        :onButtonRelease(function ()
            self.laSelectImage_:setButtonImage("off","#room-chat-pane-laba-background-down.png")
        end)
        :addTo(self)

    self.laBaImage_ = display.newSprite("#common-laba-icon-down.png")
        :pos(- ChatMsgPanel.PAGE_WIDTH * 0.5 + 32, self.HEIGHT * 0.5 - 8 - 30 - 68)
        :addTo(self)

    self.laBaNumberLabel_ = display.newTTFLabel({size=14, text="x0", color=cc.c3b(0x27, 0x90, 0xd5)})
        :pos(- ChatMsgPanel.PAGE_WIDTH * 0.5 + 55, self.HEIGHT * 0.5 - 8 - 52 - 68)
        :hide()
        :addTo(self)


        self.laSelectImage_:setVisible(false)
        self.laBaImage_:setVisible(false)
        self.laBaNumberLabel_:setVisible(false)

    --发送按钮
    self.sendBtn_ = cc.ui.UIPushButton.new({normal="#common_green_btn_up.png", pressed="#common_green_btn_down.png", disabled="#common_btn_disabled.png"}, {scale9=true})
        :setButtonLabel(cc.ui.UILabel.new({text = bm.LangUtil.getText("COMMON", "SEND"), size = 24,  color = cc.c3b(0xff, 0xff, 0xff)}))
        :setButtonSize(116, 64)
        :pos(ChatMsgPanel.PAGE_WIDTH * 0.5 - 58, self.editBox_:getPositionY() - 2)
        :onButtonClicked(buttontHandler(self, self.onSendClicked_))
        :addTo(self)

        --test
        self.laBaNumber_ = 0
    --[[暂时屏蔽
    self.laBaNumberRequestId_ = bm.HttpService.POST({mod="user", act="getUserProps",id = 32},
        function(data) 
            self.laBaNumberRequestId_ = nil
            local callData = json.decode(data)
            if callData and (#callData > 0)  and callData[1].b then
                self.laBaNumber_ = callData[1].b
                self.laBaNumberLabel_:setString("x"..callData[1].b)
            else
                self.laBaNumber_ = 0
                self.laBaNumberLabel_:setString("x0")
            end
        end, function()
            self.laBaNumberRequestId_ = nil
        end)


        --]]


    self:setPage(1, self:createShortcutPage_())
    self:setPage(2, self:createHistoryPage_())

    self.MessageType = 1
end

function ChatMsgPanel:createShortcutPage_()
    local page = display.newNode()

    --快捷消息
    local listW, listH = ChatMsgPanel.PAGE_WIDTH, ChatMsgPanel.PAGE_HEIGHT - 68
    self.shortcutMsgStringArr_ = bm.LangUtil.getText("ROOM", "CHAT_SHORTCUT")
    ChatMsgShortcutListItem.WIDTH = listW
    ChatMsgShortcutListItem.HEIGHT = 68
    ChatMsgShortcutListItem.ON_ITEM_CLICKED_LISTENER = buttontHandler(self, self.onChatShortcutClicked_)
    self.shortcutMsgList_ = bm.ui.ListView.new({
            viewRect = cc.rect(-0.5 * listW, -0.5 * listH, listW, listH),
            direction = bm.ui.ListView.DIRECTION_VERTICAL,
        }, ChatMsgShortcutListItem)
    self.shortcutMsgList_:addTo(page):pos(0, -38)
    self.shortcutMsgList_:setData(self.shortcutMsgStringArr_)
    return page
end

function ChatMsgPanel:createHistoryPage_()
    local page = display.newNode()
    --快捷消息
    local listW, listH = ChatMsgPanel.PAGE_WIDTH, ChatMsgPanel.PAGE_HEIGHT - 68
    ChatMsgHistoryListItem.WIDTH = listW
    ChatMsgHistoryListItem.HEIGHT = 68
    self.historyList_ = bm.ui.ListView.new({
        viewRect = cc.rect(-0.5 * listW, -0.5 * listH, listW, listH),
        direction = bm.ui.ListView.DIRECTION_VERTICAL,
        }, ChatMsgHistoryListItem)
    self.historyList_:addTo(page):pos(0, -38)
    return page
end

function ChatMsgPanel:onShow()
    self.shortcutMsgList_:setScrollContentTouchRect()
    self.historyList_:setScrollContentTouchRect()
    nk.cacheKeyWordFile()
end

function ChatMsgPanel:onChatShortcutClicked_(msg)
    if nk.userData.silenced == 1 then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "USER_SILENCED_MSG"))
        return
    end
    -- nk.socket.RoomSocket:sendChatMsg(msg)
    
    nk.server:sendRoomChat(msg)
    self:hidePanel()
end

function ChatMsgPanel:onEnter()
    self.historyWatcher_ = bm.DataProxy:addDataObserver(nk.dataKeys.ROOM_CHAT_HISTORY, handler(self, self.historyChanged_))
    self.bigLaBaMessageWatacher_ = bm.DataProxy:addDataObserver(nk.dataKeys.BIG_LA_BA_CHAT_HISTORY, handler(self, self.historyChanged_))
end

function ChatMsgPanel:onExit()
    bm.DataProxy:removeDataObserver(nk.dataKeys.ROOM_CHAT_HISTORY, self.historyWatcher_)
    bm.DataProxy:removeDataObserver(nk.dataKeys.BIG_LA_BA_CHAT_HISTORY, self.bigLaBaMessageWatacher_)
    if self.laBaNumberRequestId_ then
        nk.http.cancel(self.laBaNumberRequestId_)
    end
end

function ChatMsgPanel:historyChanged_(list)
    local mergedList = {}
    table.insertto(mergedList, bm.DataProxy:getData(nk.dataKeys.ROOM_CHAT_HISTORY) or {})
    table.insertto(mergedList, bm.DataProxy:getData(nk.dataKeys.BIG_LA_BA_CHAT_HISTORY) or {})
    table.sort(mergedList, function(o1, o2)
        return o2.time > o1.time
    end)
    self.historyList_:setData(mergedList)
    self.historyList_:scrollTo(9999999)
end


function ChatMsgPanel:onEditBoxStateChange_(evt, editbox)
    local text = editbox:getText()
    if evt == "began" then
    elseif evt == "ended" then
    elseif evt == "returnSend" then
        if device.platform ~= "ios" then
            self:onSendClicked_()
            self:hidePanel()
        end
    elseif evt == "changed" then
        local filteredText = nk.keyWordFilter(text)
        if filteredText ~= text then
            editbox:setText(filteredText)
        end
    else
        printf("EditBox event %s", tostring(evt))
    end
end

function ChatMsgPanel:onSendClicked_()
    if nk.userData.silenced == 1 then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "USER_SILENCED_MSG"))
        return
    end
    local text = string.trim(self.editBox_:getText())
    if self.MessageType == 2 then
        if text ~= "" then
            self.laBaUserRequestId_ = bm.HttpService.POST({mod="user", act="useprops",id = 32,message = text,key = crypto.md5("boomegg!@#$%"..text..os.time()),time = os.time() ,nick = nk.userData.nick},
                function(data) 
                    self.laBaUserRequestId_ = nil
                    local callData = json.decode(data)
                    self:hidePanel()
                end, function()
                    self.laBaUserRequestId_ = nil
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "SEND_BIG_LABA_MESSAGE_FAIL"))
                end)
        end
    else
        if text ~= "" then
            nk.server:sendRoomChat(text)

            -- nk.socket.RoomSocket:sendChatMsg(message)
            self:hidePanel()
        end
    end

       
    
end

function ChatMsgPanel:selectChangeListener(evt)
    if self.laBaNumber_ and self.laBaNumber_ <= 0 then
        return
    end
    local getFrame = display.newSpriteFrame
    if evt.target:isButtonSelected()  then
       self.MessageType = 2
       self.laBaImage_:setSpriteFrame(getFrame("common-laba-icon-up.png"))
       self.laBaNumberLabel_:show()
    else
        self.MessageType = 1
        self.laBaImage_:setSpriteFrame(getFrame("common-laba-icon-down.png"))
        self.laBaNumberLabel_:hide()
    end
   
end

function ChatMsgPanel:laSelectImageHandler_()
   if  self.laBaNumber_ and self.laBaNumber_ <= 0 then
            nk.ui.Dialog.new({
            hasCloseButton = true,
            messageText = bm.LangUtil.getText("ROOM", "NO_BIG_LA_BA"), 
            firstBtnText = bm.LangUtil.getText("COMMON", "CANCEL"),
            secondBtnText = bm.LangUtil.getText("COMMON", "BUY"), 
            callback = function (type)
                if type == nk.ui.Dialog.FIRST_BTN_CLICK then
                  
                elseif type == nk.ui.Dialog.SECOND_BTN_CLICK then
                    -- StorePopup.new(2, nil, 2):showPanel()
                    GiftStorePopup.new(2):showPanel()
                end
            end
        }):show()
   end
end

return ChatMsgPanel