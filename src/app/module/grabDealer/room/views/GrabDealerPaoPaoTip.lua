

local GrabDealerPaoPaoTip = class("GrabDealerPaoPaoTip", 
function() 
	return display.newNode() 
end)

function GrabDealerPaoPaoTip:ctor()
	
end

function GrabDealerPaoPaoTip:createNode_(data)
	self:stopAction(self.action_)
	self:cleanNode_()

	local userName;
	if not data.userName then
		userName = data.msg
	else
		userName = bm.LangUtil.getText("GRAB_DEALER", "WHO_GRAB",data.userName)
	end
	self.txt_ = display.newTTFLabel({text = userName, color = cc.c3b(0xff, 0xff, 0xff), size = 20, align = ui.TEXT_ALIGN_CENTER})

	local txtSize = self.txt_:getContentSize()

	self.width_ = txtSize.width + 50

	self.bg_ = display.newScale9Sprite("#grab_dealer_paopao.png", 0, 0, cc.size(self.width_, 41),
		cc.rect(55,20,2,2)
	)
	:addTo(self)
	self.txt_:addTo(self.bg_)
	self.txt_:pos(self.width_/2 , 41/2)

	self.action_ = self:schedule(function ()
	self:stopAction(self.action_)
		transition.fadeTo(self.bg_, {opacity = 0,time = 1,onComplete = handler(self,
							self.cleanNode_)
						})
	end,2)
end

function GrabDealerPaoPaoTip:cleanNode_()
	if self.txt_ then
		self.txt_:removeFromParent()
		self.txt_ = nil
	end
	if self.bg_ then
		self.bg_:removeFromParent()
		self.bg_ = nil
	end
end
function GrabDealerPaoPaoTip:show(data)
	self:createNode_(data)
end

function GrabDealerPaoPaoTip:onCleanup()

end
function GrabDealerPaoPaoTip:getWidth()
	return self.width_
end

return GrabDealerPaoPaoTip