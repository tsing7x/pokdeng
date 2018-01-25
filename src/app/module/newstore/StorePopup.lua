--
-- Author: tony
-- Date: 2014-11-17 16:32:41
-- 
-- Description: StorePopup. Modify by Tsing.

-- local GiftProdLineCompon = import(".views.GiftProdLineCompon")
-- local PropProdListItem = import(".views.PropProdListItem")

local ProductChipListItem = import(".views.ProductChipListItem")
local ProductPropListItem = import(".views.ProductPropListItem")
local ProductTicketListItem = import(".views.ProductTicketListItem")
local ProductCashListItem = import(".views.ProductCashListItem")
local HistoryListItem = import(".views.HistoryListItem")

local CheckoutGuidePopup = import(".CheckoutGuidePopup")

local TextureHandler = import(".TextureHandler")
local StorePopupController = import(".StorePopupController")

local StorePopup = class("StorePopup", nk.ui.Panel)
-- local logger = bm.Logger.new("StorePopup")

local StorePanelParam = {
    WIDTH = 864,
    HEIGHT = 544
}

-- local W, H = 860, 614 - 72
local PW, PH = 678, 480 - 72

-- defaultTabIndex:默认顶部tab索引
--defaultPurchaseType:默认支付渠道（对应 PURCHASE_TYPE.lua 定义的类型）
function StorePopup:ctor(defaultTabIndex, defaultPurchaseType)
    StorePopup.super.ctor(self, {StorePanelParam.WIDTH, StorePanelParam.HEIGHT})

    TextureHandler.loadTexture()
    self.defaultTab_ = defaultTabIndex or 1

    self:setNodeEventEnabled(true)
    self.bigJuhua_ = nk.ui.Juhua.new():addTo(self)
    self.controller_ = StorePopupController.new(self)
    self.defaultPurchaseType_ = defaultPurchaseType



    
end

function StorePopup:onEnter()
    self.controller_:init()
    if StorePopup.super.onEnter then
        StorePopup.super.onEnter(self)
    end

    -- bm.EventCenter:addEventListener(nk.eventNames.STORE_GIFT_SELECT_CHANG, handler(self, self.storeGiftSelectChanged_))
    -- bm.EventCenter:addEventListener(nk.eventNames.STORE_PROP_SELECT_CHANG, handler(self, self.storePropSelectChanged_))
end

function StorePopup:onExit()
    
    -- self.controller_:useBuyGiftRequest()
    if StorePopup.super.onExit then
        StorePopup.super.onExit(self)
    end
    if self.closeCallback_ then
        self.closeCallback_()
        self.closeCallback_ = nil
    end
    self.controller_:dispose()
    -- bm.EventCenter:removeEventListenersByEvent(nk.eventNames.STORE_GIFT_SELECT_CHANG)
    -- bm.EventCenter:removeEventListenersByEvent(nk.eventNames.STORE_PROP_SELECT_CHANG)
    TextureHandler.removeTexture()
end

function StorePopup:onCleanup()
    -- body
    -- self.controller_:useBuyGiftRequest()
end
-- @param :inRoomInfoParam {isInRoom = , toUid = , toUidArr = , tableNum = , allTabId = }
function StorePopup:showPanel(closeCallback)
    self.closeCallback_ = closeCallback
    
    -- if inRoomInfoParam then
    --     --todo
    --     self.isInRoom_ = inRoomInfoParam.isInRoom
    --     self.toUid_ = inRoomInfoParam.toUid
    --     self.toUidArr_ = inRoomInfoParam.toUidArr
    --     self.tableUserNum_ = inRoomInfoParam.tableNum
    --     self.allTableId_ = inRoomInfoParam.allTabId
    -- end
    self:showPanel_(true, true, true, true)
end

function StorePopup:hidePanel()
    self:hidePanel_()
end

function StorePopup:onShowed()
    self.isShowed_ = true
    if self.createMainUIRequest_ then
        self.createMainUIRequest_()
        self.createMainUIRequest_ = nil
    end

    self:updateTouchRect_()

    if device.platform == "android" and nk.OnOff:check("checkoutGuide") then
        self:checkShowCheckoutGuide()
    end
    
end

function StorePopup:updateTouchRect_()
    if self.payTypeSelectList_ then
        self.payTypeSelectList_:setScrollContentTouchRect()
    end
    if self.chipList_ then
        self.chipList_:setScrollContentTouchRect()
    end
    if self.propList_ then
        self.propList_:setScrollContentTouchRect()
    end
    if self.historyList_ then
        self.historyList_:setScrollContentTouchRect()
    end

    if self.ticketList_ then
        self.ticketList_:setScrollContentTouchRect()
    end

    if self.cashPayList_ then
        --todo
        self.cashPayList_:setScrollContentTouchRect()
    end
    -- if self.propStoreSubTabSelList_ then
    --     --todo
    --     self.propStoreSubTabSelList_:update()
    -- end
end

function StorePopup:createMainUI(payTypeList)
    if self.isShowed_ then
        self:createMainUI_(payTypeList)
    else
        self.createMainUIRequest_ = function()
            self:createMainUI_(payTypeList)  -- lua函数闭包原则
        end
    end
end

function StorePopup:createMainUI_(payTypeList)
    if self.bigJuhua_ then
        self.bigJuhua_:removeFromParent()
        self.bigJuhua_ = nil
    end

    local touchCoverBottomSize = {
        width = StorePanelParam.WIDTH,
        height = 30
    }

    local touchCoverMagrinBot = 17
    local touchCoverBottom = display.newScale9Sprite("#transparent.png", 0, - StorePanelParam.HEIGHT / 2 + touchCoverMagrinBot,
        cc.size(touchCoverBottomSize.width, touchCoverBottomSize.height))
        :addTo(self, 9)
    touchCoverBottom:setTouchEnabled(true)
    touchCoverBottom:setTouchSwallowEnabled(true)

    local userMoneyInfoLabelParam = {
        frontSize = 22,
        color = cc.c3b(0xca, 0xca, 0xca)
    }

    local moneyinfoLabelPaddingBottom = 16
    self.info_ = display.newTTFLabel({size= userMoneyInfoLabelParam.frontSize, color= userMoneyInfoLabelParam.color, text=""})
        :addTo(self)
        :pos(0, - StorePanelParam.HEIGHT / 2 + moneyinfoLabelPaddingBottom)
    self:setMoney(nk.userData["aUser.money"])

    self.payTypeList_ = payTypeList
    self.selectedPayType_ = payTypeList[1]

    if payTypeList and #payTypeList > 1 then
        PW = 678
        ProductChipListItem.PADDING_LEFT = 10
        ProductPropListItem.PADDING_LEFT = 10
        ProductTicketListItem.PADDING_LEFT = 10
        ProductCashListItem.PADDING_LEFT = 10

        self:createPayTypeList_(payTypeList)
    else
        PW = 860 - 16 * 2
        ProductChipListItem.PADDING_LEFT = 2
        ProductPropListItem.PADDING_LEFT = 2
        ProductTicketListItem.PADDING_LEFT = 2
        ProductCashListItem.PADDING_LEFT = 2
    end

    ProductChipListItem.WIDTH = PW - 6
    ProductChipListItem.HEIGHT = 77

    ProductPropListItem.WIDTH = PW - 6
    ProductPropListItem.HEIGHT = 77

    HistoryListItem.WIDTH = 860 - 16 * 2
    HistoryListItem.HEIGHT =  77

    ProductTicketListItem.WIDTH = PW - 6
    ProductTicketListItem.HEIGHT = 77

    ProductCashListItem.WIDTH = PW - 6
    ProductCashListItem.HEIGHT = 77

    self:createMainTabUI_()
    self:gotoTab(self.defaultTab_)
    self.defaultTab_ = nil

    self:addCloseBtn()
end

function StorePopup:setMoney(money)
    if self.info_ then
        local str = bm.formatNumberWithSplit(nk.userData["aUser.money"])
        self.info_:setString(bm.LangUtil.getText("STORE", "MY_CHIPS", str))
    end
end

function StorePopup:createMainTabUI_()

    -- self.mainTabBar_ = nk.ui.CommonPopupTabBar.new(
    --     {
    --         popupWidth = 860,
    --         iconOffsetX=4,
    --         iconTexture = {
    --             {"#store_tab_icon_chip_down.png", "#store_tab_icon_chip_up.png"},
    --             {"#store_tab_icon_history_down.png", "#store_tab_icon_history_up.png"},
    --         },
    --         btnText = {
    --             bm.LangUtil.getText("STORE", "TITLE_CHIP"),
    --             bm.LangUtil.getText("STORE", "TITLE_HISTORY"),
    --         }
    --     })
    --     :pos(0, StorePanelParam.HEIGHT * 0.5 - nk.ui.CommonPopupTabBar.TAB_BAR_HEIGHT * 0.5 - 10)
    --     :onTabChange(handler(self, self.onMainTabChange))
    --     :addTo(self, 10)
    local touchCoverSize = {
        width = StorePanelParam.WIDTH - 2 * 2,
        height = 102
    }

    -- panel_overlay.png
    local touchCoverTitle = display.newScale9Sprite("#transparent.png", 0, StorePanelParam.HEIGHT * 0.5 - nk.ui.CommonPopupTabBar.TAB_BAR_HEIGHT * 0.5 - 20,
        cc.size(touchCoverSize.width, touchCoverSize.height))
        :addTo(self, 9)
    touchCoverTitle:setTouchEnabled(true)
    touchCoverTitle:setTouchSwallowEnabled(true)

    self.mainTabBar_ = nk.ui.CommonPopupTabBar.new({popupWidth = 860, iconOffsetX=4,
        iconTexture = {
            {"#store_tabIcon_chip_sel.png", "#store_tabIcon_chip_nor.png"},
            -- {"#store_tabIcon_ticket_sel.png", "#store_tabIcon_ticket_nor.png"},
            {"#store_tabIcon_cash_sel.png", "#store_tabIcon_cash_nor.png"},
            {"#store_tabIcon_histry_sel.png", "#store_tabIcon_histry_nor.png"},
        },

        btnText = {
            bm.LangUtil.getText("STORE", "TITLE_CHIP"),
            -- bm.LangUtil.getText("STORE","TITLE_TICKET"),
            bm.LangUtil.getText("STORE", "TITLE_CASH"),
            bm.LangUtil.getText("STORE", "TITLE_HISTORY"),
        }
        -- extraParam = {
        --     iconCircleTexture = {"#store_tabCir_sel.png", "#xxx.png"},
        --     tabFrontColor = {cc.c3b(230, 109, 12), display.COLOR_WHITE}
        -- }
    })
    :setTabBarExtraParam({iconCircleTexture = {"store_tabCir_sel.png", "popup_tab_bar_icon_unselected.png"},
        tabFrontColor = {cc.c3b(230, 109, 12), display.COLOR_WHITE}})
    :pos(0, StorePanelParam.HEIGHT * 0.5 - nk.ui.CommonPopupTabBar.TAB_BAR_HEIGHT * 0.5 - 10)
    :onTabChange(handler(self, self.onMainTabChange))
    :addTo(self, 10)
end

function StorePopup:createPayTypeList_(payTypeList)
    local defaultPayTypeGroupIdx = 1
    local w = 180
    local contentNode = display.newNode()
    self.payTypeGroup_ = nk.ui.CheckBoxButtonGroup.new()
    local fromY = 58 * (#payTypeList - 1) * 0.5
    for i, paytype in ipairs(payTypeList) do
        display.newSprite("#store_paytype_bg.png"):addTo(contentNode):pos(-6, fromY)
        local btn = cc.ui.UICheckBoxButton.new({on="#store_paytype_selected.png", off="#transparent.png"}, {scale9=true})
            :setButtonSize(178, 58)
            :pos(0, fromY)
            :addTo(contentNode)
        btn:setTouchSwallowEnabled(false)
        self.payTypeGroup_:addButton(btn)

        local path = cc.FileUtils:getInstance():fullPathForFilename("store_paytype_" .. paytype.id .. ".png")
        dump(path,"paytype.id:" .. paytype.id .. "exists:" .. tostring(io.exists(path)))
        --优先使用单独的png文件
        if io.exists(path) then
            display.newSprite("store_paytype_" .. paytype.id .. ".png")
                :pos(-5, fromY)
                :addTo(contentNode)
        else
            --其次使用素材包中的 找不到不显示
            local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame("store_paytype_" .. paytype.id .. ".png")
            if frame then
                display.newSprite(frame):pos(-5, fromY):addTo(contentNode)
            end
        end
        fromY = fromY - 58

        if paytype.id == self.defaultPurchaseType_ then
            defaultPayTypeGroupIdx = i
            self.selectedPayType_ = paytype
            self.defaultPurchaseType_ = nil
        end
    end
    self.payTypeSelectList_ = bm.ui.ScrollView.new({
        viewRect = cc.rect(-0.5 * w, -0.5 * PH, w, PH),
        direction=bm.ui.ScrollView.DIRECTION_VERTICAL,
        scrollContent=contentNode,
    }):addTo(self, 10):pos(StorePanelParam.WIDTH * -0.5 + w * 0.5 - 2, StorePanelParam.HEIGHT * -0.5 + PH * 0.5 + 32)
    self.payTypeGroup_:getButtonAtIndex(defaultPayTypeGroupIdx):setButtonSelected(true)
    self.payTypeGroup_:onButtonSelectChanged(handler(self, self.onPayTypeChange_))
end

function StorePopup:gotoTab(tab)
    self.mainTabBar_:gotoTab(tab)
end

function StorePopup:getSelectedTab()
    return self.selectedTab_ or 1
end

function StorePopup:getSelectedPayType()
    return self.selectedPayType_ or self.payTypeList_[1]
end

function StorePopup:onMainTabChange(selectedTab)
    if self.selectedTab_ ~= selectedTab then
        self.selectedTab_ = selectedTab
        if self.input1_ then
            self.input1_:hide()
        end
        if self.input2_ then
            self.input2_:hide()
        end
        if self.submitBtn_ then
            self.submitBtn_:hide()
        end
        self.pages_ = self.pages_ or {}
        for _, page in pairs(self.pages_) do
            if page then
                --todo
                page:hide()
            end
        end

        local page = self.pages_[selectedTab]

        if not page then
            if selectedTab == 1 then
                page = self:createChipPage_()
            -- elseif selectedTab == 2 then
            --     page = self:createTicketPage_()
                
            elseif selectedTab == 2 then
                page = self:createCashPage_()
            elseif selectedTab == 3 then
                page = self:createHistoryPage_()
            end
            self.pages_[selectedTab] = page
            page:addTo(self)
        end

        page:show()
        if selectedTab == 1 then
            if self.payTypeSelectList_ then
                self.payTypeSelectList_:show()
            end
            self:loadProductList_()
        -- elseif selectedTab == 2 then
        --     if self.payTypeSelectList_ then
        --         self.payTypeSelectList_:show()
        --     end
            
        --     self:loadProductList_()

        elseif selectedTab == 2 then
            if self.payTypeSelectList_ then
                self.payTypeSelectList_:show()
            end

            self:loadProductList_()
        elseif selectedTab == 3 then
            if self.payTypeSelectList_ then
                self.payTypeSelectList_:hide()
            end
            self:loadHistory_()
        end
    end


    --[[
    if self.selectedTab_ ~= selectedTab then
        self.selectedTab_ = selectedTab
        if self.input1_ then
            self.input1_:hide()
        end
        if self.input2_ then
            self.input2_:hide()
        end
        if self.submitBtn_ then
            self.submitBtn_:hide()
        end
        self.pages_ = self.pages_ or {}
        for _, page in pairs(self.pages_) do
            page:hide()
        end
        local page = self.pages_[selectedTab]
        if not page then
            if selectedTab == 1 then
                page = self:createChipPage_()
            elseif selectedTab == 2 then
                page = self:createPropPage_()
            elseif selectedTab == 3 then
                page = self:createHistoryPage_()
            end
            page:addTo(self)
            self.pages_[selectedTab] = page
        end
        page:show()
        if selectedTab == 1 then
            if self.payTypeSelectList_ then
                self.payTypeSelectList_:show()
            end
            self:loadProductList_()
        elseif selectedTab == 2 then
            if self.payTypeSelectList_ then
                self.payTypeSelectList_:show()
            end
            self:loadProductList_()
        elseif selectedTab == 3 then
            if self.payTypeSelectList_ then
                self.payTypeSelectList_:hide()
            end
            self:loadHistory_()
        end
    end

    --]]
end

function StorePopup:onPayTypeChange_(evt)
    self.selectedPayType_ = self.payTypeList_[evt.selected] or self.payTypeList_[1]
    self:loadProductList_()
end

-- Abandoned By Req change! --
function StorePopup:onPropSubTabChanged_(evt)
    -- body
    local labelColorByState = {
        nor = cc.c3b(85, 110, 141),
        sel = cc.c3b(230, 109, 12)
    }

    if not self._propSubTabSelectedIndex then
        --todo
        self._propSubTabSelectedIndex = evt.selected

        self.propSubBtnGroup[self._propSubTabSelectedIndex].label_:setTextColor(labelColorByState.sel)
        self.propSubBtnGroup[self._propSubTabSelectedIndex].selBgImg_:show()
        self.propSubBtnGroup[self._propSubTabSelectedIndex].selIndexArrow_:show()

        -- self.pages_[2].propContPage[self._propSubTabSelectedIndex]:show()
        -- DoSomething when self.defaultPropSubIndex_ Page Loading
    end

    local isChanged = self._propSubTabSelectedIndex ~= evt.selected

    if isChanged then
        --todo
        -- 修改之前的选项为未选中状态
        self.propSubBtnGroup[self._propSubTabSelectedIndex].label_:setTextColor(labelColorByState.nor)
        self.propSubBtnGroup[self._propSubTabSelectedIndex].selBgImg_:hide()
        self.propSubBtnGroup[self._propSubTabSelectedIndex].selIndexArrow_:hide()
        self.pages_[3].propContPage[self._propSubTabSelectedIndex]:hide()
        -- 修改点击项为选中状态
        self.propSubBtnGroup[evt.selected].label_:setTextColor(labelColorByState.sel)
        self.propSubBtnGroup[evt.selected].selBgImg_:show()
        self.propSubBtnGroup[evt.selected].selIndexArrow_:show()
        self.pages_[3].propContPage[evt.selected]:show()

        -- DoSomeThing when self._propSubTabSelectedIndex to evt.selected

        local blockBottomSize = {
            width = 624,
            height = 64
        }

        local buyBtnShownBetween = 410

        if evt.selected == 1 and self.isInRoom_ then
            --todo
            self.buyOneBtn_:pos(blockBottomSize.width / 2 + buyBtnShownBetween / 2, blockBottomSize.height / 2)
            self.buyToTableBtn_:show()
        else
            self.buyOneBtn_:pos(blockBottomSize.width / 2, blockBottomSize.height / 2)
            self.buyToTableBtn_:hide()
        end

        self._propSubTabSelectedIndex = evt.selected
    end

end

-- Abandoned By Req change! -- 
function StorePopup:onSubTabGiftShopChanged_(subTabIndx)
    -- body

    if self.giftProductList_ then
        --todo
        self.giftProductList_:removeFromParent()
        self.giftProductList_ = nil
    end

    local giftData = self.controller_:getGiftGroupByIdx(subTabIndx)

    -- dump(giftData, "giftData:================")

    if #giftData == 0 then
        --todo
        self.noGiftLabel:show()

    else
        bm.EventCenter:removeEventListenersByEvent(nk.eventNames.STORE_GIFT_SELECT_CHANG)
        bm.EventCenter:addEventListener(nk.eventNames.STORE_GIFT_SELECT_CHANG, handler(self, self.storeGiftSelectChanged_))
        self.noGiftLabel:hide()

        local propGiftListViewParam = {
            width = 570,
            height = 295
        }

        local propGiftListViewMagrinRight = 36
        local contentNode = display.newNode()

        local giftProdComponMagrinEachLine = 5

        local lineComponHeight = 108

        local itemsInOneLine = 4
        local lineComponNum = math.ceil(#giftData / 4)

        local lineComponItemDataList = {}
        for i = 1, lineComponNum do
            lineComponItemDataList[i] = {}
            for j = 1, itemsInOneLine do

                if giftData[(i - 1) * itemsInOneLine + j] then
                    --todo
                    local componItem = {}
                    componItem.idx_ = (i - 1) * itemsInOneLine + j
                    componItem.data_ = giftData[(i - 1) * itemsInOneLine + j]
                    table.insert(lineComponItemDataList[i], componItem)
                end
            end
        end

        local sumLineComponHeight = lineComponHeight * lineComponNum + giftProdComponMagrinEachLine * (lineComponNum - 1)

        for i = 1, lineComponNum do
            local giftProductLineCompon = GiftProdLineCompon.new(lineComponItemDataList[i])
                :pos(- propGiftListViewParam.width / 2, sumLineComponHeight / 2 - lineComponHeight * i - giftProdComponMagrinEachLine * (i - 1))  -- 描点有点奇怪！
                :addTo(contentNode)
        end

        local propProdListPosAdjust = {
            x = 5,
            y = 25
        }

        self.giftProductList_ = bm.ui.ScrollView.new({viewRect = cc.rect(- propGiftListViewParam.width / 2, - propGiftListViewParam.height / 2,
            propGiftListViewParam.width, propGiftListViewParam.height), direction = bm.ui.ScrollView.DIRECTION_VERTICAL, scrollContent = contentNode})
            :pos(StorePanelParam.WIDTH / 2 - propGiftListViewMagrinRight - propGiftListViewParam.width / 2 + propProdListPosAdjust.x, - propProdListPosAdjust.y)
            :addTo(self.pages_[3].propContPage[1])

        self.giftSelectedId_ = tonumber(giftData[1].pnid)
    end

end

-- Abandoned By Req change! --
function StorePopup:onPropBuyBtnCallBack_()
    -- body

    -- 购买礼物 --
    if self._propSubTabSelectedIndex == 1 then
        --todo
        if self.isInRoom_ then
            --todo
            self.controller_:presentGiftToUid(self.giftSelectedId_, self.toUid_)
        else
            self.controller_:buyGiftRequest(self.giftSelectedId_)
        end
        
    end

    -- 购买道具 --
    if self._propSubTabSelectedIndex == 2 then
        --todo
        self.controller_:buyPropsById(self.propInfoSelectedId_)
    end
end

-- Abandoned By Req change! --
function StorePopup:onBuyGiftToAllTableCallBack_()
    -- body
    self.controller_:presentGiftToTable(self.giftSelectedId_, self.toUidArr_, self.allTableId_)
end

-- Abandoned By Req change! --
function StorePopup:onPropListDataGet()
    -- body

    if self.propLoading_ then
        --todo
        self.propLoading_:removeFromParent()
        self.propLoading_ = nil
    end
    
    local PropListData = self.controller_:getPropListData()

    if PropListData and #PropListData > 0 then
        --todo
        self.propProductList_:setData(PropListData)
        self.propInfoSelectedId_ = PropListData[1].data_.id
    else
        self.noPropOnSellLabel:show()
    end
    -- 这里开始setData -- 并将第一个礼物的信息记录下来
    -- self.propInfoSelectedId_ = xxx[1].xxx
end

-- Abandoned By Req change! --
function StorePopup:onGetPropDataWrong(propType)
    -- body
    if propType == 1 then
        --todo
        --读取配置出错
        if self.propLoading_ then
            --todo
            self.propLoading_:removeFromParent()
            self.propLoading_ = nil
        end
    end
    
    if propType == 2 then
        --todo
        -- 网络错误弹框
        nk.ui.Dialog.new({
        messageText = bm.LangUtil.getText("COMMON", "REQUEST_DATA_FAIL"), 
                secondBtnText = bm.LangUtil.getText("COMMON", "RETRY"), 
                callback = function (type)
                    if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                        self.controller_:loadPropShopProductList(2)
                    else
                        if self.propLoading_ then
                            --todo
                            self.propLoading_:removeFromParent()
                            self.propLoading_ = nil
                        end
                    end
                end
        }):show()
    end
    -- 
end

-- Abandoned By Req change! --
function StorePopup:loadPropGoodsList(pagePropType)
    -- body
    self.controller_:loadPropShopProductList(pagePropType)
end

function StorePopup:loadProductList_()
    local selectedPayType = self:getSelectedPayType()
    if not selectedPayType then
        return
    end
    -- dump(selectedPayType, "selectedPayType:===================")

    if self.selectedTab_ == 1 then
        self.controller_:loadChipProductList(self:getSelectedPayType())
    -- elseif self.selectedTab_ == 2 then
    --     self.controller_:loadTicketProductList(self:getSelectedPayType())
    elseif self.selectedTab_ == 2 then
        -- 添加现金币订单支付类型变化 --
        self.controller_:loadCashProductList(self:getSelectedPayType())
    end
end

function StorePopup:loadHistory_()
    self.controller_:loadHistory()
end

function StorePopup:setCashPaymentList(paytype, isComplete, data)
    -- body
    -- dump(data, "setCashPaymentList.data:======================")

    self:showInputIfNeeded_("cash")
    if paytype.id == self:getSelectedPayType().id then
        if not self.pages_[2] then return end
        
        if isComplete then
            self.cashPayListJuhua_:hide()
            if type(data) == "string" then
                self.cashPayListMsg_:setString(data)
                self.cashPayListMsg_:show()
                self.cashPayList_:setData(nil)
            else
                self.cashPayListMsg_:hide()
                self.cashPayList_:setData(data)
                self:updateTouchRect_()
            end
        else
            self.cashPayList_:setData(nil)
            self.cashPayListMsg_:hide()
            self.cashPayListJuhua_:show()
        end
    end
end

function StorePopup:setTicketList(paytype, isComplete, data)

    -- dump(data, "setTicketList.data:======================")
    self:showInputIfNeeded_("tickets")
    if paytype.id == self:getSelectedPayType().id then
        if not self.pages_[2] then return end
        if isComplete then
            self.ticketListJuhua_:hide()
            if type(data) == "string" then
                self.ticketListMsg_:setString(data)
                self.ticketListMsg_:show()
                self.ticketList_:setData(nil)
            else
                self.ticketListMsg_:hide()
                self.ticketList_:setData(data)
                self:updateTouchRect_()
            end
        else
            self.ticketList_:setData(nil)
            self.ticketListMsg_:hide()
            self.ticketListJuhua_:show()
        end
    end
end


function StorePopup:setChipList(paytype, isComplete, data)
    self:showInputIfNeeded_("chips")
    if paytype.id == self:getSelectedPayType().id then
        if not self.pages_[1] then return end
        if isComplete then
            self.chipListJuhua_:hide()
            if type(data) == "string" then
                self.chipListMsg_:setString(data)
                self.chipListMsg_:show()
                self.chipList_:setData(nil)
            else
                self.chipListMsg_:hide()
                self.chipList_:setData(data)
                self:updateTouchRect_()
            end
        else
            self.chipList_:setData(nil)
            self.chipListMsg_:hide()
            self.chipListJuhua_:show()
        end
    end
end

function StorePopup:showInputIfNeeded_(productType)
    self.selectedProductType_ = productType
    if not self.input1_ then
        self.input1_ = cc.ui.UIInput.new({
            image = "#common_input_bg.png",
            imagePressed = "#common_input_bg_down.png",
            size = cc.size(PW - 210, 44),
        }):addTo(self, 100):hide()
        self.input1_:setFontName(ui.DEFAULT_TTF_FONT)
           self.input1_:setFontSize(24)
           self.input1_:setFontColor(cc.c3b(0xb7, 0xc8, 0xd4))
        self.input1_:setPlaceholderFontName(ui.DEFAULT_TTF_FONT)
        self.input1_:setPlaceholderFontSize(24)
        self.input1_:setPlaceholderFontColor(cc.c3b(0xb7, 0xc8, 0xd4))
    end
    if not self.input2_ then
        self.input2_ = cc.ui.UIInput.new({
            image = "#common_input_bg.png",
            imagePressed = "#common_input_bg_down.png",
            size = cc.size(PW - 210, 44),
        }):addTo(self, 100):hide()
        self.input2_:setFontName(ui.DEFAULT_TTF_FONT)
           self.input2_:setFontSize(24)
           self.input2_:setFontColor(cc.c3b(0xb7, 0xc8, 0xd4))
        self.input2_:setPlaceholderFontName(ui.DEFAULT_TTF_FONT)
        self.input2_:setPlaceholderFontSize(24)
        self.input2_:setPlaceholderFontColor(cc.c3b(0xb7, 0xc8, 0xd4))
    end
    if not self.submitBtn_ then
        self.submitBtn_ = cc.ui.UIPushButton.new({normal="#common_green_btn_up.png", pressed="#common_green_btn_down.png"}, {scale9=true})
            :setButtonLabel("normal", display.newTTFLabel({size=28, text=bm.LangUtil.getText("STORE", "CARD_INPUT_SUBMIT"), align=ui.TEXT_ALIGN_CENTER}))
            :onButtonClicked(buttontHandler(self, self.onSubmitClicked_))
            :addTo(self, 100)
            :hide()
    end
    self.input1_:setMaxLength(0)
    self.input1_:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.input1_:setInputFlag(cc.EDITBOX_INPUT_FLAG_SENSITIVE)
    self.input1_:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self.input1_:setPlaceHolder("")
    self.input1_:setText("")
    self.input2_:setMaxLength(0)
    self.input2_:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.input2_:setInputFlag(cc.EDITBOX_INPUT_FLAG_SENSITIVE)
    self.input2_:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self.input2_:setPlaceHolder("")
    self.input2_:setText("")

    local selectedPayType = self:getSelectedPayType()
    self.controller_:prepareEditBox(selectedPayType, self.input1_, self.input2_, self.submitBtn_)
    local inputHeight = 0
    if selectedPayType.inputType == "singleLine" then
        inputHeight = 80
        self.input1_:pos(StorePanelParam.WIDTH * 0.5 - PW + (PW - 210) * 0.5, StorePanelParam.HEIGHT * -0.5 + PH - 10)
        self.submitBtn_:setButtonSize(176, 48):pos(StorePanelParam.WIDTH * 0.5 - 110, StorePanelParam.HEIGHT * -0.5 + PH - 12)
        self.input1_:show()
        self.input2_:hide()
        self.submitBtn_:show()
    elseif selectedPayType.inputType == "twoLine" then
        inputHeight = 120
        self.input1_:pos(StorePanelParam.WIDTH * 0.5 - PW + (PW - 210) * 0.5, StorePanelParam.HEIGHT * -0.5 + PH)
        self.input2_:pos(StorePanelParam.WIDTH * 0.5 - PW + (PW - 210) * 0.5, StorePanelParam.HEIGHT * -0.5 + PH - 50)
        self.submitBtn_:setButtonSize(176, 100):pos(StorePanelParam.WIDTH * 0.5 - 110, StorePanelParam.HEIGHT * -0.5 + PH - 26)
        self.input1_:show()
        self.input2_:show()
        self.submitBtn_:show()
    elseif selectedPayType.inputType == "noLine" then
        inputHeight = 80
        self.submitBtn_:setButtonSize(176, 48):pos(StorePanelParam.WIDTH * 0.5 - 110, StorePanelParam.HEIGHT * -0.5 + PH - 12)
        self.input1_:hide()
        self.input2_:hide()
        self.submitBtn_:show()
    else
        self.input1_:hide()
        self.input2_:hide()
        self.submitBtn_:hide()
    end

    if self.chipList_ then
        self.chipList_:setViewRect(cc.rect(-0.5 * (PW - 4), -0.5 * (PH - inputHeight - 4), (PW - 4), (PH - inputHeight - 4)))
        self.chipList_:pos(StorePanelParam.WIDTH * 0.5 - PW * 0.5 - 16, StorePanelParam.HEIGHT * -0.5 + PH * 0.5 + 32 - inputHeight * 0.5)
    end

    if self.propList_ then
        self.propList_:setViewRect(cc.rect(-0.5 * (PW - 4), -0.5 * (PH - inputHeight - 4), (PW - 4), (PH - inputHeight - 4)))
        self.propList_:pos(StorePanelParam.WIDTH * 0.5 - PW * 0.5 - 16, StorePanelParam.HEIGHT * -0.5 + PH * 0.5 + 32 - inputHeight * 0.5)
    end

    if self.ticketList_ then
        self.ticketList_:setViewRect(cc.rect(-0.5 * (PW - 4), -0.5 * (PH - inputHeight - 4), (PW - 4), (PH - inputHeight - 4)))
        self.ticketList_:pos(StorePanelParam.WIDTH * 0.5 - PW * 0.5 - 16, StorePanelParam.HEIGHT * -0.5 + PH * 0.5 + 32 - inputHeight * 0.5)
    end

    if self.cashPayList_ then
        --todo
        self.cashPayList_:setViewRect(cc.rect(-0.5 * (PW - 4), -0.5 * (PH - inputHeight - 4), (PW - 4), (PH - inputHeight - 4)))
        self.cashPayList_:pos(StorePanelParam.WIDTH * 0.5 - PW * 0.5 - 16, StorePanelParam.HEIGHT * -0.5 + PH * 0.5 + 32 - inputHeight * 0.5)
    end
end

function StorePopup:onSubmitClicked_()
    self.controller_:onInputCardInfo(self:getSelectedPayType(), self.selectedProductType_, self.input1_, self.input2_, self.submitBtn_)
end

function StorePopup:setPropList(paytype, isComplete, data)
    self:showInputIfNeeded_("props")
    if paytype.id == self:getSelectedPayType().id then
        if not self.pages_[3] then return end
        if isComplete then
            self.propListJuhua_:hide()
            if type(data) == "string" then
                self.propListMsg_:setString(data)
                self.propListMsg_:show()
                self.propList_:setData(nil)
            else
                self.propListMsg_:hide()
                self.propList_:setData(data)
                self:updateTouchRect_()
            end
        else
            self.propList_:setData(nil)
            self.propListMsg_:hide()
            self.propListJuhua_:show()
        end
    end
end

function StorePopup:setHistoryList(isComplete, data)
    print("setHistoryList", isComplete, data)
    -- if not self.pages_[3] then return end
    if not self.pages_[3] then return end
    if isComplete then
        self.historyListJuhua_:hide()
        if type(data) == "string" then
            self.historyListMsg_:setString(data)
            self.historyListMsg_:show()
            self.historyList_:setData(nil)
        else
            self.historyListMsg_:hide()
            self.historyList_:setData(data)
            self:updateTouchRect_()
        end
    else
        self.historyList_:setData(nil)
        self.historyListMsg_:hide()
        self.historyListJuhua_:show()
    end
end

function StorePopup:createChipPage_()
    local page = display.newNode()
    local pageX, pageY = StorePanelParam.WIDTH * 0.5 - PW * 0.5 - 16, StorePanelParam.HEIGHT * -0.5 + PH * 0.5 + 32
    display.newScale9Sprite("#store_page_background.png", pageX, pageY, cc.size(PW, PH)):addTo(page)
    self.chipList_ = bm.ui.ListView.new({
            viewRect = cc.rect(-0.5 * (PW - 4), -0.5 * (PH - 4), (PW - 4), (PH - 4)),
            direction=bm.ui.ListView.DIRECTION_VERTICAL
        }, ProductChipListItem)
        :pos(pageX, pageY)
        :addTo(page)
    self.chipList_:addEventListener("ITEM_EVENT", handler(self, self.onItemEvent_))
    self.chipListJuhua_ = nk.ui.Juhua.new():addTo(page):pos(pageX, pageY):hide()
    self.chipListMsg_ = display.newTTFLabel({text = "", color = cc.c3b(255, 255, 255), size = 24, align = ui.TEXT_ALIGN_CENTER})
        :pos(pageX, pageY)
        :addTo(page)
        :hide()
    return page
end

--比赛门票
function StorePopup:createTicketPage_()
    local page = display.newNode()
    local pageX, pageY = StorePanelParam.WIDTH * 0.5 - PW * 0.5 - 16, StorePanelParam.HEIGHT * -0.5 + PH * 0.5 + 32
    display.newScale9Sprite("#store_page_background.png", pageX, pageY, cc.size(PW, PH)):addTo(page)
    self.ticketList_ = bm.ui.ListView.new({
            viewRect = cc.rect(-0.5 * (PW - 4), -0.5 * (PH - 4), (PW - 4), (PH - 4)),
            direction=bm.ui.ListView.DIRECTION_VERTICAL
        }, ProductTicketListItem)
        :pos(pageX, pageY)
        :addTo(page)
    self.ticketList_:addEventListener("ITEM_EVENT", handler(self, self.onItemEvent_))
    self.ticketListJuhua_ = nk.ui.Juhua.new():addTo(page):pos(pageX, pageY):hide()
    self.ticketListMsg_ = display.newTTFLabel({text = "", color = cc.c3b(255, 255, 255), size = 24, align = ui.TEXT_ALIGN_CENTER})
        :pos(pageX, pageY)
        :addTo(page)
        :hide()
    return page
end

-- Abandoned By Req change! --
function StorePopup:createPagePropProductList(pageIndex)
    -- body
    local createPagePropProductListByPropType = {
        [1] = function()  -- giftPageList
            -- body
            local giftPageNode = display.newNode()

            local subTabBarBlockParam = {
                width = 568,
                height = 48,
                offsetX = -4,
                offsetY = -4
            }

            local propGiftListWidth = 580
            local propGiftListViewMagrinRight = 36

            local propGiftSubTabBarPaddingTop = 95

            local noGiftOnSellLabelPosShift = {
                x = 120,
                y = 30
            }

            local noGiftTipLabelFrontSize = 24
            self.noGiftLabel = display.newTTFLabel({text = bm.LangUtil.getText("STORE", "NO_PRODUCT_HINT"), size = noGiftTipLabelFrontSize, align = ui.TEXT_ALIGN_CENTER})
                :pos(noGiftOnSellLabelPosShift.x, noGiftOnSellLabelPosShift.y)
                :addTo(giftPageNode)
                :hide()
            local subTabBarFrontParam = {
                sizes = {
                    nor = 22,
                    sel = 22
                },

                colors = {
                    nor = cc.c3b(85, 110, 141),
                    sel = cc.c3b(230, 109, 12)
                }
            }

            self.subTabBarShopGift_ = nk.ui.TabBarWithIndicator.new({
                background = "#popup_sub_tab_bar_bg.png", 
                indicator = "#popup_sub_tab_bar_indicator.png"}, 
                bm.LangUtil.getText("GIFT", "SUB_TAB_TEXT_SHOP_GIFT"), 
                {selectedText = {color = subTabBarFrontParam.colors.sel, size = subTabBarFrontParam.sizes.sel}, 
                defaltText = {color = subTabBarFrontParam.colors.nor, size = subTabBarFrontParam.sizes.nor}}, true, 
            true)
            self.subTabBarShopGift_:addTo(giftPageNode)
            
            self.subTabBarShopGift_:setTabBarSize(subTabBarBlockParam.width, subTabBarBlockParam.height, subTabBarBlockParam.offsetX, subTabBarBlockParam.offsetY)
            self.subTabBarShopGift_:pos(StorePanelParam.WIDTH / 2 - propGiftListViewMagrinRight - propGiftListWidth / 2,
                StorePanelParam.HEIGHT / 2 - propGiftSubTabBarPaddingTop - subTabBarBlockParam.height / 2)
            self.subTabBarShopGift_:gotoTab(1, true)
            self.subTabBarShopGift_:onTabChange(handler(self, self.onSubTabGiftShopChanged_))
            
            self:loadPropGoodsList(1)

            local loadingAnimPosShift = {
                x = 120,
                y = 30
            }

            self.propLoading_ = nk.ui.Juhua.new():addTo(giftPageNode):pos(loadingAnimPosShift.x, - loadingAnimPosShift.y)

            local giftData = self.controller_:getGiftGroupByIdx(1)
            -- dump(giftData, "giftData:================")

            if #giftData == 0 then
                --todo
                self.noGiftLabel:show()

            else
                local propGiftListViewParam = {
                    width = 570,
                    height = 295
                }

                local contentNode = display.newNode()

                local giftProdComponMagrinEachLine = 5
                local lineComponHeight = 108
                local itemsInOneLine = 4

                local lineComponNum = math.ceil(#giftData / 4)
                local lineComponItemDataList = {}
                for i = 1, lineComponNum do
                    lineComponItemDataList[i] = {}
                    for j = 1, itemsInOneLine do
                        if giftData[(i - 1) * itemsInOneLine + j] then
                            --todo
                            local componItem = {}
                            componItem.idx_ = (i - 1) * itemsInOneLine + j
                            componItem.data_ = giftData[(i - 1) * itemsInOneLine + j]
                            table.insert(lineComponItemDataList[i], componItem)
                        end
                    end
                end
                -- dump(lineComponItemDataList, "lineComponItemDataList:============")

                local sumLineComponHeight = lineComponHeight * lineComponNum + giftProdComponMagrinEachLine * (lineComponNum - 1)

                for i = 1, lineComponNum do
                    local giftProductLineCompon = GiftProdLineCompon.new(lineComponItemDataList[i])
                        :pos(- propGiftListViewParam.width / 2, sumLineComponHeight / 2 - lineComponHeight * i - giftProdComponMagrinEachLine * (i - 1))  -- 描点有点奇怪！
                        :addTo(contentNode)
                end

                local propProdListPosAdjust = {
                    x = 5,
                    y = 25
                }

                self.propLoading_:removeFromParent()
                self.propLoading_ = nil

                self.giftProductList_ = bm.ui.ScrollView.new({viewRect = cc.rect(- propGiftListViewParam.width / 2, - propGiftListViewParam.height / 2,
                    propGiftListViewParam.width, propGiftListViewParam.height), direction = bm.ui.ScrollView.DIRECTION_VERTICAL, scrollContent = contentNode})
                    :pos(StorePanelParam.WIDTH / 2 - propGiftListViewMagrinRight - propGiftListViewParam.width / 2 + propProdListPosAdjust.x, - propProdListPosAdjust.y)
                    :addTo(giftPageNode)

                self.giftSelectedId_ = tonumber(giftData[1].pnid)
            end

            return giftPageNode
        end,

        [2] = function()  -- propPageList
            -- body
            local propPageNode = display.newNode()

            local propProdListMagrinRight = 36
            local propProdTabPaddingTop = 166

            local propHddjListViewSize = {
                width = 590,
                height = 355
            }

            local propProdListViewPosShift = {
                x = 25,
                y = 0
            }

            self.propProductList_ = bm.ui.ListView.new({viewRect = cc.rect(- propHddjListViewSize.width / 2, - propHddjListViewSize.height / 2,
                propHddjListViewSize.width, propHddjListViewSize.height), direction = bm.ui.ListView.DIRECTION_VERTICAL}, PropProdListItem)
                :pos(StorePanelParam.WIDTH / 2 - propHddjListViewSize.width / 2 - propProdListViewPosShift.x, - propProdListViewPosShift.y)
                :addTo(propPageNode)

            local noPropOnSellLabelPosShift = {
                x = 120,
                y = 30
            }

            local noPropsLabelSize = 24
            self.noPropOnSellLabel = display.newTTFLabel({text = bm.LangUtil.getText("STORE", "NO_PRODUCT_HINT"), size = noPropsLabelSize, align = ui.TEXT_ALIGN_CENTER})
                :pos(noPropOnSellLabelPosShift.x, noPropOnSellLabelPosShift.y)
                :addTo(propPageNode)
                :hide()
            --拉取数据，等待数据到达setData
            self:loadPropGoodsList(2)

            local loadingAnimPosShift = {
                x = 120,
                y = 30
            }

            self.propLoading_ = nk.ui.Juhua.new():addTo(propPageNode):pos(loadingAnimPosShift.x, - loadingAnimPosShift.y)
            -- self.propProductList_:setData({1, 2, 3, 4})

            return propPageNode
        end
    }

    return createPagePropProductListByPropType[pageIndex]()
end


function StorePopup:createPropPage_()
    -- body
end

-- Override By Req Changed! --
function StorePopup:createCashPage_()
    local page = display.newNode()

    local pageX, pageY = StorePanelParam.WIDTH * 0.5 - PW * 0.5 - 16, StorePanelParam.HEIGHT * -0.5 + PH * 0.5 + 32
    display.newScale9Sprite("#store_page_background.png", pageX, pageY, cc.size(PW, PH)):addTo(page)
    self.cashPayList_ = bm.ui.ListView.new({
            viewRect = cc.rect(-0.5 * (PW - 4), -0.5 * (PH - 4), (PW - 4), (PH - 4)),
            direction=bm.ui.ListView.DIRECTION_VERTICAL
        }, ProductCashListItem)
        :pos(pageX, pageY)
        :addTo(page)

    self.cashPayList_:addEventListener("ITEM_EVENT", handler(self, self.onItemEvent_))
    self.cashPayListJuhua_ = nk.ui.Juhua.new():addTo(page):pos(pageX, pageY):hide()

    self.cashPayListMsg_ = display.newTTFLabel({text = "", color = cc.c3b(255, 255, 255), size = 24, align = ui.TEXT_ALIGN_CENTER})
        :pos(pageX, pageY)
        :addTo(page)
        :hide()

    -- -- Create SubTabs --
    -- local pagePanelSize = {
    --     width = 840,
    --     height = 435
    -- }

    -- local pageBackGroudPosYShift = 30
    -- display.newScale9Sprite("#store_bgPageProp.png", 0, - pageBackGroudPosYShift, cc.size(pagePanelSize.width, pagePanelSize.height))
    --     :addTo(page)

    -- local subTabIndexAreaSize = {
    --     width = 222,
    --     height = 435
    -- }

    -- local subTabIdxBgPosXShift = 0
    -- display.newScale9Sprite("#store_bgSubTabProp.png", - pagePanelSize.width / 2 + subTabIndexAreaSize.width / 2 + subTabIdxBgPosXShift,
    --     - pageBackGroudPosYShift, cc.size(subTabIndexAreaSize.width, subTabIndexAreaSize.height))
    --     :addTo(page)

    -- local contentNode = display.newNode()

    -- self.propShopSubTabBtnGruop_ = nk.ui.CheckBoxButtonGroup.new()

    -- self.propSubBtnGroup = {}

    -- local subBtnWidthFix = 10
    -- local subTabBtnSize = {
    --     width = subTabIndexAreaSize.width - subBtnWidthFix,
    --     height = 58
    -- }
    -- local propSubBtnImg = {
    --     {nor = "#store_subTabFir_nor.png", sel = "#store_subTabFir_sel.png"},
    --     {nor = "#store_subTabCom_nor.png", sel = "#store_subTabCom_sel.png"}
    -- }

    -- local propSubBtnLabelStr = {
    --     bm.LangUtil.getText("STORE", "TITLE_GIFT"),
    --     bm.LangUtil.getText("STORE", "TITLE_PROP")
    -- }
    
    -- local propSubBtnLabelFrontParam = {
    --     color = cc.c3b(85, 110, 141),
    --     size = 24
    -- }

    -- local btnSelIndexArrowPosXShift = 8
    -- local propTabBtnPosYShift = 52
    -- for i = 1, #propSubBtnLabelStr do
    --     local btnPosXShift = i >= 2 and - 11 or - 11
    --     local btnPosYShift = i >= 2 and 0.5 or 0
    --     self.propSubBtnGroup[i] = cc.ui.UICheckBoxButton.new({on = propSubBtnImg[i].sel, off = propSubBtnImg[i].nor}, {scale9 = true})
    --         :setButtonSize(subTabBtnSize.width, subTabBtnSize.height)
    --         -- :setButtonLabel(display.newTTFLabel({text = propSubBtnLabelParam[i].text, size = propSubBtnLabelParam[i].size,
    --         --     color = propSubBtnLabelParam[i].color.nor, align = ui.TEXT_ALIGN_LEFT}))
    --         :pos(btnPosXShift, subTabIndexAreaSize.height / 4 - propTabBtnPosYShift - subTabBtnSize.height / 2 * (2 * i - 1) - btnPosYShift)  -- 这里的，描点有点奇怪。
    --         :addTo(contentNode)

    --     self.propSubBtnGroup[i].label_ = display.newTTFLabel({text = propSubBtnLabelStr[i], size = propSubBtnLabelFrontParam.size,
    --         color = propSubBtnLabelFrontParam.color, align = ui.TEXT_ALIGN_CENTER})
    --         :addTo(self.propSubBtnGroup[i])

    --     self.propSubBtnGroup[i].selBgImg_ = display.newSprite("#store_propSubTabBtn_sel.png")
    --         :addTo(self.propSubBtnGroup[i])
    --         :hide()

    --     self.propSubBtnGroup[i].selIndexArrow_ = display.newSprite("#store_subTabSelArrow_right.png")
    --         :pos(subTabBtnSize.width / 2 + btnSelIndexArrowPosXShift, 0)
    --         :addTo(self.propSubBtnGroup[i])
    --         :hide()

    --     self.propSubBtnGroup[i]:setTouchSwallowEnabled(false)
    --     self.propShopSubTabBtnGruop_:addButton(self.propSubBtnGroup[i])
    -- end

    -- self.propShopSubTabBtnGruop_:onButtonSelectChanged(handler(self, self.onPropSubTabChanged_))

    -- local subTabRectSizeWShift = - 25
    -- local subTabSelListPosShift = {
    --     x = 5,
    --     y = 28
    -- }

    -- local subTabSelViewRectSize = {
    --     width = subTabIndexAreaSize.width - subTabRectSizeWShift,
    --     height = subTabIndexAreaSize.height
    -- }
    -- self.propStoreSubTabSelList_ = bm.ui.ScrollView.new({viewRect = cc.rect(- subTabSelViewRectSize.width / 2, - subTabSelViewRectSize.height / 2,
    --     subTabSelViewRectSize.width, subTabSelViewRectSize.height), direction = bm.ui.ScrollView.DIRECTION_VERTICAL, scrollContent = contentNode})
    --     :pos(- pagePanelSize.width / 2 + subTabSelViewRectSize.width / 2 - subTabSelListPosShift.x, - pagePanelSize.height / 2 + subTabSelViewRectSize.height / 2 - subTabSelListPosShift.y)
    --     :addTo(page)

    -- local blockBottomSize = {
    --     width = 624,
    --     height = 64
    -- }

    -- local blockBottomPosShift = {
    --     x = 8,
    --     y = 30
    -- }
    -- local blockBottom = display.newScale9Sprite("#store_bgBottomBlock.png", subTabIndexAreaSize.width + blockBottomSize.width / 2 - pagePanelSize.width / 2 - blockBottomPosShift.x,
    --     - pagePanelSize.height / 2 + blockBottomSize.height / 2 - blockBottomPosShift.y, cc.size(blockBottomSize.width, blockBottomSize.height))
    --     :addTo(page)

    -- local btnBuyBottomSize = {
    --     width = 180,
    --     height = 48
    -- }

    -- local buyBtnLabelFrontSize = 22

    -- self.buyOneBtn_ = cc.ui.UIPushButton.new({normal = "#common_green_btn_up.png", pressed = "#common_green_btn_down.png",
    --     disabled = "#common_btn_disabled.png"}, {scale9 = true})
    --     :setButtonSize(btnBuyBottomSize.width, btnBuyBottomSize.height)
    --     :setButtonLabel("normal", display.newTTFLabel({text = bm.LangUtil.getText("STORE", "BUY"), size = buyBtnLabelFrontSize, align = ui.TEXT_ALIGN_CENTER}))
    --     :onButtonClicked(buttontHandler(self, self.onPropBuyBtnCallBack_))
    --     :pos(blockBottomSize.width / 2, blockBottomSize.height / 2)
    --     :addTo(blockBottom)

    -- local buyBtnShownBetween = 410
    -- self.buyToTableBtn_ = cc.ui.UIPushButton.new({normal = "#common_dark_blue_btn_up.png", pressed = "#common_dark_blue_btn_down.png",
    --     disabled = "#common_btn_disabled.png"}, {scale9 = true})
    --     :setButtonSize(btnBuyBottomSize.width, btnBuyBottomSize.height)
    --     :setButtonLabel("normal", display.newTTFLabel({text = bm.LangUtil.getText("GIFT","BUY_TO_TABLE_GIFT_BUTTON_LABEL", self.tableUserNum_ or 0), size = buyBtnLabelFrontSize, align = ui.TEXT_ALIGN_CENTER}))
    --     :onButtonClicked(buttontHandler(self, self.onBuyGiftToAllTableCallBack_))
    --     :pos(blockBottomSize.width / 2 - buyBtnShownBetween / 2, blockBottomSize.height / 2)
    --     :addTo(blockBottom)
    --     :hide()

    -- if self.toUid_ ~= nk.userData.uid then
    --     --todo
    --     self.buyOneBtn_:getButtonLabel("normal"):setString(bm.LangUtil.getText("GIFT", "PRESENT_GIFT_BUTTON_LABEL"))
    -- end

    -- if self.defaultPropSubIndex_ == 1 and self.isInRoom_ then
    --     --todo
    --     self.buyOneBtn_:pos(blockBottomSize.width / 2 + buyBtnShownBetween / 2, blockBottomSize.height / 2)
    --     self.buyToTableBtn_:show()
    -- end
    

    -- -- page.giftPage_ = self:createPagePropProductList(1):addTo(page):hide()
    -- -- page.propPage_ = self:createPagePropProductList(2):addTo(page):hide()

    -- self.propShopSubTabBtnGruop_:getButtonAtIndex(self.defaultPropSubIndex_):setButtonSelected(true)

    -- page.propContPage = {}
    -- for i = 1, 2 do
    --     page.propContPage[i] = self:createPagePropProductList(i):addTo(page):hide()
    -- end

    -- page.propContPage[self.defaultPropSubIndex_]:show()

    return page
end

function StorePopup:createHistoryPage_()
    local page = display.newNode()
    --display.newScale9Sprite("#store_page_background.png", StorePanelParam.WIDTH * 0.5 - (860 - 16 * 2) * 0.5 - 16, StorePanelParam.HEIGHT * -0.5 + PH * 0.5 + 32, cc.size(860 - 16 * 2, PH)):addTo(page)
    display.newScale9Sprite("#pop_up_split_line.png", 0, StorePanelParam.HEIGHT * -0.5 + PH + 32, cc.size(860 - 16 * 2, 2))
        :addTo(page)
    self.historyList_ = bm.ui.ListView.new({
            viewRect = cc.rect(-0.5 * (860 - 16 * 2 - 4), -0.5 * (PH - 4), (860 - 16 * 2 - 4), (PH - 4)),
            direction=bm.ui.ListView.DIRECTION_VERTICAL
        }, HistoryListItem)
        :pos(0, StorePanelParam.HEIGHT * -0.5 + PH * 0.5 + 32)
        :addTo(page)
    self.historyListJuhua_ = nk.ui.Juhua.new():addTo(page):pos(0, StorePanelParam.HEIGHT * -0.5 + PH * 0.5 + 32):hide()
    self.historyListMsg_ = display.newTTFLabel({text = "", color = cc.c3b(255, 255, 255), size = 24, align = ui.TEXT_ALIGN_CENTER})
        :pos(0, StorePanelParam.HEIGHT * -0.5 + PH * 0.5 + 32)
        :addTo(page)
        :hide()
    return page
end

-- Abandoned By Req change! --
function StorePopup:storeGiftSelectChanged_(evt)
    -- body
    if evt.data ~= self.giftSelectedId_ then
        --todo

        self.giftSelectedId_ = evt.data
    end

end

-- Abandoned By Req change! --
function StorePopup:storePropSelectChanged_(evt)
    -- body
    if evt.data ~= self.propInfoSelectedId_ then
        --todo
        self.propInfoSelectedId_ = evt.data
    end
end

function StorePopup:onItemEvent_(evt)
    if evt.type == "GOTO_TAB" then
        self:gotoTab(evt.tab or 1)
    elseif evt.type == "MAKE_PURCHASE" then
        self.controller_:makePurchase(self:getSelectedPayType(), evt.pid, evt.goodData)
    end
end



function StorePopup:checkShowCheckoutGuide()
    local needshow = false
    local first = nk.userDefault:getIntegerForKey("CheckoutGuideFirst", 0)
    local today = os.date('%Y%m%d')
    if first == 0 then
        needshow = true
        nk.userDefault:setIntegerForKey("CheckoutGuideFirst", os.time())
    else
        local isPay = nk.userData.best and nk.userData.best.paylog == 1 or false

        if not isPay then
            local lastshow = nk.userDefault:getStringForKey("CheckoutGuideLast", "")
            if os.time() - tonumber(first) < 86400 * 3 then
                needshow = true
            else
                if lastshow == today then
                    needshow = false
                else
                    needshow = true
                end
            end
            nk.userDefault:setStringForKey("CheckoutGuideLast", today)
        else
            needshow = false
        end
    end
    nk.userDefault:flush()
    if needshow then
        CheckoutGuidePopup.new():show()
    end

end

return StorePopup
