--
-- Author: johnny@boomegg.com
-- Date: 2014-08-23 20:47:26
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

local RankingPopup = class("RankingPopup", nk.ui.Panel)
local RankingListItem = import(".RankingListItem")
local RankingPopupController = import(".RankingPopupController")

local PADDING = 16
local SUB_TAB_SPACE = 72
local POPUP_WIDTH = 720
local POPUP_HEIGHT = 480
local LIST_WIDTH = 716
local LIST_HEIGHT = 324

function RankingPopup:ctor()
    cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    self:setNodeEventEnabled(true)
    self.controller_ = RankingPopupController.new(self)

    RankingPopup.super.ctor(self, {720, 480})
    self:createNodes_()
    self:addCloseBtn()
    
end

function RankingPopup:createNodes_()
    -- 第二层背景
    -- display.newScale9Sprite("#panel_overlay.png", 0, 0, cc.size(self.width_, self.height_ - (nk.ui.CommonPopupTabBar.TAB_BAR_HEIGHT + SUB_TAB_SPACE + PADDING)))
    --     :pos(0, -(nk.ui.CommonPopupTabBar.TAB_BAR_HEIGHT + SUB_TAB_SPACE - PADDING) * 0.5)
    --     :addTo(self)
    -- 分割线
    local lineWidth = 684
    local lineHeight = 2
    local lineMarginLeft = 12
    self.line_ = display.newScale9Sprite("#pop_up_split_line.png")
        :pos(0, self.height_/2 - (nk.ui.CommonPopupTabBar.TAB_BAR_HEIGHT + SUB_TAB_SPACE))
        :addTo(self)
        :size(lineWidth, lineHeight)

    local touchCover = display.newScale9Sprite("#transparent.png", 0, self.height_ * 0.5 - 68, cc.size(self.width_, 136)):addTo(self, 9)
    touchCover:setTouchEnabled(true)
    touchCover:setTouchSwallowEnabled(true)

    -- 一级tab bar
    self.mainTabBar_ = nk.ui.CommonPopupTabBar.new(
        {
            popupWidth = 720, 
            iconOffsetX = 10, 
            iconTexture = {
                {"#friend_rank_tab_icon_selected.png", "#friend_rank_tab_icon_unselected.png"}, 
                {"#all_rank_tab_icon_selected.png", "#all_rank_tab_icon_unselected.png"}
            }, 
            btnText = bm.LangUtil.getText("RANKING", "MAIN_TAB_TEXT"), 
        }
    )
        :pos(0, self.height_ * 0.5 - nk.ui.CommonPopupTabBar.TAB_BAR_HEIGHT * 0.5)
        :addTo(self, 10)

    -- 列表
    self.listPosY_ = -(nk.ui.CommonPopupTabBar.TAB_BAR_HEIGHT + SUB_TAB_SPACE - PADDING) * 0.5
    self.list_ = bm.ui.ListView.new(
        {
            viewRect = cc.rect(-LIST_WIDTH * 0.5, -LIST_HEIGHT * 0.5, LIST_WIDTH, LIST_HEIGHT)
        }, 
        RankingListItem
    )
    :pos(0, self.listPosY_)
    :addTo(self)
end

function RankingPopup:onMainTabChange_(selectedTab)
    self.controller_:onMainTabChange(selectedTab)
    if selectedTab == 1 then
        self:showFriendRankView(selectedTab)
    elseif selectedTab == 2 then
        self:showAllRankView(selectedTab)
    end
end

function RankingPopup:onSubTabChange_(selectedTab)
    self.controller_:onSubTabChange(selectedTab)
end

function RankingPopup:setLoading(isLoading)
    if isLoading then
        self.list_:setData({})
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

function RankingPopup:setListData(data)
    self.list_:setData(data)
end

function RankingPopup:onShowed()
    -- 延迟设置，防止list出现触摸边界的问题
    self.mainTabBar_:onTabChange(handler(self, self.onMainTabChange_))
    self.list_:setScrollContentTouchRect()
end

function RankingPopup:show()
    self:showPanel_()
end

function RankingPopup:onCleanup()
    self.controller_:dispose()
end

function RankingPopup:showAllRankView(selectedTab)
    if self.subTabBarGlobal_ == nil then
            self.subTabBarGlobal_ = nk.ui.TabBarWithIndicator.new(
            {
                background = "#popup_sub_tab_bar_bg.png", 
                indicator = "#popup_sub_tab_bar_indicator.png"
            }, 
            bm.LangUtil.getText("RANKING", "SUB_TAB_TEXT_GLOBAL"), 
            {
                selectedText = {color = cc.c3b(0x27, 0x90, 0xd5), size = 20},
                defaltText = {color = cc.c3b(0xca, 0xca, 0xca), size = 20}
            }, 
            true, 
            true
        )
            self.subTabBarGlobal_:addTo(self, 11)
        end
        if self.subTabBarFriend_ then
            self.subTabBarFriend_:setVisible(false)
        end
        self.subTabBarGlobal_:setTabBarSize(600, 44, -4, -4)
        self.subTabBarGlobal_:pos(0, self.height_ * 0.5 - nk.ui.CommonPopupTabBar.TAB_BAR_HEIGHT - SUB_TAB_SPACE * 0.5)
        self.subTabBarGlobal_:onTabChange(handler(self, self.onSubTabChange_))
        self.subTabBarGlobal_:gotoTab(1, true)
        self.subTabBarGlobal_:setVisible(selectedTab == 2)
end

function RankingPopup:showFriendRankView(selectedTab)
    if self.subTabBarFriend_ == nil then
        self.subTabBarFriend_ = nk.ui.TabBarWithIndicator.new(
            {
                background = "#popup_sub_tab_bar_bg.png", 
                indicator = "#popup_sub_tab_bar_indicator.png"
            }, 
            bm.LangUtil.getText("RANKING", "SUB_TAB_TEXT_FRIEND"), 
            nil, 
            true, 
            true
    )
        self.subTabBarFriend_:addTo(self, 11)
    end
        if self.subTabBarGlobal_ then
            self.subTabBarGlobal_:setVisible(false)
        end
        self.subTabBarFriend_:setTabBarSize(500, 44, -4, -4)
        self.subTabBarFriend_:pos(0, self.height_ * 0.5 - nk.ui.CommonPopupTabBar.TAB_BAR_HEIGHT - SUB_TAB_SPACE * 0.5)
        self.subTabBarFriend_:onTabChange(handler(self, self.onSubTabChange_))
        self.subTabBarFriend_:gotoTab(1, true)
        self.subTabBarFriend_:setVisible(selectedTab == 1)
end

function RankingPopup:onExit()
    nk.schedulerPool:delayCall(function()
        cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    end, 0.1)
end

return RankingPopup