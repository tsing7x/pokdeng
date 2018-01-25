local WinLoseDetail = class("WinLoseDetail", function()
	-- body
	return display.newNode()
end)

function WinLoseDetail:ctor(data)
	-- body

	local detailContSize = {
		width = 200,
		height = 88
	}

	local nameStrFrontSize = 15
	local nameStrMagrinLeft = 5
	local nameStrMagrinTop = 5

	self:setContentSize(cc.size(detailContSize.width, detailContSize.height))

	local nameStr = data.name
	local pokerCards = data.pokerCards
	local winFalg = data.isWin

	self._nameTTF = ui.newTTFLabelMenuItem({text = nameStr, size = nameStrFrontSize, align = ui.TEXT_ALIGN_CENTER})
	self._nameTTF:setAnchorPoint(display.ANCHOR_POINTS[display.LEFT_CENTER])
	self._nameTTF:pos(nameStrMagrinLeft, self:getContentSize().height - self._nameTTF:getContentSize().height / 2 - nameStrMagrinTop)
	self._nameTTF:addTo(self)

	-- PokerCards --
	local pokerCard = nk.ui.PokerCard
	local pokerCardList = {}

	local pokerCardMagrinLeft = 4
	local pokerCardMagrinEach = 2
	local pokerCardSizeOriginal = {
		width = 80,
		height = 110
	}
	local scaleRate = 0.6

	for i = 1, 3 do
		pokerCardList[i] = pokerCard.new()
						:setCard(tonumber(string.sub(pokerCards[i], 1, 1), 16) * 16 + tonumber(string.sub(pokerCards[i], 2, 2), 16))
						:showFront()
						:scale(scaleRate)

		pokerCardList[i]:pos(pokerCardMagrinLeft + pokerCardSizeOriginal.width / 2 * scaleRate * (2 * i - 1) + pokerCardMagrinEach * (i - 1), pokerCardSizeOriginal.height / 2 * scaleRate)
		:addTo(self)
	end

	-- winLose Flag --
	local flagPosXFix = 5
	local winFalgExtraFix = 5
	if winFalg then
		--todo
		self._winLoseSpr = display.newSprite("#flag_win-gr.png")
		self._winLoseSpr:pos(pokerCardMagrinLeft + pokerCardSizeOriginal.width * scaleRate * 3 + pokerCardMagrinEach * 3 + self._winLoseSpr:getContentSize().width / 2 - flagPosXFix - winFalgExtraFix, 
							self._winLoseSpr:getContentSize().height / 2)
	else
		--todo
		self._winLoseSpr = display.newSprite("#flag_lose-gr.png")

		self._winLoseSpr:pos(pokerCardMagrinLeft + pokerCardSizeOriginal.width * scaleRate * 3 + pokerCardMagrinEach * 3 + self._winLoseSpr:getContentSize().width / 2 - flagPosXFix, 
							self._winLoseSpr:getContentSize().height / 2)
	end
	
	self._winLoseSpr:addTo(self)
end

return WinLoseDetail