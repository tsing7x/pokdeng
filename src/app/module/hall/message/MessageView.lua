
--
-- Author: shanks
-- Date: 2014.09.15
--

local MessageView = class("MessageView", nk.ui.Panel)
local MessageListItem = import(".MessageListItem")
local MessageData = import(".MessageData")

local PADDING = 16
local LIST_WIDTH = 708
local LIST_HEIGHT = 384

-- message model
MessageView.modelData = nil

local logger = bm.Logger.new("MessageView")

function MessageView:ctor()
    self:setNodeEventEnabled(true)

    MessageView.super.ctor(self, {720, 480})
    self:initView()
    self:addCloseBtn()

    self:NewMessageStatus()
end

function MessageView:NewMessageStatus()
    MessageData.hasNewMessage = false
    bm.DataProxy:setData(nk.dataKeys.NEW_MESSAGE, MessageData.hasNewMessage)
end

function MessageView:initView()
    -- second bg
    display.newScale9Sprite("#panel_overlay.png", 0, 0, cc.size(self.width_, self.height_ - (nk.ui.CommonPopupTabBar.TAB_BAR_HEIGHT + PADDING * 2)))
        :pos(0, - nk.ui.CommonPopupTabBar.TAB_BAR_HEIGHT * 0.5)
        :addTo(self)

    -- tab
    self.tabBar = nk.ui.CommonPopupTabBar.new(
        {
            popupWidth = 720, 
            iconOffsetX = 10, 
            iconTexture = {
                {"#message_friend_tab_icon_selected.png", "#message_friend_tab_icon_unselected.png"}, 
                {"#message_system_tab_icon_selected.png", "#message_system_tab_icon_unselected.png"}
            }, 
            btnText = bm.LangUtil.getText("MESSAGE", "TAB_TEXT"), 
        })
        :pos(0, self.height_ * 0.5 - nk.ui.CommonPopupTabBar.TAB_BAR_HEIGHT * 0.5)
        :addTo(self)

    -- list
    self.listPosY = - nk.ui.CommonPopupTabBar.TAB_BAR_HEIGHT * 0.5
    self.list = bm.ui.ListView.new(
        {
            viewRect = cc.rect(-LIST_WIDTH * 0.5, -LIST_HEIGHT * 0.5, LIST_WIDTH, LIST_HEIGHT)
        }, 
        MessageListItem
    )
    :pos(0, self.listPosY )
    :addTo(self)

    -- empty prompt
    self.emptyPrompt = display.newTTFLabel({text = bm.LangUtil.getText("MESSAGE", "EMPTY_PROMPT"), color = cc.c3b(0xff, 0xff, 0xff), size = 24, align = ui.TEXT_ALIGN_CENTER})
        :pos(0, 0)
        :addTo(self)
        :hide()
end 

function MessageView:onShowed()
    -- 延迟设置，防止list出现触摸边界的问题
    self:setDefaultTab()
    self.tabBar:onTabChange(handler(self, self.onTabChange))
    self.list:setScrollContentTouchRect()

    
end

--设置默认栏目
function MessageView:setDefaultTab()
    if MessageData.newMsgType then
        if #MessageData.newMsgType > 0 then
            for i,v in ipairs(MessageData.newMsgType) do
                if v <= 200 then
                    self.tabBar:gotoTab(1)
                    break;

                else
                    self.tabBar:gotoTab(2)
                    break;
                end
            end
        else
            self.tabBar:gotoTab(2)

        end
        
    end
end

function MessageView:onTabChange(selectedTab)
    self.selectedTab = selectedTab
    self:requestMessageModel()
end

function MessageView:show()
    self:showPanel_()
end

function MessageView:requestMessageModel()
    if MessageView.modelData then
        self:requestMessageData()
    else 
        local url = nk.userData.MSGTPL_ROOT
        self:setLoading(true)
        self.cacheRequestId_ = bm.cacheFile(url,function(result, content)
            if result == "success" then
                MessageView.modelData = json.decode(content)
                self:requestMessageData()
                logger:debug("success loading msgModel")

            else
                logger:debug("error loading msgModel")

            end
        end,"msg")

        
        -- nk.http.get_url(url,{},function(data)
        --     MessageView.modelData = json.decode(data)
        --     self:requestMessageData()
        -- end,function()
        --     logger:debug("error loading url")
        -- end);

        --[[
        bm.HttpService.GET_URL(url, {}, function(data)
            MessageView.modelData = json.decode(data)
            self:requestMessageData()
        end, function()
            logger:debug("error loading url")
        end)
        --]]
    end
end

function MessageView:requestMessageData()
    if self.messageData then
        self:onGetMessageData(self.messageData)
        return
    end

    self:setLoading(true)


    self.requestMessageDataId = nk.http.getUserMessage(handler(self, self.onGetMessageData),function(data)
        self:setLoading(false)
        logger:debug("get_message_data:" .. tostring(data))
    end)

    --[[
    self.requestMessageDataId = bm.HttpService.POST(
    {
        mod = "user", 
        act = "getmsg", 
    }, 
    handler(self, self.onGetMessageData), 
    function (data)
        self:setLoading(false)
        logger:debug("get_message_data:" .. data)
    end
    )
    --]]
end

-- [{"a":141042587402323,"b":102,"c":0,"d":1410425874,"e":"<#nick##Win32#><#chips##20000#>","f":10010,"g":"215962622197469","h":"","i":"13894",
-- "img":"https:\/\/d21w0fxhsbogha.cloudfront.net\/static\/images\/dash_pay_mobile.png"},{"a":141042586256374,"b":101,"c":0,"d":1410425862,
-- "e":"<#nick##Win32#>","f":3,"g":"0","h":"","i":0,"img":"https:\/\/d21w0fxhsbogha.cloudfront.net\/static\/images\/dash_pay_mobile.png"},
-- {"a":141040082562221,"b":206,"c":0,"d":1410400825,"e":"<#msg##\u0e0a\u0e34\u0e1b50K,\u0e44\u0e2d\u0e40\u0e17\u0e2115\u0e04\u0e23\u0e31\u0e49\u0e07#>",
-- "f":10013,"g":"100","h":"","i":0,"img":"https:\/\/d21w0fxhsbogha.cloudfront.net\/static\/images\/dash_pay_mobile.png"},{"a":141031861965662,"b":206,
-- "c":0,"d":1410318619,"e":"<#msg##\u0e0a\u0e34\u0e1b40K,\u0e44\u0e2d\u0e40\u0e17\u0e2110\u0e04\u0e23\u0e31\u0e49\u0e07#>","f":10013,"g":"100","h":"","i":0,
-- "img":"https:\/\/d21w0fxhsbogha.cloudfront.net\/static\/images\/dash_pay_mobile.png"}]
function MessageView:onGetMessageData(data)
    self:setLoading(false)

    self.messageData = data
    -- logger:debug("get_message_data:" .. data)

    if data then
        -- local jsonData = json.decode(data)

        self.friendData = {}
        self.systemData = {}

        for i=1, #data, 1 do
            local keyTable = {} 
            local i1 = 0
            local j1 = 0
            local str = data[i].e
            while true do
                -- print("str:" .. str)
                i1, j1 = string.find(str, "<#.-#>", j1) 
                if j1 == nil then break end
                -- print("sub:" .. string.sub(str, i1, j1))
                table.insert(keyTable, string.sub(str, i1, j1))
            end

            --从模板配置用获取图片Url
            local imgIndex = MessageView.modelData.pic[data[i].b .. ""][data[i].f .. ""]
            data[i].img = MessageView.modelData.piclist[imgIndex] or "";

            data[i].msg = MessageView.modelData.msg[data[i].b .. ""][data[i].f .. ""]
            for m=1, #keyTable, 1 do
                -- print(keyTable[m])
                local i2, j2 = string.find(keyTable[m], "<#.-#")  
                local key = string.sub(keyTable[m], (i2 + 2), (j2 - 1))
                -- print("key:" .. key)      
                local i3, j3 =     string.find(keyTable[m], "#.-#>", (j2 + 1))
                local value = string.sub(keyTable[m], (i3 + 1), (j3 - 2))
                -- print("value:" .. value)

                data[i].msg = string.gsub(data[i].msg, (key), value)
                -- print(data[i].msg .. " ====================== msg")
            end

            if checkint(data[i].b) <= 200 then
                -- friend message
                self.friendData[#self.friendData + 1] = data[i]
            else
                -- system message
                self.systemData[#self.systemData + 1] = data[i]
            end
        end

        self.list:setData(nil)
        self.emptyPrompt:hide()
        if self.selectedTab == 1 then
            self.list:setData(self.friendData)
            if #self.friendData <= 0 then
                self.emptyPrompt:show()
            end
        else
            self.list:setData(self.systemData)
            if #self.systemData <= 0 then
                self.emptyPrompt:show()
            end
        end        
    end
end

function MessageView:setLoading(isLoading)
    if isLoading then
        if not self.juhua_ then
            self.juhua_ = nk.ui.Juhua.new()
                :pos(0, self.listPosY )
                :addTo(self)
        end
    else
        if self.juhua_ then
            self.juhua_:removeFromParent()
            self.juhua_ = nil
        end
    end
end

function MessageView:onCleanup()
    -- nk.http.cancel(self.requestMessageDataId)
    if self.requestMessageDataId then
        nk.http.cancel(self.requestMessageDataId)
    end

    if self.cacheRequestId_ then
        nk.http.cancel(self.cacheRequestId_)
    end
end

return MessageView