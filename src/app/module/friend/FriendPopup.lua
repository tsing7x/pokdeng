--
-- Author: johnny@boomegg.com
-- Date: 2014-08-31 20:11:50
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

local FriendPopup = class("FeiendPopup", nk.ui.Panel)
local FriendListItem = import(".FriendListItem")
local FriendPopupController = import(".FriendPopupController")
local InvitePopup = import(".InviteRecallPopup")

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

function FriendPopup:ctor(defaultTab)
    cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    self:setNodeEventEnabled(true)
    self.controller_ = FriendPopupController.new(self)

    FriendPopup.super.ctor(self, {720, 480})
    self:createNodes_()
    self:addCloseBtn()
    if defaultTab then
        self.mainTabBar_:gotoTab(defaultTab)
    end

     -- init analytics
    -- if device.platform == "android" or device.platform == "ios" then
    --     cc.analytics:start("analytics.UmengAnalytics")
    -- end

    --暂时隐藏
    --self.mainTabBar_:setVisible(false)

end

function FriendPopup:createNodes_()
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
        :addTo(self):hide()
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
            btnText = bm.LangUtil.getText("FRIEND", "MAIN_TAB_TEXT"), 
        }
    )
        :pos(0 + 20, self.height_ * 0.5 - nk.ui.CommonPopupTabBar.TAB_BAR_HEIGHT * 0.5)
        :addTo(self, 10)

    self.listPosY_ = -nk.ui.CommonPopupTabBar.TAB_BAR_HEIGHT * 0.5

    -- 恢复好友按钮
    self.restoreBtn_ = cc.ui.UIPushButton.new({normal = "#friend_restore_up.png", pressed = "#friend_restore_down.png"})
        :pos(-POPUP_WIDTH / 2 + 53, POPUP_HEIGHT / 2 - 37)
        :addTo(self,11)
        :onButtonClicked(handler(self, self.onRestoreList_))
    --self.restoreBtn_:hide()

    self.paopaoTips_ = nk.ui.PaoPaoTips.new(bm.LangUtil.getText("FRIEND", "RESTORE_BTN_TIP"), 24)
    self.paopaoTips_:pos(-POPUP_WIDTH / 2 + 53, POPUP_HEIGHT / 2 + 20):addTo(self, 12)
    
    local restore_state_tip_state = nk.userDefault:getIntegerForKey(nk.cookieKeys.TIPS_STATE.."restore", 0)
    if restore_state_tip_state == 1 then
        self.paopaoTips_:hide()
    end

    if PAOPAO_DISABLE then
        self.paopaoTips_:hide()
    end

    self.restoreTips_ = display.newTTFLabel({
             text = bm.LangUtil.getText("FRIEND", "RESTORE_TEXT"),
             size = 16,
             color = cc.c3b(0xff,0x00,0x00),
             align = ui.TEXT_ALIGN_CENTER,
             valign = ui.TEXT_VALIGN_CENTER
        })
        :align(display.CENTER_TOP, 0, self.height_ * 0.5 - nk.ui.CommonPopupTabBar.TAB_BAR_HEIGHT - 5)
        :addTo(self)
    self.restoreTips_:hide()

    self.returnBtn_ = cc.ui.UIPushButton.new({normal = "#friend_restore_back_up.png", pressed = "#friend_restore_back_down.png"})
        :pos(-POPUP_WIDTH / 2 + 53, POPUP_HEIGHT / 2 - 37)
        :addTo(self,11)
        :onButtonClicked(handler(self, self.onReturnBtn_))
    self.returnBtn_:hide()
end

function FriendPopup:onMainTabChange_(selectedTab)    
    if self.delList_ then
        self.delList_:removeFromParent()
        self.delList_ = nil
    end    
    self.returnBtn_:hide()
    self.restoreTips_:hide()
    self.restoreBtn_:show()
    self:setDelListNoDataTip(false)
    self.paopaoTips_:setText(bm.LangUtil.getText("FRIEND", "RESTORE_BTN_TIP"))
    
    if selectedTab == 1 then
        local overlayHeight = self.height_ - (nk.ui.CommonPopupTabBar.TAB_BAR_HEIGHT + PADDING * 2)
        self.panelOverlay_:setContentSize(cc.size(self.width_, overlayHeight))
        self.panelOverlay_:hide()
        self.line_:show()
        -- 移除邀请按钮
        if self.inviteBtnNode_ then 
            self.inviteBtnNode_:removeFromParent()
            self.inviteBtnNode_ = nil
        end
        -- 添加列表
        self.list_ = bm.ui.ListView.new(
            {
                viewRect = cc.rect(-LIST_WIDTH * 0.5, -LIST_HEIGHT * 0.5, LIST_WIDTH, LIST_HEIGHT)
            }, 
            FriendListItem
        )
        :pos(0, self.listPosY_)
        :addTo(self)
        self.list_.controller_ = self.controller_
    elseif selectedTab == 2 then
        self:setLoading(false)
        self:setNoDataTip(false)
        local overlayHeight = self.height_ - (nk.ui.CommonPopupTabBar.TAB_BAR_HEIGHT + PADDING + 160)
        self.panelOverlay_:setContentSize(cc.size(self.width_ - CONTENT_PADDING * 2, overlayHeight))
        self.panelOverlay_:show()
        self.line_:hide()
        -- 移除列表
        if self.list_ then 
            self.list_:removeFromParent()
            self.list_ = nil
        end
        -- 添加邀请按钮
        self.inviteBtnNode_ = display.newNode():addTo(self)

        -- 邀请描述
        display.newTTFLabel(
            {
                text = bm.LangUtil.getText("FRIEND", "INVITE_DESCRIPTION", nk.userData.inviteSendChips, nk.userData.inviteBackChips, "100K"), 
                color = cc.c3b(0xc7, 0xe5, 0xff),
                size = 24, 
                align = ui.TEXT_ALIGN_LEFT, 
                dimensions = cc.size(self.width_ - 60, overlayHeight)
            }
        )
            :pos(0, self.panelOverlay_:getPositionY() - overlayHeight * 0.5)
            :addTo(self.inviteBtnNode_)

        -- 邀请提示
        local historyVal = nk.userDefault:getIntegerForKey(nk.cookieKeys.FACEBOOK_INVITE_MONEY, 0)
        display.newTTFLabel(
            {
                text = bm.LangUtil.getText("FRIEND", "INVITE_REWARD_TIP", bm.formatNumberWithSplit(historyVal)), 
                color = cc.c3b(0x1a, 0x1f, 0x28), 
                size = 20, 
                dimensions = CCSize(POPUP_WIDTH-10,48),
                align = ui.TEXT_ALIGN_CENTER
            }
        )
            :pos(0, -self.height_ * 0.5 + 28)
            :addTo(self.inviteBtnNode_)

        -- 邮件邀请按钮
        local BTN_POS_Y = -140

        -- FB邀请按钮
        local btnPosX = INVITE_BTN_GAP + INVITE_BTN_WIDTH * 0.5 - self.width_ * 0.5
        cc.ui.UIPushButton.new({normal = "#facebook_invite_up_bg.png", pressed = "#facebook_invite_down_bg.png"}, {scale9 = true})
            :setButtonLabel("normal", display.newTTFLabel({text = bm.LangUtil.getText("FRIEND", "INVITE_WITH_FB"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 20, align = ui.TEXT_ALIGN_CENTER}))
            :setButtonLabel("pressed", display.newTTFLabel({text = bm.LangUtil.getText("FRIEND", "INVITE_WITH_FB"), color = styles.FONT_COLOR.GREY_TEXT, size = 20, align = ui.TEXT_ALIGN_CENTER}))
            :setButtonLabelOffset(40, 0)
            --:pos(INVITE_BTN_GAP + INVITE_BTN_WIDTH * 0.5 - self.width_ * 0.5, BTN_POS_Y)
            :pos(btnPosX, BTN_POS_Y)
            :setButtonSize(INVITE_BTN_WIDTH, INVITE_BTN_HEIGHT)
            :onButtonClicked(buttontHandler(self, self.onFbInviteClick_))
            :addTo(self.inviteBtnNode_)

        display.newSprite("#facebook_invite_icon.png")
            :pos(btnPosX - 58, BTN_POS_Y )
            :addTo(self.inviteBtnNode_)
            :scale(0.9)

        display.newScale9Sprite("#common_division_line.png", 0, 0, cc.size(2, INVITE_BTN_HEIGHT -10))
            :pos(btnPosX - 20, BTN_POS_Y)
            :addTo(self.inviteBtnNode_)

        btnPosX = INVITE_BTN_GAP * 2 + INVITE_BTN_WIDTH * 1.5 - self.width_ * 0.5
        cc.ui.UIPushButton.new({normal = "#common_dark_blue_btn_up.png", pressed = "#common_dark_blue_btn_down.png"}, {scale9 = true})
            :setButtonLabel("normal", display.newTTFLabel({text = bm.LangUtil.getText("FRIEND", "INVITE_WITH_MAIL"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 20, align = ui.TEXT_ALIGN_CENTER}))
            :setButtonLabel("pressed", display.newTTFLabel({text = bm.LangUtil.getText("FRIEND", "INVITE_WITH_MAIL"), color = styles.FONT_COLOR.GREY_TEXT, size = 20, align = ui.TEXT_ALIGN_CENTER}))
            :setButtonLabelOffset(40, 0)
            :pos(btnPosX, BTN_POS_Y)
            :setButtonSize(INVITE_BTN_WIDTH, INVITE_BTN_HEIGHT)
            :onButtonClicked(buttontHandler(self, self.onMailInviteClick_))
            :addTo(self.inviteBtnNode_)
        display.newSprite("#mail_invite_icon.png")
            :pos(btnPosX - 58, BTN_POS_Y)
            :addTo(self.inviteBtnNode_)
        display.newScale9Sprite("#common_division_line.png", 0, 0, cc.size(2, INVITE_BTN_HEIGHT -10))
            :pos(btnPosX - 20, BTN_POS_Y)
            :addTo(self.inviteBtnNode_)

        --[[
        -- 短信邀请按钮
        btnPosX = INVITE_BTN_GAP * 3 + INVITE_BTN_WIDTH * 2.5 - self.width_ * 0.5
        cc.ui.UIPushButton.new({normal = "#common_green_btn_up.png", pressed = "#common_green_btn_down.png"}, {scale9 = true})
            :setButtonLabel("normal", display.newTTFLabel({text = bm.LangUtil.getText("FRIEND", "INVITE_WITH_SMS"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 20, align = ui.TEXT_ALIGN_CENTER}))
            :setButtonLabel("pressed", display.newTTFLabel({text = bm.LangUtil.getText("FRIEND", "INVITE_WITH_SMS"), color = styles.FONT_COLOR.GREY_TEXT, size = 20, align = ui.TEXT_ALIGN_CENTER}))
            :setButtonLabelOffset(40, 0)
            :pos(btnPosX, BTN_POS_Y)
            :setButtonSize(INVITE_BTN_WIDTH, INVITE_BTN_HEIGHT)
            :onButtonClicked(buttontHandler(self, self.onSmsInviteClick_))
            :addTo(self.inviteBtnNode_)
        display.newSprite("#sms_invite_icon.png")
            :pos(btnPosX - 58, BTN_POS_Y)
            :addTo(self.inviteBtnNode_)
        display.newScale9Sprite("#common_division_line.png", 0, 0, cc.size(2, INVITE_BTN_HEIGHT -10))
            :pos(btnPosX - 20, BTN_POS_Y)
            :addTo(self.inviteBtnNode_)
        --]]

        -- Line邀请按钮
        btnPosX = INVITE_BTN_GAP * 3 + INVITE_BTN_WIDTH * 2.5 - self.width_ * 0.5
        cc.ui.UIPushButton.new({normal = "#common_green_btn_up.png", pressed = "#common_green_btn_down.png"}, {scale9 = true})
            :setButtonLabel("normal", display.newTTFLabel({text = bm.LangUtil.getText("FRIEND", "INVITE_WITH_LINE"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 20, align = ui.TEXT_ALIGN_CENTER}))
            :setButtonLabel("pressed", display.newTTFLabel({text = bm.LangUtil.getText("FRIEND", "INVITE_WITH_LINE"), color = styles.FONT_COLOR.GREY_TEXT, size = 20, align = ui.TEXT_ALIGN_CENTER}))
            :setButtonLabelOffset(40, 0)
            :pos(btnPosX, BTN_POS_Y)
            :setButtonSize(INVITE_BTN_WIDTH, INVITE_BTN_HEIGHT)
            :onButtonClicked(buttontHandler(self, self.onLineInviteClick_))
            :addTo(self.inviteBtnNode_)
        display.newSprite("#line_invite_icon.png")
            :pos(btnPosX - 58, BTN_POS_Y)
            :addTo(self.inviteBtnNode_)
        display.newScale9Sprite("#common_division_line.png", 0, 0, cc.size(2, INVITE_BTN_HEIGHT -10))
            :pos(btnPosX - 20, BTN_POS_Y)
            :addTo(self.inviteBtnNode_)




    end
    self.controller_:onMainTabChange(selectedTab)
end

function FriendPopup:onRestoreList_()
    nk.userDefault:setIntegerForKey(nk.cookieKeys.TIPS_STATE.."restore", 1)

    self:setLoading(false)
    self:setNoDataTip(false)
    self:setDelListNoDataTip(false)
    self.mainTabBar_:gotoTab(0)
    self.returnBtn_:show()
    self.restoreTips_:show()
    
    local restore_return_tip_state = nk.userDefault:getIntegerForKey(nk.cookieKeys.TIPS_STATE.."restore_return", 0)
    if restore_return_tip_state == 1 then
        self.paopaoTips_:hide()
    else       
        if PAOPAO_DISABLE then
            self.paopaoTips_:hide()
        else
            self.paopaoTips_:show()
        end
    end
    self.paopaoTips_:setText(bm.LangUtil.getText("FRIEND", "RETURN_BTN_TIP"))
    
    self.restoreBtn_:hide()
    local overlayHeight = self.height_ - (nk.ui.CommonPopupTabBar.TAB_BAR_HEIGHT + PADDING * 2)
    self.panelOverlay_:setContentSize(cc.size(self.width_, overlayHeight))
    self.panelOverlay_:hide()
    self.line_:show()
    
    -- 移除邀请按钮
    if self.inviteBtnNode_ then
        self.inviteBtnNode_:removeFromParent()
        self.inviteBtnNode_ = nil 
    end

    -- 移除列表
    if self.list_ then 
        self.list_:removeFromParent() 
        self.list_ = nil
    end

    -- 添加列表
    self.delList_ = bm.ui.ListView.new(
        {
            viewRect = cc.rect(-LIST_WIDTH * 0.5, -LIST_HEIGHT * 0.5, LIST_WIDTH, LIST_HEIGHT)
        }, 
        FriendListItem
    )
    :pos(0, self.listPosY_)
    :addTo(self)
    self.delList_.controller_ = self.controller_

    self.controller_:getDelFriendData()

end

function FriendPopup:onReturnBtn_()
    nk.userDefault:setIntegerForKey(nk.cookieKeys.TIPS_STATE.."restore_return", 1)
    self.returnBtn_:hide()
    self.restoreTips_:hide()
    self.restoreBtn_:show()
    self.mainTabBar_:gotoTab(1)
end

function FriendPopup:onFbInviteClick_()
    self:hidePanel_()
    InvitePopup.new():show()
    -- if device.platform == "android" or device.platform == "ios" then
    --     cc.analytics:doCommand{command = "event",
    --                 args = {eventId = "facebook_invite_friends", label = "user facebook_invite_friends"}}
    -- end
end

function FriendPopup:onSmsInviteClick_()
    nk.Native:sendSms(bm.LangUtil.getText("FRIEND", "INVITE_CONTENT", "100K"))
    -- if device.platform == "android" or device.platform == "ios" then
    --     cc.analytics:doCommand{command = "event",
    --                 args = {eventId = "sms_invite_friends", label = "user sms_invite_friends"}}
    -- end
end

function FriendPopup:onMailInviteClick_()
    nk.Native:showEmailView(bm.LangUtil.getText("FRIEND", "INVITE_SUBJECT"), bm.LangUtil.getText("FRIEND", "INVITE_CONTENT", "100K"))
    -- if device.platform == "android" or device.platform == "ios" then
    --     cc.analytics:doCommand{command = "event",
    --                 args = {eventId = "mail_invite_friends", label = "user mail_invite_friends"}}
    -- end
end

function FriendPopup:onLineInviteClick_()
    --line://msg/<CONTENT TYPE>/<CONTENT KEY>
    --http://line.me/R/msg/<CONTENT TYPE>/?<CONTENT KEY>
    local content = bm.LangUtil.getText("FRIEND","INVITE_CONTENT2") .. " https://goo.gl/IvNuO6"
    local contentType = "text"
    device.openURL(string.format("line://msg/%s/%s",contentType,content))
    -- if device.platform == "android" or device.platform == "ios" then
    --     cc.analytics:doCommand{command = "event",
    --                 args = {eventId = "line_invite_friends", label = "user line_invite_friends"}}
    -- end
end

function FriendPopup:setLoading(isLoading)
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

function FriendPopup:setNoDataTip(noData)
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

function FriendPopup:setDelListNoDataTip(noData)
    if noData then
        if not self.noDelListDataTip_ then
            self.noDelListDataTip_ = display.newTTFLabel({text = bm.LangUtil.getText("FRIEND", "RESTORE_NO_DATA"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 24, align = ui.TEXT_ALIGN_CENTER})
                :pos(0, self.listPosY_)
                :addTo(self)
        end
    else
        if self.noDelListDataTip_ then
            self.noDelListDataTip_:removeFromParent()
            self.noDelListDataTip_ = nil
        end
    end
end

function FriendPopup:setListData(data)
    self.list_:setData(data)
end

function FriendPopup:setDelListData(data)
    self.delList_:setData(data)
end

function FriendPopup:show()
    self:showPanel_()
end

function FriendPopup:onShowed()
    -- 延迟设置，防止list出现触摸边界的问题
    self.mainTabBar_:onTabChange(handler(self, self.onMainTabChange_))
    if self.list_ then
        self.list_:setScrollContentTouchRect()
    end
end

function FriendPopup:onCleanup()
    self.controller_:dispose()
end

function FriendPopup:onExit()
    nk.schedulerPool:delayCall(function()
        cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    end, 0.1)
end

return FriendPopup
