local GrabDealerAdvanceNotice = class("GrabDealerAdvanceNotice", function() return display.newNode()end)
local BG_WIDTH = 275
local BG_HEIGHT = 155
function GrabDealerAdvanceNotice:ctor()
	self:setTouchEnabled(true)
    self:setTouchSwallowEnabled(true)
    self:setNodeEventEnabled(true)
    self.dataPool_ = {}

    self:createNode_()
    
end
function GrabDealerAdvanceNotice:createNode_()
	self.bg_ = display.newScale9Sprite("#grab_yugao_bg.png", 0, 0, cc.size(BG_WIDTH, BG_HEIGHT))
    :addTo(self)
    :pos(display.right -BG_WIDTH/2 ,display.top - BG_HEIGHT/2)

    display.newScale9Sprite("#grab_yugao_line.png",0,0,cc.size(BG_WIDTH, 2))
    :addTo(self.bg_)
    :pos(BG_WIDTH/2 ,BG_HEIGHT/2 - BG_HEIGHT/5 )
    --:pos(display.right -BG_WIDTH/2 ,display.top - BG_HEIGHT/2 - BG_HEIGHT/5 )

    display.newTTFLabel({text = T("上庄预告"), color = cc.c3b(0xfd, 0xff, 0xec), size = 26, align = ui.TEXT_ALIGN_LEFT})
    :addTo(self.bg_)
    :align(display.LEFT_CENTER)
    :pos( 8,BG_HEIGHT -25)
    --:pos(display.right -BG_WIDTH + 8,display.top -25)

    self.name_ = display.newTTFLabel({text = "玩家姓名玩家姓名", color = cc.c3b(0xff, 0xe4, 0x00), size = 22,dimensions = cc.size((BG_WIDTH-16)/2, 30), align = ui.TEXT_ALIGN_LEFT})
    :addTo(self.bg_)
    :align(display.LEFT_CENTER)
    :pos( 8,BG_HEIGHT/2)
    --:pos(display.right -BG_WIDTH + 8,display.top -BG_HEIGHT/2)

    local size = self.name_:getContentSize()

    self.coin_ = display.newTTFLabel({text = "携带金币携带金币", color = cc.c3b(0xff, 0xe4, 0x00), size = 22,dimensions = cc.size((BG_WIDTH-16)/2, 30), align = ui.TEXT_ALIGN_LEFT})
    :addTo(self.bg_)
    :align(display.LEFT_CENTER)
    :pos( 8 + size.width+8,BG_HEIGHT/2)
    --:pos(display.right -BG_WIDTH + 8 + size.width+8,display.top -BG_HEIGHT/2)

    self.nextDealer_ = display.newTTFLabel({text = T("欢迎上庄，下轮更新庄家位"), color = cc.c3b(0xa6, 0xa6, 0xa5), size = 18,dimensions = cc.size(BG_WIDTH-16, 22), align = ui.TEXT_ALIGN_CENTER})
    :addTo(self.bg_)
    :align(display.CENTER)
    :pos(BG_WIDTH/2, 22)
    --:pos(display.right -BG_WIDTH/2,display.top -BG_HEIGHT+ 22)

    --transition.fadeIn(self.contentNode, {time = 5})

    local action = transition.fadeTo(self.bg_, {opacity = 0,time = 0.1,onComplete = handler(self,
    	function()
    		transition.removeAction(action)
    		--transition.fadeTo(self.bg_, {opacity = 255,time = 0.1})
    	end)
    })


    -- self.rect_= display.newScale9Sprite("#rounded_rect_10.png", 0, 0, cc.size(BG_WIDTH, BG_HEIGHT))
    -- :addTo(self.bg_)
    self.isShow = false
    self.bg_:setTouchEnabled(false)
    self:setTouchEnabled(false)
    -- local data = {userName="thinker",handCoin = "4000",leftTurn="5"};
    -- local data1 = {userName="vanfo",handCoin= "3000",leftTurn="3"};
    -- local data2 = {userName="seanyang",handCoin= "2000",leftTurn="1"};
    -- self:addMsg(data)
    -- self:addMsg(data1)
    -- self:addMsg(data2)

    
end
function GrabDealerAdvanceNotice:hideNotice()
    self:stopAction(self.hideAction_)
    if self.isCanHide_ == true then
        transition.fadeTo(self.bg_, {opacity = 0,time = 2})
        self.bg_:setTouchEnabled(false)
         self:setTouchEnabled(false)
       -- self.bg_:removeNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.hideNotice))
    end
end
--外部调用该方法
function GrabDealerAdvanceNotice:addMsg(data)
	table.insert(self.dataPool_,data)
	self:showMsg()
end
--强制停止
function GrabDealerAdvanceNotice:stop()
    self:stopAction(self.hideAction_)
    self:stopAction(self.action_)
    self.isCanHide_ = true
    self.isShow = false
    transition.fadeTo(self.bg_, {opacity = 0,time = 2})
    self.dataPool_ = {}
end
function GrabDealerAdvanceNotice:update()
    if self.leftTurn_ and self.leftTurn_ >1 then
        self.leftTurn_ = self.leftTurn_-1
        self.nextDealer_:setString(bm.LangUtil.getText("GRAB_DEALER", "EXCHANGE_DEALER",self.leftTurn_))
    end
end

function GrabDealerAdvanceNotice:showMsg()
	if self.isShow == false then

        self.bg_:setTouchEnabled(true)
         self:setTouchEnabled(true)
        self.bg_:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.hideNotice))

		self.isShow = true
        self.isCanHide_ = false
		self:stopAction(self.action_)	
        self:stopAction(self.hideAction_)
		local showData = self.dataPool_[1]
		self.name_:setString(showData.userName or "")
		local coin = bm.formatBigNumber(showData.handCoin or 0)
		self.coin_:setString(coin)
        self.leftTurn_ = showData.leftTurn
		self.nextDealer_:setString(bm.LangUtil.getText("GRAB_DEALER", "EXCHANGE_DEALER",showData.leftTurn))
		transition.fadeTo(self.bg_, {opacity = 255,time = 0.2})
		self.index_ = 1
		self.action_ = self:schedule(
			function ()
				self.index_ = self.index_+1;
				if self.index_== 3 then
					self:stopAction(self.action_)	
					table.remove(self.dataPool_,1)
					self.isShow = false
					if #self.dataPool_ == 0 then
						-- transition.fadeTo(self.bg_, {opacity = 0,time = 2,onComplete = handler(self,
						-- 	function()
						-- 		self.isShow = false
						-- 	end)
						-- })
                        self.isCanHide_ = true

                        --跑30秒，让它消失
                        self.hideSeconds = 0
                        self.hideAction_ = self:schedule( 
                        function()
                            self.hideSeconds = self.hideSeconds+1
                            if self.hideSeconds >= 30 then
                                self:hideNotice()
                                self.isCanHide_ = false
                            end
                         end ,1)
					else
						self:showMsg()
					end
				end
		end,1)
	end
end
function GrabDealerAdvanceNotice:onCleanup()
	self:stopAction(self.action_)
    self:stopAction(self.hideAction_)
end

return GrabDealerAdvanceNotice