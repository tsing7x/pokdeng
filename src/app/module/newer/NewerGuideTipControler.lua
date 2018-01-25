local NewerGuidePaopTip = import(".NewerGuidePaopTip")


local NewerGuideTipControler = class("NewerGuideTipControler")





function NewerGuideTipControler:ctor()
	self:addEvents()
	self:bindDataObserver()
end



 function NewerGuideTipControler:bindDataObserver()

    
end
 
function NewerGuideTipControler:unbindDataObserver()

    
end



function NewerGuideTipControler:addEvents()
	if not self.gameOverHandler_ then
		self.gameOverHandler_ = bm.EventCenter:addEventListener(nk.DailyTasksEventHandler.REPORT_GAME_OVER, handler(self, self.onReportGameOver_))
	end

	if not self.onDataObserver_ then
		self.onDataObserver_ = bm.EventCenter:addEventListener(nk.eventNames.UPDATE_SEAT_INVITE_VIEW, handler(self, self.sitStatusFunc))
	end
	
end

function NewerGuideTipControler:removeEvents()
	if self.gameOverHandler_ then
		bm.EventCenter:removeEventListener(self.gameOverHandler_)
		self.gameOverHandler_ = nil
	end

	if not self.onDataObserver_ then
		bm.EventCenter:removeEventListener(self.onDataObserver_)
		self.onDataObserver_ = nil
	end
	
end





function NewerGuideTipControler:sitStatusFunc(evt)

	local runScene = evt.data.ctx.scene 

	if not runScene then
		return
	end

	if "RoomSceneEx" ~= runScene.name then
		return
	end

	local ctx = evt.data.ctx;
	local seatId = evt.data.seatId;
	local standUpSeatId = evt.data.standUpSeatId;
	local tid = ctx.model.roomInfo.tid
	local grabBtn = runScene.grabDealerBtn
	if not grabBtn then
		return
	end

	local isSelfInSeat = ctx.model:isSelfInSeat()
	if not isSelfInSeat then
		return
	end

	local grabBtnPosX,grabBtnPosY = grabBtn:getPosition()
	local grabBtnSize = grabBtn:getContentSize()
	local parent = grabBtn:getParent()
	if not tid then
		return
	end
	if (9 == seatId) then
		--只要有人坐下庄家位都不提示
		return
	end

	local hasDealer = (ctx.model:getHaveDealer() == 1) and true or false
	if hasDealer then
		return
	end
	-- if 9 == standUpSeatId then
		--判断当前房间是否显示过，是则不提示
		if not self.tidDealer_ then
			self.tidDealer_ = {}
			
		else
			local idx = table.indexof(self.tidDealer_,tid)
			if idx then
				return
			end
		end

		local dealerNeedCoin = checkint(ctx.model:getGrabDealerNeedCoin())
		if dealerNeedCoin > 0 and nk.userData["aUser.money"] >= dealerNeedCoin then
			local needTip = self:checkShowRoomDealerToTip(bm.LangUtil.getText("NEWER", "GUIDE_ROOM_TO_DEALER"),parent,grabBtnPosX,grabBtnPosY- 100)
			if needTip then
				table.insert(self.tidDealer_,tid)
			end
		end

	-- end
end




function NewerGuideTipControler:onReportGameOver_(evt)
	--只在现金币场显示
	local runScene = evt.data.ctx.scene 

	if not runScene then
		return
	end
	if "GrabDealerRoomScene" ~= runScene.name then
		return
	end

	local data = evt.data
	local roomInfo = data.roomInfo
	local selfWin = data.selfWin
	local inSeat = data.inSeat
	local seatId = data.seatId
	local ctx = data.ctx

	local tid = roomInfo.tid
	if not tid then
		return
	end
	--判断当前房间是否显示过，是则不提示
	if not self.tidWin_ then
		self.tidWin_ = {}
	else
		local idx = table.indexof(self.tidWin_,tid)
		if idx then
			return
		end
	end

	if not selfWin then
		return
	end

	if not ctx or not ctx.seatManager then
		return
	end

	--庄家位置
	local dealerPos = ctx.seatManager:getSeatPosition(9);
	if not dealerPos then
		return
	end

	local seatView = ctx.seatManager:getSeatView(9) 
	local seatViewSize = seatView:getContentSize()

	local seatNode = runScene.nodes.seatNode
	local gPoint = seatNode:convertToWorldSpace(cc.p(dealerPos.x+180,dealerPos.y))
	local grabDealerNode = runScene.nodes.grabDealerUINode
	local nPoint = grabDealerNode:convertToNodeSpace(gPoint)
	local parent = grabDealerNode

	-- local needTip = self:checkShowRoomCashWinTip(bm.LangUtil.getText("NEWER", "GUIDE_ROOM_CASH_WIN"),parent,nPoint.x,nPoint.y)
	-- if needTip then
	-- 	table.insert(self.tidWin_,tid)
	-- end
end

function NewerGuideTipControler:dispose(clean)
	if clean then
		self:removeEvents()
		self:unbindDataObserver()
	end
end





--direction: [ARROW POS DIRECTION] <详见参数 ARROW POS DIRECTION>,
-- 		toward: [ARROW MAGRIN TOWARD] <详见参数 ARROW MAGRIN TOWARD>,
-- 		magrin: type(magrin) == "number", 箭头固定边距距离.
function NewerGuideTipControler:checkShowHallCashTip(tipStr,parent,x,y)
	local cashNum = nk.userData['match.point']
	if checkint(cashNum) > 10 then
		if not self.hallCashTip_ then
			x = x or 0
			y = y or 0
			local tipTxt = display.newTTFLabel({text = tipStr, size = 28, align = ui.TEXT_ALIGN_CENTER,dimensions = cc.size(250, 100)})
			self.hallCashTip_ = NewerGuidePaopTip.new(tipTxt,NewerGuidePaopTip.BOTTOM_CENTER,10)
			:pos(x,y)
			:addTo(parent,999)
			-- :playFadeInAnim(0.5,0,255)

			local action = cc.FadeIn:create(1.5)
    		local actionBack = action:reverse()

    		local action1 = cc.FadeIn:create(1.5)
    		local action1Back = action1:reverse()

    		local action2 = cc.FadeIn:create(1.5)
    		local action2Back = action2:reverse()
	        
    		 -- self.hallCashTip_.tipsLabel_:runAction(cc.Sequence:create( array))
    		 self.hallCashTip_.borderMain_:runAction(cc.RepeatForever:create(cc.Sequence:create(action,actionBack)))
    		 -- self.hallCashTip_.tipsArrow_:runAction(cc.Sequence:create( array))
    		 self.hallCashTip_.tipsArrow_:runAction(cc.RepeatForever:create(cc.Sequence:create(action1,action1Back)))
    		 self.hallCashTip_.tipsLabel_:runAction(cc.RepeatForever:create(cc.Sequence:create(action2,action2Back)))
		

			--5秒后自动消失
			self.hallCashTip_:performWithDelay(handler(self,function(ctx)
				if ctx.hallCashTip_ then
					ctx.hallCashTip_:removeFromParent()
				end
			end),5)

			self.hallCashTip_:setNodeEventEnabled(true)
			self.hallCashTip_.onCleanup = function()
				self.hallCashTip_ = nil
			end
		end
	end
end



function NewerGuideTipControler:checkShowRoomCashWinTip(tipStr,parent,x,y)
	local winTipStr = nk.userDefault:getStringForKey(nk.cookieKeys.DAILY_GUIDE_TIP_CASH_WIN) 
	local needTip = false
	local count = 0
	if winTipStr == "" then
		--无记录
		needTip = true
		count = count + 1
	else
		--有记录
		local dateTb = string.split(winTipStr, ",")
		count = checkint(dateTb[1])
		local date = dateTb[2]
		if date == os.date("%Y%m%d") then
			if count < 5 then
				needTip = true
				count = count + 1
				
			else
				needTip = false
			end

		else
			needTip = true
		end
	end

	if not needTip then
		return false
	end

	winTipStr = count .. "," ..os.date("%Y%m%d")
	nk.userDefault:setStringForKey(nk.cookieKeys.DAILY_GUIDE_TIP_CASH_WIN, winTipStr)
	
	if not self.roomCashWinTip_ then
		x = x or 0
		y = y or 0
		local tipTxt = display.newTTFLabel({text = tipStr, size = 28, align = ui.TEXT_ALIGN_CENTER,dimensions = cc.size(250, 100)})
		self.roomCashWinTip_ = NewerGuidePaopTip.new(tipTxt,NewerGuidePaopTip.CENTER_LEFT,10)
		:pos(x,y)
		:addTo(parent,99)
		:playFadeInAnim(0.5,0,255)

		--5秒后自动消失
		self.roomCashWinTip_:performWithDelay(handler(self,function(ctx)
			if ctx.roomCashWinTip_ then
				ctx.roomCashWinTip_:removeFromParent()
			end
		end),5)

		self.roomCashWinTip_:setNodeEventEnabled(true)
		self.roomCashWinTip_.onCleanup = function()
			self.roomCashWinTip_ = nil
		end
	end

	return true
end



function NewerGuideTipControler:checkShowRoomDealerToTip(tipStr,parent,x,y)
	local dealerTipStr = nk.userDefault:getStringForKey(nk.cookieKeys.DAILY_GUIDE_TIP_TO_DEALER) 
	local needTip = false
	local count = 0
	if dealerTipStr == "" then
		--无记录
		needTip = true
		count = count + 1
	else
		--有记录
		local dateTb = string.split(dealerTipStr, ",")
		count = checkint(dateTb[1])
		local date = dateTb[2]
		if date == os.date("%Y%m%d") then
			if count < 5 then
				needTip = true
				count = count + 1
				
			else
				needTip = false
			end

		else
			needTip = true
		end
	end

	if not needTip then
		return false
	end

	dealerTipStr = count .. "," .. os.date("%Y%m%d")
	nk.userDefault:setStringForKey(nk.cookieKeys.DAILY_GUIDE_TIP_TO_DEALER, dealerTipStr)
	
	if not self.roomDealerToTip_ then
		x = x or 0
		y = y or 0
		local tipTxt = display.newTTFLabel({text = tipStr, size = 28, align = ui.TEXT_ALIGN_CENTER,dimensions = cc.size(250, 100)})
		self.roomDealerToTip_ = NewerGuidePaopTip.new(tipTxt,NewerGuidePaopTip.CENTER_TOP,10)
		:pos(x,y)
		:addTo(parent,999)
		:playFadeInAnim(0.5,0,255)

		--5秒后自动消失
		self.roomDealerToTip_:performWithDelay(handler(self,function(ctx)
			if ctx.roomDealerToTip_ then
				ctx.roomDealerToTip_:removeFromParent()
			end
		end),5)

		self.roomDealerToTip_:setNodeEventEnabled(true)
		self.roomDealerToTip_.onCleanup = function()
			self.roomDealerToTip_ = nil
		end
	end

	return true
end


return NewerGuideTipControler