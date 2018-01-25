--
-- Author: TsingZhang@boyaa.com
-- Date: 2015-11-04 10:11:03
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- Description: SignInSuccPopup Signature Complement.
--

local panel = nk.ui.Panel

local SignInSuccPanelParam = {
	WIDTH = 415,
	HEIGHT = 240
}

local rewardType = {
	[1] = "reward/signIn_itemTypeChips.png",
	[2] = "reward/signIn_itemTypeExpression.png",
	[3] = "reward/signIn_itemTypeGoldSeed.png",
	[4] = "reward/signIn_itemTypeSliverSeed.png"
}

local SignInSuccPopup = class("SignInSuccPopup", panel)

function SignInSuccPopup:ctor(param)
	-- body
	self.super.ctor(self, {SignInSuccPanelParam.WIDTH, SignInSuccPanelParam.HEIGHT})
	self:setNodeEventEnabled(true)
	self:addCloseBtn()

	self:drawMainDescBlock(param)
end

function SignInSuccPopup:drawMainDescBlock(params)
	-- body
	local url = params.giftImgUrl
	local gType = params.rewardType
	local pid = params.pid
	local num = params.rewardNum

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

			return bm.LangUtil.getText("STORE", "TITLE_PROP")
		end,
			
		[3] = function(pid)
			-- body

			-- 针对不同pnid做出不同的返回,现阶段不用处理！
			-- if pid == ... then
			-- 	--todo
			-- end

			return bm.LangUtil.getText("DORNUCOPIA", "GOLD_SEED")
		end,
		[4] = function(pid)
			-- body

			-- 针对不同pnid做出不同的返回,现阶段不用处理！
			-- if pid == ... then
			-- 	--todo
			-- end

			return bm.LangUtil.getText("DORNUCOPIA", "SILVER_SEED")
		end,
		[5] = function(pid)
			-- body

			-- 针对不同pnid做出不同的返回,现阶段不用处理！
			-- if pid == ... then
			-- 	--todo
			-- end

			return bm.LangUtil.getText("CSIGNIN", "OP") .. bm.LangUtil.getText("CSIGNIN", "SIGNIN_GIFT_SPEC")
		end,

		[6] = function(pid)
			-- body

			-- 针对不同pnid做出不同的返回,现阶段不用处理！
			-- if pid == ... then
			-- 	--todo
			-- end

			return bm.LangUtil.getText("CSIGNIN", "SIGNIN_GIFT") .. bm.LangUtil.getText("CSIGNIN", "GIFT_CROWN")
		end,
		[7] = function(pid)
			-- body

			-- 针对不同pnid做出不同的返回,现阶段不用处理！
			-- if pid == ... then
			-- 	--todo
			-- end

			return bm.LangUtil.getText("CSIGNIN", "SIGNIN_GIFT") .. bm.LangUtil.getText("CSIGNIN", "GIFT_WEALTH")
		end
	}

	local function isSpecialGiftByType(giftType)
		-- body
		if giftType > 4 then
			--todo
			return true
		end

		return false
	end


	local function getQuantiFactByTypeAndPid(rwType, pid)
		-- body

		if isSpecialGiftByType(rwType) then
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

	local rewardImgPosYShift = 30

	self._rewardImg = display.newSprite("#reward/signIn_itemTypeChips.png")
		:pos(0, rewardImgPosYShift)
		:addTo(self)

	if isSpecialGiftByType(gType) then
		--todo
		self._giftImageLoaderId = nk.ImageLoader:nextLoaderId()
		nk.ImageLoader:loadAndCacheImage(self._giftImageLoaderId, url, handler(self, self._onGiftImgLoadCallBack), 
	             	nk.ImageLoader.CACHE_TYPE_GIFT)
	else
		self._rewardImg:setSpriteFrame(display.newSpriteFrame(rewardType[gType]))
	end

	local descLabelFrontSize = 28
	local descLabelMagrinBottom = 20
	local descColor = cc.c3b(121, 145, 177)
	local descLabelShownWidth = 390

	local descLabel = display.newTTFLabel({text = bm.LangUtil.getText("CSIGNIN", "SUCC_SIGNIN_AND_GET") .. giftNameByType[gType]() .. " " .. num .. " " .. getQuantiFactByTypeAndPid(gType), size = descLabelFrontSize, dimensions = cc.size(descLabelShownWidth, 0), color = descColor, align = ui.TEXT_ALIGN_CENTER})
	descLabel:pos(0, - SignInSuccPanelParam.HEIGHT / 2 + descLabel:getContentSize().height / 2 + descLabelMagrinBottom)
		:addTo(self)

	if gType == 1 then
		--todo
		descLabel:setString(bm.LangUtil.getText("CSIGNIN", "SUCC_SIGNIN_AND_GET") .. " " .. num .. " " .. giftNameByType[gType]())
	end
end

function SignInSuccPopup:_onGiftImgLoadCallBack(success, sprite)
	-- body
	local giftShownSize = {
		width = 60,
		height = 60
	}
	if success then
		--todo
		local texture = sprite:getTexture()
		local texSize = texture:getContentSize()

		self._rewardImg:setTexture(texture)
		self._rewardImg:setTextureRect(cc.rect(0, 0, texSize.width, texSize.height))
        self._rewardImg:setScaleX(giftShownSize.width / texSize.width)
        self._rewardImg:setScaleY(giftShownSize.height / texSize.height)
		
	else
		dump("_onGiftImgDownLoadComlete wrong!")
	end
end

function SignInSuccPopup:show()
	-- body
	self:showPanel_()

	self._hidePanelAction = self:schedule(function()
		-- body

		self:hidePanel_()
	end, 3.5)
end

function SignInSuccPopup:onCleanup()
	-- body

	self:stopAction(self._hidePanelAction)
end

return SignInSuccPopup