--
-- Author: tony
-- Date: 2014-08-12 15:50:25
--
local PurchaseType = import(".managers.PurchaseType")
local PurchaseManager = import(".managers.PurchaseManager")
local StorePopupController = import(".StorePopupController")
local HistoryListItem = import(".views.HistoryListItem")
local ProductChipListItem = import(".views.ProductChipListItem")
local ProductPropListItem = import(".views.ProductPropListItem")
local MyPropListItem = import(".views.MyPropListItem")

local StorePopup = class("StorePopup", nk.ui.Panel)

local WIDTH = 866
local HEIGHT = 566
local LEFT = WIDTH * -0.5
local TOP = HEIGHT * 0.5

local CONTENT_WIDTH = 610
local CONTENT_HEIGHT = 470

local chipData = {}
local propData = {}

function StorePopup:ctor(defaultTabIndex)
    StorePopup.super.ctor(self, {WIDTH, HEIGHT})
    self:setNodeEventEnabled(true)

    self:createNavTab_(defaultTabIndex)
    self.content_ = display.newNode():pos(120, -30):addTo(self)
    self:createTabs_()
    self:addCloseBtn()

    self:setLoading(true)
    self.controller_ = StorePopupController.new(self)

    self.btnGroup_:getButtonAtIndex(defaultTabIndex or 1):setButtonSelected(true)
end

function StorePopup:createNavTab_(defaultTabIndex)
    self.contentBg_ = display.newScale9Sprite("#store_content_background.png", 0, -32, cc.size(860, 480))
    self.contentBg_:setCapInsets(cc.rect(250, 32, 4, 4))
    self.contentBg_:addTo(self)

    self.title_ = display.newTTFLabel({text=bm.LangUtil.getText("STORE", "TITLE_STORE"), size=32, color=cc.c3b(0x64,0x9a,0xc9), align=ui.TEXT_ALIGN_CENTER})
        :pos(0,TOP - 40)
        :addTo(self)
    -- local titleW = self.title_:getContentSize().width
    -- self.titleIcon1_ = display.newSprite("#store_title_icon.png", -titleW * 0.5 - 24, self.title_:getPositionY()):addTo(self)
    -- self.titleIcon2_ = display.newSprite("#store_title_icon.png", titleW * 0.5 + 24, self.title_:getPositionY()):addTo(self)

    self.btnGroup_ = nk.ui.CheckBoxButtonGroup.new()
    self.btnGroup_:onButtonSelectChanged(handler(self, self.onTabChange_))

    local btnX = LEFT + 119
    local btnY = TOP - 120
    self.chipBtnBg_ = display.newSprite("#store_tab_btn_normal.png", btnX, btnY):addTo(self)
    self.btnGroup_:addButton(cc.ui.UICheckBoxButton.new({off="#transparent.png", on="#store_tab_btn_selected.png"}, {scale9=true})
            :setButtonSize(250, 56)
            :setButtonLabel(display.newTTFLabel({text=bm.LangUtil.getText("STORE", "TITLE_CHIP"), size=24, color=cc.c3b(255, 255, 255), align=ui.TEXT_ALIGN_CENTER}))
            :setButtonLabelOffset(-9, 0)
            :setButtonLabelAlignment(display.CENTER)
            :pos(btnX + 10, btnY)
            :addTo(self))

    btnY = btnY - 56
    self.propBtnBg_ = display.newSprite("#store_tab_btn_normal.png", btnX, btnY):addTo(self)
    self.btnGroup_:addButton(cc.ui.UICheckBoxButton.new({off="#transparent.png", on="#store_tab_btn_selected.png"}, {scale9=true})
            :setButtonSize(250, 56)
            :setButtonLabel(display.newTTFLabel({text=bm.LangUtil.getText("STORE", "TITLE_PROP"), color=cc.c3b(255, 255, 255), align=ui.TEXT_ALIGN_CENTER}))
            :setButtonLabelOffset(-9, 0)
            :setButtonLabelAlignment(display.CENTER)
            :pos(btnX + 10, btnY)
            :addTo(self))

    btnY = btnY - 60
    self.iconChip_ = display.newSprite("#chip_icon.png", LEFT + 30, btnY):addTo(self)
    self.chips_ = display.newTTFLabel({text="0", color=cc.c3b(255, 255, 255), size=24}):pos(LEFT + 30 + 30, btnY):addTo(self)
    self.chips_:setAnchorPoint(cc.p(0, 0.5))

    btnY = btnY - 56
    self.myPropBtnBg_ = display.newSprite("#store_tab_btn_normal.png", btnX, btnY):addTo(self)
    self.btnGroup_:addButton(cc.ui.UICheckBoxButton.new({off="#transparent.png", on="#store_tab_btn_selected.png"}, {scale9=true})
            :setButtonSize(250, 56)
            :setButtonLabel(display.newTTFLabel({text=bm.LangUtil.getText("STORE", "TITLE_MY_PROP"), color=cc.c3b(255, 255, 255), align=ui.TEXT_ALIGN_CENTER}))
            :setButtonLabelOffset(-9, 0)
            :setButtonLabelAlignment(display.CENTER)
            :pos(btnX + 10, btnY)
            :addTo(self))
    
    btnY = btnY - 56
    self.buyHistoryBtnBg_ = display.newSprite("#store_tab_btn_normal.png", btnX, btnY):addTo(self)
    self.btnGroup_:addButton(cc.ui.UICheckBoxButton.new({off="#transparent.png", on="#store_tab_btn_selected.png"}, {scale9=true})
            :setButtonSize(250, 56)
            :setButtonLabel(display.newTTFLabel({text=bm.LangUtil.getText("STORE", "TITLE_HISTORY"), color=cc.c3b(255, 255, 255), align=ui.TEXT_ALIGN_CENTER}))
            :setButtonLabelOffset(-9, 0)
            :setButtonLabelAlignment(display.CENTER)
            :pos(btnX + 10, btnY)
            :addTo(self))


    -- 无筹信息的提示
    self.emptyPrompt = display.newTTFLabel({text = "", color = cc.c3b(255, 255, 255), size = 24, align = ui.TEXT_ALIGN_CENTER})
        :pos(100, 0)
        :addTo(self)
        :hide()


end

function StorePopup:addDataWatcher_()
    self.moneyWatcher_ = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "aUser.money", handler(self, self.onMoneyChanged_))
end

function StorePopup:onMoneyChanged_(money)
    self.chips_:setString(bm.formatNumberWithSplit(money or 0))
    local iconW = self.iconChip_:getContentSize().width
    local textW = self.chips_:getContentSize().width
    if iconW + textW + 4 > 220 then
        self.chips_:setString(bm.formatBigNumber(money or 0))
        textW = self.chips_:getContentSize().width
    end
    local leftPadding = (240 - (iconW + textW + 4)) / 2
    self.iconChip_:setPositionX(LEFT + 4 + leftPadding + iconW * 0.5)
    self.chips_:setPositionX(LEFT + 4 + leftPadding + iconW + 4)
end

function StorePopup:removeDataWatcher_()
    bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "aUser.money", self.moneyWatcher_)
end

function StorePopup:getSelectedTabIndex()
    return self.selectedIndex_
end

function StorePopup:onTabChange_(evt)
    self.selectedIndex_ = evt.selected
    self.chipList_:setVisible(evt.selected == 1)
    self.propList_:setVisible(evt.selected == 2)
    self.myPropList_:setVisible(evt.selected == 3)
    self.historyList_:setVisible(evt.selected == 4)
    self.controller_:onTabChanged(evt.selected)
end

function StorePopup:showPanel(closeCallback)
    self.closeCallback_ = closeCallback
    self:showPanel_(true, true, true, true)
end

function StorePopup:onEnter()
    self:addDataWatcher_()
end

function StorePopup:onExit()
    self.controller_:dispose()
    self:removeDataWatcher_()
    if self.closeCallback_ then
        self.closeCallback_()
    end
end

function StorePopup:hidePanel()
    self:hidePanel_()
end

function StorePopup:onShowed()
    local cbox = self:getCascadeBoundingBox()
    cbox.width = WIDTH
    cbox.height = HEIGHT
    self:setCascadeBoundingBox(cbox)

    self.chipList_:setScrollContentTouchRect()
    self.propList_:setScrollContentTouchRect()
    self.myPropList_:setScrollContentTouchRect()
    self.historyList_:setScrollContentTouchRect()

    self.controller_:initialize()
end

function StorePopup:setLoading(isLoading)
    print("setLoading", isLoading)
    if isLoading then
        if not self.juhua_ then
            self.juhua_ = nk.ui.Juhua.new():pos(120, -30):addTo(self)
        end
    else
        if self.juhua_ then
            self.juhua_:removeFromParent()
            self.juhua_ = nil
        end
    end
end

function StorePopup:createTabs_()
    self.chipList_ = self:createProductChipTab_():addTo(self.content_):hide()
    self.propList_ = self:createProductPropTab_():addTo(self.content_):hide()
    self.myPropList_ = self:createMyPropsTab_():addTo(self.content_):hide()
    self.historyList_ = self:createHistoryTab_():addTo(self.content_):hide()

    self.chipList_:addEventListener("ITEM_EVENT", handler(self, self.onItemEvent_))
    self.propList_:addEventListener("ITEM_EVENT", handler(self, self.onItemEvent_))
    self.myPropList_:addEventListener("ITEM_EVENT", handler(self, self.onItemEvent_))
end

function StorePopup:createProductChipTab_()
    ProductChipListItem.WIDTH = CONTENT_WIDTH
    ProductChipListItem.HEIGHT = 78
    return bm.ui.ListView.new({viewRect = cc.rect(-0.5 * CONTENT_WIDTH, -0.5 * CONTENT_HEIGHT, CONTENT_WIDTH, CONTENT_HEIGHT), direction=bm.ui.ListView.DIRECTION_VERTICAL}, ProductChipListItem)
end

function StorePopup:setChipList(data)
    self.chipList_:setData(data)
    chipData = data
end

function StorePopup:emptyChipPrompt()
    if type(chipData) == "table" and #chipData >0 then
        self.emptyPrompt:hide()
    else
        self:performWithDelay(function ()
                self.emptyPrompt:show()
            end, 0.5)
        self.emptyPrompt:setString(bm.LangUtil.getText("STORE", "NO_PRODUCT_HINT"))
    end
end

function StorePopup:createProductPropTab_()
    ProductPropListItem.WIDTH = CONTENT_WIDTH
    ProductPropListItem.HEIGHT = 78
    return bm.ui.ListView.new({viewRect = cc.rect(-0.5 * CONTENT_WIDTH, -0.5 * CONTENT_HEIGHT, CONTENT_WIDTH, CONTENT_HEIGHT), direction=bm.ui.ListView.DIRECTION_VERTICAL}, ProductPropListItem)
end

function StorePopup:setPropList(data)
    self.propList_:setData(data)
    propData = data
end

function StorePopup:emptyPropPrompt()
    if type(propData) == "table" and #propData >0 then
        self.emptyPrompt:hide()
    else
        self:performWithDelay(function ()
                self.emptyPrompt:show()
            end, 0.5)
        self.emptyPrompt:setString(bm.LangUtil.getText("STORE", "NO_PROP_HINT"))
    end
end

function StorePopup:createMyPropsTab_()
    MyPropListItem.WIDTH = CONTENT_WIDTH
    MyPropListItem.HEIGHT = 78
    return bm.ui.ListView.new({viewRect = cc.rect(-0.5 * CONTENT_WIDTH, -0.5 * CONTENT_HEIGHT, CONTENT_WIDTH, CONTENT_HEIGHT), direction=bm.ui.ListView.DIRECTION_VERTICAL}, MyPropListItem)
end

function StorePopup:setMyPropData(data)
    if #data > 0 then
        self.emptyPrompt:hide()
    else
        self:performWithDelay(function ()
                self.emptyPrompt:show()
            end, 0.5)
        self.emptyPrompt:setString(bm.LangUtil.getText("STORE", "NO_MY_PROP_HINT"))
    end
    self.myPropList_:setData(data)
end

function StorePopup:createHistoryTab_()
    HistoryListItem.WIDTH = CONTENT_WIDTH
    HistoryListItem.HEIGHT = 78
    return bm.ui.ListView.new({viewRect = cc.rect(-0.5 * CONTENT_WIDTH, -0.5 * CONTENT_HEIGHT, CONTENT_WIDTH, CONTENT_HEIGHT), direction=bm.ui.ListView.DIRECTION_VERTICAL}, HistoryListItem)
end

function StorePopup:setHistoryData(data)
    if #data >0 then
        self.emptyPrompt:hide()
    else
        self:performWithDelay(function ()
                self.emptyPrompt:show()
            end, 0.5)
        self.emptyPrompt:setString(bm.LangUtil.getText("STORE", "NO_BUY_HISTORY_HINT"))
    end
    self.historyList_:setData(data)
end

function StorePopup:onItemEvent_(evt)
    if evt.type == "GOTO_TAB" then
        self.btnGroup_:getButtonAtIndex(evt.tab or 1):setButtonSelected(true)
    elseif evt.type == "MAKE_PURCHASE" then
        self.controller_:makePurchase(evt.pid)
    elseif evt.type == "REFRESH_MY_PROP" then
        self.controller_:refreshMyProps()
    end
end

return StorePopup

