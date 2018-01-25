--
-- Author: TsingZhang@boyaa.com
-- Date: 2015-11-04 10:08:45
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- Description: ComponItem Signature Complement.
--

local LoadGiftController = import("app.module.gift.LoadGiftControl")
local SignInModule = import(".SignInModule")

local SignInSuccPopup = import(".SignInSuccPopup")
local ComponItemParam = {
	WIDTH = 105,
	HEIGHT = 110
}

local rewardType = {
	[1] = "reward/signIn_itemTypeChips.png",
	[2] = "reward/signIn_itemTypeExpression.png",
	[3] = "reward/signIn_itemTypeGoldSeed.png",
	[4] = "reward/signIn_itemTypeSliverSeed.png"
}

local giftNameByType = {
	[1] = function(pid)
		-- body

		-- 固定！
		return bm.LangUtil.getText("STORE", "TITLE_CHIP")
	end,

	[2] = function(pid)
		-- body

		-- 针对不同pnid做出不同的返回,现阶段不用处理！
		-- if pid == ... then
		-- 	--todo
		-- end

		return ""
	end,
		
	[3] = function(pid)
		-- body

		-- 针对不同pnid做出不同的返回,现阶段不用处理！
		-- if pid == ... then
		-- 	--todo
		-- end
		return ""
		-- return bm.LangUtil.getText("STORE", "TITLE_PROP")
	end,
	[4] = function(pid)
		-- body

		-- 针对不同pnid做出不同的返回,现阶段不用处理！
		-- if pid == ... then
		-- 	--todo
		-- end
		return ""
		-- return bm.LangUtil.getText("STORE", "TITLE_PROP")
	end,
	[5] = function(pid)
		-- body

		-- 针对不同pnid做出不同的返回,现阶段不用处理！
		-- if pid == ... then
		-- 	--todo
		-- end

		return bm.LangUtil.getText("CSIGNIN", "SIGNIN_GIFT")
	end,

	[6] = function(pid)
		-- body

		-- 针对不同pnid做出不同的返回,现阶段不用处理！
		-- if pid == ... then
		-- 	--todo
		-- end

		return bm.LangUtil.getText("CSIGNIN", "SIGNIN_GIFT")
	end,
	[7] = function(pid)
		-- body

		-- 针对不同pnid做出不同的返回,现阶段不用处理！
		-- if pid == ... then
		-- 	--todo
		-- end

		return bm.LangUtil.getText("CSIGNIN", "SIGNIN_GIFT")
	end
}

local function isGiftByType(giftType)
	-- body
	if giftType > 4 then
		--todo
		return true
	end

	return false
end

local function getDescColorByType(signState, isSpecialGift)
	-- body
	if isSpecialGift then
		--todo
		return cc.c3b(5, 5, 5)
	end

	-- 已签 --
	if signState == 0 then
		--todo
		return cc.c3b(87, 142, 1)
		-- return cc.c3b(68, 111, 0)
	end

	-- 待签 --
	if signState == 1 then
		--todo
		return display.COLOR_WHITE
	end

	-- 未签 --
	if signState == 2 then
		--todo
		return cc.c3b(92, 195, 254)
	end

	return display.COLOR_BLACK
end

local ComponItem = class("ComponItem", function()
	-- body
	return display.newNode()
end)

function ComponItem:ctor(itemData, todayIndex)
	-- body

	self._idx = itemData._idx
	self._todayIdx = todayIndex

	self._giftType = itemData.type
	self._pid = itemData.pnid
	self._rewardNum = itemData.num

	self._giftImgUrl = nil
	self._isCanSignIn = false

	self:setTouchEnabled(true)
	self:setNodeEventEnabled(true)
	-- self:setTouchSwallowEnabled(false)
	self:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self._onItemTouched))

	self._itemBorderBg = display.newSprite("#signIn_rewBg_toSign.png")
		:pos(ComponItemParam.WIDTH / 2, ComponItemParam.HEIGHT / 2)
		:addTo(self)

	local itemRewardImgPosYAdjust = 5
	self._itemRewardTypeImg = display.newSprite("#reward/signIn_itemTypeChips.png")
		:pos(ComponItemParam.WIDTH / 2, ComponItemParam.HEIGHT / 2 - itemRewardImgPosYAdjust)
		:addTo(self)

	local function getQuantiFactByTypeAndPid(rwType, pid)
		-- body

		if isGiftByType(rwType) then
			--todo
			return bm.LangUtil.getText("GIFT", "DATA_LABEL")
		end

		if rwType == 2 then
			--todo

			-- 后续处理 --
			-- if pid then
			-- 	--todo
			-- end
			return bm.LangUtil.getText("WHEEL", "TIME")
		end

		if rwType == 3 or rwType == 4 then
			--todo

			-- 后续处理 --
			-- if pid then
			-- 	--todo
			-- end
			return bm.LangUtil.getText("GIFT", "DATA_LABEL_NUM")
		end

		return ""
	end

	local descFrontSize = 15
	local descLabelMagrinTop = 5

	if isGiftByType(self._giftType) then
		--todo
		self._rewardNum = itemData.num * 7
	end
	local itemDescLabelCont = giftNameByType[self._giftType](itemData.pnid)

	if itemDescLabelCont == "" then
		--todo
		self._itemDescLabel = display.newTTFLabel({text = tostring(self._rewardNum) .. " " .. getQuantiFactByTypeAndPid(self._giftType, itemData.pnid), size = descFrontSize, align = ui.TEXT_ALIGN_CENTER})
	else
		self._itemDescLabel = display.newTTFLabel({text = itemDescLabelCont .. "*" .. self._rewardNum .. getQuantiFactByTypeAndPid(self._giftType, itemData.pnid), size = descFrontSize, align = ui.TEXT_ALIGN_CENTER})
	end
	self._itemDescLabel:pos(ComponItemParam.WIDTH / 2, ComponItemParam.HEIGHT - self._itemDescLabel:getContentSize().height / 2 - descLabelMagrinTop)
		:addTo(self)

	if self._giftType == 1 then
		--todo
		self._itemDescLabel:setString(tostring(self._rewardNum) .. giftNameByType[self._giftType](itemData.pnid))
	end

	if self._idx <= self._todayIdx then
		--todo

		if not itemData._isSigned then
			--todo
			self._isCanSignIn = true

			if isGiftByType(itemData.type) then
				--todo

				if itemData.type == 5 then
					--todo
					self._itemBorderBg:setSpriteFrame(display.newSpriteFrame("signIn_rewBg_canSignV.png"))
					self._itemDescLabel:setTextColor(getDescColorByType(1, true))
				else
					self._itemBorderBg:setSpriteFrame(display.newSpriteFrame("signIn_rewBg_canSign.png"))
					self._itemDescLabel:setTextColor(getDescColorByType(1, false))
				end

				-- self._itemDescLabel:setString(giftNameByType[self._giftType](itemData.pnid))
				self.giftImageLoaderId_ = nk.ImageLoader:nextLoaderId()
				LoadGiftController:getInstance():getGiftUrlById(itemData.pnid, handler(self, self._onGiftUrlGetCallBack))
				-- self._itemRewardTypeImg:setSpriteFrame(display.newSpriteFrame(".png"))
			else
				self._itemBorderBg:setSpriteFrame(display.newSpriteFrame("signIn_rewBg_canSign.png"))
				self._itemRewardTypeImg:setSpriteFrame(display.newSpriteFrame(rewardType[itemData.type]))
				self._itemDescLabel:setTextColor(getDescColorByType(1, false))
			end
		else
			if isGiftByType(itemData.type) then
				--todo

				if itemData.type == 5 then
					--todo
					self._itemBorderBg:setSpriteFrame(display.newSpriteFrame("signIn_rewBg_signedV.png"))
					self._itemDescLabel:setTextColor(getDescColorByType(0, true))
				else
					self._itemBorderBg:setSpriteFrame(display.newSpriteFrame("signIn_rewBg_signed.png"))
					self._itemDescLabel:setTextColor(getDescColorByType(0, false))
				end

				-- self._itemDescLabel:setString(giftNameByType[self._giftType](itemData.pnid))
				self.giftImageLoaderId_ = nk.ImageLoader:nextLoaderId()
				LoadGiftController:getInstance():getGiftUrlById(itemData.pnid, handler(self, self._onGiftUrlGetCallBack))
				-- self._itemRewardTypeImg:setSpriteFrame(display.newSpriteFrame(".png"))
			else
				self._itemBorderBg:setSpriteFrame(display.newSpriteFrame("signIn_rewBg_signed.png"))
				self._itemRewardTypeImg:setSpriteFrame(display.newSpriteFrame(rewardType[itemData.type]))
				self._itemDescLabel:setTextColor(getDescColorByType(0, false))
			end
		end
	else

		if isGiftByType(itemData.type) then
			--todo

			if itemData.type == 5 then
				--todo
				self._itemBorderBg:setSpriteFrame(display.newSpriteFrame("signIn_rewBg_toSignV.png"))
				self._itemDescLabel:setTextColor(getDescColorByType(2, true))
			else
				self._itemBorderBg:setSpriteFrame(display.newSpriteFrame("signIn_rewBg_toSign.png"))
				self._itemDescLabel:setTextColor(getDescColorByType(2, false))
			end

			-- self._itemDescLabel:setString(giftNameByType[self._giftType](itemData.pnid))
			self.giftImageLoaderId_ = nk.ImageLoader:nextLoaderId()
			LoadGiftController:getInstance():getGiftUrlById(itemData.pnid, handler(self, self._onGiftUrlGetCallBack))
			-- self._itemRewardTypeImg:setSpriteFrame(display.newSpriteFrame(".png"))
		else
			self._itemBorderBg:setSpriteFrame(display.newSpriteFrame("signIn_rewBg_toSign.png"))
			self._itemRewardTypeImg:setSpriteFrame(display.newSpriteFrame(rewardType[itemData.type]))
			self._itemDescLabel:setTextColor(getDescColorByType(2, false))
		end

	end

	
end

function ComponItem:_onItemTouched()
	-- body
	if self._isCanSignIn then
		--todo

		if self.signInTodayId_ then
			--todo
			return
		end
		self.signInTodayId_ = nk.http.signInTodayNew(function(data)
			-- body
			-- dump(data, "signInTodayNew.data :===============")
			self.signInTodayId_ = nil

			if data.money then
				--todo
				local addedMoney = data.addmoney
				-- nk.userData["aUser.money"] = data.money
				nk.userData["aUser.money"] = nk.userData["aUser.money"] + addedMoney
			end

			if data.pnid then
				--todo
				local giftId = data.pnid
				local giftUseTimeLimit = data.num
				-- 更新互动道具 --

				if isGiftByType(self._giftType) then
					--todo
					nk.userData["aUser.gift"] = giftId
				else

					if self._giftType == 2 then
						--todo
						nk.userData.hddjNum = nk.userData.hddjNum + giftUseTimeLimit
					end
				end
				-- nk.userData.hddjNum = data.propNum
			end

			self._isCanSignIn = false

			self:showSignInSuccTipsPanel()

			self:alterSignInStateUiToday()

			SignInModule.alterSignInDataByDayIdx(self._idx)

			bm.DataProxy:setData(nk.dataKeys.HALL_SIGNIN_NEW, false)

			-- local signInList = SignInModule.getSignInDataList()

			-- dump(signInList, "signInList Alter: ===============")
		end,
		function(errData)
			-- body
			self.signInTodayId_ = nil
			dump("signInTodayNew.errData :=================")
			if errData.code == - 2 then
				--todo
				dump("Already Signed Today!")
			end
		end)
	end
end

function ComponItem:_onGiftUrlGetCallBack(imageUrl)
	-- body
	if imageUrl ~= nil and imageUrl ~= "" then
		--todo
		self._giftImgUrl = imageUrl
		nk.ImageLoader:loadAndCacheImage(self.giftImageLoaderId_, imageUrl, handler(self, self._onGiftImgDownLoadComlete), 
	             	nk.ImageLoader.CACHE_TYPE_GIFT)
	else
		dump("Get giftUrl Wrong!")
	end
	
end

function ComponItem:_onGiftImgDownLoadComlete(success, sprite)
	-- body
	local giftShownSize = {
		width = 60,
		height = 60
	}
	if success then
		--todo
		local texture = sprite:getTexture()
		local texSize = texture:getContentSize()

		self._itemRewardTypeImg:setTexture(texture)
		self._itemRewardTypeImg:setTextureRect(cc.rect(0, 0, texSize.width, texSize.height))
        self._itemRewardTypeImg:setScaleX(giftShownSize.width / texSize.width)
        self._itemRewardTypeImg:setScaleY(giftShownSize.height / texSize.height)
		
	else
		dump("_onGiftImgDownLoadComlete wrong!")
	end
	
end

function ComponItem:showSignInSuccTipsPanel()
	-- body
	local signInSuccTipsParam = {}

	signInSuccTipsParam.giftImgUrl = self._giftImgUrl
	signInSuccTipsParam.rewardType = self._giftType
	signInSuccTipsParam.pid = self._pid
	signInSuccTipsParam.rewardNum = self._rewardNum

	SignInSuccPopup.new(signInSuccTipsParam):show()
end

function ComponItem:alterSignInStateUiToday()
	-- body
	if isGiftByType(self._giftType) then
		--todo

		if self._giftType == 5 then
			--todo
			self._itemBorderBg:setSpriteFrame(display.newSpriteFrame("signIn_rewBg_signedV.png"))
		else
			self._itemBorderBg:setSpriteFrame(display.newSpriteFrame("signIn_rewBg_signed.png"))
			self._itemDescLabel:setTextColor(getDescColorByType(0, false))
		end
		
	else
		self._itemBorderBg:setSpriteFrame(display.newSpriteFrame("signIn_rewBg_signed.png"))
		self._itemDescLabel:setTextColor(getDescColorByType(0, false))
	end
	
end

function ComponItem:onExit()
	-- body
	-- self:stopAction(self._hideSucc.panelAction)

	if self.giftImageLoaderId_ then
		--todo
		nk.ImageLoader:cancelJobByLoaderId(self.giftImageLoaderId_)
	end

	if self.signInTodayId_ then
		--todo
		nk.http.cancel(self.signInTodayId_)
	end
	
end

return ComponItem