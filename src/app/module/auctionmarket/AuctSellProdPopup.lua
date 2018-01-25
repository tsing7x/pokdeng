--
-- Author: TsingZhang@boyaa.com
-- Date: 2016-01-18 15:45:51
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- Description: AuctSellProdPopup.lua By tsing.
--
local DigitInputPanel = import("app.module.hall.personalRoomDialog.ImputPasswordPanel")

local AuctSellProdChooseItem = import(".AuctSellProdChooseItem")
local AuctSellProdPopup = class("AuctSellProdPopup", function()
	-- body
	return display.newNode()
end)

function AuctSellProdPopup:ctor(defaultPageIndex, controller)
	-- body
	self.background_ = display.newSprite("#aucMar_bgMainAcutSell.png")
		:addTo(self)

	self.background_:setTouchEnabled(true)

	self.background_:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.onHideDigitInputPanel))
	self:setNodeEventEnabled(true)

	self.defaultPageIdx_ = defaultPageIndex or 1
	self.controller_ = controller

	self.bgPanelSize_ = self.background_:getContentSize()
	self:drawTopArea()

	self:drawMainBlockBelow()  -- Zorder 的差异需要先绘制下半部分的UI
	self:drawMainBlockAbove()

	self:reqNeededData()  -- 拉取绘制UI的必要数据
end




function AuctSellProdPopup:reqNeededData()
	-- body
	self.canAuctionProdList = nil
	-- self.auctTimeSwitchList = nil

	self.controller_:getCanAuctionData(function(data)
		-- body

		-- self.canAuctionProdList = data

		if #data > 0 then
			--todo

			local comboxViewData = {}
			self.canAuctionProdList = {}

			for i = 1, #data do
				if data[i].num > 0 then
					--todo

					table.insert(comboxViewData, data[i].name)
					table.insert(self.canAuctionProdList, data[i])
				end
			end

			if self and self.prodChooseCombox_ then
				--todo

				if #comboxViewData > 0 then
					--todo
					self.prodChooseCombox_:setData(comboxViewData, comboxViewData[1])

					self.prodType_ = self.canAuctionProdList[1].type
					self.prodNumHas_ = tonumber(self.canAuctionProdList[1].num)

					self.prodNameTips_:hide()
					self.prodNumTips_:hide()
				end
			end	
		else
			self.canAuctionProdList = nil
		end
		
	end, function(errData)
		-- body
		self.canAuctionProdList = nil
	end)


	local timeSwitchData = self.controller_:getInitInfo()

	local timeswitch = (timeSwitchData and timeSwitchData.timeswitch or nil)
	if not timeswitch or table.nums(timeswitch) == 0 then
		timeswitch = {}
		timeswitch["24"] = 1
	end

	--过滤未开放的时间数据
	table.filter(timeswitch, function(v, k)
	    return v ~= 0 -- 当值等于 0 时过滤掉该值
	end)

	-- 重新排列数据
	timeswitchTemp  = table.keys(timeswitch)

	table.sort(timeswitchTemp,function(t1,t2)
		return tonumber(t1) > tonumber(t2)
	end)

	

	local newCount = #timeswitchTemp or 0
	local oldCount = 0
	-- if self.auctTimeBtnGroup_ then
		oldCount = self.auctTimeBtnGroup_:getButtonsCount() or 0
        if oldCount > newCount then
            for i = newCount + 1, oldCount do
                self.auctTimeBtnGroup_:removeButtonAtIndex(i)
            end
        end
    -- end

  
   for i = 1,#timeswitchTemp do
    	local timeBtn = self.auctTimeBtnGroup_:getButtonAtIndex(i)
    	if not timeBtn then
    		timeBtn = cc.ui.UICheckBoxButton.new({off = "#aucMar_rdBtnOffAcutSell.png", on = "#aucMar_rdBtnOnAcutSell.png"},
			{scale9 = false})
			:setButtonLabel(display.newTTFLabel({text = (timeswitchTemp[i] ..bm.LangUtil.getText("AUCTION_MARKET","TIME_HOUR")), size = 20,
				color = cc.c3b(138, 158, 208), align = ui.TEXT_ALIGN_CENTER}))
			:setButtonLabelOffset(10, 0)
			:align(display.LEFT_CENTER)
			:pos(self.auctTimeBtnGroupPosX_ + (i-1)*80,self.auctTimeBtnGroupPosY_ + 15)
			-- :setButtonSize(30,100)
			:addTo(self.background_)
			self.auctTimeBtnGroup_:addButton(timeBtn)
    	else
    		timeBtn:setButtonLabelString((timeswitchTemp[i] ..bm.LangUtil.getText("AUCTION_MARKET","TIME_HOUR")))
    	end
    end

    self.auctTimeBtnGroup_:getButtonAtIndex(1):setButtonSelected(true)

	self.timeVal = timeswitchTemp

end

function AuctSellProdPopup:drawTopArea()
	-- body
	-- local bgPanelSize = self.background_:getContentSize()

	local tabLabelStr = bm.LangUtil.getText("AUCTION_MARKET","AUCTION_POP_TAB_STR")

	local tabBg = display.newSprite("#aucMar_bgSliderAcutSell.png")

	local tabBgSize = tabBg:getContentSize()
	local tabIndicOffset = {
		x = - 8,
		y = - 8
	}
	local tabBarMagrinTop = 5

	self.tabBarTop_ = nk.ui.TabBarWithIndicator.new({background = tabBg, indicator = "#aucMar_btnTabSel.png"},
		tabLabelStr,
		{
			selectedText = {color = cc.c3b(0xff,0xfe,0xff), size = 30}, 
			defaltText = {color = cc.c3b(79, 87, 106), size = 30}
		}, true, true)
		:setTabBarSize(tabBgSize.width, tabBgSize.height, tabIndicOffset.x, tabIndicOffset.y)
		:onTabChange(handler(self, self.onAuctTypeTabChanged_))
		:gotoTab(self.defaultPageIdx_)
		:pos(self.bgPanelSize_.width / 2, self.bgPanelSize_.height - tabBgSize.height / 2 - tabBarMagrinTop)
		:addTo(self.background_)

	local closeBtnPosAdjust = {
		x = 4,
		y = 8
	}

	local closeBtnSize = {
		width = 42,
		height = 42
	}

	local closeBtn = cc.ui.UIPushButton.new({normal = "#panel_close_btn_up.png", pressed = "#panel_close_btn_down.png"}, {scale9 = false})
		:onButtonClicked(buttontHandler(self, self.onCloseBtnCallBack_))
		:pos(self.bgPanelSize_.width - closeBtnSize.width / 2 - closeBtnPosAdjust.x, self.bgPanelSize_.height - closeBtnSize.height / 2 - closeBtnPosAdjust.y)
		:addTo(self.background_)
end

function AuctSellProdPopup:drawMainBlockAbove()
	-- body
	-- local bgPanelSize = self.background_:getContentSize()

	local prodInfoInputBoxSize = {
		width = 382,
		height = 48
	}
	local prodAuctSellInfoInputBoxMagrinRight = 25

	local mainAuctSellProdInfoLabelParam = {
		titleLabel = {
			frontSize = 25,
			color = cc.c3b(0x8c, 0x9f, 0xcf)
		},

		prodInfo = {
			frontSize = 24,
			color = cc.c3b(62, 78, 103)
		},

		prodTip = {
			frontSize = 16,
			color = cc.c3b(255, 147, 119)
		},

		timeItem = {
			frontSize = 20,
			color = cc.c3b(138, 158, 208)
		}
	}

	-- Main ProdInfoCtr Block --

	-- TimeChooseRadio --
	local auctTimeBtnGroupPosYShift = 25
	local timeRadioBtnSize = {
		width = 90,
		height = 30
	}


	self.auctTimeBtnGroup_ = nk.ui.CheckBoxButtonGroup.new()
	:onButtonSelectChanged(buttontHandler(self, self.onAuctTimeSelectChanged_))
	self.auctTimeBtnGroupPosX_ = self.bgPanelSize_.width - prodInfoInputBoxSize.width - prodAuctSellInfoInputBoxMagrinRight
	self.auctTimeBtnGroupPosY_ = self.bgPanelSize_.height / 2 - auctTimeBtnGroupPosYShift

	-- local tempStr = "0" .. bm.LangUtil.getText("AUCTION_MARKET","TIME_HOUR")
	-- local timeToAuctStr = {
	-- 	tempStr,
	-- 	tempStr,
	-- 	tempStr
	-- }

	local timeBtnLabelOffset = {
		x = 10,
		y = 0
	}

	local radioBtnMagrins = {
		top = 2,
		left = 5,
		right = 5,
		bottom = 2
	}

	local radioDisTipsBgSize = {
		width = 122,
		height = 28
	}

	local radioDisItemBgSize = {
		width = 82,
		height = 28
	}

	-- local radioDisBgPosXShift = 5
	-- self.radioBtnDisTipsBg_ = display.newScale9Sprite("#aucMar_bgProdNameItem.png", self.bgPanelSize_.width - radioDisTipsBgSize.width / 2 - prodAuctSellInfoInputBoxMagrinRight - radioDisBgPosXShift,
	-- 	self.bgPanelSize_.height / 2 + timeRadioBtnSize.height / 2 - auctTimeBtnGroupPosYShift, cc.size(radioDisTipsBgSize.width, radioDisTipsBgSize.height))
	-- 	:addTo(self.background_)

	-- self.radioDisItemBg_ = {}
	-- for i = 1, #timeToAuctStr do
	-- 	self.radioDisItemBg_[i] = display.newScale9Sprite("#aucMar_bgProdNameItem.png", self.bgPanelSize_.width - radioDisItemBgSize.width / 2 * (2 *(#timeToAuctStr - i + 1) - 1) - prodAuctSellInfoInputBoxMagrinRight
	-- 		- radioDisBgPosXShift - radioDisTipsBgSize.width,
	-- 			self.bgPanelSize_.height / 2 + timeRadioBtnSize.height / 2 - auctTimeBtnGroupPosYShift, cc.size(radioDisItemBgSize.width, radioDisItemBgSize.height))
	-- 		:addTo(self.background_)
	-- end
	-- self.radioDisItemBg_[1]:hide()
	-- self.radioDisItemBg_[2]:hide()
	-- self.radioDisItemBg_[3]:hide()

	-- for i = 1, #timeToAuctStr do
	-- 	local timeRadioBtn = cc.ui.UICheckBoxButton.new({off = "#aucMar_rdBtnOffAcutSell.png", on = "#aucMar_rdBtnOnAcutSell.png"},
	-- 		{scale9 = false})
	-- 		:setButtonLabel(display.newTTFLabel({text = timeToAuctStr[i], size = mainAuctSellProdInfoLabelParam.timeItem.frontSize,
	-- 			color = mainAuctSellProdInfoLabelParam.timeItem.color, align = ui.TEXT_ALIGN_CENTER}))
	-- 		:setButtonLabelOffset(timeBtnLabelOffset.x, timeBtnLabelOffset.y)
	-- 		:align(display.LEFT_CENTER)
	-- 		:setButtonEnabled(false)

	-- 	self.auctTimeBtnGroup_:addButton(timeRadioBtn)
	-- end

	-- self.auctTimeBtnGroup_:setButtonsLayoutMargin(radioBtnMagrins.top, radioBtnMagrins.right, radioBtnMagrins.bottom, radioBtnMagrins.left)  -- setButtonsLayoutMargin(top, right, bottom, left)
	-- 	:onButtonSelectChanged(buttontHandler(self, self.onAuctTimeSelectChanged_))
	-- 	:pos(self.bgPanelSize_.width - prodInfoInputBoxSize.width - prodAuctSellInfoInputBoxMagrinRight,
	-- 		self.bgPanelSize_.height / 2 - auctTimeBtnGroupPosYShift)
	-- 	:addTo(self.background_)

	-- local defaultSelectIdx = 1
	-- self.auctTimeBtnGroup_:getButtonAtIndex(defaultSelectIdx):setButtonSelected(true)

	-- 暂未开放设置！

	-- self.auctTimeBtnGroup_:getButtonAtIndex(2):setButtonEnabled(false)
	-- self.auctTimeBtnGroup_:getButtonAtIndex(3):setButtonEnabled(false)


	--[[
	local notOpenTipsMagrinRight = 35
	self.auctTimeItemNotOpenTip_ = display.newTTFLabel({text = bm.LangUtil.getText("AUCTION_MARKET","NOT_OPEN"), size = mainAuctSellProdInfoLabelParam.timeItem.frontSize,
		color = mainAuctSellProdInfoLabelParam.timeItem.color, align = ui.TEXT_ALIGN_CENTER})
	self.auctTimeItemNotOpenTip_:pos(self.bgPanelSize_.width - self.auctTimeItemNotOpenTip_:getContentSize().width / 2 - notOpenTipsMagrinRight,
		self.auctTimeBtnGroup_:getPositionY() + timeRadioBtnSize.height / 2)
		:addTo(self.background_)

	local prodInfoTilLabelMagrinRight = 30

	local auctTimeLabel = display.newTTFLabel({text = bm.LangUtil.getText("AUCTION_MARKET","SELECT_TIME"), size = mainAuctSellProdInfoLabelParam.titleLabel.frontSize,
		color = mainAuctSellProdInfoLabelParam.titleLabel.color, align = ui.TEXT_ALIGN_CENTER})
	auctTimeLabel:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER_RIGHT])
	auctTimeLabel:pos(self.auctTimeBtnGroup_:getPositionX() - prodInfoTilLabelMagrinRight,
		self.auctTimeBtnGroup_:getPositionY() + timeRadioBtnSize.height / 2)
		:addTo(self.background_)
--]]
	-- End --

	local prodInfoTilLabelMagrinRight = 30
	local auctTimeLabel = display.newTTFLabel({text = bm.LangUtil.getText("AUCTION_MARKET","SELECT_TIME"), size = mainAuctSellProdInfoLabelParam.titleLabel.frontSize,
		color = mainAuctSellProdInfoLabelParam.titleLabel.color, align = ui.TEXT_ALIGN_CENTER})
	auctTimeLabel:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER_RIGHT])
	auctTimeLabel:pos(self.bgPanelSize_.width - prodInfoInputBoxSize.width - prodAuctSellInfoInputBoxMagrinRight - prodInfoTilLabelMagrinRight,
		self.bgPanelSize_.height / 2 - auctTimeBtnGroupPosYShift + timeRadioBtnSize.height / 2)
		:addTo(self.background_)


	-- NumInputBox --

	local prodAcutNumInputBoxBgMagrinBottom = 28
	local prodNumInputBoxBg = display.newScale9Sprite("#aucMar_bgPriEdit.png", self.bgPanelSize_.width - prodInfoInputBoxSize.width / 2 - prodAuctSellInfoInputBoxMagrinRight,
		self.bgPanelSize_.height / 2 - auctTimeBtnGroupPosYShift + timeRadioBtnSize.height + prodInfoInputBoxSize.height / 2 + prodAcutNumInputBoxBgMagrinBottom,
		cc.size(prodInfoInputBoxSize.width, prodInfoInputBoxSize.height))
		:addTo(self.background_)

	local prodNumMagrinLeft = 20
	self.prodNum_ = display.newTTFLabel({text = "0", size = mainAuctSellProdInfoLabelParam.prodInfo.frontSize,
		color = mainAuctSellProdInfoLabelParam.prodInfo.color, align = ui.TEXT_ALIGN_CENTER})
	self.prodNum_:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER_LEFT])
	self.prodNum_:pos(prodNumMagrinLeft, prodInfoInputBoxSize.height / 2)
		:addTo(prodNumInputBoxBg)

	self.curProdNumString = "0"

	local prodNumLabel = display.newTTFLabel({text = bm.LangUtil.getText("AUCTION_MARKET","INPUT_NUM"), size = mainAuctSellProdInfoLabelParam.titleLabel.frontSize,
		color = mainAuctSellProdInfoLabelParam.titleLabel.color, align = ui.TEXT_ALIGN_CENTER})
	prodNumLabel:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER_RIGHT])
	prodNumLabel:pos(prodNumInputBoxBg:getPositionX() - prodInfoInputBoxSize.width / 2 - prodInfoTilLabelMagrinRight,
		prodNumInputBoxBg:getPositionY())
		:addTo(self.background_)

	bm.TouchHelper.new(prodNumInputBoxBg, handler(self, self.onProdNumClkCallBack_))

	local prodNumTipMagrinTop = 2
	self.prodNumTips_ = display.newTTFLabel({text = bm.LangUtil.getText("AUCTION_MARKET","NOT_ENOUGH_NUM_FOR_RETRY"), size = mainAuctSellProdInfoLabelParam.prodTip.frontSize,
		color = mainAuctSellProdInfoLabelParam.prodTip.color, align = ui.TEXT_ALIGN_CENTER})
	self.prodNumTips_:pos(prodNumInputBoxBg:getPositionX(),
		prodNumInputBoxBg:getPositionY() - prodInfoInputBoxSize.height / 2 - prodNumTipMagrinTop - self.prodNumTips_:getContentSize().height / 2)
		:addTo(self.background_)

	-- self.prodNumTips_:hide()  -- 初始状态隐藏
	-- End --

	-- NameInputBox --

	local prodNameTipMagrinBottom = 10
	self.prodNameTips_ = display.newTTFLabel({text = bm.LangUtil.getText("AUCTION_MARKET","LACK_TO_AUCTION"), size = mainAuctSellProdInfoLabelParam.prodTip.frontSize,
		color = mainAuctSellProdInfoLabelParam.prodTip.color, align = ui.TEXT_ALIGN_CENTER})
	self.prodNameTips_:pos(prodNumInputBoxBg:getPositionX(),
		prodNumInputBoxBg:getPositionY() + prodInfoInputBoxSize.height / 2 + prodNameTipMagrinBottom + self.prodNameTips_:getContentSize().height / 2)
		:addTo(self.background_)

	-- self.prodNameTips_:hide()  -- 初始状态隐藏

	local prodNameInputBoxBgMagrinTop = 8
	local prodNameLabel = display.newTTFLabel({text = bm.LangUtil.getText("AUCTION_MARKET","SELECT_TO_AUCTION"), size = mainAuctSellProdInfoLabelParam.titleLabel.frontSize,
		color = mainAuctSellProdInfoLabelParam.titleLabel.color, align = ui.TEXT_ALIGN_CENTER})
	prodNameLabel:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER_RIGHT])
	prodNameLabel:pos(prodNumLabel:getPositionX(),
		self.tabBarTop_:getPositionY() - self.tabBarTop_.background_:getContentSize().height / 2 - prodNameInputBoxBgMagrinTop - prodInfoInputBoxSize.height / 2)
		:addTo(self.background_)

	-- local prodNameInputBoxBg = display.newScale9Sprite("#aucMar_bgPriEdit.png", bgPanelSize.width - prodInfoInputBoxSize.width / 2 - prodAuctSellInfoInputBoxMagrinRight,
	-- 	self.tabBarTop_:getPositionY() - self.tabBarTop_.background_:getContentSize().height / 2 - prodNameInputBoxBgMagrinTop - prodInfoInputBoxSize.height / 2,
	-- 	cc.size(prodInfoInputBoxSize.width, prodInfoInputBoxSize.height))
	-- 	:addTo(self.background_)

	-- local prodNameMagrinLeft = 20
	-- self.prodName_ = display.newTTFLabel({text = "prodName", size = mainAuctSellProdInfoLabelParam.prodInfo.frontSize,
	-- 	color = mainAuctSellProdInfoLabelParam.prodInfo.color, align = ui.TEXT_ALIGN_CENTER})
	-- self.prodName_:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER_LEFT])
	-- self.prodName_:pos(prodNameMagrinLeft, prodInfoInputBoxSize.height / 2)
	-- 	:addTo(prodNameInputBoxBg)

	-- local arrowDownBtnMagrinRight = 8
	-- local arrowDownBtn = display.newSprite("#aucMar_arrowDownAcutSell.png")
	-- arrowDownBtn:pos(prodInfoInputBoxSize.width - arrowDownBtn:getContentSize().width / 2 - arrowDownBtnMagrinRight,
	-- 	prodInfoInputBoxSize.height / 2)
	-- 	:addTo(prodNameInputBoxBg)

	-- arrowDownBtn:setTouchSwallowEnabled(false)

	-- local popDownListParam = {
	-- 	WIDTH = prodInfoInputBoxSize.width,
	-- 	HEIGHT = prodInfoInputBoxSize.height * 5
	-- }

	local params = {}
   	params.itemCls = AuctSellProdChooseItem
    params.listWidth = prodInfoInputBoxSize.width
    params.listHeight = prodInfoInputBoxSize.height * 4.5
    params.listOffY = - prodInfoInputBoxSize.height / 2 - 2
    params.borderSize = cc.size(prodInfoInputBoxSize.width, prodInfoInputBoxSize.height)
    params.lblSize = mainAuctSellProdInfoLabelParam.prodInfo.frontSize

    params.barRes = "#aucMar_arrowDownAcutSell.png"
    params.borderRes = "#aucMar_bgPriEdit.png"
    params.lblcolor = mainAuctSellProdInfoLabelParam.prodInfo.color

    params.barNoScale = true  -- Addtional ParamItem.
    params.barMagrin = 8
    params.lblAnchPot = display.CENTER_LEFT
	self.prodChooseCombox_ = nk.ui.ComboboxView.new(params, handler(self, self.onHideDigitInputPanel),
		handler(self, self.onComboxItemClkCallBack))
		:pos(prodNumInputBoxBg:getPositionX(), prodNameLabel:getPositionY())
		:addTo(self.background_, 3)  -- 显示层级必须要提高.

	self.prodChooseCombox_:setData({"."}, "prodName")  -- Test --
	-- 这里需要取到相应的数据, 设置诸如 ：{"cash.", "props.", "name.3", "name.4", "name.5", "name.6"}, "prodName"
	-- 取到数据如果为nil 则显示无可拍物品Tips

	-- bm.TouchHelper.new(prodNameInputBoxBg, handler(self, self.onProdNameChooseCallBack_))
	-- End --
end

function AuctSellProdPopup:drawMainBlockBelow()
	-- body
	-- local bgPanelSize = self.background_:getContentSize()
	-- Digit Input Area --
	blockAreaBelowInfoLabelParam = {
		aucPrice = {
			frontSize = 26,
			color = cc.c3b(97, 106, 123)
		},

		digitNum = {
			frontSize = 25,
			color = display.COLOR_WHITE
		},

		btnTip = {
			frontSize = 26,
			color = display.COLOR_WHITE
		},

		btnLabel = {
			frontSize = 26,
			color = display.COLOR_WHITE
		},

		tipBottom = {
			frontSize = 18,
			color = cc.c3b(153, 153, 153)
		}
	}
	
	local digitInputBlockMagrins = {
		left = 15,
		bottom = 45
	}
	local digitBlockBg = display.newSprite("#aucMar_bgDentAcutSell.png")

	local dgBlockSize = digitBlockBg:getContentSize()
	digitBlockBg:pos(digitInputBlockMagrins.left + dgBlockSize.width / 2, dgBlockSize.height / 2 + digitInputBlockMagrins.bottom)
		:addTo(self.background_)

	local inputBgMagrinTop = 2
	local auctPriceInputBg = display.newSprite("#aucMar_bgDigitEditAcutSell.png")
	local auctPriceInputBgSize = auctPriceInputBg:getContentSize()

	auctPriceInputBg:pos(dgBlockSize.width / 2, dgBlockSize.height - inputBgMagrinTop - auctPriceInputBgSize.height / 2)
		:addTo(digitBlockBg)

	local priceLabelMagrinLeft = 15
	self.auctPriceTxt_ = display.newTTFLabel({text = "0", size = blockAreaBelowInfoLabelParam.aucPrice.frontSize,
		color = blockAreaBelowInfoLabelParam.aucPrice.color, align = ui.TEXT_ALIGN_CENTER})
	self.auctPriceTxt_:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER_LEFT])
	self.auctPriceTxt_:pos(priceLabelMagrinLeft, auctPriceInputBgSize.height / 2)
		:addTo(auctPriceInputBg)

	self.auctPriString = "0"

	local delBtnSize = {
		width = 76,
		height = 48
	}
	local delBtnmagrinRight = 2
	local deleteBtn = cc.ui.UIPushButton.new("#aucMar_backAcutSell.png", {scale9 = false})
		:onButtonClicked(buttontHandler(self, self.onAuctPriceDelBtnCallBack_))
		:pos(auctPriceInputBgSize.width - delBtnSize.width / 2 - delBtnmagrinRight, auctPriceInputBgSize.height / 2)
		:addTo(auctPriceInputBg)

	local digitBtnSize = {
		width = 70,
		height = 48
	}

	local digitBtnMagrins = {
		firstRowLeft = 15,
		topAndBottom = 5,
		eachLine = 2,
		eachRow = 2
	}
	for i = 1, 10 do
		local digitBtn = cc.ui.UIPushButton.new("#aucMar_btnDigitNum.png", {scale9 = true})
			:setButtonSize(digitBtnSize.width, digitBtnSize.height)
			:setButtonLabel("normal", display.newTTFLabel({text = tostring(i == 10 and 0 or i), size = blockAreaBelowInfoLabelParam.digitNum.frontSize,
				color = blockAreaBelowInfoLabelParam.digitNum.color, align = ui.TEXT_ALIGN_CENTER}))
			:onButtonClicked(buttontHandler(self, self.onDigitClkCallBack_))

		if i <= 5 then
			--todo
			digitBtn:pos(digitBtnMagrins.firstRowLeft + digitBtnSize.width / 2 * (2 * i - 1) + digitBtnMagrins.eachRow * (i - 1),
				digitBtnMagrins.topAndBottom + digitBtnSize.height * 1.5 + digitBtnMagrins.eachLine)
		else
			digitBtn:pos(digitBtnMagrins.firstRowLeft + digitBtnSize.width / 2 * (2 * (i - 5) - 1) + digitBtnMagrins.eachRow * ((i - 5) - 1),
				digitBtnMagrins.topAndBottom + digitBtnSize.height / 2)
		end

		digitBtn:addTo(digitBlockBg)
		-- digitBtn:setTouchSwallowEnabled(false)
	end
	-- End --

	-- RestArea --
	local auctBtnSize = {
		width = 195,
		height = 70
	}

	local confirmBtnMagrinRight = 20
	self.confirmAuctBtn_ = cc.ui.UIPushButton.new({normal = "#aucMar_btnYellow.png", pressed = "#aucMar_btnYellow.png", disabled = "#common_btn_disabled.png"},
		{scale9 = true})
		:setButtonSize(auctBtnSize.width, auctBtnSize.height)
		:setButtonLabel("normal", display.newTTFLabel({text = bm.LangUtil.getText("AUCTION_MARKET","SURE_AUCTION_2"), size = blockAreaBelowInfoLabelParam.btnLabel.frontSize,
			color = blockAreaBelowInfoLabelParam.btnLabel.color, align = ui.TEXT_ALIGN_CENTER}))
		:onButtonClicked(buttontHandler(self, self.onConfirmAuctBtnCallBack_))
		:pos(self.bgPanelSize_.width - confirmBtnMagrinRight - auctBtnSize.width / 2, digitBlockBg:getPositionY())
		:addTo(self.background_)

	self.confirmAuctBtn_:setButtonEnabled(false)

	local auctBtnTipMagrinBottom = 5
	local auctBtnTip = display.newTTFLabel({text = bm.LangUtil.getText("AUCTION_MARKET","INPUT_ORG_PRICE"), size = blockAreaBelowInfoLabelParam.btnLabel.frontSize,
		color = blockAreaBelowInfoLabelParam.btnLabel.color, align = ui.TEXT_ALIGN_CENTER})
	auctBtnTip:pos(self.confirmAuctBtn_:getPositionX(),
		self.confirmAuctBtn_:getPositionY() + auctBtnSize.height / 2 + auctBtnTipMagrinBottom + auctBtnTip:getContentSize().height / 2)
		:addTo(self.background_)

	local tipsBottomMagrinBottom = 5
	self.tipsBottom_ = display.newTTFLabel({text = bm.LangUtil.getText("AUCTION_MARKET","PRICING_TIP_4"), size = blockAreaBelowInfoLabelParam.tipBottom.frontSize,
		color = blockAreaBelowInfoLabelParam.tipBottom.color, align = ui.TEXT_ALIGN_CENTER})
	self.tipsBottom_:pos(self.bgPanelSize_.width / 2, self.tipsBottom_:getContentSize().height / 2 + tipsBottomMagrinBottom)
		:addTo(self.background_)
end

function AuctSellProdPopup:onAuctTypeTabChanged_(selectedIdx)
	-- body
	-- if not self.selectedIdx_ then
	-- 	--todo
	-- 	self.selectedIdx_ = selectedIdx
	-- end

	if selectedIdx == 2 then
		--todo
		self.tipsBottom_:setString(bm.LangUtil.getText("AUCTION_MARKET","PRICING_TIP_1"))
		self.tipsBottom_:setTextColor(display.COLOR_RED)

		self.auctPriceTxt_:setString(bm.LangUtil.getText("AUCTION_MARKET","PRICING_TIP_2"))

		local userLevelFact = nk.Level:getLevelByExp(nk.userData["aUser.exp"])
		if userLevelFact < 10 then
			--todo
			nk.CenterTipManager:showCenterTip({text = bm.LangUtil.getText("AUCTION_MARKET","PRICING_TIP_3"), messageType = 1000})

			local backToTab = 1
			self.tabBarTop_:gotoTab(backToTab)

			return
		end
	else
		self.tipsBottom_:setString(bm.LangUtil.getText("AUCTION_MARKET","PRICING_TIP_4"))
		self.tipsBottom_:setTextColor(cc.c3b(153, 153, 153))

		if string.len(self.auctPriString) > 0 then
			--todo
			self.auctPriceTxt_:setString(self.auctPriString)
		end
	end

	self.selectedIdx_ = selectedIdx
end

-- Abandoned By Realization Change. --
function AuctSellProdPopup:onProdNameChooseCallBack_()
	-- body
	if evtName == bm.TouchHelper.TOUCH_BEGIN then

    elseif evtName == bm.TouchHelper.CLICK then
    	-- popDown ProdNameList --
    	local params = {}
       	params.itemCls = ScoreComboItem
        params.listWidth = itemDW
        params.listHeight = itemDH*7+0
        params.listOffY = -itemDH*0.5
        params.borderSize = cc.size(itemDW,itemDH)
        params.lblSize = 18

    	self.popProdChooseList_ = nk.ui.ComboboxView.new(params)
    		:pos(0, 0)
    		:addTo(self.background_)
    end
end
-- End --

function AuctSellProdPopup:onProdNumClkCallBack_(target, evtName)
	-- body
	if evtName == bm.TouchHelper.TOUCH_BEGIN then

    elseif evtName == bm.TouchHelper.CLICK then
    	-- Popup DigitInput Panel --

    	if not self.digitInputPanel_ then
    		--todo
    		-- self.curProdNumString = ""
    		local digitPanelPosYShift = 5

    		self.digitInputPanel_ = DigitInputPanel.new(self)
		    	:pos(self.bgPanelSize_.width / 2, self.bgPanelSize_.height / 2 - digitPanelPosYShift)
		    	:addTo(self.background_)
    	else
    		self.digitInputPanel_:removeFromParent()
    		self.digitInputPanel_ = nil

    		-- -- 根据需求确定xx数值,预计 tonumber(self.curProdNumString) 应该是10的整数倍  tonumber(self.auctPriString) 在合理范围之内
			-- if tonumber(self.curProdNumString) > 0 and tonumber(self.curProdNumString) % xx == 0 and tonumber(self.auctPriString) > 0 then
			-- 	--todo

			-- 	if self.selectedIdx_ == 2 and tonumber(self.auctPriString) < 10000000 then
			-- 		--todo
			-- 		self.confirmAuctBtn_:setButtonEnabled(false)

			-- 	else
			-- 		self.confirmAuctBtn_:setButtonEnabled(true)
			-- 	end
			-- else
			-- 	self.confirmAuctBtn_:setButtonEnabled(false)
			-- end
    	end
    end
end

function AuctSellProdPopup:changeBaseChip_(numLabel)
	-- body
	-- 根据该物品的实际数量xxxx 做出判断

	-- if string.len(self.curProdNumString) > 0 and tonumber(self.curProdNumString) > xxxx then
	-- 	--todo
	-- 	self.prodNumTips_:show()
	-- 	return
	-- end

	if string.len(self.curProdNumString) >= 12 then
		--todo
		return
	end

	self.curProdNumString = self.curProdNumString .. numLabel:getString()
	self.prodNum_:setString(bm.formatNumberWithSplit(self.curProdNumString))

	if self.curProdNumString == "00" then
		--todo
		local curString = string.sub(self.curProdNumString, 0, 1)
        self.curProdNumString = curString
	end

	-- if tonumber(self.curProdNumString) >= xxxx then
	-- 	--todo
	-- 	self.prodNum_:setString(bm.formatNumberWithSplit(xxxx))
	-- 	self.curProdNumString = tostring(xxxx)
	-- end

	local auctPriStart = tonumber(self.auctPriString)

	if self.canAuctionProdList then
		--todo

		if self.prodType_ and tonumber(self.curProdNumString) > 0 and tonumber(self.curProdNumString) <= self.prodNumHas_ then
			--todo

			-- self.prodNameTips_:hide()
			self.prodNumTips_:hide()

			if auctPriStart > 0 then
				--todo
				self.confirmAuctBtn_:setButtonEnabled(true)
			else
				self.confirmAuctBtn_:setButtonEnabled(false)
			end
			
		else

			self.confirmAuctBtn_:setButtonEnabled(false)
			if tonumber(self.curProdNumString) > self.prodNumHas_ then
				--todo
				self.prodNumTips_:show()
			end
		end
	end
end

function AuctSellProdPopup:onOk_()
	-- body
	self:onHideDigitInputPanel()

	if string.len(self.curProdNumString) <= 0 then
		--todo
		self.curProdNumString = "0"
	end
end

function AuctSellProdPopup:onDelete_()
	-- body
	if self.curProdNumString == "0" then
		--todo
		return
	end

	local curLength = string.len(self.curProdNumString)
    local curString = string.sub(self.curProdNumString, 0, curLength - 1)

    self.curProdNumString = curString
    self.prodNum_:setString(bm.formatNumberWithSplit(self.curProdNumString))

    local auctPriStart = tonumber(self.auctPriString)

    if self.canAuctionProdList then
		--todo

		if self.prodType_ and tonumber(self.curProdNumString) > 0 and tonumber(self.curProdNumString) <= self.prodNumHas_ then
			--todo

			-- self.prodNameTips_:hide()
			self.prodNumTips_:hide()

			if auctPriStart > 0 then
				--todo
				self.confirmAuctBtn_:setButtonEnabled(true)
			else
				self.confirmAuctBtn_:setButtonEnabled(false)
			end
			
		else

			self.confirmAuctBtn_:setButtonEnabled(false)
			if tonumber(self.curProdNumString) > self.prodNumHas_ then
				--todo
				self.prodNumTips_:show()
			else
				self.prodNumTips_:hide()
			end
		end
	end
end

function AuctSellProdPopup:onHideDigitInputPanel()
	-- body
	if self.digitInputPanel_ then
		--todo
		self.digitInputPanel_:removeFromParent()
		self.digitInputPanel_ = nil
	end

	-- -- 根据需求确定xx数值,预计 tonumber(self.curProdNumString) 应该是10的整数倍  tonumber(self.auctPriString) 在合理范围之内
	-- if tonumber(self.curProdNumString) > 0 and tonumber(self.curProdNumString) % xx == 0 and tonumber(self.auctPriString) > 0 then
	-- 	--todo

	-- 	if self.selectedIdx_ == 2 and tonumber(self.auctPriString) < 10000000 then
	-- 		--todo
	-- 		self.confirmAuctBtn_:setButtonEnabled(false)

	-- 	else
	-- 		self.confirmAuctBtn_:setButtonEnabled(true)
	-- 	end
	-- else
	-- 	self.confirmAuctBtn_:setButtonEnabled(false)
	-- end
end

function AuctSellProdPopup:onComboxItemClkCallBack(data)
	-- body
	dump(data, "onComboxItemClkCallBack.data:===============")

	local idx = data.id

	if self.canAuctionProdList and #self.canAuctionProdList > 0 then
		--todo
		self.prodType_ = self.canAuctionProdList[idx].type
		self.prodNumHas_ = tonumber(self.canAuctionProdList[idx].num)
	
		local auctPriStart = tonumber(self.auctPriString)

		if self.prodType_ and tonumber(self.curProdNumString) > 0 and tonumber(self.curProdNumString) <= self.prodNumHas_ then
			--todo
			self.prodNumTips_:hide()

			if auctPriStart > 0 then
				--todo
				self.confirmAuctBtn_:setButtonEnabled(true)
			else
				self.confirmAuctBtn_:setButtonEnabled(false)
			end
			
		else
			self.confirmAuctBtn_:setButtonEnabled(false)

			if tonumber(self.curProdNumString) > self.prodNumHas_ then
				--todo
				self.prodNumTips_:show()
			else
				self.prodNumTips_:hide()
			end
		end

	end
end

function AuctSellProdPopup:onAuctTimeSelectChanged_(evt)
	-- body
	self.timeSelIdx_ = evt.selected
end

function AuctSellProdPopup:onDigitClkCallBack_(evt)
	-- body

	-- 依据显示层次调用下面的代码段 -- 
	if self.digitInputPanel_ then
		--todo
		self.digitInputPanel_:removeFromParent()
		self.digitInputPanel_ = nil

		-- -- 根据需求确定xx数值,预计 tonumber(self.curProdNumString) 应该是10的整数倍  tonumber(self.auctPriString) 在合理范围之内
		-- if tonumber(self.curProdNumString) > 0 and tonumber(self.curProdNumString) % xx == 0 and tonumber(self.auctPriString) > 0 then
		-- 	--todo

		-- 	if self.selectedIdx_ == 2 and tonumber(self.auctPriString) < 10000000 then
		-- 		--todo
		-- 		self.confirmAuctBtn_:setButtonEnabled(false)

		-- 	else
		-- 		self.confirmAuctBtn_:setButtonEnabled(true)
		-- 	end
		-- else
		-- 	self.confirmAuctBtn_:setButtonEnabled(false)
		-- end
		return
	end

	-- if string.len(self.auctPriString) > 0 and tonumber(self.auctPriString) >= nk.userData["aUser.money"] then
	-- 	--todo
	-- 	return
	-- end

	if string.len(self.auctPriString) >= 12 then
		--todo
		return
	end

	local label = evt.target:getButtonLabel()
	local clkNum = label:getString()

	self.auctPriString = self.auctPriString .. clkNum
	self.auctPriceTxt_:setString(bm.formatNumberWithSplit(self.auctPriString))

	if self.auctPriString == "00" then
		--todo
		local curString = string.sub(self.auctPriString, 0, 1)
        self.auctPriString = curString
	end

	-- if tonumber(self.auctPriString) > nk.userData["aUser.money"] then
	-- 	--todo
	-- 	self.auctPriceTxt_:setString(bm.formatNumberWithSplit(nk.userData["aUser.money"]))
	-- 	self.auctPriString = tostring(nk.userData["aUser.money"])
	-- end

	-- -- 根据需求确定xx数值,预计 tonumber(self.curProdNumString) 应该是10的整数倍  tonumber(self.auctPriString) 在合理范围之内
	-- if tonumber(self.curProdNumString) > 0 and tonumber(self.curProdNumString) % xx == 0 and tonumber(self.auctPriString) > 0 then
	-- 	--todo

	-- 	if self.selectedIdx_ == 2 and tonumber(self.auctPriString) < 10000000 then
	-- 		--todo
	-- 		self.confirmAuctBtn_:setButtonEnabled(false)

	-- 	else
	-- 		self.confirmAuctBtn_:setButtonEnabled(true)
	-- 	end
	-- else
	-- 	self.confirmAuctBtn_:setButtonEnabled(false)
	-- end
	local auctPriStart = tonumber(self.auctPriString)
	if self.canAuctionProdList then
		--todo
		if self.prodType_ and tonumber(self.curProdNumString) > 0 and tonumber(self.curProdNumString) <= self.prodNumHas_ then
			--todo
			-- self.prodNumTips_:hide()

			if auctPriStart > 0 then
				--todo
				self.confirmAuctBtn_:setButtonEnabled(true)
			else
				self.confirmAuctBtn_:setButtonEnabled(false)
			end
			
		else
			self.confirmAuctBtn_:setButtonEnabled(false)

			-- if tonumber(self.curProdNumString) > self.prodNumHas_ then
			-- 	--todo
			-- 	self.prodNumTips_:show()
			-- else
			-- 	self.prodNumTips_:hide()
			-- end
		end
	end
	
end

function AuctSellProdPopup:onAuctPriceDelBtnCallBack_()
	-- body
	if self.auctPriString == "0" then
		--todo
		return
	end

	local curLength = string.len(self.auctPriString)
    local curString = string.sub(self.auctPriString, 0, curLength - 1)

    self.auctPriString = curString
    self.auctPriceTxt_:setString(bm.formatNumberWithSplit(self.auctPriString))

    local auctPriStart = tonumber(self.auctPriString)
	if self.canAuctionProdList then
		--todo
		if self.prodType_ and tonumber(self.curProdNumString) > 0 and tonumber(self.curProdNumString) <= self.prodNumHas_ then
			--todo
			-- self.prodNumTips_:hide()

			if auctPriStart > 0 then
				--todo
				self.confirmAuctBtn_:setButtonEnabled(true)
			else
				self.confirmAuctBtn_:setButtonEnabled(false)
			end
			
		else
			self.confirmAuctBtn_:setButtonEnabled(false)

			-- if tonumber(self.curProdNumString) > self.prodNumHas_ then
			-- 	--todo
			-- 	self.prodNumTips_:show()
			-- else
			-- 	self.prodNumTips_:hide()
			-- end
		end
	end
end

function AuctSellProdPopup:onConfirmAuctBtnCallBack_()
	-- body

	-- 作多重判断 :拍卖类型,物品数量,价格合理
	self.confirmAuctBtn_:setButtonEnabled(false)

	if string.len(self.auctPriString) <= 0 then
		--todo
		self.auctPriString = "0"
	end

	if string.len(self.curProdNumString) <= 0 then
		--todo
		self.curProdNumString = "0"
	end

	local auctType = self.selectedIdx_
	-- local prodName = self.prodChooseCombox_:getText()
	local prodNum = tonumber(self.curProdNumString)
	local auctPriStart = tonumber(self.auctPriString)

	-- if auctPriStart == 0 then
	-- 	--todo
	-- 	auctPriStart = 1
	-- end

	-- if auctPriStart <= 0 then
	-- 	--todo
	-- end

	local auctTimeVal = nil
	if not self.timeSelIdx_ then
		--todo
		-- nk.CenterTipManager:showCenterTip({text = "暂未开放拍卖时间设置!", messageType = 1000})

		-- return
		auctTimeVal = 12  -- 默认拍卖时长
	else
		auctTimeVal = self.timeVal[self.timeSelIdx_]
	end
	
	local reqParam = {}
	reqParam.prodType = self.prodType_
	reqParam.num = prodNum
	reqParam.expireTime = auctTimeVal
	reqParam.auctType = auctType
	reqParam.auctStartPrice = auctPriStart

	if auctType == 2 then
		--todo
		-- local userLevelFact = nk.Level:getLevelByExp(nk.userData["aUser.exp"])
		-- if userLevelFact < 10 then
		-- 	--todo
		-- 	nk.CenterTipManager:showCenterTip({text = "满10级才可参与一口价竞拍,请再接再厉", messageType = 1000})

		-- 	return
		-- end
		
		if auctPriStart < 10000000 then
			--todo
			nk.CenterTipManager:showCenterTip({text = bm.LangUtil.getText("AUCTION_MARKET","PRICING_TIP_1"), messageType = 1000})

			self.confirmAuctBtn_:setButtonEnabled(true)
			return
		end

		-- 正常拍卖
		self.controller_:addAuctSellProd(reqParam, function(data)
			-- body
			nk.CenterTipManager:showCenterTip({text = bm.LangUtil.getText("AUCTION_MARKET","PRICING_TIP_5"), messageType = 1000})

			if self and self.hidePanel then
				--todo
				self.controller_:getMyAuctionData()  -- 拉取我的在拍物品，刷新UI

				self:hidePanel()
			end
		end, function(errData)
			-- body

			if errData.errorCode == - 3 then
				--todo
				nk.CenterTipManager:showCenterTip({text = bm.LangUtil.getText("AUCTION_MARKET","PRICING_TIP_6"), messageType = 1000})

				if self and self.hidePanel then
					--todo
					self:hidePanel()
				end
			else
				nk.CenterTipManager:showCenterTip({text = bm.LangUtil.getText("AUCTION_MARKET","PRICING_TIP_7"), messageType = 1000})
				
				self.confirmAuctBtn_:setButtonEnabled(true)
			end
			
		end)

	else
		-- 可参与竞拍！
		self.controller_:addAuctSellProd(reqParam, function(data)
			-- body
			nk.CenterTipManager:showCenterTip({text = bm.LangUtil.getText("AUCTION_MARKET","PRICING_TIP_5"), messageType = 1000})

			if self and self.hidePanel then
				--todo
				self.controller_:getMyAuctionData()
				self:hidePanel()
			end

		end, function(errData)
			-- body
			if errData.errorCode == - 3 then
				--todo
				nk.CenterTipManager:showCenterTip({text = bm.LangUtil.getText("AUCTION_MARKET","PRICING_TIP_6"), messageType = 1000})

				if self and self.hidePanel then
					--todo
					self:hidePanel()
				end
			else
				nk.CenterTipManager:showCenterTip({text = bm.LangUtil.getText("AUCTION_MARKET","PRICING_TIP_7"), messageType = 1000})
			end
		end)
	end
end 

function AuctSellProdPopup:onCloseBtnCallBack_()
	-- body
	self:hidePanel()
end

function AuctSellProdPopup:showPanel()
	-- body
	nk.PopupManager:addPopup(self)
end

function AuctSellProdPopup:onShowed()
	-- body
	if self.prodChooseCombox_ and self.prodChooseCombox_.list_ then
		--todo
		self.prodChooseCombox_.list_:update()
	end
end

function AuctSellProdPopup:hidePanel()
	-- body
	nk.PopupManager:removePopup(self)
end

return AuctSellProdPopup