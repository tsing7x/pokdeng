local config = import(".Config")

local PromotActModule = import(".PromotActModule")
local GameDlPopup = import(".GameDLTipPopup")

local PromotItem = class("PromotItem", function()
	-- body
	return display.newNode()
end)

-- @param : {finishNum = type(number), state = type(number) >>1：可领取, 0: 未完成条件不可领取 }
function PromotItem:ctor(isClaimed, index, param)
	-- body

	self:setNodeEventEnabled(true)

	self._idx = index

	if isClaimed then
		--todo
		local claimedChip = display.newSprite("#prom_unactiveChip_".. index .. ".png")
			:addTo(self)
 
		local claimedFlag = display.newSprite("#prom_flag.png")
			-- :pos(0, 0)
			:addTo(self)
	else
		local unClaimedChipBg = display.newSprite("#prom_bgChip.png")
			:addTo(self)

		local getTitleByIdx = {
			[1] = function()
				-- body
				return bm.LangUtil.getText("CUNIONACT", "TASK_ONGOING")
			end,

			[2] = function()
				-- body
				if param then
					--todo
					return tostring(param.finishNum) .. "/30"
				else
					return "0/30"
				end
				
			end,

			[3] = function()
				-- body
				if param then
					--todo
					return tostring(param.finishNum) .. "/2"
				else
					return "0/2"
				end
			end
		}

		local titleMagrinTop = 20

		local chipTitle = display.newTTFLabel({text = getTitleByIdx[index](), size = config.ChipItemParam.frontSizes.title,
				color = config.ChipItemParam.colors.title, align = ui.TEXT_ALIGN_CENTER})
		chipTitle:pos(config.ChipItemParam.WIDTH / 2, config.ChipItemParam.HEIGHT - titleMagrinTop - chipTitle:getContentSize().height / 2)
			:addTo(unClaimedChipBg)

		local diamondMagrin = {
			top = 80,
			left = 45
		}

		local diamond = display.newSprite("#prom_diam.png")
			:pos(diamondMagrin.left, config.ChipItemParam.HEIGHT - diamondMagrin.top)
			:addTo(unClaimedChipBg)

		local chipIdxLabelPosFix = {
			x = 3,
			y = 0
		}

		local chipIdx = display.newTTFLabel({text = tostring(index), size = config.ChipItemParam.frontSizes.chipNum,
			color = config.ChipItemParam.colors.chipNum, align = ui.TEXT_ALIGN_CENTER})
			:pos(diamond:getContentSize().width / 2 - chipIdxLabelPosFix.x, diamond:getContentSize().height / 2 - chipIdxLabelPosFix.y)
			:addTo(diamond)

		local labelShownWidth = 125

		local labelCont = {
			[1] = function()
				-- body
				-- 针对是否已经安装做出判断: 1/1<已安装>,0/1<未安装>
				local isAppInstalled = PromotActModule._appInstallState

				-- just for test --
				-- isAppInstalled = true
				-- end --

				self._isAppInstalled = isAppInstalled

				if isAppInstalled then
					--todo
					return bm.LangUtil.getText("CUNIONACT", "INSTALL_GAME_TIPS", "1/1")
				end

				return bm.LangUtil.getText("CUNIONACT", "INSTALL_GAME_TIPS", "0/1")
			end,

			[2] = function()
				-- body
				return bm.LangUtil.getText("CUNIONACT", "GAME_PLAYROUND_TIPS", getTitleByIdx[2]()) 
			end,

			[3] = function()
				-- body
				return bm.LangUtil.getText("CUNIONACT", "GAME_INVITE_TIPS", getTitleByIdx[3]())
			end
		}
		local descLabelMagrin = {
			left = 0,
			top = 80
		}

		local descLable = display.newTTFLabel({text = labelCont[index](), dimensions = cc.size(labelShownWidth, 0),
			size = config.ChipItemParam.frontSizes.desc, color = config.ChipItemParam.colors.desc, align = ui.TEXT_ALIGN_LEFT})
		descLable:setAnchorPoint(display.ANCHOR_POINTS[display.LEFT_CENTER])
		descLable:pos(diamondMagrin.left + diamond:getContentSize().width / 2 + descLabelMagrin.left, config.ChipItemParam.HEIGHT - descLabelMagrin.top)
			:addTo(unClaimedChipBg)

		local appIconMagrin = {
			left = 15,
			top = 165
		}

		local appIcon = nil
		if index == 1 then
			--todo
			appIcon = display.newSprite("#prom_gameDown.png")
		else
			appIcon = display.newSprite("#prom_icGame.png")
		end

		appIcon:pos(appIconMagrin.left + appIcon:getContentSize().width / 2, config.ChipItemParam.HEIGHT - appIconMagrin.top)
			:addTo(unClaimedChipBg)

		local BtnFrontDimensions = {
			width = 70,
			height = 35
		}

		local appBtnParam = {
			width = 55,
			magrinRight = 30,
			posYFix = 5
		}

		local appActionBtn = nil

		if index == 1 then
			--todo
			if self._isAppInstalled then 
				appActionBtn = cc.ui.UIPushButton.new("#prom_btnGrey.png", {scale9 = false})
			else
				--todo
				appActionBtn = cc.ui.UIPushButton.new("#prom_btnGreen.png", {scale9 = false})
			end
		else

			if param.state == 2 or param.state == 3 then
				--todo
				appActionBtn = cc.ui.UIPushButton.new("#prom_btnGreen.png", {scale9 = false})
				self._isAppActionActive = true
			else
				appActionBtn = cc.ui.UIPushButton.new("#prom_btnGrey.png", {scale9 = false})
				self._isAppActionActive = false
			end
			
			
		end
		appActionBtn:onButtonClicked(buttontHandler(self, self._onAppActionCallBack))
			:pos(config.ChipItemParam.WIDTH - appBtnParam.magrinRight - appBtnParam.width / 2, config.ChipItemParam.HEIGHT - appIconMagrin.top - appBtnParam.posYFix)
			:addTo(unClaimedChipBg)

		local actionTips = {
			[1] = function()
				-- body
				if self._isAppInstalled then
					--todo
					return bm.LangUtil.getText("CUNIONACT", "HAS_DOWNLOAD")
				end
				return bm.LangUtil.getText("CUNIONACT", "GAME_DOWNLOAD_GOOGLEPLAY_HINT")
			end,

			[2] = function()
				-- body
				return bm.LangUtil.getText("CUNIONACT", "GAME_ENTER_HINT")
			end,

			[3] = function()
				-- body
				return bm.LangUtil.getText("CUNIONACT", "GAME_ENTER_HINT")
			end
		}

		local tipsShownPosYFix = 10
		local appActionBtnTips = display.newTTFLabel({text = actionTips[index](), dimensions = cc.size(BtnFrontDimensions.width, BtnFrontDimensions.height), 
			size = config.ChipItemParam.frontSizes.claimBtn, align = ui.TEXT_ALIGN_CENTER})
			:pos(0, tipsShownPosYFix)
			:addTo(appActionBtn)

		local giftBoxMagrinTop = 250
		local giftBoxPosXFix = 5
		local giftBox = display.newSprite("#prom_giftBox.png")
		giftBox:pos(appIconMagrin.left + giftBox:getContentSize().width / 2 + giftBoxPosXFix, config.ChipItemParam.HEIGHT - giftBoxMagrinTop)
			:addTo(unClaimedChipBg)

		local giftGetBtnMagrinTop = 245

		local giftGetBtn = nil

		if param.state == 3 then
			--todo
			giftGetBtn = cc.ui.UIPushButton.new("#prom_btnGreen.png", {scale9 = false})
			self._isCanGiftGet = true
		else
			if self._isAppInstalled then
				--todo
				if param.state == 4 then
					--todo
					giftGetBtn = cc.ui.UIPushButton.new("#prom_btnGrey.png", {scale9 = false})
					self._isCanGiftGet = true
				else
					giftGetBtn = cc.ui.UIPushButton.new("#prom_btnGreen.png", {scale9 = false})
					self._isCanGiftGet = true
				end
				
			else
				giftGetBtn = cc.ui.UIPushButton.new("#prom_btnGrey.png", {scale9 = false})
				self._isCanGiftGet = false
			end
			
		end

		giftGetBtn:onButtonClicked(buttontHandler(self, self._onGiftGetCallBack))
			:pos(config.ChipItemParam.WIDTH - appBtnParam.magrinRight - appBtnParam.width / 2, config.ChipItemParam.HEIGHT - giftGetBtnMagrinTop)
			:addTo(unClaimedChipBg)

		local giftGetBtnTips = display.newTTFLabel({text = bm.LangUtil.getText("CUNIONACT", "GET_IMMEDIATELY"), size = config.ChipItemParam.frontSizes.claimBtn, align = ui.TEXT_ALIGN_CENTER})
			:pos(0, tipsShownPosYFix)
			:addTo(giftGetBtn)
	end
end

function PromotItem:_onAppActionCallBack()
	-- body

	if self._idx == 1 then
		--todo

		-- just for test GameDlPopup --
		-- self._isAppInstalled = false
		-- end --

		if not self._isAppInstalled then
			--todo
			GameDlPopup.new():show()
		end
	else

		if self._isAppActionActive then
			--todo
			nk.Native:launchApp(config.NinekeGamePackageName)
			-- 关闭所有弹窗 -- 
			nk.PopupManager:removeAllPopup()
		end
	end

end

function PromotItem:_onGiftGetCallBack()
	-- body
	if self._isCanGiftGet then
		--todo
		local state = self._isAppInstalled and 2 or 1

		local getSvrInterfaceByChipIdx = {
			[1] = nk.http.claimUnionActRewardOne,

			[2] = nk.http.claimUnionActRewardTwo,

			[3] = nk.http.claimUnionActRewardThree
		}

		local getRewardSuccTopTips = bm.LangUtil.getText("CUNIONACT", "GET_REWARD_SUCC_TIPS")

		local claimChipRewardById = nil
		if self._idx == 1 then
			--todo
			claimChipRewardById = getSvrInterfaceByChipIdx[self._idx](state,
				function(data)
					-- body

					dump(data, "claimUnionActReward" .. self._idx .. ".data :========================")

					-- 记录修改的金钱，互动道具 的值
					nk.userData["aUser.money"] = data.money
					nk.userData.hddjNum = data.propNum

					nk.TopTipManager:showTopTip(getRewardSuccTopTips[self._idx])
					PromotActModule.getDataListSvr()
				end,

				function(errData)
					-- body
					dump(errData, "claimUnionActReward" .. self._idx .. ".errData :======================")

					-- 发出消息 >>弹出提示：领取失败，请重试

					nk.TopTipManager:showTopTip(bm.LangUtil.getText("CUNIONACT", "GET_REWARD_FAILED"))
				end)
		else
			claimChipRewardById = getSvrInterfaceByChipIdx[self._idx](
				function(data)
					-- body

					dump(data, "claimUnionActReward" .. self._idx .. ".data :========================")

					nk.userData["aUser.money"] = data.money
					nk.TopTipManager:showTopTip(getRewardSuccTopTips[self._idx])
					PromotActModule.getDataListSvr()
				end,

				function(errData)
					-- body
					dump(errData, "claimUnionActReward" .. self._idx .. ".errData :======================")

					nk.TopTipManager:showTopTip(bm.LangUtil.getText("CUNIONACT", "GET_REWARD_FAILED"))
				end)
		end

		return 
	end
end

function PromotItem:onExit()
	-- body
	-- remove eventListener -- 
end

return PromotItem