-- 公共参数 --

-- end --

local config = import(".Config")

local ViewItem = class("ViewItem", function()
	-- body
	return display.newNode()
end)

function ViewItem:ctor(itemData)
	-- body

	local HeadParam = {
		width = 73,
		height = 73
	}

	local FrontSizes = {
		name = 18,
		point = 22,
		reward = 18
	}

	local Colors = {
		name = cc.c3b(207, 211, 231),
		point = cc.c3b(244, 197, 33),
		reward = cc.c3b(207, 211, 231)
	}

	local txtMagrinLeft = 2
	local txtMagrinTopBottom = 2
	self:setNodeEventEnabled(true)

	self:setContentSize(cc.size(config.ListViewItemParam.WIDTH, config.ListViewItemParam.HEIGHT))
	self.headImageLoaderId_ = nk.ImageLoader:nextLoaderId()
	-- head -- 
	local headBorder = display.newScale9Sprite("#user_info_avatar_bg.png", 
		0, 0, cc.size(HeadParam.width, HeadParam.height)):pos(HeadParam.width / 2, HeadParam.height / 2):addTo(self)

	-- Data -- 

	local headUrl = itemData.mavatar

	local anteMoney = itemData.anteMoney
	local nameStr = itemData.name
	local reward = checkint(itemData.trunMoney)

	-- print(···)
	local pokerCards = itemData.cards
	local isWin = nil

	-- print("itemData.trunMoney:" .. reward)
	if reward == 0 then
		--todo
		-- do Nothing.
	else if reward > 0 then
		--todo
		-- print("itemData.trunMoney Win :" .. reward)
		isWin = true
		else
			--todo
			-- print("itemData.trunMoney Lose :" .. reward)
			isWin = false
		end
		
	end
	-- local isWin = itemData.trunMoney > 0

	local handPoker = require("app.module.room.model.HandPoker").new()
	handPoker:setCards(pokerCards)
	local point = handPoker:getTypeLabel()

	local expGet = itemData.getExp
	local isDealer = itemData.isDealer
	local seatId = itemData.seatId
	local uid = itemData.uid
	

	-- self:setTouchEnabled(false)
	-- self:setTouchSwallowEnabled(false)
	self._avatar = display.newSprite("#common_male_avatar.png")
		:pos(HeadParam.width / 2, HeadParam.height / 2)
		:addTo(self)

	self._avatar:scale(72 / self._avatar:getContentSize().width)
	-- local texture = display.newSpriteFrame("#common_male_avatar.png"):getTexture()

	if headUrl ~= nil and headUrl ~= "" then
		--todo
		-- texture = display.newSpriteFrame(headUrl):getTexture() 
		-- self._avatar:setTexture(texture)
		-- self._avatar = display.newSprite(headUrl)

		nk.ImageLoader:loadAndCacheImage(self.headImageLoaderId_,
                headUrl, 
                handler(self, self.loadCacheHeadImgCallBack),
                nk.ImageLoader.CACHE_TYPE_USER_HEAD_IMG)
	else
		--todo

		-- self._avatar:pos(HeadParam.width / 2, HeadParam.height / 2)
		-- self._avatar:addTo(self)
	end

	-- Name -- 
	local nameStrShownLenInPiexl = 66
	self._name = display.newTTFLabel({text = nk.Native:getFixedWidthText("", FrontSizes.name, (tostring(nameStr) or ""), nameStrShownLenInPiexl),
		size = FrontSizes.name, color = Colors.name, align = ui.TEXT_ALIGN_CENTER})
	
	self._name:setAnchorPoint(display.ANCHOR_POINTS[display.LEFT_CENTER])
	self._name:pos(HeadParam.width + txtMagrinLeft, self:getContentSize().height - self._name:getContentSize().height / 2 - txtMagrinTopBottom)
	self._name:addTo(self)

	-- Point --
	self._point = display.newTTFLabel({text = tostring(point), size = FrontSizes.point, color = Colors.point, align = ui.TEXT_ALIGN_CENTER})
	self._point:setAnchorPoint(display.ANCHOR_POINTS[display.LEFT_CENTER])
	
	self._point:pos(HeadParam.width + txtMagrinLeft * 2, HeadParam.height / 2)

	self._point:addTo(self)

	-- Reward -- 
	self._reward = display.newTTFLabel({text = tostring(reward), size = FrontSizes.reward, color = Colors.reward, align = ui.TEXT_ALIGN_CENTER})
	self._reward:setAnchorPoint(display.ANCHOR_POINTS[display.LEFT_CENTER])
	
	self._reward:pos(HeadParam.width + txtMagrinLeft, self._reward:getContentSize().height / 2 + txtMagrinTopBottom)
	self._reward:addTo(self)

	-- three Card -- 
	local scaleRate = 0.6
	-- local pokerCardMagrinEach = 2
	local pokerCardPosXControl = 66
	local pokerCardShitfX = 34
	local pokerCardSizeOriginal = {
		width = 80,
		height = 110
	}

	-- local PosXAdjustPiexl = 5
	local pokerCard = nk.ui.PokerCard
	local pokerCardList = {}
	for i = 1, #pokerCards do
		
		pokerCardList[i] = pokerCard.new()
						:setCard(pokerCards[i])
						:showFront()
						:scale(scaleRate)
		if i == 1 then
			--todo
			pokerCardList[i]:pos(HeadParam.width + txtMagrinLeft + pokerCardPosXControl + pokerCardSizeOriginal.width / 2 * scaleRate, HeadParam.height / 2)
						:addTo(self)
		else
			pokerCardList[i]:pos(HeadParam.width + txtMagrinLeft + pokerCardPosXControl + pokerCardShitfX * (i - 1) + pokerCardSizeOriginal.width / 2 * scaleRate, HeadParam.height / 2)
						:addTo(self)
		end
		
	end

	local colorMapHeight = 18
	local colorMapPosXShitf = 0.5
	-- local flagPosXFix = 5
	-- local loseFalgExtraFix = 5

	self._flagColorMap = display.newScale9Sprite("#flagColorMap-gr.png", HeadParam.width / 2 - colorMapPosXShitf, colorMapHeight / 2, cc.size(HeadParam.width, colorMapHeight))
		:addTo(self)


	if isWin == nil then
		--todo
		-- do Nothing.
	else if isWin then
		--todo
		self._winLoseSp = display.newSprite("#flagWin-gr.png")
		self._winLoseSp:pos(HeadParam.width / 2, colorMapHeight / 2)
	else
		self._winLoseSp = display.newSprite("#flagLose-gr.png")

		self._winLoseSp:pos(HeadParam.width / 2, colorMapHeight / 2)
	end
		--todo

	if self._winLoseSp then
			--todo
		self._winLoseSp:addTo(self)
	end
		
	end
	-- if isWin then
	-- 	--todo
	-- 	self._winLoseSp = display.newSprite("#flagWin-gr.png")
	-- 	self._winLoseSp:pos(HeadParam.width / 2, colorMapHeight / 2)
	-- else
	-- 	self._winLoseSp = display.newSprite("#flagLose-gr.png")

	-- 	self._winLoseSp:pos(HeadParam.width / 2, colorMapHeight / 2)
	-- end
	
	-- self._winLoseSp:addTo(self)
end

function ViewItem:loadCacheHeadImgCallBack(success, sprite)
	-- body

	local avatarShownEdgeLen = 72

	if success then

		local headTexture = sprite:getTexture()
		local size = headTexture:getContentSize()
        -- self.avatar_:setTexture(headTexture)
        
		if self._avatar == nil then
			--todo
			self._avatar = display.newSprite("#common_male_avatar.png")
		else
			self._avatar:setTexture(headTexture)
		end
		self._avatar:setTextureRect(cc.rect(0, 0, size.width, size.height))
        self._avatar:setScaleX(avatarShownEdgeLen / size.width)
        self._avatar:setScaleY(avatarShownEdgeLen / size.height)
	end
end

function ViewItem:onCleanup()
	-- body
	nk.ImageLoader:cancelJobByLoaderId(self.headImageLoaderId_)
end

return ViewItem