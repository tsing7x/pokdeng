local AuctionRow = class("AuctionRow", function()
	return display.newNode()
end)

AuctionRow.CLICKED_EVENT = "CLICKED_EVENT"

function AuctionRow:ctor(upImage,downImage)
	--if not upImage or not downImage then return end
	self.index_ = 1
	self.upBtn_ = cc.ui.UIPushButton.new(upImage, {scale9 = false})
	:onButtonClicked(buttontHandler(self, self.upBtnClk))
	:addTo(self)
	:show()
	self.downBtn_ = cc.ui.UIPushButton.new(downImage, {scale9 = false})
	:onButtonClicked(buttontHandler(self, self.downBtnClk))
	:addTo(self)
	:hide()
end

function AuctionRow:upBtnClk( ... )
	self:setState(2)
	self.clickCallback_()
	return self
end
function AuctionRow:downBtnClk( ... )
	self:setState(1)
	self.clickCallback_()
	return self
end


function AuctionRow:onButtonClicked(callback)
    self.clickCallback_ = callback
    return self
end
function AuctionRow:setState(index)
	if index > 2 then index = 1 end
	self.index_ = index
	if self.index_ == 1 then
		self.upBtn_:show()
		self.downBtn_:hide()
	elseif self.index_ == 2 then
		self.upBtn_:hide()
		self.downBtn_:show()
	end
end
function AuctionRow:getIndex()
	return self.index_
end

function AuctionRow:onCleanup()
	-- body
end

return AuctionRow