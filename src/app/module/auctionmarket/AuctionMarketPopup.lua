-- Author: Vanfo
-- Date: 2016-01-8 14:20:00
local AuctionMarketHelpPopup = import(".AuctionMarketHelpPopup")

local AuctionCentreView = import(".AuctionCentreView")
local AuctionFixedPriceView = import(".AuctionFixedPriceView")
local AuctionMineView = import(".AuctionMineView")
local AuctionRecordView = import(".AuctionRecordView")

local LIST_NUM_IN_PAGE = 20


--test--
local AuctionMarketFilterBar = import(".AuctionMarketFilterBar")

--拍卖市场
local AuctionMarketPopupController = import(".AuctionMarketPopupController")
local AuctionMarketPopup = class("AuctionMarketPopup", function()
	-- body
	return display.newNode()
end)

local logger = bm.Logger.new("AuctionMarketPopup")

AuctionMarketPopup.WIDTH = 937
AuctionMarketPopup.HEIGHT = 619

AuctionMarketPopup.TabBar = 
{
	txtColor = {selected = "#fffeff",normal = "#ff467f"}
}

local MainBoardMarginLeft = 46
local MainBoardMarginRight = 100

function AuctionMarketPopup:ctor(defaultTabIndx)
	display.addSpriteFrames("auctionMarket_th.plist", "auctionMarket_th.png")

	self.width_, self.height_= AuctionMarketPopup.WIDTH, AuctionMarketPopup.HEIGHT
	self.background_ = display.newSprite("#aucMar_bgMain.png")
		:addTo(self)
	self:size(self.width_, self.height_)
	
	self.background_:setTouchEnabled(true)
	self.background_:setTouchSwallowEnabled(true)
	self:setNodeEventEnabled(true)
	self:addCloseBtn()

	self.defaultTabIndx_ = defaultTabIndx or 1
	self.controller_ = AuctionMarketPopupController.new(self)

	self.contPages_ = {}
	self:initViews()
	self.controller_:getAuctionInitInfo()

	self:addPropertyObservers()
end

function AuctionMarketPopup:addCloseBtn()
    if not self.closeBtn_ then
        self.closeBtn_ = cc.ui.UIPushButton.new({normal = "#message_item_delete_btn_up.png", pressed = "#message_item_delete_btn_down.png"})
            :pos(self.width_ * 0.5 - 22, self.height_ * 0.5 - 25)
            :onButtonClicked(function() 
                    self:onClose()
                    nk.SoundManager:playSound(nk.SoundManager.CLOSE_BUTTON)
                end)
            :addTo(self, 99)
    end
end

function AuctionMarketPopup:showPanel_(isModal, isCentered, closeWhenTouchModel, useShowAnimation)
    nk.PopupManager:addPopup(self, isModal ~= false, isCentered ~= false, closeWhenTouchModel ~= false, useShowAnimation ~= false)
    return self
end

function AuctionMarketPopup:hidePanel_()
    nk.PopupManager:removePopup(self)
    return self
end

function AuctionMarketPopup:onClose()
    self:hidePanel_()
end



function AuctionMarketPopup:addPropertyObservers()
	self.chipObserverHandle_ = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "aUser.money", handler(self, function (obj, money)
        if obj and obj.chipLabel_ then
            obj.chipLabel_:setString(bm.formatNumberWithSplit(money))
        end
        
    end))

    self.cashObserverHandle_ = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "match.point", handler(self, function (obj, point)
        if obj and obj.crashCoinLabel_ then
            obj.crashCoinLabel_:setString(bm.formatNumberWithSplit(point))
        end
        
    end))

end


function AuctionMarketPopup:removePropertyObservers()
	bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "aUser.money", self.chipObserverHandle_)
	bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "match.point", self.cashObserverHandle_)
end

-- data PHP返回数据  params：请求发送的数据
function AuctionMarketPopup:onGetAuctionCenterDataSucc_(data,params)
	-- local params = {}
	-- params.atype = atype
	-- params.curPage = curPage 
	-- params.pageNum = sortkey 
	-- params.order = order 

	if data and data.point then
		if nk.userData.match then
			nk.userData.match.point = data.point
		end
		
		nk.userData["match.point"] = data.point
	end

	if data and data.money then
		nk.userData["aUser.money"] = data.money
		
	end


	if self.currentView_ and self.currentView_["onGetAuctionCenterDataSucc_"] then
		self.currentView_:onGetAuctionCenterDataSucc_(data,params)
	end

	-- 根据请求类型，更新视图
	local atype = params.atype
	if 1 == atype then

	elseif 2 == atype then


	elseif 3 == atype then


	elseif 4 == atype then


	end
end


function AuctionMarketPopup:onAddAuctSellProdSucc_(data)
	if data and data.point then
		if nk.userData.match then
			nk.userData.match.point = data.point
		end
		
		nk.userData["match.point"] = data.point
	end

	if data and data.money then
		nk.userData["aUser.money"] = data.money
	end


	if self.currentView_ and self.currentView_["onAddAuctSellProdSucc_"] then
		self.currentView_:onAddAuctSellProdSucc_(data)
	end
end


function AuctionMarketPopup:onAuctProdByAttrSucc_(data)

	if data and data.point then
		if nk.userData.match then
			nk.userData.match.point = data.point
		end
		nk.userData["match.point"] = data.point

	end

	if data and data.money then
		nk.userData["aUser.money"] = data.money

	end

	if self.currentView_ and self.currentView_["onAuctProdByAttrSucc_"] then
		self.currentView_:onAuctProdByAttrSucc_(data)
	end
end

function AuctionMarketPopup:onAuctProdByAttrFail_(errData)
	if self.currentView_ and self.currentView_["onAuctProdByAttrFail_"] then
		self.currentView_:onAuctProdByAttrFail_(errData)
	end
end



function AuctionMarketPopup:onGetAuctionFixedPriceDataSucc_(data,params)

	if data and data.point then
		if nk.userData.match then
			nk.userData.match.point = data.point
		end
		
		nk.userData["match.point"] = data.point
	
	end

	if data and data.money then
		nk.userData["aUser.money"] = data.money

	end

	if self.currentView_ and self.currentView_["onGetAuctionFixedPriceDataSucc_"] then
		self.currentView_:onGetAuctionFixedPriceDataSucc_(data,params)
	end
end


function AuctionMarketPopup:onGetMyAuctionDataSucc_(data)

	if data and data.point then
		if nk.userData.match then
			nk.userData.match.point = data.point
		end
		
		nk.userData["match.point"] = data.point

	end

	if data and data.money then
		nk.userData["aUser.money"] = data.money
		
	end

	if self.currentView_ and self.currentView_["onGetMyAuctionDataSucc_"] then
		self.currentView_:onGetMyAuctionDataSucc_(data,params)
	end
end




function AuctionMarketPopup:onAddMyAuctionDataSucc_(data)
	if self.currentView_ and self.currentView_["onAddMyAuctionDataSucc_"] then
		self.currentView_:onAddMyAuctionDataSucc_(data)
	end
end

function AuctionMarketPopup:onGetAuctionRecordDataSucc_(data)
	if self.currentView_ and self.currentView_["onGetAuctionRecordDataSucc_"] then
		self.currentView_:onGetAuctionRecordDataSucc_(data)
	end
end


function AuctionMarketPopup:onGetAuctionInitInfoSucc_(data)

	if not data then
		return
	end

	-- local filterType = data.item
	-- self.auctionMarketFilterBar_:setFilterTypes(data)
end



function AuctionMarketPopup:initViews()
	-- body

	-- Title Block
	local titleWord = display.newSprite("#aucMar_wordTitle.png")
	:addTo(self)
	local titleSize = titleWord:getContentSize()
	titleWord:pos(0,self.height_*0.5 - titleSize.height * 0.5)

	local tabLabelStr = bm.LangUtil.getText("AUCTION_MARKET","AUCTION_HELP_DES_TITLE")

	local mainTabIndicOffset = {
		x = - 8,
		y = - 8
	}

	-- 顶部栏
	local topNode = display.newNode()
	:pos(0,self.height_*0.5 - titleSize.height * 0.5 - 50)
	:addTo(self,99)

	--用户昵称
	local nameTxt = display.newTTFLabel({text =  bm.LangUtil.getText("AUCTION_MARKET","NICK"), size = 24, align = ui.TEXT_ALIGN_CENTER,color = cc.c3b(0xff,0xff,0xfd)})
	:align(display.CENTER_LEFT)
	:pos(-AuctionMarketPopup.WIDTH*0.5 + MainBoardMarginLeft,-20)
	:addTo(topNode)

	local nameTxtSize = nameTxt:getContentSize()
	self.nameLabel_ = display.newTTFLabel({text = nk.userData["aUser.name"], size = 24, align = ui.TEXT_ALIGN_CENTER,color = cc.c3b(0xff,0xff,0xfd)})
	:align(display.CENTER_LEFT)
	:pos(-AuctionMarketPopup.WIDTH*0.5 + MainBoardMarginLeft+nameTxtSize.width,-20)
	:addTo(topNode)

	--用户筹码显示
	self.iconChip_ = display.newSprite("#chip_icon.png")
	:addTo(topNode)
	:pos(0,-20)
	self.chipLabel_ = display.newTTFLabel({text = bm.formatNumberWithSplit( nk.userData["aUser.money"]), size = 24, align = ui.TEXT_ALIGN_CENTER,color = cc.c3b(0xff,0xd2,0x00)})
	:align(display.LEFT_CENTER)
	:addTo(topNode)
	:pos(0,-20)
	self:adjustChipLabelPos()

	--用户现金币
	self.crashCoinLabel_ = display.newTTFLabel({text = bm.formatNumberWithSplit(nk.userData["match.point"]), size = 24, align = ui.TEXT_ALIGN_CENTER,color = cc.c3b(0xff,0xd2,0x00)})
	:align(display.CENTER_RIGHT)
	:pos(AuctionMarketPopup.WIDTH*0.5 - MainBoardMarginRight,-20)
	:addTo(topNode)

	local crashCoinLabelSize = self.crashCoinLabel_:getContentSize()
	-- local crashCoinTxt = display.newTTFLabel({text = "现金币:", size = 24, align = ui.TEXT_ALIGN_CENTER,color = cc.c3b(0xff,0xff,0xfd)})
	-- :align(display.CENTER_RIGHT)
	-- :pos(AuctionMarketPopup.WIDTH*0.5 - MainBoardMarginLeft - crashCoinLabelSize.width,-20)
	-- :addTo(topNode) 

	-- 现金币图标
    display.newSprite("#aucMar_coin.png")
        :pos(AuctionMarketPopup.WIDTH*0.5 - MainBoardMarginRight - crashCoinLabelSize.width - 30,-20)
        :addTo(topNode)
        :scale(0.8)

	-- Main tabBar
	local tabBarPosXShift = 20
	local tabBg = display.newSprite("#aucMar_bgTabMain.png")
	local tabBgSize = tabBg:getContentSize()
	self.mainTabBar_ = nk.ui.TabBarWithIndicator.new(
		{
			background = tabBg, 
			indicator = "#aucMar_btnTabSel.png"
		},
		tabLabelStr, 
		{
			selectedText = {color = cc.c3b(0xff,0xfe,0xff), size = 28}, 
			defaltText = {color = cc.c3b(0xff,0x46,0x7f), size = 28}
		}, 
    	true, true)
	:setTabBarSize(tabBgSize.width, tabBgSize.height, mainTabIndicOffset.x, mainTabIndicOffset.y)
	:pos(- tabBarPosXShift,-(12+ tabBgSize.height * 0.5)-30)
	:onTabChange(handler(self, self.onMainTabChangeCallBack_))
		:gotoTab(self.defaultTabIndx_)
		:addTo(topNode)

	local tabBarPosY = self.mainTabBar_:getPositionY()

	local QMarkBtnMagrins = {
		right = 40,
		top = - 5
	}

	local QMarkBtn = cc.ui.UIPushButton.new("#aucMar_btnQMark.png")
		:onButtonClicked(buttontHandler(self, self.onQBtnCallBack_))
		:pos(self.width_ / 2 - QMarkBtnMagrins.right, - 20 - QMarkBtnMagrins.top)
		:addTo(topNode)

	-- QMarkBtn:setScale(0.8)
	-- mainTabBar:gotoTab(1)

	-- self.tabContPageContainer_ = display.newNode()
	-- 	:addTo(self.background_)


	
	self.auctionMarketFilterBar_ = AuctionMarketFilterBar.new()
	:addTo(topNode)
	self.auctionMarketFilterBar_:setDelegate(self)
	self.auctionMarketFilterBar_:setController(self.controller_)
	self.auctionMarketFilterBar_:addEventListener("FILTER_BAR_SORT_EVENT", handler(self, self.onFilterBarSort))
	self.auctionMarketFilterBar_:addEventListener("FILTER_BAR_TYPE_SELECT_EVENT",handler(self,self.onFilterBarTypeSelect))
	local filterBarSize = self.auctionMarketFilterBar_:getContentSize()
	self.auctionMarketFilterBar_:pos(0,tabBarPosY-tabBgSize.height * 0.5 - filterBarSize.height * 0.5 -20)

end


function AuctionMarketPopup:onFilterBarTypeSelect(evt)
	local data = evt.data
	if not data then
		return
	end
	-- body
	dump(evt,"onFilterBarTypeSelect===========")
	if self.currentView_ and self.currentView_["onFilterBarTypeSelect"] then
		self.currentView_:onFilterBarTypeSelect(data)
	end
end

function AuctionMarketPopup:onFilterBarSort(event)
	local data = event.data
	local evt = event.name
	if not data then
		return
	end
	-- if "FILTER_BAR_SORT_EVENT" == evt then
		-- dump("index:" .. data.index .. " state:" .. data.state,(data.state == 1 and "升序" or "降序"))
	-- end

	if self.currentView_ and self.currentView_["onFilterBarSort"] then
		self.currentView_:onFilterBarSort(data.index,data.state)
	end
end


function AuctionMarketPopup:sortByState()
	-- body
end



function AuctionMarketPopup:adjustChipLabelPos()
	local chipLabelSize = self.chipLabel_:getContentSize()
	local chipIconSize = self.iconChip_:getContentSize()
    self.iconChip_:setPositionX(-(chipIconSize.width + chipLabelSize.width + 6) * 0.5)
    self.chipLabel_:setPositionX(self.iconChip_:getPositionX() + chipIconSize.width + 6)

end

function AuctionMarketPopup:onMainTabChangeCallBack_(selectedTab)
	self:setSelectIndex(selectedTab)
end

function AuctionMarketPopup:onQBtnCallBack_()
	-- body
	AuctionMarketHelpPopup.new():show()
end

function AuctionMarketPopup:setSelectIndex(index)

	logger:debug("AuctionMarketPopup:index-",index)
	self.selectedIdx_ = index
	if self.currentView_ then
		self.currentView_:hide()
	end

	if not self.contPages_[index] then
		if index == 1 then
			self.contPages_[index] = AuctionCentreView.new():pos(0,-120):hide():addTo(self)
		elseif index == 2 then
			self.contPages_[index] = AuctionFixedPriceView.new():pos(0,-120):hide():addTo(self)
		elseif index == 3 then
			self.contPages_[index] = AuctionMineView.new():pos(0,-50):hide():addTo(self)
		elseif index == 4 then
			self.contPages_[index] = AuctionRecordView.new():pos(0,-120):hide():addTo(self)
		end
		self.contPages_[index]:setDelegate(self)
		self.contPages_[index]:setController(self.controller_)
		self.contPages_[index]:setIndex(index)
	end

	self.currentView_ = self.contPages_[index]
	self.currentView_:show()

	self:requestListDataByIndex(index)
	self:setFilterBarLabel(index)
	self:setFilterBarSortBtn(index)
	self:setFilterBarBtnsEnable(index)

	self.auctionMarketFilterBar_:hideTypeList()
end


function AuctionMarketPopup:setFilterBarLabel(index)
	local labelTb = 
 	bm.LangUtil.getText("AUCTION_MARKET","FILTER_BAR_LABELS_1")

 	if index == 4 then
 		labelTb = 
	 	bm.LangUtil.getText("AUCTION_MARKET","FILTER_BAR_LABELS_2")
 	end

 	self.auctionMarketFilterBar_:setLabelTb(labelTb)

end



function AuctionMarketPopup:setFilterBarSortBtn(index)
	local sortBtnTb = {0,0,1,1,1,0,0}
	if index == 2 then
		sortBtnTb = {0,0,1,0,1,0,0}
	elseif index == 3 then
		sortBtnTb = {0,0,0,0,0,0,0}
	elseif index == 4 then
		sortBtnTb = {0,0,0,0,0,0,0}
	end

	self.auctionMarketFilterBar_:setSortBtnTb(sortBtnTb)


	
end


function AuctionMarketPopup:setFilterBarBtnsEnable(index)
	local btnsEnableTb = {0,0,0,0,0,0,0}
	if index == 1 then
		btnsEnableTb = {1,0,1,1,1,0,0}
	elseif index == 2 then
		btnsEnableTb = {1,0,1,0,1,0,0}
	elseif index == 3 then
		btnsEnableTb = {1,0,0,0,0,0,0}
	elseif index == 4 then
		btnsEnableTb = {1,0,0,0,0,0,0}
	end
	self.auctionMarketFilterBar_:setFilterBarBtnsEnable(btnsEnableTb)
end


function AuctionMarketPopup:setLoading(isLoading)
    if isLoading then
        
        if not self.juhua_ then
            self.juhua_ = nk.ui.Juhua.new()
                :pos(0,0)
                :addTo(self)
        end
    else
        if self.juhua_ and self.juhua_:getParent() then
            self.juhua_:removeFromParent()
            self.juhua_ = nil
        end
    end
end



function AuctionMarketPopup:requestListDataByIndex(index)

	local requestDataFunTb = {"getAuctionCenterData","getAuctionFixedPriceData","getMyAuctionData","getAuctionRecordData"}
	local requestData = function(idx)
		-- if idx == 1 then
		-- 	self.controller_:getAuctionCenterData()
		-- elseif idx == 2 then
		-- 	self.controller_:getAuctionFixedPriceData()
		-- elseif idx == 3 then
		-- 	self.controller_:getMyAuctionData()

		-- elseif idx == 4 then
		-- 	-- self.controller_:getAuctionCenterData()
		-- end

		if self.contPages_[idx] and self.contPages_[idx][(requestDataFunTb[idx])] then
			self.contPages_[idx][(requestDataFunTb[idx])](self.contPages_[idx])
		end

	end



	if not self.timeMarkTb then
		self.timeMarkTb = {}
	end

	local lastTime = self.timeMarkTb[index]
	if not lastTime then
		self.timeMarkTb[index] = os.time()
		requestData(index)
	else
		local nowTime = os.time()
		-- 控制刷新频率
		if tonumber(nowTime) - tonumber(lastTime) > 8 then
			self.timeMarkTb[index] = nowTime
			if self.contPages_[index] and self.contPages_[index]["reset"] then
				self.contPages_[index]:reset()
			end
			requestData(index)
		end

	end
end


function AuctionMarketPopup:onCloseBtnCallBack_()
	self:hidePanel_()
end

function AuctionMarketPopup:onShowed()
	
end

function AuctionMarketPopup:onEnter()
	
end

function AuctionMarketPopup:onExit()
	display.removeSpriteFramesWithFile("auctionMarket_th.plist", "auctionMarket_th.png")

	nk.schedulerPool:delayCall(function()
	    cc.Director:getInstance():getTextureCache():removeUnusedTextures()
	end, 0.1)
end

function AuctionMarketPopup:onCleanup()
	self:removePropertyObservers()
	if self.controller_ then
		self.controller_:dispose()
	end
end

return AuctionMarketPopup