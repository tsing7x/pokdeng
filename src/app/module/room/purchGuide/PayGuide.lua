--
-- Author: TsingZhang@boyaa.com
-- Date: 2016-07-19 17:40:34
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- Description: PayGuide.lua Design && Modify By TsingZhang.
--

local pg = import(".Init")
local config = import(".Config")
local QuickPurchaseServiceManager = import("app.module.newstore.QuickPurchaseServiceManager")

local PayGuide = class("PayGuide", nk.ui.Panel)
local ChipRechgWareItem = import(".ChipRechgWareItem")
local ChipFrChgWareItem = import(".ChipFrChgWareItem")
local StorePopup = import("app.module.newstore.StorePopup")
local UserCrash = import("app.module.room.userCrash.UserCrash")
local PURCHASE_TYPE = import("app.module.newstore.PURCHASE_TYPE")

-- @param: 
-- param.isOpenThrPartyPay = isThirdPayOpen  -- 第三方开关状态
-- param.isFirstCharge = isFirstCharge  -- 首冲标志
-- param.sceneType = payGuideShownType  -- 显示场景 1:普通推荐(默认), 2:筹码不足, 3:破产
-- param.payListType = payBillType  -- 订单类型 1:初级场推荐(默认), 2:中级场, 3:高级场
-- param.isSellCashCoin = isCashCoinSell  -- 是否快捷支付售出现金币

-- 批注: 由于商城取消了现金币的GooglePlay支付方式,对于参数传递要求如下.
	-- when isSellCashCoin == true isOpenThrPartyPay must be true.
function PayGuide:ctor(param)
	-- body
	self:setNodeEventEnabled(true)
	pg.loadTexture()

	local panelSize = {
		[1] = config.FirstChargePanelParam,
		[2] = config.ReChagePanelParam
	}
	local isCashCoinSell = param.isSellCashCoin
	-- if appconfig.ROOT_CGI_SID == 1 then

	if isCashCoinSell then
		--todo
		local size = panelSize[2]

		PayGuide.super.ctor(self, {size.WIDTH, size.HEIGHT})
	else
		if device.platform == "android" or device.platform == "windows" then
			--todo
			local isThrFirstCharge = param.isFirstCharge and param.isOpenThrPartyPay

			local size = isThrFirstCharge and panelSize[1] or panelSize[2]
			PayGuide.super.ctor(self, {size.WIDTH, size.HEIGHT})

		-- elseif appconfig.ROOT_CGI_SID == 2 then
		elseif device.platform == "ios" then
			--todo
			local size = param.isFirstCharge and panelSize[1] or panelSize[2]

			PayGuide.super.ctor(self, {size.WIDTH, size.HEIGHT})
		end
	end
	
	self:initViews(param)

end

function PayGuide:initViews(param)
	-- body

	local isThrPay, isFirstCharge, sType, billType, isCashCoinSell = param.isOpenThrPartyPay, param.isFirstCharge, param.sceneType, param.payListType, param.isSellCashCoin

	-- if isFirstCharge then
	-- 	--todo
	-- 	isThrPay = true
	-- end

	local UiParam = {}
	UiParam.isOpenThrPartyPay = isThrPay
	UiParam.isFirstCharge = isFirstCharge
	UiParam.sceneType = sType
	UiParam.isCashCoin = isCashCoinSell

	self:drawColorBgAndCloseBtn(UiParam)

	-- init ListViews --
	local containerMagrinBottom = 0
	local container = nil
	
	if self._chipWareListView then
		--todo
		self._chipWareListView:removeFromParent()
		self._chipWareListView = nil
	end

	-- if appconfig.ROOT_CGI_SID == 1 then
	if isCashCoinSell then
		--todo
		containerMagrinBottom = 82

		container = display.newNode()
			:pos(self._colorBg:getContentSize().width / 2, config.RechgListViewParam.HEIGHT / 2 + containerMagrinBottom)
			:addTo(self._colorBg)
		-- ChipGoodsListView --

		self._chipWareListView = bm.ui.ListView.new({viewRect = cc.rect(- config.RechgListViewParam.WIDTH / 2, - config.RechgListViewParam.HEIGHT / 2, config.RechgListViewParam.WIDTH, config.RechgListViewParam.HEIGHT),
			direction = bm.ui.ListView.DIRECTION_VERTICAL}, ChipRechgWareItem)
			:pos(0, 0)
			:addTo(container)
	else
		if device.platform == "android" or device.platform == "windows" then
			--todo
			if isFirstCharge and isThrPay then
				--todo
				containerMagrinBottom = 70

				container = display.newNode()
					:pos(self._colorBg:getContentSize().width / 2, config.FirChgListViewParam.HEIGHT / 2 + containerMagrinBottom)
					:addTo(self._colorBg)
				-- ChipGoodsListView --

				self._chipWareListView = bm.ui.ListView.new({viewRect = cc.rect(- config.FirChgListViewParam.WIDTH / 2, - config.FirChgListViewParam.HEIGHT / 2, config.FirChgListViewParam.WIDTH, config.FirChgListViewParam.HEIGHT),
					direction = bm.ui.ListView.DIRECTION_VERTICAL}, ChipFrChgWareItem)
					:pos(0, 0)
					:addTo(container)
			else
				containerMagrinBottom = 82

				container = display.newNode()
					:pos(self._colorBg:getContentSize().width / 2, config.RechgListViewParam.HEIGHT / 2 + containerMagrinBottom)
					:addTo(self._colorBg)
				-- ChipGoodsListView --

				self._chipWareListView = bm.ui.ListView.new({viewRect = cc.rect(- config.RechgListViewParam.WIDTH / 2, - config.RechgListViewParam.HEIGHT / 2, config.RechgListViewParam.WIDTH, config.RechgListViewParam.HEIGHT),
					direction = bm.ui.ListView.DIRECTION_VERTICAL}, ChipRechgWareItem)
					:pos(0, 0)
					:addTo(container)
			end
		-- elseif appconfig.ROOT_CGI_SID == 2 then
		elseif device.platform == "ios" then
			--todo
			if isFirstCharge then
				--todo
				containerMagrinBottom = 70

				container = display.newNode()
					:pos(self._colorBg:getContentSize().width / 2, config.FirChgListViewParam.HEIGHT / 2 + containerMagrinBottom)
					:addTo(self._colorBg)
				-- ChipGoodsListView --

				self._chipWareListView = bm.ui.ListView.new({viewRect = cc.rect(- config.FirChgListViewParam.WIDTH / 2, - config.FirChgListViewParam.HEIGHT / 2, config.FirChgListViewParam.WIDTH, config.FirChgListViewParam.HEIGHT),
					direction = bm.ui.ListView.DIRECTION_VERTICAL}, ChipFrChgWareItem)
					:pos(0, 0)
					:addTo(container)
			else
				containerMagrinBottom = 82

				container = display.newNode()
					:pos(self._colorBg:getContentSize().width / 2, config.RechgListViewParam.HEIGHT / 2 + containerMagrinBottom)
					:addTo(self._colorBg)
				-- ChipGoodsListView --

				self._chipWareListView = bm.ui.ListView.new({viewRect = cc.rect(- config.RechgListViewParam.WIDTH / 2, - config.RechgListViewParam.HEIGHT / 2, config.RechgListViewParam.WIDTH, config.RechgListViewParam.HEIGHT),
					direction = bm.ui.ListView.DIRECTION_VERTICAL}, ChipRechgWareItem)
					:pos(0, 0)
					:addTo(container)
			end
		end
	end

	self._chipWareListView:addEventListener("ITEM_EVENT", handler(self, self._onItemBuying))

	self._isThrPayOpen = isThrPay
	self._firstChargeFlag = isFirstCharge
	self._billType = billType

	self._isCashCoinSell = isCashCoinSell
end

function PayGuide:drawColorBgAndCloseBtn(UIParam)
	-- body
	-- UiParam.isOpenThrPartyPay = isThrPay
	-- UiParam.isFirstCharge = isFirstCharge
	-- UiParam.sceneType = sType
	-- UiParam.isCashCoin = isCashCoinSell

	local isThirdPay, isFirstCharge, stype, isCashCoinSell = UIParam.isOpenThrPartyPay, UIParam.isFirstCharge, UIParam.sceneType, UIParam.isCashCoin
	-- draw Common Part --
	local colorBgPosYShift = {
		firstChg = 5,
		reChg = 0
	}

	local colorBgSize = {
		firstChg = {
			width = 658,
			height = 348
		},

		reChg = {
			width = 727,
			height = 385
		}
	}

	local closeBtnSize = {
		width = 40,
		height = 40
	}

	local closeBtnMagrinParam = {
		firstChg = {
			top = 15,
			right = 15
		},

		reChg = {
			top = 22,
			right = 18
		}
	}

	local goStroeBtnSize = {
		firstChg = {
			width = 172,
			height = 52
		},

		reChg = {
			width = 190,
			height = 58
		}
	}

	local goStoreBtnMagrin = {
		firstChg = {
			bottom = 12,
			right = 15
		},

		reChg = {
			bottom = 14,
			right = 15
		}
	}

	-- titleBlock --
	local titleBg = nil

	if isCashCoinSell then
		--todo
		local bgPosYShift = colorBgPosYShift.reChg
		local bgSize = colorBgSize.reChg

		self._colorBg = display.newScale9Sprite("#payGuide_colorMapBlue.png", 0, bgPosYShift, cc.size(bgSize.width, bgSize.height))
			:addTo(self)

		local closeBtnMagrin = closeBtnMagrinParam.reChg

		local closeBtn = cc.ui.UIPushButton.new("#payGuide_closeBlue.png", {scale9 = false})
			:pos(config.ReChagePanelParam.WIDTH / 2 - closeBtnMagrin.right - closeBtnSize.width / 2,
				config.ReChagePanelParam.HEIGHT / 2 - closeBtnMagrin.top - closeBtnSize.height / 2)
			:onButtonClicked(buttontHandler(self, self._onCloseBtnCallBack))
			:addTo(self)

		local btnSize = goStroeBtnSize.reChg
		local btnMagrin = goStoreBtnMagrin.reChg
		local btnFrontSize = config.ReChagePanelParam.frontSizes.goStroeBtn

		local goStoreBtn = cc.ui.UIPushButton.new("#payGuide_btnBleL.png", {scale9 = true})
			:setButtonSize(btnSize.width, btnSize.height)
			:setButtonLabel("normal", display.newTTFLabel({text = bm.LangUtil.getText("CPURCHGUIDE", "OTHER_PAY_BILL"), size = btnFrontSize, color = config.ReChagePanelParam.colors.goStroeBtn, align = ui.TEXT_ALIGN_CENTER}))
			:onButtonClicked(buttontHandler(self, self._onGoStoreBtnCallBack))

		goStoreBtn:pos(bgSize.width - btnMagrin.right - btnSize.width / 2, btnMagrin.bottom + btnSize.height / 2)
			:addTo(self._colorBg)

		-- tipsBottom --
		local tipsBottomLableMagrin = {
			left = 25,
			bottom = 32
		}

		local tipsBottom = display.newTTFLabel({text = bm.LangUtil.getText("CPURCHGUIDE", "MTACH_TICKET_USETIP"), size = config.ReChagePanelParam.frontSizes.tipsBottom, color = config.ReChagePanelParam.colors.tipsbottom, align = ui.TEXT_ALIGN_CENTER})
		tipsBottom:pos(tipsBottomLableMagrin.left + tipsBottom:getContentSize().width / 2, tipsBottomLableMagrin.bottom + tipsBottom:getContentSize().height / 2)
			:addTo(self._colorBg)

		local titlePayFlag = nil

		-- 仅作BluePay && GooglePlay 标示UI区分
		if device.platform == "android" or device.platform == "windows" then
			--todo
			local payFlagMagrinLeft = 20
			if isThirdPay then
				--todo
				titleBg = display.newSprite("#payGuide_titleBgFirCharge.png")
				titleBg:pos(titleBg:getContentSize().width / 2, bgSize.height - titleBg:getContentSize().height / 2)
					:addTo(self._colorBg)

				titlePayFlag = display.newSprite("#payGuide_TitleBlPay.png")
				titlePayFlag:pos(titlePayFlag:getContentSize().width / 2 + payFlagMagrinLeft, titleBg:getContentSize().height / 2)
					:addTo(titleBg)
			else
				local titleBgPosXFix = 1
				local titleBgPoxYFix = 0

				titleBg = display.newSprite("#payGuide_titleBgGP.png")

				titleBg:pos(titleBg:getContentSize().width / 2 - titleBgPosXFix, bgSize.height - titleBg:getContentSize().height / 2 - titleBgPoxYFix)
					:addTo(self._colorBg)

				titlePayFlag = display.newSprite("#payGuide_flagGP.png")
				titlePayFlag:pos(titlePayFlag:getContentSize().width / 2 + payFlagMagrinLeft, titleBg:getContentSize().height / 2)
					:addTo(titleBg)
				titlePayFlag:scale(0.8)
			end

		elseif device.platform == "ios" then
			--todo
			titleBg = display.newSprite("#payGuide_titleBgFirCharge.png")
			titleBg:pos(titleBg:getContentSize().width / 2, bgSize.height - titleBg:getContentSize().height / 2)
				:addTo(self._colorBg)
		end
		
		local titlePosXShift = 70
		local title = display.newTTFLabel({text = bm.LangUtil.getText("CPURCHGUIDE", "USE_MATCH_TICKET_REG_PREF"), size = config.ReChagePanelParam.frontSizes.title, color = config.ReChagePanelParam.colors.title, align = ui.TEXT_ALIGN_CENTER})
			:pos(titleBg:getContentSize().width / 2 + titlePosXShift, titleBg:getContentSize().height / 2)
			:addTo(titleBg)

	else
		-- if appconfig.ROOT_CGI_SID == 1 then
		if device.platform == "android" or device.platform == "windows" then
			--todo
			local isThrFirstCharge = isThirdPay and isFirstCharge

			local bgPosYShift = isThrFirstCharge and colorBgPosYShift.firstChg or colorBgPosYShift.reChg
			local bgSize = isThrFirstCharge and colorBgSize.firstChg or colorBgSize.reChg

			-- local colcorBgMap = isFirstCharge and "#payGuide_colorMapBlue.png" or "#payGuide_colorMapLBlue.png"

			self._colorBg = display.newScale9Sprite("#payGuide_colorMapBlue.png", 0, bgPosYShift, cc.size(bgSize.width, bgSize.height))
				:addTo(self)

			if isThirdPay then
				--todo

				if isFirstCharge then
					--todo
					titleBg = display.newSprite("#payGuide_titleBgFirCharge.png")

					titleBg:pos(titleBg:getContentSize().width / 2, bgSize.height - titleBg:getContentSize().height / 2)
						:addTo(self._colorBg)
				else
					-- just do not for changes --

					local titleBgBlockSize = {
						width = 660,
						height = 48
					}

					titleBg = display.newScale9Sprite("#payGuide_titleBgFirCharge.png", 0, 0, cc.size(titleBgBlockSize.width, titleBgBlockSize.height))

					titleBg:pos(titleBg:getContentSize().width / 2, bgSize.height - titleBg:getContentSize().height / 2)
						:addTo(self._colorBg)
				end
				
			else

				local titleBgPosXFix = 1
				local titleBgPoxYFix = 0

				titleBg = display.newSprite("#payGuide_titleBgGP.png")

				titleBg:pos(titleBg:getContentSize().width / 2 - titleBgPosXFix, bgSize.height - titleBg:getContentSize().height / 2 - titleBgPoxYFix)
					:addTo(self._colorBg)
			end

			-- closeBtn --

			local closeBtnMagrin = isThrFirstCharge and closeBtnMagrinParam.firstChg or closeBtnMagrinParam.reChg

			local closeBtn = cc.ui.UIPushButton.new("#payGuide_closeBlue.png", {scale9 = false})
			if isThrFirstCharge then
				--todo
				closeBtn:pos(config.FirstChargePanelParam.WIDTH / 2 - closeBtnMagrin.right - closeBtnSize.width / 2,
						config.FirstChargePanelParam.HEIGHT / 2 - closeBtnMagrin.top - closeBtnSize.height / 2)
					
			else
				closeBtn:pos(config.ReChagePanelParam.WIDTH / 2 - closeBtnMagrin.right - closeBtnSize.width / 2,
						config.ReChagePanelParam.HEIGHT / 2 - closeBtnMagrin.top - closeBtnSize.height / 2)
			end

			closeBtn:onButtonClicked(buttontHandler(self, self._onCloseBtnCallBack))
					:addTo(self)
			
			-- goStoreBtn --

			local btnSize = isThrFirstCharge and goStroeBtnSize.firstChg or goStroeBtnSize.reChg
			local btnMagrin = isThrFirstCharge and goStoreBtnMagrin.firstChg or goStoreBtnMagrin.reChg
			local btnFrontSize = isThrFirstCharge and config.FirstChargePanelParam.frontSizes.goStroeBtn or config.ReChagePanelParam.frontSizes.goStroeBtn

			local goStoreBtn = cc.ui.UIPushButton.new("#payGuide_btnBleL.png", {scale9 = true})
				:setButtonSize(btnSize.width, btnSize.height)
				:setButtonLabel("normal", display.newTTFLabel({text = bm.LangUtil.getText("CPURCHGUIDE", "OTHER_PAY_BILL"), size = btnFrontSize, color = config.FirstChargePanelParam.colors.goStroeBtn, align = ui.TEXT_ALIGN_CENTER}))
				:onButtonClicked(buttontHandler(self, self._onGoStoreBtnCallBack))

			goStoreBtn:pos(bgSize.width - btnMagrin.right - btnSize.width / 2, btnMagrin.bottom + btnSize.height / 2)
				:addTo(self._colorBg)

			-- different Part --
			if isThrFirstCharge then
				--todo
				local tipsBottomLableMagrin = {
					left = 25,
					part1Bottom = 42,
					eachLine = 5,
					eachRow = 8
				}

				local tipsBottomPart1 = display.newTTFLabel({text = bm.LangUtil.getText("CPURCHGUIDE", "CHARGE"), size = config.FirstChargePanelParam.frontSizes.tipsBottom, color = config.FirstChargePanelParam.colors.tipsbottom, align = ui.TEXT_ALIGN_CENTER})
				tipsBottomPart1:pos(tipsBottomLableMagrin.left + tipsBottomPart1:getContentSize().width / 2, tipsBottomLableMagrin.part1Bottom + tipsBottomPart1:getContentSize().height / 2)
					:addTo(self._colorBg)

				local bluePayFlagBottom = display.newTTFLabel({text = "BluePay", size = config.FirstChargePanelParam.frontSizes.tipsBottom, color = config.FirstChargePanelParam.colors.tipsBluePay, algin = ui.TEXT_ALIGN_CENTER})
				bluePayFlagBottom:pos(tipsBottomLableMagrin.left + tipsBottomPart1:getContentSize().width + tipsBottomLableMagrin.eachRow + bluePayFlagBottom:getContentSize().width / 2,
					tipsBottomLableMagrin.part1Bottom + bluePayFlagBottom:getContentSize().height / 2)
					:addTo(self._colorBg)

				local tipsBottomPart2 = display.newTTFLabel({text = bm.LangUtil.getText("CPURCHGUIDE", "CHARGE_ANY_FIRST"), size = config.FirstChargePanelParam.frontSizes.tipsBottom, color = config.FirstChargePanelParam.colors.tipsbottom, align = ui.TEXT_ALIGN_CENTER})
				tipsBottomPart2:pos(tipsBottomLableMagrin.left + tipsBottomPart1:getContentSize().width + bluePayFlagBottom:getContentSize().width + tipsBottomLableMagrin.eachRow * 2 + tipsBottomPart2:getContentSize().width / 2,
					tipsBottomLableMagrin.part1Bottom + tipsBottomPart2:getContentSize().height / 2)
					:addTo(self._colorBg)

				local tipsBottomPart3 = display.newTTFLabel({text = bm.LangUtil.getText("CPURCHGUIDE", "ALWAYS_GET_FIVE_TIMES_REWARD"), size = config.FirstChargePanelParam.frontSizes.tipsBottom, color = config.FirstChargePanelParam.colors.tipsbottom, align = ui.TEXT_ALIGN_CENTER})
				tipsBottomPart3:pos(tipsBottomLableMagrin.left + tipsBottomPart3:getContentSize().width / 2, tipsBottomLableMagrin.part1Bottom - tipsBottomLableMagrin.eachLine - tipsBottomPart3:getContentSize().height / 2)
					:addTo(self._colorBg)

				local titleAndViceTitleLabel = {
					[1] = {
						title = {
							part1 = bm.LangUtil.getText("CPURCHGUIDE", "CHARGE"),
							part2 = bm.LangUtil.getText("CPURCHGUIDE", "FIRST_CHARGE_FAVFIVE_TIMES")
						},

						viceTitle = bm.LangUtil.getText("CPURCHGUIDE", "FAV_ONLY_ONCE")
					},

					[2] = {
						title = bm.LangUtil.getText("CPURCHGUIDE", "CHIPS_NOT_ENOUGH"),
						viceTitle = bm.LangUtil.getText("CPURCHGUIDE", "CHARGE_NOW_FAVFIVE_TIMES")
					},

					[3] = {
						title = bm.LangUtil.getText("CPURCHGUIDE", "BANKRUPT_TIP"),
						viceTitle = bm.LangUtil.getText("CPURCHGUIDE", "CHARGE_NOW_FAVFIVE_TIMES")
					}
				}

				local title = titleAndViceTitleLabel[stype].title
				local viceTitle = titleAndViceTitleLabel[stype].viceTitle

				if stype == 1 then
					--todo
					local titlePart1MagrinLeft = 90
					local titleMagrinEach = 10

					local viceTitleLabelMagrins = {
						right = 60,
						top = 40
					}

					local titlePart1Label = display.newTTFLabel({text = title.part1, size = config.FirstChargePanelParam.frontSizes.title, color = config.FirstChargePanelParam.colors.title, align = ui.TEXT_ALIGN_CENTER})
					titlePart1Label:pos(titlePart1MagrinLeft + titlePart1Label:getContentSize().width / 2, titleBg:getContentSize().height / 2)
						:addTo(titleBg)

					local bluePayFlagTitle = display.newSprite("#payGuide_TitleBlPay.png")
					bluePayFlagTitle:pos(titlePart1MagrinLeft + titlePart1Label:getContentSize().width + titleMagrinEach + bluePayFlagTitle:getContentSize().width / 2,
						titleBg:getContentSize().height / 2)
						:addTo(titleBg)

					local titlePart2Label = display.newTTFLabel({text = title.part2, size = config.FirstChargePanelParam.frontSizes.title, color = config.FirstChargePanelParam.colors.title, align = ui.TEXT_ALIGN_CENTER})
					titlePart2Label:pos(titlePart1MagrinLeft + titlePart1Label:getContentSize().width + bluePayFlagTitle:getContentSize().width + titleMagrinEach * 2 + titlePart2Label:getContentSize().width / 2, titleBg:getContentSize().height / 2)
						:addTo(titleBg)

					local viceTitleLabel = display.newTTFLabel({text = viceTitle, size = config.FirstChargePanelParam.frontSizes.viceTitle, color = config.FirstChargePanelParam.colors.viceTitle, align = ui.TEXT_ALIGN_CENTER})
					viceTitleLabel:pos(bgSize.width - viceTitleLabelMagrins.right - viceTitleLabel:getContentSize().width / 2, bgSize.height - viceTitleLabelMagrins.top - viceTitleLabel:getContentSize().height / 2)
						:addTo(self._colorBg)
				else

					local viceTitleMagrinTop = - 2
					local titleLabel = display.newTTFLabel({text = title, size = config.FirstChargePanelParam.frontSizes.title, color = config.FirstChargePanelParam.colors.title, align = ui.TEXT_ALIGN_CENTER})
						:pos(bgSize.width / 2, titleBg:getContentSize().height / 2)
						:addTo(titleBg)

					local viceTitleLabel = display.newTTFLabel({text = viceTitle, size = config.FirstChargePanelParam.frontSizes.viceTitle, color = config.FirstChargePanelParam.colors.viceTitle, align = ui.TEXT_ALIGN_CENTER})
					viceTitleLabel:pos(bgSize.width / 2, bgSize.height - titleBg:getContentSize().height - viceTitleMagrinTop - viceTitleLabel:getContentSize().height / 2)
						:addTo(self._colorBg)
				end
			else
				local chipsNotEnoughTitleStr = bm.LangUtil.getText("CPURCHGUIDE", "CHIPS_NOT_ENOUGH")
				local bankruptTitleStr = bm.LangUtil.getText("CPURCHGUIDE", "BANKRUPT_TIP")

				local quickChargeForPerferStr = bm.LangUtil.getText("CPURCHGUIDE", "QUICK_CHARGE_FOR_PERFER")
				local chargeNowTipStr = bm.LangUtil.getText("CPURCHGUIDE", "QUICK_CHARGE_FOR_PERFER")

				local getTitleStrByStype = function(senceType)
					-- body
					if senceType == 1 then
						--todo
						return quickChargeForPerferStr
					end

					if senceType == 2 then
						--todo
						return chipsNotEnoughTitleStr
					end

					if senceType == 3 then
						--todo
						return bankruptTitleStr
					end

					return nil
				end

				local titleLabel = display.newTTFLabel({text = getTitleStrByStype(stype), size = config.ReChagePanelParam.frontSizes.title, --[[color = ,]] align = ui.TEXT_ALIGN_CENTER})
					:pos(bgSize.width / 2, titleBg:getContentSize().height / 2)
					:addTo(titleBg)

				if stype ~= 1 then
					--todo
					local viceTitleMagrinTop = 2

					local viceTitleLabel = display.newTTFLabel({text = chargeNowTipStr, size = config.ReChagePanelParam.frontSizes.viceTitle, --[[color = ,]] align = ui.TEXT_ALIGN_CENTER})
					viceTitleLabel:pos(bgSize.width / 2, bgSize.height - titleBg:getContentSize().height - viceTitleMagrinTop - viceTitleLabel:getContentSize().height / 2)
						:addTo(self._colorBg)
				end

				local payFlag = nil
				if isThirdPay then
					--todo
					local payFlagMagrin = {
						left = 15,
						bottom = 22
					}

					payFlag = display.newSprite("#payGuide_flagBP.png")
					payFlag:pos(payFlag:getContentSize().width / 2 + payFlagMagrin.left, payFlag:getContentSize().height / 2 + payFlagMagrin.bottom)
						:addTo(self._colorBg)
				else
					local payFlagMagrin = {
						left = 20,
						bottom = 22
					}

					payFlag = display.newSprite("#payGuide_flagGP.png")
					payFlag:pos(payFlag:getContentSize().width / 2 + payFlagMagrin.left, payFlag:getContentSize().height / 2 + payFlagMagrin.bottom)
						:addTo(self._colorBg)
				end
			end

		-- elseif appconfig.ROOT_CGI_SID == 2 then
		elseif device.platform == "ios" then
			--todo
			local bgSize = isFirstCharge and colorBgSize.firstChg or colorBgSize.reChg

			self._colorBg = display.newScale9Sprite("#payGuide_colorMapBlue.png", 0, bgPosYShift, cc.size(bgSize.width, bgSize.height))
				:addTo(self)

			if isFirstCharge then
				--todo
				titleBg = display.newSprite("#payGuide_titleBgFirCharge.png")

				titleBg:pos(titleBg:getContentSize().width / 2, bgSize.height - titleBg:getContentSize().height / 2)
					:addTo(self._colorBg)
			else
				local titleBgBlockSize = {
					width = 660,
					height = 48
				}

				titleBg = display.newScale9Sprite("#payGuide_titleBgFirCharge.png", 0, 0, cc.size(titleBgBlockSize.width, titleBgBlockSize.height))

				titleBg:pos(titleBg:getContentSize().width / 2, bgSize.height - titleBg:getContentSize().height / 2)
					:addTo(self._colorBg)
			end

			-- closeBtn --

			local closeBtnMagrin = isFirstCharge and closeBtnMagrinParam.firstChg or closeBtnMagrinParam.reChg

			local closeBtn = cc.ui.UIPushButton.new("#payGuide_closeBlue.png", {scale9 = false})
			if isFirstCharge then
				--todo
				closeBtn:pos(config.FirstChargePanelParam.WIDTH / 2 - closeBtnMagrin.right - closeBtnSize.width / 2,
						config.FirstChargePanelParam.HEIGHT / 2 - closeBtnMagrin.top - closeBtnSize.height / 2)
					
			else
				closeBtn:pos(config.ReChagePanelParam.WIDTH / 2 - closeBtnMagrin.right - closeBtnSize.width / 2,
						config.ReChagePanelParam.HEIGHT / 2 - closeBtnMagrin.top - closeBtnSize.height / 2)
			end

			closeBtn:onButtonClicked(buttontHandler(self, self._onCloseBtnCallBack))
					:addTo(self)
			
			-- goStoreBtn --

			local btnSize = isFirstCharge and goStroeBtnSize.firstChg or goStroeBtnSize.reChg
			local btnMagrin = isFirstCharge and goStoreBtnMagrin.firstChg or goStoreBtnMagrin.reChg
			local btnFrontSize = isFirstCharge and config.FirstChargePanelParam.frontSizes.goStroeBtn or config.ReChagePanelParam.frontSizes.goStroeBtn

			local goStoreBtn = cc.ui.UIPushButton.new("#payGuide_btnBleL.png", {scale9 = true})
				:setButtonSize(btnSize.width, btnSize.height)
				:setButtonLabel("normal", display.newTTFLabel({text = bm.LangUtil.getText("CPURCHGUIDE", "OTHER_PAY_BILL"), size = btnFrontSize, color = config.FirstChargePanelParam.colors.goStroeBtn, align = ui.TEXT_ALIGN_CENTER}))
				:onButtonClicked(buttontHandler(self, self._onGoStoreBtnCallBack))

			goStoreBtn:pos(bgSize.width - btnMagrin.right - btnSize.width / 2, btnMagrin.bottom + btnSize.height / 2)
				:addTo(self._colorBg)


			-- bgSize = isFirstCharge and colorBgSize.firstChg or colorBgSize.reChg

			if isFirstCharge then
				-- 首次支付
				--todo
				local tipsBottomMagrins = {
					left = 25,
					bottom = 15
				}
				local tipsFrontSize = 22
				local tipsShownWidth = 360
				local tipsBottom = display.newTTFLabel({text = bm.LangUtil.getText("CPURCHGUIDE", "CHARGE_FIRST_ANYBILL_FOR_DOUBLE_REWARD"), size = tipsFrontSize,
					color = config.FirstChargePanelParam.colors.tipsBottom, dimensions = cc.size(tipsShownWidth, 0), align = ui.TEXT_ALIGN_LEFT})
				-- tipsBottom:setAnchorPoint(ap)
				tipsBottom:pos(tipsBottomMagrins.left + tipsBottom:getContentSize().width / 2, tipsBottomMagrins.bottom + tipsBottom:getContentSize().height / 2)
					:addTo(self._colorBg)

				local getTitleLabelStrByType = {
					[1] = function()
						-- body
						return bm.LangUtil.getText("CPURCHGUIDE", "CHARGE_FIRST_ONLY_DOUBLE_REWARD")
					end,

					[2] = function()
						-- body
						return bm.LangUtil.getText("CPURCHGUIDE", "CHIP_NOT_ENOUGH_FOR_DOUBLE_REWARD")
					end,

					[3] = function()
						-- body
						return bm.LangUtil.getText("CPURCHGUIDE", "BANKRUPT_FOR_DOUBLE_REWARD")
					end
				}

				local title = display.newTTFLabel({text = getTitleLabelStrByType[stype](), size = config.FirstChargePanelParam.frontSizes.title,
					color = config.FirstChargePanelParam.colors.title, ui.TEXT_ALIGN_CENTER})
					:pos(bgSize.width / 2, titleBg:getContentSize().height / 2)
					:addTo(titleBg)

			else
				-- 快捷支付
				local chipsNotEnoughTitleStr = bm.LangUtil.getText("CPURCHGUIDE", "CHIPS_NOT_ENOUGH")
				local bankruptTitleStr = bm.LangUtil.getText("CPURCHGUIDE", "BANKRUPT_TIP")

				local quickChargeForPerferStr = bm.LangUtil.getText("CPURCHGUIDE", "QUICK_CHARGE_FOR_PERFER")
				local chargeNowTipStr = bm.LangUtil.getText("CPURCHGUIDE", "QUICK_CHARGE_FOR_PERFER")

				local getTitleStrByStype = function(senceType)
					-- body
					if senceType == 1 then
						--todo
						return quickChargeForPerferStr
					end

					if senceType == 2 then
						--todo
						return chipsNotEnoughTitleStr
					end

					if senceType == 3 then
						--todo
						return bankruptTitleStr
					end

					return nil
				end

				local titleLabel = display.newTTFLabel({text = getTitleStrByStype(stype), size = config.ReChagePanelParam.frontSizes.title, --[[color = ,]] align = ui.TEXT_ALIGN_CENTER})
					:pos(bgSize.width / 2, titleBg:getContentSize().height / 2)
					:addTo(titleBg)

				if stype ~= 1 then
					--todo
					local viceTitleMagrinTop = 2

					local viceTitleLabel = display.newTTFLabel({text = chargeNowTipStr, size = config.ReChagePanelParam.frontSizes.viceTitle, --[[color = ,]] align = ui.TEXT_ALIGN_CENTER})
					viceTitleLabel:pos(bgSize.width / 2, bgSize.height - titleBg:getContentSize().height - viceTitleMagrinTop - viceTitleLabel:getContentSize().height / 2)
						:addTo(self._colorBg)
				end
			end

		end
	end
	
end

function PayGuide:addBluePayFlag()
	-- body
	local bluePayFlag = display.newSprite("#payGuide_flagPay.png")
	bluePayFlag:pos(self._colorBg:getContentSize().width - bluePayFlag:getContentSize().width / 2, bluePayFlag:getContentSize().height / 2)
		:addTo(self._colorBg)
end

function PayGuide:_onGoStoreBtnCallBack()
	-- body
	self._state = nil
	self:hidePanel_()

	if self._isCashCoinSell then
		--todo
		StorePopup.new(2):showPanel()
	else
		StorePopup.new():showPanel()
	end
end

-- Abandoned! --
function PayGuide:_onMorePayWaysBtnCallBack()
	-- body

	self._state = nil
	self:hidePanel_()

	StorePopup.new():showPanel()
end

function PayGuide:_onCloseBtnCallBack()
	-- body
	-- self._justRemove_ = false
	self:hidePanel_()
end

function PayGuide:loadListItemData()
	-- body
	-- getListData&setData --
	-- @param data : getted!
	if not self._quickPay then
		self._quickPay = QuickPurchaseServiceManager.new()
	end
	
	self._quickPay:setPurchaseCallback(handler(self, self.onPurchaseResultCallBack))
    self._loadingBar = nk.ui.Juhua.new():addTo(self)
	self._quickPay:loadPayConfig(handler(self, self.onLoadPayConfig))
    
	-- self._chipWareListView:setData({{2}, {1}, {4}, {8}, {9}})
end

function PayGuide:setListItemData(itemDatas, state)

	-- body
	if not itemDatas or type(itemDatas) ~= "table" or #itemDatas < 2 then
		--todo
		return
	end

	local data = {}

	local getPayBillByType = nil

	if self._isCashCoinSell then
		--todo
		if #itemDatas < 3 then
			--todo
			-- No ItemData[3]
			return
		end

		data[1] = itemDatas[1]

		data[2] = itemDatas[3]

		data[1].isCashCoin = true
		data[2].isCashCoin = true

		data[2].tag = "hot"

		-- 根据不同平台不同支付类型推荐不同的订单
		-- if device.platform == "android" or device.platform == "windows" then
		-- 	--todo

		-- elseif device.platform == "ios" then
		-- 	--todo

		-- end
	else

		-- if appconfig.ROOT_CGI_SID == 1 then
		if device.platform == "android" or device.platform == "windows" then
			--todo
			if state and self._isThrPayOpen then
				--todo
				if #itemDatas < 3 then
					--todo
					-- No ItemData[3]
					return
				end

				data[1] = itemDatas[1]

				data[2] = itemDatas[3]
				data[2].tag = "hot"
			else

				if self._isThrPayOpen then
					--todo
					getPayBillByType = function(billType)
						-- body
						if billType == nil then
							--todo
							if #itemDatas < 3 then
								--todo
								-- No ItemData[3]
								return
							end

							data[1] = itemDatas[2]

							data[2] = itemDatas[3]
							data[2].tag = "hot"

							-- data[1].thrPayOpen = true
							-- data[2].thrPayOpen = true
							return
						end

						if billType == 1 then
							--todo
							if #itemDatas < 3 then
								--todo
								-- No ItemData[3]
								return
							end

							data[1] = itemDatas[2]

							data[2] = itemDatas[3]
							data[2].tag = "hot"

							-- data[1].thrPayOpen = true
							-- data[2].thrPayOpen = true
							return
						end

						if billType == 2 then
							--todo
							if #itemDatas < 4 then
								--todo
								-- No ItemData[4]
								return
							end

							data[1] = itemDatas[3]

							data[2] = itemDatas[4]
							data[2].tag = "hot"

							-- data[1].thrPayOpen = true
							-- data[2].thrPayOpen = true
							return
						end

						if billType == 3 then
							--todo
							if #itemDatas < 4 then
								--todo
								-- No ItemData[3]
								return
							end

							data[1] = itemDatas[3]

							data[2] = itemDatas[4]
							data[2].tag = "hot"
							
							-- data[1].thrPayOpen = true
							-- data[2].thrPayOpen = true
							return
						end

					end
				else
					getPayBillByType = function(billType)
						-- body
						if billType == nil then
							--todo
							data[1] = itemDatas[1]

							data[2] = itemDatas[2]
							data[2].tag = "hot"

							-- data[1].thrPayOpen = false
							-- data[2].thrPayOpen = false
							return
						end

						if billType == 1 then
							--todo
							data[1] = itemDatas[1]

							data[2] = itemDatas[2]
							data[2].tag = "hot"

							-- data[1].thrPayOpen = false
							-- data[2].thrPayOpen = false
							return
						end

						if billType == 2 then
							--todo
							if #itemDatas < 3 then
								--todo
								-- No ItemData[3]
								return
							end

							data[1] = itemDatas[2]

							data[2] = itemDatas[3]
							data[2].tag = "hot"

							-- data[1].thrPayOpen = false
							-- data[2].thrPayOpen = false
							return
						end

						if billType == 3 then
							--todo
							if #itemDatas < 4 then
								--todo
								-- No ItemData[3]
								return
							end

							data[1] = itemDatas[3]

							data[2] = itemDatas[4]
							data[2].tag = "hot"
							
							-- data[1].thrPayOpen = false
							-- data[2].thrPayOpen = false
							return
						end
					end
				end

				getPayBillByType(self._billType)
			end

		-- elseif appconfig.ROOT_CGI_SID == 2 then
		elseif device.platform == "ios" then
			--todo
			if state then
				--todo
				data[1] = itemDatas[1]

				data[2] = itemDatas[2]
				data[2].tag = "hot"
			else
				getPayBillByType = function(billType)
					-- body
					if billType == nil then
						--todo
						data[1] = itemDatas[1]

						data[2] = itemDatas[2]
						data[2].tag = "hot"

						-- data[1].thrPayOpen = true
						-- data[2].thrPayOpen = true
						return
					end

					if billType == 1 then
						--todo
						data[1] = itemDatas[1]

						data[2] = itemDatas[2]
						data[2].tag = "hot"

						-- data[1].thrPayOpen = true
						-- data[2].thrPayOpen = true
						return
					end

					if billType == 2 then
						--todo
						if #itemDatas < 3 then
							--todo
							-- No ItemData[3]
							return
						end

						data[1] = itemDatas[2]

						data[2] = itemDatas[3]
						data[2].tag = "hot"

						-- data[1].thrPayOpen = true
						-- data[2].thrPayOpen = true
						return
					end

					if billType == 3 then
						--todo
						if #itemDatas < 4 then
							--todo
							-- No ItemData[3]
							return
						end
						data[1] = itemDatas[3]

						data[2] = itemDatas[4]
						data[2].tag = "hot"
						
						-- data[1].thrPayOpen = true
						-- data[2].thrPayOpen = true
						return
					end
				end

				getPayBillByType(self._billType)
			end
		end
	end
	-- data[1].tag = "hot"

	data[1]._idx = 1
	data[2]._idx = 2

	self._chipWareListView:setData(data)
end
	
function PayGuide:onLoadPayConfig(ret, paytypeConfig)
	-- body

	-- dump(paytypeConfig,"PayGuide:onLoadPayConfig")

	if not self._quickPay or not self._loadingBar then
		--todo
		return
	end
	
    if ret == 0 then

    	if self._isCashCoinSell then
    		--todo
    		if device.platform == "android" or device.platform == "windows" then
    			--todo

    			if self._isThrPayOpen then
    				--todo
    				local isServiceAvailable = self._quickPay:isServiceAvailable(PURCHASE_TYPE.BLUE_PAY)
			        local service = self._quickPay:getPurchaseService(PURCHASE_TYPE.BLUE_PAY)

			        if isServiceAvailable and service then
			        	--todo
			        	self._quickPay:loadCashProductList(PURCHASE_TYPE.BLUE_PAY, function(config, isComplete, data)             
			                if isComplete then

			                	if self and self._loadingBar then
			                		--todo
			                		self._loadingBar:removeSelf()
									self._loadingBar = nil
			                	end

								dump(data, "loadCashProductList.data :=====================")
			                	self:setListItemData(data, self._firstChargeFlag)
			                end
			            end)
			        end
    			else
    				local isServiceAvailable = self._quickPay:isServiceAvailable(PURCHASE_TYPE.IN_APP_BILLING)
			        local service = self._quickPay:getPurchaseService(PURCHASE_TYPE.IN_APP_BILLING)

			        if isServiceAvailable and service then
			            self._quickPay:loadCashProductList(PURCHASE_TYPE.IN_APP_BILLING, function(config, isComplete, data)             
			                if isComplete then
			                	
			                	if self and self._loadingBar then
			                		--todo
			                		self._loadingBar:removeSelf()
									self._loadingBar = nil
			                	end

								dump(data, "loadCashProductList.data :=====================")
			                	self:setListItemData(data, self._firstChargeFlag)
			                end
			            end)
			        end
    			end

    		elseif device.platform == "ios" then
    			--todo

    			if self._isThrPayOpen then
    				--todo
    				local isServiceAvailable = self._quickPay:isServiceAvailable(PURCHASE_TYPE.BLUE_PAY)
			        local service = self._quickPay:getPurchaseService(PURCHASE_TYPE.BLUE_PAY)

			        if isServiceAvailable and service then
			            self._quickPay:loadCashProductList(PURCHASE_TYPE.BLUE_PAY, function(config, isComplete, data)             
			                if isComplete then
			                	if self and self._loadingBar then
			                		--todo
			                		self._loadingBar:removeSelf()
									self._loadingBar = nil
			                	end

								dump(data, "loadCashProductList.data :=====================")
			                	self:setListItemData(data, self._firstChargeFlag)
			                end
			            end)
			        end	
    			else
    				local isServiceAvailable = self._quickPay:isServiceAvailable(PURCHASE_TYPE.IN_APP_PURCHASE)
			        local service = self._quickPay:getPurchaseService(PURCHASE_TYPE.IN_APP_PURCHASE)

			        if isServiceAvailable and service then
			            self._quickPay:loadCashProductList(PURCHASE_TYPE.IN_APP_PURCHASE, function(config, isComplete, data)             
			                if isComplete then
			                	if self and self._loadingBar then
			                		--todo
			                		self._loadingBar:removeSelf()
									self._loadingBar = nil
			                	end

								dump(data, "loadCashProductList.data :=====================")
			                	self:setListItemData(data, self._firstChargeFlag)
			                end
			            end)
			        end
    			end
    		end
    	else
    		-- if appconfig.ROOT_CGI_SID == 1 then
	    	if device.platform == "android" or device.platform == "windows" then
	    		--todo
	    		if self._isThrPayOpen then
		    		--todo
		    		local isServiceAvailable = self._quickPay:isServiceAvailable(PURCHASE_TYPE.BLUE_PAY)
			        local service = self._quickPay:getPurchaseService(PURCHASE_TYPE.BLUE_PAY)

			        if isServiceAvailable and service then
			            self._quickPay:loadChipProductList(PURCHASE_TYPE.BLUE_PAY, function(config, isComplete, data)             
			                if isComplete then
			                	if self and self._loadingBar then
			                		--todo
			                		self._loadingBar:removeSelf()
									self._loadingBar = nil
			                	end

								dump(data, "loadCashProductList.data :=====================")
			                	self:setListItemData(data, self._firstChargeFlag)
			                end
			            end)
			        end
		    	else
		    		local isServiceAvailable = self._quickPay:isServiceAvailable(PURCHASE_TYPE.IN_APP_BILLING)
			        local service = self._quickPay:getPurchaseService(PURCHASE_TYPE.IN_APP_BILLING)

			        if isServiceAvailable and service then
			            self._quickPay:loadChipProductList(PURCHASE_TYPE.IN_APP_BILLING, function(config, isComplete, data)             
			                if isComplete then
			                	if self and self._loadingBar then
			                		--todo
			                		self._loadingBar:removeSelf()
									self._loadingBar = nil
			                	end

			                	self:setListItemData(data, self._firstChargeFlag)
			                end
			            end)
			        end

		    	end
		    -- elseif appconfig.ROOT_CGI_SID == 2 then
		    elseif device.platform == "ios" then
		    	--todo

		    	if self._isThrPayOpen then
		    		--todo
		    		local isServiceAvailable = self._quickPay:isServiceAvailable(PURCHASE_TYPE.BLUE_PAY)
			        local service = self._quickPay:getPurchaseService(PURCHASE_TYPE.BLUE_PAY)

			        if isServiceAvailable and service then
			            self._quickPay:loadChipProductList(PURCHASE_TYPE.BLUE_PAY, function(config, isComplete, data)             
			                if isComplete then
			                	if self and self._loadingBar then
			                		--todo
			                		self._loadingBar:removeSelf()
									self._loadingBar = nil
			                	end

			                	self:setListItemData(data, self._firstChargeFlag)
			                end
			            end)
			        end
		    	else
		    		local isServiceAvailable = self._quickPay:isServiceAvailable(PURCHASE_TYPE.IN_APP_PURCHASE)
			        local service = self._quickPay:getPurchaseService(PURCHASE_TYPE.IN_APP_PURCHASE)

			        if isServiceAvailable and service then
			            self._quickPay:loadChipProductList(PURCHASE_TYPE.IN_APP_PURCHASE, function(config, isComplete, data)             
			                if isComplete then
			                	if self and self._loadingBar then
			                		--todo
			                		self._loadingBar:removeSelf()
									self._loadingBar = nil
			                	end

			                	self:setListItemData(data, self._firstChargeFlag)
			                end
			            end)
			        end
		    	end
	    	end
    	end

    else
    	if self and self._loadingBar then
    		--todo
    		self._loadingBar:removeSelf()
			self._loadingBar = nil
    	end
    end
end

function PayGuide:_onItemBuying(evt)
	-- body
	-- 购买方法/快捷支付, 上报数据
	-- function reportData("crash_gostore2","crash gostore2")
	local data = evt.data
	-- dump(data, "onItemBuying.data: ==================")
	-- if appconfig.ROOT_CGI_SID == 1 then
	if device.platform == "android" or device.platform == "windows" then
		--todo
		if self._isThrPayOpen then
			--todo
			self._quickPay:makePurchase(PURCHASE_TYPE.BLUE_PAY, data.pid, data)
		else
			self._quickPay:makePurchase(PURCHASE_TYPE.IN_APP_BILLING, data.pid, data)
		end
	-- elseif appconfig.ROOT_CGI_SID == 2 then
	elseif device.platform == "ios" then
		--todo
		if self._isThrPayOpen then
			--todo
			self._quickPay:makePurchase(PURCHASE_TYPE.BLUE_PAY, data.pid, data)
		else
			self._quickPay:makePurchase(PURCHASE_TYPE.IN_APP_PURCHASE, data.pid, data)
		end
	end

    self._state = nil

    self._loadingBar = nk.ui.Juhua.new(nil, true):addTo(self)
end

function PayGuide:onPurchaseResultCallBack(isSucc, result)
	-- body
	self._loadingBar:removeSelf()
	self._loadingBar = nil

	if isSucc then
		--todo
		nk.userData.best.paylog = 1

		-- 后面有可能会加上现金币购买及现金币购买记录字段,注意修改。
		if self._isCashCoinSell then
			--todo
			dump("CashCoinBillPurchaseResultCallBack!")
		else
			if self._isThrPayOpen then
				--todo
				bm.DataProxy:setData(nk.dataKeys.CHARGEFAV_ONOFF, false)

				-- local isAlmChargeFavPay = nk.userData.bagPayList and nk.userData.bagPayList.almRechgFav == 1 or false
				local rechargeFavAccess = nk.userData.bagPayList and nk.userData.bagPayList.access == 1 or false
				if nk.OnOff:check("rechargeFavGray") and rechargeFavAccess then
					--todo
					bm.DataProxy:setData(nk.dataKeys.ALMRECHARGEFAV_ONOFF, true)
				end
			end

			nk.userData.best.ispay = 1
		end
	end

	self:hidePanel_()
end

-- @Param :state 0.Needed BankRuptPop, nil.None Oper onCleanup, others.ChipNotEnough; 
-- quickPlayHandler.quickPlayFunc; inRoom.isInRoomFlag
function PayGuide:show(state, quickPlayHandler,inRoom)
	-- body
	self._state = state
	self._handler = quickPlayHandler
	self.inRoom_ = inRoom
	self:showPanel_()
end

function PayGuide:onShowed()
	-- body
	if self._chipWareListView then
		--todo
		self._chipWareListView:setScrollContentTouchRect()
	end

	self:loadListItemData()
end

function PayGuide:onEnter()
	-- body
	-- pg.loadTexture()
end

function PayGuide:onExit()
	-- body

	pg.removeTexture()
end

-- end --
function PayGuide:onCleanup()
	-- body

	if self._quickPay then
        self._quickPay:autoDispose()
        self._quickPay = nil
    end

    -- _state = 0,破产补助

    if self._state == nil then
    	--todo

    	return
    end

    if self._state == 0 then
-- 		--todo

		if nk.userData["aUser.bankMoney"] >= nk.userData.bankruptcyGrant.maxsafebox then
            --保险箱的钱大于设定值，引导保险箱取钱
            local userCrash = UserCrash.new(0,0,0,0,true,self.inRoom_)
            userCrash:show()

        else
        	local rewardTime = nk.userData.bankruptcyGrant.bankruptcyTimes + 1
	        local bankruptcyTimes = nk.userData.bankruptcyGrant.bankruptcyTimes
	        local rewardMoney = nk.userData.bankruptcyGrant.money[rewardTime] or 0
	        local limitDay = nk.userData.bankruptcyGrant.day or 1
	        local limitTimes = nk.userData.bankruptcyGrant.num or 0
	        local userCrash = UserCrash.new(bankruptcyTimes,rewardMoney,limitDay,limitTimes)
	        userCrash:show()
        end
	else

		local runningScene = nk.runningScene
		if (not runningScene) or (runningScene.name == nil) or runningScene.name == "RoomScene" then
	         -- _state = 1,搓桌引导
			nk.ui.Dialog.new({
	            hasCloseButton = false,
	            messageText = bm.LangUtil.getText("ROOM", "SIT_DOWN_NOT_ENOUGH_MONEY"), 
	            firstBtnText = bm.LangUtil.getText("ROOM", "AUTO_CHANGE_ROOM"),
	            secondBtnText = bm.LangUtil.getText("ROOM", "CHARGE_CHIPS"), 
	            callback = function (type)
	            if type == nk.ui.Dialog.FIRST_BTN_CLICK then
	            	if self._handler then
	            		--todo
	            		if self._handler == - 1 then
	            			--todo
	            			nk.TopTipManager:showTopTip(bm.LangUtil.getText("HALL", "PERSONAL_ROOM_CANT_CHANGEROOM"))
	            		else
	            			self._handler()
	            		end
	            	else
	            		nk.server:quickPlay()
	            	end
	            elseif type == nk.ui.Dialog.SECOND_BTN_CLICK then
	                	StorePopup.new():showPanel()
	                end
	            end
	    	}):show() 
	    else
	    	nk.ui.Dialog.new({
	            hasCloseButton = true,
	            hasFirstButton = false,
	            messageText = bm.LangUtil.getText("ROOM", "SIT_DOWN_NOT_ENOUGH_MONEY"), 
	            secondBtnText = bm.LangUtil.getText("ROOM", "CHARGE_CHIPS"), 
	            callback = function (type)
	            if type == nk.ui.Dialog.FIRST_BTN_CLICK then
	            	if self._handler then
	            		--todo
	            		self._handler()
	            	else
	            		nk.server:quickPlay()
	            	end
	            elseif type == nk.ui.Dialog.SECOND_BTN_CLICK then
	                	StorePopup.new():showPanel()
	                end
	            end
	    	}):show() 
	    end
		
	end
	-- self._chipWareListView:removeEventListener(listener)
end

return PayGuide