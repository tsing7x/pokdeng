--
-- Author: TsingZhang@boyaa.com
-- Date: 2016-03-14 15:14:54
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- Description: GiftStorePopup.lua By Tsing.
--

local GiftProdLineCompon = import(".views.GiftProdLineCompon")
local PropProdListItem = import(".views.PropProdListItem")

local TextureHandler = import(".TextureHandler")
local StorePopupController = import(".StorePopupController")

local GiftStorePopup = class("GiftStorePopup", nk.ui.Panel)

local GiftStorePanelParam = {
	WIDTH = 865,
	HEIGHT = 545
}

function GiftStorePopup:ctor(defaultTab)
	-- body
	GiftStorePopup.super.ctor(self, {GiftStorePanelParam.WIDTH, GiftStorePanelParam.HEIGHT})

	TextureHandler.loadTexture(2)
	self.defualtTabIdx_ = defaultTab or 1
	self.controller_ = StorePopupController.new(self)
	self:setNodeEventEnabled(true)

	self:renderTitleBlock()
	self:renderMainBlock()
end

function GiftStorePopup:renderTitleBlock()
	-- body
	local titleBlockWidthFixEachSide = 0
	local titleBlockSize = {
		width = GiftStorePanelParam.WIDTH - titleBlockWidthFixEachSide * 2,
		height = 55
	}

	local titleBlockBgPosShift = 0
	local titleBlockBg = display.newScale9Sprite("#gstore_titleBlock.png", 0, GiftStorePanelParam.HEIGHT / 2 - titleBlockSize.height / 2 - titleBlockBgPosShift,
		cc.size(titleBlockSize.width, titleBlockSize.height))
		:addTo(self)

	local titleLabelParam = {
		frontSize = 36,
		color = display.COLOR_WHITE
	}
	local titleLabel = display.newTTFLabel({text = bm.LangUtil.getText("STORE", "TITLE_PROP"), size = titleLabelParam.frontSize, color = titleLabelParam.color, align = ui.TEXT_ALIGN_CENTER})
		:pos(titleBlockSize.width / 2, titleBlockSize.height / 2)
		:addTo(titleBlockBg)

	local iconCirclePosXShift = 5
	local titleIconCirle = display.newSprite("#popup_tab_bar_icon_unselected.png")
	local titleIconCircleSize = titleIconCirle:getContentSize()

	titleIconCirle:pos(titleBlockSize.width / 2 - titleLabel:getContentSize().width / 2 - titleIconCircleSize.width / 2 - iconCirclePosXShift,
		titleBlockSize.height / 2)
		:addTo(titleBlockBg)

	local giftStoreIcon = display.newSprite("#gstore_tabIcon_prop_nor.png")
		:pos(titleIconCircleSize.width / 2, titleIconCircleSize.height / 2)
		:addTo(titleIconCirle)

	self:addCloseBtn()
end

function GiftStorePopup:renderMainBlock()
	-- body
	-- self.loadingBar_ = nk.ui.Juhua.new():addTo(self)

	local mainBlockBgSize = {
		width = 840,
		height = 455
	}

	local panelBgPosYShift = 30
	local panelBg = display.newScale9Sprite("#gstore_bgPageProp.png", 0, - panelBgPosYShift, cc.size(mainBlockBgSize.width, mainBlockBgSize.height))
		:addTo(self)

	local tabIndexAreaSize = {
		width = 222,
		height = 455
	}

	local tabIndexAreaPosXShift = 0
	local tabIndexBgPanel = display.newScale9Sprite("#gstore_bgSubTabProp.png", - mainBlockBgSize.width / 2 + tabIndexAreaSize.width / 2 + tabIndexAreaPosXShift,
		- panelBgPosYShift, cc.size(tabIndexAreaSize.width, tabIndexAreaSize.height))
		:addTo(self)

	local tabIndexContentNode = display.newNode()

	self.propStoreTabBtnGruop_ = nk.ui.CheckBoxButtonGroup.new()
	self.propTabBtnGroup = {}

	local tabBtnWidthFix = 10
	local propTabBtnSize = {
        width = tabIndexAreaSize.width - tabBtnWidthFix,
        height = 60
    }

    local propTabBtnImg = {
        {nor = "#gstore_subTabFir_nor.png", sel = "#gstore_subTabFir_sel.png"},
        {nor = "#gstore_subTabCom_nor.png", sel = "#gstore_subTabCom_sel.png"}
    }

    local propTabBtnLabelStr = {
        bm.LangUtil.getText("STORE", "TITLE_GIFT"),
        bm.LangUtil.getText("STORE", "TITLE_PROP")
    }

    local propTabBtnLabelParam = {
        color = cc.c3b(85, 110, 141),
        size = 24
    }

    local btnSelIndexArrowPosXShift = 8
    local propTabBtnPosYShift = 52

    for i = 1, #propTabBtnLabelStr do

        local btnPosXShift = i >= 2 and - 11 or - 12.5
        -- local btnPosXShift = - 12
        local btnPosYShift = i >= 2 and 2 or 2.5
        self.propTabBtnGroup[i] = cc.ui.UICheckBoxButton.new({on = propTabBtnImg[i].sel, off = propTabBtnImg[i].nor}, {scale9 = true})
            :setButtonSize(propTabBtnSize.width, propTabBtnSize.height)
            -- :setButtonLabel(display.newTTFLabel({text = propSubBtnLabelParam[i].text, size = propSubBtnLabelParam[i].size,
            --     color = propSubBtnLabelParam[i].color.nor, align = ui.TEXT_ALIGN_LEFT}))
            :pos(btnPosXShift, tabIndexAreaSize.height / 4 - propTabBtnPosYShift - propTabBtnSize.height / 2 * (2 * i - 1) - btnPosYShift)  -- 这里的，描点有点奇怪。
            :addTo(tabIndexContentNode)

        self.propTabBtnGroup[i].label_ = display.newTTFLabel({text = propTabBtnLabelStr[i], size = propTabBtnLabelParam.size,
            color = propTabBtnLabelParam.color, align = ui.TEXT_ALIGN_CENTER})
            :addTo(self.propTabBtnGroup[i])

        self.propTabBtnGroup[i].selBgImg_ = display.newSprite("#gstore_propSubTabBtn_sel.png")
            :addTo(self.propTabBtnGroup[i])
            :hide()

        self.propTabBtnGroup[i].selIndexArrow_ = display.newSprite("#gstore_subTabSelArrow_right.png")
            :pos(propTabBtnSize.width / 2 + btnSelIndexArrowPosXShift, 0)
            :addTo(self.propTabBtnGroup[i])
            :hide()

        self.propTabBtnGroup[i]:setTouchSwallowEnabled(false)
        self.propStoreTabBtnGruop_:addButton(self.propTabBtnGroup[i])
    end

    self.propStoreTabBtnGruop_:onButtonSelectChanged(handler(self, self.onPropTabSelChanged_))

    local tabRectSizeWShift = - 25
    local tabSelListPosShift = {
        x = 5,
        y = 28
    }

    local tabSelViewRectSize = {
        width = tabIndexAreaSize.width - tabRectSizeWShift,
        height = tabIndexAreaSize.height
    }

    self.propTabSelList_ = bm.ui.ScrollView.new({viewRect = cc.rect(- tabSelViewRectSize.width / 2, - tabSelViewRectSize.height / 2,
        tabSelViewRectSize.width, tabSelViewRectSize.height), direction = bm.ui.ScrollView.DIRECTION_VERTICAL, scrollContent = tabIndexContentNode})
        :pos(- mainBlockBgSize.width / 2 + tabSelViewRectSize.width / 2 - tabSelListPosShift.x,
        	- mainBlockBgSize.height / 2 + tabSelViewRectSize.height / 2 - tabSelListPosShift.y)
        :addTo(self)

    local blockBottomSize = {
        width = 624,
        height = 64
    }

    local blockBottomPosShift = {
        x = 8,
        y = 30
    }
    self.blockBottom_ = display.newScale9Sprite("#gstore_bgBottomBlock.png", tabIndexAreaSize.width + blockBottomSize.width / 2 - mainBlockBgSize.width / 2 - blockBottomPosShift.x,
        - mainBlockBgSize.height / 2 + blockBottomSize.height / 2 - blockBottomPosShift.y, cc.size(blockBottomSize.width, blockBottomSize.height))
        :addTo(self, 9)

    self.blockBottom_:setTouchEnabled(true)
    self.blockBottom_:setTouchSwallowEnabled(true)

    self.propStoreTabBtnGruop_:getButtonAtIndex(self.defualtTabIdx_):setButtonSelected(true)

    self.propPages = {}
    for i = 1, #propTabBtnLabelStr do
    	self.propPages[i] = self:createPagePropProductList(i):addTo(self):hide()
    end

    self.propPages[self.defualtTabIdx_]:show()
end

function GiftStorePopup:createPagePropProductList(pageIdx)
	-- body
	local createPagePropProductListByPropType = {
        [1] = function()  -- giftPageList
            -- body
            local giftPageNode = display.newNode()

            local subTabBarBlockParam = {
                width = 570,
                height = 50,
                offsetX = -4,
                offsetY = -4
            }

            local propGiftListWidth = 575
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

            self.subTabBarShopGift_:addTo(giftPageNode, 9)
            self.subTabBarShopGift_:setTouchEnabled(true)
            self.subTabBarShopGift_:setTouchSwallowEnabled(true)

            self.subTabBarShopGift_:setTabBarSize(subTabBarBlockParam.width, subTabBarBlockParam.height, subTabBarBlockParam.offsetX, subTabBarBlockParam.offsetY)
            self.subTabBarShopGift_:pos(GiftStorePanelParam.WIDTH / 2 - propGiftListViewMagrinRight - propGiftListWidth / 2,
                GiftStorePanelParam.HEIGHT / 2 - propGiftSubTabBarPaddingTop - subTabBarBlockParam.height / 2)
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

            if #giftData <= 0 then
                --todo
                self.noGiftLabel:show()

            else
                local propGiftListViewParam = {
                    width = 585,
                    height = 305
                }

                local contentNode = display.newNode()
                -- local container = display.newNode():addTo(contentNode)
                -- local colorLayer = display.newColorLayer(cc.c4b(255, 255, 255, 255)):addTo(contentNode)
                -- colorLayer:setContentSize(575, 400)

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
                    x = 0,
                    y = 30
                }

                self.propLoading_:removeFromParent()
                self.propLoading_ = nil

                self.giftProductList_ = bm.ui.ScrollView.new({viewRect = cc.rect(- propGiftListViewParam.width / 2, - propGiftListViewParam.height / 2,
                    propGiftListViewParam.width, propGiftListViewParam.height), direction = bm.ui.ScrollView.DIRECTION_VERTICAL, scrollContent = contentNode})
                    :pos(GiftStorePanelParam.WIDTH / 2 - propGiftListViewMagrinRight - propGiftListViewParam.width / 2 + propProdListPosAdjust.x, - propProdListPosAdjust.y)
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
                width = 595,
                height = 365
            }

            local propProdListViewPosShift = {
                x = 25,
                y = 0
            }

            self.propProductList_ = bm.ui.ListView.new({viewRect = cc.rect(- propHddjListViewSize.width / 2, - propHddjListViewSize.height / 2,
                propHddjListViewSize.width, propHddjListViewSize.height), direction = bm.ui.ListView.DIRECTION_VERTICAL}, PropProdListItem)
                :pos(GiftStorePanelParam.WIDTH / 2 - propHddjListViewSize.width / 2 - propProdListViewPosShift.x, - propProdListViewPosShift.y)
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
            -- self.propProductList_:update()
            return propPageNode
        end
    }

    return createPagePropProductListByPropType[pageIdx]()
end

function GiftStorePopup:onGetPropDataWrong(propType)
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
end

function GiftStorePopup:onPropListDataGet()
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
        -- self.propProductList_:update()
        self.propInfoSelectedId_ = PropListData[1].data_.id
    else
        self.noPropOnSellLabel:show()
    end
end

function GiftStorePopup:onPropTabSelChanged_(evt)
	-- body
	local labelColorByState = {
        nor = cc.c3b(85, 110, 141),
        sel = cc.c3b(230, 109, 12)
    }

    if not self.propTabSelectedIdx_ then
        --todo
        self.propTabSelectedIdx_ = evt.selected

        self.propTabBtnGroup[self.propTabSelectedIdx_].label_:setTextColor(labelColorByState.sel)
        self.propTabBtnGroup[self.propTabSelectedIdx_].selBgImg_:show()
        self.propTabBtnGroup[self.propTabSelectedIdx_].selIndexArrow_:show()

        -- self.pages_[2].propContPage[self._propSubTabSelectedIndex]:show()
        -- DoSomething when self.defaultPropSubIndex_ Page Loading
    end

    local isChanged = self.propTabSelectedIdx_ ~= evt.selected

    if isChanged then
        --todo
        -- 修改之前的选项为未选中状态
        self.propTabBtnGroup[self.propTabSelectedIdx_].label_:setTextColor(labelColorByState.nor)
        self.propTabBtnGroup[self.propTabSelectedIdx_].selBgImg_:hide()
        self.propTabBtnGroup[self.propTabSelectedIdx_].selIndexArrow_:hide()
        self.propPages[self.propTabSelectedIdx_]:hide()
        -- self.pages_[3].propContPage[self.propTabSelectedIdx_]:hide()
        -- 修改点击项为选中状态
        self.propTabBtnGroup[evt.selected].label_:setTextColor(labelColorByState.sel)
        self.propTabBtnGroup[evt.selected].selBgImg_:show()
        self.propTabBtnGroup[evt.selected].selIndexArrow_:show()
        self.propPages[evt.selected]:show()
        -- self.pages_[3].propContPage[evt.selected]:show()

        -- doSomeThing when self._propSubTabSelectedIndex to evt.selected

        if self.buyOneBtn_ and self.buyToTableBtn_ then
            --todo
            local blockBottomSize = {
                width = 624,
                height = 64
            }

            local buyBtnShownBetween = 410

            if evt.selected == 1 then
                --todo

                if self.isInRoom_ then
                    --todo
                    if self.toUid_ ~= nk.userData.uid then
                        --todo
                        self.buyOneBtn_:getButtonLabel("normal"):setString(bm.LangUtil.getText("GIFT", "PRESENT_GIFT_BUTTON_LABEL"))
                    else
                        self.buyOneBtn_:getButtonLabel("normal"):setString(bm.LangUtil.getText("STORE", "BUY"))
                    end
                    
                    self.buyOneBtn_:pos(blockBottomSize.width / 2 + buyBtnShownBetween / 2, blockBottomSize.height / 2)
                    self.buyToTableBtn_:show()
                else
                    self.buyOneBtn_:getButtonLabel("normal"):setString(bm.LangUtil.getText("STORE", "BUY"))
                    self.buyOneBtn_:pos(blockBottomSize.width / 2, blockBottomSize.height / 2)
                    self.buyToTableBtn_:hide()
                end
            else
                self.buyOneBtn_:getButtonLabel("normal"):setString(bm.LangUtil.getText("STORE", "BUY"))
                self.buyOneBtn_:pos(blockBottomSize.width / 2, blockBottomSize.height / 2)
                self.buyToTableBtn_:hide()
            end

        end

        self.propTabSelectedIdx_ = evt.selected
    end
end

function GiftStorePopup:onPropBuyBtnCallBack_()
	-- body
	if self.propTabSelectedIdx_ == 1 then
        --todo

        if self.isInRoom_ then
            --todo
            self.controller_:presentGiftToUid(self.giftSelectedId_, self.toUid_)
        else
            self.controller_:buyGiftRequest(self.giftSelectedId_)
        end
        
    end

    -- 购买道具 --
    if self.propTabSelectedIdx_ == 2 then
        --todo
        self.controller_:buyPropsById(self.propInfoSelectedId_)
    end
end

function GiftStorePopup:onBuyGiftToAllTableCallBack_()
	-- body
	self.controller_:presentGiftToTable(self.giftSelectedId_, self.toUidArr_, self.allTableId_)
end

function GiftStorePopup:onSubTabGiftShopChanged_(subTabIndx)
	-- body
	if self.giftProductList_ then
        --todo
        self.giftProductList_:removeFromParent()
        self.giftProductList_ = nil
    end

    local giftData = self.controller_:getGiftGroupByIdx(subTabIndx)

    -- dump(giftData, "giftData:================")

    if #giftData <= 0 then
        --todo
        self.noGiftLabel:show()

    else
        bm.EventCenter:removeEventListenersByEvent(nk.eventNames.STORE_GIFT_SELECT_CHANG)
        bm.EventCenter:addEventListener(nk.eventNames.STORE_GIFT_SELECT_CHANG, handler(self, self.storeGiftSelectChanged_))
        self.noGiftLabel:hide()

        local propGiftListViewParam = {
            width = 585,
            height = 305
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
            x = 0,
            y = 30
        }

        self.giftProductList_ = bm.ui.ScrollView.new({viewRect = cc.rect(- propGiftListViewParam.width / 2, - propGiftListViewParam.height / 2,
            propGiftListViewParam.width, propGiftListViewParam.height), direction = bm.ui.ScrollView.DIRECTION_VERTICAL, scrollContent = contentNode})
            :pos(GiftStorePanelParam.WIDTH / 2 - propGiftListViewMagrinRight - propGiftListViewParam.width / 2 + propProdListPosAdjust.x, - propProdListPosAdjust.y)
            :addTo(self.propPages[1])

        self.giftSelectedId_ = tonumber(giftData[1].pnid)
    end
end

function GiftStorePopup:loadPropGoodsList(pagePropType)
	-- body
	self.controller_:loadPropShopProductList(pagePropType)
end

function GiftStorePopup:storeGiftSelectChanged_(evt)
    -- body
    if evt.data ~= self.giftSelectedId_ then
        --todo

        self.giftSelectedId_ = evt.data
    end

end

function GiftStorePopup:storePropSelectChanged_(evt)
	-- body
	if evt.data ~= self.propInfoSelectedId_ then
        --todo
        self.propInfoSelectedId_ = evt.data
    end
end

function GiftStorePopup:showPanel(closeCallBack, roomInfo)
	-- body
	self.closeCallback_ = closeCallBack

	if roomInfo then
		--todo
		self.isInRoom_ = roomInfo.isInRoom
        self.toUid_ = roomInfo.toUid
        self.toUidArr_ = roomInfo.toUidArr
        self.tableUserNum_ = roomInfo.tableNum
        self.allTableId_ = roomInfo.allTabId
	end

	self:showPanel_(true, true, true, true)
end

function GiftStorePopup:onShowed()
	-- body
    local blockBottomSize = {
        width = 624,
        height = 64
    }

    local btnBuyBottomSize = {
        width = 180,
        height = 48
    }

    local buyBtnLabelFrontSize = 22

    self.buyOneBtn_ = cc.ui.UIPushButton.new({normal = "#common_green_btn_up.png", pressed = "#common_green_btn_down.png",
        disabled = "#common_btn_disabled.png"}, {scale9 = true})
        :setButtonSize(btnBuyBottomSize.width, btnBuyBottomSize.height)
        :setButtonLabel("normal", display.newTTFLabel({text = bm.LangUtil.getText("STORE", "BUY"), size = buyBtnLabelFrontSize, align = ui.TEXT_ALIGN_CENTER}))
        :onButtonClicked(buttontHandler(self, self.onPropBuyBtnCallBack_))
        :pos(blockBottomSize.width / 2, blockBottomSize.height / 2)
        :addTo(self.blockBottom_)

    local buyBtnShownBetween = 410
    self.buyToTableBtn_ = cc.ui.UIPushButton.new({normal = "#common_dark_blue_btn_up.png", pressed = "#common_dark_blue_btn_down.png",
        disabled = "#common_btn_disabled.png"}, {scale9 = true})
        :setButtonSize(btnBuyBottomSize.width, btnBuyBottomSize.height)
        :setButtonLabel("normal", display.newTTFLabel({text = bm.LangUtil.getText("GIFT","BUY_TO_TABLE_GIFT_BUTTON_LABEL", self.tableUserNum_ or 0), size = buyBtnLabelFrontSize, align = ui.TEXT_ALIGN_CENTER}))
        :onButtonClicked(buttontHandler(self, self.onBuyGiftToAllTableCallBack_))
        :pos(blockBottomSize.width / 2 - buyBtnShownBetween / 2, blockBottomSize.height / 2)
        :addTo(self.blockBottom_)
        :hide()

    if self.toUid_ ~= nk.userData.uid then
        --todo
        self.buyOneBtn_:getButtonLabel("normal"):setString(bm.LangUtil.getText("GIFT", "PRESENT_GIFT_BUTTON_LABEL"))
    end

    if self.defualtTabIdx_ == 1 and self.isInRoom_ then
        --todo
        self.buyOneBtn_:pos(blockBottomSize.width / 2 + buyBtnShownBetween / 2, blockBottomSize.height / 2)
        self.buyToTableBtn_:show()
    end

	if self.propTabSelList_ then
		--todo
		self.propTabSelList_:update()
	end

	if self.giftProductList_ then
		--todo
		self.giftProductList_:update()
	end

	if self.propProductList_ then
		--todo
		self.propProductList_:update()
        self.propProductList_:update()
	end
    
end

function GiftStorePopup:hidePanel()
	-- body
	self:hidePanel_()
end

function GiftStorePopup:onEnter()
	-- body
	if self.super.onEnter then
        self.super.onEnter(self)
    end

    bm.EventCenter:addEventListener(nk.eventNames.STORE_GIFT_SELECT_CHANG, handler(self, self.storeGiftSelectChanged_))
    bm.EventCenter:addEventListener(nk.eventNames.STORE_PROP_SELECT_CHANG, handler(self, self.storePropSelectChanged_))
end

function GiftStorePopup:onExit()
	-- body
	self.controller_:useBuyGiftRequest()
    if self.super.onExit then
        self.super.onExit(self)
    end

	if self.closeCallback_ then
        self.closeCallback_()
        self.closeCallback_ = nil
    end
	self.controller_:dispose()
    bm.EventCenter:removeEventListenersByEvent(nk.eventNames.STORE_GIFT_SELECT_CHANG)
    bm.EventCenter:removeEventListenersByEvent(nk.eventNames.STORE_PROP_SELECT_CHANG)
    TextureHandler.removeTexture(2)
end

function GiftStorePopup:onCleanup()
	-- body
end

return GiftStorePopup