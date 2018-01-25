--
-- Author: thinkeras3@163.com
-- Date: 2015-09-15 17:11:50
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
--

local PADDING = 16
local POPUP_WIDTH = 720
local POPUP_HEIGHT = 480
local LIST_WIDTH = 716
local LIST_HEIGHT = 364
local INVITE_BTN_WIDTH = 200
local INVITE_BTN_HEIGHT = 84
local INVITE_BTN_GAP = 30
local CONTENT_PADDING = 12

local PAOPAO_DISABLE = true

local InvitePlayPopup = class("InvitePlayPopup", nk.ui.Panel)
local InvitePlayItem = import(".InvitePlayItem")

function InvitePlayPopup:ctor()
   -- self.roomModel_ = roomModel
	self:setNodeEventEnabled(true)
	InvitePlayPopup.super.ctor(self, {720, 480})
	self:createNodes_()
	self:addCloseBtn()
end

function InvitePlayPopup:createNodes_()
	-- 第二层背景
    self.panelOverlay_ = display.newScale9Sprite("#panel_overlay.png", 0, 0, cc.size(self.width_, self.height_ - (nk.ui.CommonPopupTabBar.TAB_BAR_HEIGHT + PADDING * 2)))
        :align(display.CENTER_TOP, 0, self.height_ * 0.5 - nk.ui.CommonPopupTabBar.TAB_BAR_HEIGHT - PADDING)
        :addTo(self)
        :hide()
    -- 分割线
    local lineWidth = 684
    local lineHeight = 2
    local lineMarginLeft = 12

    self.line_ = display.newScale9Sprite("#pop_up_split_line.png")
        :align(display.CENTER_TOP, 0, self.height_ * 0.5 - nk.ui.CommonPopupTabBar.TAB_BAR_HEIGHT - 24)
        :addTo(self)
        :size(lineWidth, lineHeight)

    local touchCover = display.newScale9Sprite("#transparent.png", 0, self.height_ * 0.5 - 45, cc.size(self.width_, 90)):addTo(self, 9)
    touchCover:setTouchEnabled(true)
    touchCover:setTouchSwallowEnabled(true)

    -- 一级tab bar
    self.mainTabBar_ = nk.ui.CommonPopupTabBar.new(
        {
            popupWidth = 650, 
            iconOffsetX = 10, 
            iconTexture = {
                {"#friend_list_tab_icon_selected.png", "#friend_list_tab_icon_unselected.png"}, 
                {"#invite_friend_tab_icon_selected.png", "#invite_friend_tab_icon_unselected.png"}
            }, 
            btnText = bm.LangUtil.getText("HALL", "PERSONAL_ROOM_INVITE_PLAY"), 
        }
    )
        :pos(0 + 20, self.height_ * 0.5 - nk.ui.CommonPopupTabBar.TAB_BAR_HEIGHT * 0.5)
        :addTo(self, 10)

    self.listPosY_ = -nk.ui.CommonPopupTabBar.TAB_BAR_HEIGHT * 0.5

    

    
end

function InvitePlayPopup:show()
	self:showPanel_()
end

function InvitePlayPopup:onShowed()
	-- 添加列表
    self.list_ = bm.ui.ListView.new(
            {
                viewRect = cc.rect(-LIST_WIDTH * 0.5, -LIST_HEIGHT * 0.5, LIST_WIDTH, LIST_HEIGHT)
            }, 
            InvitePlayItem
        )
        :pos(0, self.listPosY_)
        :addTo(self)

    self.list_:addEventListener("ITEM_EVENT", handler(self, self.sendInvite))
    

    self.mainTabBar_:onTabChange(handler(self, self.onMainTabChange_))
    --self.mainTabBar_:gotoTab(1)
    if self.list_ then
        self.list_:setScrollContentTouchRect()
    end
end

function InvitePlayPopup:onMainTabChange_(selectedTab)
    self:setNoDataTip(false)
    self:setLoading(false)
    nk.http.cancel(self.friendDataRequestId_)
    nk.http.cancel(self.getOnlinePlayerRequestId_)
    self.list_:setData({})
    
    if selectedTab == 1 then
        if not self.friendData_ then
            self:getFriendList()
        else
            if #self.friendData_ > 0 then
                self:setNoDataTip(false)
                self.list_:setData(self.friendData_)
            else
                self:setNoDataTip(true)
            end
        end    
    else
        if not self.onlineUserList then
            self:getOnlinePlayers()
        else
            if #self.onlineUserList >0 then
                self:setNoDataTip(false)
                self.list_:setData(self.onlineUserList)
            else
                self:setNoDataTip(true)
            end
        end
    end
end
function InvitePlayPopup:getOnlinePlayers()
    self:setLoading(true)
    self.getOnlinePlayerRequestId_ = nk.http.getOnlinePlayer(
        function(data)
            self:setLoading(false)
            nk.http.cancel(self.getOnlinePlayerRequestId_)
            if #data>0 then
                self:setNoDataTip(false)
                for i=1,#data do
                    data[i].isOnlineData = 1;
                end
                self.onlineUserList = data
                self.list_:setData(self.onlineUserList)
            else
                self:setNoDataTip(true)
            end
        end,
        function ()
            self:setLoading(false)
            nk.http.cancel(self.getOnlinePlayerRequestId_)
            nk.ui.Dialog.new({
                messageText = bm.LangUtil.getText("COMMON", "REQUEST_DATA_FAIL"), 
                secondBtnText = bm.LangUtil.getText("COMMON", "RETRY"), 
                callback = function (type)
                    if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                        self:getOnlinePlayers()
                    end
                end
            })
            :show()    
       end
    )
end
function InvitePlayPopup:getFriendList()
	self:setLoading(true)
	self.friendDataRequestId_ = nk.http.getHallFriendList(
        handler(self, self.onGetFriendData_), 
        function ()
            self:setLoading(false)
            nk.http.cancel(self.friendDataRequestId_)
            nk.ui.Dialog.new({
                messageText = bm.LangUtil.getText("COMMON", "REQUEST_DATA_FAIL"), 
                secondBtnText = bm.LangUtil.getText("COMMON", "RETRY"), 
                callback = function (type)
                	if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                    	self:getFriendList()
                    end
                end
    		})
            :show()    
       end)
end
function InvitePlayPopup:onGetFriendData_(data)
    nk.http.cancel(self.friendDataRequestId_)
	if data then
        self.friendData_ = data
        local uidList = {}
        if self.friendData_ then
            for i, v in ipairs(self.friendData_) do
                uidList[#uidList + 1] = v.fid
            end
        end
        nk.userData.friendUidList = uidList
        --if self.mainSelectedTab_ == 1 then
            if #self.friendData_ > 0 then
                self:setNoDataTip(false)
                self.list_:setData(self.friendData_)
            else
                self:setNoDataTip(true)
            end
            self:setLoading(false)
        --end
    end
end

function InvitePlayPopup:setNoDataTip(noData)
    if noData then
        if not self.noDataTip_ then
            self.noDataTip_ = display.newTTFLabel({text = bm.LangUtil.getText("FRIEND", "NO_FRIEND_TIP"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 24, align = ui.TEXT_ALIGN_CENTER})
                :pos(0, self.listPosY_)
                :addTo(self)
        end
    else
        if self.noDataTip_ then
            self.noDataTip_:removeFromParent()
            self.noDataTip_ = nil
        end
    end
end
function InvitePlayPopup:onCleanup()
	nk.http.cancel(self.friendDataRequestId_)
end

function InvitePlayPopup:onExit()

end
function InvitePlayPopup:setLoading(isLoading)
    if isLoading then
        if not self.juhua_ then
            self.juhua_ = nk.ui.Juhua.new()
                :pos(0, self.listPosY_)
                :addTo(self)
        end
    else
        if self.juhua_ then
            self.juhua_:removeFromParent()
            self.juhua_ = nil
        end
    end
end

function InvitePlayPopup:sendInvite(evt)
    local fid = evt.data
    local content = {}
    --content.tid = self.roomModel_.model.roomInfo.tid;
    --content.name = nk.userData["aUser.name"];
    --local contentStr_ = json.encode(content)
    self.broadcastRequestId_ = nk.http.broadcastUser(fid,2,content,
        function(data) 
            nk.http.cancel(self.broadcastRequestId_)
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("HALL", "PERSONAL_ROOM_INVITE_ONLINE")[5])
        end,
        function(errordata)
            nk.http.cancel(self.broadcastRequestId_)
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("HALL", "PERSONAL_ROOM_INVITE_ONLINE")[6])
        end
        )
end
return InvitePlayPopup