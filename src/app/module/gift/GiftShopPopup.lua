--
-- Author: Tom
-- Date: 2014-11-26 14:22:19
--
local GiftShopPopUp = class("GiftShopPopUp", nk.ui.Panel)
local GiftListItem = import(".GiftListItem")
local GiftPopupController = import(".GiftPopupController")
local GiftListView = import(".GiftListView")
local PADDING = 16
local SUB_TAB_SPACE = 72
local POPUP_WIDTH = 720
local POPUP_HEIGHT = 480
local LIST_WIDTH = 680
local LIST_HEIGHT = 264
local WIDTH = 720 
local HEIGHT = 480
local BOTTOM 
local LEFT
local RIGHT


function GiftShopPopUp:ctor(defaultTab)
    self:setNodeEventEnabled(true)
    self.controller_ = GiftPopupController.new(self)
    GiftShopPopUp.super.ctor(self,{WIDTH,HEIGHT})
    bm.EventCenter:addEventListener(nk.eventNames.HIDE_GIFT_POPUP, handler(self, self.hidePopup))
    
    BOTTOM = -self.height_ * 0.5
    LEFT = -self.width_*0.5
    RIGHT = self.width_*0.5

    self:createNodes_()
    self:addCloseBtn()

    if defaultTab then
        self.mainTabBar_:gotoTab(defaultTab)
    end

end

function GiftShopPopUp:createNodes_()
    -- 一级tab bar
    self.mainTabBar_ = nk.ui.CommonPopupTabBar.new(
        {
            popupWidth = 720, 
            iconOffsetX = 10, 
            iconTexture = {
                {"#shop_gift_list_tab_icon_selected.png", "#shop_gift_list_tab_icon_unselected.png"}, 
                {"#my_gift_list_tab_icon_selected.png", "#my_gift_list_tab_icon_unselected.png"}
            }, 
            btnText = bm.LangUtil.getText("GIFT", "MAIN_TAB_TEXT"), 
        }
    )
        :pos(0, self.height_ * 0.5 - nk.ui.CommonPopupTabBar.TAB_BAR_HEIGHT * 0.5)
        :addTo(self)

    self.listPosY_ = -nk.ui.CommonPopupTabBar.TAB_BAR_HEIGHT * 0.5


    --添加数据到列表
    self.giftList_ = GiftListView.new(
        {
            viewRect = cc.rect(-LIST_WIDTH * 0.5, -LIST_HEIGHT * 0.5, LIST_WIDTH, LIST_HEIGHT),
            direction = bm.ui.ListView.DIRECTION_VERTICAL
        }, 
        GiftListItem
    )
    :pos(0, self.listPosY_)
    :addTo(self)

    self.giftList_.controller_ = self.controller_ 
    self.giftList_:onButtonSelectChanged(handler(self, self.onButtonSelectChanged_))

    self.buyGiftButton_ = cc.ui.UIPushButton.new({normal = "#common_green_btn_up.png",pressed = "#common_green_btn_down.png"}, {scale9 = true})
        :setButtonSize(200, 60)
        :setButtonLabel("normal", display.newTTFLabel({text=bm.LangUtil.getText("COMMON","BUY"), size=24, color=cc.c3b(0xb2, 0xdc, 0xff), align=ui.TEXT_ALIGN_CENTER}))
        :pos(RIGHT - 120, BOTTOM + 38)
        :onButtonClicked(buttontHandler(self, self.buyGiftHanler))
        :addTo(self)
        :hide()

    self.buyOtherFriendButton_ = cc.ui.UIPushButton.new({normal = "#common_dark_blue_btn_up.png",pressed = "#common_dark_blue_btn_down.png"}, {scale9 = true})
        :setButtonSize(200, 60)
        :setButtonLabel("normal", display.newTTFLabel({text=bm.LangUtil.getText("GIFT","BUY_TO_TABLE_GIFT_BUTTON_LABEL"), size=24, color=cc.c3b(0xb2, 0xdc, 0xff), align=ui.TEXT_ALIGN_CENTER}))
        :pos(LEFT + 120, BOTTOM + 38)
        :onButtonClicked(buttontHandler(self, self.buyGiftToOtherHandler))
        :addTo(self)
        :hide()

    self.curSelectGiftLabel_ = display.newTTFLabel({text = bm.LangUtil.getText("GIFT","CURRENT_SELECT_GIFT_BUTTON_LABEL") , color = cc.c3b(0x27, 0x90, 0xd5), size = 26, align = ui.TEXT_ALIGN_CENTER})
        :pos(0, BOTTOM + 58)
        :addTo(self)
        :hide()

    self.curSelectGiftName_ = display.newTTFLabel({text = bm.LangUtil.getText("GIFT","MY_GIFT_MESSAGE_PROMPT_LABEL") , size=24, color=cc.c3b(0xb2, 0xdc, 0xff), align=ui.TEXT_ALIGN_CENTER})
        :pos(0, BOTTOM + 48)
        :addTo(self)
        :hide()
    
end

function GiftShopPopUp:onButtonSelectChanged_(btnGroup, evt)
    print("onButtonSelectChanged_onButtonSelectChanged_",btnGroup)
end

function GiftShopPopUp:onMainTabChange_(selectedTab)
    self.selectTab_ = selectedTab
    if selectedTab == 1 then
        self:showShopGiftView(selectedTab)
        self:hideMainTab_1Button(true)
    elseif selectedTab == 2 then
        self:hideMainTab_1Button(false)
        self:showMyGiftView(selectedTab)
        self.controller_:updateGiftIdHandler(0)
    end
    self.controller_:onMainTabChange(selectedTab)
    self.controller_:getTableUseUid(self.useId_,self.useIdArray_,self.toUidArr_)
end

function GiftShopPopUp:showShopGiftView(selectedTab)
    if self.subTabBarShopGift_ == nil then
        self.subTabBarShopGift_ = nk.ui.TabBarWithIndicator.new(
            {
                background = "#popup_sub_tab_bar_bg.png", 
                indicator = "#popup_sub_tab_bar_indicator.png"
            }, 
            bm.LangUtil.getText("GIFT", "SUB_TAB_TEXT_SHOP_GIFT"), 
            nil, 
            true, 
            true
    )
        self.subTabBarShopGift_:addTo(self)
    end
        if self.subTabBarMyGift_ then
            self.subTabBarMyGift_:setVisible(false)
        end
        self.subTabBarShopGift_:setTabBarSize(560, 44, -4, -4)
        self.subTabBarShopGift_:pos(0, self.height_ * 0.5 - nk.ui.CommonPopupTabBar.TAB_BAR_HEIGHT - SUB_TAB_SPACE * 0.5)
        self.subTabBarShopGift_:onTabChange(handler(self, self.onSubTabChange_))
        self.subTabBarShopGift_:gotoTab(1, true)
        self.subTabBarShopGift_:setVisible(selectedTab == 1)
end

function GiftShopPopUp:showMyGiftView(selectedTab)
    if self.subTabBarMyGift_ == nil then
            self.subTabBarMyGift_ = nk.ui.TabBarWithIndicator.new(
            {
                background = "#popup_sub_tab_bar_bg.png", 
                indicator = "#popup_sub_tab_bar_indicator.png"
                }, 
            bm.LangUtil.getText("GIFT", "SUB_TAB_TEXT_MY_GIFT"), 
            nil, 
            true, 
            true
        )
            self.subTabBarMyGift_:addTo(self)
        end
        if self.subTabBarShopGift_ then
            self.subTabBarShopGift_:setVisible(false)
        end
        self.subTabBarMyGift_:setTabBarSize(560, 44, -4, -4)
        self.subTabBarMyGift_:pos(0, self.height_ * 0.5 - nk.ui.CommonPopupTabBar.TAB_BAR_HEIGHT - SUB_TAB_SPACE * 0.5)
        self.subTabBarMyGift_:onTabChange(handler(self, self.onSubTabChange_))
        self.subTabBarMyGift_:gotoTab(1, true)
        self.subTabBarMyGift_:setVisible(selectedTab == 2)
    
end

function GiftShopPopUp:onSubTabChange_(selectedTab)
    self.controller_:onSubTabChange(selectedTab)
end


function GiftShopPopUp:show(isRoom,uid,allTableId,tableNum,toUidArr)
    self.isRoom = isRoom
    self.useId_ = uid
    self.useIdArray_ = allTableId
    self.toUidArr_ = toUidArr
    self:showPanel_()
    if self.useId_ == nk.userData.uid then
        if self.isRoom then
            self.buyGiftButton_:setButtonLabel("normal", display.newTTFLabel({text=bm.LangUtil.getText("COMMON","BUY"), size=24, color=cc.c3b(0xb2, 0xdc, 0xff), align=ui.TEXT_ALIGN_CENTER}))
        end
    else
        if self.isRoom then
            self.buyGiftButton_:setButtonLabel("normal", display.newTTFLabel({text=bm.LangUtil.getText("GIFT","PRESENT_GIFT_BUTTON_LABEL"), size=24, color=cc.c3b(0xb2, 0xdc, 0xff), align=ui.TEXT_ALIGN_CENTER}))
        end
    end
    
    if self.isRoom then
        self.buyOtherFriendButton_:setButtonLabel("normal", display.newTTFLabel({text= bm.LangUtil.getText("GIFT","BUY_TO_TABLE_GIFT_BUTTON_LABEL",tableNum), size=24, color=cc.c3b(0xb2, 0xdc, 0xff), align=ui.TEXT_ALIGN_CENTER}))
    end
end  

function GiftShopPopUp:hidePopup()
     nk.PopupManager:removePopup(self)

end

function GiftShopPopUp:onRemovePopup(removeFunc)
    if self.selectTab_ and self.selectTab_ == 2 then
        self.controller_:useBuyGiftRequest(self.isRoom)
    end
    removeFunc()
end

function GiftShopPopUp:setListData(data, selectedId)
    self.data_ = data
    self.giftList_:setData(self.data_, nil)
    if selectedId then
        self.giftList_:selectGiftById(selectedId)
    else
        self.giftList_:selectGiftByIndex(1)
    end
end

function GiftShopPopUp:updateGiftStatus(evt)
    local sss = {}
    self.giftList_:setData(sss, nil)
    if self.data_ then
        self.giftList_:setData(self.data_, evt.data)
    end
end


function GiftShopPopUp:setLoading(isLoading)
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


function GiftShopPopUp:setNoDataTip(noData)
    if noData then
        if not self.noDataTip_ then
            self.noDataTip_ = display.newTTFLabel({text = bm.LangUtil.getText("GIFT", "NO_GIFT_TIP"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 24, align = ui.TEXT_ALIGN_CENTER})
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



function GiftShopPopUp:onShowed()
    self.mainTabBar_:onTabChange(handler(self, self.onMainTabChange_))
    if self.list_ then
        self.list_:setScrollContentTouchRect()
    end
end

function GiftShopPopUp:hideMainTab_1Button(flag)
    if flag then
        self.buyGiftButton_:show()
        if self.isRoom then
            self.buyOtherFriendButton_:show()
            self.buyGiftButton_:pos(RIGHT - 120, BOTTOM + 38)
        else
            self.buyGiftButton_:pos(0, BOTTOM + 38)
        end
        self.curSelectGiftName_:hide()
    else
        self.buyGiftButton_:hide()
        if self.isRoom then
            self.buyOtherFriendButton_:hide()
            self.buyGiftButton_:pos(RIGHT - 120, BOTTOM + 38)
        else 
            self.buyGiftButton_:pos(0, BOTTOM + 38)
        end
        self.curSelectGiftName_:show()
    end
    
end


function GiftShopPopUp:onCleanup()
    bm.EventCenter:removeEventListenersByEvent(nk.eventNames.HIDE_GIFT_POPUP)
    self.controller_:dispose()
end

function GiftShopPopUp:buyGiftHanler()
    if self.isRoom then
        if self.useId_ == nk.userData.uid then
            self.controller_:buyGiftRequest(self.isRoom)
        else
            self.controller_:requestPresentGiftData(self.isRoom)
        end
    else
        self.controller_:buyGiftRequest(self.isRoom)
    end
    
end

function GiftShopPopUp:buyGiftToOtherHandler()
    self.controller_:requestPresentTableGift(self.isRoom)
end


return GiftShopPopUp